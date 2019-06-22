import cdk = require('@aws-cdk/cdk');
import ec2 = require('@aws-cdk/aws-ec2');
import ecs = require('@aws-cdk/aws-ecs');
import s3 = require('@aws-cdk/aws-s3');
import rds = require('@aws-cdk/aws-rds');
import { ContainerImage } from '@aws-cdk/aws-ecs';
import { PolicyStatement, PolicyStatementEffect } from '@aws-cdk/aws-iam';
import { Repository } from '@aws-cdk/aws-ecr';

export class CdkStack extends cdk.Stack {
  constructor(scope: cdk.Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    const dbPassword = Math.random()
      .toString(36)
      .substring(2, 15);

    // By default The VPC CIDR will be evenly divided between 1 public and 1 private subnet per AZ.
    const vpc = new ec2.Vpc(this, `VPC`, {
      maxAZs: 2,
      cidr: '10.0.0.0/16',
    });

    const dbSg = new ec2.SecurityGroup(this, 'DatabaseSecurityGroup', {
      vpc,
      description: 'Allows connection on port 5432 from Public VPC SG',
    });

    // Define bucket for assets
    const bucket = new s3.Bucket(this, `AssetsBucket`, {
      publicReadAccess: true,
    });

    const dbSubnetGroup = new rds.CfnDBSubnetGroup(this, `DatabaseSubnetGroup`, {
      dbSubnetGroupDescription: 'Database subnet group',
      subnetIds: vpc.privateSubnets.map(subnet => subnet.subnetId),
    });

    const database = new rds.CfnDBInstance(this, `Database`, {
      engine: 'postgres',
      engineVersion: '10.6',
      dbInstanceClass: 'db.t2.micro',
      vpcSecurityGroups: [dbSg.securityGroupId],
      masterUsername: id,
      dbName: id,
      masterUserPassword: dbPassword,
      dbSubnetGroupName: dbSubnetGroup.dbSubnetGroupName,
      allocatedStorage: '10',
    });

    // Define ECS Cluster
    const cluster = new ecs.Cluster(this, `Cluster`, { vpc });

    // Define ECS Service using Fargate with CloudWatch logs and LoadBalancer
    const service = new ecs.LoadBalancedFargateService(this, `Service`, {
      cpu: '256',
      memoryMiB: '512',
      createLogs: true,
      cluster,
      image: ContainerImage.fromEcrRepository(
        Repository.fromRepositoryName(this, 'terraform-vs-cdk', 'terraform-vs-cdk'),
        'latest',
      ),
      environment: {
        ASSETS_BUCKET: bucket.bucketName,
        DB_ENDPOINT: database.dbInstanceEndpointAddress,
        DB_USERNAME: id,
        DB_PASSWORD: dbPassword,
        DB_NAME: database.dbInstanceId,
      },
      containerPort: 3000,
    });

    // Allow connections to the DB from the service SG
    service.service.connections.securityGroups.forEach(sg => {
      dbSg.addIngressRule(sg, new ec2.TcpPort(5432));
    });

    // Allow Fargate task to manipulate S3 bucket
    const s3AccessPolicy = new PolicyStatement(PolicyStatementEffect.Allow);
    s3AccessPolicy.addAction('s3:*');
    s3AccessPolicy.addResource(bucket.bucketArn);

    // Attach policy
    service.service.taskDefinition.taskRole.addToPolicy(s3AccessPolicy);

    // Define service scaling
    const scaling = service.service.autoScaleTaskCount({
      maxCapacity: 2,
    });
    scaling.scaleOnCpuUtilization('CpuScaling', {
      targetUtilizationPercent: 50,
      scaleInCooldownSec: 60,
      scaleOutCooldownSec: 60,
    });

    new cdk.CfnOutput(this, 'LoadBalancerDNS', {
      value: service.loadBalancer.loadBalancerDnsName,
    });
  }
}

# Terraform vs AWS CDK - Comparison by building 2-tier Web Application

Goal of this repo is to compare provisioning of 2-tier web app with CDK and Terraform.

## Todo

- Terraform infra

## Intro

What we'll be building:
![Infra](assets/infra.svg?sanitize=true 'Infra')

Key points:

- VPC with two subnets (public and private) in each AZ, IPGW in Public, NAT Gateway in private
- ECS Cluster in Public Subnet running Fargate cluster with Node.js service and task
- Application Load Balancer exposed to the public connected to the Fargate service
- Public S3 bucket with assets
- IAM Role for task to manipulate S3 Bucket
- Serverless RDS Aurora MySQL-compatible instance in private subnet, accessible only from ECS tasks

For this comparison's sake we'll need a Docker image with a simple Express.js stored in ECR. Simply execute `./build-and-push.sh` to create an AWS Elastic Container Registry, build the Docker image and push it to the cloud.

## Prerequisites

- AWS CLI
- AWS CDK
- Docker
- Terraform

## CDK

- Imperative (consequences? code flow etc.)
- Can be written in TS, Java, Python
- Make sure that CDK and construct libraries are the same version
- API Changes pretty quickly, examples are outdated and require some adjustments like `loadBalancer.loadBalancerDnsName` vs loadBalancer.dnsName`
- Nested Stacks and 200 resources limit is cumbersome, still not resolved https://github.com/awslabs/aws-cdk/issues/239
- Can write custom resources which are like modules in Terraform
- Some of the constructs are really explicit making you wonder how you should correctly plug all the parts
- With higher level of abstraction you end up having more circular dependencies, e.g. ECS Service wants Database URL but database's SG needs to know from which SG it should allow the traffic

#### Initialization

```sh
cdk init app --language=typescript
```

We'll need ECS, EC2, S3 and RDS packages:

```
npm i @aws-cdk/aws-ecs @aws-cdk/aws-ec2 @aws-cdk/aws-s3 @aws-cdk/aws-rds
```

To render CloudFormation file:

```sh
npm run build && cdk synth
```

To deploy

```sh
cdk deploy
```

## Terraform

...

```sh
➜  find ./cdk/lib -name "*.ts" | xargs cat | wc -l
105
➜  find ./terraform -name "*.tf" | xargs cat | wc -l
516
```

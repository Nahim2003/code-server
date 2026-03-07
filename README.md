![CI](https://github.com/Nahim2003/code-server/actions/workflows/build-and-push.yml/badge.svg)
## Project Overview

This project deploys code-server to AWS using containerised infrastructure.

The environment is provisioned using Terraform and runs on ECS Fargate behind an
Application Load Balancer with HTTPS termination.

The goal of this project was to build a production-style container deployment
using AWS networking, load balancing, and infrastructure as code.

URL: https://tm.nahim-dev.com

## Architecture

Client → Route53 → ALB (443 HTTPS) → Target Group (HTTP 8080) → ECS Fargate Task (code-server)
<p align="center">
  <img src="https://github.com/user-attachments/assets/b7e5128e-4cbf-43c1-aa9e-9fb246d058bc" width="700" alt="ECS architecture diagram" />
</p>

## Tech Stack

- AWS ECS Fargate
- Application Load Balancer
- Route 53
- AWS Certificate Manager
- Amazon VPC
- Terraform
- Docker
- Amazon ECR
- code-server

## Deployment Flow

1. A Docker image is built for the code-server application.
2. The image is pushed to **Amazon ECR**.
3. **Terraform** provisions the AWS infrastructure including:
   - VPC
   - Public subnets
   - Application Load Balancer
   - ECS cluster and service
   - Route53 DNS configuration
4. The **ECS Fargate service** pulls the container image from ECR.
5. The **Application Load Balancer** routes HTTPS traffic to the ECS tasks.
6. The container runs **code-server** on port `8080`.
7. ALB health checks (`/login`) ensure the container is healthy and available.

## Key Config

* code-server binds: 0.0.0.0:8080

- Target group: ip targets, port 8080

- Health check: GET /login (200–399)

- HTTPS terminated at ALB (ACM cert)

- Image built for linux/amd64 (required for Fargate)

## Deploy
terraform init
terraform apply

## Build + Push (ECR)
aws ecr get-login-password --region us-east-1 \
| docker login --username AWS --password-stdin 764283926008.dkr.ecr.us-east-1.amazonaws.com

docker buildx build --platform linux/amd64 -t ecs-codeserver:vX .
docker tag ecs-codeserver:vX 764283926008.dkr.ecr.us-east-1.amazonaws.com/ecs-codeserver:vX
docker push 764283926008.dkr.ecr.us-east-1.amazonaws.com/ecs-codeserver:vX

## Force ECS redeploy
aws ecs update-service \
  --region us-east-1 \
  --cluster ecs-codeserver-tf-cluster \
  --service ecs-codeserver-tf-service \
  --force-new-deployment

## Verify
curl -I https://tm.nahim-dev.com/login
aws elbv2 describe-target-health --region us-east-1 --target-group-arn <TG_ARN>

## Debugging Highlights

* Fixed 502/503/504 from port/health-check mismatches

- Fixed WebSocket errors by aligning ALB → container flow

- Fixed CannotPullContainerError (linux/amd64) with buildx --platform linux/amd64

- Resolved Terraform SG rule drift via import/state cleanup
## Live demo
<video src="https://github.com/user-attachments/assets/97e836b8-d4f1-44a7-9b36-869e3638e794"
       width="700"
       controls>
</video>

## CI/CD Pipeline

The project uses GitHub Actions to automatically deploy updates.

Pipeline flow:

1. Push code to `main`
2. GitHub Actions builds the Docker image
3. Image is pushed to Amazon ECR
4. ECS service is forced to deploy the new image
5. Health check verifies the application is running

This enables automated end-to-end deployment.

## Future Improvements

- Implement CI/CD using GitHub Actions
- Add CloudWatch logging and monitoring
- Configure ECS service autoscaling
- Deploy ECS tasks in private subnets
- Add WAF protection in front of the ALB

## Lessons Learned

While building this project I encountered several real-world deployment issues:

- **ALB health check failures** caused ECS tasks to continuously drain.
- **WebSocket errors** when accessing code-server through the load balancer.
- **Docker architecture mismatch** between ARM (local machine) and AMD64 (ECS runtime).
- **Target group misconfiguration** that caused tasks to register but fail health checks.
- **Terraform state conflicts** when modifying security group rules.

Debugging these issues improved my understanding of:

- ECS service deployments
- ALB target groups and health checks
- Docker image architecture
- Terraform infrastructure lifecycle

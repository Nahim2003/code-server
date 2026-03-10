# code-server on AWS ECS Fargate

This project deploys **code-server** to AWS using containerised infrastructure.

The environment is provisioned using **Terraform** and runs on **ECS Fargate** behind an **Application Load Balancer with HTTPS termination**.

The goal of this project was to build a production-style container deployment using AWS networking, load balancing, infrastructure as code, and CI/CD automation.

---

# Live Demo

URL:  
https://tm.nahim-dev.com


<img width="345" height="67" alt="Screenshot 2026-03-10 at 23 23 30" src="https://github.com/user-attachments/assets/006d9de4-91b0-4c7b-8c8e-e105609cf6b6" />


---

# Architecture

Request flow:

Client → Route53 → ALB (HTTPS 443) → Target Group (HTTP 8080) → ECS Fargate Task → code-server

## Architecture Diagram

<img width="1371" height="1356" alt="ecs diagram drawio" src="https://github.com/user-attachments/assets/08db8087-b820-451c-a4f9-56594b89fc44" />


---

# Tech Stack

- AWS ECS Fargate
- Application Load Balancer
- Amazon Route53
- AWS Certificate Manager (ACM)
- Amazon VPC
- Terraform
- Docker
- Amazon ECR
- GitHub Actions
- code-server

---

# Local Setup

Clone the repository:

```bash
git clone https://github.com/Nahim2003/code-server.git
cd code-server
```

Build the Docker image:

```bash
docker build -t ecs-codeserver .
```

Run the container locally:

```bash
docker run -p 8080:8080 ecs-codeserver
```

Open in browser:

```
http://localhost:8080
```

---

# Project Structure

```
.
├── .github/workflows
│   ├── build-and-push.yml
│   ├── deploy-infra.yml
│   └── destroy-infra.yml
├── infra
│   ├── main.tf
│   ├── backend.tf
│   ├── provider.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── acm.tf
│   ├── iam.tf
│   ├── ecs_exec.tf
│   └── modules
│       ├── alb
│       ├── ecs
│       └── vpc
├── wrapper
│   └── code-server
├── Dockerfile
├── start.sh
└── README.md
```

---

# Deployment Flow

1. A Docker image is built for the code-server application.
2. The image is pushed to **Amazon ECR**.
3. **Terraform** provisions the AWS infrastructure including:
   - VPC
   - public subnets
   - Application Load Balancer
   - ECS cluster and service
   - Route53 DNS configuration
   - ACM certificate
4. The ECS Fargate service pulls the container image from ECR.
5. The Application Load Balancer routes HTTPS traffic to ECS tasks.
6. The container runs **code-server on port 8080**.
7. ALB health checks ensure the container is healthy.

---

# Key Configuration

code-server bind address:

```
0.0.0.0:8080
```

Target group configuration:

```
Type: ip
Port: 8080
```

Health check configuration:

```
Path: /login
Success codes: 200-399
```

HTTPS is terminated at the **Application Load Balancer using ACM certificates**.

Docker image is built for:

```
linux/amd64
```

This is required for ECS Fargate.

---

# Deploy Infrastructure

```
terraform init
terraform apply
```

---

# Build and Push Docker Image

Authenticate to ECR:

```
aws ecr get-login-password --region us-east-1 \
| docker login --username AWS --password-stdin 764283926008.dkr.ecr.us-east-1.amazonaws.com
```

Build and push the container:

```
docker buildx build --platform linux/amd64 -t ecs-codeserver:vX .

docker tag ecs-codeserver:vX \
764283926008.dkr.ecr.us-east-1.amazonaws.com/ecs-codeserver:vX

docker push \
764283926008.dkr.ecr.us-east-1.amazonaws.com/ecs-codeserver:vX
```

---

# Force ECS Redeploy

```
aws ecs update-service \
--region us-east-1 \
--cluster ecs-codeserver-tf-cluster \
--service ecs-codeserver-tf-service \
--force-new-deployment
```

---

# Verify Deployment

```
curl -I https://tm.nahim-dev.com/login
```

Check target health:

```
aws elbv2 describe-target-health \
--region us-east-1 \
--target-group-arn <TARGET_GROUP_ARN>
```

---

# Live Demo

Demo recording:


[recording-2026-03-10-23-34-53.webm](https://github.com/user-attachments/assets/6c83d00a-309e-4f30-b0df-dbeb1ac7b6a3)



---

# CI/CD Pipeline

The project uses **GitHub Actions** to automate deployments.

Pipeline flow:

1. Push code to `main`
2. GitHub Actions builds the Docker image
3. The image is pushed to **Amazon ECR**
4. ECS service deploys the new container
5. Health checks confirm the application is running

This enables automated end-to-end deployment.

---

# Pipeline Screenshots

## Build and Push Pipeline

<img width="1430" height="791" alt="Screenshot 2026-03-07 at 00 23 00" src="https://github.com/user-attachments/assets/8384ee59-9f84-4dd7-8dd1-910d6720c57c" />

## Deploy Infrastructure Pipeline

<img width="1436" height="697" alt="Screenshot 2026-03-07 at 00 27 04" src="https://github.com/user-attachments/assets/dac3f0b5-67aa-4912-9302-a1f9185605fe" />

## Destroy Infrastructure Pipeline

```
![Destroy Pipeline](pipeline-destroy.png)
```

---

# Debugging Highlights

During development several real-world deployment issues were encountered:

- 502 / 503 / 504 errors caused by **port and health-check mismatches**
- WebSocket issues when accessing code-server through the load balancer
- Docker architecture mismatch between **ARM (local machine)** and **AMD64 (ECS runtime)**
- Target group misconfiguration causing tasks to register but fail health checks
- Terraform security group rule drift requiring **state cleanup**

---

# Lessons Learned

While building this project I encountered several infrastructure challenges:

- ECS tasks draining due to failing ALB health checks
- WebSocket connectivity issues behind the load balancer
- Docker architecture mismatches between development and production
- Terraform state conflicts when modifying security group rules

These debugging sessions improved my understanding of:

- ECS service deployments
- ALB target groups and health checks
- Docker multi-architecture builds
- Terraform infrastructure lifecycle
- CI/CD deployment pipelines

---

# Future Improvements

- Add Terraform **plan pipeline**
- Implement **CloudWatch monitoring and alarms**
- Configure **ECS service autoscaling**
- Deploy ECS tasks in **private subnets**
- Add **AWS WAF** in front of the ALB

---

# Deployment Status

This project was successfully deployed to **AWS ECS Fargate behind an Application Load Balancer with HTTPS using Route53 and ACM**.

The infrastructure has since been **destroyed to avoid ongoing AWS charges**, but the full Terraform configuration, CI/CD pipelines, and project documentation remain available in this repository.

## ECS Fargate + code-server (Terraform)

Deploys code-server (VS Code in the browser) on AWS using ECS Fargate, ALB (HTTPS), ACM, Route 53, and ECR, fully managed with Terraform.

URL: https://tm.nahim-dev.com

Architecture

Client → Route53 → ALB (443 HTTPS) → Target Group (HTTP 8080) → ECS Fargate Task (code-server)

Key Config

code-server binds: 0.0.0.0:8080

Target group: ip targets, port 8080

Health check: GET /login (200–399)

HTTPS terminated at ALB (ACM cert)

Image built for linux/amd64 (required for Fargate)

Deploy
terraform init
terraform apply

Build + Push (ECR)
aws ecr get-login-password --region us-east-1 \
| docker login --username AWS --password-stdin 764283926008.dkr.ecr.us-east-1.amazonaws.com

docker buildx build --platform linux/amd64 -t ecs-codeserver:vX .
docker tag ecs-codeserver:vX 764283926008.dkr.ecr.us-east-1.amazonaws.com/ecs-codeserver:vX
docker push 764283926008.dkr.ecr.us-east-1.amazonaws.com/ecs-codeserver:vX

Force ECS redeploy
aws ecs update-service \
  --region us-east-1 \
  --cluster ecs-codeserver-tf-cluster \
  --service ecs-codeserver-tf-service \
  --force-new-deployment

Verify
curl -I https://tm.nahim-dev.com/login
aws elbv2 describe-target-health --region us-east-1 --target-group-arn <TG_ARN>

Debugging Highlights

Fixed 502/503/504 from port/health-check mismatches

Fixed WebSocket errors by aligning ALB → container flow

Fixed CannotPullContainerError (linux/amd64) with buildx --platform linux/amd64

Resolved Terraform SG rule drift via import/state cleanup

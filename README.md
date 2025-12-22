# ECS Code-Server Project

## 1. Overview

Short summary (2–4 sentences):

- What this project is:
  - A containerised deployment of code-server behind a Node.js reverse proxy.
- What it’s for:
  - Simulates a real production-style workload to be deployed on ECS Fargate.
- Key tech:
  - Node.js, code-server, Docker, AWS ECS, ALB, Route 53, ACM, Terraform, GitHub Actions (eventually).

Example prompts for yourself:
- “This project exposes VS Code in the browser via code-server, fronted by a Node.js wrapper that provides a `/health` endpoint and proxies traffic to code-server.”
- “The final goal is to run this container on ECS Fargate, fronted by an Application Load Balancer with HTTPS and a custom domain.”

---

## 2. Architecture

### 2.1 High-level design

Explain the main pieces in a few bullets:

- `code-server`:
  - Runs VS Code in the browser on port **8080** inside the container.
- `Node.js wrapper`:
  - Listens on port **3000**.
  - Exposes `/health` → `{"status": "ok"}`.
  - Proxies all other traffic to `code-server` on `http://127.0.0.1:8080`.
- Docker:
  - Multi-stage build:
    - **builder stage**: Node 18, runs `npm install` for the wrapper.
    - **runtime stage**: `codercom/code-server` + Node runtime + your `start.sh`.
- ECS (planned / implemented):
  - Fargate service running this container.
  - ALB listening on 80/443.
  - Target group pointing to the ECS service.
  - Route 53 record → ALB.
  - ACM cert for HTTPS.

### 2.2 Architecture diagram

Add a section for a diagram (you can link to an image or use Mermaid):

```md
![Architecture Diagram](./docs/architecture.png)


*(Just leave a placeholder if you haven’t drawn it yet.)*

---

## 3. Project Structure

Describe your repo layout:

```md
```bash
.
├── app/
│   ├── Dockerfile
│   ├── start.sh
│   ├── README.md
│   └── wrapper/
│       └── code-server/
│           ├── package.json
│           ├── package-lock.json
│           ├── server.js
│           └── ...
└── infra/           # (Terraform, later)
    ├── main.tf
    ├── modules/
    └── ...


Then a short bullet list:

- `wrapper/code-server/server.js` – Express app exposing `/health` and proxying to `code-server`.
- `start.sh` – Entrypoint script that:
  - starts `code-server` in the background,
  - then starts the Node wrapper in the foreground.
- `Dockerfile` – Multi-stage build combining Node wrapper + code-server.
- `infra/` – Terraform configuration to recreate the AWS stack (once you add it).

---

## 4. Running Locally with Docker

Explain how to build and run the container:

```md
### 4.1 Prerequisites

- Docker installed (Docker Desktop or similar).
- (Optional) curl for testing.

### 4.2 Build the image

```bash
cd app
docker build -t ecs-codeserver .

### 4.3 Run the container

docker run --rm -p 3000:3000 ecs-codeserver


You should see logs like:
Starting code-server...
Starting node wrapper...
Proxy server is running on http://localhost:3000
4.4 Verify health and proxy
curl http://localhost:3000/health
# {"status":"ok"}

curl -I http://localhost:3000/
# HTTP/1.1 302 Found
# location: ./login

---

## 5. Docker Image Design

You can briefly document the Dockerfile logic:

```md
### 5.1 Builder stage

- Base image: `node:18-slim`
- `WORKDIR /app/wrapper/code-server`
- `COPY wrapper/code-server/package*.json ./`
- `RUN npm install`
- `COPY wrapper/code-server/ .`

### 5.2 Runtime stage

- Base image: `codercom/code-server:latest`
- Installs `nodejs` + `npm` via `apt-get`.
- `WORKDIR /app/wrapper/code-server`
- Copies built app from builder stage.
- Copies `start.sh` and uses it as `ENTRYPOINT`.
- Exposes port `3000`.
6. AWS Deployment (ClickOps) – Summary
You can fill this in as you do the AWS side:
## 6. AWS Deployment (ECS Fargate)

### 6.1 ECR

- Created an ECR repository: `<your-repo-name>`
- Tagged and pushed the image:

```bash
docker tag ecs-codeserver <account-id>.dkr.ecr.<region>.amazonaws.com/ecs-codeserver:<tag>
docker push <account-id>.dkr.ecr.<region>.amazonaws.com/ecs-codeserver:<tag>
6.2 ECS + ALB
ECS Cluster: <cluster-name> (Fargate).
Task Definition:
Container image: ECR image above.
Container port: 3000.
Service:
Behind an Application Load Balancer.
Target group health check on /health.
6.3 Route 53 + ACM
ACM certificate for tm.<your-domain> (in us-east-1 for ALB).
ALB HTTPS listener (443) using that certificate.
Route 53 A/CNAME record: tm.<your-domain> → ALB DNS.
Final URL: https://tm.<your-domain> (or https://tm.labs.<your-domain>).

---

## 7. Terraform (IaC) – Placeholder

Once you do Terraform, you can expand this:

```md
## 7. Infrastructure as Code (Terraform)

- `infra/main.tf` – root config.
- Modules:
  - `vpc/` – VPC + subnets + routing.
  - `ecs/` – ECS cluster, task definition, service.
  - `alb/` – Application Load Balancer + listener + target group.
  - `ecr/` – ECR repository.
  - `acm/` – certificate.
  - `route53/` – DNS record.

### 7.1 Usage

```bash
cd infra
terraform init
terraform plan
terraform apply

---

## 8. CI/CD (GitHub Actions) – Placeholder

Template for when you add it:

```md
## 8. CI/CD (GitHub Actions)

- Workflow: `.github/workflows/deploy.yml`
- Jobs:
  - **build-and-push**:
    - Build Docker image.
    - Tag with Git SHA.
    - Push to ECR.
  - **terraform-deploy**:
    - `terraform fmt`, `validate`, `plan`, `apply`.
    - Uses GitHub OIDC with AWS (no static keys).
  - **post-deploy-check**:
    - `curl https://tm.<your-domain>/health`
    - Fails pipeline if unhealthy.
9. Screenshots
Leave placeholders and fill them later:
## 9. Screenshots

- [ ] Docker container running locally and logs visible.
- [ ] `/health` check output from curl.
- [ ] code-server UI in the browser via `http://localhost:3000`.
- [ ] Deployed app on AWS via `https://tm.<your-domain>`.
10. Future Improvements / Notes
A small section for reflection:
Use non-root user in the final image.
Slim down image size (multi-stage + only runtime deps).
Parameterise port / target URL via env vars.
Add secrets management (SSM / Secrets Manager).

FROM node:18-slim AS builder

WORKDIR /app/wrapper/code-server

COPY wrapper/code-server/package*.json ./
RUN npm install
RUN ls -R /app
COPY wrapper/code-server/ .

FROM codercom/code-server:latest

USER root

RUN apt-get update && apt-get install -y nodejs npm
RUN rm -rf /var/lib/apt/lists/*

WORKDIR /app/wrapper/code-server

COPY --from=builder /app/wrapper/code-server /app/wrapper/code-server
COPY start.sh ./start.sh

EXPOSE 3000
ENTRYPOINT ["./start.sh"]

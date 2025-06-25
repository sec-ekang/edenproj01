## Lab 1: Docker Compose – Step-by-Step Guide

### 1. Prerequisites

- **Prepare the following files:**
    - `Dockerfile`
    - `docker-compose.yml`
    - `Jenkinsfile`

### 2. Environment Setup

- **Provision a VM:**  
  At least 2 cores, 8GB RAM (single VM for both Jenkins and web server)
- **Install Ubuntu Linux**  
- **Install Docker and Jenkins**  
- **Install Jenkins essential plugins**

### 3. Jenkins & Slack Integration

- **Connect Jenkins to Slack:**
    - Create a Slack access token
    - Create a Slack channel and workspace
    - Configure Slack integration in Jenkins

### 4. Docker Hub Integration

- **Generate Docker Hub access token**
- **Register Docker Hub credentials (username & token) in Jenkins**

- **Create a Docker Hub repository** for your application

### 5. Jenkinsfile Adjustments

- Set `APP_NAME` to your Docker Hub repository name
- Set `DOCKER_HUB_USER` to your Docker Hub username
- Check image push section matches Docker Hub ID
- Set correct Jenkins agent/node label

### 6. Permissions & User Management

- **Add Jenkins user to the Docker group**  
  ```bash
  sudo usermod -aG docker jenkins
  sudo systemctl restart jenkins
  ```
- **Set folder permissions for Jenkins**  
  ```bash
  sudo chown -R jenkins:jenkins /home/user01/sock-shop
  # Or, if preferred:
  sudo chown -R user01:jenkins /home/user01/sock-shop
  sudo chmod -R 775 /home/user01/sock-shop
  sudo systemctl restart jenkins
  ```

### 7. Docker Compose Usage

- Ensure correct file permissions for `docker-compose.yml`
- Recommended: **fetch docker-compose file directly from GitHub**

### 8. GitHub & Jenkins Integration

- Generate Jenkins SSH key  
- Add public key to GitHub (read/write access)
- Generate GitHub token and register it in Jenkins credentials
- Test connection:
  ```bash
  sudo -u jenkins ssh -T git@github.com
  ```

### 9. Important Notes

- Use matching names for Docker Hub images and GitHub repos
- Do **not** fetch source directly from GitHub in the Dockerfile
- Cleanup: Pipeline errors may leave uncleaned files; perform regular cleanups

---

## Key Files Overview

### Dockerfile
- Multi-stage build (builder and production)
- Runs Node.js application as non-root user
- Sets healthchecks and entrypoint

### docker-compose.yml
- Defines multiple microservices for Sock Shop demo
- Uses variables for image tags and credentials
- Maps service ports and sets container options
- Avoid Jenkins (8080) and front-end port conflicts

### Jenkinsfile
- Multi-stage pipeline: checkout, cleanup, build, push, deploy
- Uses Docker for building and pushing images
- Deploys using Docker Compose
- Sends Slack notifications for success/failure
- Cleans up workspace and old Docker images

### Clean-up Script (Clean_pipeline_errors.sh)
- Removes stopped containers, unused images, volumes, networks
- Cleans Jenkins workspace and logs
- Removes old artifacts and temp files

---

## General Workflow

1. **Source Code Checkout** from GitHub
2. **Remove Old Docker Images/Containers**
3. **Build and Push New Docker Image** to Docker Hub
4. **Deploy Using Docker Compose**
5. **Clean up resources and notify via Slack**


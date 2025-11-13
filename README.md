# AWS Containerized Web App

![Web App Screenshot](./screenshot-webapp.png)

This project is a containerized static web application that runs on AWS.  
Locally it is served from a Docker container using Apache on Rocky Linux.  
In the cloud it is deployed behind an Application Load Balancer using Amazon ECS with Fargate and a private ECR image.

---

## Features

- Rocky Linux 8 base image
- Apache HTTP server inside a Docker container
- Static landing page built with HTML and inline CSS
- Port 80 exposed for HTTP traffic
- Image stored in Amazon ECR
- ECS service running on Fargate in multiple Availability Zones
- Application Load Balancer distributing traffic across tasks
- IAM roles and access keys used for secure access to AWS services

---

## Running Locally with Docker

You can still run this app locally without touching AWS:

1. Install Docker on your machine.
2. Open a terminal in the project folder.
3. Build the image: `docker build -t project-image .`
4. Run the container: `docker run -d -p 80:80 --name project-container project-image`
5. Open a browser and visit: `http://localhost`

---

## Cloud Architecture Overview

The cloud version of this project is not just “docker run on EC2.”  
It uses several AWS services working together:

- **EC2 instance**  
  Used as a build machine to install Docker, build the image, and push it to ECR.

- **IAM user and access keys**  
  Created an IAM user, generated an access key and secret key, then configured the AWS CLI using `aws configure` so the EC2 host can talk to ECR.

- **IAM roles**  
  - An EC2 or admin-style role with permission to work with ECR.  
  - An ECS task execution role (`AmazonECSTaskExecutionRolePolicy`) so ECS can pull images and write logs.

- **Amazon ECR (Elastic Container Registry)**  
  Private repository that stores the built Docker image.  
  The image is tagged and pushed from the EC2 instance to this repo.

- **Amazon ECS with Fargate**  
  Manages the running containers. A task definition describes how to run the container (image URI, port mapping, CPU and memory), and a service keeps the desired number of tasks running across multiple Availability Zones.

- **Application Load Balancer (ALB)**  
  Internet facing ALB with listeners on port 80 that forwards traffic to a target group registered with the ECS service. This gives you high availability and simple scaling.

---

## AWS Deployment Steps (Summary)

High level steps that were actually done:

1. **Launch EC2 instance**
   - Amazon Linux
   - Created or selected an SSH key pair
   - Configured a security group for SSH (22) and HTTP (80)

2. **Install and start Docker on EC2**
   - Downloaded Docker install script and installed Docker packages
   - Verified with `docker --version`
   - Started the Docker service and confirmed it was active

3. **Create project on EC2**
   - Created a `project` directory
   - Wrote `Dockerfile` using `rockylinux:8`, installed `httpd`, copied `index.html`, exposed port 80, and started Apache in the foreground
   - Created `index.html` for the landing page

4. **Build and test the container**
   - Built the image with a tag (for example `project-image`)
   - Ran the container mapping host port 80 to container port 80
   - Hit the EC2 public IP in a browser to confirm the site worked

5. **Create ECR repository**
   - Opened Amazon ECR and created a private repository for the image
   - Copied the repository URI for later use

6. **Set up IAM and CLI authentication**
   - Created or used an IAM user
   - Generated an access key and secret access key
   - Configured `aws configure` on the EC2 instance (AWS access key, secret key, region, output format)
   - Ensured an IAM role with sufficient permissions (AdministratorAccess for demo) existed and that ECS task execution role policy was available

7. **Log in to ECR and push the image**
   - Used the ECR login command to authenticate the local Docker client to ECR
   - Tagged the local image with the full ECR URI
   - Pushed the tagged image to ECR

8. **Create Application Load Balancer**
   - Created an internet facing ALB
   - Selected the default VPC and at least two or three subnets across Availability Zones
   - Attached a security group allowing HTTP from the internet
   - Created a target group with HTTP health checks

9. **Create ECS task definition**
   - New task definition using Fargate launch type
   - Container definition used the ECR image URI and container port 80
   - Selected the ECS task execution IAM role
   - Set basic CPU and memory settings

10. **Create ECS cluster and service**
    - Created an ECS cluster in the default VPC and selected subnets in multiple Availability Zones
    - Created a service using the task definition and Fargate
    - Set desired task count (for example 2) for high availability
    - Attached the ALB and target group so traffic from the ALB flows into the tasks

11. **Validate the deployment**
    - Copied the ALB DNS name
    - Opened it in a browser and confirmed the landing page loaded
    - Checked ECS service and target group health status to confirm both tasks were healthy

---

## Future Improvements

- Add a simple API backend for dynamic data instead of a purely static page
- Use HTTPS with a certificate through AWS Certificate Manager
- Add auto scaling for ECS tasks based on CPU or request count
- Add CloudWatch logging and dashboards
- Integrate CI/CD so new commits build and push images automatically

---

## Author

Kamil Bisbis  
Built as a hands on project to practice Docker, AWS IAM, ECR, ECS, load balancers, and containerized web hosting.
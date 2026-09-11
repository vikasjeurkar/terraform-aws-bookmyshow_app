# terraform_code
# AWS Infrastructure Deployment using Terraform

## 📌 Project Overview

This project demonstrates how to deploy a **highly available AWS web application infrastructure using Terraform (Infrastructure as Code)**.

The infrastructure is created in the **AWS Mumbai (`ap-south-1`) region** and includes:

* Custom VPC
* Two public subnets across two Availability Zones
* Internet Gateway
* Public Route Table
* Security Groups
* Two EC2 web servers
* Application Load Balancer (ALB)
* Target Group
* ALB Listener
* Health Checks
* Terraform Outputs

The Application Load Balancer distributes incoming HTTP traffic across both EC2 web servers.

---

## 🏗️ Architecture

```text
                         Internet
                            |
                            | HTTP :80
                            |
                    +------------------+
                    | Application      |
                    | Load Balancer    |
                    |      (ALB)       |
                    +--------+---------+
                             |
                  +----------+----------+
                  |                     |
                  | HTTP :80            | HTTP :80
                  |                     |
          +-------v-------+     +-------v-------+
          | EC2 WebServer |     | EC2 WebServer |
          |      1        |     |      2        |
          | ap-south-1a   |     | ap-south-1b   |
          +-------+-------+     +-------+-------+
                  |                     |
                  +----------+----------+
                             |
                    +--------v--------+
                    |      VPC        |
                    |  10.0.0.0/16    |
                    +-----------------+

             Public Subnet 1       Public Subnet 2
             10.0.0.0/24           10.0.1.0/24
             ap-south-1a           ap-south-1b
```

---

## 🚀 AWS Resources Created

### 1. VPC

A custom VPC is created with the CIDR block provided through the Terraform variable.

```text
VPC
CIDR: var.cidr
Region: ap-south-1
```

DNS support and DNS hostnames are enabled.

---

### 2. Public Subnets

Two public subnets are created in different Availability Zones.

| Subnet          | CIDR          | Availability Zone |
| --------------- | ------------- | ----------------- |
| Public Subnet 1 | `10.0.0.0/24` | `ap-south-1a`     |
| Public Subnet 2 | `10.0.1.0/24` | `ap-south-1b`     |

Both subnets have:

```text
map_public_ip_on_launch = true
```

This allows EC2 instances launched in these subnets to receive public IP addresses.

---

### 3. Internet Gateway

An Internet Gateway is attached to the VPC.

It provides internet connectivity for resources in the public subnets.

```text
Internet
   |
Internet Gateway
   |
  VPC
```

---

### 4. Route Table

A public route table is created with the following default route:

```text
0.0.0.0/0 → Internet Gateway
```

Both public subnets are associated with this route table.

---

### 5. Application Load Balancer

An internet-facing **Application Load Balancer** is created.

Configuration:

```text
Load Balancer Type: Application
Scheme: Internet-facing
Port: 80
Protocol: HTTP
```

The ALB receives requests from the internet and forwards them to the EC2 web servers.

---

### 6. ALB Security Group

The ALB security group allows HTTP traffic from the internet.

```text
Inbound:
TCP 80 → 0.0.0.0/0

Outbound:
All traffic
```

---

### 7. EC2 Security Group

The EC2 security group allows HTTP traffic only from the ALB security group.

```text
ALB Security Group
        |
        | TCP 80
        v
EC2 Web Servers
```

SSH access is also enabled on port 22.

> ⚠️ For production environments, replace `0.0.0.0/0` for SSH with your trusted public IP address.

---

### 8. EC2 Web Servers

Two EC2 instances are created.

| Server      | Subnet          | Availability Zone |
| ----------- | --------------- | ----------------- |
| WebServer-1 | Public Subnet 1 | ap-south-1a       |
| WebServer-2 | Public Subnet 2 | ap-south-1b       |

Both instances use:

```text
Instance Type: t3.micro
```

User-data scripts are used to configure the web servers automatically during instance launch.

```text
userdata.sh
userdata1.sh
```

---

### 9. Target Group

An Application Load Balancer target group is created for the EC2 instances.

```text
Protocol: HTTP
Port: 80
Health Check Path: /
```

Both EC2 instances are registered as targets.

The ALB uses health checks to determine whether the web servers are healthy.

---

### 10. ALB Listener

The ALB listens for HTTP requests on port 80.

```text
Client
  |
  | HTTP :80
  v
ALB Listener
  |
  v
Target Group
  |
  +----> WebServer-1
  |
  +----> WebServer-2
```

---

# 📂 Project Structure

Recommended project structure:

```text
terraform-aws-alb-project/
│
├── main.tf
├── variables.tf
├── outputs.tf
├── userdata.sh
├── userdata1.sh
├── terraform.tfvars
├── .gitignore
└── README.md
```

---

# 🛠️ Prerequisites

Before running this project, install and configure:

### 1. Terraform

Terraform version:

```text
>= 1.5.0
```

Verify:

```bash
terraform version
```

### 2. AWS CLI

Verify:

```bash
aws --version
```

Configure AWS credentials:

```bash
aws configure
```

Enter:

```text
AWS Access Key ID
AWS Secret Access Key
Default region: ap-south-1
Output format: json
```

> Never commit AWS access keys or secret keys to GitHub.

---

# ⚙️ Configuration

The VPC CIDR is provided through a Terraform variable.

Example `variables.t

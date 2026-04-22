# AWS EKS Fargate Deployment with Terraform

This project provides a comprehensive, production-ready Terraform configuration to deploy a serverless Amazon Elastic Kubernetes Service (EKS) cluster using AWS Fargate. 

The infrastructure is designed for high availability across three availability zones, implementing a strict separation between public and private networking.

## 🚀 Overview

This deployment automates the creation of a full EKS environment without the need to manage EC2 worker nodes. By utilizing AWS Fargate, your Kubernetes pods run in a serverless environment, reducing operational overhead.

### Key Features
- **Serverless Compute**: Uses AWS Fargate for pod execution.
- **High Availability**: Deployed across 3 Availability Zones (AZs).
- **Secure Networking**: 
  - Public subnets for Load Balancers and NAT Gateways.
  - Private subnets for EKS Cluster and Fargate pods.
- **Integrated Add-ons**:
  - **AWS Load Balancer Controller**: Automatically manages AWS ALBs and NLBs.
  - **Metrics Server**: Provides resource metrics for HPA (Horizontal Pod Autoscaler).
  - **CoreDNS**: Optimized for Fargate execution.
- **IAM Integration**: Implements OIDC provider for IAM Roles for Service Accounts (IRSA).
- **CI/CD Ready**: Includes a Jenkins pipeline for automated deployment and verification.

## 🏗 Architecture

### Networking
- **VPC**: Custom VPC with a public/private subnet split.
- **Public Subnets**: Host NAT Gateways and Public Load Balancers.
- **Private Subnets**: Host the EKS control plane and Fargate pods.
- **Connectivity**: Private subnets route outbound traffic through NAT Gateways in the public subnets.

### Components
- **EKS Cluster**: The Kubernetes control plane.
- **Fargate Profile**: Defines which pods (by namespace) should run on Fargate (`default` and `kube-system`).
- **OIDC Provider**: Enables pods to assume IAM roles for AWS service access.
- **Helm Releases**:
  - `aws-load-balancer-controller`: Manages ingress traffic.
  - `metrics-server`: Enables pod monitoring.

## 📋 Prerequisites

Before deploying, ensure you have the following installed and configured:

- [Terraform](https://developer.hashicorp.com/terraform) (`>= 1.5.0`)
- [AWS CLI](https://aws.amazon.com/cli/) (Configured with appropriate credentials)
- [kubectl](https://kubernetes.io/docs/home/)
- [Helm](https://helm.sh/)

## 🛠 Deployment

### 1. Clone the repository
```bash
git clone <repository-url>
cd aws-terraform-eks-farget-deployment
```

### 2. Initialize and Apply
Navigate to the deployment directory:
```bash
cd deploy
terraform init
terraform apply
```

### 3. Configure Kubectl
After the apply is complete, Terraform will output a command to update your kubeconfig. Copy and run that command:
```bash
# Example output from terraform:
aws eks update-kubeconfig --region us-east-1 --name eks-farget-cluster
```

## ⚙️ Configuration

You can customize the deployment by modifying `deploy/variable.tf` or using a `.tfvars` file.

| Variable | Description | Default |
|----------|-------------|---------|
| `region` | AWS region for deployment | `us-east-1` |
| `cluster_name` | Name of the EKS cluster | `eks-farget-cluster` |
| `cidr_block` | VPC CIDR block | `10.0.0.0/16` |
| `cidr_public_subnet_X` | CIDR for public subnets 1-3 | `10.0.1.0/24` etc. |
| `cidr_private_subnet_X` | CIDR for private subnets 1-3 | `10.0.4.0/24` etc. |

## 🔍 Project Structure

```text
.
├── deploy/
│   ├── vpc.tf                          # Network infrastructure (VPC, Subnets, NAT Gateways)
│   ├── iam.tf                          # IAM Roles and OIDC configuration
│   ├── eks_cluster.tf                  # EKS Cluster and Fargate Profile definition
│   ├── loadbalancer_controller.tf       # Helm chart for AWS LB Controller
│   ├── metrics_server.tf                # Helm chart for Metrics Server
│   ├── kubectl_path_deployment_coredns.tf # CoreDNS Fargate configuration
│   ├── variable.tf                      # Input variables
│   ├── output.tf                        # Deployment outputs
│   ├── provider.tf                      # Terraform provider configuration
│   ├── required_providers.tf          # Provider version constraints
│   └── load_balancer_controller_iam_policy.json # IAM Policy for LB Controller
└── Jenkinsfile                         # CI/CD pipeline definition
```

## 🔄 CI/CD Pipeline

The project includes a `Jenkinsfile` that automates the infrastructure lifecycle.

### Pipeline Workflow
The pipeline consists of the following stages:
1. **Deploy EKS Cluster**: 
   - Initializes Terraform.
   - Validates the configuration.
   - Generates an execution plan.
   - Applies the changes automatically (`terraform apply --auto-approve`).
2. **Connect Kubectl Agent to EKS**:
   - Updates the local `kubeconfig` to allow communication with the new cluster.
   - Verifies connectivity by running `kubectl get svc`.

### Jenkins Configuration
To use the pipeline, ensure your Jenkins environment has:
- **AWS Credentials**: A credential ID named `aws_cred` configured with the necessary permissions to create EKS, VPC, and IAM resources.
- **Required Tools**: Terraform, AWS CLI, and Kubectl installed on the Jenkins agent.
- **Parameter**: The pipeline accepts a `BRANCH` parameter to specify which git branch to build (default: `master`).

## 🧹 Cleanup


To avoid ongoing AWS costs, destroy the infrastructure when it is no longer needed:

```bash
cd deploy
terraform destroy
```

---
*Note: This project is designed for EKS Fargate. Ensure your AWS account has sufficient quotas for the requested resources in the specified region.*

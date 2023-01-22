## Workspaces

- dev
- uat
- prod

## Stages:

1. dev: `export WORKSPACE=dev`
2. uat: `export WORKSPACE=uat`
3. prod: `export WORKSPACE=prod`

## Resources

### Network 

## Networking

All configurations were applied using Infrastructure as Code by terraform

Dev, UAT and Prod Environments are allowed to have workloads, therefore, the following VPCs (Virtual Private Cloud) have been created:

| AWS Account        | Cidr         | Description       |
| ------------------ | ------------ | ----------------- |
| dev                | 10.10.0.0/16 | Number of Nats: 1 |
| uat                | 20.20.0.0/16 | Number of Nats: 1 |
| prod               | 30.30.0.0/16 | Number of Nats: 1 |

### Subnets

Inside every VPC (Virtual Private Cloud) there are subnets to manage network traffic within the VPC leveraging robust security layers for your environments.

| Subnets Layer | Description                                      |
| ------------- | ------------------------------------------------ |
| Public        | This layer has public access, typically all workloads here will have a public access endpoint. AWS LoadBalancers and AWS NATs (Network Address Translation) will be deployed into this layer. |
| Private       | Private subnets are not public access, only public subnets can reach this layer. All outbound requests are routed to NATs (Network Address Translation) deployed on the public layer. Application workloads should be deployed into this layer. |
| Intra        | Intra subnets are not public access, they are only accessible from Private subnets and are ideal for data storage services. |

| AWS Account      | Subnet Type | Cidr            | Availabillity Zone |
| ---------------- | ----------- | --------------- | ------------------ |
| DEV              | Public-A    | 10.10.0.0/21    |  us-east-1a        |
| DEV              | Public-B    | 10.10.8.0/21    |  us-east-1b        |
| DEV              | Public-C    | 10.10.16.0/21   |  us-east-1c        |
| DEV              | Private-A   | 10.10.40.0/21   |  us-east-1a        |
| DEV              | Private-B   | 10.10.48.0/21   |  us-east-1b        |
| DEV              | Private-C   | 10.10.56.0/21   |  us-east-1c        |
| DEV              | Intra-A     | 10.10.80.0/21   |  us-east-1a        |
| DEV              | Intra-B     | 10.10.88.0/21   |  us-east-1b        |
| DEV              | Intra-C     | 10.10.96.0/21   |  us-east-1c        |
| UAT              | Public-A    | 20.20.0.0/20    |  us-east-1a        |
| UAT              | Public-B    | 20.20.8.0/20    |  us-east-1b        |
| UAT              | Public-C    | 20.20.16.0/20   |  us-east-1c        |
| UAT              | Private-A   | 20.20.40.0/20   |  us-east-1a        |
| UAT              | Private-B   | 20.20.48.0/20   |  us-east-1b        |
| UAT              | Private-C   | 20.20.56.0/20   |  us-east-1c        |
| UAT              | Intra-A     | 20.20.80.0/20   |  us-east-1a        |
| UAT              | Intra-B     | 20.20.88.0/20   |  us-east-1b        |
| UAT              | Intra-C     | 20.20.96.0/20   |  us-east-1c        |
| PROD             | Public-A    | 30.30.0.0/20    |  us-east-1a        |
| PROD             | Public-B    | 30.30.8.0/20    |  us-east-1b        |
| PROD             | Public-C    | 30.30.16.0/20   |  us-east-1c        |
| PROD             | Private-A   | 30.30.40.0/20   |  us-east-1a        |
| PROD             | Private-B   | 30.30.48.0/20   |  us-east-1b        |
| PROD             | Private-C   | 30.30.56.0/20   |  us-east-1c        |
| PROD             | Intra-A     | 30.30.80.0/20   |  us-east-1a        |
| PROD             | Intra-B     | 30.30.88.0/20   |  us-east-1b        |
| PROD             | Intra-C     | 30.30.96.0/20   |  us-east-1c        |

## Terraform
1. `terraform init`
2. `terraform workspace new $WORKSPACE`
3. `terraform workspace list`
4. `terraform validate`
5. `terraform fmt --recursive`
6. `terraform plan --var-file=../envs/$WORKSPACE.tfvars`
7. `terraform apply --var-file=../envs/$WORKSPACE.tfvars`

  To switch the workspace run this command

8. `terraform workspace list`
9. `terraform workspace select <workspace name>`

  To destroy terraform resources run this command

10. `terraform destroy --var-file=../envs/<workspace>.tfvars`
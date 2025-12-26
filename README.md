# terraform-vpc-eks
Created VPC, EKS using terraform

Change s3 bucket, dynamodb table name, region in backend.tf file

## Follow below commands to run the terraform
```bash
terraform init
terraform plan -var-file=dev.tfvars
terraform apply -var-file=dev.tfvars
```

Destroy the  resources
```bash
terraform destroy -var-file=dev.tfvars
```
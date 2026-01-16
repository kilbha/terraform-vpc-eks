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

## Updating K8s Cluster
Get supported addon for given cluster version
```bash
aws eks describe-addon-versions     --addon-name <addon-name>     --kubernetes-version <cluster-version>     --query "addons[].addonVersions[?compatibilities[0].defaultVersion==\`true\`].addonVersion"     --output text
```

Check kubelet version
```bash
kubectl describe node <node-name> | grep -i kubelet
```

Check autoscaler version
```bash
kubectl get deployment cluster-autoscaler -n kube-system \
  -o=jsonpath='{.spec.template.spec.containers[0].image}'
```
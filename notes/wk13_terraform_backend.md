
# Verifying a Terraform S3/DynamoDB remote backend using AWS CLI 
## Verifying the s3 bucket

```bash
aws s3 ls
aws s3 ls s3://${bucket_name} --recursive
```
## get remote `tfstate` file

```bash
aws s3api get-object --bucket ${bucket_name} --key terraform.tfstate ${output_file}
```
## Remove all files from bucket

```bash
aws s3api delete-objects     --bucket ${bucket_name} --delete "$(aws s3api list-object-versions \
    --bucket ${bucket_name} \
    --output=json \
    --query='{Objects: Versions[].{Key:Key,VersionId:VersionId}}')"
```
  
```bash
aws s3 rm s3://${bucket_name} --recursive
``` 
## Delete the bucket

```bash
aws s3 rb s3://${bucket_name} --force
```

## Verify the DyanmoDB table

```bash
aws dynamodb list-tables
aws dynamodb scan --table-name ${table_name}
```

## GitOps

GitOps is a little like DevOps in that isn't a tool or framework that you can add to your projects.

"GitOps uses a Git repository as the single source of truth for infrastructure definitions." - GitLab docs

Code that defines your infrastructure is pushed to a Git repository. From there merge or pull requests are used to trigger a CI/CD pipeline that will provision your infrastructure. Your CI/CD pipeline could be a service like Spacelift, or GitHub actions... The tools you use often depends on your needs and personal preferences of your development team. 

Automating some of these components allow teams to deploy updates faster and experiment with new features. In theory when you have a working pipeline it is relatively easy to create a new branch that would allow you to try out a new feature in an isolated environment.


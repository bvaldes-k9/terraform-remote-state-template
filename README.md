# Terraform Remote State Template
![Static Badge](https://img.shields.io/badge/Terraform-V1.8.0-%23844FBA?logo=terraform) ![Static Badge](https://img.shields.io/badge/AWS_CLI-V2.15.19-%23232F3E?logo=amazonaws)

- Infrastructure template that creates S3 bucket and DynamoDB table, which we then transfer terraform state to said S3 bucket which will then host our remote state.

![Terraform Remote state](https://github.com/bvaldes-sol/terraform-remote-state-template/assets/88116524/129ddd90-4064-4b39-8b3c-ce232666ada1)

- Picture
## Who is this for?

- This project is useful to AWS Terraform Admins or Devs looking to have a reusable template to quickly standup remote state infrastructure with more simplicity to add to their IAC infrastructure.
- DynamoDB Table allows for multiple users to collab on the remote state but prevents more than one to issue  commands to protect the state file.

## Installation
- AWS IAM user with S3, DynamoDB Access permissions
- AWS CLI
- Terraform

### AWS
#### AWS IAM User 

• Configure an IAM user with the Amazon S3 and DynamoDB Access.
• Then ensure in your user creation the IAM has your programmatic access created too.

#### AWS CLI setup

• Setup is based on your machine's operating system please follow AWS documententation linked below as its the most up to date and fastest process o download/configure.
- https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html


### AWS Configurations

• After creating your user that has programmatic access to with permissions to services you will be deploying on AWS, you head to your terminal and issue the cmd. 
- `$ aws configure --profile insert-name-here`

• Follow the prompts and fill in the data you have from your programmtic access.


### Terraform
#### Terraform CLI setup

• Setup is based on your machine's operating system please follow Hashicorp documententation linked below as its the most up to date and fastest process o download/configure.
- https://learn.hashicorp.com/tutorials/terraform/install-cli



## Configuration
### Terraform


#### `variable.tf` resources

The backend are the specifices to where you want the backend state. You'll notice in the file that it's considered description with "#" in front of the them. We want to deploy our host infrastructure first(The S3 bucket and Dynamo DB) then once that's done and applied, we come back here remove the "#" and use the "terraform init" cmd and the state will be moved to your specified bucket.

PLEASE WAIT TO DEPLOY INFRASTRUCTURE FIRST BEFORE REMOVING "#"
- backend "s3"
    -      bucket          = "insert-bucket-name-from-bucket-name-variable"
    -      key             = "file-folder-name-on-s3/terraform.tfstate"
    -      region          = "aws-region-for-s3"
    -      dynamodb_table  = "dynamo-name"
    -      encrypt         = true

- variable "provider_region"
    -       default     = "aws-region"


The below number is set to 30 to help with keeping cost down change based on your needs for deletion window.
- variable "kms_key_deletion_window"
    -       default     = "30"

- variable "kms_key_alias" 
  -     default     = "kms-key-name"

S3 bucket name here must match the provider section.
- variable "s3_bucket_name" 
  -     default     = "s3-bucket-name"

Days before moving a version to long term storage glacier
- variable "transition_noncurrent_days" 
  -     default     = 7

I recommend glacier storage for your price saving but change this on your use case.
- variable "storage_class"
  -     default     = "GLACIER"

Specifies days noncurrent object versions expire.
- variable "expiration_noncurrent_days" 
  -     default     = 8

Must Ensure this matches the provider section
- variable "dynamodb_table_name" 
  -     default     = "dynamo-name"

Change the billing based on your use case and how often you change the terraform state.
- variable "dynamodb_table_billing_mode"
  -     default     = "PAY_PER_REQUEST"

Do not change this or the DynamoDB table will fail, this prevents the multiple users of making changes to the state file at once.
- variable "lock_key_id"
  -     default     = "LockID"



```console
foo@bar:~$ terraform init

foo@bar:~$ terraform fmt

foo@bar:~$ terraform plan

foo@bar:~$ terraform apply
```
Afterwards it may take some time for the infrastructure to be completed, once's it's done we can go back to our `variable.tf` and remove the "#" from our lines of code like the gif below.

![2024-05-12_15-56-05_1](https://github.com/bvaldes-sol/terraform-remote-state-template/assets/88116524/cf2048df-36d3-4e11-83a3-014358004e6f)



- `bucket = custom-bucket-name`

- If your testing and add the below value you will have to manually delete every file afterwards when cleaning up.
     - `change lifecycle = true`
     - `prevent_destroy = true`

## Usage
- Now that we're setup, ensure your at the file directory and run the following commands, if you get stuck seek my troubleshoot section.




## Clean up
All done? 
- Lets start with deleting the cluster with the cmd:
    - `$ kops delete cluster cluster-name --yes`

- Head over to AWS terminal, route53 or your registar and delete the CNAME records you created for prometheus and grafana on Route53

- After kops delete and records is completed you can head out of ansible/ and now towards terraform/, to clean up terraform issue the destroy command 
- `$ terraform destory -auto-approve`

## Troubleshoot
• Beware if you redeploy and make too many changes to your domain's name servers you may have to either flush your DNS or change your local DNS server to such as 8.8.8.8, 1.1.1.1, etc.
A good way to test if your issue is the above is two options
- Use the cmd: 
    - $ `dig NS yoursubdomain.yourdomain.com`
    - which you should see 4 nameservers appear if route53 or your registar is configured correctly.
    
- If you've followed all the steps but still cant access the subdomain then it is likely this issue and changing your DNS server or cache, you'll see your subdomains. Just remember either to change your DNS server or flush your cache.

• If your cluster seems to be stuck on validation check and see if they can be SSH'd. If the servers are unreachable ensure that if you've made any adjustments to the vpc, subnets, routes are correctly configured.

• There has been issue if you have a hosted zone for your domain as this will deploy another hosted-zone for your domain. For testing purposes if you face any trouble with reaching nameservers with the cmd `dig NS yoursubdomain.domain.com` then delete the hosted zone thats not managed by terraform and retry again.


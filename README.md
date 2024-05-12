# Terraform Remote State Template
![Static Badge](https://img.shields.io/badge/Terraform-V1.8.0-%23844FBA?logo=terraform) ![Static Badge](https://img.shields.io/badge/AWS_CLI-V2.15.19-%23232F3E?logo=amazonaws)

- Infrastructure template that creates S3 bucket and DynamoDB table, which we then transfer terraform state to said S3 bucket which will then host our remote state.

### | [Installation](#installation) | [Configuration](#configuration) | [Usage](#usage) | [Clean Up](#clean-up) | [Troubleshoot](#troubleshoot) |

![Terraform Remote state](https://github.com/bvaldes-sol/terraform-remote-state-template/assets/88116524/129ddd90-4064-4b39-8b3c-ce232666ada1)

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

• Setup is based on your machine's operating system please follow AWS documententation linked below as its the most up to date and fastest process to download and configure.
- https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html


### AWS Configurations

• After creating your user that has programmatic access to with permissions to services you will be deploying on AWS, you head to your terminal and issue the cmd. 
- `$ aws configure --profile insert-name-here`

• Follow the prompts and fill in the data you have from your programmtic access.


### Terraform
#### Terraform CLI setup

• Setup is based on your machine's operating system please follow Hashicorp documententation linked below as its the most up to date and fastest process to download and configure.
- https://learn.hashicorp.com/tutorials/terraform/install-cli



## Configuration

### Terraform


#### `variable.tf` resources

The backend are the specifices to where you want the backend state. You'll notice in the file that it's considered description with "#" in front of the them. We want to deploy our host infrastructure first(The S3 bucket and Dynamo DB) then once that's done and applied, we come back here remove the "#" and use the "terraform init" cmd and the state will be moved to your specified bucket.

PLEASE WAIT TO DEPLOY INFRASTRUCTURE FIRST BEFORE REMOVING "#" We'll follow this process in the Usage Section.
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

## Usage

- Now that we're setup, ensure your at the file directory and run the following commands, if you get stuck seek my troubleshoot section.

```console
foo@bar:~$ terraform init

foo@bar:~$ terraform fmt

foo@bar:~$ terraform plan

foo@bar:~$ terraform apply
```
Afterwards it may take some time for the infrastructure to be completed, once's it's done we can go back to our `variable.tf` and remove the "#" from our lines of code like the gif below.

![2024-05-12_15-56-05_1](https://github.com/bvaldes-sol/terraform-remote-state-template/assets/88116524/cf2048df-36d3-4e11-83a3-014358004e6f)

After these changes you can run the following cmd to move the state file.
```console
foo@bar:~$ terraform init
```

## Clean Up

All done? 
- Lets start with migrating the remote state back to local and then deleting the resources. 
- First you'll need to add back the comment out to the backend block in `variables.tf` Similar to how it was before removing them but in reverse.
![2024-05-12_15-56-05_1](https://github.com/bvaldes-sol/terraform-remote-state-template/assets/88116524/cf2048df-36d3-4e11-83a3-014358004e6f)

- Once you've saved the file changes and commented out the backend block we can migrate the state file.

```
foo@bar:~$ terraform init -migrate-state

Initializing the backend...
Terraform has detected you're unconfiguring your previously set "s3" backend.
Do you want to copy existing state to the new backend?
  Pre-existing state was found while migrating the previous "s3" backend to the
  newly configured "local" backend. No existing state was found in the newly
  configured "local" backend. Do you want to copy this state to the new "local"
  backend? Enter "yes" to copy and "no" to start with an empty state.

  Enter a value: yes



Successfully unset the backend "s3". Terraform will now operate locally.

Initializing provider plugins...
- Reusing previous version of hashicorp/aws from the dependency lock file
- Using previously-installed hashicorp/aws v5.46.0

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```
- You can now test to see if the migrated state has worked by running `terraform plan` if you get no errors then we can proceed to delete our created resources.

- First you'll need to delete the objects we created within our S3 bucket.
- Head over to the S3 bucket and delete the objects in it.
![delete s3 object](https://github.com/bvaldes-sol/terraform-remote-state-template/assets/88116524/e701e35d-e7ff-4fe0-82f4-05ee6cbb1a39)
- To delete resources created by terraform run the following commmand
```
terraform destroy
```
- if you face any issue with terraform destory make sure you deleted any objects within the s3 bucket first before issueing the `terraform destroy` command. If you face any other issues check below the troubleshoot section.

## Troubleshoot
 #### Error acquiring the state lock

```
│ Error message: operation error DynamoDB: PutItem, https response error StatusCode: 400, 
RequestID: XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX, 
ConditionalCheckFailedException: The conditional request failed
│ Lock Info:
│   ID:        XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX
│   Path:      S3-bucket-name/terraform-remote-state-template/terraform.tfstate
│   Operation: migration source state
│   Who:       Your-machine\Foo@Bar
```
- When faced with this error it's typically because a process is still running and terraform doesnt want to have multiple process running thanks to our LockID. Once you've confirmed no one else is intentially running a process and it's just an error'd out process you can run the following command. Understand there is a chance of further endangering the state file which can make recovery even more diffcult. 
```
foo@bar:~$ terraform force-unlock XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX
Do you really want to force-unlock?
  Terraform will remove the lock on the remote state.
  This will allow local Terraform commands to modify this state, even though it
  may still be in use. Only 'yes' will be accepted to confirm.

  Enter a value: yes

Terraform state has been successfully unlocked!

The state has been unlocked, and Terraform commands should now be able to
obtain a new lock on the remote state.

```
- If your concerned that there is truly another process running and want to play it on the more safe side, it's recommend to wait an hour and then check with "terraform init" to see if the issue persist. If it does persisit then it's more likely to be a stuck process and running the unlock command is the resolution.

- Make sure to get the ID from the lock info "ID:" and replace the XXXX's with that.
This command will kill that on going process allowing for new process to begin.

- Then you can continue with terraform init and terraform plan.
#

#### Terraform Destroy Error

```
aws_s3_bucket.tf_backend: Destroying... [id=s3-bucket-name]
╷
│ Error: deleting S3 Bucket (ocean-omega435-tf-state-backend): operation error S3: DeleteBucket, 
    https response error StatusCode: 409, 
    RequestID: XXXXXXXXXXXXXXXX, 
    HostID: /XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX=, 
    api error BucketNotEmpty: The bucket you tried to delete is not empty. You must delete all versions in the bucket.
```
- this error occurs when versioning has been going on and even if you deleted the objects manually from the S3 bucket the versions could still exist. You'll then need to delete the S3 bucket manually and will ask you to confirm when you. Afterwards run the `terraform destroy` command and you'll be cleared up.
#
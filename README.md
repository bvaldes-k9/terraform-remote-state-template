# terraform-remote-state-template
- Badges

Infrastructure template to create S3 bucket and DynamoDB table to then transfer terraform state to remote state on bucket. 


- Picture


# Installation
- AWS CLI
- AWS IAM user with S3, dynamoDB Access permissions
- Terraform

## AWS
AWS CLI setup

• Setup is based on your machine's operating system please follow AWS documententation linked below as its the most up to date and fastest process o download/configure.
- https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html

AWS IAM User 

• Configure an IAM user with the Amazon S3 and DynamoDB Access.
• Then ensure in your user creation the IAM has your programmatic access created too.


## AWS Configurations

• After creating your user that has programmatic access to with permissions to services you will be deploying on AWS, you head to your terminal and issue the cmd. 
- `$ aws configure --profile insert-name-here`

• Follow the prompts and fill in the data you have from your programmtic access.


## Terraform
Terraform CLI setup

• Setup is based on your machine's operating system please follow Hashicorp documententation linked below as its the most up to date and fastest process o download/configure.
- https://learn.hashicorp.com/tutorials/terraform/install-cli



# Configuration
### Terraform




`variable.tf` resources

- `bucket = custom-bucket-name`

- If your testing and add the below value you will have to manually delete every file afterwards when cleaning up.
     - `change lifecycle = true`
     - `prevent_destroy = true`

`provider.tf` resources




# Clean up
All done? 
- Lets start with deleting the cluster with the cmd:
    - `$ kops delete cluster cluster-name --yes`

- Head over to AWS terminal, route53 or your registar and delete the CNAME records you created for prometheus and grafana on Route53

- After kops delete and records is completed you can head out of ansible/ and now towards terraform/, to clean up terraform issue the destroy command 
- `$ terraform destory -auto-approve`

# Troubleshoot
• Beware if you redeploy and make too many changes to your domain's name servers you may have to either flush your DNS or change your local DNS server to such as 8.8.8.8, 1.1.1.1, etc.
A good way to test if your issue is the above is two options
- Use the cmd: 
    - $ `dig NS yoursubdomain.yourdomain.com`
    - which you should see 4 nameservers appear if route53 or your registar is configured correctly.
    
- If you've followed all the steps but still cant access the subdomain then it is likely this issue and changing your DNS server or cache, you'll see your subdomains. Just remember either to change your DNS server or flush your cache.

• If your cluster seems to be stuck on validation check and see if they can be SSH'd. If the servers are unreachable ensure that if you've made any adjustments to the vpc, subnets, routes are correctly configured.

• There has been issue if you have a hosted zone for your domain as this will deploy another hosted-zone for your domain. For testing purposes if you face any trouble with reaching nameservers with the cmd `dig NS yoursubdomain.domain.com` then delete the hosted zone thats not managed by terraform and retry again.


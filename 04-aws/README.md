# 04. Real resources in a real account

Everything so far ran against your own disk, where a mistake costs nothing. From here the resources are real, they cost money, and other people can see them. The commands do not change at all.

From now on the binary is `tofu`.

```
cd ~/learn-iac/04-aws
```

## 1. Check who you are

```
export AWS_PROFILE=shared-services-dev-MHI_ReadWriteBasic
aws sts get-caller-identity
```

If that fails, stop and say so. Nothing below works without it.

OpenTofu does not have its own way of holding credentials. The AWS provider uses the same lookup order as the AWS Command Line Interface, in order: environment variables, then the profile named by `AWS_PROFILE`, then the shared credentials file, then the roles attached to whatever machine it is running on. Our automation uses the last of those and never holds a key at all.

Nothing about your credentials goes in a `.tf` file, ever.

## 2. Claim a name

Everyone in the room shares one account, so every resource needs your name on it or you will collide with the person next to you.

```
cp terraform.tfvars.example terraform.tfvars
```

Edit it and set `name_prefix` to your own name in lower case.

## 3. Configure the provider

Create `main.tf`:

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Owner     = var.name_prefix
      ManagedBy = "opentofu"
      Purpose   = "learn-iac"
    }
  }
}
```

A `provider` block configures a plugin. `required_providers` says which plugin and which version, and the two are separate because one configuration can hold several differently configured copies of the same provider.

`default_tags` puts those three tags on everything this provider creates. Tags are how anyone finds out later who made a resource and whether it can be deleted, so an untagged resource is somebody's problem forever.

Create `variables.tf`:

```hcl
variable "name_prefix" {
  description = "Your name, in lower case. Prefixes every resource so the room does not collide."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,20}$", var.name_prefix))
    error_message = "name_prefix must be lower case letters, digits and hyphens, starting with a letter."
  }
}

variable "aws_region" {
  description = "Region everything is created in."
  type        = string
  default     = "eu-west-2"
}
```

`name_prefix` has no default, so leaving it out is an error rather than a surprise.

## 4. Read something before writing anything

Add to `main.tf`:

```hcl
data "aws_caller_identity" "current" {}
```

A `data` source reads. A `resource` writes. Data sources are how a configuration finds out about things it does not own, and they are refreshed on every plan.

## 5. Create a bucket

```hcl
locals {
  bucket_name = "${var.name_prefix}-learn-iac-${data.aws_caller_identity.current.account_id}"
}

resource "aws_s3_bucket" "class" {
  bucket = local.bucket_name

  # Lets `destroy` delete the bucket even though there is an object in it.
  # Reasonable for a class, wrong almost everywhere else.
  force_destroy = true
}

resource "aws_s3_object" "greeting" {
  bucket  = aws_s3_bucket.class.id
  key     = "hello.txt"
  content = "Written by ${var.name_prefix} from OpenTofu\n"
}
```

Bucket names are unique across every AWS account in the world, which is why the account number is in there. This is the first argument you have met that you cannot simply invent.

```
tofu init
tofu plan
```

Read this plan properly. It is much longer than the local ones, because the provider lists every attribute of a bucket, most of which you did not set and AWS will fill in. Find the three tags in there.

```
tofu apply
```

Slower than before, because each line is now an API call that has to come back.

## 6. Look at it from the other side

Create `outputs.tf`, so that the commands below have something to read the bucket name from:

```hcl
output "bucket_name" {
  description = "Name of the bucket created for you."
  value       = aws_s3_bucket.class.id
}

output "account_id" {
  description = "Account everything was created in."
  value       = data.aws_caller_identity.current.account_id
}
```

Outputs are recorded in state, so they need an apply before they can be read:

```
tofu apply
aws s3 ls
aws s3 cp s3://$(tofu output -raw bucket_name)/hello.txt -
```

Two tools, one bucket. Nothing about it is special to OpenTofu.

## 7. Break it on purpose

Change the object outside OpenTofu, the way somebody would in a hurry:

```
echo "edited by hand" | aws s3 cp - s3://$(tofu output -raw bucket_name)/hello.txt
tofu plan
```

The plan now shows a change you did not make in code. That gap is called drift, and finding it is most of what a plan is for. Running `tofu apply` puts it back to what the configuration says.

This is why the answer to "can I just fix it in the console" is no. The console change survives until the next apply and then vanishes, usually at the worst moment.

## 8. Look at the state

```
tofu state list
tofu state show aws_s3_bucket.class
```

`state list` gives you the address of everything OpenTofu is tracking, and those addresses are what you pass to every other state command. Worth knowing before you need them.

## 9. Before you commit

This is the first step that produced real identifiers, and this repository is public. Check what you are about to add.

`terraform.tfvars` is ignored by git, and that is not tidiness. It is the file people put credentials in, and an ignored file cannot be committed by accident.

The account number is fine. AWS documents account numbers as identifying rather than secret, and they appear in the infrastructure repository's committed variable files.

The bucket name is fine here because it is yours and it is gone in five minutes. Real bucket names are treated differently. The infrastructure repository's `s3-bucket` module takes only a prefix and lets AWS append the unique suffix, specifically so that the real name never enters the repository. Step 09 comes back to this.

## 10. Destroy

```
tofu destroy
aws s3 ls
```

Check the bucket is gone. Anything left behind in a shared account is charged to somebody, and untangling whose it was is why step 2 exists.

```
git status
git add 04-aws
git commit -m "step 04: first AWS resources"
```

Read the `git status` output before the `add`. If `terraform.tfvars` appears in it, the `.gitignore` is not doing its job and you should stop and say so.

## If you have time

- Remove `force_destroy` and try to destroy a bucket with an object still in it. Read the error.
- Add an `aws_ssm_parameter` holding your favourite colour, then change it with `aws ssm put-parameter --overwrite` and plan again.
- Comment out the `default_tags` block and plan. Count how many resources want changing.

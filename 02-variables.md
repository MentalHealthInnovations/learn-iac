# 02. Variables, outputs and loops

Step 01 had every value written into the middle of the resource. That configuration can only ever produce one thing. This step pulls the values out to the edge, so the same code can produce different results, and then makes it produce several at once.

You are editing the same files you wrote in step 01.

```
WORKSPACE=your-name
cd ~/learn-iac/workspaces/$WORKSPACE
```

## 1. Declare some variables

Create `variables.tf`:

```hcl
variable "pet_length" {
  description = "How many words in the generated pet name."
  type        = number
  default     = 2

  validation {
    condition     = var.pet_length >= 1 && var.pet_length <= 4
    error_message = "pet_length must be between 1 and 4."
  }
}

variable "greeting" {
  description = "Opening word written into each generated file."
  type        = string
  default     = "Hello"
}
```

The file name does not matter. Terraform reads every `.tf` file in the directory and treats them as one configuration. Splitting them up is a convention for humans, and `variables.tf`, `main.tf` and `outputs.tf` is the usual split.

A `description` is not decoration. It is what appears when someone runs `terraform plan` and gets prompted for a value they did not supply.

Now use them. In `main.tf`, replace `length = 3` with `length = var.pet_length`, and change the file content to:

```hcl
  content = "${var.greeting} from ${random_pet.server.id}\n"
```

```
terraform plan
```

Step 01 ended with `destroy`, so this plans both resources from nothing. What has changed is where the values come from, not what gets built: `var.pet_length` defaults to 2 and `var.greeting` to "Hello", which is what the resource said outright before.

## 2. Set them from a file

Create `terraform.tfvars`:

```hcl
pet_length = 3
greeting   = "Good morning"
```

```
terraform plan
```

`terraform.tfvars` is picked up automatically, with no flag naming it. It is also ignored by git in this repository, because a variables file is where credentials end up when nobody is paying attention. The convention that goes with that is committing a `terraform.tfvars.example` alongside it, so the next person can see which variables the file is expected to set without the values being in the repository. There is one in [reference/02-variables](reference/02-variables/).

## 3. A local is not a variable

Add a `locals` block near the top of `main.tf`:

```hcl
locals {
  output_dir = "${path.module}/generated"
}
```

Then use it, replacing the hardcoded path in the `local_file` resource:

```hcl
  filename = "${local.output_dir}/hello.txt"
```

A local is a value computed once inside the configuration and reused. A variable is an input from outside it. The test for which you want: could a caller reasonably need to change it? If not, make it a local, so it does not appear in the interface that other people have to read.

## 4. Make several things at once

Add a third variable to `variables.tf`:

```hcl
variable "environments" {
  description = "One file is written for each name in this set."
  type        = set(string)
  default     = ["dev", "staging", "prod"]
}
```

And change the `local_file` resource to:

```hcl
resource "local_file" "greeting" {
  for_each = var.environments

  filename = "${local.output_dir}/${each.key}.txt"
  content  = "${var.greeting} from ${random_pet.server.id}, running in ${each.key}\n"
}
```

```
terraform plan
terraform apply
ls generated/
```

One resource block, three files. Look at the addresses in the apply output: `local_file.greeting["dev"]` and so on. Each one is tracked separately in state, so removing `staging` from the set destroys that file and leaves the other two alone. Try it.

There is an older loop, `count`, which indexes by position instead. Removing the middle item from a `count` list renumbers everything after it, and Terraform reads that as destroying and recreating several resources rather than one. Reach for `for_each` unless you have a reason not to.

## 5. Get values back out

Create `outputs.tf`:

```hcl
output "pet_name" {
  description = "The generated pet name."
  value       = random_pet.server.id
}

output "files" {
  description = "Path of every file written, keyed by environment."
  value       = { for env, file in local_file.greeting : env => file.filename }
}
```

```
terraform apply
terraform output
terraform output -raw pet_name
```

Outputs are how one piece of infrastructure hands a value to a person, a script, or another configuration. The last of those matters from [step 04](04-modules.md) onwards, when a module needs to tell its caller what it built.

## 6. Tidy and commit

```
terraform fmt
terraform validate
git add ~/learn-iac/workspaces/$WORKSPACE
git commit -m "step 02: variables, outputs and for_each"
```

`terraform.tfvars` will not be committed. That is deliberate. Check with `git status` that only the files you meant to add went in.

Leave this applied. Step 03 needs the state you have just built, so do not run `destroy` at the end of this one.

## If you have time

- Set `pet_length = 9` in `terraform.tfvars` and read the error. That is the `validation` block earning its place.
- Add a variable of type `map(string)` mapping each environment to a region name, and write the region into each file.
- Add an output that returns only the production file path, without listing the others.

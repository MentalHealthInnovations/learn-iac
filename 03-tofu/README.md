# 03. Switching to OpenTofu

No new concepts. This step swaps one binary for another, on a configuration that already has state, and shows that nothing breaks. After it, you will not type `terraform` again for the rest of the class.

```
cd ~/learn-iac/03-tofu
```

## 1. Why we are doing this

In 2023 HashiCorp changed Terraform's licence from the Mozilla Public Licence to the Business Source Licence, which restricts competing commercial use (HashiCorp's [licence FAQ](https://www.hashicorp.com/license-faq)). Terraform 1.5.7, the version you have been using, is the last release under the old licence.

A fork carried on under the old terms, took the name OpenTofu, and is now hosted by the Linux Foundation ([opentofu.org](https://opentofu.org)). It reads the same configuration language and the same state format.

Our infrastructure repository runs OpenTofu, so the class follows it across.

## 2. Build something with Terraform first

The switch only means anything if there is existing state to carry over.

```
cp ../02-variables/*.tf .
cp ../02-variables/terraform.tfvars.example terraform.tfvars
terraform init
terraform apply
terraform output pet_name
```

Note that pet name down. It is what you are checking survives.

## 3. Switch

```
rm .terraform.lock.hcl
tofu init
```

The lock file has to go first because it records which registry each provider came from, and Terraform resolved them against `registry.terraform.io`. OpenTofu uses `registry.opentofu.org`, which carries the same providers under the same names. `tofu init` writes a new lock file pointing at the registry it actually uses.

Read what `init` prints rather than skipping past it.

## 4. Check nothing moved

```
tofu plan
```

This is the whole step. The state file written by Terraform is read by OpenTofu without conversion, the configuration parses identically, and the plan comes back with no changes.

```
tofu output pet_name
```

Same name as before.

## 5. Confirm it still works

Change `greeting` in `terraform.tfvars` to something else and run:

```
tofu apply
cat generated/prod.txt
```

## 6. Destroy and commit

```
tofu destroy
git add 03-tofu
git commit -m "step 03: migrate to OpenTofu"
```

## What carries forward

Every command you have learned keeps its name. `tofu init`, `tofu plan`, `tofu apply`, `tofu destroy`, `tofu fmt`, `tofu validate`, `tofu output`. The arguments are the same too.

Two things to remember for later:

- Terragrunt calls a binary underneath it, and by default that binary is `terraform`. [mise.toml](../mise.toml) sets `TG_TF_PATH=tofu` for this repository so that it calls OpenTofu instead. Step 08 is where that starts to matter.
- Provider source addresses in `required_providers` still read `hashicorp/random`. That is the name of the provider, not a statement about which registry serves it.

## If you have time

- Open the new `.terraform.lock.hcl` and find the registry hostname in it.
- Run `terraform plan` in this directory now, after OpenTofu has been through it, and see whether the older binary still copes.

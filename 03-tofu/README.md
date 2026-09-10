# 03. Switching to OpenTofu

No new concepts. This step swaps one binary for another, on the configuration you have already applied, and shows that nothing breaks. After it, you will not type `terraform` again.

```
WORKSPACE=your-name
cd ~/learn-iac/workspaces/$WORKSPACE
```

## 1. Why we are doing this

State encryption. A state file records every attribute of everything you built, including the values a provider marked sensitive, so it is the most valuable file in the repository to an attacker. OpenTofu encrypts it client-side, before it is written anywhere, and the feature is part of the free tool rather than a paid tier ([OpenTofu state encryption docs](https://opentofu.org/docs/language/state/encryption/)). Our infrastructure repository turns that on for every unit, which you will see generated in [step 07](../07-mhi-infra/).

That matters because our state lives in an S3 bucket. Bucket-level encryption protects it from someone reading the disk, and does nothing about someone who can read the bucket. Client-side encryption means the object is ciphertext to anyone holding bucket access alone.

The reason a separate tool exists to have that feature is the licence. In 2023 HashiCorp changed Terraform's licence from the Mozilla Public Licence to the Business Source Licence, which restricts competing commercial use (HashiCorp's [licence FAQ](https://www.hashicorp.com/license-faq)). Terraform 1.5.7, the version you have been using, is the last release under the old licence. A fork carried on under the old terms, took the name OpenTofu, and is now hosted by the Linux Foundation ([opentofu.org](https://opentofu.org)). It reads the same configuration language and the same state format, which is what the rest of this step demonstrates.

## 2. Note what you have

The switch only means anything if there is existing state to carry over, which is why step 02 left everything applied.

```
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

## 6. Destroy

```
tofu destroy
```

Step 04 restructures these files into a module, which is easier from an empty state than from one holding resources whose addresses are about to change.

## 7. Nothing to commit

Check:

```
git status
```

No tracked file changed. The `.tf` files are untouched, and the lock file and `terraform.tfvars` are both ignored. That is the result worth taking away: this was a change of tooling, not a change of configuration, and the repository cannot tell the difference.

## What carries forward

Every command you have learned keeps its name. `tofu init`, `tofu plan`, `tofu apply`, `tofu destroy`, `tofu fmt`, `tofu validate`, `tofu output`. The arguments are the same too.

Two things to remember for later:

- Terragrunt calls a binary underneath it, and by default that binary is `terraform`. [mise.toml](../mise.toml) sets `TG_TF_PATH=tofu` for this repository so that it calls OpenTofu instead. [Step 06](../06-terragrunt/) is where that starts to matter.
- Provider source addresses in `required_providers` still read `hashicorp/random`. That is the name of the provider, not a statement about which registry serves it.

## If you have time

- Open the new `.terraform.lock.hcl` and find the registry hostname in it.
- Run `terraform plan` in this directory now, after OpenTofu has been through it, and see whether the older binary still copes.

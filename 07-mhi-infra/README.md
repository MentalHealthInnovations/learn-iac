# 07. The real thing

Everything you have built so far writes text files. This step opens the repository that runs our AWS estate and shows you that it is the same three ideas at a larger size, plus a handful you have not met.

Nothing here is applied, planned, or destroyed. You read.

```
git clone git@github.com:MentalHealthInnovations/mhi-infra.git ~/mhi-infra
cd ~/mhi-infra
```

## Stop 1: the shape

```
ls iac/aws
```

Three directories, and you already know what two of them are for.

`modules/` holds reusable patterns, the same thing as your `modules/greeting`. `live/` holds the calls, the same thing as your `module "dev"` block, one directory per deployed piece of infrastructure. `bootstrap/` is the chicken-and-egg problem: the state buckets and encryption keys everything else needs before it can run, applied by hand rather than by the usual path.

Modules come in two tiers. A component module wraps one kind of thing, a bucket or a database, and knows nothing about any particular project. A project module composes components into a workload. Nothing project-specific is allowed into a component, which is what stops the reusable half of the repository slowly becoming unreusable.

## Stop 2: a module you can already read

```
ls iac/aws/modules/s3-bucket
cat iac/aws/modules/s3-bucket/variables.tf
```

Four familiar files, `main.tf`, `variables.tf`, `outputs.tf`, `versions.tf`, and two you have not seen. `tests/` holds `.tftest.hcl` files, which are not optional for a module here. `README.md` is generated from the variable descriptions rather than written, which is why writing a good `description` is worth the effort.

Read the description on `kms_key_arn`. Notice that it does not say what the variable is, which is obvious, but what happens if you leave it null and why that is sometimes the right choice. That is the standard to aim for.

**Question:** find the argument in this module that exists so a bucket can be deleted while objects remain. Why would you want that off in production?

## Stop 3: a live unit you can already read

```
cat iac/aws/live/shared-services/ecr-nginx/terragrunt.hcl
```

This is a `terragrunt.hcl` like the ones you wrote in step 06. It includes a root config, includes a shared partial, and supplies `inputs`. Two things are new.

`exclude` stops the unit deploying to some accounts. This one runs in `shared-services-dev` and nowhere else.

The comments carry the reasoning. Read the paragraph explaining why the repository exists at all, about private subnets having no route to a public registry. That is the house style: the file says what it does, and the comment says why anyone would want it.

## Stop 4: the root, and what you never have to write again

```
grep -n 'generate "' iac/root.hcl
grep -n 'remote_state' iac/root.hcl
```

In step 04 you wrote a `required_providers` block in your root module, and in step 06 Terragrunt generated one for you. Here the same mechanism supplies three things to every unit in the repository: the provider configuration, the backend configuration, and a client-side state encryption block.

Look at the `remote_state` block. It is the shape you used in step 06, with `backend = "s3"` instead of `backend = "local"`, and the bucket and key computed from where the unit sits in the tree. Two hundred directories, one definition.

**Question:** if the backend configuration is generated, what happens to a `backend.tf` file that someone writes by hand in a unit directory? Find the answer in the block rather than guessing.

## Stop 5: environments are files, not directories

In step 05 you copied a directory per environment and hated it. In step 06 you removed the duplicated configuration but kept the three directories. This repository goes one further.

```
ls iac/aws/live/shared-services
ls iac/aws/live/shared-services/vars
```

The units are listed once. The `vars/` directory holds one file per account, and the presence of that file is what deploys the group's units into that account. Adding an environment is adding a file. Nothing is copied.

```
head -40 iac/aws/live/shared-services/vars/shared-services-dev.hcl
```

That file is the account's identity plus the values its units read. Read a few of the comments. Several of them explain a cost or a failure mode rather than a setting, which is the point: the file records the decisions, and the decisions are the part nobody remembers a year later.

## Stop 6: units that need each other

```
cat iac/aws/live/_envcommon/ecr-repository.hcl
```

You met `dependency` in step 06. Read this one properly, because the interesting part is the three lines of configuration around it rather than the dependency itself.

A dependency reads another unit's outputs. Before that unit has ever been applied, there are no outputs to read, so a plan would fail with nothing useful to say. `mock_outputs` supplies a stand-in. `mock_outputs_allowed_terraform_commands` limits it to plan and validate, so a real apply can never quietly use a fake value. `mock_outputs_merge_strategy_with_state` handles the case where a unit's apply failed halfway and left an empty state behind.

Read the comment explaining why the mock value is a self-describing string rather than a plausible-looking ARN.

**Question:** what would go wrong if `mock_outputs_allowed_terraform_commands` were left out?

## What you have not seen

The class deliberately stayed on your filesystem. Five things change when the thing on the other end is a cloud provider.

**Plans take time and can be wrong about the past.** Every resource is refreshed against a live API, so a plan is slow and it can show you changes nobody made in code. That gap is called drift, and it is most of what a plan is for.

**State is shared, remote, locked and encrypted.** Yours sat in the working directory. Here it lives in an S3 bucket in a separate account, is locked while a run is in progress so two people cannot corrupt it, and is encrypted client-side on top of the bucket's own encryption, so bucket access alone does not reveal it.

**Secrets exist.** Some values a unit needs cannot be committed and cannot be invented at runtime. Those are encrypted with SOPS, committed as ciphertext, reviewed in a pull request, and decrypted at plan time by whoever holds the key. Look at `docs/how-to/manage-a-secret.md`.

**Nobody applies from a laptop.** A pull request runs a plan in CI. Merging is the approval, and the merge triggers the apply. The permission sets are arranged so that most people can run a plan and cannot write state, which enforces it rather than relying on everyone remembering.

**Everything is written to be published.** The rules you read in step 00 come from this repository, and they are why the bucket module takes a prefix and lets AWS generate the real name, and why access bindings live in an encrypted file.

## Where to go next

```
cat PRINCIPLES.md
ls docs/adr
ls docs/how-to
```

The architecture decision records are the useful reading. Each one is a decision that was contested, with the reasoning and the cost of the alternative. `docs/how-to/` is the recipe collection for when you have a job to do.

If you want to run something for real, the smallest useful task is reading a plan on an open pull request and saying what you think it does.

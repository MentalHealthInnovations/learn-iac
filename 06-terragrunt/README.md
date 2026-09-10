# 06. Terragrunt

Step 05 left you with three directories that were nearly identical, three commands to run in the right order by hand, and no way to change the pattern everywhere at once. This step converts those same three directories so that none of that is true, and adds a fourth unit that depends on the other three.

Terragrunt is a thin wrapper. It is not a fork of OpenTofu and it does not replace the language. It generates files into a working copy of your configuration and then runs `tofu` against that copy. Everything you have learned still applies underneath.

```
WORKSPACE=your-name
cd ~/learn-iac/workspaces/$WORKSPACE
```

## 1. Write the shared configuration once

Create `root.hcl` at the top of your workspace:

```hcl
remote_state {
  backend = "local"

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }

  config = {
    path = "${get_parent_terragrunt_dir()}/state/${path_relative_to_include()}/terraform.tfstate"
  }
}

inputs = {
  output_dir = "${get_parent_terragrunt_dir()}/generated"
}
```

This is the answer to the problem step 05 ended on. A backend block accepts no variables, so it cannot be written once and parameterised. Terragrunt sidesteps that by writing the block itself, per unit, with the values filled in.

`path_relative_to_include()` returns where the unit sits relative to this file, so `dev` gets `state/dev/terraform.tfstate` and nothing has to be spelled out per environment. In our infrastructure repository the same block says `backend = "s3"` and computes a bucket and key the same way. [Step 07](../07-mhi-infra/) shows it.

## 2. Replace each environment with four lines

Out with the duplication:

```
rm dev/main.tf staging/main.tf prod/main.tf
```

Create `dev/terragrunt.hcl`:

```hcl
include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_parent_terragrunt_dir()}/modules/greeting"
}

inputs = {
  environment = "dev"
}
```

There is no `main.tf`. There is no `required_providers` block, no `module` block, no `output` block. `source` says which module this unit is an instance of, and `inputs` says what makes it different from the other instances. That is the entire environment.

Now `staging/terragrunt.hcl`, identical but `environment = "staging"`, and `prod/terragrunt.hcl`:

```hcl
inputs = {
  environment = "prod"
  greeting    = "Good morning"
  pet_length  = 3
}
```

Compare that against the file you just deleted, which is kept at [reference/05-environments/prod/main.tf](../reference/05-environments/prod/main.tf). The same three values, and nothing else.

## 3. Apply one, and go looking for the generated file

```
cd dev
terragrunt apply
cd ..
```

Now find the `backend.tf` that Terragrunt wrote. It is not next to your `terragrunt.hcl`:

```
find dev -name backend.tf
cat $(find dev -name backend.tf)
```

It is several directories down inside `.terragrunt-cache`. Terragrunt copies the module and the generated files into that cache and runs `tofu` there, which is why your unit directory stays almost empty and why the cache is in `.gitignore`.

Read the path in the generated block. It points at `state/dev/terraform.tfstate`, outside the cache, which is what stops your state being thrown away when the cache is cleared.

## 4. A unit that depends on the others

Create `summary/terragrunt.hcl`:

```hcl
include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_parent_terragrunt_dir()}/modules/summary"
}

dependency "dev" {
  config_path                             = "../dev"
  mock_outputs_allowed_terraform_commands = ["validate", "init", "plan"]
  mock_outputs_merge_strategy_with_state  = "shallow"

  mock_outputs = {
    pet_name = "MOCK-dev-not-yet-applied"
  }
}
```

Add the same block twice more for `staging` and `prod`, changing the name, the `config_path` and the mock value. Then:

```hcl
inputs = {
  pet_names = {
    dev     = dependency.dev.outputs.pet_name
    staging = dependency.staging.outputs.pet_name
    prod    = dependency.prod.outputs.pet_name
  }
}
```

That points at a module you do not have yet. Copy it, or write your own that takes `pet_names` and `output_dir` and writes one file listing them:

```
cp -r ~/learn-iac/reference/06-terragrunt/modules/summary modules/
```

A `dependency` does two things at once. It reads another unit's outputs, and it declares an ordering. Nowhere do you write down that the environments come before the summary.

## 5. Why the mocks are there

You have applied `dev` and not the other two. Plan the summary:

```
cd summary
terragrunt plan
cd ..
```

The plan shows dev's real pet name alongside `MOCK-staging-not-yet-applied` and `MOCK-prod-not-yet-applied`, with a warning naming each unit that had no outputs to give.

Without the mocks this would fail. A unit that has never been applied has no outputs, so a plan that reads them has nothing to read, and you would be unable to plan anything until you had already applied everything it depends on. That is a deadlock in CI, where the plan is what gates the apply.

`mock_outputs_allowed_terraform_commands` is why a fake value can never reach an apply. Take it out and the mock is substituted on every command, including one that builds something real.

The mock values are deliberately obvious rather than plausible. They appear in a plan someone has to review, so they need to be recognisable there and not just in this file.

## 6. Run everything

From the top of your workspace:

```
terragrunt run --all apply
```

Read what it prints before the work starts. It draws the graph it worked out:

```
.
├── dev
│   ╰── summary
├── prod
│   ╰── summary
╰── staging
    ╰── summary
```

The three environments run at the same time, and the summary waits for all of them. One command, in place of step 05's three in a fixed order that you had to remember.

If a unit fails with `unable to acquire file lock ... resource deadlock avoided`, that is several units downloading the same provider at once on a cold cache. Run the command again. The second run has the providers already and goes through.

```
cat generated/summary.txt
ls state
```

## 7. What changed and what did not

Gone: the duplicated provider block, the duplicated module call, the per-directory `main.tf`, the hand-written backend configuration, and running one command per environment in an order you had to know.

Unchanged, deliberately: each environment still has its own state file, in `state/dev`, `state/staging` and `state/prod`. That was the whole reason step 05 used separate directories, and none of this gives it away. `run --all` runs several units, and each one is still its own `tofu` run against its own state.

## 8. Tidy up

```
terragrunt run --all destroy
git add ~/learn-iac/workspaces/$WORKSPACE
git commit -m "step 06: terragrunt"
```

## If you have time

- Change something in `modules/greeting` and apply it everywhere with one command. Compare with what step 05 required.
- Add a fourth environment. Count the lines you had to write.
- Delete `mock_outputs_allowed_terraform_commands` from one dependency, destroy everything, and work out from the plan what the risk is.

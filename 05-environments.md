# 05. Three environments, the hard way

This step is deliberately tedious. You will build the same thing three times, by copying it, and by the end you should be irritated. Step 06 removes the irritation. Doing it in that order matters, because Terragrunt looks like unnecessary machinery until you have felt what it takes away.

```
WORKSPACE=your-name
cd ~/learn-iac/workspaces/$WORKSPACE
```

## 1. First, the question from step 04

A `module` block takes `for_each`. So the obvious way to build three environments is one directory, one module block, a set of three names. Why not do that?

Because it puts all three environments in one state file, and one state file is one blast radius. With `for_each`, you cannot plan dev without also refreshing prod, you cannot apply dev without prod being in the same run, and a mistake in a shared input shows up as a change to all three at once. The thing you most want, that a bad afternoon in dev cannot reach production, is exactly what a shared state file gives away.

So environments get separate state. Separate state means separate directories, one `tofu` run each. That is the constraint everything below follows from, and it is why the tedium is not bad design.

`for_each` over a module is still the right answer within one environment, for three of the same thing that live and die together. It is the wrong answer across environments.

## 2. Clear the root

Your root calls the module twice. Three environments cannot live in one root, so the root stops being a place where anything runs:

```
rm main.tf outputs.tf
```

`modules/greeting` stays exactly where it is. One copy of the pattern, shared by all three environments.

## 3. Build dev

```
mkdir -p dev
```

Create `dev/main.tf`:

```hcl
terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
}

module "greeting" {
  source = "../modules/greeting"

  environment = "dev"
  output_dir  = "${path.root}/generated"
  greeting    = "Hello"
  pet_length  = 2
}

output "pet_name" {
  value = module.greeting.pet_name
}
```

```
tofu -chdir=dev init
tofu -chdir=dev apply
```

## 4. Build staging and prod

Copy the directory twice and edit what differs:

```
cp -r dev staging
cp -r dev prod
rm -rf staging/.terraform staging/terraform.tfstate* staging/generated
rm -rf prod/.terraform prod/terraform.tfstate* prod/generated
```

The removals matter. Copying a directory that has been applied copies its state with it, and a state file that thinks it already owns dev's resources will not build staging's. This is the first hint that state is per-directory and travels with the files, whether you meant it to or not.

Now edit `staging/main.tf`, changing `environment` to `"staging"`. Then `prod/main.tf`, changing `environment` to `"prod"`, `greeting` to `"Good morning"` and `pet_length` to `3`.

```
tofu -chdir=staging init
tofu -chdir=staging apply
tofu -chdir=prod init
tofu -chdir=prod apply
```

## 5. Count what you just duplicated

Look at the three `main.tf` files side by side:

```
diff dev/main.tf staging/main.tf
diff dev/main.tf prod/main.tf
```

The `required_providers` block is identical in all three and has nothing to do with any environment. The `module` block is identical apart from the values. The `output` block is identical. Between dev and staging, one word differs out of roughly twenty-five lines.

Now imagine the real version. Ten units instead of one, so thirty directories. A provider block that also pins a region, a role to assume, and a default set of tags. A backend configuration naming a bucket and a key that must be different in every one of the thirty, and which cannot be computed, because a backend block accepts no variables at all.

## 6. Feel the second problem

```
tofu -chdir=dev apply
tofu -chdir=staging apply
tofu -chdir=prod apply
```

Three commands, in a fixed order, that you have to get right by hand. There is no command that means "apply all three", and nothing knows that one of them has to run before another.

## 7. Make a change to all three

Change the module: add a second file to `modules/greeting/main.tf`, or change the file content. Then work out how to get that change applied everywhere.

There is no way to do it except visiting each directory in turn. Miss one and you have an environment quietly running the old pattern, and nothing tells you.

## 8. Tidy up

```
tofu -chdir=dev destroy
tofu -chdir=staging destroy
tofu -chdir=prod destroy
git add ~/learn-iac/workspaces/$WORKSPACE
git commit -m "step 05: three environments by copy and paste"
```

Leave the directories in place. Step 06 rebuilds this same layout without the duplication.

## What to carry into step 06

Three problems, in the order Terragrunt solves them.

Configuration that is identical everywhere gets written once and generated into each directory. Values that differ per environment get declared where the environment is declared. Running the same command across every directory becomes one command that also understands the ordering.

Nothing about separate state changes. Each environment keeps its own, which was the point of the separate directories in the first place.

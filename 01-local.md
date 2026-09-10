# 01. Your first Terraform

You describe the end state you want, and Terraform works out which calls to make to get there. You never write "create this, then that".

```
WORKSPACE=your-name
cd ~/learn-iac/workspaces/$WORKSPACE
```

## 1. Declare what you need

Create `main.tf` containing this and nothing else:

```hcl
terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}
```

A provider is a plugin that knows how to talk to one system. There is one for AWS, one for GitHub, one for Cloudflare, and a few that talk to nothing outside your machine. `random` is one of those.

`~> 3.6` means any 3.x from 3.6 upwards, but not 4.0. Providers make breaking changes at major versions.

## 2. Initialise

```
terraform init
ls -a
```

`.terraform/` holds the downloaded plugin. `.terraform.lock.hcl` records the exact version and checksum chosen, so the next person to run `init` gets the same plugin rather than whatever is newest. Both are ignored by git here, explained in [.gitignore](.gitignore).

You will need to run `init` every time you add or change a provider.

## 3. Add a resource

Append this to `main.tf`:

```hcl
resource "random_pet" "server" {
  length    = 2
  separator = "-"
}
```

`random_pet` is the type, `server` is the name you refer to it by. The name is yours to choose and means nothing outside this configuration.

```
terraform plan
```

Read the output. Terraform intends to add one thing, and the `id` is `(known after apply)` because the name does not exist until something generates it.

```
terraform apply
```

It shows the same plan again and waits. Type `yes`.

## 4. Look at the state

```
cat terraform.tfstate
```

Terraform has no memory beyond this file. It records what it created and what the attributes came out as, and every future `plan` compares your configuration, this file, and the real world.

Two things follow:

- Lose the file and Terraform forgets it made anything. It will happily create a second copy of everything.
- Two people running against the same infrastructure need the same file, so a state file on your laptop stops working the moment anyone else joins. [Step 07](07-mhi-infra.md) shows where it goes instead.

## 5. Add something that depends on it

Add `local` to the providers block, so it reads:

```hcl
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
```

and append a second resource:

```hcl
resource "local_file" "greeting" {
  filename = "${path.module}/generated/hello.txt"
  content  = "Hello from ${random_pet.server.id}\n"
}
```

A new provider means a new `init`:

```
terraform init
terraform apply
cat generated/hello.txt
```

Nothing told Terraform to make the pet name before the file. Referring to `random_pet.server.id` inside the content created that ordering. Terraform builds a graph out of those references and works out what can run in parallel and what has to wait.

## 6. Change something

Edit `length = 2` to `length = 3` and run:

```
terraform plan
```

Read this one carefully. The pet cannot be edited into a longer name, so it is destroyed and recreated, and the file follows because its content refers to it. Terraform names the attribute that forced it, before anything happens rather than after.

```
terraform apply
cat generated/hello.txt
```

## 7. Tidy the code

```
terraform fmt
terraform validate
```

`fmt` rewrites the file to the standard layout, `validate` checks it makes sense without contacting anything. Run both before every commit. [Step 07](07-mhi-infra.md) shows the repository that enforces them automatically.

## 8. Destroy

```
terraform destroy
ls generated/
```

The file is gone, and `terraform.tfstate` is empty of resources. Destroying at the end of a step leaves the next one a clean slate, and it is the habit that stops resources being left running once they cost money.

Leave the `.tf` files where they are. The next step edits them.

## 9. Commit

```
git add ~/learn-iac/workspaces/$WORKSPACE
git commit -m "step 01: first local resources"
```

Commit at the end of every step. The pull request reads better as a sequence of steps than as one lump.

## If you have time

- Add a `random_integer` resource and write its value into a second file.
- Delete `terraform.tfstate`, run `plan` again, and work out from the output what Terraform now believes.
- Change `separator` from `-` to `_` and predict what the plan will say before you run it.

# 01. Your first Terraform

The idea behind Terraform is that you describe the end state you want, and it works out which calls to make to get there. You never write "create this, then that". You write what should exist, and it compares that against what already exists.

Everything this step creates lands on your own disk, where you can look at it.

Your workspace is the directory you made in step 00, and every step from here builds on what the one before it left there.

```
WORKSPACE=your-name
cd ~/learn-iac/workspaces/$WORKSPACE
```

## 1. Declare what you need

Create a file called `main.tf` containing this and nothing else:

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

A provider is a plugin that knows how to talk to one system. There is one for AWS, one for GitHub, one for Cloudflare, and a few that talk to nothing outside your machine. `random` is one of those, which is why we can start here without arranging an account first.

`~> 3.6` means any 3.x from 3.6 upwards, but not 4.0. Providers make breaking changes at major versions, so nobody floats free.

## 2. Initialise

```
terraform init
```

Look at what appeared:

```
ls -a
```

`.terraform/` holds the downloaded plugin. `.terraform.lock.hcl` records the exact version and checksum that were chosen, so that the next person to run `init` gets the same plugin rather than whatever is newest. Both are ignored by git in this repository, explained in [.gitignore](../.gitignore).

You will need to run `init` every time you add or change a provider.

## 3. Add a resource

Append this to `main.tf`:

```hcl
resource "random_pet" "server" {
  length    = 2
  separator = "-"
}
```

`random_pet` is the type, and `server` is the name you will refer to it by. The name is yours to choose and means nothing outside this configuration.

```
terraform plan
```

Read the output rather than skipping it. Terraform is telling you it intends to add one thing, and that the `id` is `(known after apply)`, because the name does not exist until something generates it.

```
terraform apply
```

It shows the same plan again and waits. Type `yes`.

## 4. Look at the state

```
cat terraform.tfstate
```

This is the point of the whole step. Terraform has no memory beyond this file. It records what it created and what the attributes came out as, and every future `plan` is a comparison between your configuration, this file, and the real world.

Two things follow from that, and both come up again later:

- Lose the file and Terraform forgets it made anything. It will happily create a second copy of everything.
- Two people running against the same infrastructure need the same file, which is why a state file on your laptop stops working the moment anyone else joins. [Step 07](../07-mhi-infra/) shows where it goes instead.

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
terraform plan
terraform apply
```

Then:

```
cat generated/hello.txt
```

Nothing told Terraform to make the pet name before the file. Referring to `random_pet.server.id` inside the file's content is what created that ordering. Terraform builds a graph out of those references and works out for itself what can run in parallel and what has to wait.

## 6. Change something

Edit `length = 2` to `length = 3` and run:

```
terraform plan
```

Read this one carefully. The pet cannot be edited into a longer name, so it has to be destroyed and recreated, and the file has to follow because its content refers to it. Terraform tells you which attribute forced that, and it tells you before anything happens rather than after.

```
terraform apply
cat generated/hello.txt
```

## 7. Tidy the code

```
terraform fmt
terraform validate
```

`fmt` rewrites the file to the standard layout, and `validate` checks that it makes sense without contacting anything. Both are worth running before every commit, and [step 07](../07-mhi-infra/) shows the repository that enforces them automatically.

## 8. Destroy

```
terraform destroy
```

Type `yes`. Then check:

```
ls generated/
```

The file is gone, and `terraform.tfstate` is now empty of resources. Destroying at the end of a step leaves the next one a clean slate, and it is the habit that stops things being left running once the thing on the other end costs money.

Leave the `.tf` files where they are. The next step edits them.

## 9. Commit

```
git add ~/learn-iac/workspaces/$WORKSPACE
git commit -m "step 01: first local resources"
```

Commit at the end of every step. The pull request you raise at the end reads better as a sequence of steps than as one lump.

## If you have time

- Add a `random_integer` resource and write its value into a second file.
- Delete `terraform.tfstate`, then run `plan` again, and work out from the output what Terraform now believes.
- Change `separator` from `-` to `_` and predict what the plan will say before you run it.

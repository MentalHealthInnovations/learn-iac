# 04. Modules

Step 02 produced three files from one resource block. That works while everything is the same shape. A module is what you reach for when you want the same *pattern* several times, with different values, and you want to change the pattern in one place.

From here on the binary is `tofu`.

```
cd ~/learn-iac/04-modules
```

## 1. You have already written one

A module is a directory containing `.tf` files. That is the entire definition. The directory you worked in for steps 01 to 03 is a module, called the root module, and the only thing that makes it special is that it is the one you ran `tofu` in.

So nothing below is new syntax. It is the same files, in a subdirectory, called by name.

## 2. Move the pattern into a module

Create `modules/greeting/main.tf`:

```hcl
resource "random_pet" "this" {
  length    = var.pet_length
  separator = "-"
}

resource "local_file" "this" {
  filename = "${var.output_dir}/${var.environment}.txt"
  content  = "${var.greeting} from ${random_pet.this.id}, running in ${var.environment}\n"
}
```

`this` is the conventional resource name when a module creates one of something. The module's name already says what it is, so repeating it in the resource name only makes the addresses longer.

Create `modules/greeting/variables.tf`:

```hcl
variable "environment" {
  description = "Name of the environment this instance represents."
  type        = string
}

variable "output_dir" {
  description = "Directory the file is written to. Supplied by the caller, because a module should not decide where its output lands."
  type        = string
}

variable "greeting" {
  description = "Opening word written into the file."
  type        = string
  default     = "Hello"
}

variable "pet_length" {
  description = "How many words in the generated pet name."
  type        = number
  default     = 2
}
```

And `modules/greeting/versions.tf`:

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
```

A module declares which providers it needs. It does not configure them, and it must not contain a `provider` block. Configuration belongs to the root, so that one provider setup serves every module underneath it. Step 07 shows what goes wrong when a module carries its own.

## 3. The boundary is the point

A module cannot see its caller's variables, and the caller cannot see inside the module. Everything crossing that line does so through an input variable going in or an output coming back. That restriction is what makes a module reusable rather than merely relocated.

Create `modules/greeting/outputs.tf`:

```hcl
output "pet_name" {
  description = "The generated pet name."
  value       = random_pet.this.id
}

output "file_path" {
  description = "Where the file was written."
  value       = local_file.this.filename
}
```

## 4. Call it

Create `main.tf` in `04-modules` itself:

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

module "dev" {
  source = "./modules/greeting"

  environment = "dev"
  output_dir  = "${path.root}/generated"
}

module "prod" {
  source = "./modules/greeting"

  environment = "prod"
  output_dir  = "${path.root}/generated"
  greeting    = "Good morning"
  pet_length  = 3
}
```

Two calls, one pattern. `dev` takes the defaults for `greeting` and `pet_length`, `prod` overrides both.

```
tofu init
```

`init` is needed again, and not because of providers. Adding or moving a module changes what `init` has to record, so a "module not installed" error later almost always means a missing `init`.

```
tofu plan
tofu apply
ls generated/
```

## 5. Read the addresses

```
tofu state list
```

Every address is now prefixed: `module.dev.random_pet.this`, `module.prod.local_file.this`. Two independent copies of the same pattern, tracked separately. Change `greeting` on `prod` and re-plan, and only the `prod` file moves.

## 6. Outputs do not escape by themselves

`tofu output` shows nothing, even though the module defines two outputs. A module's outputs are visible to its caller, and stop there. To surface them, the root has to re-export them.

Create `outputs.tf`:

```hcl
output "dev_pet" {
  description = "Pet name generated for dev."
  value       = module.dev.pet_name
}

output "prod_pet" {
  description = "Pet name generated for prod."
  value       = module.prod.pet_name
}
```

```
tofu apply
tofu output
```

That looks like ceremony at this size. It is what lets one unit of infrastructure hand a value to another without either knowing the other's internals, which is how step 06 wires things together.

## 7. Why not a loop

A `module` block takes `for_each`, so those two calls could collapse into one block over a set of environment names. Hold that thought. Step 05 is about why environments are the one case where you usually do not do that.

## 8. Tidy up

```
tofu fmt
tofu validate
tofu destroy
git add 04-modules
git commit -m "step 04: modules"
```

## If you have time

- Add a third call for `staging` and predict the plan before running it.
- Move `output_dir` into a `locals` block in the root so it is written once instead of twice.
- Delete `modules/greeting/outputs.tf` and try to reference `module.dev.pet_name`. Read the error and work out what it tells you about the boundary.

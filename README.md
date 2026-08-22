# Infrastructure as Code, from scratch

A hands-on class that starts with one file writing to your own disk and ends with a tour of the repository that runs our AWS estate. Everything is typed in your own terminal.

The class also runs as an ordinary piece of engineering work. You take a branch, commit at each step, and raise a pull request at the end for review.

## Before the session

Work through [00-setup](00-setup/) on the machine you are bringing. It takes about fifteen minutes and it is the part that cannot be fixed live.

## The steps

Session one, from nothing to AWS.

| Step | What you build | What it teaches |
| --- | --- | --- |
| [01-local](01-local/) | A random name and a text file on your disk | `init`, `plan`, `apply`, `destroy`, and what state is |
| [02-variables](02-variables/) | The same thing, parameterised, three files instead of one | Variables, outputs, locals, `for_each` |
| [03-tofu](03-tofu/) | Nothing new | Why we left Terraform, and moving a state file across |
| [04-aws](04-aws/) | A bucket and a parameter in a real account | Providers, credentials, arguments you cannot invent |
| [05-remote-state](05-remote-state/) | The same, with state held in S3 | Remote backends, locking, why local state stops working past one person |

Session two, from AWS to this estate.

| Step | What you build | What it teaches |
| --- | --- | --- |
| [06-modules](06-modules/) | Step 04 turned into a module and called twice | Modules, inputs, outputs, composition |
| [07-environments](07-environments/) | Dev, staging and prod, by copy and paste | The duplication problem, felt rather than described |
| [08-terragrunt](08-terragrunt/) | The same three, without the copy and paste | `terragrunt.hcl`, generated backends, dependencies, `run --all` |
| [09-mhi-infra](09-mhi-infra/) | Nothing. Read only. | How the real repository is laid out, and why |

## Catching up

If a step defeats you, take the finished version and carry on:

```
git checkout reference -- 01-local
```

The `reference` branch holds a completed copy of every step. Reach for it rather than falling behind, and come back to the step afterwards.

## Rules of the room

- Prefix every resource you create in AWS with your own name, so twelve people can share one account without colliding.
- Run `destroy` at the end of any step that created something. Anything left behind costs money.
- Ask the moment you are stuck. Each step builds on the one before it, so a step you did not finish blocks the rest.

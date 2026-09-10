# Infrastructure as Code, from scratch

A hands-on course that starts with one file writing to your own disk and ends with a tour of the repository that runs our AWS estate. Everything is typed in your own terminal.

Every step runs against your own filesystem rather than a cloud account, so there are no credentials to arrange, nothing to pay for, and a `plan` that returns instantly. What you learn transfers unchanged: the language, the commands, the state file and the tooling are the same whether the thing on the other end is a text file or a database.

The course also runs as an ordinary piece of engineering work. You take a branch, commit at each step, and raise a pull request at the end for review. That last part is [step 08](08-pull-request/) and is as much of the point as the rest.

Everyone works in a directory of their own under `workspaces/`, so a dozen pull requests against `main` touch no common file and every one of them can be merged. The numbered directories at the top of the repository hold the instructions and stay as they are.

You build one configuration across steps 01 to 06 rather than a fresh copy per step, so each step edits, extracts or replaces what the one before it left. The diff a reviewer reads is then a sequence of refactors, which is what this work looks like in practice.

## Start here

Work through [00-setup](00-setup/) first. It installs the tools and gives you a branch and a directory to work in.

## The steps

| Step | What you build | What it teaches |
| --- | --- | --- |
| [01-local](01-local/) | A random name and a text file on your disk | `init`, `plan`, `apply`, `destroy`, and what state is |
| [02-variables](02-variables/) | The same thing, parameterised, three files instead of one | Variables, outputs, locals, `for_each` |
| [03-tofu](03-tofu/) | Nothing new | Why we run OpenTofu, and moving a state file across |
| [04-modules](04-modules/) | The same resources, extracted into a module and called twice | Modules, inputs, outputs, composition |
| [05-environments](05-environments/) | Dev, staging and prod, by copy and paste | The duplication problem, felt rather than described |
| [06-terragrunt](06-terragrunt/) | The same three, without the copy and paste | `terragrunt.hcl`, generated blocks, dependencies, `run --all` |
| [07-mhi-infra](07-mhi-infra/) | Nothing. Read only. | How the real repository is laid out, and what a cloud provider adds |
| [08-pull-request](08-pull-request/) | A reviewed pull request | Pushing, describing, responding to review, and why merging is the approval |

## Catching up

[reference/](reference/) holds what your workspace should contain at the end of each step. If a step defeats you, drop the finished version over the top of your own and carry on:

```
WORKSPACE=your-name
cp -r ~/learn-iac/reference/04-modules/. ~/learn-iac/workspaces/$WORKSPACE/
```

The trailing `/.` copies the contents rather than the directory. Delete anything the step was supposed to remove, because copying files in cannot take files out. Step 03 has no snapshot of its own, since it changes which binary you run and leaves every file alone.

Reach for this rather than falling behind, and come back to the step afterwards.

## This repository is public

Everything you write here, including your branch, your pull request and your commit messages, is readable by anyone. That is deliberate, and it is worth understanding before you type your first commit, because it is also true of the repository that runs our AWS estate.

Two reasons for it. The first is that the discipline is the point: "could this be public?" is a sharper test than "is this tidy enough", and it is harder to let slip under pressure than a self-imposed rule. The second is that other charities get to read a real infrastructure repository rather than a sanitised template, and the working code is the hard part to get right. Both come from ADR-0005 in the infrastructure repository (`docs/adr/0005-open-source-the-repo.md`), which reached the same decision for the same reasons.

Never commit, here or there:

- Secrets of any kind. Keys, tokens, passwords, certificates, connection strings with credentials in them.
- Service-user data. For a mental health organisation this is the absolute line.
- Staff personal-life data. Personal email addresses, home addresses, HR records.
- Internal references. Ticket keys, internal-only URLs, the names of internal tools and chat channels.
- Real production bucket names, host names, and private addresses.

Fine to commit: AWS account numbers, which AWS documents as identifying rather than secret, and staff work email addresses.

A secret that a running system needs is supplied at the point it runs, from an identity the machine already holds or from a secret store it can read, so that the value never exists in a file at all. [Step 07](07-mhi-infra/) shows what that looks like in practice.

## How to work through it

- Run `destroy` at the end of any step that created something, so the next step starts from nothing.
- Ask the moment you are stuck. Each step builds on the one before it, so a step you did not finish blocks the rest.
- Read the plan output rather than scrolling past it. Most of the course is learning to read a plan.

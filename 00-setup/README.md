# 00. Setup

Do this before the session, on the machine you are bringing. About fifteen minutes.

Everything here is checked by a command that prints something. If a command prints nothing or prints an error, stop there and say so, rather than moving on.

## 1. Install mise

We pin every tool with [mise](https://mise.jdx.dev), so that everyone in the room runs the same versions.

```
brew install mise
```

If you are not on macOS, follow the [mise installation page](https://mise.jdx.dev/getting-started.html) instead.

Then hook it into your shell, once:

```
echo 'eval "$(mise activate zsh)"' >> ~/.zshrc
```

Open a new terminal window. Everything below assumes that new window.

## 2. Clone the repository

```
git clone git@github.com:MentalHealthInnovations/learn-iac.git ~/learn-iac
```

The rest of this page assumes your shell is in `~/learn-iac`.

## 3. Install the tools

mise will not read a config file it has not been told to trust:

```
mise trust
mise install
```

That installs Terraform, OpenTofu, Terragrunt and pre-commit at the versions in [mise.toml](../mise.toml). The first run downloads a few hundred megabytes.

## 3a. Install the commit hooks

```
pre-commit install
```

This repository runs checks on every commit, listed in [.pre-commit-config.yaml](../.pre-commit-config.yaml). Two of them matter to you.

`terraform_fmt` rewrites your `.tf` files to the standard layout. When it does, the commit stops and the rewritten file is sitting there unstaged, so you `git add` it again and commit a second time. That is the hook working, not an error.

`gitleaks` looks for anything shaped like a credential and refuses the commit if it finds one. This repository is public, so a committed credential is a published credential, and the only reliable fix for one is to treat it as compromised and rotate it. The hook is there to make sure you never need to.

Check they run:

```
pre-commit run --all-files
```

The first run downloads each hook's own environment and is slow. Later runs are quick.

## 4. Create the provider cache

```
mkdir -p ~/.terraform.d/plugin-cache
```

Every step downloads providers into this one directory rather than its own, which makes each `init` after the first one quick.

## 5. Check the tools

```
terraform version
tofu version
terragrunt --version
```

Expect Terraform 1.5.7, OpenTofu 1.12.x and Terragrunt 1.1.3. A different version means mise is not active in this shell, so go back to step 1.

Nothing in this class needs a cloud account, credentials, or a network connection beyond downloading the tools and two small plugins. If the commands above worked, you are ready.

## 6. Take a branch

You work on your own branch for the whole class and raise a pull request from it at the end.

```
git switch -c session/your-name
```

Use your actual name, in lower case, with a hyphen between words.

## Done

Move on to [01-local](../01-local/) when the session starts.

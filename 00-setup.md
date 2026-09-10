# 00. Setup

Everything here is checked by a command that prints something. If a command prints nothing or prints an error, stop there and say so, rather than moving on.

## 1. Install mise

We pin every tool with [mise](https://mise.jdx.dev), so that everyone runs the same versions.

```
brew install mise
```

If you are not on macOS, follow the [mise installation page](https://mise.jdx.dev/getting-started.html) instead.

Then hook it into your shell, once:

```
echo 'eval "$(mise activate zsh)"' >> ~/.zshrc
source ~/.zshrc
```

## 2. Clone the repository

```
git clone https://github.com/MentalHealthInnovations/learn-iac.git ~/learn-iac
```

The rest of this page assumes your shell is in `~/learn-iac`.

## 3. Install the tools

mise will not read a config file it has not been told to trust:

```
mise trust
mise install
mkdir -p ~/.terraform.d/plugin-cache
```

That installs Terraform, OpenTofu, Terragrunt and pre-commit at the versions in [mise.toml](mise.toml). The first run downloads a few hundred megabytes.

The last line creates the shared provider download cache that [mise.toml](mise.toml) points `TF_PLUGIN_CACHE_DIR` at. Every step downloads providers into that one directory rather than its own, which makes each `init` after the first one quick. OpenTofu will not create the directory itself ([OpenTofu CLI configuration docs](https://opentofu.org/docs/cli/config/config-file/)), so it has to exist before the first `init`.

## 4. Install the commit hooks

```
pre-commit install
```

This repository runs checks on every commit, listed in [.pre-commit-config.yaml](.pre-commit-config.yaml). Two of them matter to you.

`terraform_fmt` rewrites your `.tf` files to the standard layout. When it does, the commit stops and the rewritten file is sitting there unstaged, so you `git add` it again and commit a second time. That is the hook working, not an error.

`gitleaks` looks for anything shaped like a credential and refuses the commit if it finds one. This repository is public, so a committed credential is a published credential, and the only reliable fix for one is to treat it as compromised and rotate it. The hook is there to make sure you never need to.

Check they run:

```
pre-commit run --all-files
```

The first run downloads each hook's own environment and is slow. Later runs are quick.

## 5. Take a branch

You work on your own branch throughout and raise a pull request from it at the end.

```
WORKSPACE=your-name
git switch -c learn/$WORKSPACE
```

Use your actual name, in lower case, with a hyphen between words.

## 6. Make your own working directory

Everyone works in a directory of their own, so that a dozen pull requests can be merged without any of them touching the same file.

```
mkdir -p workspaces/$WORKSPACE
```

Every step from here on works inside `workspaces/$WORKSPACE/`, and each one opens by setting `WORKSPACE` again so that it stands on its own in a fresh terminal.

## Done

Move on to [01-local](01-local.md).

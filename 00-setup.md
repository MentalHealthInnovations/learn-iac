# 00. Setup

## 1. Install mise

Every tool is pinned with [mise](https://mise.jdx.dev), so that everyone runs the same versions.

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
cd ~/learn-iac
```

## 3. Install the tools

mise will not read a config file it has not been told to trust:

```
mise trust
mise install
mkdir -p ~/.terraform.d/plugin-cache
```

That installs Terraform, OpenTofu, Terragrunt and pre-commit at the versions in [mise.toml](mise.toml). The first run downloads a few hundred megabytes.

The last line creates the shared provider cache that [mise.toml](mise.toml) points `TF_PLUGIN_CACHE_DIR` at, so each `init` after the first is quick. OpenTofu will not create that directory itself ([OpenTofu CLI configuration docs](https://opentofu.org/docs/cli/config/config-file/)).

## 4. Install the commit hooks

```
pre-commit install
```

Checks run on every commit, listed in [.pre-commit-config.yaml](.pre-commit-config.yaml). Two of them matter to you.

`terraform_fmt` rewrites your `.tf` files to the standard layout. When it does, the commit stops and the rewritten file is left unstaged, so you `git add` it again and commit a second time. That is the hook working, not an error.

`gitleaks` refuses a commit containing anything shaped like a credential. This repository is public, so a committed credential is a published credential, and the only reliable fix is to rotate it.

Check they run:

```
pre-commit run --all-files
```

The first run downloads each hook's own environment and is slow.

## 5. Take a branch

```
WORKSPACE=your-name
git switch -c learn/$WORKSPACE
```

Use your actual name, in lower case, with a hyphen between words.

## 6. Make your working directory

```
mkdir -p workspaces/$WORKSPACE
```

Every step works inside `workspaces/$WORKSPACE/` and opens by setting `WORKSPACE` again, so each stands on its own in a fresh terminal.

## Done

Move on to [01-local](01-local.md).

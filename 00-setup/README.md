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

That installs Terraform, OpenTofu and Terragrunt at the versions in [mise.toml](../mise.toml). The first run downloads a few hundred megabytes.

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

## 6. Check your AWS access

Nothing before step 04 touches AWS, but a credential problem found on the day costs you the second half of the class, so find it now.

```
export AWS_PROFILE=learn-iac
aws sts get-caller-identity
```

That prints an account number, a user id and an ARN carrying your name. An error, a hang, or a prompt for a password means something is wrong and needs sorting before the session.

If `aws` is not found, install the AWS Command Line Interface (CLI) with `brew install awscli`.

## 7. Take a branch

You work on your own branch for the whole class and raise a pull request from it at the end.

```
git switch -c session/your-name
```

Use your actual name, in lower case, with a hyphen between words.

## Done

Move on to [01-local](../01-local/) when the session starts.

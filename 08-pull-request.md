# 08. Raise a pull request

You have been committing at the end of every step. This one gets that work reviewed, which is the part that matters and the part nobody practises.

```
WORKSPACE=your-name
cd ~/learn-iac
```

## 1. Look at what you have

```
git log --oneline
git diff main...HEAD --stat
```

One commit per step, and a diff that shows the same directory being built up and refactored rather than copied. That is why each step ended with a commit: the reviewer reads a sequence they can follow, not one lump.

The three dots in `main...HEAD` mean "everything on my branch that is not on main", which is exactly what a pull request contains. Two dots would mean something different and is a common source of confusion.

## 2. Push your branch

You cloned over HTTPS, which needs no SSH key but does need GitHub credentials before it will accept a push. The GitHub CLI is the shortest way to arrange that:

```
gh auth login
```

Choose HTTPS as the protocol and answer yes when it offers to authenticate Git with your GitHub credentials, which is what stores them for later pushes ([GitHub's caching-credentials docs](https://docs.github.com/en/get-started/git-basics/caching-your-github-credentials-in-git)). Git Credential Manager does the same job if you already have it.

```
git push -u origin HEAD
```

`-u` sets the upstream, so from now on plain `git push` knows where to go. Git prints a link to open a pull request. Follow it.

If the push is rejected because you have no write access, fork the repository, add your fork as a second remote, and push there instead. The pull request then comes from your fork, and everything below reads the same.

## 3. Write the description

The base branch is `main`. Everything you have added lives under `workspaces/$WORKSPACE/`, so your pull request touches no file anyone else's touches and can be merged without waiting for theirs.

Title it the way the commits are titled: `type: description`, so `docs: worked through the steps` or similar.

For the body, three things are worth more than a summary of what you did, which the reviewer can see in the diff:

- Where you got stuck, and what unstuck you.
- Anything you copied from `reference/` rather than working out, and why.
- A question about something that worked but you did not understand.

The third is the most valuable and the least often written. A pull request is a place to ask, not only a place to submit.

## 4. Get reviewed

Your reviewer reads the diff and leaves comments on specific lines. Some will be questions, some will be suggestions, some will be wrong. All three are normal.

Reply to the ones you disagree with rather than silently changing the code. A review is a conversation between two people who both want the thing to work, and a reviewer who is mistaken would rather find out in the thread than after the merge.

## 5. Respond with a commit

Make the change, then:

```
FILE=path/to/the/file/you/changed
git add $FILE
git commit -m "fix: address review comment on $FILE"
git push
```

The pull request updates itself. You do not open a new one, and you do not need to do anything in the web interface. This surprises people the first time.

If the commit hooks reject the commit, read what they say. `terraform_fmt` rewriting a file is not a failure, it is the hook doing its job: add the rewritten file and commit again.

## 6. Why this matters more for infrastructure

In an ordinary code repository, a merged pull request means the code is in. In the repository you looked at in step 07, merging is the approval to change live infrastructure. Continuous integration runs a plan when the pull request opens, a person reads that plan, and merging is what triggers the apply.

That is enforced rather than agreed. The permission sets are arranged so that most people can run a plan and cannot write state, so applying from a laptop is not something you are trusted not to do, it is something you cannot do.

Which means the review you are practising here is not a formality bolted on to the end. It is the only thing standing between a plan and production.

## 7. Afterwards

Once your pull request is approved, merge it. Then, because the branch has served its purpose:

```
git switch main
git pull
git branch -d learn/$WORKSPACE
```

## If you have time

- Read someone else's pull request and leave one comment on it. Reviewing is the harder half and gets less practice.
- Find a commit of yours with a message that would not help anyone in six months, and work out what it should have said.

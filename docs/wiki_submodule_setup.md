# Wiki Submodule Setup

## What is a git submodule

A git submodule is a pointer from one git repository to a specific commit in a completely separate git repository. The main Mealchemy repo does not store the wiki files directly. Instead, it holds a reference to the wiki submodule pointer. The two repos have independent histories, independent branches, and independent push/pull flows.

This means when you are inside the `wiki/` folder, you are operating on the wiki repo, not the main repo. The branch is `master`, not `main`. The reason for this is that it allows for all team members to have the same instance of documenation on all branches, instead of trying to propogate updated diagrams and requirements down to all branches.

## Why we use it this way

Storing the wiki as a submodule means the documentation is versioned alongside the code. You can see which version of the docs matched which version of the codebase. It also means the wiki content shows up in the GitHub wiki tab for easy browsing, while still being trackable in CI and the main repo history.

The `wiki-sync.yml` workflow runs daily at 02:00 UTC. It checks if the wiki repo has any new commits and if it does, updates the submodule pointer across every open branch in the main repo automatically. Teammates get the latest wiki without needing to manually run any sync commands.

--------------------------------------
Setup steps we took to accomplish this:

## First-time setup (done once)

### 1. Enable the GitHub wiki tab

Wiki tab was enabled for our repo at the start of setup.

### 2. Add the wiki as a submodule

Run this from the root of the main repo:

```bash
git submodule add https://github.com/cos301-se-2026/Mealchemy.wiki.git wiki
git commit -m "Add wiki as submodule"
git push
```

This creates the `wiki/` folder and the `.gitmodules` file that records the submodule URL.

## Cloning the repo with the submodule

If you are cloning fresh, include the submodule in one command:

```bash
git clone --recurse-submodules https://github.com/cos301-se-2026/Mealchemy.git
```

If you already cloned without it and `wiki/` is empty:

```bash
git submodule update --init --recursive
```

## Editing and pushing wiki changes

Always `cd` into the `wiki/` folder first. The git commands you run inside there apply to the wiki repo, not the main repo.

```bash
cd wiki
# create or edit .md files
git add .
git commit -m "Update docs"
git push origin master
```

The wiki branch is `master` not `main`. This is how GitHub creates it.

After pushing, the changes show up immediately in the GitHub Wiki tab. The submodule pointer in the main repo will be updated by the daily `wiki-sync.yml` workflow, or you can do it manually (see below).

## Pulling the latest wiki changes

If someone else pushed wiki changes and you want them locally:

```bash
git submodule update --remote wiki
```

Or after a regular `git pull` on the main repo:

```bash
git submodule update --init --recursive
```

## Manually updating the submodule pointer in the main repo

If you do not want to wait for the daily sync workflow:

```bash
# From the main repo root
git submodule update --remote wiki
git add wiki
git commit -m "Update wiki submodule pointer"
git push
```

## Common mistake to avoid

If you run `git status` or `git commit` while inside `wiki/` and see a branch listed as `## master`, you are in the wiki repo. If you are in the main repo, you will see your feature branch or `dev`. Always check before committing.

Running `git push` from inside `wiki/` pushes to the wiki repo. Running `git push` from the main repo root pushes to the main repo. They are completely separate.

-------------------------------------
## What wiki-sync.yml does

The workflow file at `.github/workflows/wiki-sync.yml` runs on a schedule (daily at 02:00 UTC) and can also be triggered manually from the Actions tab.

What it does step by step:
1. Checks whether the wiki repo has any new commits since the main repo last recorded it
2. If yes, it loops over every open branch in the main repo
3. Updates the submodule pointer on each branch to point at the latest wiki commit
4. Commits with `[skip ci]` so this automated commit does not trigger another full CI run

The result is that all teammates on all branches always have the latest wiki without doing anything manually.

## Triggering wiki-sync manually

Go to the **Actions** tab on GitHub, find **wiki-sync**, click **Run workflow**, and select the branch. Useful if you pushed a big wiki update and do not want to wait until 02:00 UTC.

# Git Safety Workflow

This repo is set up so the playable demo has a stable checkpoint before risky feature work.

## Branches

- `main` is the stable playable line.
- `dev` is where new gameplay experiments should happen first.

## Baseline Tag

- `stable/playable-baseline` marks the first clean Godot horde demo checkpoint.

## Before Risky Changes

Run:

```powershell
git status
git add .
git commit -m "Describe the working checkpoint"
```

Then make the risky change on `dev`.

## If Something Breaks

To compare the current work against the last commit:

```powershell
git diff
```

To return to the stable playable branch:

```powershell
git switch main
```

To go back to active development:

```powershell
git switch dev
```

## Off-Machine Backup

The remaining safety upgrade is adding a GitHub remote and pushing Git LFS assets:

```powershell
git remote add origin https://github.com/iammikevineyard/<repo-name>.git
git push -u origin main
git push -u origin dev
git push origin stable/playable-baseline
git lfs push --all origin
```

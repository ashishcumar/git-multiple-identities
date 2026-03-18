# git-multiple-identities

Use **one global Git identity** and **multiple path-specific identities** — e.g. personal as default, office for `~/work`, client-A for `~/clients/client-a`. No manual switching; Git picks identity by repo path.

## Quick start

```bash
git clone https://github.com/ashishcumar/git-multiple-identities.git
cd git-multiple-identities
./setup.sh
```

You’ll be asked for:

1. **Global default** — name and email used in any repo that doesn’t match a path below.
2. **Path-specific identities** — for each: a label (e.g. `office`, `client-a`), folder path, name, and email. Add as many as you need; answer `n` when done.

Your existing `~/.gitconfig` is backed up with a timestamp before any changes.

## How it works

- **Default identity** is stored in `~/.gitconfig` under `[user]`.
- For each path-specific identity, the script creates `~/.gitconfig-<label>` and adds an `includeIf "gitdir:<path>/"` in `~/.gitconfig` that loads that file for repos **inside** that path.
- Repos outside all configured paths use the global identity.

Paths should not overlap (or list more specific paths first). The **trailing slash** in paths is required and is added by the script.

## Verify

Inside a repo:

```bash
git config user.name && git config user.email
```

You should see the identity for that path (or the global one if the repo isn’t under any configured path).

## Requirements

- Git 2.13+ (for `includeIf`)
- Bash (macOS / Linux)

## License

MIT

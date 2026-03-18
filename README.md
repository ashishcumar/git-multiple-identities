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

## Publishing / pushing branches

**Commit identity** (name/email) is chosen by path. **Push authentication** is separate:

- **HTTPS** — Git uses your system or credential-helper credentials (e.g. one account per host). To push as different identities to the same host, use different remotes (e.g. different URLs or a credential helper that picks by repo path), or use SSH instead.
- **SSH** — Use one SSH key per identity and point Git at the right key per repo or host. Example for a work key:
  ```bash
  # In a repo under your work path, or in ~/.ssh/config:
  Host github.com-work
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_work
  ```
  Then set the remote to `git@github.com-work:org/repo.git` for that repo.

If "Publish Branch" fails, check: remote URL (`git remote -v`), that you’re logged in (HTTPS) or that the correct SSH key is used and added to the remote (e.g. GitHub/GitLab).

### GitHub: "Your push would publish a private email address" (GH007)

GitHub blocks pushes when the commit author email is one you’ve marked as **private** (so it won’t appear in public repo history). Fix it by either:

- **Use GitHub’s noreply email** so your real email never appears:
  ```bash
  git config user.email "USERNAME@users.noreply.github.com"
  ```
  Then rewrite the last commit to use it: `git commit --amend --reset-author --no-edit`, and push again. Your exact noreply address is shown under [GitHub → Settings → Emails](https://github.com/settings/emails).
- Or in [GitHub → Settings → Emails](https://github.com/settings/emails), make the email public or disable “Block command line pushes that expose my email”.

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

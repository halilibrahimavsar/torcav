# Hosting the Privacy Policy on GitHub Pages

Google Play and Apple App Store both require a **public, stable URL** for your privacy policy. The simplest free option for an individual developer is GitHub Pages. This document walks through the steps.

## One-time setup

### 1. Create a public repository
- Sign in to GitHub at https://github.com.
- Click **New repository**.
- **Repository name:** `torcav-privacy` (or any name you prefer)
- **Public** (Pages requires this on free accounts)
- Initialise with a README (optional but easier)
- Click **Create repository**

### 2. Add the privacy policy as `index.md`
Two ways:

**Option A — via web UI (easiest):**
- In the new repo, click **Add file → Create new file**
- Name it `index.md`
- Paste the contents of `docs/PRIVACY_POLICY.md` from the Torcav repository
- Commit to `main`

**Option B — via git CLI:**
```bash
git clone git@github.com:<your-username>/torcav-privacy.git
cd torcav-privacy
cp /path/to/torcav/docs/PRIVACY_POLICY.md index.md
git add index.md
git commit -m "Initial privacy policy"
git push
```

### 3. Enable GitHub Pages
- In the `torcav-privacy` repo, go to **Settings → Pages**
- Under **Source**, select **Deploy from a branch**
- Select branch `main`, folder `/ (root)`, click **Save**
- Wait ~1 minute. The page will appear at:
  `https://<your-username>.github.io/torcav-privacy/`

### 4. Verify
- Open the URL in a browser.
- The markdown should render as a styled HTML page.
- If you only see raw markdown source, the Jekyll renderer didn't pick up the file. Add a tiny `_config.yml` with `theme: jekyll-theme-cayman` (or any theme) and re-push.

### 5. Wire the URL into Torcav
Update `lib/features/settings/presentation/pages/privacy_policy_page.dart` — find the `_privacyPolicyUrl` constant and set it to the GitHub Pages URL.

The file is at:
```
lib/features/settings/presentation/pages/privacy_policy_page.dart
```

Search for `_privacyPolicyUrl` and replace the placeholder with your URL.

### 6. Use the URL in Play Console
- Play Console → App content → Privacy policy → paste the URL.
- Apple App Store Connect → App Information → Privacy Policy URL.

## Updating the policy later

When you change the policy in the Torcav repository:

1. Bump the version number and update the **Effective date** in `docs/PRIVACY_POLICY.md`.
2. Copy the new content to `index.md` in `torcav-privacy` and commit.
3. (Optional) Open a new minor app release that mentions the policy update — KVKK and GDPR both expect material changes to be visible to users.

## Notes

- GitHub Pages is free for public repositories on personal accounts.
- The URL never changes as long as the repo + username stays the same.
- You can later switch to a custom domain (e.g., `privacy.torcav.app`) by adding a `CNAME` file. This is optional.
- If you ever delete the `torcav-privacy` repo, the URL stops working **and Play Store may de-rank your listing**. Treat this URL like a production resource.

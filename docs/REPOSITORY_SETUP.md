# GitHub repository setup

Suggested repository name:

```text
bd-rlocked-eeg-field-paper
```

## Browser workflow

1. Go to GitHub.
2. Select **New repository**.
3. Enter the repository name.
4. Choose **Private** initially. Make it public only after checking ethics, consent, coauthor approval, and journal policy.
5. Do not initialize with a README, license, or `.gitignore` if you plan to push this prepared folder from your computer.
6. After creating the empty repository, copy the repository URL.

## Command-line workflow

From the folder that contains this repository package:

```bash
cd bd_rlocked_eeg_github_repo_public
git init
git add .
git commit -m "Initial paper repository"
git branch -M main
git remote add origin https://github.com/<USER_OR_ORG>/bd-rlocked-eeg-field-paper.git
git push -u origin main
```

For the full derived-data package, use a private repository or Git LFS for large files. Do not push subject-level data to a public repository unless approved.

## Recommended first GitHub release

1. Confirm the license.
2. Replace DOI placeholders in `CITATION.cff`.
3. Confirm whether manuscript drafts should be public.
4. Confirm whether derived subject-level tables can be public.
5. Tag the first release after acceptance, for example:

```bash
git tag v1.0.0
git push origin v1.0.0
```

Then archive the release with Zenodo if you want a repository DOI.

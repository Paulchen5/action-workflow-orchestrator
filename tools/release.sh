#!/usr/bin/env bash
set -euo pipefail

# Check if current directory is a git repository root
if [ ! -d .git ]; then
    echo "Error: This script must be run from the repository root (where .git is a directory)."
    exit 1
fi

ohai() {
    echo -e "\\033[34m==>\\033[0m \\033[1m$*\\033[0m"
}

# prepare release branch
ohai "Preparing release..."
previous_branch=$(git branch --show-current)
ohai "Current branch detected: ${previous_branch}"
ohai "Stashing uncommitted changes..."
git stash push --keep-index -m "pre-release"
ohai "Fetching latest changes from main..."
git fetch origin main
version=$(npm run get-next-version --silent)
ohai "New version will be: ${version}"

# start releasing
ohai "Start release process..."
release_branch="release/v${version}"
ohai "Creating and switching to release branch: ${release_branch}"
git switch --create ${release_branch} origin/main-test

# update versions
ohai "Updating versions and changelog..."
npm run release --silent
echo ${version} > VERSION

# build and push docker image
ohai "Building and pushing Docker image..."
make docker-build
make docker-push

# Update docker image version in action.yml
ohai "Updating Docker image version in action.yml..."
node ./tools/docker-image.js ${version}

# commit changes
ohai "Committing release changes..."
git add action.yml CHANGELOG.md package.json package-lock.json VERSION
git commit --gpg-sign --message "chore(release): v${version}"

# push branch and open pr
ohai "Pushing release branch and creating pull request..."
changelog=$(npm run get-last-changelog-entry --silent)
git push origin ${release_branch}
gh pr create --base main-test --head ${release_branch} --title "chore(release): v${version}" --body "${changelog}"

# post release steps
ohai "Running post-release steps..."
ohai "Switching back to previous branch: ${previous_branch}"
git switch ${previous_branch}
git branch -D ${release_branch}
ohai "Applying stashed changes..."
git stash apply stash@{0}

# check for merge conflicts after applying stash
if git status --untracked-files=no --porcelain | grep -q '^UU'; then
    echo "Error: Merge conflicts detected after applying stash. Please resolve them manually."
    exit 1
else
    ohai "No merge conflicts detected. Dropping the stash..."
    git stash drop stash@{0}
fi
ohai "Release process completed."

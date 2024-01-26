#!/bin/bash
set -e

while getopts u:t: flag
do
    case "${flag}" in
        u) github_username=${OPTARG};;
        t) github_api_token=${OPTARG};;
    esac
done

if [ ! -z ${github_username+x} ] && [ ! -z ${github_api_token+x} ]; then
    publish_documentation=true
fi

git_name="Documentation Bot"
git_email="elgato.mobile@corsair.com"
github_repository="elgatosf/streamdeck-kit-ipad"
git_remote="GitHub_docs"
documentation_branch="gh-pages"
documentation_dir="docs"
initial_branch=$(git branch | sed -n -e 's/^\* \(.*\)/\1/p')

build_documentation() {
    if [ ! -d "./$documentation_dir" ]; then
        echo "🗂️ Creating directory ${documentation_dir}..."
        mkdir $documentation_dir
    fi

    # Enables deterministic output 
    # - useful when you're committing the results to host on github pages
    export DOCC_JSON_PRETTYPRINT=YES

    echo "🚮 Cleaning DerivedData..."
    rm -rf ~/Library/Developer/Xcode/DerivedData

    echo "📙 Building documentation..."
    xcodebuild docbuild \
    -quiet \
    -scheme StreamDeckKit \
    -destination generic/platform=iOS \
    OTHER_DOCC_FLAGS="--transform-for-static-hosting --hosting-base-path streamdeck-kit-ipad --output-path $documentation_dir"

    if [ -z "$(ls -A $documentation_dir)" ]; then
    echo "🛑 No documentation was generated"
    exit 1
    fi
}

# Just build the docs if no GitHub credentials were given
if [ "$publish_documentation" != true ]; then
    rm -rf $documentation_dir
    build_documentation
    exit 0
fi

cleanup() {
    echo "🧽 Cleaning up..."
    git checkout $initial_branch
    rm -rf $documentation_dir
    git remote rm $git_remote
}

trap cleanup EXIT

# Setup remote and fetch latest 
git config user.name "$git_name"
git config user.email "$git_email"

# Add remote to sync with
git_remote_url="https://$github_username:$github_api_token@github.com/$github_repository/"
git remote add $git_remote $git_remote_url

# Pull from remote when matching branch exists
branches_found=$(git ls-remote --heads GitHub refs/heads/$initial_branch)
if [ -n "$branches_found" ]; then
    echo "⬇️ Pulling from ${github_repository}..."
    git pull $git_remote $initial_branch
fi

build_documentation

# Stash changes
git stash push -u  -- $documentation_dir

# Move to pages-branch and apply stash
echo "⤵️ Checking out branch \"$documentation_branch\"..."
git checkout $documentation_branch
rm -rf $documentation_dir
git stash pop

# Stage and commit changes 
git add $documentation_dir
commit_message="Updated DocC documentation"
echo "📄 Committing \"$commit_message\"..."
git commit -m "$commit_message"

# Push changes to repo
echo "⬆️ pushing to $git_remote:$documentation_branch..."
git push --set-upstream $git_remote $documentation_branch

#!/bin/bash
set -e

# This script builds the DocC documentation for a specific target of the package and publishes it to the GitHub Pages branch
#
# If no no credentials are given, it just builds the documentation as a static site to the documentation_dir.
# When `python3` is available. It will start a web server and host the resulting page.
#
# Parameters:
#   -r Repository: The path of the GitHub repo (without domain and leading slashes).
#   -s Scheme: The scheme to build the documentation for. Use `xcodebuild -list` to see a list of possible values.
#   -t Token: An API token that can be used to authenticate with GitHub.
#   -u User: A GitHub username that can be used to authenticate with GitHub.

git_name="Documentation Bot"
git_email="elgato.mobile@corsair.com"
git_remote="GitHub_docs"
github_repository="elgatosf/streamdeck-kit-ipad"
hosting_base_path="streamdeck-kit-ipad"
build_scheme="StreamDeckKit"
documentation_branch="gh-pages"
documentation_dir="docs"
initial_branch=$(git branch | sed -n -e 's/^\* \(.*\)/\1/p')

while getopts p:r:s:t:u: flag
do
    case "${flag}" in
        p) hosting_base_path=${OPTARG};;
        r) github_repository=${OPTARG};;
        s) build_scheme=${OPTARG};;
        t) github_api_token=${OPTARG};;
        u) github_username=${OPTARG};;
    esac
done

if [ ! -z ${github_username+x} ] && [ ! -z ${github_api_token+x} ]; then
    publish_documentation=true
fi

build_documentation() {
    if [ ! -d "./$documentation_dir" ]; then
        echo "🗂️ Creating directory ${documentation_dir}..."
        mkdir $documentation_dir
    fi

    # Enables deterministic output 
    # - useful when you're committing the results to host on github pages
    export DOCC_JSON_PRETTYPRINT=YES

    # Don't set base path when building for local(testing) deployment.
    if [ "$publish_documentation" = true ]; then
        base_path_param=" --hosting-base-path $hosting_base_path"
    else
        base_path_param=""
    fi

    echo "🚮 Cleaning DerivedData..."
    rm -rf ~/Library/Developer/Xcode/DerivedData

    echo "📙 Building documentation for scheme ${build_scheme}..."
    xcodebuild docbuild \
    -quiet \
    -scheme $build_scheme \
    -destination generic/platform=iOS \
    OTHER_DOCC_FLAGS="--transform-for-static-hosting$base_path_param --output-path $documentation_dir"
}

# When no GitHub credentials were given, just build the docs.
if [ "$publish_documentation" != true ]; then
    rm -rf $documentation_dir
    build_documentation
    if command -v python3 &> /dev/null; then
        echo "🌍 Starting web-server. Find the docs at http://localhost:8080/documentation"
        python3 -m http.server 8080 -d $documentation_dir
    fi
    exit 0
fi

cleanup() {
    echo "🧽 Cleaning up..."
    git checkout $initial_branch
    rm -rf $documentation_dir
    git remote rm $git_remote
}

trap cleanup EXIT

# Setup remote and fetch latest.
git config user.name "$git_name"
git config user.email "$git_email"

# Add remote to sync with.
git_remote_url="https://$github_username:$github_api_token@github.com/$github_repository/"
git remote add $git_remote $git_remote_url

# Pull from remote when matching branch exists.
branches_found=$(git ls-remote --heads GitHub refs/heads/$initial_branch)
if [ -n "$branches_found" ]; then
    echo "⬇️ Pulling from ${github_repository}..."
    git pull $git_remote $initial_branch
fi

build_documentation

# Stash changes.
echo "💾 Stashing changes..."
git stash push -u  -- $documentation_dir

# Move to pages-branch and apply stash.
echo "⤵️ Checking out branch \"$documentation_branch\"..."
git checkout $documentation_branch
rm -rf $documentation_dir
echo "🔨 Applying stash..."
git stash pop

# Stage and commit changes.
git add $documentation_dir
commit_message="Updated DocC documentation"
echo "📄 Committing \"$commit_message\"..."
git commit -m "$commit_message"

# Push changes to repo.
echo "⬆️ pushing to $git_remote:$documentation_branch..."
git push --set-upstream $git_remote $documentation_branch

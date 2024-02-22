#!/bin/bash
set -e

# This script builds the DocC documentation for a specific target of the package and publishes it to the GitHub Pages branch
#
# If no no credentials are given, it just builds the documentation as a static site to the documentation_dir.
# When `python3` is available. It will start a web server and host the resulting page.
#
# To publish the documentation to GitHub Pages, run the fillowing
# `sh  build-documentation.sh -t "<GitHub access token>" -u <GitHub username>`
#
# Parameters (For default values, see the definition at the top of the implementation):
#   -p Hosting base path: If the doc is not hosted at the root of the domain, set the path here.
#   -r Repository: The path of the GitHub repo (without domain and leading slashes).
#   -s Scheme: The scheme to build the documentation for. Use `xcodebuild -list` to see a list of possible values.
#   -t Token: An API token that can be used to authenticate with GitHub.
#   -u User: A GitHub username that can be used to authenticate with GitHub.

git_remote="GitHub_docs"
github_repository="elgatosf/streamdeck-kit-ipad"
hosting_base_path="streamdeck-kit-ipad"
build_scheme="StreamDeckKit"
documentation_branch="gh-pages"
documentation_dir="docs"
initial_branch=$(git branch | sed -n -e 's/^\* \(.*\)/\1/p')
format_bold=$(tput bold)
format_normal=$(tput sgr0)

# Parsing flags.
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

echo "Running documentation build script with parameters:"
echo " - p) hosting_base_path: ${hosting_base_path}"
echo " - r) github_repository: ${github_repository}"
echo " - s) build_scheme: ${build_scheme}"
echo " - t) github_api_token: ${github_api_token}"
echo " - u) github_username: ${github_username}"

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
    -scheme $build_scheme \
    -destination generic/platform=iOS \
    OTHER_DOCC_FLAGS="--transform-for-static-hosting$base_path_param --output-path $documentation_dir" \
    | xcpretty
}

cleanup() {
    echo "🧽 Cleaning up..."
    current_branch=$(git branch | sed -n -e 's/^\* \(.*\)/\1/p')
    
    if [ "$current_branch" != "$initial_branch" ]; then
        echo "⤵️ Checking out branch \"$initial_branch\"..."
        git checkout $initial_branch
    fi

    if [ -d "./$documentation_dir" ]; then
        echo "🚮 Deleting \"$documentation_dir\" folder..."
        rm -rf $documentation_dir
    fi

    remotes_found=$(git remote | grep $git_remote)
    if [ -n "$remotes_found" ]; then
        echo "🚮 Removing remote \"$git_remote\"..."
        git remote rm $git_remote
    fi
}

trap cleanup EXIT

# When no GitHub credentials were given, just build the docs.
if [ "$publish_documentation" != true ]; then
    build_documentation
    if command -v python3 &> /dev/null; then
        echo "🌍 Starting web-server. Find the docs at ${format_bold}http://localhost:8080/documentation${format_normal}"
        python3 -m http.server 8080 -d $documentation_dir
    fi
    exit 0
fi

# Add remote to sync with.
git_remote_url="https://$github_username:$github_api_token@github.com/$github_repository/"
git remote add $git_remote $git_remote_url
echo "⬇️ Fetching $git_remote($git_remote_url)..."
git fetch $git_remote

build_documentation

# Stash changes.
echo "💾 Stashing changes..."
git stash push -u  -- $documentation_dir

# Move to pages-branch and apply stash.
echo "⤵️ Checking out branch \"$documentation_branch\"..."
git checkout --track  $git_remote/$documentation_branch
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

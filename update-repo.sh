#!/bin/sh
update_current_repo() {
#    if [[ $TRAVIS_EVENT_TYPE != "api" ]]; then
#        echo "This build wasn't trigger using api. SDK auto update declined."
#        return 0
#    fi
    if [[ $sdk_updated == FALSE ]]; then
        echo "Nothing to update in repo."
        return 1
    fi

    local testapp_head_ref testapp_branch_ref
    testapp_head_ref=$(git rev-parse HEAD)
    if [[ $? -ne 0 || ! $testapp_head_ref ]]; then
        echo "Failed to get HEAD reference"
        return 1
    fi

    testapp_branch_ref=$(git rev-parse "$TRAVIS_BRANCH")
    if [[ $? -ne 0 || ! $testapp_branch_ref ]]; then
        echo "Failed to get $TRAVIS_BRANCH reference."
        return 1
    fi

    if [[ $testapp_head_ref != $testapp_branch_ref ]]; then
        echo "HEAD ref ($testapp_head_ref) does not match $TRAVIS_BRANCH ref ($testapp_branch_ref)"
        echo "There might be a new commit in repository."
        return 0
    fi

    if ! git add --all .; then
        echo "Failed to add modified files to git index"
        return 1
    fi

    if ! git commit -m "Travis CI Commit: Updated sdk for the latest version"; then
    echo "Failed to commit updates"
    return 1
    fi

    local remote=origin
    if [[ $GITHUB_TOKEN != "" ]]; then
        remote=https://$GITHUB_TOKEN@github.com/$TRAVIS_REPO_SLUG
    else
        echo "GitHub token is missing"
    fi

    if ! git push --quiet "$remote" "$TRAVIS_BRANCH" > /dev/null; then
        echo "Failed to push git changes"
        return 1
    else
        echo "Pushed successfully"
    fi
}
update_current_repo


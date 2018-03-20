#!/bin/sh
# mobile-sdk-ios auto update script

update_submodule() {
#    if [[ $TRAVIS_EVENT_TYPE != "api" ]]; then
#        echo "This build wasn't trigger using api. Repo auto update declined."
#        return 0
#    fi

    if [[ $TRAVIS_BRANCH != master ]]; then
        echo "This is not master branch"
        return 0
    fi

    if ! git checkout "$TRAVIS_BRANCH"; then
        echo "Failed to checkout $TRAVIS_BRANCH"
        return 1
    fi

    if ! cd ./SnapshotTests; then
        echo "Folder with sdk was not found"
        return 1
    fi

    local remote=origin
    if [[ $GITHUB_TOKEN != "" ]]; then
        remote=https://$GITHUB_TOKEN@github.com/RomanTysiachnik/SnapshotTests
    else
        echo "GitHub token is missing"
    fi

    export sdk_updated=FALSE
    local sdk_current_ref sdk_new_ref
    sdk_current_ref=$(git rev-parse HEAD)
    if [[ $? -ne 0 || ! $sdk_current_ref ]]; then
        echo "Failed to get old HEAD reference"
        return 1
    fi

    if ! git pull "$remote" "master" ; then
        echo "Failed to pull repo."
    fi

    sdk_new_ref=$(git rev-parse HEAD)
    if [[ $? -ne 0 || ! $sdk_new_ref ]]; then
        echo "Failed to get new HEAD reference."
        return 1
    fi

    if ! cd ..; then
        echo "Failed to return to the previous folder"
        return 1
    fi

    if [[ $sdk_current_ref == $sdk_new_ref ]]; then
        echo "The  repo has the latest version."
        return 0
    else
        sdk_updated=TRUE
    fi
}

update_submodule

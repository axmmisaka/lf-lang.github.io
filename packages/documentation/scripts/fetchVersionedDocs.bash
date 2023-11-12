#!/bin/bash

REMOTE='https://github.com/axmmisaka/lingua-franca.git'
BRANCH='move-docs-here' # I'm unsure if this is useful
REPO_NAME='lingua-franca-docs'
RESULT_DIR_NAME='docs'

git clone --quiet --no-checkout --filter=blob:none --sparse ${REMOTE} -b ${BRANCH} ${REPO_NAME}
pushd ${REPO_NAME} || exit 1

git sparse-checkout init --no-cone
git sparse-checkout set docs

tags=$(git tag)
tags_with_docs=()
for tag in ${tags}; do
    git worktree add "../${RESULT_DIR_NAME}/${tag}" "${tag}" --no-checkout
    git -C "../${RESULT_DIR_NAME}/${tag}" checkout --quiet "${tag}"
    if [[ -d "../${RESULT_DIR_NAME}/${tag}/docs" ]]; then
        tags_with_docs+=("${tag}")
    else
        rm -rf "../${RESULT_DIR_NAME}/${tag}/"
    fi
done
# Go back to origin pwd
popd || exit 1

for tag in "${tags_with_docs[@]}"; do
    # First, strip out the inner "docs" directory
    mv "./${RESULT_DIR_NAME}/${tag}/docs/"* "./${RESULT_DIR_NAME}/${tag}"
    rm -r "./${RESULT_DIR_NAME}/${tag}/docs/"
    if [ "${tag}" = "nightly" ]; then
        # See below; although we do not alter the permalink for nightly
        find "docs/${tag}/" -type f -name "*.md" -exec sed -i -E "2 aversion: ${tag}" {} +
    else
        # This looks like shit, let me explain.
        # First, it finds all *.md file under the "docs/${tag}/" directory.
        # Then these files are passed to `sed` via `exec`, as an "array" (the + option), to the `{}` part at the back of this command.
        # sed is configured to do stuff in-place `-i`, and it does two things:
        # First, it replaces the /docs/handbook/xxxyyy to contain the version number: /docs/handbook/v6.9.420/xxxyyy
        # Then, at the second line, it appends "version: xxxyyy" to the metadata
        find "docs/${tag}/" -type f -name "*.md" -exec sed -i -E "s/^permalink: \/docs\/handbook\/(.*)$/permalink: \/docs\/handbook\/${tag}\/\1/;2 aversion: ${tag}" {} +
    fi
done



for tag in "${tags_with_docs[@]}"; do
    echo ${tag}
done
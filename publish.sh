#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

LATEST_TAG=$(git tag -l | tail -n 1)

printf "Your latest release version: ${LATEST_TAG}\n"
printf "Provide the new release version without the 'v' prefix.\n"
read -p "What is the new release version (<EIDAS_NODE_VERSION>-<REVISION>): " NEW_TAG

# Update version in helm chart
sed -i 's@version: .*@version: '"${NEW_TAG}"'@' ${DIR}/helm/Chart.yaml

# Commit, Tag and push changes
git add ${DIR}/helm/Chart.yaml
git commit -m "Helm Chart Release ${NEW_TAG}"
git tag -s v${NEW_TAG} -m "v${NEW_TAG}"
git push --atomic origin main v${NEW_TAG}

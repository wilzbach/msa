#!/bin/bash

s3="aws s3"
export AWS_DEFAULT_REGION="eu-central-1"

# to be sure - run build again
npm run build

# current version
PACKAGE_VERSION=$(cat package.json \
  | grep version \
  | head -1 \
  | awk -F: '{ print $2 }' \
  | sed 's/[",]//g')

MINOR_VERSION=$(echo $PACKAGE_VERSION | awk -F. '{printf "%s.%s", $1, $2}')
MAJOR_VERSION=$(echo $PACKAGE_VERSION | awk -F. '{print $1}')

echo "LATEST: ${PACKAGE_VERSION}"

for folder in "latest" ${PACKAGE_VERSION} ${MINOR_VERSION} ${MAJOR_VERSION} ; do

echo "uploading to s3 folder: $folder"

$s3 cp --acl public-read --content-type "application/javascript" dist/msa.js "s3://cdn.bio.sh/msa/${folder}/msa.js"
$s3 cp --acl public-read --content-type "application/octet-stream" dist/msa.js.map "s3://cdn.bio.sh/msa/${folder}/msa.js.map"
$s3 cp --acl public-read --content-type "application/javascript" --content-encoding "gzip" dist/msa.min.gz.js "s3://cdn.bio.sh/msa/${folder}/msa.min.gz.js"
$s3 cp --acl public-read --content-type "application/octet-stream" dist/msa.js.map "s3://cdn.bio.sh/msa/${folder}/msa.min.js.map"

done

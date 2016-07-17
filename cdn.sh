#!/bin/bash

s3="aws s3"
export AWS_DEFAULT_REGION="eu-central-1"

# set version to equal git tag
npm install npm-prepublish
./node_modules/npm-prepublish/bin/npm-prepublish.js --verbose

# to be sure - run build again
npm run build

# current version
PACKAGE_VERSION=$(git describe --exact-match HEAD)

if [ $? -eq 0 ] ; then
	PACKAGE_VERSION="${PACKAGE_VERSION:1:${#PACKAGE_VERSION}-1}"
	MINOR_VERSION=$(echo $PACKAGE_VERSION | awk -F. '{printf "%s.%s", $1, $2}')
	MAJOR_VERSION=$(echo $PACKAGE_VERSION | awk -F. '{print $1}')
fi

echo "LATEST: ${PACKAGE_VERSION}"

# only update versions if tagged
if [[ ! -z "${PACKAGE_VERSION}" ]] ; then
	VERSIONS="latest ${PACKAGE_VERSION} ${MINOR_VERSION} ${MAJOR_VERSION}"
else
	VERSIONS="latest"
fi

for folder in $VERSIONS ; do

echo "uploading to s3 folder: $folder"

$s3 cp --acl public-read --content-type "application/javascript" dist/msa.js "s3://cdn.bio.sh/msa/${folder}/msa.js"
$s3 cp --acl public-read --content-type "application/octet-stream" dist/msa.js.map "s3://cdn.bio.sh/msa/${folder}/msa.js.map"
$s3 cp --acl public-read --content-type "application/javascript" --content-encoding "gzip" dist/msa.min.gz.js "s3://cdn.bio.sh/msa/${folder}/msa.min.gz.js"
$s3 cp --acl public-read --content-type "application/octet-stream" dist/msa.js.map "s3://cdn.bio.sh/msa/${folder}/msa.min.js.map"

done

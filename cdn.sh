#!/bin/bash

npm run build

echo "uploading to s3"

s3cmd --acl-public -m "application/javascript" put dist/msa.js s3://cdn.bio.sh/msa/latest/msa.js
s3cmd --acl-public -m "application/octet-stream" put dist/msa.js.map s3://cdn.bio.sh/msa/latest/msa.js.map
s3cmd --acl-public -m "application/javascript" --add-header='Content-Encoding: gzip' put dist/msa.min.gz.js s3://cdn.bio.sh/msa/latest/msa.min.gz.js
s3cmd --acl-public -m "application/octet-stream" put dist/msa.js.map s3://cdn.bio.sh/msa/latest/msa.min.js.map

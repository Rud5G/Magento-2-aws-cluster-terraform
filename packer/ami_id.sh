#!/bin/bash
AMI_ID=$(jq -r '.builds[-1].artifact_id' ./packer/manifest.json | cut -d ":" -f2)
echo -n "{\"AMI_ID\":\"${AMI_ID}\"}"

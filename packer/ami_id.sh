#!/bin/bash
AMI_ID=$(jq -r '.builds[-1].artifact_id' ./packer/manifest_for_${INSTANCE_NAME}.json | cut -d ":" -f2)
echo -n "{\"AMI_ID\":\"${AMI_ID}\"}"

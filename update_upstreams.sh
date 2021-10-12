#!/bin/bash

ADMIN_EMAIL=""
ASG_NAME=""

TIMESTAMP=$(date +%Y%m%d-%H%M%S)

NGINX_UPSTREAMS_CONFIG="/etc/nginx/upstreams.conf"
UPSTREAMS_LOGFILE="/var/log/nginx/upstreams.tmp.${TIMESTAMP}"
UPSTREAMS_MD5="/var/log/nginx/upstreams.md5"

UPSTREAMS=$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names "${ASG_NAME}" | jq -r ".AutoScalingGroups[].Instances[].InstanceId")

if [ -z "${UPSTREAMS}" ]
then
  echo "[!] EMPTY OR NO NEW INSTANCES"
  exit 1
fi

UPSTREAMS_NEW_MD5="($(echo ${UPSTREAMS} | md5sum))"
  if [ -e "${UPSTREAMS_MD5}" ] ; then
    UPSTREAMS_OLD_MD5="$(< ${UPSTREAMS_MD5} )"
     if [ "${UPSTREAMS_NEW_MD5}" == "${UPSTREAMS_OLD_MD5}" ] ; then
       echo "[!] NO CHANGES"
    exit 1
  fi
fi

for UPSTREAM_ID in "${UPSTREAMS}"
do
UPSTREAM_PRIVATE_IPV4="$(aws ec2 describe-instances --instance-ids ${UPSTREAM_ID} --query "Reservations[].Instances[].PrivateIpAddress")"
if [ -z "${UPSTREAM_PRIVATE_IPV4}" ]; then
  echo "[!] FAILED TO GET IP ADDRESS FOR ${UPSTREAM_ID}"
  exit 1
  fi
  aws ec2 wait instance-status-ok --instance-ids ${UPSTREAM_ID}
  UPSTREAMS_GROUP_PRIVATE_IPV4+="server ${UPSTREAM_PRIVATE_IPV4}:80 fail_timeout=5s;\n"
  echo "${UPSTREAM_ID} | ${UPSTREAM_PRIVATE_IPV4}" >> ${UPSTREAMS_LOGFILE}
done

cat > ${NGINX_UPSTREAMS_CONFIG}<<END
${UPSTREAMS_GROUP_PRIVATE_IPV4}
END

nginx -qt

NGINX_EXIT=$?
if [ ${NGINX_EXIT} -ne 0 ]; then
  echo "[!] ERROR IN NGINX CONFIG"
  ## send alert here for nginx error
  ## add re-check logic
  exit 1
fi

systemctl restart nginx
## systemctl status nginx

echo "${UPSTREAMS_NEW_MD5}" > "${UPSTREAMS_MD5}"

#cat ${UPSTREAMS_LOGFILE}
## send alert here for asg / varnish updated upstreams
echo

#!/bin/bash
GREEN_COL="\\033[32;1m"
RED_COL="\\033[1;31m"
NORMAL_COL="\\033[0;39m"
SOURCE_REGISTRY=$1
TARGET_REGISTRY=$2
# shell 变量赋值，当没有从命令行中传递值给SOURCE_REGISTRY和TARGET_REGISTRY变量时，便采用下述值进行覆盖。
: ${IMAGES_LIST_FILE:="images-list.txt"}
: ${TARGET_REGISTRY:="10.7.20.12:5000"}
: ${SOURCE_REGISTRY:="docker.io"}
BLOBS_PATH="docker/registry/v2/blobs/sha256"
REPO_PATH="docker/registry/v2/repositories"
set -eo pipefail
CURRENT_NUM=0
ALL_IMAGES="$(sed -n '/#/d;s/:/:/p' ${IMAGES_LIST_FILE} | sort -u)"
TOTAL_NUMS=$(echo "${ALL_IMAGES}" | wc -l)
# shopeo 拷贝函数，注意其传递的参数，此处值得学习记录。
skopeo_copy() {
if skopeo copy --insecure-policy --src-tls-verify=false --dest-tls-verify=false \
--override-arch amd64 --override-os linux -q docker://$1 docker://$2; then
 echo -e "$GREEN_COL Progress: ${CURRENT_NUM}/${TOTAL_NUMS} sync $1 to $2 successful $NORMAL_COL"
else
 echo -e "$RED_COL Progress: ${CURRENT_NUM}/${TOTAL_NUMS} sync $1 to $2 failed $NORMAL_COL"
 exit 2
fi
}
# 调用拷贝函数并记录当前执行序号。
for image in ${ALL_IMAGES}; do
let CURRENT_NUM=${CURRENT_NUM}+1
skopeo_copy ${SOURCE_REGISTRY}/${image} ${TARGET_REGISTRY}/${image}
done

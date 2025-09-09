#!/usr/bin/env bash

#====================================================
#	app部署脚本
#	Author:	cove
#====================================================

source ./scripts/sh.config

# while [[ $# -gt 0 ]]
# do
#     key="$1"

#     case $key in
#         --platform|-p)
#         platform="$2"
#         shift
#         shift
#         ;;
#     esac
# done

# if [ "$platform" = "android" ]; then
#     curl -F "file=@$android_apk_path" -F "token=$token" $server_url
# elif [ "$platform" = "ios" ]; then
#     curl -F "file=@/xxxxx/xxxxx/xxx/xxx.ipa" http://172.16.10.152:20802/app/upload
# else
#     echo "Invalid platform. Please use 'android' or 'ios'."
# fi

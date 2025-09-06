#!/bin/bash

server_url="http://172.16.10.152:20802/app/upload"
token="15e93092292790428387b04f40442415"

android_apk_path="./build/app/outputs/apk/release/app-release.apk"
ios_ipa_path="./build/ios/ipa/建管平台.ipa"

platform="android"
while [[ $# -gt 0 ]]
do
    key="$1"

    case $key in
        --platform|-p)
        platform="$2"
        shift
        shift
        ;;
    esac
done

if [ "$platform" = "android" ]; then
    curl -F "file=@$android_apk_path" -F "token=$token" $server_url
elif [ "$platform" = "ios" ]; then
    curl -F "file=@/xxxxx/xxxxx/xxx/xxx.ipa" http://172.16.10.152:20802/app/upload
else
    echo "Invalid platform. Please use 'android' or 'ios'."
fi

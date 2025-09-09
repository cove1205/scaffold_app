#!/usr/bin/env bash

#========================================
#	app构建脚本
#	Author:	cove
#========================================

source ./scripts/sh.config

APK="apk"
IPA="ipa"
DEBUG="debug"
RELEASE="release"
PROFILE="profile"

# 帮助信息
HELP_MESSAGE_PARAM_PLATFORM="参数 -p, 构建平台, options [$ANDROID,$IOS]"
HELP_MESSAGE_PARAM_BUILD_TYPE="参数 -t, 构建类型, options [$DEBUG,$RELEASE,$PROFILE]"
HELP_MESSAGE_PARAM_VERSION="参数 -v, 版本号, e.g: <x.y.z>"
HELP_MESSAGE_PARAM_BUILD_NUMBER="参数 -b, 构建版本, e.g: 123456789"
HELP_MESSAGE_PARAM_ANDROID_TARGET="参数 -a, Android目标平台, options [android-arm, android-arm64, android-x64] (仅当-p android时有效)"
HELP_MESSAGE_PARAM_IOS_EXPORT="参数 -e, iOS导出方法, options [app-store, ad-hoc, development] (仅当-p ios时有效)"

description() {
    cat <<EOF
Usage:
build.sh [-p platform] [-t build_type] [-v version] [-b build_number] [-a android_target] [-e ios_export_method] [-h] [--verbose]

comment:
$HELP_MESSAGE_PARAM_PLATFORM
$HELP_MESSAGE_PARAM_BUILD_TYPE
$HELP_MESSAGE_PARAM_VERSION
$HELP_MESSAGE_PARAM_BUILD_NUMBER
$HELP_MESSAGE_PARAM_ANDROID_TARGET
$HELP_MESSAGE_PARAM_IOS_EXPORT
EOF
    exit -1
}

while getopts 'p:t:v:b:a:e:hlc' OPT; do
    case $OPT in
    p) platform="$OPTARG" ;;
    t) build_type="$OPTARG" ;;
    v) version="$OPTARG" ;;
    b) build_number="$OPTARG" ;;
    a) android_target="$OPTARG" ;;  # Android target-platform参数
    e) ios_export_method="$OPTARG" ;; # iOS export-method参数
    h) description ;;
    ?) description ;;
    esac
done

# 校验构建环境
check_type() {

    echo ""
    print_start "校验构建环境"

    local default_build_type=$RELEASE

    case "$build_type" in
    "$RELEASE" | "$DEBUG" | "$PROFILE")
        print_ok "构建环境:[$build_type]"
        ;;
    "")
        print_warn "未设置构建环境,将使用默认值[$default_build_type]"
        build_type=$default_build_type
        ;;
    *)
        print_error "请输入正确的构建环境"
        echo $HELP_MESSAGE_PARAM_BUILD_TYPE
        exit 1
        ;;
    esac
}

# 校验平台类型
check_platform() {

    echo ""
    print_start "校验平台类型"

    default_platform=$ANDROID
    default_platform_option=$APK
    default_android_target="android-arm64"
    default_ios_export="app-store"
    platform_sub_option=""

    case "${platform:-}" in
    "$ANDROID")
        platform_option=$APK
        print_ok "平台:[$platform]"

        # 校验Android target-platform参数
        if [ -n "${android_target:-}" ]; then
            case "$android_target" in
            "android-arm"|"android-arm64"|"android-x64")
                print_ok "Android目标平台:[$android_target]"
                ;;
            *)
                print_error "无效的Android目标平台: $android_target"
                echo $HELP_MESSAGE_PARAM_ANDROID_TARGET
                exit 1
                ;;
            esac
        else
            print_warn "未设置Android目标平台,将使用默认值[$default_android_target]"
            android_target=$default_android_target
        fi
        platform_sub_option="--target-platform ${android_target}"
        ;;
    "$IOS")
        platform_option=$IPA
        print_ok "平台:[$platform]"
        # 校验iOS export-method参数
        if [ -n "${ios_export_method:-}" ]; then
            case "$ios_export_method" in
            "app-store"|"ad-hoc"|"development")
                print_ok "iOS导出方法:[$ios_export_method]"
                ;;
            *)
                print_error "无效的iOS导出方法: $ios_export_method"
                echo $HELP_MESSAGE_PARAM_IOS_EXPORT
                exit 1
                ;;
            esac
        else
            print_warn "未设置iOS导出方法,将使用默认值[$default_ios_export]"
            ios_export_method=$default_ios_export
        fi
        platform_sub_option="--export-method ${ios_export_method}"
        ;;
    "")
        print_warn "未设置platform,将使用默认值[$default_platform]"
        print_warn "忽略 -a 和 -e 参数,使用默认值[$default_android_target]"
        platform=$default_platform
        platform_option=$default_platform_option
        platform_sub_option="--target-platform ${default_android_target}"
        ;;
    *)
        print_error "请输入正确的platform"
        echo $HELP_MESSAGE_PARAM_PLATFORM
        exit 1
        ;;
    esac
}

# 校验版本参数
check_build_option() {

    local default_version="1.0.0"
    local default_build_number="1"
    build_name_option=""
    build_number_option=""

    echo ""
    print_start "校验版本参数"

    if [ -n "${version:-}" ]; then
        print_ok "版本号:[$version]"
    else
        print_warn "未设置版本号,将使用默认版本号[$default_version]"
        version=$default_version
    fi
    build_name_option="--build-name=${version}"

    if [ -n "${build_number:-}" ]; then
        print_ok "Build号:[$build_number]"
    else
        print_warn "未设置build号,将使用默认build号[$default_build_number]"
        build_number=$default_build_number
    fi
    build_number_option="--build-number=${build_number}"
}

# 信号处理
interrupted=false
# 清理函数
cleanup() {
    interrupted=true
    echo -e "\n${Red}[ERROR]${Font} 用户中断操作"
    exit 130
}

trap cleanup INT

# 执行构建
build() {

    echo ""
    print_start "开始构建"

    # 构建基础命令
    build_cmd="flutter clean && flutter build ${platform_option} --${build_type} --build-name=${version} --build-number=${build_number} ${platform_sub_option}"

    print_ok "执行构建命令:"
    echo "[$build_cmd]"
    echo ""

    # 执行构建命令
    eval $build_cmd

    build_exit_code=$?

    # 检查是否被中断
    if [ "$interrupted" = true ]; then
        print_error "构建取消"
        exit 130
    fi

    if [ $build_exit_code -eq 130 ] || [ $build_exit_code -eq 2 ]; then
        print_error "构建取消"
        exit 130
    elif [ $build_exit_code -ne 0 ]; then
        print_error "构建失败"
        exit $build_exit_code
    else
        print_ok "构建完成"
    fi
}

# 打印构建信息
print_build_info() {

    echo ""
    print_start "本次构建信息:"

    vars[0]="构建平台:$platform"
    vars[2]="主版本号:$version"
    vars[3]="构建版本:$build_number"
    # vars[4]="构建类型:$type"

    # 根据平台添加特定信息
    if [ "$platform" = "$ANDROID" ]; then
        vars[1]="目标架构:$android_target"
    elif [ "$platform" = "$IOS" ]; then
        vars[1]="导出方式:$ios_export_method"
    fi

    # 计算最长的变量名的长度
    max_length=0
    for var in ${vars[@]}; do
        length=$(get_string_length "$var")
        if ((length > max_length)); then
            max_length=$length
        fi
    done

    border_length=$((max_length + 2))
    plain_length=$((max_length + 4))

    # 输出边框
    top_border=$(printf "┌%${border_length}s┐" | tr ' ' '─')
    bottom_border=$(printf "└%${border_length}s┘" | tr ' ' '─')
    echo "$top_border"

    # 输出每个变量的值
    for var1 in ${vars[@]}; do
        echo $var1 | awk '{printf "│ %-'${plain_length}'s │\n",$1}'
    done

    # 输出边框
    echo "$bottom_border"

}

# 主函数
main() {
    # set -x
    check_type
    check_platform
    check_build_option
    build
    print_build_info
}

main "$@"

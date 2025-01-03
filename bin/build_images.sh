#!/bin/bash

image_name="aspnmy/coder-man"
CURRENT_DIR=$(
    cd "$(dirname "$0")" || exit
    pwd
)



# 引入函数库
source_utilityFunction() {
    UTILITY_FUNCTION_PATH="${CURRENT_DIR}/Core/utilityFunction.sh"

    # 检查函数库文件是否存在
    if [ -f "$UTILITY_FUNCTION_PATH" ]; then
        # 引入函数库
        source "$UTILITY_FUNCTION_PATH"
    else
        log "函数库文件不存在: $UTILITY_FUNCTION_PATH"
        exit 1
    fi
}

# 调用 source_utilityFunction 函数
source_utilityFunction

# 函数:构建基础底层 coder-alpine Docker 镜像(此镜像不含coder代码)
bud_docker_alpine_base() {

    ver=$(get_Config_alpine_baseVer)

    log "开始构建 $image_name:$ver 使用 Dockerfile-alpine-Base..."
    sudo docker build -f Dockerfile-alpine-Base -t "$image_name:$ver" .
    echo "构建完成。"
}


# 函数:构建国内版基础镜像-未包含离线组件
bud_docker_cnbase() {

    ver=$(get_Config_cnbaseVer)

    log "开始构建 $image_name:$ver 使用 Dockerfile-Cn-Base..."
    sudo docker build -f Dockerfile-Cn-Base -t "$image_name:$ver" .
    echo "构建完成。"
}



# 函数:构建coder官方离线版镜像-只包含基础业务
bud_docker_def() {

    ver=$(get_Config_defVer)
    log "开始构建 $image_name:$ver 使用 Dockerfile-Define..."
    sudo docker build -f Dockerfile-Define -t "$image_name:$ver" .
    echo "构建完成。"
}

# 函数:构建中国版 离线版完整镜像-包含常用的开发组件
bud_docker_cnoffline() {

    ver=$(get_Config_cnoffVer)
    log "开始构建 $image_name:$ver 使用 Dockerfile-Cn-Offline..."
    sudo docker build -f Dockerfile-Cn-Offline -t "$image_name:$ver" .
    echo "构建完成。"
}

# 函数:构建中国版 离线版完整镜像-包含常用的开发组件(mini版)
# 使用ADD的方式添加离线组件，以获得更小的镜像大小
bud_docker_cnofflineMini() {

    ver=$(get_Config_cnoffMiniVer)
    log "开始构建 $image_name:$ver 使用 Dockerfile-Cn-Offline-mini..."
    sudo docker build -f Dockerfile-Cn-Offline-mini -t "$image_name:$ver" .
    echo "构建完成。"
}

# 函数:构建中国版 离线版完整镜像-包含常用的开发组件(mini版)
# 使用国内私库拉取离线组件的方式构建镜像，方便部署
bud_docker_cnofflineSK() {
    # appkey 为私库的访问密钥
    #
    local appkey
    local url
    ver=$(get_Config_cnoffMiniSKVer)
    local cgf_dir
    wget "https://$url/Dockerfiles/coder/$ver/Dockerfile-Cn-Offline-mini-SK"
    echo "私库访问对接未完成,请等待开发中"
    exit 1
    log "开始构建 $image_name:$ver 使用 Dockerfile-Cn-Offline-mini-SK..."
    sudo docker build -f Dockerfile-Cn-Offline-mini-SK -t "$image_name:$ver" .
    echo "构建完成。"
}

# 主函数:显示菜单并根据用户选择执行相应函数
main() {
    echo "请选择 Docker 构建选项:"
    echo "0) 构建国际版-基础底层 coder-alpine Docker 镜像(此镜像不含coder代码)"
    echo "1) 构建中国版-基础镜像-未包含离线组件"
    echo "2) 构建coder-官方离线版镜像-只包含基础业务"
    echo "3) 构建中国版-离线版完整镜像-包含常用的开发组件"
    echo "4) 构建中国版 离线版完整镜像-包含常用的开发组件(mini版)构建前请确认离线组件已经下载本地"
    echo "5) 构建中国版 离线版完整镜像-包含常用的开发组件(私库版)构建前请确认私库拥有访问权限"
    read -p "输入您的选择(需要执行的业务数字):" choice

    case $choice in
        0)
            bud_docker_alpine_base
            ;;
        1)
            bud_docker_cnbase
            ;;
        2)
            bud_docker_def
            ;;
        3)
            bud_docker_cnoffline
            ;;
        4)
            bud_docker_cnofflineMini
            ;;
        5)
            bud_docker_cnofflineSK
            ;;
        *)
            echo "无效的选择。请重新运行脚本并选择一个有效选项。"
            exit 1
            ;;
    esac
}

# 调用主函数
main "$@"

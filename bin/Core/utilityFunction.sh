#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

CURRENT_DIR=$(
    cd "$(dirname "$0")" || exit
    pwd
)

LogsPATH="${CURRENT_DIR}/logs"


ck_files() {
    # 判断 LogsPATH 目录是否存在，不存在则创建
    if [ ! -d "${LogsPATH}" ]; then
        log "创建日志目录：${LogsPATH}"
        mkdir -p "${LogsPATH}"
    fi

    # 判断文件是否存在，不存在则创建
    formatted_date=$(date +"%Y%m%d")
    LogFile="${LogsPATH}/Coder-man-$formatted_date.log"
    if [ ! -f "${LogFile}" ]; then
        log "创建日志文件：${LogFile}"
        touch "${LogFile}"
        set_Chmod_644 "${LogFile}"
    fi
}

get_Script_dir_Config() {
    local config_path="./Config_env.json"

    # 检查配置文件是否存在
    if [ -f "$config_path" ]; then
        log "配置文件存在：$config_path"
    else
        log "配置文件不存在：$config_path，使用默认路径：$config_path"
        
    fi

    echo "$config_path"
}

log() {
    local rr_debug
    local logs_time
    rr_debug=$(get_Config_debug)
    logs_time=$(get_Time)
    local message="[Aspnmy Log][$logs_time][$0]: $1"

    if [ "$rr_debug" -eq 0 ]; then
        # 如果 logs_debug 等于 0，log()函数只输出messages到终端，不写日志文件
        case "$1" in
            *"失败"*|*"错误"*|*"请使用 root 或 sudo 权限运行此脚本"*)
                echo -e "${RED}${message}${NC}"
                ;;
            *"成功"*)
                echo -e "${GREEN}${message}${NC}"
                ;;
            *"忽略"*|*"跳过"*)
                echo -e "${YELLOW}${message}${NC}"
                ;;
            *)
                echo -e "${BLUE}${message}${NC}"
                ;;
        esac
    elif [ "$rr_debug" -eq 1 ]; then
        ck_files
        # 如果 logs_debug 等于 1，log()函数只输出日志文件不输出message
        formatted_date=$(date +"%Y%m%d")
        LogFile="${LogsPATH}/Coder-man-$formatted_date.log"
        echo "$message" >> "${LogFile}"
    fi
}

set_Chmod_644() {
    chmod 644 "$1"
}

set_Chmod_755() {
    chmod 755 "$1"
}

# 安装必须组件
ck_install_jq() {
# 检查 jq 是否安装
if ! command -v jq >/dev/null 2>&1; then
    echo "jq 未安装，正在安装..."

    # 检测操作系统类型并安装 jq
    case "$(uname -s)" in
        Linux*) 
            # 对于使用 apt 的 Debian/Ubuntu 系统
            if command -v apt-get >/dev/null 2>&1; then
                echo "检测到基于 apt 的系统，正在使用 apt-get 安装 jq..."
                sudo apt-get update && sudo apt-get install -y jq
            # 对于使用 yum 的 CentOS/RHEL 系统
            elif command -v yum >/dev/null 2>&1; then
                echo "检测到基于 yum 的系统，正在使用 yum 安装 jq..."
                sudo yum install -y jq
            # 对于使用 dnf 的 Fedora 系统
            elif command -v dnf >/dev/null 2>&1; then
                echo "检测到基于 dnf 的系统，正在使用 dnf 安装 jq..."
                sudo dnf install -y jq
            # 对于使用 zypper 的 openSUSE 系统
            elif command -v zypper >/dev/null 2>&1; then
                echo "检测到基于 zypper 的系统，正在使用 zypper 安装 jq..."
                sudo zypper install -y jq
            else
                echo "未检测到支持的包管理器，安装 jq 失败。" >&2
                exit 1
            fi
            ;;
        Darwin*)
            # 对于 macOS 使用 brew
            if command -v brew >/dev/null 2>&1; then
                echo "检测到 macOS 系统，正在使用 brew 安装 jq..."
                brew install jq
            else
                echo "未检测到 Homebrew，安装 jq 失败。" >&2
                exit 1
            fi
            ;;
        FreeBSD*)
            # 对于 FreeBSD 使用 pkg
            if command -v pkg >/dev/null 2>&1; then
                echo "检测到 FreeBSD 系统，正在使用 pkg 安装 jq..."
                sudo pkg install -y jq
            else
                echo "未检测到 pkg 包管理器，安装 jq 失败。" >&2
                exit 1
            fi
            ;;
        *)
            echo "不支持的操作系统，安装 jq 失败。" >&2
            exit 1
            ;;
    esac

    # 检查安装是否成功
    if ! command -v jq >/dev/null 2>&1; then
        echo "jq 安装失败，请手动安装 jq。" >&2
        exit 1
    else
        echo "jq 安装成功。"
    fi
else
    echo "jq 已安装。"
fi

}

get_Config_debug() {
    # 检查JSON文件是否存在
    local config_dir
    config_dir=$(get_Script_dir_Config)

    if [ ! -f "$config_dir" ]; then
        log "JSON file not found!"
        exit 1
    fi
    # 使用jq解析JSON文件中的logs_debug字段
    res=$(jq -r '.["logs_debug"]' "$config_dir")
    echo "$res"
}

# coder的alpine基础镜像版本-未打包coder代码本身
# 需要构建更小的coder镜像需要，一般直接以coder官方镜像为基础进行打包
get_Config_alpine_baseVer() {
    local config_dir
    config_dir=$(get_Script_dir_Config)

    if [ ! -f "$config_dir" ]; then
        log "JSON file not found!"
        exit 1
    fi
    # 使用jq解析JSON文件中的alpinebaseVer字段
    res=$(jq -r '.["alpine_baseVer"]' "$config_dir")
    echo "$res"
}



# 国内版基础镜像-未包含离线组件
get_Config_cnbaseVer() {
    local config_dir
    config_dir=$(get_Script_dir_Config)

    if [ ! -f "$config_dir" ]; then
        log "JSON file not found!"
        exit 1
    fi
    # 使用jq解析JSON文件中的cn_baseVer字段
    res=$(jq -r '.["cn_baseVer"]' "$config_dir")
    echo "$res"
}

# coder官方离线版镜像-只包含基础业务
get_Config_defVer() {
    local config_dir
    config_dir=$(get_Script_dir_Config)

    if [ ! -f "$config_dir" ]; then
        log "JSON file not found!"
        exit 1
    fi
    # 使用jq解析JSON文件中的defVer字段
    res=$(jq -r '.["defVer"]' "$config_dir")
    echo "$res"
}

# 国内离线版完整镜像-包含常用的开发组件
get_Config_cnoffVer() {
    local config_dir
    config_dir=$(get_Script_dir_Config)

    if [ ! -f "$config_dir" ]; then
        log "JSON file not found!"
        exit 1
    fi
    # 使用jq解析JSON文件中的cnoffVer字段
    res=$(jq -r '.["cnoffVer"]' "$config_dir")
    echo "$res"
}

# 国内离线版完整镜像(mini版)-包含常用的开发组件
get_Config_cnoffMiniVer() {
    local config_dir
    config_dir=$(get_Script_dir_Config)

    if [ ! -f "$config_dir" ]; then
        log "JSON file not found!"
        exit 1
    fi
    # 使用jq解析JSON文件中的cnoffVer字段
    res=$(jq -r '.["cnoffMiniVer"]' "$config_dir")
    echo "$res"
}

# 组件以私库提供下载的形式构建，私库可以是国内镜像站等能使用wget或者curl形式下载的位置
get_Config_cnoffMiniSKVer() {
    local config_dir
    config_dir=$(get_Script_dir_Config)

    if [ ! -f "$config_dir" ]; then
        log "JSON file not found!"
        exit 1
    fi
    # 使用jq解析JSON文件中的cnoffVer字段
    res=$(jq -r '.["cnoffMiniSKVer"]' "$config_dir")
    echo "$res"
}

# coder反代常用的caddy基础镜像
# 方便先构建成caddy-base镜像再和coder镜像进行整合(多阶段构建)减小镜像体积
get_Config_caddyBaseVer() {
    local config_dir
    config_dir=$(get_Script_dir_Config)

    if [ ! -f "$config_dir" ]; then
        log "JSON file not found!"
        exit 1
    fi
    # 使用jq解析JSON文件中的caddyBassVer字段
    res=$(jq -r '.["caddyBassVer"]' "$config_dir")
    echo "$res"
}


get_Time() {
    formatted_date=$(date +"%Y-%m-%d %H:%M:%S")
    echo "$formatted_date"
}

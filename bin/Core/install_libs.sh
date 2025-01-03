#!/bin/bash

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

# coder-man-特别说明

- 感谢原作者的分享，根据原作者的分享代码重新修改的业务分支coder-man，更改了易用性的设置
- 原作者开源的版本：<https://github.com/dev-easily/coder-templates.git>
- 主要修改的地方如下：
- 1、官方离线版的基础镜像，定期上传到aspnmy/coder-man:base-${version},目前最新的是v2.18.0 ，最稳定的是v2.17.3 , 官方离线版基础镜像没有打包plugins和templates
- 2、打包plugins和templates到部署镜像，定期上传到aspnmy/coder-man:${version}-cn ，如有要下载v2.18.0，就是 docker pull aspnmy/coder-man:v2.18.0-cn，如果后缀是en的代表镜像源为官方
- 3、部署镜像未包含内置数据库，推荐数据库容器单独启用。
- 4、易用性的改变主要是方便国内镜像注册表或者docker官方注册表，拉取即用无需关注是否需要外部拉取资源的这个问题（所以镜像体积比较大-但是方便给人部署），原作者的设计是把打包plugins拉取到宿主机共享文件./plugins中 以-v 参数提供给coder容器使用，这样的形式更适合自建业务开发。而我们合并打包plugins的原因是，因为有时候经常要替客户部署，一键拉取更简单，哪怕提供给客户拉取，也是包含plugins的更方便使用。
- 当然更方便的方案就是plugins也提供国内镜像源，但是维护量较大。后续会提供一个plugins的国内下载镜像源，这样部署coder容器体积更小，拉取更快。

## 使用说明

### 快速构建

- 拉取本仓库到本地,按照下面运行命令

```bash
cd ./bin
bash build_images.sh

```

- 根据命令提示构建自己需要的离线镜像

### 快速使用

- 安照下面部署方式，拉取现成的库进行使用

```bash
services:
  coder-man-cn:
    container_name: coder-man-cn-${ver-"v2.18.0-cn"}
    image: aspnmy/coder-man:${ver-"v2.18.0-cn"}
    ports:
      - "7080:7080"
    environment:
      CODER_TELEMETRY_ENABLE: "true" # Disable telemetry
      CODER_BLOCK_DIRECT: "true" # force SSH traffic through control plane's DERP proxy
      CODER_DERP_SERVER_STUN_ADDRESSES: "disable" # Only use relayed connections
      CODER_UPDATE_CHECK: "false" # Disable automatic update checks
      ## ----
      CODER_PG_CONNECTION_URL: "postgresql://${username:-latest}:${userpasswd:-latest}@${host:-127.0.0.1}:${port:-5432}/coder?sslmode=disable"
      CODER_HTTP_ADDRESS: "0.0.0.0:7080"
      # You'll need to set CODER_ACCESS_URL to an IP or domain
      # that workspaces can reach. This cannot be localhost
      # or 127.0.0.1 for non-Docker templates!
      # 此处输入可以外网访问的域名或者局域网域名 要带有协议头 推荐使用http协议
      # 如需https协议可以用web_server进行反代
      CODER_ACCESS_URL: "${CODER_ACCESS_URL-http://192.168.0.1:7080}"
    # If the coder user does not have write permissions on
    # the docker socket, you can uncomment the following
    # lines and set the group ID to one that has write
    # permissions on the docker socket.
    group_add:
      - "998" # docker group on host
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - coder-man-cn:/home/coder/.terraform.d/plugins/registry.terraform.io

volumes:
    coder-man-cn:


```

## docker 镜像 tag 说明

### aspnmy/coder-man:base-${version}

- 带有base字样的是基础镜像，不含离线组件
- 如果base后面带有cn指的是镜像源为国内的镜像，不含cn或带有en的是指国际版镜像

### aspnmy/coder-man:${version}-cn

- 不含base的镜像，是指完全离线镜像。
- 后面带有cn代表镜像源为国内
- 后面带有en代表镜像源使用国外
- 后面带有mini代表使用更小的基础镜像构建的离线镜像
- 后面带有mini-SK代表使用私库部署的方式构建的离线镜像
- 后面带有nginx或者caddy的代表已经包含反代用的web_server(推荐这个版本)

## 参数配置说明

### 文件位置

- 参数文件位于./bin/Core/Config_env.json 文件结构如下:

```json
{
    "logs_debug": "0",
    "alpine_baseVer":"alpine-3.21.0",
    "cn_baseVer": "base-v2.18.1",
    "defVer":"v2.18.1-en",
    "cnoffVer":"v2.18.1-cn",
    "cnoffMiniVer":"v2.18.1-cn-mini",
    "cnoffMiniSKVer":"v2.18.1-cn-mini-sk"
}
```

- 参数的值代表你要构建的镜像版本号 需要和构建文件中的from语句中的官方version保持一致

## 常见问题

- 运行本程序需要jq组件，构建工具自动会安装jq组件，如果没有安装成功，请先自行安装

## 后续开发业务

### 更多的离线镜像

- 后续会增加一些其他镜像的构建工具

### Web管理构建

- 主要会做一个web_UI,使用nextjs套件来调取sh脚本来实现web业务中的构建，方便操作一点

## 群组与沟通

[https://t.me/+eq8FgfNVNIY3NWNk](https://t.me/+eq8FgfNVNIY3NWNk)
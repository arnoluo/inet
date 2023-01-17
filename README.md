# inet
**inet(internal network)**, 基于 `docker compose`, `traefik` 构建的单节点单域名多服务docker环境，用于本地开发及单服务器环境部署。

## 前置安装
### 安装 [docker](https://docker.com)
### 安装 `dnsmasq` (osx可选)
本地开发使用，线上可使用服务商提供的dns解析服务。此服务将开启本地dns(用作子域名解析)，使用子路径或需自行配置子域名时 可不装。

> 开启/关闭/重启dnsmasq: `brew services start/stop/restart dnsmasq`

> 若修改了项目内 `conf/dnsmasq/inet.conf`，需重新执行下面第三步

#### 初始化
1. `brew install dnsmasq`

2. 开启配置文件夹
    - `vim /usr/local/etc/dnsmasq.conf`
    - 配置文件中找到并取消注释此行 `conf-dir=/usr/local/etc/dnsmasq.d/,*.conf`

3. 覆盖配置文件夹
    - 当前文件夹下执行 `make dns` (需已安装make，若无可直接执行该内部命令)
    - 执行 `dig inet @127.0.0.1` (inet替换为conf内实际自定义域名), 返回应该类似这样
    ```
    ;; ANSWER SECTION:
    inet.                 0       IN      A       127.0.0.1
    ```

4. 配置osx系统使用 dnsmasq
    - 所有请求都由dnsmasq解析: 修改系统设置中的dns配置即可
    - 或指定域名由dnsmasq解析: `sudo mkdir -p /etc/resolver && echo 'nameserver 127.0.0.1' | sudo tee /etc/resolver/inet` (/etc/resolver/inet inet替换为conf内实际自定义域名)

#### 更换域名解析
> 如： 更换 inet 为 yournewhost
1. `vim conf/dnsmasq/inet.conf`, 修改为 `address=/yournewhost/127.0.0.1`
2. 更新配置文件并重启dnsmasq: `make dns`
3. 按照实际需求，更新并执行[初始化 第四步](#初始化)， 如: `sudo mkdir -p /etc/resolver && echo 'nameserver 127.0.0.1' | sudo tee /etc/resolver/yournewhost`

#### 卸载
```bash
brew uninstall dnsmasq
# 执行后应有提示：需手动移除配置项
rm -rvf /usr/local/etc/dnsmasq.d && rm -fv /usr/local/etc/dnsmasq.conf
sudo rm -fv /etc/resolver/inet
```

## 常用命令 (using make)
### build
`make build` (init && autocreating demo code)

### stop
- `make down`
- `make clean` (down && clean log)

### start/restart
- `make up` (down && up）
- `make upd` (down && up in dameon)

### refresh dns(for dnsmasq)
- `make dns` (run it after modifing `conf/dnsmasq/inet.conf`)

### 生成 nginx 配置
- `make ngcfg port={container port} name={server name} path={relative path base on HOST_SRC_DIR}`


## 初始化并测试
> 初始化将使用默认 `/src/html` 项目并绑定到 inet 主域名，用做测试，可更新相关配置指向新项目

1. `make build`
2. `make upd`
3. `curl http://inet`

## 部署项目
主机端选定一个需部署的根目录，如 `/path/to/projects`, 其中有多个项目 `/path/to/projects/demo1`, `/path/to/projects/demo2`。
以 `demo1` 为例，将 `demo1` 部署到npa容器(npa仅支持解析静态/php文件)内，分配容器内nginx监听端口 `88`，主机端以 `example.inet` 域名形式访问

### 1 配置挂载目录
`vim .env`
```conf
HOST_SRC_DIR=/path/to/projects
# many conf here ...
TRAEFIK_SUBDOMAIN_DEMO1_NAME=example
TRAEFIK_SUBDOMAIN_DEMO1_PORT=88
```

### 2 自动生成 nginx conf
> 这里 `name` 用于映射到容器具体目录，必需与项目同名。

`make ngcfg port=88 name=demo1 path=demo1`

### 3 添加traefik路由解析到 npa service
`make down`
`vim docker-compose.yml`
```yml
  npa:
    image: arnoluo/nginx-php:alpine3.16
    labels:
      ##### many labels here ...
      - traefik.http.routers.${TRAEFIK_SUBDOMAIN_DEMO1_NAME}.rule=Host(`${TRAEFIK_SUBDOMAIN_DEMO1_NAME}.${TRAEFIK_HOST_NAME}`)
      - traefik.http.routers.${TRAEFIK_SUBDOMAIN_DEMO1_NAME}.entrypoints=web
      - traefik.http.routers.${TRAEFIK_SUBDOMAIN_DEMO1_NAME}.service=${TRAEFIK_SUBDOMAIN_DEMO1_NAME}-svc
      - traefik.http.services.${TRAEFIK_SUBDOMAIN_DEMO1_NAME}-svc.loadbalancer.server.port=${TRAEFIK_SUBDOMAIN_DEMO1_PORT}
```

### 4 重启服务并访问
`make upd`
`curl http://example.inet`


## 测试数据库连接
使用 `src/test` 进行简单连接测试
1. `make down && make ngcfg port=81 name=test path=test`
2. 以下文件中代码去掉注释
`.env`
```conf
TRAEFIK_SUBDOMAIN_TEST_NAME=test
TRAEFIK_SUBDOMAIN_TEST_PORT=81
```

`docker-compose.yml`
```yml
- traefik.http.routers.${TRAEFIK_SUBDOMAIN_TEST_NAME}.rule=Host(`${TRAEFIK_SUBDOMAIN_TEST_NAME}.${TRAEFIK_HOST_NAME}`)
- traefik.http.routers.${TRAEFIK_SUBDOMAIN_TEST_NAME}.entrypoints=web
- traefik.http.routers.${TRAEFIK_SUBDOMAIN_TEST_NAME}.service=${TRAEFIK_SUBDOMAIN_TEST_NAME}-svc
- traefik.http.services.${TRAEFIK_SUBDOMAIN_TEST_NAME}-svc.loadbalancer.server.port=${TRAEFIK_SUBDOMAIN_TEST_PORT}
```
3. 重启测试连接
`make upd`
`curl test.inet`


## 参考
[vegasbrianc/docker-traefik-prometheus](https://github.com/vegasbrianc/docker-traefik-prometheus)
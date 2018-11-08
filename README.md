# ddns.sh
shell实现的DDNS

## 特性

- 纯shell实现
- 可随意添加自定义模块

## 功能

- 基础DDNS
- 通知功能

## 目前支持的IP获取方式
- ip.sb
- ifconfig.co
- ip-api.com

## 目前支持的DNS

- Cloudflare
- DNSPOD

## 目前支持的通知方式

- [@notificationme_bot](https://t.me/notificationme_bot)
- TelegramBot

## 使用方式

### 依赖

- bash
- curl
- sed+grep

### 配置

各配置文件均在各目录下

按照变量名及提示修改即可

例如 dns/cf/config notify/tgbot/config

### 运行

#### 直接运行(推荐)

运行

```bash
/path/ddns.sh
```

可使用systemd等开机启动

#### 单次运行(不推荐)

```cpp
/path/ddns.sh -d
```

### TODO
- 增加更多的DNS API
- 支持IPV6
- 完善错误处理
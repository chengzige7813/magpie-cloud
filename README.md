# magpie-cloud

在京东云 JoyCode DevCloud 上跑 magpie 转发服务，把 radeon cloud 等上游提供给本机 DSH 使用。

## 这个仓库是什么

一个**最小可启动**的项目：平台要求的 `package.json` + 一个替换掉的 `serve` 脚本。

真正的逻辑在 `bin/start.sh`：它下载 magpie 二进制、写入 provider 配置、前台运行在 `8080`。

## 为什么需要这样一个仓库

京东云 DevCloud 有两条产品线：

| | Git 仓库式 | 远程项目式 |
|---|---|---|
| 代码来源 | Git 地址 + 分支 | 开发机文件系统快照 |
| 是否执行 Dockerfile | 由仓库内容决定 | **不执行** |
| 本机能否操作 | 能（推代码即可） | 需 IDE 客户端，而它依赖京东内网 |

本机不属于京东内网（`joycode-api-saas.jd.com` 解析到 `172.28.x.x` 内网段，返回 502），
所以远程项目那条线的「IDE 打开」不可用。**Git 仓库式是本机唯一能全自动驱动的通道。**

## 平台硬规则（违反任意一条都会"构建成功但打不开"）

1. 只暴露容器端口 **8080**
2. 必须绑定 **0.0.0.0**，不是 127.0.0.1
3. 单个应用只能有一个对外端口
4. 没有 Job / CronJob —— 进程必须常驻
5. 本地存储 10GB，随 Pod 生命周期消失（所以配置在启动时生成）

## 启动链路

```
package.json 的 scripts.serve  →  bin/start.sh  →  magpie serve
                                                    ↓
                                          0.0.0.0:8080
```

## 加一个上游服务商

改 `bin/start.sh` 里的 `providers.json` 段落，加一条 provider 即可，推代码后重新部署。

字段含义：

| 字段 | 说明 |
|---|---|
| `id` | 内部标识，小写连字符 |
| `name` | 显示名 |
| `key` | 上游 API Key |
| `chat` | 上游 OpenAI 兼容地址（到 `/v1` 为止） |
| `baseAPI` | 固定 `chat` |
| `models` | 该服务商提供的模型名列表 |

## 验证

```bash
curl https://<应用域名>/v1/models
```

返回 JSON 里能看到 `radeon-cloud/GLM-5.3-Flash` 就说明通了。

# magpie-cloud

京东云 DevCloud 上的 magpie 转发服务。把 radeon cloud 等上游暴露为 OpenAI 兼容接口。

## 这里有什么

| 文件 | 作用 |
|---|---|
| `bin/start.sh` | **唯一事实来源**。下载 magpie、写 provider 配置、注册网关密钥、前台运行 |
| `DEPLOY.md` | 「应用变更」页要填的两个字段 |
| `package.json` / `server.js` | 平台模板要求的占位文件，实际不参与启动 |

启动方式不走 `npm`。平台直接把 `bin/start.sh` 拉到容器里执行，`server.js` 不参与。

## 部署

见 [`DEPLOY.md`](DEPLOY.md)。改完 `bin/start.sh` 要同步到 gist，然后**暂停 → 启动**容器。

容器不会因为参数变更自动重建。

## 加一个上游服务商

改 `bin/start.sh` 里 `providers.json` 的 `providers` 数组：

```json
{
  "id": "your-provider",
  "name": "显示名",
  "icon": "generic",
  "key": "上游 API Key",
  "chat": "https://上游地址/v1",
  "baseAPI": "chat",
  "models": ["模型名1", "模型名2"]
}
```

| 字段 | 说明 |
|---|---|
| `id` | 内部标识，小写连字符，会出现在模型名前缀 |
| `key` | 上游 API Key |
| `chat` | 上游 OpenAI 兼容地址，到 `/v1` 为止 |
| `baseAPI` | 固定 `chat` |
| `models` | 该服务商提供的模型名列表 |

## 网关密钥

`bin/start.sh` 里的 `GATEWAY_KEY` 就是访问密钥，脚本启动时用 `magpie gateway-key add` 注册。

`MAGPIE_API_KEY` 环境变量**注册不了**密钥——那是客户端发密钥用的变量名。

## 验证

```bash
curl -s https://<应用域名>/v1/models -H "Authorization: Bearer <GATEWAY_KEY>"
```

返回里能看到 `你的provider/模型名` 就说明通了。

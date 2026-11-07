#!/bin/bash
# ============================================================
# magpie 云端启动脚本 · 京东云 JoyCode DevCloud
#
# 由「应用变更」调用：
#   启动命令 = bash
#   启动参数 = -c curl${IFS}-sL${IFS}-o${IFS}/tmp/b.sh${IFS}<本文件URL>;bash${IFS}/tmp/b.sh
#
# 平台约定（实测）：
#   - 启动命令 = 可执行文件；启动参数 = 它的 argv，空格分割，≤ 200 字符
#   - 用 ${IFS} 代替空格，可把整段脚本压成单个 token
#   - 只有 8080 对外，必须绑 0.0.0.0
#   - /tmp 每次容器重启清零 → 每次重新下载（约 72MB）
#   - 从容器外访问必须带「网关密钥」，用 `magpie gateway-key add` 注册，
#     环境变量 MAGPIE_API_KEY 只是客户端用的，不注册任何东西
# ============================================================

set -e

MAGPIE_VER=v0.1.3233
MIRROR=https://gh-proxy.com/
ASSET="${MIRROR}https://github.com/yetone/magpie/releases/download/${MAGPIE_VER}/magpie-cli-linux-amd64"

# 网关密钥：8080 是公网，任何外部调用都要带它
GATEWAY_KEY="2qajr8976d4oksglbxmpn05civwtzhe1"

export XDG_CONFIG_HOME=/tmp/magpie-data
CONF_DIR="${XDG_CONFIG_HOME}/magpie"
mkdir -p "${CONF_DIR}"

cat > "${CONF_DIR}/providers.json" <<'PROVIDERS_EOF'
{
  "version": 1,
  "providers": [
    {
      "id": "radeon-cloud",
      "name": "radeon cloud",
      "icon": "generic",
      "key": "rc-3a86595718c41fb6dc2558627e4048e2cb9b5e085e7a8e57",
      "chat": "https://developer.amd.com.cn/radeon/api/v1",
      "baseAPI": "chat",
      "models": ["GLM-5.3-Flash", "DeepSeek-V4.1-Flash"]
    }
  ],
  "deleted": []
}
PROVIDERS_EOF

printf '{}' > "${CONF_DIR}/plugin-auth.json"

echo "[magpie] version=${MAGPIE_VER}"
if [ ! -x /tmp/magpie ]; then
  echo "[magpie] downloading 72MB via gh-proxy"
  curl -fsSL --retry 3 --retry-delay 2 -o /tmp/magpie "${ASSET}"
  chmod +x /tmp/magpie
fi

# ---- 注册网关密钥（必须在 serve 之前跑一次）----
export MAGPIE_ADDR=127.0.0.1:8080
echo "[magpie] registering gateway key"
/tmp/magpie gateway-key add "cloud-client" --key "${GATEWAY_KEY}" || \
  echo "[magpie] WARN: gateway-key add failed (continuing)"

echo "[magpie] egress ip = $(curl -s --max-time 8 https://ipinfo.io/ip 2>/dev/null || echo unknown)"
echo "[magpie] serving on 0.0.0.0:8080"

exec env MAGPIE_ADDR=0.0.0.0:8080 MAGPIE_MIRRORS=on /tmp/magpie serve

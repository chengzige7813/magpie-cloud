#!/bin/bash
# ============================================================
# magpie 云端启动脚本 · 京东云 JoyCode DevCloud（快照镜像线）
#
# 作用：在应用容器启动时，把 magpie 拉下来、写入 provider 配置、
#       然后前台运行在 0.0.0.0:8080。
#
# 平台约束（实测得出，改这个文件前先读）：
#   1. 只有 8080 端口对外，且必须绑 0.0.0.0
#   2. /tmp 每次容器重启清零 → 二进制每次重新下载（约 72MB）
#   3. 这里是 start.sh，被平台按 `/bin/bash -c -l` 调用，
#      所以可以自由用引号、分号、heredoc —— 限制只在"启动命令"字段
# ============================================================

set -e

MAGPIE_VER=v0.1.3233
MIRROR=https://gh-proxy.com/
ASSET="${MIRROR}https://github.com/yetone/magpie/releases/download/${MAGPIE_VER}/magpie-cli-linux-amd64"

# magpie 的配置目录由 XDG_CONFIG_HOME 决定，固定到 /tmp 下
export XDG_CONFIG_HOME=/tmp/magpie-data
CONF_DIR="${XDG_CONFIG_HOME}/magpie"
mkdir -p "${CONF_DIR}"

# ---------------- provider 配置 ----------------
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

# 空登录态：云端不挂 WorkBuddy 账号，只做转发
printf '{}' > "${CONF_DIR}/plugin-auth.json"

# ---------------- 下载二进制 ----------------
echo "[magpie] version=${MAGPIE_VER}"
if [ ! -x /tmp/magpie ]; then
  echo "[magpie] downloading (72MB, via gh-proxy)"
  curl -fsSL --retry 3 --retry-delay 2 -o /tmp/magpie "${ASSET}"
  chmod +x /tmp/magpie
fi

echo "[magpie] egress ip = $(curl -s --max-time 8 https://ipinfo.io/ip 2>/dev/null || echo unknown)"

# ---------------- 前台运行 ----------------
echo "[magpie] serving on 0.0.0.0:8080"
exec env MAGPIE_ADDR=0.0.0.0:8080 MAGPIE_MIRRORS=on /tmp/magpie serve

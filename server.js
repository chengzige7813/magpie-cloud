// 平台模板要求的占位入口。实际启动不走这里。
//
// 真实启动链路见 DEPLOY.md：平台直接执行 bin/start.sh，
// 这个文件只保证仓库结构符合模板预期，不参与运行。
//
// 如果发现容器在跑这个文件，说明「启动命令」被改回了默认值。

console.log('[placeholder] 这个文件不该被启动。请检查应用变更页的启动命令是否为 bash');

const http = require('node:http');

http
  .createServer((req, res) => {
    res.writeHead(503, { 'content-type': 'text/plain; charset=utf-8' });
    res.end('placeholder: 启动命令配置错误，见 DEPLOY.md');
  })
  .listen(8080, '0.0.0.0', () => {
    console.log('[placeholder] listening on 0.0.0.0:8080');
  });

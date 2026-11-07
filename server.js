// 京东云 DevCloud 入口文件
//
// 平台会按 package.json 的 scripts.start / serve 推断启动方式。
// 这个文件只做一件事：把控制权交给 bin/start.sh，由它启动 magpie。
//
// 为什么不在这个文件里直接写 magpie 逻辑？
//   因为这里的 JS 只是"占位入口"，真正的服务是 magpie 这个二进制。
//   用 exec 让 magpie 接管进程，容器的 PID 1 就变成 magpie，
//   日志和信号都能正常传递，不会出现"父进程活着但服务没起来"的假象。

const { spawn } = require('node:child_process');
const path = require('node:path');

const script = path.join(__dirname, 'bin', 'start.sh');

console.log('[entry] 转交给 bin/start.sh 启动 magpie');
console.log('[entry] script=' + script);

const child = spawn('/bin/bash', [script], {
  stdio: 'inherit',
  env: process.env,
});

child.on('exit', (code, signal) => {
  console.log(`[entry] magpie 退出 code=${code} signal=${signal}`);
  process.exit(code === null ? 1 : code);
});

child.on('error', (err) => {
  console.error('[entry] 启动失败:', err.message);
  process.exit(1);
});

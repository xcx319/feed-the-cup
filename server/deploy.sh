#!/bin/bash
# deploy.sh - 部署 Feed The Cups 联机服务器
# 使用方式: bash deploy.sh
# 前提: ssh cup 可以连接到服务器

set -e

REMOTE="cup"
REMOTE_DIR="/opt/feed-the-cups-server"

echo "==> 上传服务器文件..."
ssh $REMOTE "mkdir -p $REMOTE_DIR"
scp server/package.json server/server.js $REMOTE:$REMOTE_DIR/

echo "==> 安装依赖..."
ssh $REMOTE "cd $REMOTE_DIR && npm install --production"

echo "==> 启动/重启服务..."
# 使用 pm2 管理进程（如果没有 pm2，先安装）
ssh $REMOTE "which pm2 || npm install -g pm2"
ssh $REMOTE "cd $REMOTE_DIR && pm2 delete feed-the-cups 2>/dev/null || true && pm2 start server.js --name feed-the-cups && pm2 save"

echo "==> 查看状态..."
ssh $REMOTE "pm2 status feed-the-cups"

echo ""
echo "✓ 部署完成！"
echo "  服务器地址: ws://$(ssh $REMOTE 'curl -s ifconfig.me'):8080"
echo ""
echo "  在 OnlineNetwork.gd 中更新 SERVER_URL 为上面的地址"

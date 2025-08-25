#!/bin/bash

echo "📊 视频聊天应用日志监控"
echo "======================"

# 监控后端服务日志
echo "🔍 启动后端服务并监控日志..."
cd /root/reactApp/backend

# 启动后端服务（如果未运行）
if ! pgrep -f "node src/app.js" > /dev/null; then
    echo "🚀 启动后端服务..."
    npm start > ../debug-tools/backend.log 2>&1 &
    BACKEND_PID=$!
    echo "后端进程ID: $BACKEND_PID"
    echo $BACKEND_PID > ../debug-tools/backend.pid
    sleep 2
fi

echo "📱 后端服务状态检查："
curl -s http://localhost:3000/health | jq '.' || curl -s http://localhost:3000/health
echo ""

echo "📈 实时日志监控（按Ctrl+C退出）:"
tail -f ../debug-tools/backend.log 2>/dev/null || echo "日志文件尚未生成，请稍后重试"

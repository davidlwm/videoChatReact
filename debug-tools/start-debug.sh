#!/bin/bash

echo "🚀 启动调试环境"
echo "=============="

# 启动后端服务
echo "1. 启动后端服务..."
cd /root/reactApp/backend
npm start > ../debug-tools/backend.log 2>&1 &
BACKEND_PID=$!
echo "后端进程ID: $BACKEND_PID"
echo $BACKEND_PID > ../debug-tools/backend.pid

# 等待服务启动
echo "2. 等待服务启动..."
sleep 3

# 测试服务
echo "3. 测试服务状态..."
curl -s http://localhost:3000/health || echo "⚠️ 服务启动失败"

echo ""
echo "✅ 调试环境已启动"
echo "📊 监控命令:"
echo "   ./monitor-logs.sh        - 查看实时日志"
echo "   ./performance-monitor.sh - 性能监控"  
echo "   ./collect-debug-info.sh  - 收集调试信息"
echo ""
echo "🛑 停止服务:"
echo "   kill $BACKEND_PID"

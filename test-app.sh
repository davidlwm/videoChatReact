#!/bin/bash

echo "🧪 开始测试视频聊天应用后端..."

# 检查Node.js版本
echo "📋 Node.js版本:"
node --version
echo ""

# 启动后端服务(后台)
echo "🚀 启动后端服务..."
cd backend
npm start &
BACKEND_PID=$!
echo "后端进程ID: $BACKEND_PID"
sleep 3

# 测试健康检查
echo "🏥 测试健康检查接口..."
curl -s http://localhost:3000/health | jq '.' || curl -s http://localhost:3000/health
echo ""

# 测试房间创建API
echo "🏠 测试房间创建..."
curl -s -X POST http://localhost:3000/api/join-room \
  -H "Content-Type: application/json" \
  -d '{"token":"TEST123"}' | jq '.' || \
  curl -s -X POST http://localhost:3000/api/join-room \
  -H "Content-Type: application/json" \
  -d '{"token":"TEST123"}'
echo ""

# 测试房间信息获取
echo "📊 测试房间信息获取..."
curl -s http://localhost:3000/api/room/TEST123 | jq '.' || \
  curl -s http://localhost:3000/api/room/TEST123
echo ""

# 测试服务器统计
echo "📈 测试服务器统计..."
curl -s http://localhost:3000/api/stats | jq '.' || \
  curl -s http://localhost:3000/api/stats
echo ""

# 停止后端服务
echo "🛑 停止后端服务..."
kill $BACKEND_PID
sleep 1

echo "✅ 后端测试完成!"
echo ""
echo "📱 前端测试需要在真机或模拟器上运行："
echo "   cd frontend && npx react-native run-android"
echo ""
echo "🎯 应用功能："
echo "   1. Token匹配房间"
echo "   2. WebRTC P2P视频通话" 
echo "   3. 实时文字聊天"
echo "   4. 音视频控制"
#!/bin/bash

echo "🔍 收集调试信息"
echo "=============="

DEBUG_DIR="/root/reactApp/debug-tools/debug-info-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$DEBUG_DIR"

echo "📋 收集系统信息..."
{
    echo "=== 系统信息 ==="
    uname -a
    echo ""
    echo "=== Node.js版本 ==="
    node --version
    echo ""
    echo "=== Java版本 ==="
    java -version
    echo ""
    echo "=== 系统资源 ==="
    free -h
    echo ""
    echo "=== 磁盘空间 ==="
    df -h
    echo ""
    echo "=== 进程信息 ==="
    ps aux | grep -E "(node|java)" | grep -v grep
} > "$DEBUG_DIR/system-info.txt"

echo "📦 收集项目信息..."
{
    echo "=== 项目结构 ==="
    tree /root/reactApp -I 'node_modules|.git' -L 3
    echo ""
    echo "=== 后端package.json ==="
    cat /root/reactApp/backend/package.json
    echo ""
    echo "=== 前端package.json ==="
    cat /root/reactApp/frontend/package.json
} > "$DEBUG_DIR/project-info.txt"

echo "🔗 收集网络信息..."
{
    echo "=== 端口监听状态 ==="
    netstat -tulpn | grep -E "(3000|8081)"
    echo ""
    echo "=== 防火墙状态 ==="
    sudo ufw status 2>/dev/null || echo "ufw未安装"
} > "$DEBUG_DIR/network-info.txt"

echo "📊 测试API接口..."
{
    echo "=== 健康检查 ==="
    curl -s http://localhost:3000/health || echo "API不可访问"
    echo ""
    echo "=== 房间创建测试 ==="
    curl -s -X POST http://localhost:3000/api/join-room \
         -H "Content-Type: application/json" \
         -d '{"token":"DEBUG123"}' || echo "API不可访问"
    echo ""
} > "$DEBUG_DIR/api-test.txt"

echo "✅ 调试信息已收集到: $DEBUG_DIR"
echo "📁 包含文件:"
ls -la "$DEBUG_DIR"

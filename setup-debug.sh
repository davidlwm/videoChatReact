#!/bin/bash

echo "🔧 设置远程调试和监控方案"
echo "=========================="
echo ""

# 创建简单的调试工具
mkdir -p /root/reactApp/debug-tools

# 1. 创建日志监控脚本
cat > /root/reactApp/debug-tools/monitor-logs.sh << 'EOF'
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
EOF

# 2. 创建性能监控脚本  
cat > /root/reactApp/debug-tools/performance-monitor.sh << 'EOF'
#!/bin/bash

echo "⚡ 应用性能监控"
echo "=============="

# 监控系统资源
echo "💻 系统资源使用："
echo "CPU: $(top -bn1 | grep 'Cpu(s)' | sed 's/.*, *\([0-9.]*\)%* id.*/\1/' | awk '{print 100 - $1"%"}')"
echo "内存: $(free | grep Mem | awk '{printf "%.1f%%", $3/$2 * 100.0}')"
echo "磁盘: $(df -h / | awk 'NR==2{printf "%s", $5}')"
echo ""

# 监控Node.js进程
NODE_PID=$(pgrep -f "node src/app.js")
if [ ! -z "$NODE_PID" ]; then
    echo "📊 Node.js进程资源使用 (PID: $NODE_PID):"
    ps -p $NODE_PID -o pid,ppid,cmd,%mem,%cpu --no-headers
    echo ""
fi

# 网络连接监控
echo "🌐 网络连接状态："
netstat -an | grep ":3000" | head -5
echo ""

# API响应时间测试
echo "⏱️  API响应时间测试："
for i in {1..3}; do
    start_time=$(date +%s%N)
    curl -s http://localhost:3000/health > /dev/null
    end_time=$(date +%s%N)
    response_time=$(( ($end_time - $start_time) / 1000000 ))
    echo "测试 $i: ${response_time}ms"
done
EOF

# 3. 创建调试信息收集脚本
cat > /root/reactApp/debug-tools/collect-debug-info.sh << 'EOF'
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
EOF

# 4. 创建一键启动脚本
cat > /root/reactApp/debug-tools/start-debug.sh << 'EOF'
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
EOF

# 设置执行权限
chmod +x /root/reactApp/debug-tools/*.sh

echo "✅ 远程调试工具已创建完成"
echo ""
echo "📁 调试工具位置: /root/reactApp/debug-tools/"
echo ""
echo "🛠️  可用工具:"
echo "1. start-debug.sh        - 一键启动调试环境"
echo "2. monitor-logs.sh       - 实时日志监控"
echo "3. performance-monitor.sh - 性能监控"
echo "4. collect-debug-info.sh - 收集调试信息"
echo ""
echo "💡 使用方法:"
echo "cd /root/reactApp/debug-tools"
echo "./start-debug.sh"
echo ""

# 测试调试工具
echo "🧪 测试调试工具..."
cd /root/reactApp/debug-tools
./start-debug.sh

sleep 2

echo ""
echo "📊 运行性能监控..."
./performance-monitor.sh
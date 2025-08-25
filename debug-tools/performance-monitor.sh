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

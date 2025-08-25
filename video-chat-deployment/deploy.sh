#!/bin/bash
# 云服务器部署脚本 - deploy.sh

echo "🚀 开始部署视频聊天应用后端..."

# 检查Node.js是否已安装
if ! command -v node &> /dev/null; then
    echo "❌ 未检测到Node.js，开始安装..."
    curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
    sudo apt-get install -y nodejs
fi

# 检查PM2是否已安装
if ! command -v pm2 &> /dev/null; then
    echo "📦 安装PM2进程管理器..."
    sudo npm install -g pm2
fi

# 创建应用目录
echo "📁 创建应用目录..."
sudo mkdir -p /opt/video-chat-app
sudo chown $USER:$USER /opt/video-chat-app

# 进入应用目录
cd /opt/video-chat-app

# 如果是首次部署，克隆代码；否则更新代码
if [ ! -d "backend" ]; then
    echo "📥 初始化项目结构..."
    mkdir -p backend
    mkdir -p logs
else
    echo "🔄 更新项目代码..."
fi

# 复制后端文件到服务器
echo "📋 请手动将后端代码上传到 /opt/video-chat-app/backend/"
echo "或使用以下命令:"
echo "scp -r ./backend/* username@server_ip:/opt/video-chat-app/backend/"

# 安装依赖
echo "📦 安装依赖包..."
cd backend
npm install --production

# 创建环境变量文件
echo "⚙️ 创建环境配置..."
cat > .env << EOL
# 生产环境配置
NODE_ENV=production
PORT=3000

# 允许的域名 (CORS配置)
ALLOWED_ORIGINS=*

# WebRTC STUN服务器
STUN_SERVER_1=stun:stun.l.google.com:19302
STUN_SERVER_2=stun:stun1.l.google.com:19302
EOL

# 创建PM2配置文件
echo "🔧 创建PM2配置..."
cat > ecosystem.config.js << EOL
module.exports = {
  apps: [{
    name: 'video-chat-backend',
    script: 'src/app.js',
    instances: 'max',
    exec_mode: 'cluster',
    env: {
      NODE_ENV: 'production',
      PORT: 3000
    },
    error_file: '../logs/err.log',
    out_file: '../logs/out.log',
    log_file: '../logs/combined.log',
    time: true,
    max_memory_restart: '500M',
    restart_delay: 3000,
    max_restarts: 10,
    autorestart: true,
    watch: false
  }]
}
EOL

# 配置防火墙
echo "🔥 配置防火墙..."
sudo ufw allow 22/tcp    # SSH
sudo ufw allow 3000/tcp  # 应用端口
sudo ufw --force enable

# 启动应用
echo "🚀 启动应用..."
pm2 start ecosystem.config.js
pm2 save
pm2 startup

echo ""
echo "✅ 部署完成！"
echo ""
echo "📊 应用信息："
echo "   端口: 3000"
echo "   进程管理: PM2"
echo "   日志位置: /opt/video-chat-app/logs/"
echo ""
echo "🛠️ 常用命令："
echo "   查看状态: pm2 status"
echo "   查看日志: pm2 logs video-chat-backend"
echo "   重启应用: pm2 restart video-chat-backend"
echo "   停止应用: pm2 stop video-chat-backend"
echo ""
echo "🌐 应用访问地址："
echo "   健康检查: http://YOUR_SERVER_IP:3000/health"
echo "   API统计: http://YOUR_SERVER_IP:3000/api/stats"
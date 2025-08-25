# 视频聊天应用 - 云服务器部署文档

## 服务器基本信息
- **IP地址**: 139.9.86.87
- **操作系统**: Ubuntu 24.04 x86_64
- **访问凭据**: root / tarenadavid
- **部署路径**: /opt/video-chat-app/
- **服务端口**: 3000

## 部署架构

```
云服务器 (139.9.86.87)
├── PM2进程管理器
│   ├── video-chat-backend (实例1)
│   └── video-chat-backend (实例2)
├── 应用目录 (/opt/video-chat-app/)
│   ├── backend/          # Node.js应用代码
│   ├── logs/            # 应用日志目录
│   └── ecosystem.config.js # PM2配置文件
└── 系统服务
    ├── ufw防火墙 (端口22, 3000开放)
    └── Node.js v22.17.0
```

## 快速部署指南

### 1. 连接服务器
```bash
ssh root@139.9.86.87
# 密码: tarenadavid
```

### 2. 检查服务状态
```bash
# 查看PM2进程状态
pm2 status

# 查看应用日志
pm2 logs video-chat-backend

# 检查端口占用
netstat -tulpn | grep :3000

# 检查防火墙状态
ufw status
```

### 3. 服务管理命令
```bash
# 重启应用
pm2 restart video-chat-backend

# 停止应用
pm2 stop video-chat-backend

# 启动应用
pm2 start video-chat-backend

# 删除应用(谨慎使用)
pm2 delete video-chat-backend
```

## 更新部署流程

### 方式1: 手动上传更新
```bash
# 本地执行 - 上传后端代码
scp -r ./backend/* root@139.9.86.87:/opt/video-chat-app/backend/

# 服务器执行 - 重启服务
ssh root@139.9.86.87 "cd /opt/video-chat-app/backend && npm install --production && pm2 restart video-chat-backend"
```

### 方式2: 使用部署脚本
```bash
# 在服务器上运行部署脚本
cd /opt/video-chat-app
./deploy.sh
```

## 环境配置文件

### PM2配置 (ecosystem.config.js)
```javascript
module.exports = {
  apps: [{
    name: 'video-chat-backend',
    script: 'src/app.js',
    instances: 2,  // 2个实例集群模式
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
```

### 环境变量 (.env.production)
```bash
NODE_ENV=production
PORT=3000
ALLOWED_ORIGINS=*
STUN_SERVER_1=stun:stun.l.google.com:19302
STUN_SERVER_2=stun:stun1.l.google.com:19302
LOG_LEVEL=info
```

## API接口测试

### 健康检查接口
```bash
curl http://139.9.86.87:3000/health
# 预期返回:
# {"status":"OK","timestamp":"2025-08-25T14:19:47.428Z","service":"video-chat-backend"}
```

### 房间管理接口
```bash
# 创建/加入房间
curl -X POST http://139.9.86.87:3000/api/join-room \
  -H "Content-Type: application/json" \
  -d '{"token":"TEST123"}'
# 预期返回:
# {"success":true,"roomId":"TEST123","userCount":0}

# 查看房间信息
curl http://139.9.86.87:3000/api/room/TEST123
# 预期返回:
# {"success":true,"roomId":"TEST123","userCount":0,"users":[]}

# 查看服务器统计
curl http://139.9.86.87:3000/api/stats
# 预期返回:
# {"success":true,"totalRooms":1,"totalUsers":0,"timestamp":"..."}
```

## 监控和日志

### 实时监控
```bash
# 实时查看所有日志
pm2 logs

# 实时查看特定应用日志
pm2 logs video-chat-backend

# 查看系统资源使用
pm2 monit

# 查看进程详细信息
pm2 show video-chat-backend
```

### 日志文件位置
```
/opt/video-chat-app/logs/
├── err.log          # 错误日志
├── out.log          # 输出日志
└── combined.log     # 合并日志
```

## 网络配置

### 防火墙规则
```bash
# 查看当前规则
ufw status verbose

# 允许SSH (22端口)
ufw allow 22/tcp

# 允许应用端口 (3000端口)
ufw allow 3000/tcp

# 启用防火墙
ufw --force enable
```

### 端口占用处理
```bash
# 查找占用3000端口的进程
lsof -i :3000

# 或使用netstat
netstat -tulpn | grep :3000

# 结束进程 (谨慎使用)
kill -9 PID_NUMBER
```

## 故障排除

### 常见问题及解决方案

1. **服务无法启动**
   ```bash
   # 检查Node.js版本
   node --version
   
   # 检查依赖安装
   cd /opt/video-chat-app/backend
   npm install --production
   
   # 查看错误日志
   pm2 logs video-chat-backend --err
   ```

2. **端口被占用**
   ```bash
   # 找到占用进程并结束
   lsof -i :3000
   kill -9 [PID]
   
   # 重启PM2服务
   pm2 restart video-chat-backend
   ```

3. **内存不足**
   ```bash
   # 查看内存使用
   free -h
   
   # 调整PM2实例数
   pm2 scale video-chat-backend 1  # 减少到1个实例
   ```

4. **无法访问API**
   ```bash
   # 检查防火墙
   ufw status
   
   # 检查服务状态
   pm2 status
   
   # 测试本地连接
   curl http://localhost:3000/health
   ```

## 性能优化建议

### 服务器级别
1. **实例数调整**: 根据CPU核心数调整PM2实例数量
2. **内存限制**: 设置合理的 `max_memory_restart` 值
3. **日志轮转**: 配置日志轮转避免磁盘满载

### 应用级别
1. **连接池**: 如需数据库连接，配置连接池
2. **缓存机制**: 对频繁访问的数据添加缓存
3. **压缩**: 启用gzip压缩减少传输数据

## 备份和恢复

### 代码备份
```bash
# 创建代码备份
tar -czf video-chat-backup-$(date +%Y%m%d).tar.gz /opt/video-chat-app/backend/

# 恢复代码
tar -xzf video-chat-backup-YYYYMMDD.tar.gz -C /
```

### 配置备份
```bash
# 备份重要配置文件
cp /opt/video-chat-app/backend/.env.production ~/backup/
cp /opt/video-chat-app/backend/ecosystem.config.js ~/backup/
```

## 安全注意事项

1. **密码管理**: 定期更换服务器密码
2. **端口管理**: 只开放必要端口 (22, 3000)
3. **日志监控**: 定期检查异常访问日志
4. **依赖更新**: 定期更新Node.js和npm包

## 联系信息

- **部署时间**: 2025-08-25
- **版本信息**: Node.js v22.17.0, PM2 v6.0.8
- **维护记录**: 见 PROJECT_LOG.md

---

**文档版本**: 1.0  
**最后更新**: 2025-08-25 22:40  
**状态**: 生产环境运行正常
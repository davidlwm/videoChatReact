const express = require('express');
const http = require('http');
const cors = require('cors');
const { Server } = require('socket.io');
require('dotenv').config();

const roomController = require('./controllers/roomController');
const socketService = require('./services/socketService');

const app = express();
const server = http.createServer(app);

// CORS配置
const corsOptions = {
  origin: process.env.ALLOWED_ORIGINS ? process.env.ALLOWED_ORIGINS.split(',') : "*",
  methods: ["GET", "POST"],
  credentials: true
};

app.use(cors(corsOptions));
app.use(express.json());

// Socket.io配置
const io = new Server(server, {
  cors: corsOptions
});

// API路由
app.use('/api', require('./routes/api'));

// Socket.io事件处理
socketService.initialize(io);

// 健康检查
app.get('/health', (req, res) => {
  res.json({ 
    status: 'OK', 
    timestamp: new Date().toISOString(),
    service: 'video-chat-backend'
  });
});

const PORT = process.env.PORT || 3000;

server.listen(PORT, () => {
  console.log(`🚀 服务器运行在端口 ${PORT}`);
  console.log(`📊 环境: ${process.env.NODE_ENV || 'development'}`);
});

module.exports = app;
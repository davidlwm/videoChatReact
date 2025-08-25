const RoomController = require('../controllers/roomController');
const { v4: uuidv4 } = require('uuid');

let io = null;

class SocketService {
  static initialize(socketIO) {
    io = socketIO;

    io.on('connection', (socket) => {
      console.log(`🔌 用户连接: ${socket.id}`);

      // 加入房间
      socket.on('join-room', (data) => {
        try {
          const { token } = data;
          const userId = uuidv4();
          
          // 加入Socket.io房间
          socket.join(token);
          
          // 添加用户到房间控制器
          RoomController.addUserToRoom(token, userId, socket.id);
          
          // 存储用户信息到socket
          socket.roomId = token;
          socket.userId = userId;

          // 通知房间其他用户
          socket.to(token).emit('user-joined', { 
            userId,
            message: '有新用户加入房间'
          });

          // 发送成功响应
          socket.emit('join-room-success', {
            success: true,
            roomId: token,
            userId,
            message: '成功加入房间'
          });

          console.log(`📝 用户 ${userId} 加入房间 ${token}`);
        } catch (error) {
          socket.emit('join-room-error', { 
            success: false, 
            error: error.message 
          });
        }
      });

      // 发送消息
      socket.on('send-message', (data) => {
        try {
          if (!socket.roomId) {
            socket.emit('message-error', { error: '未加入房间' });
            return;
          }

          const messageData = {
            userId: socket.userId,
            content: data.content,
            type: data.type || 'text'
          };

          // 保存消息
          const savedMessage = RoomController.addMessage(socket.roomId, messageData);
          
          if (savedMessage) {
            // 广播消息给房间内所有用户
            io.to(socket.roomId).emit('receive-message', savedMessage);
            console.log(`💬 房间 ${socket.roomId} 收到消息`);
          }
        } catch (error) {
          socket.emit('message-error', { error: error.message });
        }
      });

      // WebRTC信令 - Offer
      socket.on('webrtc-offer', (data) => {
        socket.to(socket.roomId).emit('webrtc-offer', {
          offer: data.offer,
          userId: socket.userId
        });
        console.log(`📡 WebRTC Offer from ${socket.userId}`);
      });

      // WebRTC信令 - Answer
      socket.on('webrtc-answer', (data) => {
        socket.to(socket.roomId).emit('webrtc-answer', {
          answer: data.answer,
          userId: socket.userId
        });
        console.log(`📡 WebRTC Answer from ${socket.userId}`);
      });

      // WebRTC信令 - ICE Candidate
      socket.on('webrtc-ice-candidate', (data) => {
        socket.to(socket.roomId).emit('webrtc-ice-candidate', {
          candidate: data.candidate,
          userId: socket.userId
        });
        console.log(`🧊 ICE Candidate from ${socket.userId}`);
      });

      // 用户断开连接
      socket.on('disconnect', () => {
        console.log(`🔌 用户断开: ${socket.id}`);
        
        if (socket.roomId) {
          // 从房间移除用户
          RoomController.removeUserFromRoom(socket.roomId, socket.id);
          
          // 通知房间其他用户
          socket.to(socket.roomId).emit('user-left', {
            userId: socket.userId,
            message: '用户离开房间'
          });
        }
      });
    });
  }

  static getIO() {
    return io;
  }
}

module.exports = SocketService;
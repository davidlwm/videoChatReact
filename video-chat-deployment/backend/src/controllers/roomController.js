const { v4: uuidv4 } = require('uuid');

// 内存存储房间数据 (极简设计)
const rooms = new Map();

class RoomController {
  // 加入房间
  static joinRoom(token) {
    try {
      if (!token) {
        return { success: false, error: '需要提供token' };
      }

      // 使用token作为房间ID
      const roomId = token;
      
      if (!rooms.has(roomId)) {
        // 创建新房间
        rooms.set(roomId, {
          roomId,
          users: [],
          messages: [],
          createdAt: new Date()
        });
      }

      const room = rooms.get(roomId);
      
      return { 
        success: true, 
        roomId,
        userCount: room.users.length
      };
    } catch (error) {
      return { success: false, error: error.message };
    }
  }

  // 用户加入房间
  static addUserToRoom(roomId, userId, socketId) {
    const room = rooms.get(roomId);
    if (!room) {
      return false;
    }

    // 检查用户是否已存在
    const existingUser = room.users.find(user => user.id === userId);
    if (existingUser) {
      // 更新socketId
      existingUser.socketId = socketId;
    } else {
      // 添加新用户
      room.users.push({
        id: userId,
        socketId,
        joinedAt: new Date()
      });
    }

    return true;
  }

  // 用户离开房间
  static removeUserFromRoom(roomId, socketId) {
    const room = rooms.get(roomId);
    if (!room) {
      return false;
    }

    room.users = room.users.filter(user => user.socketId !== socketId);
    
    // 如果房间空了，删除房间
    if (room.users.length === 0) {
      rooms.delete(roomId);
    }

    return true;
  }

  // 获取房间信息
  static getRoomInfo(roomId) {
    return rooms.get(roomId) || null;
  }

  // 添加消息到房间
  static addMessage(roomId, message) {
    const room = rooms.get(roomId);
    if (!room) {
      return false;
    }

    const messageData = {
      id: uuidv4(),
      ...message,
      timestamp: new Date()
    };

    room.messages.push(messageData);
    
    // 只保留最近50条消息
    if (room.messages.length > 50) {
      room.messages = room.messages.slice(-50);
    }

    return messageData;
  }

  // 获取所有房间统计
  static getStats() {
    return {
      totalRooms: rooms.size,
      totalUsers: Array.from(rooms.values()).reduce((sum, room) => sum + room.users.length, 0)
    };
  }
}

module.exports = RoomController;
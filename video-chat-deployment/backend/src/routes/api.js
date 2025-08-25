const express = require('express');
const router = express.Router();
const RoomController = require('../controllers/roomController');

// 加入房间API
router.post('/join-room', (req, res) => {
  try {
    const { token } = req.body;
    
    if (!token) {
      return res.status(400).json({
        success: false,
        error: '缺少token参数'
      });
    }

    const result = RoomController.joinRoom(token);
    
    if (result.success) {
      res.json(result);
    } else {
      res.status(400).json(result);
    }
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// 获取房间信息
router.get('/room/:roomId', (req, res) => {
  try {
    const { roomId } = req.params;
    const room = RoomController.getRoomInfo(roomId);
    
    if (room) {
      res.json({
        success: true,
        room: {
          roomId: room.roomId,
          userCount: room.users.length,
          messageCount: room.messages.length,
          createdAt: room.createdAt
        }
      });
    } else {
      res.status(404).json({
        success: false,
        error: '房间不存在'
      });
    }
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// 服务器统计信息
router.get('/stats', (req, res) => {
  try {
    const stats = RoomController.getStats();
    res.json({
      success: true,
      ...stats,
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

module.exports = router;
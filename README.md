# 视频聊天应用 - 极简版

基于React Native + WebRTC的点对点视频聊天应用

## 🚀 快速开始

### 启动后端服务
```bash
cd backend
npm run dev
```

### 启动前端应用
```bash
cd frontend
npx react-native run-android
# 或
npx react-native run-ios
```

## 📱 主要功能

- ✅ Token房间匹配
- ✅ P2P视频通话
- ✅ 实时文字聊天
- ✅ 音视频控制（静音/关闭视频/切换摄像头）
- ✅ 极简UI设计

## 🛠️ 技术栈

- **前端**: React Native + WebRTC
- **后端**: Node.js + Socket.io + Express
- **通信**: WebSocket + WebRTC P2P

## 📋 使用说明

1. 启动后端服务器
2. 在手机上启动应用
3. 输入相同的Token即可匹配到同一房间
4. 自动建立P2P视频连接

## 🔧 开发环境

- Node.js 18+
- React Native CLI
- Android Studio / Xcode
- 支持摄像头和麦克风的设备

## 📖 项目结构

```
├── backend/           # Node.js后端
│   ├── src/
│   │   ├── app.js           # 主服务器
│   │   ├── controllers/     # 房间控制器
│   │   ├── services/        # Socket服务
│   │   └── routes/          # API路由
├── frontend/          # React Native前端
│   ├── src/
│   │   ├── components/      # UI组件
│   │   ├── screens/         # 页面组件
│   │   └── services/        # WebRTC & Socket服务
```

## 🎯 极简设计原则

- 单页面应用
- 最小化功能集
- 无数据库依赖
- 内存状态管理
- P2P直连通信
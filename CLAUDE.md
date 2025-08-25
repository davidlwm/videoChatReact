# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Information
- **Project Name**: 视频聊天应用 (Video Chat Application)
- **Tech Stack**: React Native + Node.js + WebRTC + Socket.io
- **Platform Support**: iOS + Android
- **Language**: Chinese (中文)
- **Design Principle**: Minimalist design with minimal complexity

## Project Structure
```
reactApp/
├── 需求文档.md           # Product requirements document
├── 技术架构方案.md       # Technical architecture design
├── CLAUDE.md            # This configuration file
├── README.md            # Project overview
├── test-app.sh          # Backend API testing script
├── setup-debug.sh       # Debug environment setup
├── android-build-guide.sh # Android build guide
├── debug-tools/         # Debug and monitoring scripts
├── frontend/            # React Native client
│   ├── src/
│   │   ├── components/      # UI components (VideoView, ControlButtons, etc.)
│   │   ├── screens/         # Screen components (MainScreen)
│   │   └── services/        # Core services (WebRTC, Socket)
│   ├── android/             # Android native code
│   ├── ios/                 # iOS native code
│   └── package.json
└── backend/             # Node.js server
    ├── src/
    │   ├── app.js              # Main server file
    │   ├── controllers/        # Business logic (roomController)
    │   ├── services/           # Socket service
    │   └── routes/             # API routes
    └── package.json
```

## Architecture Overview

### Core Services Architecture
- **WebRTC Service** (`frontend/src/services/webrtcService.js`): Handles P2P video/audio connections
- **Socket Service** (`frontend/src/services/socketService.js`): Manages WebSocket communication with server
- **Room Controller** (`backend/src/controllers/roomController.js`): Manages room state and users
- **Socket Service** (`backend/src/services/socketService.js`): Handles WebSocket events and WebRTC signaling

### WebRTC Flow
1. Users join room using shared token
2. Socket.io handles signaling (offer/answer/ICE candidates)
3. WebRTC establishes P2P connection
4. Direct audio/video streaming between clients

### State Management
- Backend: In-memory room state (no database)
- Frontend: Component-level state with React hooks
- Real-time sync via Socket.io events

## Common Development Commands

### Backend Development
```bash
# Development mode (with auto-reload)
cd backend && npm run dev

# Production mode
cd backend && npm start

# Test backend APIs
./test-app.sh
```

### Frontend Development
```bash
# Install dependencies
cd frontend && npm install

# Start Metro bundler
cd frontend && npm start

# Run on Android
cd frontend && npm run android

# Run on iOS  
cd frontend && npm run ios

# Run tests
cd frontend && npm test

# Lint code
cd frontend && npm run lint
```

### Debug and Monitoring
```bash
# Setup debug environment
./setup-debug.sh

# Monitor logs
./debug-tools/monitor-logs.sh

# Performance monitoring
./debug-tools/performance-monitor.sh

# Collect debug info
./debug-tools/collect-debug-info.sh
```

### Android Build
```bash
# Debug APK (faster)
cd frontend/android && ./gradlew assembleDebug

# Release APK (production)
cd frontend/android && ./gradlew assembleRelease

# Check devices
adb devices

# View logs
cd frontend && npx react-native log-android
```

### iOS Build
```bash
# Debug build
cd frontend && npx react-native run-ios

# Release build
xcodebuild -workspace frontend/ios/frontend.xcworkspace -scheme frontend -configuration Release

# View logs  
cd frontend && npx react-native log-ios
```

## Development Environment Requirements

### Prerequisites
- Node.js 18+
- React Native CLI
- Android Studio (for Android development)
- Xcode (for iOS development)
- Camera and microphone enabled devices for testing

### Key Dependencies
**Frontend:**
- `react-native-webrtc@124.0.6` - WebRTC implementation
- `socket.io-client@4.8.1` - Real-time communication
- `@react-native-async-storage/async-storage@2.2.0` - Local storage

**Backend:**
- `express@5.1.0` - Web server framework
- `socket.io@4.8.1` - WebSocket server
- `uuid@11.1.0` - Unique ID generation
- `cors@2.8.5` - Cross-origin support

## WebRTC Configuration

### STUN Servers
```javascript
iceServers: [
  { urls: 'stun:stun.l.google.com:19302' },
  { urls: 'stun:stun1.l.google.com:19302' },
]
```

### Media Constraints
- Video: 1280x720 @ 30fps (configurable)
- Audio: Echo cancellation, noise suppression enabled
- Camera: Front-facing by default with flip capability

## API Endpoints

### REST API
- `GET /health` - Health check
- `POST /api/join-room` - Join room with token
- `GET /api/room/:token` - Get room information
- `GET /api/stats` - Server statistics

### WebSocket Events
**Client → Server:**
- `join-room` - Join room with token
- `send-message` - Send chat message
- `webrtc-offer/answer/ice-candidate` - WebRTC signaling

**Server → Client:**
- `join-room-success/error` - Room join response
- `receive-message` - Incoming chat message
- `user-joined/left` - User presence updates
- `webrtc-offer/answer/ice-candidate` - WebRTC signaling

## Development Conventions

### Code Style
- Use ES6+ syntax
- Functional components preferred
- Use React Hooks for state management
- Clean and descriptive variable names
- TypeScript support available (`tsconfig.json` configured)

### File Naming Conventions
- Components: PascalCase (`VideoView.js`, `ControlButtons.js`)
- Services: camelCase (`socketService.js`, `webrtcService.js`)
- Screens: PascalCase (`MainScreen.js`)
- Controllers: camelCase (`roomController.js`)

### Testing
- Jest configured for frontend (`jest.config.js`)
- Test files in `__tests__/` directory
- Run tests: `npm test` in frontend directory

## Troubleshooting

### Common Issues
1. **WebRTC Connection Failed**: Check STUN server accessibility and network permissions
2. **Socket Connection Error**: Verify backend server is running on correct port
3. **Camera/Mic Access**: Ensure device permissions are granted
4. **Android Build Issues**: Check Java/Gradle versions and Android SDK setup

### Network Configuration
- Backend default port: 3000
- Android emulator server URL: `http://10.0.2.2:3000`
- iOS simulator server URL: `http://localhost:3000`

### Debug URLs
- WebRTC internals: `chrome://webrtc-internals` (for web debugging)
- Test API: `curl http://localhost:3000/health`

## Key Implementation Details

### WebRTC Service Features
- Automatic camera switching
- Audio/video toggle controls
- Connection state monitoring
- ICE candidate handling
- Offer/Answer SDP negotiation

### Socket Service Features  
- Auto-reconnection handling
- Room-based messaging
- WebRTC signaling relay
- User presence tracking
- Error handling with callbacks

### Room Management
- Token-based room matching
- In-memory state storage
- User join/leave notifications
- Message history per room
- Automatic cleanup on disconnect
const { WebSocketServer } = require("ws");
const RoomManager = require("./room_manager");

const wss = new WebSocketServer({ port: 8080 });
const roomManager = new RoomManager();
let nextWsId = 1;

// 应用层心跳参数（不依赖 ws.ping/pong，因为 Godot WebSocketPeer 不暴露 pong 回调）
// 与客户端 ws_client.gd 的 STALE_THRESHOLD 对齐：5s 无任何消息 → 判超时
const HEARTBEAT_TIMEOUT_MS = 5000;

wss.on("connection", (ws) => {
  ws.ws_id = nextWsId++;
  ws._lastPong = Date.now();
  ws._lastActivity = Date.now();
  console.log(`[connect] ws_id=${ws.ws_id}`);

  // 原生 ws ping/pong：兜底检测半开连接
  ws.on("pong", () => {
    ws._lastPong = Date.now();
  });

  ws.on("message", (data) => {
    let msg;
    try {
      msg = JSON.parse(data.toString());
    } catch (e) {
      ws.send(JSON.stringify({ type: "error", payload: { message: "Invalid JSON" } }));
      return;
    }

    const { type, payload } = msg;
    console.log(`[msg] ws_id=${ws.ws_id} type=${type}`);

    // 任何消息都更新活动时间（客户端发包本身就是活着的证据）
    ws._lastActivity = Date.now();

    try {
      switch (type) {
        case "app_ping":
          // 应用层心跳：立即回 pong（echo 客户端时间戳方便客户端算 RTT）
          ws.send(JSON.stringify({
            type: "app_pong",
            payload: { t: Date.now(), echo: payload && payload.t },
          }));
          break;

        case "list_rooms":
          ws.send(JSON.stringify({ type: "room_list", payload: { rooms: roomManager.listRooms() } }));
          break;

        case "create_room":
          const result = roomManager.createRoom(ws, ws.ws_id, (payload && payload.name) || "Game");
          ws.send(JSON.stringify({ type: "room_created", payload: result }));
          break;

        case "join_room":
          roomManager.joinRoom(ws, ws.ws_id, payload.code);
          ws.send(JSON.stringify({ type: "room_joined", payload: { code: payload.code } }));
          break;

        case "leave_room":
          roomManager.leaveRoom(ws);
          break;

        case "ready":
          roomManager.toggleReady(ws);
          break;

        case "start_game":
          roomManager.startGame(ws);
          break;

        case "load_complete":
          roomManager.loadComplete(ws);
          break;

        case "game_data":
          roomManager.relayGameData(ws, payload);
          break;

        case "update_map":
          roomManager.updateMap(ws, payload.map);
          break;

        default:
          console.log(`[warn] Unknown message type: ${type}`);
      }
    } catch (e) {
      console.error(`[error] ${e.message}`);
      ws.send(JSON.stringify({ type: "error", payload: { message: e.message } }));
    }
  });

  ws.on("close", () => {
    console.log(`[disconnect] ws_id=${ws.ws_id}`);
    roomManager.handleDisconnect(ws);
  });

  ws.on("error", (err) => {
    console.error(`[error] ws_id=${ws.ws_id}: ${err.message}`);
  });
});

// Heartbeat 监控：原生 ws.ping() 兜底 + 应用层 lastActivity 检测
setInterval(() => {
  const now = Date.now();
  wss.clients.forEach((ws) => {
    // 1. 原生 ws ping/pong 兜底（30s 无 pong 帧 → terminate）
    if (ws._lastPong && now - ws._lastPong > 30000) {
      console.log(`[heartbeat] ws_id=${ws.ws_id} ws.ping timeout (30s), terminating`);
      ws.terminate();
      return;
    }
    try { ws.ping(); } catch (e) { /* ws 可能已关闭 */ }

    // 2. 应用层心跳：在房间里的玩家 15s 无任何消息 → 通知对方 + terminate
    if (now - ws._lastActivity > HEARTBEAT_TIMEOUT_MS) {
      const playerRole = roomManager.getPlayerRole(ws);
      if (playerRole !== 0) {
        console.log(`[heartbeat] ws_id=${ws.ws_id} app timeout (${HEARTBEAT_TIMEOUT_MS / 1000}s no activity), notifying peer + terminating`);
        roomManager.notifyPeerTimeout(ws);
        ws.terminate();
      }
    }
  });
}, 5000);  // 每 5s 巡检一次

console.log("RTS Relay Server running on ws://0.0.0.0:8080");

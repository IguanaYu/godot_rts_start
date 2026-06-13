const { WebSocketServer } = require("ws");
const RoomManager = require("./room_manager");

const wss = new WebSocketServer({ port: 8080 });
const roomManager = new RoomManager();
let nextWsId = 1;

wss.on("connection", (ws) => {
  ws.ws_id = nextWsId++;
  ws._lastPong = Date.now();
  console.log(`[connect] ws_id=${ws.ws_id}`);

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

    try {
      switch (type) {
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

// Heartbeat every 10s
setInterval(() => {
  wss.clients.forEach((ws) => {
    if (ws._lastPong && Date.now() - ws._lastPong > 30000) {
      console.log(`[heartbeat] ws_id=${ws.ws_id} timeout, terminating`);
      ws.terminate();
      return;
    }
    ws.ping();
    ws._lastPong = Date.now();
  });
}, 10000);

console.log("RTS Relay Server running on ws://0.0.0.0:8080");

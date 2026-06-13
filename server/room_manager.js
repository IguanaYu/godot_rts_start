class RoomManager {
  constructor() {
    this.rooms = new Map();
    this.wsToRoom = new Map();
  }

  _generateCode() {
    const chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
    let code;
    do {
      code = "";
      for (let i = 0; i < 6; i++) {
        code += chars[Math.floor(Math.random() * chars.length)];
      }
    } while (this.rooms.has(code));
    return code;
  }

  createRoom(ws, wsId, roomName) {
    this.leaveRoom(ws);
    const code = this._generateCode();
    this.rooms.set(code, {
      code,
      name: roomName || "Game",
      host: { ws, id: wsId, ready: true },
      guest: null,
      map: "map_1",
      state: "waiting",
      hostLoaded: false,
      guestLoaded: false,
    });
    this.wsToRoom.set(ws, code);
    return { code, name: roomName || "Game", map: "map_1" };
  }

  listRooms() {
    const result = [];
    for (const [code, room] of this.rooms) {
      if (room.state === "waiting" && room.guest === null) {
        result.push({
          code,
          name: room.name,
          playerCount: 1,
          map: room.map,
        });
      }
    }
    return result;
  }

  joinRoom(ws, wsId, code) {
    const room = this.rooms.get(code);
    if (!room) throw new Error("Room not found");
    if (room.state !== "waiting") throw new Error("Game already started");
    if (room.guest) throw new Error("Room is full");

    this.leaveRoom(ws);
    room.guest = { ws, id: wsId, ready: false };
    this.wsToRoom.set(ws, code);
    this._sendTo(room.host.ws, "player_joined", { player_id: wsId });
  }

  leaveRoom(ws) {
    const code = this.wsToRoom.get(ws);
    if (!code) return;

    const room = this.rooms.get(code);
    if (!room) {
      this.wsToRoom.delete(ws);
      return;
    }

    if (room.host && room.host.ws === ws) {
      // Host left — disband room
      if (room.guest) {
        this._sendTo(room.guest.ws, "player_left", {});
      }
      this.rooms.delete(code);
    } else if (room.guest && room.guest.ws === ws) {
      // Guest left
      room.guest = null;
      room.hostLoaded = false;
      room.guestLoaded = false;
      this._sendTo(room.host.ws, "player_left", {});
    }

    this.wsToRoom.delete(ws);
  }

  handleDisconnect(ws) {
    this.leaveRoom(ws);
  }

  toggleReady(ws) {
    const code = this.wsToRoom.get(ws);
    if (!code) throw new Error("Not in a room");

    const room = this.rooms.get(code);
    if (!room || !room.guest) return;

    if (room.guest.ws === ws) {
      room.guest.ready = !room.guest.ready;
      this._sendTo(room.host.ws, "player_ready", { ready: room.guest.ready });
    }
  }

  startGame(ws) {
    const code = this.wsToRoom.get(ws);
    if (!code) throw new Error("Not in a room");

    const room = this.rooms.get(code);
    if (!room || !room.host) throw new Error("Room not found");
    if (room.host.ws !== ws) throw new Error("Only host can start");
    if (!room.guest || !room.guest.ready) throw new Error("Guest not ready");

    room.state = "loading";
    room.hostLoaded = false;
    room.guestLoaded = false;
    this._sendTo(room.host.ws, "start_game", { map: room.map });
    this._sendTo(room.guest.ws, "start_game", { map: room.map });
  }

  loadComplete(ws) {
    const code = this.wsToRoom.get(ws);
    if (!code) return;

    const room = this.rooms.get(code);
    if (!room) return;

    if (room.host && room.host.ws === ws) {
      room.hostLoaded = true;
    } else if (room.guest && room.guest.ws === ws) {
      room.guestLoaded = true;
    }

    if (room.hostLoaded && room.guestLoaded) {
      room.state = "playing";
      const seed = Math.floor(Math.random() * 2147483647);
      this._sendTo(room.host.ws, "both_loaded", { seed });
      this._sendTo(room.guest.ws, "both_loaded", { seed });
    }
  }

  relayGameData(ws, payload) {
    const code = this.wsToRoom.get(ws);
    if (!code) return;

    const room = this.rooms.get(code);
    if (!room) return;

    const other =
      room.host && room.host.ws !== ws ? room.host.ws : room.guest ? room.guest.ws : null;
    if (other) {
      this._sendTo(other, "game_data", payload);
    }
  }

  updateMap(ws, map) {
    const code = this.wsToRoom.get(ws);
    if (!code) return;

    const room = this.rooms.get(code);
    if (!room || !room.host || room.host.ws !== ws) return;

    room.map = map;
    if (room.guest) {
      this._sendTo(room.guest.ws, "map_changed", { map });
    }
  }

  _sendTo(ws, type, payload) {
    if (ws.readyState === 1) {
      ws.send(JSON.stringify({ type, payload }));
    }
  }
}

module.exports = RoomManager;

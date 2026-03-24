/**
 * Feed The Cups - WebSocket Relay Server
 *
 * 职责：
 * - 管理游戏房间（创建/加入/离开）
 * - 转发玩家实时状态（位置、压力值、持有物品等）
 * - 同步游戏事件（订单、天数、金钱等）
 * - 不做权威逻辑计算，纯中继
 */

const WebSocket = require('ws');

const PORT = process.env.PORT || 8080;
const wss = new WebSocket.Server({ port: PORT, maxPayload: 4 * 1024 * 1024 });

// 房间结构: { id, host, players: Map<ws, playerInfo>, state: 'lobby'|'playing' }
const rooms = new Map();
// ws -> { roomId, playerId, playerName }
const clients = new Map();

let nextRoomId = 1000;
let nextPlayerId = 1;

function broadcast(room, msg, excludeWs = null) {
  const data = JSON.stringify(msg);
  for (const [ws] of room.players) {
    if (ws !== excludeWs && ws.readyState === WebSocket.OPEN) {
      ws.send(data);
    }
  }
}

function sendTo(ws, msg) {
  if (ws.readyState === WebSocket.OPEN) {
    ws.send(JSON.stringify(msg));
  }
}

function getRoomList() {
  const list = [];
  for (const [id, room] of rooms) {
    if (room.state === 'lobby') {
      list.push({
        id,
        hostName: room.hostName,
        playerCount: room.players.size,
        maxPlayers: room.maxPlayers,
        levelName: room.levelName || '',
      });
    }
  }
  return list;
}

wss.on('connection', (ws) => {
  console.log('[+] Client connected');

  ws.on('message', (raw) => {
    let msg;
    try {
      msg = JSON.parse(raw);
    } catch {
      return;
    }

    const client = clients.get(ws);

    switch (msg.type) {

      // ── 大厅 ──────────────────────────────────────────────
      case 'get_rooms': {
        sendTo(ws, { type: 'room_list', rooms: getRoomList() });
        break;
      }

      case 'create_room': {
        const roomId = String(nextRoomId++);
        const playerId = nextPlayerId++;
        const room = {
          id: roomId,
          hostWs: ws,
          hostName: msg.playerName || 'Host',
          players: new Map([[ws, { id: playerId, name: msg.playerName || 'Player', ready: false }]]),
          state: 'lobby',
          maxPlayers: msg.maxPlayers || 4,
          levelName: msg.levelName || '',
        };
        rooms.set(roomId, room);
        clients.set(ws, { roomId, playerId, playerName: msg.playerName });
        sendTo(ws, {
          type: 'room_created',
          roomId,
          playerId,
          isHost: true,
        });
        console.log(`[Room ${roomId}] Created by ${msg.playerName}`);
        break;
      }

      case 'join_room': {
        const room = rooms.get(msg.roomId);
        if (!room) {
          sendTo(ws, { type: 'error', code: 'ROOM_NOT_FOUND' });
          break;
        }
        if (room.state !== 'lobby') {
          sendTo(ws, { type: 'error', code: 'GAME_ALREADY_STARTED' });
          break;
        }
        if (room.players.size >= room.maxPlayers) {
          sendTo(ws, { type: 'error', code: 'ROOM_FULL' });
          break;
        }
        const playerId = nextPlayerId++;
        room.players.set(ws, { id: playerId, name: msg.playerName || 'Player', ready: false });
        clients.set(ws, { roomId: msg.roomId, playerId, playerName: msg.playerName });

        // 告知新玩家当前房间成员
        const memberList = [];
        for (const [, info] of room.players) {
          memberList.push({ id: info.id, name: info.name, ready: info.ready });
        }
        sendTo(ws, {
          type: 'room_joined',
          roomId: msg.roomId,
          playerId,
          isHost: false,
          members: memberList,
        });

        // 通知房间其他人
        broadcast(room, {
          type: 'player_joined',
          playerId,
          playerName: msg.playerName,
        }, ws);

        console.log(`[Room ${msg.roomId}] ${msg.playerName} joined (${room.players.size}/${room.maxPlayers})`);
        break;
      }

      case 'leave_room': {
        handleLeave(ws);
        break;
      }

      case 'set_ready': {
        if (!client) break;
        const room = rooms.get(client.roomId);
        if (!room) break;
        const info = room.players.get(ws);
        if (info) info.ready = msg.ready;
        broadcast(room, {
          type: 'player_ready',
          playerId: client.playerId,
          ready: msg.ready,
        });
        break;
      }

      case 'start_game': {
        if (!client) break;
        const room = rooms.get(client.roomId);
        if (!room || room.hostWs !== ws) break;
        room.state = 'playing';
        room.levelName = msg.levelName || room.levelName;
        broadcast(room, {
          type: 'game_start',
          levelName: room.levelName,
          hostId: client.playerId,
        });
        console.log(`[Room ${client.roomId}] Game started: ${room.levelName}`);
        break;
      }

      // ── 游戏中实时同步 ────────────────────────────────────
      // 玩家位置/状态（高频，每帧或每0.1s）
      case 'player_state': {
        if (!client) break;
        const room = rooms.get(client.roomId);
        if (!room) break;
        // 直接转发给房间其他人，附上发送者ID
        broadcast(room, {
          type: 'player_state',
          playerId: client.playerId,
          pos: msg.pos,           // {x, y}
          pressure: msg.pressure,
          holdItem: msg.holdItem, // 持有物品名
          face: msg.face,         // 朝向
          state: msg.state,       // 动画状态
        }, ws);
        break;
      }

      // 游戏事件（低频，触发式）
      case 'game_event': {
        if (!client) break;
        const room = rooms.get(client.roomId);
        if (!room) break;
        // 记录 p2p_relay 事件用于调试
        if (msg.event === 'p2p_relay') {
          console.log(`[Room ${client.roomId}] p2p_relay from player ${client.playerId}, target=${msg.data && msg.data.target}, b64_len=${msg.data && msg.data.b64 && msg.data.b64.length}`);
        }
        // 转发给所有人（包括自己，用于确认）
        broadcast(room, {
          type: 'game_event',
          playerId: client.playerId,
          event: msg.event,   // 事件名
          data: msg.data,     // 事件数据
        }, ws);
        break;
      }

      // 主机同步权威状态（订单、金钱、天数等）
      case 'host_sync': {
        if (!client) break;
        const room = rooms.get(client.roomId);
        if (!room || room.hostWs !== ws) break;
        broadcast(room, {
          type: 'host_sync',
          data: msg.data,
        }, ws);
        break;
      }

      // 聊天/表情
      case 'chat': {
        if (!client) break;
        const room = rooms.get(client.roomId);
        if (!room) break;
        broadcast(room, {
          type: 'chat',
          playerId: client.playerId,
          playerName: client.playerName,
          text: msg.text,
        }, ws);
        break;
      }

      default:
        break;
    }
  });

  ws.on('close', () => {
    handleLeave(ws);
    clients.delete(ws);
    console.log('[-] Client disconnected');
  });

  ws.on('error', (err) => {
    console.error('[!] WS error:', err.message);
  });
});

function handleLeave(ws) {
  const client = clients.get(ws);
  if (!client) return;
  const room = rooms.get(client.roomId);
  if (!room) return;

  room.players.delete(ws);
  broadcast(room, {
    type: 'player_left',
    playerId: client.playerId,
    playerName: client.playerName,
  });

  if (room.players.size === 0) {
    rooms.delete(client.roomId);
    console.log(`[Room ${client.roomId}] Closed (empty)`);
  } else if (room.hostWs === ws) {
    // 转移房主给第一个剩余玩家
    const [newHostWs, newHostInfo] = room.players.entries().next().value;
    room.hostWs = newHostWs;
    room.hostName = newHostInfo.name;
    broadcast(room, {
      type: 'host_changed',
      newHostId: newHostInfo.id,
    });
    console.log(`[Room ${client.roomId}] Host transferred to ${newHostInfo.name}`);
  }
}

console.log(`Feed The Cups relay server running on ws://0.0.0.0:${PORT}`);

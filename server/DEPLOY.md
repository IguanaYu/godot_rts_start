# RTS 多人联机服务器部署手册

## 1. 服务器文件位置

文件在 worktree 目录下：
```
E:\godot\rts\godot_rts_start\.claude\worktrees\lockstep-multiplayer\server\
  ├── package.json
  ├── index.js
  └── room_manager.js
```

**注意**：`.claude\worktrees\` 是隐藏目录，文件管理器需要开启"显示隐藏项目"才能看到。

## 2. 服务器要求

- 操作系统：Linux（Ubuntu/CentOS 均可）
- Node.js >= 18.x
- 开放端口：**8080**（TCP，防火墙 + 安全组都要放行）

## 3. 上传并部署

### 3.1 打包 server 目录

在本地 Windows 上，把 `server/` 目录打成压缩包上传：
```
E:\godot\rts\godot_rts_start\.claude\worktrees\lockstep-multiplayer\server\
```

### 3.2 上传到服务器

用你习惯的方式（scp / WinSCP / Xshell 等）上传到服务器，例如放到 `/home/your-user/rts-server/`。

### 3.3 安装依赖并启动

```bash
cd /home/your-user/rts-server/
npm install
node index.js
```

看到 `RTS Relay Server running on ws://0.0.0.0:8080` 就说明启动成功。

### 3.4 后台运行（推荐 pm2）

```bash
npm install -g pm2
pm2 start index.js --name rts-relay
pm2 save
pm2 startup          # 设置开机自启（按提示执行输出的命令）
```

pm2 常用命令：
```bash
pm2 status           # 查看状态
pm2 logs rts-relay   # 查看日志
pm2 restart rts-relay
pm2 stop rts-relay
```

## 4. 验证服务器

在本地 Windows 终端用 wscat 测试：

```bash
# 安装 wscat（只需一次）
npm install -g wscat

# 连接测试
wscat -c ws://111.229.19.23:8080
> {"type":"list_rooms"}
# 应收到：{"type":"room_list","payload":{"rooms":[]}}

> {"type":"create_room","payload":{"name":"test"}}
# 应收到：{"type":"room_created","payload":{"code":"XXXXXX","name":"test","map":"map_1"}}

> {"type":"list_rooms"}
# 应看到刚才创建的房间

# Ctrl+C 退出
```

## 5. Godot 客户端连接

客户端地址已配置在 `relay_manager.gd` 中：
```gdscript
const SERVER_URL := "ws://111.229.19.23:8080"
```

启动 Godot 游戏 → 主菜单 → 多人联机 → 自动连接服务器 → 进入房间浏览器。

## 6. 检查清单

- [ ] 服务器 8080 端口已开放（云防火墙 + 系统防火墙）
- [ ] `node index.js` 启动无报错
- [ ] `wscat` 能连接并收发消息
- [ ] Godot 客户端能连上服务器

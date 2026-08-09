# CLAUDE.md UI 硬规则模板（addon 内参考，复制到目标项目 CLAUDE.md 末尾）

## UI 编辑硬规则（必读）

AI 改 UI 时最常犯的错：按钮加到屏幕外、内容超出容器、点击穿透、装饰节点互相重叠。下面规则 + UI Safety addon 双保险。

### 改任何 Control 之前必须先报告

新增/修改 Control 节点前，在响应里写明：
- 父节点当前 rect（位置 + 尺寸）
- 目标节点预计 rect（含位置 + 尺寸）
- 是否越出 {{VIEWPORT_W}}×{{VIEWPORT_H}} viewport（明确说 yes/no + 越出多少像素）
- 父容器剩余可用空间

### 容器优先（避免裸 Control + position）

- 默认用 VBox / HBox / Scroll / Margin / Grid Container
- 裸 Control + position 只用于固定单个浮窗
- "内容可能多"的场景**必须**用 ScrollContainer

### spacing / 尺寸规范

- spacing 必须是 4 或 8 的倍数
- 字号 13/14/16/18/22 之一，不要写中间值

### 提交前必须跑校验

改 UI 代码后，PostToolUse hook 会自动跑：
```
godot --headless --script res://addons/ui_safety/runtime/run_bounds_check_cli.gd
```
有 issue 时 hook 会把 stderr 塞回来，必须修复或加入白名单才能继续。

### 运行时调试（F3/F4/F5）

跑 game 后按热键：
- **F3** Outline：所有 Control 描边（绿=OK / 红=越界 / 黄=重叠 / 蓝=size 不足）
- **F4** Pick：鼠标悬停查点击链（专查点击穿透）
- **F5** Stats：控制台列出所有 issue

详见 [addons/ui_safety/README.md](addons/ui_safety/README.md) 与 [docs/reference/ui_specs.md](docs/reference/ui_specs.md)。

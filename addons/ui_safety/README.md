# UI Safety

跨项目通用的 Godot 4 addon，专门解决"AI 写 UI 时按钮加到屏幕外、同级重叠、点击穿透"等低级问题。

## 解决什么问题

AI 写 UI 时是按"结构/语义"摆节点的，它不知道视口像素、容器累积高度、HUD 占位。结果就是按钮加到屏幕外、透明 ColorRect 抢了按钮的点击、同级 Control 互相重叠。

CLAUDE.md 单独写规则无效（Anthropic 官方说 "advisory not enforcement"），必须配可执行的工具做强制。

## 功能（三层 + 一个 hook）

| 层 | 功能 | 热键/CLI |
|---|---|---|
| **L1 规则** | CLAUDE.md 加 UI 编辑硬规则 + 项目 ui_specs.md | （文档） |
| **L2 运行时校验** | 所有 Control 边界可视化、Pick 鼠标下的节点链、列出所有越界/重叠 issue | **F3** Outline / **F4** Pick / **F5** Stats |
| **L4 headless 校验** | CLI 跑 game 后扫一遍 UI 树，把 issue 报告给 Claude Code hook | `godot --headless --script res://addons/ui_safety/runtime/run_bounds_check_cli.gd` |
| **PostToolUse hook** | Claude 改完 UI 文件自动跑 L4，issue 报告塞回给 Claude 逼它修复 | `.claude/hooks/ui_bounds_check.sh` |

L3 截图回归（screenshot_compare）暂未实现，留作后续扩展。

## 安装

### 方式 A：手动复制（任何 Godot 4 项目）

1. 复制 `addons/ui_safety/` 到你的项目根
2. 编辑器打开 Project → Project Settings → Plugins，勾选 "UI Safety"
3. 启用后会自动注册 `UIBoundsValidator` autoload

### 方式 B：用 Claude Code Skill（推荐）

如果你用 Claude Code，跑 `/ui-safety-setup`，skill 会自动：
- 复制 addon + 启用插件
- 生成项目特定的 `docs/reference/ui_specs.md`（含 viewport 尺寸、已知 issue）
- 写 `.claude/hooks/ui_bounds_check.sh`（替换 GODOT 路径和项目路径）
- 改 `.claude/settings.local.json` 加 PostToolUse hook
- 在 `CLAUDE.md` 末尾追加 UI 硬规则章节

## 使用

跑 game 后按热键：

- **F3** Outline 模式：所有 Control 描边
  - 绿色 = 正常
  - 红色 = 越界（出 viewport）
  - 黄色 = 同级重叠
  - 蓝色 = size 不足（小于 minimum_size）
  - 灰色 = 在 ScrollContainer 内（已剪裁，不报）
- **F4** Pick 模式：鼠标悬停任意 Control，屏幕右上角显示该节点的完整 path + rect + mouse_filter + visible 链。专查"点击被谁拦截"
- **F5** Stats 模式：控制台 push_warning 列出所有 issue，屏幕左下角显示统计

ESC 关闭所有模式。

## 校验逻辑

`validate_all()` 跨所有 CanvasLayer 递归遍历 Control，检测：

- **OUT_OF_BOUNDS**：rect 越出 viewport（容差 0.5px）
- **OVERLAP**：同级 Control 重叠（不含 MarginContainer / 装饰组）
- **SIZE_TOO_SMALL**：size 小于 combined_minimum_size

### 白名单（避免误报）

1. **MarginContainer**：故意让子重叠 margin 区，跳过 OVERLAP
2. **装饰组 wrapper**：父节点含 Button 或 NinePatchRect 子节点 → 它的孩子们（ButtonBG + TextureRect + Label + Button + CostLabel）故意叠在同区域
3. **OOB 祖先去重**：父节点已 OOB → 子节点必然 OOB，只报父一次
4. **ScrollContainer 内**：clip_contents=true 的 ScrollContainer 内的子节点不查越界（已剪裁）
5. **完全 contain**：一个 sib 完全 contain 另一个 sib → 不算 OVERLAP（装饰层叠）

## 给 hook / CI 用

```bash
# 直接跑校验
godot --headless --path <PROJECT> --script res://addons/ui_safety/runtime/run_bounds_check_cli.gd

# 退出码：
#   0 = 无 issue
#   1 = 有 issue（stderr/stdout 输出详情）
#   2 = 加载/初始化失败
```

支持参数：
- `-- scene foo.tscn`：指定场景（默认 res://scenes/main.tscn）

## 配套：CLAUDE.md UI 硬规则

光靠工具不够，CLAUDE.md 也要写明规则让 AI 提前思考。推荐规则（已模板化到 `templates/CLAUDE_md_ui_rules.md`）：

- 新增/修改 Control 前必须先报告：父节点 rect + 目标 rect + 是否越出 viewport
- 默认用 Container（VBox/HBox/Scroll/Margin/Grid），裸 Control + position 只用于固定单个浮窗
- spacing 必须是 4 或 8 的倍数
- 详情面板内容多时必须用 ScrollContainer

## 设计来源

详见调研报告：`docs/reference/research/AI写UI安全_越界检测与视觉反馈调研.md`

借鉴业界成熟方案：
- Flutter `debugPaintSizeEnabled`（所有 Control 边界可视化）→ 我们的 F3
- Unreal Widget Reflector Pick Hit-Testable（专查点击穿透）→ 我们的 F4
- LinkedIn LayoutTest-iOS（递归几何校验，零 flaky）→ 我们的核心校验逻辑

## 跨项目复用

本 addon 设计为通用工具，可搬到任何 Godot 4 项目。打包发布流程：

1. 把 `addons/ui_safety/` 单独提取到独立 Git repo
2. 通过 git submodule 或直接复制引入目标项目
3. 可选：发布到 [Godot Asset Library](https://godotengine.org/asset-library/)

## License

MIT

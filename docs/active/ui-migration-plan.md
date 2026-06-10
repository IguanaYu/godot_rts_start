# HTML UI 原型迁移计划

> 将 `docs/ui-redesign-prototype.html` 的 UI 设计逐 Task 迁移到 Godot GDScript。  
> 保留所有现有贴图/纹理/动画，只改布局和新增元素。

---

## 总体进度

| Task | 内容 | 状态 |
|------|------|------|
| 1 | 主菜单 | pending |
| 2 | 存档选择 | done |
| 3 | 关卡选择 | pending |
| 4 | 游戏 HUD | pending |
| 5 | 暂停菜单 | pending |
| 6 | 设置页 | pending |
| 7 | 升级卡牌 | pending |

---

## 通用注意事项

- **变量名唯一性**: GDScript 不允许同函数内重复声明变量名，注意 `StyleBoxFlat` / `StyleBoxEmpty` 等命名
- **translations.csv**: 只用 ASCII 字符，避免 `·` 等特殊符号
- **九宫格贴图**: NinePatchRect 使用 `PRESET_FULL_RECT` 填充 wrapper，不要手动设 `custom_minimum_size`
- **HBoxContainer 子节点**: 需要 `SIZE_EXPAND_FILL` 水平方向才能等分宽度
- **测试方式**: `"E:\godot\Godot_v4.6.1-stable_win64.exe" --path "F:\godot_game\rts_base\rts-base"`

---

## Task 1: 主菜单 — `scripts/ui/main_menu.gd`

**目标**: 添加副标题、版本号、语言切换改为按钮组

**改动点**:
- `_create_title()`（第 119 行）后：添加副标题 Label（"A Medieval RTS Adventure"），字号 18，灰色
- `_create_buttons()`（第 140 行）：`anchor_top` 0.35→0.38，`anchor_bottom` 0.70→0.72
- `_create_language_option()`（第 197 行）：OptionButton → 3 个 Button 横排，当前语言金色高亮
- 新增版本号 Label 右下角，字号 12，深灰色
- **注意**: 按钮尺寸不要改（60px 高度保持原样），贴图依赖该尺寸

**新增翻译 Key**:
```
MAIN_MENU_SUBTITLE,A Medieval RTS Adventure,中世纪RTS冒险,中世紀RTS冒険
```

---

## Task 2: 存档选择 — `scripts/ui/save_select.gd` ✅

**目标**: 纵向排列改为横向 3 张卡片，每张包含缩略图、进度条、虚线空边框

**已完成改动**:
- VBoxContainer → HBoxContainer 横向布局
- 新增 ColorRect 缩略图占位（80px 高）
- 新增 ProgressBar（绿色填充）
- 新增空存档虚线边框 + 深色半透明背景
- 新增 `SAVE_META` 翻译 key
- 按钮尺寸调整：enter 120x36, del 70x32

---

## Task 3: 关卡选择 — `scripts/ui/level_select.gd`

**目标**: 模式切换移到标题区域 + 星级难度

**改动点**:
- 布局比例：第 303 行 0.35→0.38，第 391 行 0.65→0.62
- **模式切换**：从右侧面板移到标题区域（`_create_banner()` 第 263 行）
  - 标题右侧加 "Campaign | Test Levels" 两个 tab 按钮
  - 点击切换 `_is_test_mode`，调用 `_rebuild_left_panel()`
- `_create_difficulty_selector()`（第 581 行）：3 个文字 Button → 星级按钮（★）
- `_create_level_button()`（第 339 行）：添加关卡图标 TextureRect

---

## Task 4: 游戏 HUD — `scripts/systems/game_ui.gd`

**目标**: 资源栏面板化、建造面板宽度调整、波次进度条、小地图、选择信息面板

### 4a. 资源栏包裹（第 282-398 行）
- 金币 Label + 升级币 + FPS 外包深色半透明面板（ColorRect bg）
- 修复 FPS 和升级币位置重叠

### 4b. 建造面板宽度
- `anchor_left` 0.1→0.2, `anchor_right` 0.9→0.8
- separation 16→10, 按钮大小 80→72

### 4c. 波次倒计时进度条（第 355 行后）
- 添加 ProgressBar（宽 200px，高 4px，红色填充）
- 最后 5 秒文字脉冲动画

### 4d. 选择信息面板（第 372 行）
- Label 外包 PanelContainer + StyleBoxFlat 深色背景

### 4e. 小地图占位（`_create_ui` 末尾）
- 右下角 180x180 Control + WoodTable 背景 + "Minimap" 文字

### 4f. 目标面板
- 已有 `_create_objectives_panel()`（第 1354 行），确认和 HTML 原型对齐

### 4g. 技能栏面板 — `scripts/commander_skill/commander_skill_panel.gd`
- `_create_panel()`：main_container 外包深色半透明面板，能量条+技能按钮统一底板

---

## Task 5: 暂停菜单 — `scripts/systems/game_ui.gd` 第 836 行

**目标**: 面板顶部 Banner + 按钮分组

**改动点**:
- 面板顶部加 Banner 装饰（ColorRect 金棕色 + 标题）
- 按钮分 GAME / SYSTEM 两组，中间加分隔线

**新增翻译 Key**:
```
PAUSE_GROUP_GAME,GAME,游戏,ゲーム
PAUSE_GROUP_SYSTEM,SYSTEM,系统,システム
```

---

## Task 6: 设置页 — `scripts/systems/game_ui.gd` 第 1024 行

**目标**: 滚动列表改为标签页

**改动点**:
- `_open_settings_page()` 改为标签页（Display/Audio/Gameplay/Language）
- 顶部标签行 + 4 个 VBoxContainer 内容区切换

---

## Task 7: 升级卡牌 — `scripts/upgrade/upgrade_panel.gd`

**目标**: 卡片加大 + 稀有度边框 + hover 效果

**改动点**:
- 卡片尺寸 150x200 → 200x280
- 稀有度边框：3px 彩色 StyleBoxFlat（银/金/钻石蓝）
- 描述字号 13→14
- hover 上浮效果：Tween position.y -8

---

## 验证

每个 Task 完成后：
1. 启动 Godot 检查布局
2. 测试交互（按钮、切换、hover）
3. 测试多语言
4. 测试不同分辨率

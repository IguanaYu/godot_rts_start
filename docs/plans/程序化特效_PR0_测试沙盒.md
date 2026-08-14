# PR-0：测试沙盒场景（极简版）

> **目标**：搭一个独立场景，能 spawn 单位互打、看 HP/伤害飘字、控制时间。后续所有 PR 在这里验证。
>
> **范围**：极简版。MVP 四件事：spawn 单位 + 时间控制 + 选中详情 + 重置。
>
> **关联**：[ROADMAP](程序化特效落地_ROADMAP.md) | [总方案](../design/程序化特效落地总方案.md)

---

## 1. 现状盘点

### 已有可复用资源

| 资源 | 位置 | 复用价值 |
|---|---|---|
| `stress_test_spawner.gd` | scripts/systems/ | @tool + 参数化批量 spawn，**核心 spawn 逻辑可直接借鉴** |
| `detail_panel.gd` | scripts/ui/ | 选中单位详情面板（HP/DMG/CD/状态），**直接实例化复用** |
| `floating_text.gd` | scripts/effects/ | 伤害飘字，CanvasLayer 15，**直接复用** |
| `unit.tscn` + 所有单位场景 | scenes/units/ | **直接 spawn**，无需新建 |
| map_1 tileset | scenes/maps/ | **复用地形** |

### 现有"测试场景"对比

- **`stress_test.tscn`**：性能向，启动自动批量 spawn 方阵，跑完即停。不适合手动验证视觉。
- **正式关卡 `map_1.tscn`**：完整游戏流程，验证视觉太重（要等建造/升本/解锁）。
- **结论**：需要一个**新的、轻量的、手动驱动的**测试场景。

---

## 2. 决策点

### 决策点 1：沙盒如何接入项目？

**方案 A**：独立场景，编辑器 F6 直接运行（不进 main.gd 启动流程）
- ✅ 启动快、隔离干净、不影响正式游戏
- ✅ 不需要改 main.gd
- ❌ 需要重新搭基础（地图、单位管理、UI 层级）

**方案 B**：在 main.gd 里加"沙盒模式"开关，启动时选正式/沙盒
- ✅ 复用 main.gd 的所有基础设施（unit_grid、combat_controller、selection_system 等）
- ❌ 改动侵入大，可能影响正式游戏
- ❌ 启动慢

**方案 C**：基于 `map_1.tscn` 改造，去掉建造/产金逻辑保留战斗
- ✅ 复用现有场景结构
- ❌ 改造工作量比新建还大

**💡 我的建议**：**方案 A**。沙盒是开发工具不是游戏内容，独立场景最干净。缺失的基础设施（unit_grid 等）按需引入。

---

### 决策点 2：时间控制怎么实现？

**方案 A**：`Engine.time_scale = 0.5 / 1.0 / 2.0`
- ✅ 一行代码，所有 _process/_physics_process/Tween 自动跟随
- ✅ 已有的 Timer 也会跟随（如果 `process_callback = TIMER_PROCESS_PHYSICS`）
- ❌ UI 也会被影响（要在 CanvasLayer 里反向 scale）

**方案 B**：自定义 tick 系统，每个单位自己读 time_scale
- ✅ 精确控制（UI 不受影响）
- ❌ 需要改所有单位/建筑的 process 逻辑
- ❌ 工作量爆炸

**方案 C**：暂停 `get_tree().paused` + `process_mode` 控制
- ✅ 暂停功能好用
- ❌ 慢放/快放做不到

**💡 我的建议**：**方案 A** + 给 UI 节点设 `process_mode = PROCESS_MODE_ALWAYS`。暂停用 `paused`，慢放/快放用 `time_scale`。UI 用 ALWAYS 模式不受影响。

---

### 决策点 3：spawn 单位的交互方式？

**方案 A**：左面板选单位 → 点击战场在该位置放 1 个
- ✅ 简单直观
- ❌ 放 50 个单位要点 50 次

**方案 B**：左面板选单位 → 拖拽画方阵批量放（复用 stress_test_spawner 逻辑）
- ✅ 适合大规模测试
- ❌ 拖拽逻辑要新写

**方案 C**：左面板选单位 + 数量滑条 → 点击战场一次放 N 个方阵
- ✅ 兼顾简单和批量
- ✅ 数量可控

**💡 我的建议**：**方案 C**。左面板加个数量选择（1/5/10/20），点击战场按方阵 spawn。复用 stress_test_spawner 的方阵计算逻辑。

---

### 决策点 4：木桩怎么做？

**方案 A**：新建专用木桩场景 `dummy.tscn`（静态贴图 + 高 HP + 无攻击）
- ✅ 干净，可定制不同 HP/护甲/类型
- ❌ 新建资源

**方案 B**：复用现有单位（比如剑士），关掉 AI 和攻击，改 HP
- ✅ 不用新建
- ❌ 单位会跑掉/还击，不像木桩

**方案 C**：用建筑当木桩（城墙/农场）
- ✅ 静态，已有 HP
- ❌ 攻击建筑会触发警戒逻辑，且建筑 HP 太高

**💡 我的建议**：**方案 A**。新建一个 `dummy.tscn`，用现有石头/箱子贴图，HP 可配置（500/2000/5000 三档）。未来还能用作"伤害数值验证靶"。

---

### 决策点 5：选中详情面板怎么挂？

**方案 A**：直接实例化 `detail_panel.tscn`，传入选中单位
- ✅ 复用现成代码
- ❌ detail_panel 可能依赖 main.gd 的某些上下文（需验证）

**方案 B**：新写一个简化版 `sandbox_detail_panel.gd`（只显示 HP/DMG/状态）
- ✅ 不依赖现有代码
- ❌ 重复造轮子

**💡 我的建议**：**先试方案 A**。读一下 `detail_panel.gd` 看依赖，如果只读 unit 实例的属性就直接用；如果依赖 main.gd 的方法（比如 `get_selected_units()`）就走方案 B。

---

### 决策点 6：沙盒里需不需要 F5（aggro 可视化）等 Debug 开关？

**方案 A**：极简版先不做，PR-3/4/5 时按需加
- ✅ MVP 最快交付
- ❌ 后续 PR 验证时可能不方便

**方案 B**：PR-0 就把 F5/F6 Debug 开关做齐
- ✅ 一次到位
- ❌ 偏离"极简"原则

**💡 我的建议**：**方案 A**。PR-0 只做核心四件事。Debug 开关放到对应 PR 里（比如 F5 aggro 可视化在 PR-3 UnitVisualFeedback 里加，因为那时才有"地面环绘制"的基础）。

---

## 3. 我的建议总结

| 决策点 | 建议方案 | 理由 |
|---|---|---|
| 沙盒接入 | A（独立场景 F6 运行）| 开发工具，隔离干净 |
| 时间控制 | A（Engine.time_scale + paused）| 一行代码搞定 |
| spawn 交互 | C（选单位 + 数量 + 点击方阵）| 兼顾简单和批量 |
| 木桩 | A（新建 dummy.tscn）| 干净可控 |
| 详情面板 | 先试 A（复用 detail_panel）| 避免重复造轮子 |
| Debug 开关 | A（PR-0 不做）| 极简，按需后加 |

---

## 4. 接入点 / 涉及文件

### 新增文件

```
scenes/sandbox/
├─ effect_sandbox.tscn          # 沙盒主场景
└─ dummy.tscn                   # 木桩（HP 可配置）

scripts/sandbox/
├─ sandbox_controller.gd        # 沙盒主控（spawn/重置/时间控制）
└─ sandbox_config.gd            # 可放置单位清单（const 数组）
```

### 修改文件

无（沙盒是独立的，不动现有代码）。

### 复用但不修改

- [scripts/systems/stress_test_spawner.gd](../../scripts/systems/stress_test_spawner.gd) — 借鉴方阵 spawn 逻辑
- [scripts/ui/detail_panel.gd](../../scripts/ui/detail_panel.gd) — 直接实例化
- [scripts/effects/floating_text.gd](../../scripts/effects/floating_text.gd) — 自动工作
- [scenes/units/*.tscn](../../scenes/units/) — 直接 spawn

---

## 5. 验证标准

PR-0 完成后，在沙盒里能：

- [ ] F6 启动沙盒，看到 30×30 小地图 + 左面板（单位按钮）+ 顶栏（时间控制）+ 右面板（详情）
- [ ] 点击左面板"剑士" + 数量 5 + 点击战场，spawn 5 个剑士方阵
- [ ] 同样方式 spawn 5 个敌方火法师，双方自动开打
- [ ] 点击单位，右面板显示 HP/DMG/CD
- [ ] 顶栏点"0.5x"，全场慢放
- [ ] 顶栏点"暂停"，全场冻结
- [ ] 顶栏点"重置"，所有 spawn 单位清空
- [ ] 伤害飘字正常显示（复用 floating_text）
- [ ] spawn 木桩（HP 500），剑士打它，能看到伤害数值

---

## 6. 配置说明（用户怎么用）

### 添加新单位到沙盒

编辑 `scripts/sandbox/sandbox_config.gd`：

```gdscript
extends Node

const SPAWNABLE_UNITS := [
    { "scene": preload("res://scenes/units/soldier.tscn"), "name": "剑士", "faction": "player" },
    { "scene": preload("res://scenes/units/archer.tscn"), "name": "弓兵", "faction": "player" },
    { "scene": preload("res://scenes/units/pyromancer.tscn"), "name": "火焰法师", "faction": "enemy" },
    # 加一行就出一个按钮
]

const SPAWNABLE_DUMMIES := [
    { "scene": preload("res://scenes/sandbox/dummy.tscn"), "name": "木桩 HP500", "hp": 500 },
    { "scene": preload("res://scenes/sandbox/dummy.tscn"), "name": "木桩 HP2000", "hp": 2000 },
]
```

左面板会自动按这个清单生成按钮，不需要手动搭 UI。

### 启动方式

Godot 编辑器 → 打开 `scenes/sandbox/effect_sandbox.tscn` → 按 **F6**（运行当前场景）。

不接入 main.gd 启动流程。

---

## 7. 已知风险

| 风险 | 缓解 |
|---|---|
| `detail_panel.gd` 可能依赖 main.gd 上下文 | 先读代码验证；不行就走方案 B 新写简化版 |
| 敌方单位 spawn 后没有 EnemyAI 不还击 | 参考 stress_test_spawner.gd:58-62，spawn 后手动加 EnemyAI 节点 |
| `Engine.time_scale` 可能影响 Tween | 验证一下 hit_flash Tween 等是否跟随（应该是跟随的）|
| 沙盒里 spawn 的单位死了不触发 main.gd 的 `_on_unit_died` | 沙盒自己挂 `died` 信号，不依赖 main.gd |

---

## 8. 后续 PR 衔接

PR-0 完成后，后续 PR 在沙盒里验证的方式：

| PR | 沙盒验证 |
|---|---|
| PR-1 shader 接入 | spawn 单位互打 → 看受击白闪、死亡 dissolve |
| PR-2 粒子池 | spawn 50 单位互打 → 看是否卡顿 |
| PR-3 单位视觉 | spawn 单位 → 看脚下状态环、攻击冲量 |
| PR-4 建筑视觉 | 沙盒需扩展加建筑 spawn 入口（PR-4 时加）|
| PR-5 命中粒子 + 后处理 | spawn 单位互打 → 看命中火花、屏幕冲击波 |
| PR-6 技能视觉 | 沙盒需扩展加技能释放按钮（PR-6 时加）|

PR-4 和 PR-6 需要扩展沙盒，到时候再补对应入口。

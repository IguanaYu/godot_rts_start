# 代码架构

> 改代码前读本文定位模块。Godot 4.6 / GDScript / 2D。
> 这是活文档：目录职责是探索起点，读懂某模块后回来补充细节。

## 总体形态

- 单场景入口 `scenes/main.tscn` + `scripts/main.gd`（约 2100 行）做游戏主控：导航烘焙、建筑放置、队形、网格（GRID_SIZE=64）
- 数据驱动：单位属性走 `UnitStats` 资源（resources/），地图走 map_config，关卡/胜负条件走配置
- 项目规则：功能性脚本必须被场景引用（挂节点/@export/.tres/autoload），不靠 class_name 全局可用；不需要编辑器类型名就不加 class_name，用 preload + duck typing

## scripts/ 目录地图

| 目录 | 文件数 | 职责（推断处标注 ?） |
|------|------|------|
| `main.gd` | 1 | 游戏主控：导航网格烘焙、建筑放置、队形、游戏时间 |
| `units/` | 6 | **单位**：unit.gd（约 1900 行核心）、enemy_ai、ally_ai、boss_ai、大战术释放者 AI |
| `buildings/` | 2 | 建筑：building.gd、building_garrison（驻军） |
| `core/` | 5 | 通用组件：health/aggro/shadow 组件、帧动画特效、单位空间网格（性能） |
| `effects/` | 22 | 视觉特效：jelly_effect（果冻受击）等程序化特效 + 粒子/配方库（PR 系列在扩展） |
| `victory/` | 27 | 15 种胜负条件实现（摧毁基地/生存/护送/暗杀/守卫…） |
| `ui/` | 26 | UI：底部栏、详情面板、小地图、跳字等 |
| `systems/` | 14 | 系统：building_placer（放置+解锁联动）、game_ui 等 |
| `systems_game/` | 10 | 玩法系统：wave_manager（波次）等 |
| `outpost/` | 8 | 据点：CapturePoint、outpost_commander（据点指挥官） |
| `commander/` + `commander_skill/` | 16 | 指挥官与指挥官技能（法术释放、状态面板） |
| `skills/` + `tactics/` + `upgrade/` | 12 | 单位技能、战术、升级（兵种全局升级 7 节点） |
| `stats/` | 6 | 数值定义（UnitStats 等） |
| `tech/` | 2 | 科技点/时代 |
| `network/` | 7 | 联机（优先级低） |
| `autoload/` | 2 | balance_scheme（平衡方案）、load_router（加载路由） |
| `environment/` | 3 | 环境/地形装饰（terrain_layer、terrain_obstacle 在根级） |
| `resources/` | 5 | 资源相关脚本（? 与 stats/resources 区分待确认） |
| `faction.gd` / `difficulty*.gd` / `map_config.gd` | 根级 | 势力、难度、地图配置 |

其他根目录：`scenes/`（场景）、`resources/`（.tres 配置数据）、`shaders/`、`locales/`（翻译）、`tests/`、`addons/`（ui_safety 截图回归）、`server/`（联机服务端？待确认）。

## 关键机制（写代码时的共识）

- **统一游戏时间**：所有计时器/cooldown 共用 `main._game_time`，禁止 `Time.get_ticks_msec()`（暂停/倍速才正确）
- **单位移动**：NavigationAgent2D（radius=16），`move_to()` → `_move_process()` → `move_and_slide()`；寻路问题历史方案见 memory/archived
- **导航烘焙**：建筑放置/拆除后 main.gd `_rebuild_navigation()` 重建导航网格
- **远程攻击**：箭矢走 ProjectileData/效果类（Splash/Slow），曾只在箭塔接线，单位侧接入情况看最新代码
- **手写 .tscn 教训**：非根节点必须 `parent="."`，否则静默不加载
- **UI 安全**：addons/ui_safety 提供 L3 截图回归 + L4 headless 校验，规格见 reference/ui_specs.md

## 配置入口（非程序员改游戏内容的地方）

- 全局配置 → manual/game-config-manual.md
- 地图/关卡 → manual/地图配置指南.md、多人地图配置手册.md
- 技能效果 → manual/skill_effects_reference.md
- 新增单位 → standards/单位设计公式化指南.md（数值）+ plans/单位实施路线图_按代码改动分层.md（零代码/改代码边界）

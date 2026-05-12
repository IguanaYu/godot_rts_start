# RTS 游戏 UI 与功能完善计划

## 概述
共8项任务，除第8项（选关界面）需要先设计方案外，其余7项可直接执行。

---

## 1. 空格键回到基地 [可直接执行]
- 修改 `scripts/main.gd`：`_input()` 添加 `KEY_SPACE` 分支
- 遍历 `player_buildings` 找 Castle，设置 `camera.position`
- 城堡被摧毁则回退到第一个玩家建筑

## 2. 右键/A键点击特效 [可直接执行]
- 新建 `scripts/click_effect.gd`
- 移动指示：用 `assets/.../Cursors/Cursor_01.png`，放大+淡出
- 攻击指示：用 `assets/.../Swords/Swords.png` 红色剑，弹出+旋转
- 素材已在项目中

## 3. 近战兵打不到人修复 [可直接执行]
- 修改 `scripts/unit.gd`
- 边缘瞄准方案：新增 `_get_nearest_building_edge()` 函数
- 用 `unit_pos.clamp(building_rect.position, building_rect.end)` 找最近边缘点
- 导航目标从建筑中心改为最近边缘，距离也改为到边缘距离
- 不改建筑碰撞和导航 margin

## 4. 波次倒计时 [可直接执行]
- 修改 `scripts/wave_manager.gd`：添加 `countdown_updated(wave_number, remaining, total_waves)` 信号，在 `_process()` 中每帧发射
- 修改 `scripts/main.gd`：
  - 新增 `wave_countdown_label` 变量（居中红色 Label，在建筑按钮栏下方）
  - 修改 `_setup_wave_manager()` 连接 `countdown_updated` 和 `all_waves_completed` 信号
  - `_on_countdown_updated()`：显示 "Wave X/Y incoming in: Zs"，最后5秒变亮红
  - `_on_all_waves_completed()`：隐藏倒计时
- 箭头功能待后续设计

## 5. 漂浮奖励数字 [可直接执行]
- 新建 `scripts/floating_text.gd`
- 修改 `scripts/main.gd`：添加 `show_floating_text()` 方法
- 修改 `scripts/capture_point.gd`：发奖励时调用
- 金币：黄色 "+200"，单位：绿色 "+5 弓箭手"

## 6. 事件控制台/日志 [可直接执行]
- 修改 `scripts/main.gd`：添加可折叠面板 + `log_event()` 方法
- 记录：波次、占领、奖励、建筑摧毁、单位建造

## 7. 召唤/回血特效 [可直接执行]
- 需要先复制素材到 `assets/effects/`：
  - `Dust_01.png`、`Dust_02.png`（Particle FX 文件夹）
  - `Heal_Effect.png`（Blue Units/Monk/ 文件夹）
- 新建 `dust_effect.gd`、`heal_effect.gd` 及对应 .tscn
- 参照 `explosion.tscn` 模式

---

## 8. 选关界面重设计 [需要先设计方案]
- 需要准备：4张地图预览截图
- 布局思路：左侧关卡列表 + 右侧预览面板（图+描述）
- 具体配色和样式待设计

---

## 素材清单（已在项目中，需复制）
| 素材 | 当前位置 | 用途 |
|------|---------|------|
| Cursor_01.png | assets/.../Cursors/ | 移动点击特效 |
| Swords.png | assets/.../Swords/ | 攻击点击特效 |
| Dust_01.png | assets/.../Particle FX/ | 召唤特效 |
| Dust_02.png | assets/.../Particle FX/ | 召唤特效 |
| Heal_Effect.png | assets/.../Blue Units/Monk/ | 回血特效 |

## 需要手动准备
- 4张地图预览截图（用于选关界面）
- 选关界面UI设计方案
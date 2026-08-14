# PR-5：命中粒子 + 屏幕后处理

> **目标**：让战斗有"冲击感"。命中粒子落地 + 大招/爆炸有屏幕级冲击波和色差。
>
> **预期收益**：战斗从"数值对撞"变成"看得见的打击"。Boss 死亡、技能释放有电影感。
>
> **关联**：[ROADMAP](程序化特效落地_ROADMAP.md) | [总方案 2.4](../design/程序化特效落地总方案.md) | [调研报告 1.4/1.6](../design/程序化动画与特效调研报告.md)

---

## 1. 现状盘点

### 命中反馈现状

- `take_damage()` 触发 hit_flash（PR-1）+ 受击位移（PR-3）
- **缺失**：命中点的世界内粒子（火花/血雾）
- 远程命中（箭矢到目标）和近战命中视觉相同，**无区分**

### 屏幕级反馈现状

- **完全缺失**：无 screen shake、无冲击波、无色差
- Boss 死亡、建筑爆炸、技能释放**都没有屏幕级冲击**

### 关键代码位置

- [scripts/units/unit.gd:1173](../../scripts/units/unit.gd) `take_damage()` — 命中点已知
- [scripts/buildings/building.gd:929](../../scripts/buildings/building.gd) `die()` — 爆炸点已知
- PR-2 的 `ParticlePool.spawn("hit_spark", pos)` — 命中粒子入口

### 关键约束

- 屏幕后处理需要 CanvasLayer（layer 高于游戏内容，低于 UI）
- UI 在 CanvasLayer layer=10，所以后处理 CanvasLayer 用 layer=15-20 之间（注：跳字在 15，后处理可以用 12-14，避免遮 UI）
- 实际上后处理要在游戏内容之上，应该在 5-9 之间（游戏内容默认 layer 0）

---

## 2. 决策点

### 决策点 1：后处理 CanvasLayer 放哪个 layer？

**现状**：
- 游戏内容默认 layer=0
- 跳字 layer=15
- 底部 UI 条 layer=10

**方案 A**：后处理 layer=5（游戏内容之上，UI 之下）
- ✅ 不会盖住 UI
- ✅ 不会盖住跳字
- ❌ 可能盖住 aggro_line（如果在 layer 1-4）

**方案 B**：后处理 layer=20（最上层，盖住一切）
- ✅ 冲击感最强
- ❌ 色差会染 UI

**方案 C**：后处理 layer=9（紧贴 UI 下方）
- ✅ 不影响 UI
- ❌ 跳字在 15 会被冲击波遮住一瞬间（可接受）

**方案 D**：分两层——游戏层后处理（layer=5）+ UI 不受影响
- ✅ 最干净
- ❌ Godot CanvasLayer 后处理是全屏的，无法只作用游戏层

**💡 我的建议**：**方案 A**。后处理 layer=5。色差/冲击波只作用游戏内容，UI 和跳字不受影响。aggro_line 等如果在 layer 1-4 也合理（被后处理覆盖一瞬间是符合直觉的）。

---

### 决策点 2：冲击波 shader 怎么实现？

**方案 A**：全屏 ColorRect + SCREEN_TEXTURE 采样 + 径向偏移
- ✅ 标准做法
- ❌ SCREEN_TEXTURE 采样开销

**方案 B**：仅 ColorRect 透明 shader 画一个扩散环（不采 SCREEN_TEXTURE）
- ✅ 性能好
- ❌ 没有"扭曲背景"效果，只是画个圈

**方案 C**：方案 A + 多个冲击波同时
- ✅ 多个爆炸同时不失真
- ❌ shader 复杂

**💡 我的建议**：**方案 B 起步**。PR-5 先做"扩散环"（不扭曲背景），如果效果不够再升级到方案 A。理由：
1. 像素风扭曲效果不一定好看（像素会被拉糊）
2. 扩散环 + screen shake 已经足够有冲击感
3. 性能友好

---

### 决策点 3：screen shake 怎么实现？

**方案 A**：移动 Camera2D 位置（offset 抖动）
- ✅ 直接
- ❌ 影响 camera clamp 逻辑

**方案 B**：相机 offset 抖动 + 现有 clamp 兼容
- ✅ 兼容
- ❌ 要改 game_camera.gd

**方案 C**：后处理 shader 做全屏抖动（UV 偏移）
- ✅ 不动相机
- ❌ UI 也跟着抖（如果在同 CanvasLayer）

**方案 D**：方案 B + 抖动强度按事件分级（小伤=2px、大伤=5px、Boss 死=10px）
- ✅ 分级清晰
- ✅ 玩家疲劳度可控

**💡 我的建议**：**方案 D**。改 `game_camera.gd` 加一个 `shake(strength_px, duration)` API，内部用 offset 抖动 + 与 clamp 兼容（抖动期间临时放宽 clamp 范围）。强度按事件分级。

---

### 决策点 4：色差什么时候触发？

**方案 A**：每次受击都色差
- ✅ 反馈强
- ❌ 战斗密集时全屏色差，玩家晕

**方案 B**：只在"屏幕级事件"触发（Boss 死亡、技能释放、建筑爆炸）
- ✅ 稀缺，有冲击感
- ✅ 不晕

**方案 C**：按伤害量阈值（>50 伤害才色差）
- ✅ 数据驱动
- ❌ 普通单位暴击也可能 >50

**方案 D**：方案 B + 指挥官技能释放瞬间（PR-6 配合）
- ✅ 仪式感
- ✅ 频率可控

**💡 我的建议**：**方案 B + D**。色差只在"屏幕级事件"触发：Boss 死亡、建筑爆炸、指挥官技能释放。普通战斗不色差。

---

### 决策点 5：命中粒子如何区分近战/远程？

**现状**：take_damage 不区分

**方案 A**：take_damage 加 `is_ranged_hit: bool` 参数
- ✅ 清晰
- ❌ 改签名

**方案 B**：用 attacker 的 unit_type 判断（ARCHER = 远程）
- ✅ 不改签名
- ❌ 法师类（pyromancer）也算远程，要列全

**方案 C**：粒子统一用 hit_spark，不做区分
- ✅ 简单
- ❌ 远程命中视觉不够"飞过来的"

**方案 D**：方案 B + 远程粒子额外加方向性（朝飞行方向喷射）
- ✅ 视觉符合物理
- ❌ 粒子配置复杂

**💡 我的建议**：**方案 C 起步**。PR-5 先统一用 hit_spark，所有命中一致。如果玩家反馈"分不清谁打的"，PR-5 之后迭代加方向性。

---

### 决策点 6：暴击/Boss 伤害的加量粒子？

**现状**：所有命中视觉相同

**方案 A**：take_damage 加 `is_critical: bool` 参数，暴击触发大号粒子 + screen shake
- ✅ 暴击有冲击感
- ❌ 改签名

**方案 B**：按伤害量分级（< 20 = 小、20-50 = 中、> 50 = 大）
- ✅ 数据驱动
- ✅ 不改签名

**方案 C**：所有命中统一粒子，Boss 单位受伤才加 screen shake
- ✅ 简单
- ❌ 普通暴击没冲击感

**💡 我的建议**：**方案 B**。按伤害量分级触发不同强度粒子 + shake。不需要改 take_damage 签名，在调用 `ParticlePool.spawn("hit_spark")` 和 `camera.shake()` 时按 amount 参数选强度。

---

### 决策点 7：后处理 controller 是 Autoload 还是场景节点？

**方案 A**：Autoload 单例 `PostProcessController`
- ✅ 全局 API（任何代码都能调）
- ✅ 切场景不丢
- ❌ Autoload 越多越乱

**方案 B**：每个场景自己挂后处理节点
- ✅ 场景隔离
- ❌ 沙盒和正式场景要各挂一份

**方案 C**：Autoload + 自动挂 CanvasLayer 到 main tree
- ✅ 全局 API + 节点正确挂载
- ❌ 复杂

**💡 我的建议**：**方案 A**。`PostProcessController` Autoload，内部维护一个 CanvasLayer + ColorRect，`_ready()` 时挂到 root。API：`shake_screen()` / `chromatic_aberration()` / `shockwave()`。

---

## 3. 我的建议总结

| 决策点 | 建议方案 | 理由 |
|---|---|---|
| 后处理 CanvasLayer | A（layer=5）| 不影响 UI 和跳字 |
| 冲击波 shader | B（扩散环，不扭曲）| 像素风友好 + 性能好 |
| Screen shake | D（相机 offset + 分级）| 兼容 clamp + 冲击可控 |
| 色差触发 | B+D（屏幕级事件 + 技能）| 稀缺不晕 |
| 命中粒子区分 | C（起步统一）| 先简单后迭代 |
| 暴击加量 | B（按伤害量分级）| 数据驱动 |
| 后处理 controller | A（Autoload）| 全局 API |

---

## 4. 接入点 / 涉及文件

### 新增文件

```
shaders/post_process.gdshader                 # 后处理 shader（冲击波环 + 色差二合一）
scripts/effects/post_process_controller.gd    # Autoload 单例
```

### 修改文件

| 文件 | 改动 |
|---|---|
| [project.godot](../../project.godot) | 注册 PostProcessController Autoload |
| [scripts/systems/game_camera.gd](../../scripts/systems/game_camera.gd) | 加 `shake(strength_px, duration)` API，兼容 clamp |
| [scripts/units/unit.gd](../../scripts/units/unit.gd) (`take_damage`) | 调 `ParticlePool.spawn("hit_spark", pos)` + 按伤害量分级 |
| [scripts/units/unit.gd](../../scripts/units/unit.gd) (`die`) | 如果 `is_boss`：调 `PostProcessController.shake_screen(10, 0.3)` + chromatic_aberration |
| [scripts/buildings/building.gd](../../scripts/buildings/building.gd) (`die`) | 调 `PostProcessController.shake_screen(8, 0.2)` + `shockwave(pos, 200)` |

---

## 5. 后处理 API 设计

```gdscript
# post_process_controller.gd (Autoload)
extends CanvasLayer

func _ready() -> void:
    layer = 5
    # 创建 ColorRect + ShaderMaterial 子节点

# === Screen Shake ===
# 通过 game_camera.gd 实现，这里只是转发
func shake_screen(strength_px: float = 5.0, duration: float = 0.2) -> void

# === Chromatic Aberration（色差）===
func chromatic_aberration(strength: float = 0.005, duration: float = 0.2) -> void
    # Tween shader_parameter/strength: 0 → peak → 0

# === Shockwave（冲击波环）===
func shockwave(screen_pos: Vector2, max_radius: float = 200.0, duration: float = 0.4) -> void
    # 在指定位置画扩散环（不扭曲背景）

# === 组合快捷 ===
func big_impact(screen_pos: Vector2) -> void
    # shake_screen(8, 0.2) + chromatic_aberration(0.005, 0.2) + shockwave(screen_pos, 200, 0.4)
```

---

## 6. 后处理 shader 骨架

```glsl
shader_type canvas_item;

uniform sampler2D screen_tex : hint_screen_texture;
uniform float chromatic_strength : hint_range(0.0, 0.02) = 0.0;
uniform vec2 chromatic_center = vec2(0.5, 0.5);

// 冲击波列表（最多同时 4 个）
uniform int shockwave_count = 0;
uniform vec4 shockwaves[4]; // xy = center (uv), z = current_radius, w = max_radius

void fragment() {
    vec2 uv = UV;
    vec4 col = texture(screen_tex, uv);

    // 色差
    if (chromatic_strength > 0.0) {
        vec2 dir = uv - chromatic_center;
        float r = texture(screen_tex, uv + dir * chromatic_strength).r;
        float b = texture(screen_tex, uv - dir * chromatic_strength).b;
        col.r = r;
        col.b = b;
    }

    // 冲击波环
    for (int i = 0; i < shockwave_count; i++) {
        vec4 sw = shockwaves[i];
        float dist = distance(uv, sw.xy);
        float ring_width = 0.01;
        float ring = smoothstep(sw.z, sw.z - ring_width, dist)
                   - smoothstep(sw.z - ring_width, sw.z - ring_width * 2.0, dist);
        col.rgb += vec3(1.0) * ring * 0.5;
    }

    COLOR = col;
}
```

---

## 7. 验证标准（沙盒）

- [ ] spawn 剑士 vs 敌方 → 每次命中出 **hit_spark 粒子**（黄→红→透明，additive）
- [ ] 大量命中（50 单位互打）→ 粒子走池，不卡
- [ ] 沙盒加个 debug 按钮"触发冲击波" → 点击后看到**扩散环**（0.4 秒）
- [ ] 沙盒加个 debug 按钮"触发色差" → 点击后看到**屏幕 RGB 分裂**（0.2 秒）
- [ ] 杀死巨魔 → **大 screen shake（10px）+ 色差 + 冲击波**同时触发
- [ ] 建筑爆炸 → **screen shake（8px）+ 冲击波**
- [ ] 普通单位受击 → 不触发 screen shake（强度 < 阈值）
- [ ] 沙盒"重置"时，所有后处理强度归零

---

## 8. 配置说明

### shake 强度分级（在 PostProcessController 或调用方定义）

```gdscript
const SHAKE_SMALL := 3.0    # 普通命中（其实不 shake）
const SHAKE_MEDIUM := 5.0   # 大伤害（>50）/ 技能命中
const SHAKE_LARGE := 8.0    # 建筑爆炸
const SHAKE_HUGE := 10.0    # Boss 死亡
```

### 触发后处理的阈值

- shake：伤害 > 30 触发 shake_small，> 60 触发 medium
- chromatic_aberration：仅 Boss 死亡、建筑爆炸、指挥官技能
- shockwave：建筑爆炸、Boss 死亡、指挥官技能

### 沙盒 debug 入口

PR-0 沙盒需要扩展（或 PR-5 时加）：

```
顶栏加按钮：
[触发冲击波] [触发色差] [触发 shake 小] [触发 shake 大]
```

方便单独验证每个后处理效果。

---

## 9. 已知风险

| 风险 | 缓解 |
|---|---|
| Screen shake 与 camera clamp 冲突 | 抖动期间临时放宽 clamp 范围，抖动结束恢复 |
| 后处理 shader 全屏采样开销 | 像素风分辨率低，开销可控；如真卡可降 ColorRect 分辨率 |
| 冲击波同时多个时 shader 数组上限 | 设 `shockwave_count <= 4`，超出丢弃（峰值场景容忍） |
| 色差强度过大让玩家晕 | 上限 0.005，触发时间 0.2 秒 |
| hit_spark 粒子在像素风下看不清 | 粒子贴图用纯色小亮点 + additive blend，确保高亮 |
| 沙盒 layer 设置错误导致后处理盖住 UI | 后处理 layer=5，UI layer=10，跳字 layer=15，验证一遍 |

---

## 10. 后续衔接

- **PR-6**：指挥官技能释放调 `PostProcessController.big_impact(screen_pos)`
- **PR-7**：T3 变体专属视觉里，Boss 杀手击杀 Boss 触发特殊冲击波

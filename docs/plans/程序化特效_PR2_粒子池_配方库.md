# PR-2：粒子对象池 + 配方库

> **目标**：建 ParticlePool Autoload + 6 种基础粒子配方 .tscn，替换现有 instantiate() 调用。
>
> **预期收益**：RTS 同屏几十单位不再因粒子实例化卡顿。后续所有粒子相关 PR 都依赖这个基础设施。
>
> **关联**：[ROADMAP](程序化特效落地_ROADMAP.md) | [总方案 1.3/1.4](../design/程序化特效落地总方案.md) | [调研报告 3.x](../design/程序化动画与特效调研报告.md)

---

## 1. 现状盘点

### 现有粒子/特效场景

读 `scenes/effects/` 目录：

| 场景 | 类型 | 触发方式 |
|---|---|---|
| `dust_effect.tscn` | 尘土 | 建筑/单位落地，每次 `instantiate()` |
| `heal_effect.tscn` | 治疗光环 | 僧侣治疗，每次 `instantiate()` |
| `explosion.tscn` | 爆炸 | 建筑/单位死亡，每次 `instantiate()` |
| `spawn_effect.tscn` | 出生光柱 | 单位创建，每次 `instantiate()` |
| `arrow.tscn` / `arrow_trail.tscn` | 箭矢 + 尾迹 | 远程攻击，每次 `instantiate()` |
| `move_click_effect.tscn` / `attack_click_effect.tscn` | 点击反馈 | 玩家指令，每次 `instantiate()` |
| `outpost_capture_ring.tscn` | 据点占领环 | 据点占领，每次 `instantiate()` |
| `warning_marker.tscn` | 警告标记 | 区域警告，每次 `instantiate()` |

**核心问题**：所有特效都走 `instantiate() + add_child()`，大规模战斗（50+ 单位同时受击/死亡）会严重卡顿（GitHub Issue #104360 实锤）。

### 性能瓶颈定位

- `instantiate()` 开销：PackedScene 解包 + 节点树挂载
- `GPUParticles2D` 首次创建：shader 编译（~10ms，卡一帧）
- `free()` 开销：节点销毁

**结论**：粒子池是必需，不是优化。

---

## 2. 决策点

### 决策点 1：池化哪些特效？

**方案 A**：只池化高频特效（dust / hit_spark / explosion），低频特效（spawn / outpost_ring）保持 instantiate
- ✅ 改动小，聚焦瓶颈
- ❌ API 不统一，开发者要记哪个走池哪个不走

**方案 B**：所有特效都走池
- ✅ API 统一
- ❌ 低频特效（比如据点占领环）池化收益低，预热浪费内存

**方案 C**：池化高频 + 中频特效，标记类特效（ring/marker）保持 instantiate
- ✅ 平衡
- ✅ "一次性绘制类"特效（Node2D + _draw）不适合粒子池

**💡 我的建议**：**方案 C**。区分两类：
- **池化**：GPUParticles2D 类特效（dust/heal_orb/explosion 粒子部分/hit_spark/energy_fog/debris/blood_mist）
- **不池化**：纯绘制类特效（ outpost_capture_ring / warning_marker / arrow / arrow_trail）——这些是 Node2D + _draw，不适合粒子池

---

### 决策点 2：池的预热策略？

**方案 A**：固定数量预热（启动时每种 20 个）
- ✅ 简单
- ❌ 可能不够（大战时）或浪费（平时）

**方案 B**：动态扩容（池空时新建一个，记录峰值）
- ✅ 适应实际负载
- ❌ 首次扩容仍会卡一下

**方案 C**：固定预热 + 动态扩容兜底
- ✅ 平时够用，峰值不崩
- ✅ 可以根据峰值日志调预热数量

**方案 D**：按场景预热（进入战斗场景时多预热，主城场景少预热）
- ✅ 精细
- ❌ 复杂

**💡 我的建议**：**方案 C**。启动时每种 20 个，池空时 push_warning + 动态新建。后续根据实测日志调预热数。

---

### 决策点 3：池节点挂哪里？

**方案 A**：Autoload 单例作为父节点，所有池化粒子挂这下面
- ✅ 全局访问
- ✅ 不依赖场景结构
- ❌ Autoload 节点树可能过大

**方案 B**：每个场景自己管池（main.gd / sandbox_controller.gd 各自维护）
- ✅ 场景隔离
- ❌ 切场景时池丢失

**方案 C**：Autoload 持有池数据，但节点挂在 current_scene 下
- ✅ 跟场景走
- ❌ 切场景时要迁移节点

**💡 我的建议**：**方案 A**。Autoload 单例 `ParticlePool`，所有池化粒子作为子节点。切场景时粒子节点不丢失（在 Autoload 树里），只是不在当前场景显示——这反而对（粒子可能在场景切换瞬间还在播放）。

---

### 决策点 4：配方参数怎么存？

**方案 A**：每个配方一个 `.tscn` 文件，参数固定写在节点里
- ✅ 编辑器可视化调整
- ✅ 清晰
- ❌ 变体需要复制文件

**方案 B**：一个基础 `.tscn` + 多个 `.res`（ParticleProcessMaterial）参数
- ✅ 变体灵活
- ❌ 材质资源管理复杂

**方案 C**：代码生成（`ParticlePool.create_dust(pos)` 内部 new GPUParticles2D + 配参数）
- ✅ 不需要 .tscn
- ❌ 参数硬编码，调参要改代码

**方案 D**：方案 A + 共享 ParticleProcessMaterial（同配方的实例共享材质）
- ✅ 内存友好
- ✅ 编辑器可视化

**💡 我的建议**：**方案 D**。每个配方一个 `.tscn`，内含 GPUParticles2D + ParticleProcessMaterial（材质独立，不共享——因为 pool 复用时不希望互相干扰）。变体（如大命中 vs 小命中）复制 `.tscn` 改参数。

---

### 决策点 5：现有特效如何迁移？

**方案 A**：一次性全替换（dust/heal/explosion 全走池）
- ✅ 一步到位
- ❌ 改动面大，容易出 bug

**方案 B**：先做池系统，现有特效保持 instantiate，新特效走池
- ✅ 渐进
- ❌ 双轨制，混乱

**方案 C**：先迁移最高频的（dust + explosion），其他按需迁移
- ✅ 聚焦瓶颈
- ✅ 渐进验证

**💡 我的建议**：**方案 C**。PR-2 范围内只迁移 `dust_effect` 和 `explosion`（最高频）。`heal_effect` 等保持现状，PR-3（UnitVisualFeedback 接入治疗）时再迁。

---

## 3. 我的建议总结

| 决策点 | 建议方案 | 理由 |
|---|---|---|
| 池化范围 | C（池化粒子类，绘制类不池）| 区分两类特效 |
| 预热策略 | C（固定 + 动态兜底）| 平时够用峰值不崩 |
| 池节点位置 | A（Autoload 单例）| 全局访问 |
| 配方参数 | D（每配方一 .tscn + 独立材质）| 可视化 + 灵活 |
| 现有迁移 | C（先迁 dust + explosion）| 聚焦瓶颈 |

---

## 4. 接入点 / 涉及文件

### 新增文件

```
scripts/effects/particle_pool.gd              # Autoload 单例
scenes/effects/particles/dust.tscn             # 尘土
scenes/effects/particles/hit_spark.tscn        # 命中火花
scenes/effects/particles/debris.tscn           # 碎片
scenes/effects/particles/energy_fog.tscn       # 能量雾
scenes/effects/particles/heal_orb.tscn         # 治疗光斑
scenes/effects/particles/blood_mist.tscn       # 血雾
```

### 修改文件

| 文件 | 改动 |
|---|---|
| [project.godot](../../project.godot) | 注册 ParticlePool Autoload |
| [scripts/main.gd](../../scripts/main.gd) (`_ready`) | 启动时调 `ParticlePool.prewarm_all()` |
| [scripts/effects/dust_effect.gd](../../scripts/effects/dust_effect.gd) | 触发处改用 `ParticlePool.spawn("dust", pos)` |
| [scripts/buildings/building.gd](../../scripts/buildings/building.gd) (`die`) | 爆炸改用 `ParticlePool.spawn("explosion", pos)` |
| [scripts/units/unit.gd](../../scripts/units/unit.gd) (`die`) | 死亡爆炸（如果有）改走池 |

---

## 5. 配方参数表（参考调研报告 3.2）

### dust.tscn（尘土）
```
amount: 8
lifetime: 0.5s
gravity: (0, -15)
direction: (0, -1) spread=30°
initial_velocity: 15
scale_curve: 大→小
color_ramp: 灰白→透明
texture: 软圆盘
explosiveness: 0.5
```

### hit_spark.tscn（命中火花）
```
amount: 15
lifetime: 0.3s
gravity: (0, 200)
direction: (0, 1) spread=45°
initial_velocity: 80
scale_curve: 小→更小
color_ramp: 黄→红→透明
texture: 小亮点
explosiveness: 0.8
blend_mode: add
```

### debris.tscn（碎片）
```
amount: 12
lifetime: 0.6s
gravity: (0, 400)
direction: 各方向 spread=180°
initial_velocity: 60
scale_curve: 随机
color_ramp: 石灰→透明
texture: 小方块
explosiveness: 0.9
```

### energy_fog.tscn（能量雾）
```
amount: 20
lifetime: 1.0s
gravity: (0, -5)
direction: (0, -1) spread=60°
initial_velocity: 10
scale_curve: 脉动
color_ramp: 紫→透明
texture: 软圆盘
explosiveness: 0.2
blend_mode: add
```

### heal_orb.tscn（治疗光斑）
```
amount: 15
lifetime: 0.8s
gravity: (0, -30)
direction: (0, -1) spread=20°
initial_velocity: 25
scale_curve: 小→大→消失
color_ramp: 金→透明
texture: 小亮点
explosiveness: 0.3
blend_mode: add
```

### blood_mist.tscn（血雾）
```
amount: 8
lifetime: 0.4s
gravity: (0, 300)
direction: 各方向 spread=180°
initial_velocity: 40
scale_curve: 小→更小
color_ramp: 暗红→透明
texture: 小圆点
explosiveness: 0.9
```

---

## 6. 验证标准（沙盒）

PR-2 完成后：

- [ ] 启动游戏，控制台无预热错误
- [ ] 沙盒 spawn 50 剑士 vs 50 敌方，开战时观察 FPS（应保持 60+）
- [ ] 单位落地有尘土粒子（走池）
- [ ] 建筑死亡爆炸走池
- [ ] 大量粒子触发时，控制台**无** `push_warning("Particle pool empty: ...")` 日志（如果有，调大预热数）
- [ ] 沙盒"重置"后，所有粒子停止，池中节点正确归还

---

## 7. 配置说明

### 调整预热数量

在 `main.gd::_ready()` 或 `particle_pool.gd` 顶部：

```gdscript
const PREWARM_COUNTS := {
    "dust": 30,
    "hit_spark": 25,
    "debris": 20,
    "energy_fog": 25,
    "heal_orb": 20,
    "blood_mist": 20,
}
```

跑大规模战斗测试时，打开 verbose 日志看 `push_warning` 频率，按需调大。

### 添加新粒子配方

1. 在 `scenes/effects/particles/` 新建 `.tscn`（参考现有配方参数）
2. 在 `particle_pool.gd` 的 `_ready()` 加 `prewarm("new_effect", 20)`
3. 触发处调 `ParticlePool.spawn("new_effect", pos)`

---

## 8. 已知风险

| 风险 | 缓解 |
|---|---|
| 池中粒子 `finished` 信号丢失（节点被 free）| `_return_to_pool` 用 `Callable.bind()`，节点不 free 只 hide |
| GPUParticles2D 的 `interpolate` 导致物理插值卡顿（#65390）| 设 `interpolate = false` 或 `fixed_fps = 60` |
| 粒子位置错乱（池复用时旧位置残留）| spawn 时强制 `global_position = pos` + `restart()` |
| 大量同时触发时池瞬间空 | 动态扩容 + warning 日志，长期根据日志调预热数 |
| 现有特效迁移后视觉变化（参数不一致）| 迁移时保留原参数，对比前后视觉效果 |

---

## 9. 后续衔接

- **PR-3**：UnitVisualFeedback 的 hit_spark / heal_orb 触发走池
- **PR-4**：BuildingActivityVisual 的 dust / debris 触发走池
- **PR-5**：命中粒子全面接入池
- **PR-6**：技能视觉的能量雾/治疗光斑走池

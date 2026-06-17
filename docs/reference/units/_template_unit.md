# 单位字段模板

## 重要约定
- 字段缺失时填 `—`，不要留空
- 伤害/HP 为游戏内绝对数值（非 DPS），冷却为秒，射程/射程为游戏内距离单位
- 升级加成用 `+X` 表示，如 `6+1` 表示基础 6 每级 +1
- 攻击类型用标准英文缩写：[N]ormal / [P]iercing / [S]iege / [C]haos / [M]agic / [H]ero / [E]xplosive / [C]oncussive
- 目标类型：G=地面 / A=空中 / B=双用
- 多个来源数据不一致时，取 Liquipedia 值，并备注差异

## 单位数据表

| 分类 | 字段 | 类型 | 说明 |
|---|---|---|---|
| **身份** | name_zh | string | 中文名 |
| | name_en | string | 英文原名 |
| | race | string | 所属种族 |
| | faction | string | 子阵营（如合作指挥官/文明） |
| | tier | int | 科技等级 1-4 |
| | mode | string | 数据来源模式（标准/战役/合作） |
| | source_game | string | 具体游戏版本 |
| | description | string | 一句话描述 |
| **生产** | built_from | string | 生产建筑 |
| | prereq_tech | string | 前置科技（仅列必要的） |
| | cost_mineral | int | 矿物/金/主要资源 |
| | cost_gas | int | 气/木/石/次要资源 |
| | cost_supply | int | 人口/补给 |
| | build_time | float | 建造/训练时间(秒) |
| **生存** | hp | int | 生命值 |
| | shield | int | 护盾值（没有则 0） |
| | armor_type | string | 护甲类型标签 |
| | armor_value | int | 基础护甲值 |
| | armor_upgrade | string | 护甲升级加成（如 +1×3） |
| | tags | string[] | 标签（轻甲/重甲/生物/机械/灵能） |
| **机动** | move_speed | float | 移动速度 |
| | acceleration | float | 加速度 |
| | turn_rate | float | 转向速率 |
| | fly | bool | 是否飞行单位 |
| | transport_slots | int | 占用运输位 |
| | collision_radius | float | 碰撞体积 |
| | vision | int | 视野范围 |
| **攻击** | weapon_name | string | 武器名称 |
| | damage_base | int | 基础伤害（如 6+1 表示 6 基础 +1 每级） |
| | damage_upgrade | string | 升级加成 |
| | attack_type | string | 攻击类型（N/P/S/C/M/H/E） |
| | cooldown | float | 攻击冷却(秒) |
| | range | float | 攻击射程 |
| | target_types | string | G/A/B |
| | projectile_speed | float | 弹道速度 |
| | splash_radius | float | 溅射半径（0=无） |
| | splash_falloff | string | 溅射衰减（线性/平方/无） |
| | bonus_vs | string | 克制目标+倍率（如 "重甲×2"） |
| | min_range | float | 最小射程（0=无） |
| **技能** | active | string[] | 主动技能：名/冷却/耗能/效果 |
| | passive | string[] | 被动技能：名/条件/效果 |
| | autocast | string[] | 自动施法技能 |
| **升级** | weapon_upgrades | string | 武器升级路线 |
| | armor_upgrades | string | 护甲升级路线 |
| | special_upgrades | string | 特殊升级（解锁技能/变体） |
| **备注** | data_source | string | 数据来源 URL |
| | notes | string | 补充说明/机制细节 |

## 示例：SC2 Terran Marine

| 分类 | 字段 | 值 |
|---|---|---|
| **身份** | name_zh | 陆战队员 |
| | name_en | Marine |
| | race | Terran |
| | faction | — |
| | tier | 1 |
| | mode | 标准 |
| | source_game | SC2 LotV |
| | description | 基础步兵，可对空对地，Stim提升攻速 |
| **生产** | built_from | Barracks |
| | prereq_tech | — |
| | cost_mineral | 50 |
| | cost_gas | 0 |
| | cost_supply | 1 |
| | build_time | 18s |
| **生存** | hp | 45 |
| | shield | 0 |
| | armor_type | Light |
| | armor_value | 0 |
| | armor_upgrade | +1×3 |
| | tags | 生物, 轻甲 |
| **机动** | move_speed | 2.25 |
| | acceleration | — |
| | turn_rate | — |
| | fly | 否 |
| | transport_slots | 1 |
| | collision_radius | — |
| | vision | 9 |
| **攻击** | weapon_name | C-14 Gauss Rifle |
| | damage_base | 6 |
| | damage_upgrade | +1×3 |
| | attack_type | N |
| | cooldown | 0.86 |
| | range | 5 |
| | target_types | B |
| | projectile_speed | 即时 |
| | splash_radius | 0 |
| | splash_falloff | — |
| | bonus_vs | — |
| | min_range | 0 |
| **技能** | active | Stim: 10s 内攻速+50%, 扣 10 HP |
| | passive | Combat Shield(+10 HP) |
| | autocast | — |
| **升级** | weapon_upgrades | Infantry Weapons Lv1-3 |
| | armor_upgrades | Infantry Armor Lv1-3 |
| | special_upgrades | Stim, Combat Shield |
| **备注** | data_source | Liquipedia SC2 |
| | notes | 基础 DPS 6.98 (6/0.86)，Stim 后 DPS 10.5 |
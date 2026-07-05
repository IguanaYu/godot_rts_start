# 项目文档索引

RTS 项目的所有设计、调研、配置手册、归档文档都在 `docs/` 下。本文件是唯一入口。

## 目录结构

| 目录 | 用途 | 何时往这里放 |
|------|------|------|
| [active/](active/) | 进行中的设计、Phase 计划、长期参考的白皮书 | 还在推进或仍在被频繁查阅的"现行工作" |
| [manual/](manual/) | 操作类配置手册（"怎么做"） | 给出具体步骤的指南：编辑器配置、技能效果表、资源来源 |
| [reference/](reference/) | 调研与设计参考（"参考用"） | 跨游戏数值调研、单位数据、设计方法论 |
| [brainstorming/](brainstorming/) | 仍活跃的工具型设计文档 | 设计方法论、实施路线图、仍在演进的设计稿 |
| [archived/](archived/) | 历史归档 | 已完成实现、被新方案替代、废弃的想法 |

---

## active/ — 进行中的工作

- [战役设计_Phase1_基础设施.md](active/战役设计_Phase1_基础设施.md) — 16 关战役解锁系统 + 分数系统
- [战役设计_Phase2_纯配置关卡.md](active/战役设计_Phase2_纯配置关卡.md) — 纯配置关卡（第 5–8 关）
- [phase1_skill_floating_text_and_summon_projectile.md](active/phase1_skill_floating_text_and_summon_projectile.md)
- [phase2_skill_framework.md](active/phase2_skill_framework.md)
- [ui-migration-plan.md](active/ui-migration-plan.md)
- [关卡设计白皮书.md](active/关卡设计白皮书.md) — 可量化的关卡评价指标体系
- [AI队友系统_配置说明书.md](active/AI队友系统_配置说明书.md)
- [科技点系统_功能介绍.md](active/科技点系统_功能介绍.md)
- [地图配置指南.md](active/地图配置指南.md) — 单机地图
- [多人地图配置手册.md](active/多人地图配置手册.md) — 多势力地图
- [单位变体测试方案.md](active/单位变体测试方案.md)

## manual/ — 配置手册

- [game-config-manual.md](manual/game-config-manual.md) — 游戏全局配置项
- [skill_effects_reference.md](manual/skill_effects_reference.md) — 技能效果表
- [驻军系统_配置教程.md](manual/驻军系统_配置教程.md)
- [asset_sources.md](manual/asset_sources.md) — 美术/音频素材来源
- [数据获取来源列表.md](manual/数据获取来源列表.md)

## reference/ — 调研与设计参考

### research/ — 跨游戏数值与机制调研

星际争霸 2 系列（命名前缀「星际2」与「星际争霸2」混用，属同一系列）：
- [合作模式_地图机制与时间轴](reference/research/星际2合作模式_地图机制与时间轴.md)
- [合作模式_敌方进攻波次数据](reference/research/星际2合作模式_敌方进攻波次数据.md)
- [合作模式_突变因子完整列表](reference/research/星际2合作模式_突变因子完整列表.md)
- [合作模式数值分析](reference/research/星际争霸2合作模式数值分析.md)
- [数值分析方法论](reference/research/星际争霸2数值分析方法论.md) / [分析结果](reference/research/星际争霸2数值分析结果.md)
- [数值设计逆向工程](reference/research/星际争霸2数值设计逆向工程.md)
- [经济科技战斗力全链路模型](reference/research/星际争霸2经济科技战斗力全链路模型.md)
- [自由之翼战役模式深度调研](reference/research/星际争霸2自由之翼战役模式深度调研.md)

其他游戏：
- [魔兽争霸3 数值逆向工程](reference/research/魔兽争霸3数值逆向工程分析.md)
- [星际2 vs 魔兽3 RTS 数值设计对比](reference/research/星际2vs魔兽3_RTS数值设计对比分析.md)
- [亿万僵尸 数值与节奏调研](reference/research/亿万僵尸_数值与节奏调研.md)
- [红警2/3 任务模式调研](reference/research/红警2_3_任务模式调研.md)
- [大战术释放 跨游戏机制调研](reference/research/大战术释放_跨游戏机制调研.md) — 高 HP 引导型精英敌人的跨游戏 archetype 调研（Payday/Helldivers/DRG/Vermintide/WC3/TV Tropes）
- [近战兵修复完整调研报告](reference/research/近战兵修复完整调研报告.md)

### design/ — 数值设计参考

- [RTS战斗节奏设计：从 10 秒 TTK 反推数值](reference/design/RTS战斗节奏设计_从10秒TTK反推数值.md)
- [战斗节奏：角色定位数值范围（SLOW 方案）](reference/design/战斗节奏_角色定位数值范围_SLOW方案.md)
- [rts-level-design-reference](reference/design/rts-level-design-reference.md)
- [victory-defeat-conditions-catalog](reference/design/victory-defeat-conditions-catalog.md)
- [大战术释放 设计要点与避坑指南](reference/design/大战术释放_设计要点与避坑指南.md) — 6 条核心设计经验 + 反模式 + 设计 checklist

### units/ — 单位数据调研

按游戏系列组织的单位数据，[进入 units/ 索引](reference/units/_index.md)。涵盖星际、魔兽、帝国时代、C&C、英雄连、沙丘等系列。

## brainstorming/ — 仍活跃的工具型设计文档

- [单位设计公式化指南.md](brainstorming/单位设计公式化指南.md) — 设计方法论
- [单位实施路线图_按代码改动分层.md](brainstorming/单位实施路线图_按代码改动分层.md)
- [建筑计划.md](brainstorming/建筑计划.md)
- [局外成长设计调研.md](brainstorming/局外成长设计调研.md)
- [大战术释放_设计草案.md](brainstorming/大战术释放_设计草案.md) — 高 HP 引导型精英敌人：5 种原始战术 + 6 种调研补充变体 + RTS 维度 + 待决策问题

## archived/ — 历史归档

已完成实现（漂浮文字、菜单顺序、网络健壮性等）、被新方案替代的旧设计（Phase3/4、盟友关卡系列、Phase1/2 的部分内容）、已落地的创意池（单位/建筑创意大全）。需要时直接进入 [archived/](archived/) 浏览。

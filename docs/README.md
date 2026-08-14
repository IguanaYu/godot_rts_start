# 项目文档索引

RTS 项目的所有文档都在 `docs/` 下，本文件是唯一入口（人和 AI 都从这里查）。
每个条目一行说明**何时查它**。找不到想要的 → 直接进对应目录浏览或全文搜索。

## 目录职责

| 目录 | 回答的问题 | 生命周期 |
|------|------|------|
| [game/](game/) | 这个游戏**是什么**：概览、代码架构、进度、已实现功能 | 活文档，持续更新 |
| [manual/](manual/) | 某件事**怎么操作**：配置手册、生成教程 | 活文档，随功能演进 |
| [standards/](standards/) | 设计新东西时**按什么标准**：数值基准、设计方法论 | 活文档，决策后更新 |
| [research/product/](research/product/) | **别的游戏**怎么做：竞品数值/机制调研 | 只读沉淀，不再更新 |
| [research/technical/](research/technical/) | **某种技术/做法**怎么做：音频、shader 等非竞品调研 | 只读沉淀 |
| [decisions/](decisions/) | 当初**为什么这么定**：决策稿及候选方案 | 只追加 |
| [sessions/](sessions/) | 讨论**过程档案**：对话纪要 | 只存不改 |
| [plans/](plans/) | **正在做**什么：阶段设计、PR 计划、测试方案 | 完成后迁 archived/ |
| [brainstorming/](brainstorming/) | **还没定**的设计草案 | 成熟后转 TODO/plans |
| [reference/](reference/) | **查数据**：跨游戏单位数据库、UI 规格 | 持续扩充 |
| [archived/](archived/) | 历史归档（已完成的计划、被替代的方案） | 冷仓库 |

根目录的 [TODO.md](../TODO.md)（已决定要做，排期推进）和 [idea.md](../idea.md)（灵感池）不属于 docs/，但属于整个文档体系的工作流入口。

---

## game/ — 游戏本体（接手任何讨论前先读）

- [游戏概览](game/overview.md) — 定位/核心循环/玩法系统/画风，了解"这是个什么游戏"
- [代码架构](game/architecture.md) — scripts/ 目录地图与关键文件，改代码前读
- [开发进度](game/progress.md) — T1→T4 各阶段做了什么、当前状态，恢复上下文用
- [科技点系统_功能介绍](game/科技点系统_功能介绍.md) — 暗线累积资源，T2/T3 解锁的底层支撑

## manual/ — 操作指南（动手做某件事时查）

- [game-config-manual.md](manual/game-config-manual.md) — 游戏全局配置项
- [地图配置指南.md](manual/地图配置指南.md) — 新建/修改单机地图
- [多人地图配置手册.md](manual/多人地图配置手册.md) — 多势力地图
- [关卡玩法指南.md](manual/关卡玩法指南.md) — 关卡玩法类型说明
- [AI队友系统_配置说明书.md](manual/AI队友系统_配置说明书.md) — AI 队友行为配置
- [skill_effects_reference.md](manual/skill_effects_reference.md) — 技能效果总表
- [单位特效_配置与生成教程.md](manual/单位特效_配置与生成教程.md) — 7 类 35 效果挑选/调参/spawn
- [大战术释放者_配置与生成教程.md](manual/大战术释放者_配置与生成教程.md) — 引导桩精英敌人配置
- [驻军系统_配置教程.md](manual/驻军系统_配置教程.md) — 建筑驻军
- [asset_sources.md](manual/asset_sources.md) — 美术/音频素材来源
- [数据获取来源列表.md](manual/数据获取来源列表.md) — 调研数据从哪来

## standards/ — 设计基准（设计数值/机制前必读）

- [单位设计公式化指南.md](standards/单位设计公式化指南.md) — 新单位数值必须套用的公式
- [RTS战斗节奏设计_从10秒TTK反推数值.md](standards/RTS战斗节奏设计_从10秒TTK反推数值.md) — 战斗节奏基准
- [战斗节奏_角色定位数值范围_SLOW方案.md](standards/战斗节奏_角色定位数值范围_SLOW方案.md) — 各角色定位的数值区间
- [关卡设计白皮书.md](standards/关卡设计白皮书.md) — 可量化的关卡评价指标体系，做关卡前读
- [rts-level-design-reference.md](standards/rts-level-design-reference.md) — 关卡设计通用参考
- [victory-defeat-conditions-catalog.md](standards/victory-defeat-conditions-catalog.md) — 胜负条件目录（配合 scripts/victory/ 的 15 种实现）
- [大战术释放_设计要点与避坑指南.md](standards/大战术释放_设计要点与避坑指南.md) — 精英敌人设计 6 条经验 + 反模式
- [玩法设计讨论方法论.md](standards/玩法设计讨论方法论.md) — 和 AI 聊设计的方法
- [游戏开发skill.md](standards/游戏开发skill.md) — 谢尔方法设计顾问 prompt，压测游戏创意用

## research/product/ — 竞品调研（查"别的游戏怎么做"）

星际争霸 2 系列（前缀「星际2」「星际争霸2」混用，同一系列）：
- [合作模式_地图机制与时间轴](research/product/星际2合作模式_地图机制与时间轴.md)
- [合作模式_敌方进攻波次数据](research/product/星际2合作模式_敌方进攻波次数据.md)
- [合作模式_突变因子完整列表](research/product/星际2合作模式_突变因子完整列表.md)
- [合作模式数值分析](research/product/星际争霸2合作模式数值分析.md)
- [数值分析方法论](research/product/星际争霸2数值分析方法论.md) / [分析结果](research/product/星际争霸2数值分析结果.md)
- [数值设计逆向工程](research/product/星际争霸2数值设计逆向工程.md)
- [经济科技战斗力全链路模型](research/product/星际争霸2经济科技战斗力全链路模型.md)
- [自由之翼战役模式深度调研](research/product/星际争霸2自由之翼战役模式深度调研.md)

其他游戏数值/机制：
- [魔兽争霸3 数值逆向工程](research/product/魔兽争霸3数值逆向工程分析.md)
- [星际2 vs 魔兽3 RTS 数值设计对比](research/product/星际2vs魔兽3_RTS数值设计对比分析.md)
- [帝国时代2 数值与节奏调研](research/product/帝国时代2_数值与节奏调研.md)
- [亿万僵尸 数值与节奏调研](research/product/亿万僵尸_数值与节奏调研.md)
- [红警2/3 任务模式调研](research/product/红警2_3_任务模式调研.md)
- [植物大战僵尸 引导与教学设计调研](research/product/植物大战僵尸_引导与教学设计调研.md)
- [大战术释放 跨游戏机制调研](research/product/大战术释放_跨游戏机制调研.md) — 高 HP 引导型精英敌人的跨游戏 archetype
- [近战兵修复完整调研报告](research/product/近战兵修复完整调研报告.md)
- [RTS 小地图功能调研](research/product/RTS小地图功能调研_星际2_魔兽3_亿万僵尸.md)
- [中立物设计 PVE 视角调研](research/product/中立物设计_PVE视角调研.md)
- [局外成长设计调研](research/product/局外成长设计调研.md)

UI / 特效专题：
- [游戏UI设计定式_跨游戏与设计系统调研](research/product/游戏UI设计定式_跨游戏与设计系统调研.md) / [调研评估与补强](research/product/游戏UI设计定式_调研评估与补强.md)
- [资源面板UI 跨游戏调研](research/product/资源面板UI_跨游戏调研.md)
- [任务事件UI 跨游戏调研](research/product/任务事件UI_跨游戏调研.md)
- [AI写UI安全_越界检测与视觉反馈调研](research/product/AI写UI安全_越界检测与视觉反馈调研.md)
- [RTS特效分类与作用调研](research/product/RTS特效分类与作用调研.md)
- [伤害法术特效 跨游戏调研](research/product/伤害法术特效_跨游戏调研.md)
- [单单位环绕特效 跨游戏调研](research/product/单单位环绕特效_跨游戏调研.md)

玩法设计与资源转化：
- [RTS_玩法设计建议](research/product/RTS_玩法设计建议.md)
- [RTS_自动化建造与游戏类型演化](research/product/RTS_自动化建造与游戏类型演化.md)
- [RTS_资源转化图分析](research/product/RTS_资源转化图分析.md)（本作框架）
- [RTS_Circle_Empires_2_资源转化图分析](research/product/RTS_Circle_Empires_2_资源转化图分析.md)
- [RTS_红警2_资源转化图分析](research/product/RTS_红警2_资源转化图分析.md)

## research/technical/ — 技术调研（做技术选型前查）

音频系列（00-06 连贯阅读，06 是总结）：
- [audio_00_overview](research/technical/audio_00_overview.md) / [01_free_resources](research/technical/audio_01_free_resources.md) / [02_ai_sfx_tools](research/technical/audio_02_ai_sfx_tools.md) / [03_ai_voice](research/technical/audio_03_ai_voice.md) / [04_opensource_and_godot](research/technical/audio_04_opensource_and_godot.md) / [05_sound_inventory](research/technical/audio_05_sound_inventory.md) / [06_research_summary](research/technical/audio_06_research_summary.md)

视觉技术：
- [程序化动画与特效调研报告](research/technical/程序化动画与特效调研报告.md) — 纯代码/shader 驱动视觉表现的方案池

## decisions/ — 决策记录（查"当初为什么这么定"）

T3 阶段模块决策稿（含被否决的候选，其中 C 模块另有候选库全量记录）：
- [C模块决策稿](decisions/T3阶段设计_C模块决策稿.md) + [C模块设计候选库](decisions/T3阶段设计_C模块设计候选库.md)
- [E模块决策稿](decisions/T3阶段设计_E模块决策稿.md) / [F模块决策稿](decisions/T3阶段设计_F模块决策稿.md) / [G模块决策稿](decisions/T3阶段设计_G模块决策稿.md) / [H模块决策稿](decisions/T3阶段设计_H模块决策稿.md) / [I模块决策稿](decisions/T3阶段设计_I模块决策稿.md)

## sessions/ — 对话纪要（查历史讨论现场）

- [2026-07-20_运营设计对话](sessions/2026-07-20_运营设计对话.md)
- [2026-07-21_资源图框架深化](sessions/2026-07-21_资源图框架深化.md)
- [2026-07-28_玩法推进纪要](sessions/2026-07-28_玩法推进纪要.md)
- [2026-08-04_T2宏观设计讨论](sessions/2026-08-04_T2宏观设计讨论.md)

## plans/ — 进行中计划

- [T4阶段设计_00_总览](plans/T4阶段设计_00_总览.md) — 当前阶段目标与子任务（配合 [调研报告](plans/T4阶段设计_调研报告.md)）
- 程序化特效系列：[落地总方案](plans/程序化特效落地总方案.md) + [ROADMAP](plans/程序化特效落地_ROADMAP.md) + [PR0 测试沙盒](plans/程序化特效_PR0_测试沙盒.md) ~ [PR7 T3变体专属](plans/程序化特效_PR7_T3变体专属.md)
- [单位动态与状态视觉设计方案](plans/单位动态与状态视觉设计方案.md) / [建筑活动视觉设计方案](plans/建筑活动视觉设计方案.md)
- [单位变体测试方案](plans/单位变体测试方案.md) / [单位实施路线图_按代码改动分层](plans/单位实施路线图_按代码改动分层.md)

## brainstorming/ — 未定的设计草案

- [RPG模式_单英雄辅助战_调研与方案](brainstorming/RPG模式_单英雄辅助战_调研与方案.md) — 待继续聊机制
- [RTS核心要素补全_设计文档](brainstorming/RTS核心要素补全_设计文档.md) — 待排优先级
- [大战术释放_设计草案](brainstorming/大战术释放_设计草案.md)
- [任务事件UI_设计草案](brainstorming/任务事件UI_设计草案.md)
- [建筑计划](brainstorming/建筑计划.md) — 建筑效果发散脑暴（基于早期 4 建筑时代，部分已过时）

## reference/ — 数据查询

- [units/](reference/units/_index.md) — 跨游戏单位数据库（星际/魔兽/帝国时代/C&C/战锤40K 等），含单位/阵营模板
- [ui_specs.md](reference/ui_specs.md) — UI 安全规格

## archived/ — 历史归档

T1/T2/T3 全部实施计划、16 关关卡诊断、战役 Phase1-4、UI 改造、小地图 v2、技能系统重构、单位/建筑创意大全等。需要考古时直接进 [archived/](archived/) 浏览。

---

## 维护规则（人和 AI 共同遵守）

1. **接到任务先查这里**：设计/开发前按上表定位相关文档再动手。
2. **产出文档必须登记**：新文档写完，在本文件对应分区加一行"何时查它"。
3. **生命周期流转**：
   - plans/ 完成 → 移入 archived/，索引行删除（archived 不逐条登记）
   - 讨论出决策 → decisions/ 加决策稿，可引用 sessions/ 纪要
   - brainstorming 成熟 → 转 TODO.md 排期，方案细节落 plans/
   - sessions 只存不改：对话有沉淀价值时按 `YYYY-MM-DD_主题.md` 命名存入
4. **一个文档只回答一个问题**：操作步骤进 manual/，设计标准进 standards/，别人的做法进 research/，别混写。
5. **改名/移动用 git mv**，保持历史可追溯；移动后同步更新本索引。

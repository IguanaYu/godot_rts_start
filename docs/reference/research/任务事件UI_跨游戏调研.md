# 任务事件 UI — 跨游戏调研

> 调研对象：WC3、SC2、C&C、AOE2/4、Company of Heroes、Northgard、Stormgate、ZeroSpace、8-Bit Armies
>
> 用途：为本项目任务面板重构 + 任务事件提示统一化 + 动态组件库选型提供案例支撑。

---

## 一、案例事实

### 1.1 魔兽争霸3（WC3）

**任务日志（F9）**：
- 左侧地图 + 右侧任务列表。任务分 **Required Quests（主线，金色图标）** 与 **Optional Quests（支线，银白色图标）** 两组。
- 任务条目格式：图标 + 标题（金色高亮）+ 描述正文。描述支持颜色标签 `|cFFFFFFFF...|r` 与换行符 `|n`。奖励通常用独立段落 `Reward: ...` 列出。

**任务事件提示（屏幕中央 cinematic 风格）**：
- 触发器 `Quest - Display ... the [Quest Discovered / Completed / Failed / Requirement / Hint / Mission Failed] message`，共 6 种类型。
- **Quest Discovered**：黄色大字 + "新任务"配音，居中，停留 5–8 秒。
- **Quest Completed**：绿色文字 + 完成音效，常附奖励列表行（`+500 gold`）。
- **Quest Failed / Mission Failed**：红色 + 失败音效。

**世界标记**：NPC 头顶黄感叹号 `!` = 可接任务，问号 `?` = 可交付。小地图对应显示金色感叹号点。

### 1.2 星际争霸2（SC2）

**任务目标面板**：
- 位置：屏幕**右上角**，与资源/补给栏并列。
- 主目标在面板顶部白色/浅黄；**Bonus Objectives** 缩进或灰色/绿色调区分，常带 `+research / +zerg` 标签。
- 进度形式多样：纯文字 `12/30 Killed`、计数 `3/5 War Mills destroyed`、横向进度条；倒计时任务用 **MM:SS** 格式贴在目标行尾。

**多阶段目标动态切换**：触发器 `ObjectiveCreate / ObjectiveSetName / ObjectiveSetState`，状态实时切 Active/Completed/Failed，面板同步刷新并播放动画/音效。

**特殊任务 UI 组件**：
- **The Dig**：激光钻机蓄力进度条 + "destroy 3 Xel'Naga artifacts" 计数。
- **Supreme (HotS)**：4 个 Xel'naga Relic 收集条，每解锁 1 个 Kerrigan 等级。
- **Wings of Liberty**：每关末尾的"研究所点数"汇总条（Zerg/Protoss 进度，最大 25/25）。
- **In Utter Darkness**：杀敌计数器 + 倒计时 + 神族存活 HP，三组件并列。

**世界标记**：SC2 单位头顶无明显 quest 图标，但小地图会对剧情目标建筑打"主线图标"（独特发光）。

### 1.3 其他参考

- **C&C / Red Alert 2**：右上角 `Primary / Secondary Objective` 列表；失败时全屏红字 `Mission Failed`。开场全屏 EVA briefing 文字页。
- **AOE2 DE**：右下角 objectives 标签按钮，主目标紫色徽章，次目标绿色，失败红色，已完成划线灰化。任务更新时左下角弹 `New Objective` toast + 钟声音效，约 4 秒淡出。
- **AOE4**：新增 `scout report`（侦察报告）开场卡片，告知目标位置与敌方阵营。颜色信号：人口接近上限时数字变橙，不到红。
- **Company of Heroes 2**：右上方小尺寸 objectives 列表，"clean, clear, and inoffensive"。Primary 金色 ★ 图标，Secondary 银色勋章。屏幕顶部居中弹 toast + 阵营语音（`Primary objective updated`），无堆叠——新 toast 替换旧的。
- **Northgard**：左上方 quest tracker，主任务用斧头/盾牌图标，支线用卷轴，lore event 用紫色符文。长程事件（Famine / Blizzard）在右上角挂**回合数倒计时徽章**（`5 turns left`）。
- **Stormgate**：HUD 在 0.5.0 patch 直接移除顶栏——社区反馈"top bar 占用过多屏幕"。战役 toast 用屏幕居中滑入 banner + 阵营语音。
- **ZeroSpace**：每关 1 主目标 + N side objectives + 1-3 成就。UI 比 SC2 更现代（字体、配色、可读性）。
- **8-Bit Armies**：极简——开场全屏 objective 文字页，进行中屏幕右上角只显示一行 primary objective。完成按完成度给 1-3 星，silver objective 解锁装备。

---

## 二、试错教训

### 2.1 验证为好的设计

1. **目标面板靠角落（右上/右下），不要占顶部中央** — Stormgate 移除顶栏、CoH2 右上小型 tracker 都被社区认可为"clean"。
2. **主/次目标用图标 + 颜色双重区分** — AoE 紫绿、CoH 金银勋章、Northgard 斧头/卷轴/符文。形状识别比读字快。
3. **toast 配专属音效** — C&C EVA、CoH 阵营语音、AoE 钟声。音效能预判 toast 类型。
4. **toast 支持手动关闭 + 自动淡出双轨** — Northgard 6 秒淡出但允许点 X 关闭。
5. **完成态明确化（划线灰化）** — AoE 已完成目标划横线 + 灰化。
6. **百分比/血量类用进度条** — SC2 The Dig 激光进度条被验证是经典。

### 2.2 验证为坏的设计

1. **CoH3 的 objectives 面板比 CoH2 退步** — 玩家反馈"cluttered、distracting"，不该牺牲简洁度。
2. **toast 堆叠超过 3 条就乱** — 多数游戏最多堆 2-3 条，超出排队或丢弃旧的。
3. **顶栏占用太多屏幕** — Stormgate 0.5.0 直接移除。"动态出现 + 自动隐藏"比"常驻顶栏"更受欢迎。
4. **WC3 任务面板过长被吐槽** — Reforged 后任务描述超过 ~6 行奖励信息会被截断。单任务描述应控制在 3-4 行 + 单行 reward 区。
5. **SC2 Bonus Objective 若与 Primary 颜色一致容易漏做** — 社区强烈偏好 Bonus 用绿/灰色调区分。
6. **SC2 多阶段目标直接替换文字会让玩家迷茫** — 应有 ~0.5s 淡入 + 音效提示 `New Objective`。
7. **WC3 cinematic 任务提示停留 5s 以上会盖住战斗 HUD** — 现代玩家更接受 3s 短提示。
8. **没有屏外方向指示，玩家迷路** — 多个 RTS 玩家抱怨"不知道目标在哪"。脉冲小地图点 + 屏幕边缘箭头是必备。

---

## 三、对本项目的启发（简版，详见设计草案）

1. **统一任务数据模型**：所有 VictoryCondition 子类产出的目标用统一 schema：`{id, title, description, state, kind, progress_format, progress_value, target_value, marker, ...}`。当前各子类自己拼字符串（`"Kill: " + category`、`OBJ_KILL_COUNT` 翻译里直接塞 `%d/%d`）需要重构成结构化数据。
2. **任务事件提示系统独立于任务面板**：新增 `MissionEventBus`（toast）系统，触发 `mission_event_emitted(type, payload)` 信号。任务面板只负责常驻显示，toast 负责瞬时提示。
3. **动态组件库**：列出本项目需要的组件类型（文字进度、横向进度条、圆形倒计时、HP 条、计数图标、状态徽章），让任务面板按 `progress_format` 字段动态选择渲染器。
4. **任务面板靠右上角**（已是当前位置）：维持。新增折叠按钮、Bonus 折叠组。
5. **音效占位**：接到任务、完成、失败三态各自独立音效。

---

## 四、来源

- WC3：
  - [Hive Workshop - Color Tags](https://www.hiveworkshop.com/threads/warcraft-iii-color-tags-and-linebreaks.31386/)
  - [World Editor Tutorials - Exploring Quests](https://world-editor-tutorials.thehelper.net/cat_usersubmit.php?view=163278)
  - [Quest message - Hive Workshop](https://www.hiveworkshop.com/threads/quest-message.267570/)
- SC2：
  - [SC2Mapster Triggers/Functions](https://sc2mapster.fandom.com/wiki/Triggers/Functions)
  - [Galaxy API Reference](https://mapster.talv.space/galaxy/reference)
  - [StarCraft Wiki - Supreme](https://starcraft.fandom.com/wiki/Supreme)
  - [Liquipedia Campaign](https://liquipedia.net/starcraft2/Campaign)
- AOE：
  - [Steam 社区 - Display Objectives](https://steamcommunity.com/app/813780/discussions/0/1743392703800650386/)
  - [AoE 论坛 - Scout Reports](https://forums.ageofempires.com/t/custom-campaign-win-conditions-scenario-instructions-and-scout-reports/79387)
  - [Maguro AoE4 UI](https://www.maguro.one/2021/12/aoe4.html)
- CoH：
  - [Reddit CoH2 vs CoH3 UI](https://www.reddit.com/r/CompanyOfHeroes/comments/vxjkyc/ui_elements_comparison_coh2_vs_coh3/)
  - [COH2.org Ardennes Assault Review](https://www.coh2.org/news/28132/company-of-heroes-2-ardennes-assault-review)
- Stormgate：
  - [Patch 0.5.0 - 移除顶栏](https://playstormgate.com/news/stormgate-update-0-5-0)
  - [Reddit Top Bar UI](https://www.reddit.com/r/Stormgate/comments/1ettoki/top_bar_ui_opinion_reduces_quality_of_life/)
- 其他：
  - [ZeroSpace Wiki Campaign](https://zerospace.fandom.com/wiki/Campaign)
  - [8-Bit Armies Achievements Wiki](https://8bitarmies.fandom.com/wiki/Achievements)
  - [Microsoft Fluent 2 Toast Guidelines](https://fluent2.microsoft.design/components/web/react/core/toast/usage)
  - [Game UI Database - Notification: Objective](https://www.gameuidatabase.com/index.php?scrn=156)

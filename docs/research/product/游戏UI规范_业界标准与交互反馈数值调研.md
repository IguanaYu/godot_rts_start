# 游戏 UI 规范 — 业界标准结构与交互反馈数值调研

> 数据源: GameAnalytics Game UX Style Guide / Material Design 2-3（states + motion tokens）/ NN/g（Button States / Tooltip / Animation Duration）/ PatternFly / Xbox XAG / SC2·AoE 实测与社区 / Wildmarch devlog 等，全部来源见文末
> 采集日期: 2026-08-15
> 用途: 回答 T4 A.2「UI 规范」两个问题——① 业界一份专业游戏 UI 规范包含哪些维度（避免我们自己漏维度）；② 交互态/Tooltip/报错提示/动效时长四个面的标准数值（现有决策完全没覆盖的面）。调研产出 → [UI设计规范.md](../../standards/UI设计规范.md)
> 关联: 前作 [游戏UI设计定式_跨游戏与设计系统调研](游戏UI设计定式_跨游戏与设计系统调研.md)（管布局/占比，2026-08-08 拍板 11 条决策的依据）；本篇管**结构与交互**，不重复布局结论

---

## 0. 一句话总结

一份专业游戏 UI 规范 = **六层结构**（信息架构 / 视觉基础 / 组件 / 交互 / 动效 / 无障碍本地化）；本项目现有决策集中在视觉基础层（~70%），**交互层与动效层完全空白**，而这两个空白恰好有现成的业界标准数值可抄——Material 状态层透明度、tooltip 300ms、动效三档 token（100/250/400ms）——不需要发明，只需要裁剪。

---

## 1. 元问题：业界 UI 规范的六层结构

综合 GameAnalytics（Gameloft/Digit 资深 UX 总监框架）、Medium 七段式、Material Design 3 分层：

| 层 | 管什么 | 业界共识要点 | 本项目现状 |
|---|---|---|---|
| **A 信息架构** | 文档目的 / 产品定位 / 屏幕流 / **UX 核心原则 3-6 条** / Red Routes 高频路径 | "90% 的工作室不投入专门的 UX style guide"（GameAnalytics）；Red Routes = 玩家最高频操作路径，优先保证流畅 | ❌ 缺（无原则条文、无屏幕流） |
| **B 视觉基础** | 字体 / 色彩（含**功能色**）/ 图标 / 间距 token / 形状风格 | 间距必须是可复用 token；功能色（警告/错误/成功）与主色分开定义 | ✅ ~70%（字号/字体/图标/风格有；**功能色板、间距 token 缺**） |
| **C 组件** | 基础组件（按钮/弹窗/列表）/ 模板（底部栏）/ **游戏特有四分类** | Toptal 四分类：Non-diegetic（HUD）/ Diegetic（游戏内物件）/ Spatial（选中框/血条）/ Meta（震屏/受击变红） | ◐ 部分（底部栏三段是 Template 级；无组件清单） |
| **D 交互** | **五态** / tooltip / 反馈报错 / 微文案 | NN/g 五态：enabled/disabled/hovered/focused/pressed | ❌ 完全缺（本次主补） |
| **E 动效与音频** | 时长 token / 缓动选择 / 音画配对 | 进入 ease-out、退出 ease-in、屏内 ease-in-out | ❌ 完全缺（音频等 C.2） |
| **F 无障碍/本地化** | 最小字号 / 对比度 / **色盲冗余** / 文本宽度预留 | Xbox XAG：主机 1080p ≥26px、PC ≥18px；约 8% 男性色觉缺陷，禁止仅靠颜色传达信息；欧语比英文长 20-35% | ❌ 完全缺（建议写最小可行版） |

**注意**：Riot / Blizzard / Supercell 均未公开完整 UI 规范（未查到）；最接近的大厂公开资产是 Bungie GDC 演讲 "Tenacious Design and The Interface of Destiny"。开源游戏 Thrive 的 wiki 有真实公开 style guide。

### RTS 特有视角（Dave Pottinger / FrostGiant 讨论帖）

- RTS UI 三大布局范式：底栏 / 侧栏 / 浮动 widget（本项目已选底栏，前作调研拍板）
- **小地图是 RTS 最高频注视点**，位置优先锚定（本项目右下，符合惯例）
- RTS 与 app UI 最大差异：**面板/命令卡切换基本无动画（0-50ms），动效全部留给"事件"**（单位出生、升级完成）——这是抄 app 规范时最容易抄错的地方

---

## 2. 面 1 交互态 — 标准数值

### 业界基准（Material 3 状态层 + NN/g）

| 项 | 业界值 | 来源 |
|---|---|---|
| Hover 反馈 | **0ms 即时**（被动状态不许延迟）+ ~100ms 过渡 | NN/g Button States |
| Hover 视觉 | on 色叠加 **8%** 不透明度（状态层） | M3 State Layers |
| Pressed 视觉 | 叠加 **10%**（M3）/ 12%（M2） | M3 Applying States |
| Disabled 视觉 | 内容 **38%** / 容器 **12%** 不透明度 | M3 Applying States |
| 状态切换动画 | ~**100ms** | M3 motion short2 |

要点：M3 五态全部用**同一色系透明度叠加**实现，靠"变亮/变暗"而非换色——对 Tiny Swords 有限色板的项目极友好，不用为每个状态画新贴图。

### 标杆案例

- **SC2 命令卡**：热键直接印在按钮上；禁用态 = 图标压暗 + 数字变红；**资源不足时按钮变灰但仍可点击**（点击触发报错反馈）——本项目 T2 PR-1 已采用同款思路（时代锁定不 disable 让点击触发拦截飘字）。
- **冷却遮罩**：WoW/LoL/Dota2/SC2 一致惯例 = 从 12 点方向**顺时针扫入填充**，就绪瞬间遮罩消失（可加 100ms 闪白）。未查到成文标准，实拍一致。

### 对本作启示

720p 小按钮（72×72 wrapper），M3 的 2%-8% 视觉差可能不可感知，**建议放大到 hover 12% / pressed 20%**；本项目现有 button_factory hover 1.12x + modulate 1.15 与"状态层叠加"是同效手段（变亮），可保留并规范统一；三套禁用态写法（0.6 灰 / 0.5 alpha / 变色数字）应收敛为一套。

---

## 3. 面 2 Tooltip — 标准数值

### 业界基准

| 项 | 业界值 | 来源 |
|---|---|---|
| 出现延迟 | **300ms**（PatternFly 默认；共识区间 300-500ms） | PatternFly / UX SE |
| 出现动画 | 100ms 内显示完毕 | UX SE hover intent |
| 消失延迟 | **100-1000ms**（防闪烁；VS Code 可配置） | VS Code #221607 |
| 进阶 | 鼠标移入 tooltip 不应消失（桥接） | CodeMirror 讨论 |
| 位置 | 锚定元素旁，**不得遮挡关联内容** | NN/g Tooltip Guidelines |

### NN/g 三条铁律

1. **任务必需信息不许藏进 tooltip**——建造消耗属于此类，应常驻按钮上（本项目已做到：CostLabel 常驻 ✅）
2. 内容简短
3. **全站一致**：要么全有要么全无

### 标杆案例

**SC2 命令卡 tooltip 结构**：名称 → 消耗（动态字段实时取值）→ 热键 → 描述，由 Button 数据类型结构化生成（SC2Mapster Data/Buttons）。

### 对本作启示

本项目两套 tooltip（建造 0.8s / 技能 0.6s）**都偏慢**且不一致，统一 **300ms**；内容结构对齐 SC2 四段式（名称→消耗→热键→描述——现有格式 `%s (%s)\n$%d [%s]` 已接近，规范时补描述位）；消耗已常驻按钮，符合 NN/g 铁律 1。

---

## 4. 面 3 报错/提示 — 标准数值

### 业界基准

| 场景 | 业界做法 | 来源 |
|---|---|---|
| 资源不足（SC2） | **多通道**：种族语音（"Not enough minerals — **mine more minerals**"，报错附带解法）+ 错误音效；职业选手几乎不关（关它会连坐关掉 supply 警告） | r/starcraft |
| 资源不足（AoE1/2） | 语音报错（language.dll 字串 ID 3001-3005）+ beep | AoE language.dll dump |
| 建造位置无效 | **绿/红 ghost 实时变色 + 一行原因** | Wildmarch devlog |
| Toast 时长 | **2-7s**（Friedman）；M3 Snackbar 4s 短 / 10s 长；两行 20 词实测 ~3.2s；无障碍公式 5s + 每 120 词 +1s | Friedman / M3 / UX SE |
| Toast 堆叠 | 垂直堆叠上限 5 条（Halstack）或只允许 1 条后者顶替（Canva） | Halstack / Canva |
| 波次预警 | 无硬数值；惯例 = **常驻波次信息块**（可悬停查备战细节）+ 来袭瞬间提示，不做一次性 toast | Defender's Quest post-mortem |

### 对本作启示

- 资源不足三通道轻量组合：短促错误音（等 C.2）+ 文字**含解法**（现有"金币不足（需要 150）"已含数值 ✅）+ 消耗数字闪红 200ms。现有单通道红字可保留，音效与按钮闪是补强项。
- SC2 的"故意略烦人"是催促修经济的手段；本作轻度 PVE 可降低强度但保留音效通道。
- 波次预警本作已有"常驻倒计时（objectives_panel）+ 世界 marker + 小地图红点"，结构上已对齐 Defender's Quest 结论，缺的只是来袭瞬间的横幅（3-4s）。
- 本作飘字 2.0s 漂浮 + 1.2s 淡出（总 3.2s）正好落在 toast 实测舒适区。

---

## 5. 面 4 动效时长 — 标准数值

### 业界基准（M2/M3 duration tokens + NN/g）

| 场景 | 业界值 | 来源 |
|---|---|---|
| 微交互（hover/press/选中） | **50-200ms**（short1-4 = 50/100/150/200） | M3 tokens-specs |
| 面板/组件展开收起 | **250-400ms**（medium1-4）；M2 卡片展开 300ms / 收起 250ms | M3 / M2 Speed |
| 大型容器转换 | 450-600ms（long1-4） | M3 |
| NN/g 共识 | 100-500ms 合理；**100ms 感知为即时**；1s 是注意力流上限 | NN/g Animation Duration |
| 缓动选择 | **进入 ease-out / 退出 ease-in / 屏内移动 ease-in-out** | M3 Easing |
| 高频操作 | RTS 惯例：连续建造/切 tab/框选 **无动画或 ≤50ms**（SC2/AoE2 实测） | 业界惯例，未查到成文标准 |

### RTS 关键差异（本调研最重要的裁剪依据）

**SC2/AoE2 面板与命令卡切换基本无动画（0-50ms 级），动效全部留给"事件"**（单位出生、升级完成）。抄 app 规范（250ms 面板动画）到 RTS 高频操作上是错的——M2 Reply 案例也是导航过渡从 300ms 减到 250ms，高频路径永远取更短值。

### 对本作启示

现有值对照：按钮 0.12s ✅ 在区间内；飘字 0.3s 弹出 ✅；解锁闪 0.5s 略长（事件级可接受）；暂停菜单/T3 弹窗/结算**硬切无过渡**——按 RTS 惯例这不算缺陷，可保持，或给结算页加 400ms 遮罩淡入。规范定三档 token：**fast=100ms / medium=250ms / slow=400ms**，附"高频操作 ≤50ms 或无动画"特例条款。

---

## 6. 结论：可直接采用的数值包（18 项）

| # | 项目 | 建议值 | 依据 |
|---|---|---|---|
| 1 | Hover 反馈延迟 | 0ms 即时 + 100ms 过渡 | NN/g + M3 short2 |
| 2 | Hover 视觉 | 变亮叠加 12%（720p 小按钮，M3 8% 放大） | M3 状态层 |
| 3 | Pressed 视觉 | 变暗叠加 20% + scale 0.90 | M3 放大（现有 button_factory 同思路） |
| 4 | Disabled 视觉 | 整体 ~40% 透明度（M3 38%）；消耗数字保留并变暗红 | M3 |
| 5 | 选中/当前 tab | 描边或角标高亮，切换 100ms | M3 short2 |
| 6 | 冷却遮罩 | 顺时针填充从 12 点起；就绪可闪白 100ms | 四游戏一致惯例 |
| 7 | Tooltip 出现延迟 | **300ms**（现 600/800 两套偏慢，统一） | PatternFly/NN/g 共识 |
| 8 | Tooltip 消失延迟 | 200ms（可移入不消失） | VS Code/CodeMirror 实践 |
| 9 | Tooltip 结构 | 名称→消耗→热键→描述；消耗常驻按钮不进 tooltip 专属 | SC2 + NN/g 铁律 |
| 10 | 资源不足反馈 | 音效 + 文字含解法 + 消耗闪红 200ms；按钮不锁死可点击 | SC2 多通道 |
| 11 | 无效放置 | ghost 红/绿实时变色 + 一行原因 | Wildmarch/RTS 惯例 |
| 12 | Toast/横幅 | 普通 3s；重要（波次来袭）4s + 常驻波次条 | M3 Snackbar 4s + 实测 3.2s |
| 13 | Toast 堆叠 | 最多 3 条，超出丢弃最旧（Halstack 5 条收严——RTS 屏幕小） | Halstack |
| 14 | 微交互动效 | 100ms，ease-out | M3 short2 |
| 15 | 面板开关 | 250ms，进入 ease-out / 退出 ease-in | M3 medium1 |
| 16 | 全屏过渡 | 400ms，ease-in-out | M3 medium4 + NN/g 上限内 |
| 17 | 高频操作节流 | 建造/tab 切换/框选 ≤50ms 或无动画 | SC2/AoE2 RTS 惯例 |
| 18 | 动效总上限 | 任何 UI 动效 ≤500ms | NN/g 1s 上限取保守半值 |

## 7. 风险与知悉项

- **最小字号**：本作 12px 低于 Xbox XAG（主机 26px / PC 18px）——720p 独占 PC 游戏非强制，但规范中应记知悉项；若未来移植主机需重排字号阶梯。
- **色盲冗余**：本作颜色语义（红错/绿成/黄警）目前仅靠颜色区分，~8% 男性玩家不可辨——至少给错误加图标或形状冗余（可在规范中定原则，实施排后）。
- **本地化宽度**：欧语比英文长 20-35%；本作中文为主 + translations.csv 已有 i18n 机制，按钮文案宽度预留规则写入规范即可。
- 抄 app 规范的最大陷阱：**面板切换动画时长不适用于 RTS 高频操作**，必须带 17 号特例条款。

---

## 追加：第 3 章视觉基础审查（2026-08-15 二次调研）

对已拍板的字号/字体/图标/间距/功能色五块做专业性验证，结论：

- **字体事实错误**：Godot 4 项目运行时默认字体是 Open Sans SemiBold（非 Noto Sans），且无 CJK 字形，中文运行时回退系统字体跨平台不一致 → 改为内嵌思源黑体（Noto Sans CJK 同字型双品牌，OFL）
- **"4pt 基线"出处错**：正确出处 Material M2 4dp baseline grid（排版 4dp / 组件 8dp），非 Apple HIG；Godot Label 也达不到真基线对齐 → 改称"4px 行高节奏"
- **12px 中文行高**：M3 行高按拉丁调校，中文多行需 1.4-1.6 倍 → 12px 档行高 16→20
- **76×76 属实但过时**：Hive Workshop/s2editor-guides 双源确认 SC2 标准，但非二次幂、72 显示仅 1.06 倍超采样 → 源图改 128×128
- **间距 4 档不够**：业界完整阶梯到 64 → 扩为 4/8/12/16/24/32/48/64
- **功能色直连美术色板是反模式**：业界三层 primitive → semantic → 组件 token，禁止直用 primitive；纯深底项目直接选深底值，"向高明度调整"删除；对比度 XAG 102（= WCAG 4.5:1 / 3:1）
- **新发现 tnum**：资源数字用 tabular figures（`opentype_features = {"tnum": 1}`）防跳动，思源黑体 CJK tnum 支持未查到需实测

来源：[Godot gui_using_fonts](https://docs.godotengine.org/en/stable/tutorials/ui/gui_using_fonts.html) / [godot-proposals #9012](https://github.com/godotengine/godot-proposals/discussions/9012) / [Source Han Sans](https://github.com/adobe-fonts/source-han-sans) / [M3 type scale](https://m3.material.io/styles/typography/type-scale-tokens) / [M2 baseline grid](https://m2.material.io/design/layout/understanding-layout.html) / [XAG 101/102](https://learn.microsoft.com/en-us/xbox/accessibility/xbox-accessibility-guidelines/101) / [Game Accessibility Guidelines](https://gameaccessibilityguidelines.com/use-an-easily-readable-default-font-size/) / [Hive Workshop SC2 icons](https://www.hiveworkshop.com/threads/importing-custom-icons-into-sc2.166907/) / [s2editor-guides](https://s2editor-guides.readthedocs.io/New_Tutorials/04_Data_Editor/075_Buttons/) / [NYS Design System tokens](https://designsystem.ny.gov/foundations/tokens/) / [WCAG 1.4.3](https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum.html) / [godot #23951 tnum](https://github.com/godotengine/godot/issues/23951)

## 来源

结构层（六层框架）：
- [GameAnalytics — Game UX Style Guide](https://www.gameanalytics.com/blog/game-ux-style-guide) / [Medium — UI Style Guide 七段式](https://medium.com/designers-thoughts/a-must-for-all-complex-user-facing-digital-products-ui-style-guide-439dbcdb1bb9) / [Material Design 3](https://m3.material.io/) / [Toptal 游戏四分类] / [Xbox XAG 101](https://learn.microsoft.com/en-us/xbox/accessibility/xbox-accessibility-guidelines/101) / [Keywords 本地化](https://www.keywordsstudios.com/en/about-us/news-events/news/a-step-by-step-guide-to-game-localization/) / [Gridly 本地化 UI](https://www.gridly.com/blog/game-ui-design-localization-best-practices/) / [Bungie Destiny UI GDC](https://gdcvault.com/play/1023460/) / [Thrive wiki style guide](https://wiki.revolutionarygamesstudio.com/wiki/Visual_Style_Guide) / [r/FrostGiant RTS UI](https://www.reddit.com/r/FrostGiant/comments/mi6bct/rts_ui_design_deep_dive/) / [Dave Pottinger 访谈](https://waywardstrategy.com/2015/05/04/lets-talk-rts-user-interface-part-1-interview-with-dave-pottinger/) / [Game UI Database](https://www.gameuidatabase.com/) / [Interface In Game](https://interfaceingame.com/)

数值层（四面标准）：
- [M3 State Layers](https://m3.material.io/foundations/interaction/states/state-layers) / [M3 Applying States](https://m3.material.io/foundations/interaction/states/applying-states) / [M3 Easing & Duration Tokens](https://m3.material.io/styles/motion/easing-and-duration/tokens-specs) / [M2 Speed](https://m2.material.io/design/motion/speed.html) / [M2 Customization](https://m2.material.io/design/motion/customization.html)
- [NN/g Button States](https://www.nngroup.com/articles/button-states-communicate-interaction/) / [NN/g Tooltip Guidelines](https://www.nngroup.com/articles/tooltip-guidelines/) / [NN/g Animation Duration](https://www.nngroup.com/articles/animation-duration/)
- [PatternFly Tooltip](https://www.patternfly.org/components/tooltip/design-guidelines) / [UX SE tooltip delay](https://ux.stackexchange.com/questions/358/how-long-should-the-delay-be-before-a-tooltip-pops-up) / [VS Code hide delay](https://github.com/microsoft/vscode/issues/221607) / [master.dev skip-delay](https://master.dev/blog/tooltips-need-a-delay-and-then-they-need-to-skip-it/)
- [SC2Mapster Data/Buttons](https://sc2mapster.fandom.com/wiki/Data/Buttons) / [r/starcraft 矿石提示](https://www.reddit.com/r/starcraft/comments/rwbo2/why_do_pros_so_rarely_turn_off_not_enough_minerals/) / [AoE language.dll](https://gist.github.com/phrohdoh/abbf21622e9e20cc8e3cc3ae7948ce96) / [Wildmarch 放置系统](https://www.wildmarch.net/devlog/building-on-the-battlefield/)
- [Friedman Toast 准则](https://www.linkedin.com/pulse/toasts-snackbars-ux-guidelines-vitaly-friedman-6peze) / [M3 Snackbar 时长](https://proandroiddev.com/how-to-set-custom-duration-for-material3-snackbar-in-jetpack-compose-497fbc491f8b) / [UX SE toast](https://ux.stackexchange.com/questions/11203/how-long-should-a-temporary-notification-toast-appear) / [Canva Toast](https://www.canva.dev/docs/apps/design-guidelines/toasts/) / [Defender's Quest](https://www.fortressofdoors.com/optimizing-tower-defense-for-focus-and-thinking-defenders-quest/) / [Gamine AI 游戏 UI 动效](https://gamineai.com/blog/game-ui-animation-creating-smooth-engaging-interface-transitions)

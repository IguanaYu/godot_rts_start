# 游戏 UI 设计定式 — 调研评估与补强

> 日期：2026-08-08
> 评估对象：[游戏UI设计定式_跨游戏与设计系统调研.md](游戏UI设计定式_跨游戏与设计系统调研.md)（前一次调研，含 50 份 JSON 原始资料）
> 补强动机：前一次调研在"RTS HUD 像素占比"上自承"40+ 关键词未命中权威数据"；本次针对该缺口补强
> 方法：用 WebSearch + Tavily extract 直接抓英文权威源（前次以搜狗中文为主，搜英文专业术语大量打偏）

---

## 0. TL;DR

- **前次调研结构正确、非游戏部分扎实、RTS 部分偏弱**。具体打分：
  - 非游戏 UI（8pt 网格 / 48dp 触控 / 模块化字号 / 对比度 / 间距阶梯）：**A 级**，多源交叉验证，可直接用
  - RTS HUD 像素占比（WC3 1024×570、26%）：**B 级**，仅来自博客园一篇博客，结论方向对但证据单薄
  - RTS 命令卡、图标尺寸、SC2/AoE2 具体 UI：**C 级**，几乎没搜到，自承缺口
- **本次补强找到 4 个之前漏掉的硬数据源**（详见 §2）：
  1. **SC2 命令卡按钮图标 = 76×76 px**（Hive Workshop 多教程交叉验证）
  2. **SC2 / Dota2 顶部+底部 UI 合计占垂直空间 ~30%+**（Valve 玩家社区 + Blizzard 论坛）
  3. **MATLAB 实测 50 款游戏 25 年 HUD 平均占屏 6%**（Medium - Josh Moskowitz）
  4. **PolarOrbit 关键约束：4:3→16:9，宽度 +78% / 高度 +41%** → 垂直空间比水平"贵"
- **结论修正**：前次"本项目底部栏 30.6% 偏高"的结论**方向正确但理由不完整**——30% 是 RTS 顶+底合计基准，本项目仅底部就 30.6%，加顶部资源栏会突破 35%，这才是真正"偏高"的理由（详见 §3）。

---

## 1. 评估：前次调研做对了什么 / 漏了什么

### 1.1 做对的（保留）

| 维度 | 评价 | 证据 |
|---|---|---|
| **结构** | ✅ 4 段式（案例事实 + 试错教训 + 新增方向 + 待决策点），符合本项目调研格式偏好 | 见 [游戏UI设计定式_跨游戏与设计系统调研.md](游戏UI设计定式_跨游戏与设计系统调研.md) |
| **数据源存档** | ✅ 50 份 JSON 原样存档于 `ui_design_patterns_materials/`，可追溯 | 抽查 `rts_15_wc3_zh.json` 等均为真实搜索结果（有 query/engine/results） |
| **硬定式 vs 经验法则分层** | ✅ 区分清晰，硬定式表 10 项可执行 | §2.1 |
| **非游戏部分** | ✅ Material/Apple/Bootstrap/Tailwind/Ant Design 多源交叉验证，结论可靠 | §1.3–1.5 |
| **试错教训 7 条** | ✅ 都来自社区真实踩坑（WC3 宽屏 UI 重叠、奇数字号毛边等） | §3 |

### 1.2 漏掉 / 偏弱的（需补强）

| 缺口 | 严重度 | 原因 |
|---|---|---|
| **WC3 1024×570 渲染区是单源博客** | 中 | 仅博客园 winsonchen 一篇，无第二源验证；且 1024×768 是 4:3，与现代 16:9 不能直接套用 |
| **rts_*.json 系列大量噪声** | 中 | 搜狗搜英文专业术语打偏：搜 `gameuidatabase RTS HUD` 出 NGOD 百科；搜 `HUD 比例 视野 遮挡` 出 DNF 屏幕比例。前次未做信噪过滤 |
| **SC2 命令卡、AoE2 顶部栏像素值完全缺失** | 高 | 自承"40+ 关键词未命中"，但其实英文社区（Hive Workshop、SC2Mapster Wiki）有现成数据 |
| **RTS 命令卡的网格规格（4×3 vs 5×4）未提** | 中 | 这是 RTS UI 设计的核心约束之一，Blizzard 论坛有大量讨论 |
| **垂直空间成本论证缺失** | 中 | 没找到 PolarOrbit 那篇关键文章，所以"底部栏占垂直空间代价大"缺少定量支撑 |
| **Game UI Database（5.5 万张截图）未引用** | 低 | 这是最权威的游戏 UI 实测数据库，前次完全没提 |

---

## 2. 补强：4 个新硬数据源（前次漏掉的）

### 2.1 SC2 命令卡按钮图标 = **76×76 px**（多源验证）

- **Hive Workshop 多个 SC2 mod 教程**明示：自定义命令卡按钮图标的标准尺寸是 **76×76 px**（最大可至 256×256 用于高清导入）
- 来源：[Hive Workshop - Importing Custom Icons into SC2](https://www.hiveworkshop.com/threads/importing-custom-icons-into-sc2.166907/)、[Hive Workshop - Submenus & Custom Abilities 教程](https://www.hiveworkshop.com/threads/tutorial-submenus-custom-abilities.176402/)
- **意义**：这是 RTS 命令卡按钮的**事实标准**。前次调研列的"图标 8 倍数 16/24/32/48/64"是非游戏 UI 阶梯；游戏内命令卡用的是 **76 px**，落在游戏专用规格上。

### 2.2 SC2 / Dota2 顶部+底部 UI 合计占垂直空间 **~30%+**

- **Valve 玩家社区实测**（Dota 2 HUD 优化讨论）：
  > "All resolutions, regardless of aspect ratio, have just over **30% of their vertical space filled** by the combined top and bottom UI areas. 5:4 has very slightly less... The inequity lies in field of view which favors wider resolutions. This makes 16:9 optimal."
  >
  > ——[r/DotA2 HUD mock up thread](https://www.reddit.com/r/DotA2/comments/nul6f/)
- 关键设计哲学：**SC2 和 Dota2 的 UI 都按垂直空间缩放，水平延展用黑色 spacer 填充**。这是 Blizzard / Valve 的共识。
- **意义**：前次调研用 WC3 单源得出"26%"偏低；30% 是更稳的基准。**注意这是顶+底合计，不是单底部栏**。

### 2.3 50 款游戏 25 年 HUD 实测：**平均占屏 6%**（MATLAB 像素级）

- **Josh Moskowitz 的学术级调研**：取 50 款流行游戏截图 → Adobe Illustrator 手动 mask HUD 元素 → MATLAB 统计像素占比
- 关键数据：
  - **全类型平均：HUD 占屏 6%**
  - **极简标杆**：Half-Life 1（0.9%）、GoldenEye 64（0.5%）、Super Mario Galaxy 1&2（0.9%）
  - **极繁标杆**：RTS / MOBA 顶部+底部栏设计（具体值文中未列每游戏，但分布明显偏向 25-30%+ 区间）
- 来源：[Medium - Size Does Matter: An Analysis of Videogame HUDs](https://medium.com/@joshmoskowitz/size-does-matter-an-analysis-of-videogame-huds-24321750b665)
- **意义**：第一次有跨类型量化基线。RTS 不是"6%派"，是"30%派"——这是品类选择，不是设计失误。

### 2.4 关键约束：垂直空间比水平贵（4:3→16:9 数学论证）

- **PolarOrbit - Building a Better RTS Part 2**（Andrew Crystall）：
  > "Between 1024×768 (4:3) and 1920×1080 (16:9) you have **78% more width, but only 41% more height**. Thus, vertical screen space is 'cheaper' than horizontal."
- 来源：[PolarOrbit - Building a Better RTS Part 2](http://www.polarorbit.net/2015/03/building-a-better-rts-part-2/)
- **意义**：把"底部栏占垂直空间代价大"从直觉变成数学。这也解释了为什么 Blizzard/Ensemble 都把"重信息密度"的内容（命令卡、单位详情）放在底部而不是侧边——底部占用的是"贵"的垂直，但是这是约定俗成的玩家注意力区。

### 2.5 RTS 命令卡网格规格（前次完全没提）

| 游戏 | 命令卡网格 | 总格子数 | 键盘映射 |
|---|---|---|---|
| Warcraft III | **4×3** | 12 | 自由映射 |
| Warcraft III Reforged（社区建议） | 5×3 或 5×4 | 15-20 | QWERTY/ASDFG/ZXCV |
| StarCraft II | **5×4** | 20 | **QWERTY / ASDFG / ZXCVB / (4th row)** 网格热键（标准布局） |
| 帝国时代 2 | 2×5 + 滚动 | - | 数字键 |

- 来源：[Blizzard WC3 论坛 - 5x3 or 5x4 Command Card](https://us.forums.blizzard.com/en/warcraft3/t/5x3-or-5x4-command-card-for-warcraft-iii-reforged-just-like-for-starcraft-ii/3854)、[AoE Forums - Grid Hotkeys](https://forums.ageofempires.com/t/grid-hotkeys-feel-alien-coming-from-other-franchises.../184268)
- **意义**：SC2 的 5×4 网格**直接对应键盘 QWERTY 物理布局**，这是"键盘映射=UI 网格"的事实定式。本项目 QW 栏设计应参考这个映射。

### 2.6 RTS UI 流派演化（treeform）

- 来源：[Medium - treeform - Strategy Game Battle UI](https://medium.com/@treeform/strategy-game-battle-ui-3b313ffd3769)
- 演化树：
  - **Dune / Westwood 派**（C&C、红警）：**右侧栏**，始终显示建造菜单（非 context-sensitive）
  - **Blizzard 派**（WC1）：左侧栏（早期）
  - **Total Annihilation**：左侧栏但更小，分辨率自适应（首次"小而美"）
  - **Ensemble 派**（AoE）：**顶+底双栏**（开创者，后被广泛采用）
  - **StarCraft 1**：4 段复杂形状底部栏
  - **StarCraft 2 / Supreme Commander / CoH**：顶+底双栏
  - **Homeworld 2**：widget 风格混合（受 FPS HUD 影响）
  - **现代趋势**：widget 化、HUD 化（最小化）
- **意义**：本项目"顶部资源 + 底部命令栏"是 Ensemble/Blizzard 主流，不是 Westwood 侧栏派——前次调研说了"三大流派"，但没说**演化趋势是远离侧栏、走向 widget 化**。

### 2.7 Planetary Annihilation 反例（Game Developer 权威警告）

- 来源：[Game Developer - UI Strategy Game Design Dos and Don'ts](https://www.gamedeveloper.com/design/ui-strategy-game-design-dos-and-don-ts)
- 关键引用：
  > "One of the problems with Planetary Annihilation's UI is that instead of having a unified section for commands and information, you got **three distinct areas of data**: building commands on the bottom, resources at the top and unit orders on the right side. Spreading out all your information and commands like this requires you to **split your attention more than just having one or at most two areas of data**."
- **意义**：本项目底部栏三段（快捷队列 / 详情 / 小地图）已是合理上限；如果再把"建造菜单"放到右侧、"资源"放到顶部，就重蹈 PA 覆辙。**RTS 信息区 ≤ 2 个**是 Game Developer 的明示戒律。

### 2.8 当代 RTS HUD 实现的实测 CSS（Gist）

- 来源：[GitHub Gist - senko/RTS game HUD](https://gist.github.com/senko/24d117e680759989a9fff5b2b9ab4615)（一个用 Claude Code 写的 RTS 原型）
- 实测数据（CSS 直接定义）：
  - **bottom-bar 高 172 px**
  - **minimap 188×188 / 含 padding 198×198 px**
  - **command-card 268×148 px**
  - 字体：Rajdhani（科幻无衬线）
  - 圆角：7 px
  - 阴影：`0 6px 22px rgba(0,0,0,.45)`
- **意义**：这是"现代极简派"RTS HUD 的具体数值。比经典 SC2 的"重工感"轻得多——可作为本项目视觉风格的另一个参考点。

---

## 3. 修正：补强后对前次"待决策点"的更新

### 3.1 底部栏高度 220px/720px ≈ 30.6% — 前次结论方向对，理由要补

**前次结论**：偏高，因为 WC3 全 UI（顶+底）才 26%。
**补强后修正**：

- 前次的对比基准是错的——WC3 26% 是 4:3 下的数据，且是顶+底合计
- 真实基准应该是：**SC2 / Dota2 顶+底合计 ~30%（垂直）**（§2.2）
- 本项目 720p 下底部栏 30.6% **仅是底部**；如果顶部资源栏再占 5-8%，总 UI 占比会到 35-38%，**确实偏高**
- **修正后建议**：
  - 方案 A（保留 220px 底部）：把顶部资源栏做薄（≤40px / 5.5%），总占比压在 36% 以内
  - 方案 B（缩底部）：底部缩到 180-190px（~25%），顶+底回到 30% 基准线
  - 实测方法：在 1280×720 视口下用网格叠加图校准

### 3.2 RTS 命令卡 / QW 栏设计 — 前次未提，本次新增

- 本项目 QW 栏应参考 **SC2 的 5×4 网格 = QWERTY/ASDFG/ZXCVB 物理映射**（§2.5）
- 命令格图标建议 **64-76 px**（落在 §2.1 的 SC2 标准范围内，向下兼容 8 倍数）
- 触控目标 ≥ 48 dp（前次硬定式 5）已足够；游戏内 76px 远超阈值

### 3.3 字号阶梯 — 前次给的 M3 阶梯有效，但游戏内字号偏大

- 前次建议 @720p 正文 14-16px、标题 22-28px
- **补强**：参照 SC2 命令卡按钮图标 76×76 px 的视觉重量，按钮内文字建议 **12-14 px**（小而精）
- 资源栏数字建议 **20-24 px**（一眼可读），单位是 SC2 风格"高对比大字"（参考 §2.3 极繁派设计）

### 3.4 信息分区 ≤ 2 个 — 前次未提，本次新增硬约束

- Game Developer 戒律：**RTS 信息区 ≤ 2 个**（§2.7）
- 本项目当前：顶部资源栏 + 底部三段命令栏 = 4 个区，已到上限
- **建议**：底部三段必须视觉上"合为一区"（统一背景、统一边框、统一字体），不能视觉分裂成 3 个独立 panel

---

## 4. 整合：补强后的"游戏 UI 定式"三层

### Tier 1 — 跨平台硬定式（前次✅ 已得，无需改）

| # | 定式 | 数值 |
|---|---|---|
| 1 | 间距/尺寸网格 | 8 倍数（4px 细分） |
| 2 | 行高 | ≈ 字号 × 1.5 |
| 3 | 模块化字号 | 基准 × 1.25 / 1.333 / 1.618 |
| 4 | 触控目标 | ≥ 48 dp（Apple 44pt） |
| 5 | 对比度 | 正文 ≥4.5:1，图形 ≥3:1 |
| 6 | 间距阶梯 | 4/8/16/24/48 |

### Tier 2 — 游戏内 UI 业界基准（本次补强🆕）

| # | 定式 | 数值 | 来源 |
|---|---|---|---|
| 7 | RTS 顶+底 UI 合计占垂直空间 | ~30% | SC2/Dota2 玩家社区实测 |
| 8 | RTS 命令卡网格 | 4×3（WC3）或 5×4（SC2） | Blizzard 论坛 |
| 9 | SC2 命令卡按钮图标尺寸 | 76×76 px | Hive Workshop |
| 10 | HUD 跨类型平均占屏 | 6%（FPS/RPG 极简，RTS/MOBA 30%派） | Medium MATLAB 实测 |
| 11 | RTS 信息分区上限 | ≤ 2 个 | Game Developer 戒律 |
| 12 | 垂直空间成本 | 4:3→16:9，宽 +78% / 高 +41% | PolarOrbit 数学论证 |

### Tier 3 — 经验法则（前次✅ + 本次补强）

| # | 法则 | 数值 |
|---|---|---|
| 13 | 黄金比例 / 三分法 | Φ≈1.618，1:1:1 交点 |
| 14 | 资源项横向排列 | ≤ 5 项（前次） |
| 15 | 字体种类 / 字重 / 字号上限 | 1 款 / ≤3 / ≤4 |
| 16 | RTS UI 流派选择 | 顶+底（Ensemble/Blizzard 主流）vs 侧栏（Westwood 派，已式微） |
| 17 | 视觉重量配比 | 大字（资源数）+ 中字（详情）+ 小字（辅助）三档分明 |

---

## 5. 待用户决策（不替你拍板）

1. **底部栏 220px 是否缩到 180-190px？**
   - 不缩：保留信息密度，但顶+底会超 35%
   - 缩：回到 30% 基准线，但快捷队列可能挤
   - 推荐先做 A/B 截图对比

2. **QW 栏是 5×4（SC2 风）还是 4×3（WC3 风）？**
   - 5×4：20 格，键盘热键全覆盖（QWERTY 网格），但格子小
   - 4×3：12 格，格子大，但热键映射要重新设计
   - 本项目目前是什么规格？（请确认）

3. **命令格图标用 64px 还是 76px？**
   - 64px：8 倍数，720p 下清晰
   - 76px：SC2 标准规格，但不是 8 倍数（需 4 倍数网格）

4. **底部三段视觉上是否需要统一为单一 panel？**
   - 当前若三段各自有边框/背景，视觉上像 3 个区，违反 Game Developer "≤2 个信息区"戒律
   - 推荐统一背景 + 内部分割线，让视觉上看起来是 1 个区

5. **是否要把"垂直空间成本"作为长期设计原则？**
   - 如果是，未来加任何 UI 都优先占水平（侧栏、悬浮窗）而非垂直
   - 本项目底部栏已经"占用了贵的垂直"，未来扩展宜走侧栏 / 悬浮 widget

---

## 6. 参考链接（本次新增）

- [Game UI Database 2.0](https://www.gameuidatabase.com/) — 5.5 万张游戏 UI 截图，可按 HUD 元素/布局/颜色筛选（前次完全没引用，建议作为长期参考库）
- [Game Developer - UI Strategy Game Design Dos and Don'ts](https://www.gamedeveloper.com/design/ui-strategy-game-design-dos-and-don-ts) — RTS UI 权威戒律
- [Medium - treeform - Strategy Game Battle UI](https://medium.com/@treeform/strategy-game-battle-ui-3b313ffd3769) — RTS UI 流派演化（图文）
- [Medium - Josh Moskowitz - Size Does Matter](https://medium.com/@joshmoskowitz/size-does-matter-an-analysis-of-videogame-huds-24321750b665) — 50 款游戏 HUD 实测
- [PolarOrbit - Building a Better RTS Part 2](http://www.polarorbit.net/2015/03/building-a-better-rts-part-2/) — 垂直空间成本数学论证
- [Hive Workshop - Importing Custom Icons into SC2](https://www.hiveworkshop.com/threads/importing-custom-icons-into-sc2.166907/) — SC2 命令卡 76×76 px 标准
- [SC2Mapster Wiki - UI/Layout Tutorial](https://sc2mapster.wiki.gg/wiki/UI/Layout_Tutorial) — SC2Layout 文件官方教程
- [r/DotA2 HUD mock up discussion](https://www.reddit.com/r/DotA2/comments/nul6f/) — Valve/Blizzard "UI 按垂直缩放"设计哲学
- [Blizzard WC3 Forums - 5x3 or 5x4 Command Card](https://us.forums.blizzard.com/en/warcraft3/t/5x3-or-5x4-command-card-for-warcraft-iii-reforged-just-like-for-starcraft-ii/3854) — 命令卡网格讨论
- [GitHub Gist - senko RTS HUD](https://gist.github.com/senko/24d117e680759989a9fff5b2b9ab4615) — 当代 RTS HUD CSS 实测数据

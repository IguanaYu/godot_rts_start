# AI 写 UI 安全调研：越界/重叠/错位的检测与反馈

> 起因：AI 在 Godot 里写 UI 时把"科技升级按钮"加到详情数据下方，结果越界到屏幕外，看不见也点不到。这类问题反复出现，本调研找业界解法。
>
> 调研覆盖 4 条线：Godot 生态已有工具、跨引擎 UI 调试器（Unity/Unreal/Flutter/Chrome）、AI 工具链（Claude Code/Cursor/v0 等）的防错实践、Web/移动端 VRT 方案。
>
> 4 段式结构：① 案例事实（业界都怎么做）→ ② 试错教训（哪些被证明无效）→ ③ 新增方向（针对本项目的具体方案）→ ④ 待决策思考点。

---

## TL;DR（3 句话结论）

1. **CLAUDE.md 单独无效**——Anthropic 官方都说"This context may or may not be relevant"，AI 心情不好就忽略；必须配可执行的检验（hook 或运行时工具）做 enforcement。
2. **业界最对症的方案**：Flutter 的 Debug Paint（所有 Control 边界可视化）+ Unreal Widget Reflector 的 Pick Hit-Testable（专门排查"点击被谁拦截"）+ LinkedIn LayoutTest-iOS 的几何校验（递归检查越界/重叠，完全离线零 flaky）。
3. **Godot 不是从零**：已有 [GDSnap](https://github.com/Nokorpo/GDSnap) 做 VRT 截图回归、[Zylann/godot_editor_debugger_plugin](https://github.com/Zylann/godot_editor_debugger_plugin) 做 F12 检视、`Control.get_global_rect()` + `Rect2.intersects()` 自带 API 足够做几何校验，**本项目缺的不是工具，是把它们串成"AI 改 UI → 自动检验 → 反馈 AI"的闭环**。

---

## 一、问题机制（为什么 AI 写 UI 必然出错，先说清楚根因）

调研中所有来源（学术 + 工业实践）指向同一个根因：

### 1.1 AI 看不到屏幕
- Adam Argyle（nerdy.dev）："It literally cannot see — It's an LLM, not a rendering engine!"
- SeeAct (OSU NLP, ICML'24) 实验数据：GPT-4V 在 oracle grounding 下完成 51.1% 任务，但在线 grounding 一掉就崩——**视觉定位是瓶颈**。
- 结论：纯文本 prompt 永远测不准 UI，必须有视觉输入或数值化校验。

### 1.2 AI 偏好绝对坐标而非弹性布局
- v0 系统 prompt 把"NEVER use floats or absolute positioning unless absolutely necessary"列为头号硬规则——说明这是 AI 通病。
- markaicode 列出 AI 高发 CSS bug：`position: absolute; flex: 1;` 这种混用。
- Godot 同理：AI 倾向写 `position = Vector2(100, 200)` 而非"放进 VBoxContainer 设 size_flag"。

### 1.3 越界/重叠是高频但 silent 的 bug
- AI 写完代码不会自己 push_warning，控制台没报错 → AI 误以为"代码跑通了"。
- 现有 Godot 调试需要开发者主动 Remote Scene Tree 一个个点开看 rect_size——AI 不会这么做。

---

## 二、案例事实（业界都怎么做）

### 2.1 Godot 生态已有方案

#### A. 现成插件
| 工具 | 用途 | 链接 | 备注 |
|---|---|---|---|
| **GDSnap** | 截图回归测试（VRT），CLI 批量跑 | [github.com/Nokorpo/GDSnap](https://github.com/Nokorpo/GDSnap) | Diff 图约定：青色=旧有新无，红色=新有旧无；可直接 `godot --headless --script` 跑 |
| **godot_editor_debugger_plugin (Zylann)** | F12 鼠标悬停选中 Control 看属性 | [github.com/Zylann/godot_editor_debugger_plugin](https://github.com/Zylann/godot_editor_debugger_plugin) | 254 stars，编辑器侧 DevTools 风格 |
| **DebugDraw 3D/2D** | 运行时画框/线/文本 | [Asset Library #1766](https://godotengine.org/asset-library/asset/1766) | C++/GDExtension，2D singleton 可直接 `draw_rect()` |
| **Godot Visual Smoke Test Kit** | Python+Godot 混合 CI 友好 VRT | [github.com/NonniGB/godot-production-toolkit](https://github.com/NonniGB/godot-production-toolkit) | 解耦 Godot 执行与对比，CI 不必装 Godot |

#### B. Godot 内置 API（足够做几何校验，不用装插件）
- `Control.get_global_rect()` 返回全局 `Rect2`（position + size）
- `Rect2.intersects(other_rect)` 判断重叠
- `Rect2.encloses(other_rect)` 判断包含
- `Control.get_combined_minimum_size()` 真实最小尺寸
- `get_viewport().get_visible_rect().size` 视口尺寸
- `get_viewport().gui_get_hovered_control()` 拿到鼠标下最上层 Control（4.x 已有）

#### C. 编辑器侧轻量方案
- `@tool` 脚本 + `Engine.is_editor_hint()` + `_draw()` 画自己边框
- ColorRect + `editor_only=true` 做参考框（GDQuest 教学习惯）
- EditorInspectorPlugin 给每个 Control 加"Show Bounds"按钮

### 2.2 跨引擎成熟方案（业界最值得借鉴的）

#### A. Flutter Inspector（业界最完善）
**核心机制**：`debugPaintSizeEnabled = true` 全局 flag，开启后：
- 所有 RenderBox 画**亮蓝边框**
- **Padding 区域**画淡蓝填充
- **Align/Center** 用黄色箭头指示对齐方向
- **空 spacer** 画灰色

**可搬到 Godot**：autoload 全局 flag，遍历 UI 树画框，Container 类型用不同颜色（VBox=黄、Margin=蓝、Scroll=绿）。

#### B. Unreal Widget Reflector（点击穿透排查金标准）
**Pick Hit-Testable Widgets** 功能：按下后悬停 UI，reflector 列出鼠标位置下**所有能拦截 hit test 的 widget 链**——立刻看到是哪个上层 Border/Image 在抢事件。

**可搬到 Godot**：用 `gui_get_hovered_control()` + 反向遍历父链打印 mouse_filter，对项目里反复出现的"QW 栏锁/点击穿透"问题精确命中。

#### C. LinkedIn LayoutTest-iOS（几何校验标杆）
自动遍历 view 树，断言"无子视图越界父视图"、"无意外重叠"，可配置 exception 列表。

**可搬到 Godot**：递归遍历 Control 树，对每个节点检查 (a) 是否在 viewport 内、(b) 是否与同级重叠、(c) size 是否 < minimum_size。**这是当前调研里最针对本任务的方案**——完全离线、毫秒级、零 flaky。

#### D. Chrome DevTools（祖师爷，几乎所有引擎抄它）
- **Box Model 图**：content/padding/border/margin 嵌套矩形可视化
- **Paint Flashing**：重绘区域闪绿，定位无意义重绘
- **Flexbox/Grid Editor**：可视化编辑容器属性

### 2.3 AI 工具链防错实践（2025-2026 共识）

#### A. Playwright MCP + Claude Code 截图循环（事实标准）
- Cursor 2.0 已内置浏览器自动截图
- Builder.io 实操指南：`claude mcp add playwright npx @playwright/mcp@latest`
- Medium "3 MCP Workflows That Actually Stuck" 把它列为第一名
- Anthropic 自家 Computer Use 走同样路线

**对 Godot 的迁移**：Godot 启动后用 `get_viewport().get_texture().get_image().save_png()` 截图，把 PNG 喂回 Claude（多模态）让它自检。

#### B. v0 系统 prompt 的硬规则范式
v0 把"Container 优先"明确定为"Layout Method Priority"，跟着禁了 floats、absolute、`space-*`。这种**白名单/黑名单式硬规则**比泛泛而谈"注意 UI 美观"有效得多。

**搬到 Godot**：CLAUDE.md 写明"新增 Control 默认用 Container，HUD 四角吸附才用 anchor，禁用裸 position"。

#### C. Claude Code Hooks（enforcement 唯一可靠途径）
Towards AI 那篇 "CLAUDE.md Can't Enforce Anything" 核心论点：
> "A prompt is where you express intent. Enforcement is where you guarantee it, and a guarantee has to live in code that runs whether or not the model cooperates."

做法：PostToolUse hook 在 Claude 改完 .tscn 后跑一个脚本，跑不过就 block 这次工具调用，把错误塞回 Claude 逼它进入"测试-修复"循环。

参考实现：[karanb192/claude-code-hooks](https://github.com/karanb192/claude-code-hooks)。

#### D. Design Token + 设计规范作为 context
- `jcmrs/claude-visual-style-guide`：CLAUDE.md 配 `claude-design-tokens.json` + 组件 specs + 响应式断点
- Anthropic 官方 `frontend-design` skill 明确告诉模型避开"AI slop"美学
- 8pt Grid 硬规则（spacing 必须是 4 或 8 的倍数）

**搬到 Godot**：写一份 `ui_specs.md` 列出每个 UI 区域的 rect 范围、字号、颜色 token，作为 AI 固定 context。

---

## 三、试错教训（哪些方案被证明无效）

### 3.1 CLAUDE.md 单独无效（最关键教训）
- Anthropic 官方文档原话："This context may or may not be relevant to your tasks."
- Shrivu Shankar："if the file is too long, Claude can ignore certain rules"
- **结论**：规则文档必写，但绝不能只靠它，必须配 enforcement。

### 3.2 纯截图反馈死循环（Cursor 论坛高赞痛诉）
> "It took me 2 hours and about 30-50 prompts to line up a button with a textfield yesterday… finally told it to 'strip away all css and start from scratch' that finally did it."

——Cursor 论坛 "Cursor needs awareness of the UI" 高赞帖。

**原因**：没有 structured context（DOM、viewport、computed style）的纯截图反馈低效，AI 反复改但不知道改了多少。

### 3.3 VLM 当 judge 分数虚高
- WebVoyager 用 GPT-4V 看截图判任务成功率，Reddit 从业者爆料"many startups reportedly posting 85–94% results"但实际差很远
- **结论**：自动验收不能纯靠 VLM 评分，必须配像素 diff 或 DOM bounds 数值校验。

### 3.4 复杂组件 AI 写不对
Adam Argyle：
> "The more complex the component gets, the slower and dumber the front-end help becomes."

**结论**：不要让 AI 一次性写复杂 UI，必须分小步 + 每步视觉验证。

### 3.5 字体/抗锯齿跨机器 flaky
Flutter Golden Test 的最大教训：不同平台字体渲染差异导致大量 flaky，必须固定渲染环境或加 tolerance。**对 Godot VRT 意味着**：截图对比要加 0.1% pixel tolerance，不能严卡 0 diff。

---

## 四、新增方向（针对本项目的具体方案）

### 4.1 四层防御体系（推荐落地）

```
┌─ L4 流程强制 (PostToolUse hook) ──────── 最强：失败就 block 工具调用
│
├─ L3 截图回归 (GDSnap baseline) ───────── 视觉差异，喂回 Claude 自检
│
├─ L2 运行时几何校验 (autoload) ────────── 数值化越界/重叠告警
│
└─ L1 预防 (CLAUDE.md + ui_specs.md) ──── 规则文档，让 AI 提前思考
```

每层独立有效，组合后形成"AI 改 UI → 自动检验 → 反馈 AI → 必要时 block"的闭环。

### 4.2 各层具体实施草案

#### L1 预防层（成本：30 分钟）
- 在 `CLAUDE.md` 加一节"UI 编辑硬规则"：
  - 新增/修改 Control 前必须先报：父节点 rect、目标 rect、是否越出 viewport
  - 默认用 Container（VBox/HBox/Scroll/Margin/Grid），裸 Control + position 只用于固定单个浮窗
  - spacing 必须是 4 或 8 的倍数
  - 详情面板内容多时用 ScrollContainer 防溢出
- 写一份 `docs/reference/ui_specs.md` 列屏幕分区：
  - 顶 HUD y∈[0, 80]
  - 底部 UI 条 y∈[980, 1080]
  - 右侧详情面板 rect=[1620, 80, 300, 900]
  - QW 栏、多选汇总等每个区域的像素范围
- **局限**：advisory，会被忽略；但还是要写，让 AI 至少有思考方向。

#### L2 运行时几何校验（成本：半天，**推荐第一个做**）
新建 `addons/ui_bounds_validator/UIBoundsValidator.gd` autoload：

```gdscript
# 伪代码
func _validate(root: Control) -> Array[Issue]:
    var issues: Array[Issue] = []
    var viewport_size = get_viewport().get_visible_rect().size
    for control in root.find_children("*", "Control"):
        var rect = control.get_global_rect()
        # 检查越界
        if rect.end.x > viewport_size.x or rect.end.y > viewport_size.y \
           or rect.position.x < 0 or rect.position.y < 0:
            issues.append(Issue.new("OUT_OF_BOUNDS", control, rect))
        # 检查 size 不足
        if control.get_combined_minimum_size() > control.size:
            issues.append(Issue.new("SIZE_TOO_SMALL", control, rect))
        # 检查同级重叠（白名单 MarginContainer 这种故意重叠的）
        for sibling in control.get_parent().get_children():
            if sibling is Control and sibling != control \
               and rect.intersects(sibling.get_global_rect()):
                issues.append(Issue.new("OVERLAP", control, rect, sibling))
    return issues
```

调试热键（如 F8）切换三种模式：
1. **Stats 模式**：print 所有 issue 列表
2. **Outline 模式**：用 DebugDraw2D 给所有 Control 画框，越界红色、重叠黄色、OK 绿色
3. **Pick 模式**：鼠标悬停 Control，显示该节点 path + rect + mouse_filter + visible（借鉴 Flutter Select Widget Mode）

**为什么先做这个**：
- 零依赖、毫秒级、零 flaky
- 对"按钮加到屏幕外"这种**具体场景**精确命中
- AI 写完 UI 立刻有数值化反馈，比"看一下截图"更精准
- 顺便解决项目里反复出现的 QW 栏锁/点击穿透问题（Pick 模式直接看到 mouse_filter 链）

#### L3 截图回归（成本：1 天）
- 引入 GDSnap 或自写 50 行 GDScript 复刻核心
- 给关键 UI 场景建 `ScreenshotTest` 根节点的 .tscn：详情面板、底部 UI 条、多选汇总、QW 栏
- baseline 入 git，AI 改完 UI 跑 `godot --headless --script gdsnap_cli.gd`
- Diff PNG 喂回 Claude（多模态），让它判断"越界没/重叠没/布局对没"
- **注意**：必须 `await RenderingServer.frame_post_draw` 避免黑屏；加 0.1% pixel tolerance 防字体差异 flaky

#### L4 PostToolUse hook（成本：半天，可选）
- 在 `.claude/settings.json` 配 PostToolUse hook
- 触发条件：Claude 改完 .tscn 后，自动跑 L2 几何校验脚本
- 失败时把 issue 列表塞回 Claude，逼它修复
- 参考 `karanb192/claude-code-hooks` 模式
- **风险**：会增加每次 UI 编辑延迟；建议只对 `scenes/ui/` 路径触发，不全量

### 4.3 工具选型对比

| 方案 | 自写 vs 用现成 | 推荐度 |
|---|---|---|
| 几何校验 autoload | **自写**（150 行 GDScript，复用 Godot 原生 API） | ★★★★★ |
| 截图对比 | **GDSnap**（已成熟，CLI 友好） | ★★★★ |
| 编辑器侧 Control inspector | **Zylann plugin**（254 stars 验证过） | ★★★ |
| 运行时画框 | **DebugDraw2D**（如果项目已装）否则自写 | ★★★ |
| Hook 集成 | **自写**（项目特定，没现成模板） | ★★★ |

---

## 五、待决策思考点

请挑你想先做的方向（可多选）：

### Q1：先做哪一层？
- **A. 只做 L1 预防**（30 分钟，最快但效果有限）——先写硬规则文档，立刻见效，后面再补
- **B. L1 + L2 几何校验**（半天，立竿见影）——**推荐**，对"按钮加到屏幕外"这种具体问题直接命中
- **C. L1 + L2 + L3 截图回归**（1-2 天，闭环 AI 自检）——能让 AI 自己看 diff 修复，但实现复杂
- **D. 全套四层**（2-3 天，最完整）——加上 PostToolUse hook 做强制

### Q2：几何校验用谁的实现？
- 自写 150 行 GDScript（推荐，复用项目现有 autoload 风格）
- 找现成 Godot 插件（没找到完全对口的，都得改造）

### Q3：截图反馈循环是否接 Claude 多模态？
- 接：Claude 改完 UI 自动截图 + analyze_image 自检（很酷但有成本）
- 不接：只产出 diff PNG 留给人类 review（更简单）

### Q4：项目里反复出现的点击穿透问题（QW 栏、详情面板）是否单独做 Pick 模式？
- 是：把 Pick Hit-Testable 模式（借鉴 Unreal Widget Reflector）作为 L2 的一部分
- 否：只做越界检测，点击穿透以后再说

---

## 附：完整来源（按主题分组）

### Godot 生态
- [GDSnap](https://github.com/Nokorpo/GDSnap)
- [Zylann/godot_editor_debugger_plugin](https://github.com/Zylann/godot_editor_debugger_plugin)
- [DebugDraw 3D/2D Asset](https://godotengine.org/asset-library/asset/1766)
- [Godot Visual Smoke Test Kit](https://github.com/NonniGB/godot-production-toolkit)
- [Godot GUI Containers 文档](https://docs.godotengine.org/en/stable/tutorials/ui/gui_containers.html)
- [Control 类文档](https://docs.godotengine.org/en/stable/classes/class_control.html)
- [Godot Proposal #1760 - Testing graphical and UI code](https://github.com/godotengine/godot-proposals/issues/1760)
- [GDQuest: All the Containers](https://school.gdquest.com/courses/learn_2d_gamedev_godot_4/start_a_dialogue/all_the_containers)
- [Bugnet: Debug UI Overflow in Games](https://bugnet.io/blog/how-to-debug-ui-layout-overflow-bugs-in-games)

### 跨引擎 UI 调试器
- [Unity UI Toolkit Debugger](https://docs.unity3d.com/6000.5/Documentation/Manual/UIE-ui-debugger.html)
- [Unreal Widget Reflector](https://dev.epicgames.com/documentation/unreal-engine/using-the-slate-widget-reflector-in-unreal-engine)
- [Unreal Console Slate Debugger](https://dev.epicgames.com/documentation/unreal-engine/console-slate-debugger-in-unreal-engine)
- [Flutter Inspector](https://docs.flutter.dev/tools/devtools/inspector)
- [Flutter debugPaintSizeEnabled](https://docs.flutter.dev/testing/code-debugging)
- [Chrome DevTools Paint Flashing](https://developer.chrome.com/docs/devtools/performance/reference)
- [React Native DevTools](https://reactnative.dev/docs/react-native-devtools)
- [Android Compose Layout Inspector](https://developer.android.com/develop/ui/compose/tooling/debug)
- [SwiftUI Field Guide - Debugging](https://www.swiftuifieldguide.com/layout/debugging)
- [LinkedIn LayoutTest-iOS](http://linkedin.github.io/LayoutTest-iOS/pages/040_includedTests.html)

### AI 工具链防错
- [v0 系统 Prompt 全文](https://github.com/x1xhlol/system-prompts-and-models-of-ai-tools/blob/main/v0%20Prompts%20and%20Tools/Prompt.txt)
- [CLAUDE.md Can't Enforce Anything (Towards AI)](https://pub.towardsai.net/claude-md-cant-enforce-anything-here-s-the-hook-i-use-instead-424be05a68f0)
- [How I Use Every Claude Code Feature](https://blog.sshh.io/p/how-i-use-every-claude-code-feature)
- [karanb192/claude-code-hooks](https://github.com/karanb192/claude-code-hooks)
- [Playwright MCP + Claude Code (Builder.io)](https://www.builder.io/blog/playwright-mcp-server-claude-code)
- [Visual Feedback Loop (Tweag)](https://tweag.github.io/agentic-coding-handbook/WORKFLOW_VISUAL_FEEDBACK/)
- [Cursor needs UI awareness (论坛痛诉)](https://forum.cursor.com/t/cursor-needs-awareness-of-the-ui/101532)
- [Why AI Sucks at Front End](https://nerdy.dev/why-ai-sucks-at-front-end)
- [The Screenshot Is the Missing Test for AI UI](https://themotiondesign.com/writing/screenshot-is-missing-test-for-ai-ui)
- [Screenshot Annotation Best Practices](https://yourstash.ai/articles/annotation-best-practices-ai)
- [jcmrs/claude-visual-style-guide](https://github.com/jcmrs/claude-visual-style-guide)
- [RayFernando1337/llm-cursor-rules](https://github.com/RayFernando1337/llm-cursor-rules/blob/main/fire-your-design-team.md)
- [UX Planet: Stop Claude Code Ruining Design](https://uxplanet.org/how-to-stop-claude-code-from-ruining-your-product-design-7fb10c3f5749)

### 学术证据
- [SeeAct (OSU NLP, ICML'24)](https://github.com/osu-nlp-group/seeact) - 视觉定位是 AI agent 瓶颈
- [UGround (ICLR 2025 best paper)](https://openreview.net/forum?id=kxnoqaisCT) - 1.3M 截图预训练 grounding
- [Anthropic Computer Use](https://platform.claude.com/docs/en/agents-and-tools/tool-use/computer-use-tool)
- [WebVoyager broken (Reddit)](https://www.reddit.com/r/AI_Agents/comments/1r2yziq/webvoyager-is-broken-and-every-agent-company/) - VLM judge 不可靠

### VRT 工具
- [Playwright toHaveScreenshot](https://playwright.dev/docs/test-snapshots)
- [BackstopJS](https://github.com/garris/BackstopJS)
- [pixelmatch](https://github.com/mapbox/pixelmatch)
- [Chromatic (Storybook)](https://www.chromatic.com/)
- [Flutter matchesGoldenFile](https://api.flutter.dev/flutter/flutter_test/matchesGoldenFile.html)
- [ios-snapshot-test-case](https://github.com/uber/ios-snapshot-test-case)
- [Claude Code Round-Trip Screenshot Testing](https://medium.com/@rotbart/giving-claude-code-eyes-round-trip-screenshot-testing-ce52f7dcc563)

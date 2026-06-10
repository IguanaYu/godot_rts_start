# Git 未提交文件分析报告

> 分支: `master` | 日期: 2026-06-10

---

## 一、已修改文件 (Modified)

### 1. `.gitignore` — 新增 `.agents/` 忽略规则

**改动**: 新增了一行 `.agents/`

**用途**: `.agents/` 是 Claude Code 的 agent worktree 隔离目录（创建隔离工作区时自动生成）。加入 `.gitignore` 防止其被提交到仓库。

**建议**: 同时也应把 `.mcp.json` 加入 `.gitignore`（见下文）。

【把 .gitignore文件也加入.gitignore】
---

### 2. `locales/translations.{en,ja,zh}.translation` — 翻译文件更新

**改动**: 三个二进制 `.translation` 文件各增加约 80 bytes。

**推测**: 最近新增的功能（血条变色、目标标记、信息面板）可能引入了新的翻译字符串。由于是 Godot 的二进制 PO 格式，无法直接 diff 文本内容，需要在 Godot 编辑器的"本地化"面板中查看具体变更。

**建议**: 提交前在 Godot 编辑器中确认翻译内容是否完整准确。

【推上去吧。】
---

## 二、新增文件 (Untracked)

### A. 项目调研文档（可提交）

#### 3. `docs/research/healthbar-rt-research.md` — RTS 血条调研报告

**内容**: 对比了 SC2 / War3 / AoE / C&C / OpenRA 的血条颜色方案，列出了三种实现技术方案：

| 方案 | 原理 | 优点 | 缺点 |
|------|------|------|------|
| A: StyleBoxFlat | 代码动态改 bg_color | 简单，Godot 原生 | 瞬变无渐变，有 GC 压力 |
| B: 分层渲染 | 底层红+上层绿叠加 | 天然渐变 | 需两个 ProgressBar 节点 |
| C: Shader | UV 坐标颜色映射 | 效果最好，性能最优 | 需写 shader，维护成本高 |

**设计建议**: War3 风格三色（绿>50%, 黄25-50%, 红<25%），加 1px 黑边框。

【调研报告，推上去吧】
---

#### 4. `docs/ui-unit-info-panel-research.md` — 单位信息面板 UI 调研

**内容**: 对比 SC2/WC3/AoE2/LoL/Dota/C&C 的单位信息面板设计。

**设计建议**:
- 面板位置: 左侧中部（底部建造面板上方）
- 风格: 参考 AoE2 的图标+数值网格
- 显示内容: ATK / RANGE / SPEED / ARMOR / ATK SPD
- 建筑选中时显示生产进度

【推上去】
---

#### 5. `docs/objective_marker_preview.html` — 任务目标标记视觉预览

**内容**: 一个可浏览器打开的 HTML 页面，包含：
- 7 种标记图标的 canvas 渲染预览（皇冠/盾牌/骷髅/准星/星形/旗帜/菱形）
- 游戏场景模拟（标记悬浮在单位头顶+脉冲动画+虚线光柱）
- SC2 vs WC3 vs AoE4 vs C&C vs CoH 功能对比表
- 推荐标记体系（保护类/击杀类/导航类）

【推上去吧】
---

### B. Claude Code 工具配置

#### 6. `.mcp.json` — MCP 服务器配置

```json
{
  "mcpServers": {
    "tavily": {
      "command": "npx",
      "args": ["-y", "tavily-mcp"],
      "env": {
        "TAVILY_API_KEY": "tvly-dev-..."
      }
    }
  }
}
```

**用途**: 为 Claude Code 配置 Tavily 网页搜索 MCP 服务器，让 AI 助手可以联网搜索。

**⚠️ 风险**: 包含明文 Tavily API Key。如果提交到公开仓库，key 会泄露。

**建议**: 加入 `.gitignore`，不要提交。
【同意，加入.gitignore】
---

#### 7. `skills-lock.json` — Claude Code Skills 锁定文件

**用途**: 记录已安装的 Claude Code skill（当前只有 `claude-to-im`，用于消息推送到 IM）。

**建议**: 类似 `package-lock.json`，如果想团队成员共用相同 skills 可以提交；否则加入 `.gitignore`。
【同意，加入.gitignore】
---

### C. 网页下载残留（应删除）

这些是使用 Tavily 搜索 / SkillsMP 网站时浏览器保存的 HTML 页面，与项目无关：

| 文件 | 来源 | 大小 |
|------|------|------|
| `skill_tavily.html` | Tavily 相关网页 | 较大 |
| `skillsmp_page.html` | SkillsMP 技能目录页 | - |
| `skillsmp_search.html` | SkillsMP 搜索页 | - |
| `skillsmp_search2.html` | SkillsMP 搜索页（重复） | - |
| `skillsmp_search3.html` | SkillsMP 搜索页（重复） | - |

**建议**: 全部删除，并可将 `*.html` 加入 `.gitignore`（如果项目不包含 HTML 文件的话）。
【删除吧】
---

## 三、汇总建议

| 操作 | 涉及文件 |
|------|----------|
| ✅ 可提交 | `.gitignore`, `locales/*.translation`, `docs/research/*.md`, `docs/objective_marker_preview.html` |
| ⚠️ 需处理 | `.mcp.json` — 加入 `.gitignore`（有 API key） |
| 🤔 自行决定 | `skills-lock.json` — 团队共享则提交，否则忽略 |
| ❌ 应删除 | `skill_tavily.html`, `skillsmp_page.html`, `skillsmp_search.html`, `skillsmp_search2.html`, `skillsmp_search3.html` |

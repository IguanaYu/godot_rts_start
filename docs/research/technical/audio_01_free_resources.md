# 免费音效资源库深度调研报告

> 调研日期：2026-08-10  
> 目标项目：Godot 4.6 RTS 游戏（帝国时代+红警混合风格，含奇幻元素）  
> 调研重点：免费、可商用、RTS 适用

---

## 目录

1. [授权类型速查表](#授权类型速查表)
2. [Kenney.nl](#1-kenneynl)
3. [Freesound.org](#2-freesoundorg)
4. [OpenGameArt.org](#3-opengameartorg)
5. [Pixabay Music / SFX](#4-pixabay-music--sfx)
6. [Mixkit](#5-mixkit)
7. [GameSounds.xyz](#6-gamesoundsxyz)
8. [Sonniss GDC Game Audio Bundle](#7-sonniss-gdc-game-audio-bundle)
9. [NASA Space Sounds](#8-nasa-space-sounds)
10. [Incompetech / Kevin MacLeod](#9-incompetech--kevin-macleod)
11. [Scott Buckley Music Library](#10-scott-buckley-music-library)
12. [ZapSplat](#11-zapsplat)
13. [其他补充资源](#12-其他补充资源)
14. [推荐组合](#推荐组合)
15. [Godot 集成建议](#godot-集成建议)

---

## 授权类型速查表

| 资源站 | 授权类型 | 需要署名 | 商业可用 | 注册要求 |
|--------|----------|----------|----------|----------|
| **Kenney.nl** | CC0 | 否 | 是 | 否 |
| **Freesound.org** | 每个文件不同 (CC0/CC-BY/CC-BY-NC) | CC-BY 需要 | 仅 CC0 和 CC-BY | 需要免费注册 |
| **OpenGameArt.org** | 每个文件不同 (CC0/CC-BY/OGA-BY) | CC-BY 需要 | 仅 CC0 和 CC-BY | 否 |
| **Pixabay** | Pixabay Content License | 否 | 是 | 否（注册可选） |
| **Mixkit** | Mixkit SFX Free License | 否 | 是 | 否 |
| **GameSounds.xyz** | 聚合站（CC0 + Sonniss） | 否 | 是 | 否 |
| **Sonniss GDC** | Royalty-free 商业许可 | 否 | 是 | 否 |
| **NASA Sounds** | Public Domain | 否 | 是（不能用 NASA logo） | 否 |
| **Incompetech** | CC-BY 4.0（或付费免署名） | 是（或 $30/首付费） | 是 | 否 |
| **Scott Buckley** | CC-BY 4.0（或付费免署名） | 是 | 是 | 否 |
| **ZapSplat** | Standard License（免费需署名） | 是（Gold 会员免署名） | 是 | 需要免费注册 |
| **Fesliyan Studios** | 自有许可（非商用免费，商用需捐赠） | 否 | 需捐赠 | 否 |
| **Free-Stock-Music.com** | CC-BY 4.0（或 $20/首免署名） | 是 | 是 | 否 |

---

## 1. Kenney.nl

- 网址：https://kenney.nl/assets/category:Audio
- 授权：**CC0（完全公共领域）**
- 署名：不需要（可选写 "Kenney" 或 "kenney.nl"）
- 格式：Ogg Vorbis（原始），社区有 WAV 转换版
- 风格：卡通/简洁/通用游戏风格
- 注册：不需要

### 音频包列表

| 音频包 | 文件数 | 内容描述 | RTS 适用性 |
|--------|--------|----------|------------|
| **Interface Sounds** | 100 | 按钮、点击、切换 UI 音效 | 高 - UI 点击/选择/错误 |
| **Impact Sounds** | 多个 | 撞击/打击音效 | 高 - 战斗命中 |
| **RPG Audio** | 多个 | RPG 主题音效 | 中 - 部分可用于奇幻战斗 |
| **UI Audio** | 50 | 额外 UI 音效 | 高 - UI 交互 |
| **Voiceover Pack** | 多个 | 通用语音包 | 中 - 可作为单位响应 |
| **Voiceover Pack (Fighter)** | 多个 | 战士语音包 | 高 - 单位语音 |
| **Music Jingles** | 多个 | 短音乐片段 | 高 - 升级/完成提示 |
| **Digital Audio** | 多个 | 电子音效 | 低 - 偏科幻 |
| **Casino Audio** | 多个 | 赌场音效 | 低 |
| **Sci-fi Sounds** | 多个 | 科幻音效 | 低 |
| **Foley Sounds** | 多个 | 拟音音效 | 中 - 脚步等 |
| **Music Loops** | 多个 | 循环背景音乐 | 高 - 背景音乐 |
| **Synth Voice 1 & 2** | 多个 | 合成人声 | 中 |
| **Retro Sounds 1 & 2** | 多个 | 复古 8-bit 音效 | 低 |

### RTS 游戏推荐用法

- **Interface Sounds + UI Audio** -> 点击/选择/升级 UI
- **Impact Sounds** -> 剑击/物理攻击命中
- **Voiceover Pack (Fighter)** -> 剑士单位语音响应
- **Music Jingles** -> 建造完成/时代升级提示
- **RPG Audio** -> 魔法效果

### 下载方式

直接从网站下载 ZIP 包，无需注册。也有 Godot Asset Library 版本（如 Kenney UI Audio by Calinou）。

### 源链接
- 主页：https://kenney.nl/assets/category:Audio
- 授权说明：https://kenney.nl/support
- Godot 插件版：https://godotengine.org/asset-library/asset/796

---

## 2. Freesound.org

- 网址：https://freesound.org
- 授权：**每个文件不同**，必须逐个检查
  - CC0（公共领域，无需署名）
  - CC-BY（需署名，可商用）
  - CC-BY-SA（需署名+共享协议，可商用）
  - CC-BY-NC（**不可商用** - 排除使用）
- 格式：WAV、MP3、FLAC、OGG（因上传者而异）
- 风格：极其多样（从专业录音到合成音效）
- 注册：**需要免费注册才能下载**

### 关键数据

- 超过 **700,000+ 音效**，是世界上最大的免费音效库
- 2025 年 CC0 上传量创历史新高（趋势持续上升）
- 有高级搜索可按授权类型筛选

### CC0 搜索策略

```
搜索路径：freesound.org/search -> 筛选 License: Creative Commons 0
CC0 标签浏览：freesound.org/browse/tags/cc0
```

### RTS 适用搜索关键词

| 需求 | 推荐搜索词 |
|------|-----------|
| 剑击 | `sword hit`, `sword swing`, `metal clash` |
| 弓箭 | `bow draw`, `arrow fire`, `arrow impact` |
| 爆炸 | `explosion`, `bomb`, `blast` |
| 魔法 | `magic spell`, `fireball`, `ice cast` |
| UI 点击 | `click`, `ui button`, `interface` |
| 升级 | `power up`, `level up`, `fanfare` |
| 脚步 | `footstep`, `march`, `walking dirt` |
| 环境鸟叫 | `bird`, `forest ambient`, `birds morning` |
| 风声 | `wind`, `breeze`, `wind trees` |
| 火焰 | `fire`, `flame`, `campfire` |
| 死亡 | `death`, `dying`, `grunt pain` |

### 署名格式（CC-BY 文件）

```
Title: [音效名称]
Author: [上传者名称]
Source: https://freesound.org/people/[用户名]/sounds/[ID]/
License: CC BY 4.0
```

### 注意事项

- 下载前必须确认每个文件的授权
- CC-BY-NC 文件绝对不能用于商业游戏
- 部分文件可能是录音的现场采音，质量参差不齐
- 2025 年趋势：CC0 上传量回升

### 源链接
- 主页：https://freesound.org
- CC0 浏览：https://freesound.org/browse/tags/cc0
- 授权论坛：https://freesound.org/forum/legal-help-and-attribution-questions
- 2025 年度报告：https://blog.freesound.org?p=2347

---

## 3. OpenGameArt.org

- 网址：https://opengameart.org
- 授权：**每个上传文件不同**，需要逐个检查
  - CC0（最自由）
  - CC-BY（需署名）
  - CC-BY-SA（需署名+共享）
  - CC-BY-NC（不可商用）
  - OGA-BY（OpenGameArt 自有 BY 协议）
  - GPL/LGPL（少数）
- 格式：WAV、OGG、MP3（因上传者而异）
- 风格：极其多样，偏像素/复古/RPG 风格
- 注册：不需要（浏览/下载免费，注册可评论收藏）

### RTS 高价值 CC0 音频包推荐

| 资源名称 | 内容 | 链接 |
|----------|------|------|
| **RPG Sound Pack** | 100+ RPG 音效（脚步/魔法/战斗/UI/生物） | https://opengameart.org/content/rpg-sound-pack |
| **80 CC0 RPG SFX** | 80 个奇幻 RPG 音效（刀剑/魔法/生物/物品） | https://opengameart.org/content/80-cc0-rpg-sfx |
| **100 CC0 SFX** | 100 个通用音效（门/爆炸/金属/木/玻璃） | https://opengameart.org/content/100-cc0-sfx |
| **CC0 Sound Effects (合集)** | 大量 CC0 音效合集页 | https://opengameart.org/content/cc0-sound-effects |
| **CC0 Fantasy Music & Sounds** | 奇幻音乐合集（战斗/城镇/洞穴主题） | https://opengameart.org/content/cc0-fantasy-music-sounds |
| **Fantasy Sound Effects Library** | 45 个奇幻 SFX（龙/哥布林/脚步/魔法/陷阱） | https://opengameart.org/content/fantasy-sound-effects-library |
| **Library of Game Sounds** | 大量游戏音效（跳跃/打击/爆炸/激光/升级） | https://opengameart.org/content/library-of-game-sounds |
| **512 Sound Effects (8-bit)** | 512 个 8-bit 风格音效 | https://opengameart.org/content/512-sound-effects-8-bit-style |
| **80 CC0 creature SFX** | 80 个生物音效 | CC0 标签下 |
| **50 CC0 Sci-Fi SFX** | 50 个科幻音效 | CC0 标签下 |
| **JC Sounds - Fantasy SFX Pack Vol 1** | 58 个专业奇幻 SFX（火/冰/电魔法+剑/弓） | CC-BY 4.0 |

### 搜索策略

- 按授权筛选：在搜索页面选择 "CC0" 仅看公共领域内容
- 按 Art Type 筛选：选择 "Sound Effect" 或 "Music"
- 热门标签：`Fantasy`, `RPG`, `magic`, `sword`, `battle`, `medieval`

### 特别推荐：CC0 Fantasy Music & Sounds

这个合集包含了大量适合奇幻 RTS 的音乐：
- Battle Theme（战斗主题）
- Town Theme RPG（城镇主题）
- Forest Ambience（森林环境）
- Boss Fight（Boss 战斗）
- Medieval: The Old Tower Inn（中世纪酒馆）
- Cave Theme（洞穴主题）

### 源链接
- 主页：https://opengameart.org
- CC0 音效合集：https://opengameart.org/content/cc0-sound-effects
- CC0 奇幻音乐：https://opengameart.org/content/cc0-fantasy-music-sounds

---

## 4. Pixabay Music / SFX

- 网址：
  - 音效：https://pixabay.com/sound-effects/
  - 音乐：https://pixabay.com/music/
- 授权：**Pixabay Content License**（自有许可，非 CC0 但效果类似）
- 署名：**不需要**
- 格式：MP3
- 风格：多样（电影感/电子/古典/流行/环境/奇幻）
- 注册：不需要（注册可选）

### Pixabay Content License 核心条款

**你可以：**
- 免费用于商业和非商业项目
- 不需要署名
- 修改和改编内容
- 用于游戏、视频、应用、广告等

**你不可以：**
- 将音频文件单独转售或再分发（必须作为更大作品的一部分）
- 声称是你自己创作的原始文件
- 使用含有可识别商标/品牌的内容做商业推广
- 以误导或欺骗的方式使用

### RTS 适用内容

| 类型 | 搜索关键词 | 内容量 |
|------|-----------|--------|
| **爆炸音效** | `explosion`, `bomb blast` | 1,680+ 个 |
| **游戏音效** | `game`, `sword`, `bow` | 数千个 |
| **战斗音乐** | `epic battle`, `war drums`, `cinematic action` | 数千首 |
| **奇幻音乐** | `fantasy`, `medieval`, `magical` | 数千首 |
| **环境音** | `forest`, `wind`, `rain`, `fire` | 数千个 |
| **UI 音效** | `click`, `interface`, `button` | 数千个 |

### 特别推荐

- **Cyberwave-Orchestra** 上传了大量剑击/战斗音效
- **freesound_community** 上传了多种战斗/环境音效
- **DRAGON-STUDIO** 提供高质量爆炸/特效音效
- 音乐部分有大量 "epic orchestral" / "fantasy battle" 主题曲目

### 注意事项

- Pixabay 的音乐/音效由社区上传，质量参差不齐
- 2026 年有 AI 生成音乐混入，质量需要筛选
- 部分文件可能有 Content ID 注册（YouTube 可能误报版权），保留下载记录

### 源链接
- 音效主页：https://pixabay.com/sound-effects/
- 音乐主页：https://pixabay.com/music/
- 授权摘要：https://pixabay.com/service/license-summary/
- FAQ：https://pixabay.com/service/faq

---

## 5. Mixkit

- 网址：https://mixkit.co/free-sound-effects/
- 授权：**Mixkit Sound Effects Free License**
- 署名：**不需要**
- 格式：MP3 和 WAV
- 风格：专业制作/干净/通用
- 注册：**不需要**

### Mixkit SFX Free License 核心条款

**你可以：**
- 免费用于商业和个人项目
- 用于视频游戏（明确列出）
- 不需要署名
- 不需要注册

**你不可以：**
- 将音效单独转售/再分发
- 声称是自己创作的
- 注册为商标

### RTS 适用内容

| 类别 | 内容 | 链接 |
|------|------|------|
| **Game SFX** | 76 个游戏音效（奖励/升级/完成/点击） | https://mixkit.co/free-sound-effects/game/ |
| **战斗 SFX** | 拳击/打击/武器音效 | https://mixkit.co/free-sound-effects/fighting/ |
| **UI/Click SFX** | 界面点击/切换/通知 | 多个分类下 |
| **环境 SFX** | 自然环境/动物/天气 | https://mixkit.co/free-sound-effects/nature/ |

### 注意事项

- **重要区分**：Mixkit 的 Sound Effects 和 Stock Music 是不同的许可！SFX 更宽松
- SFX 数量较少（约几百个），不如 Freesound 或 Pixabay 量大
- 质量经过人工筛选，一致性较高
- 现在属于 Envato 生态

### 源链接
- SFX 主页：https://mixkit.co/free-sound-effects/
- 游戏 SFX：https://mixkit.co/free-sound-effects/game/
- 许可信息：https://mixkit.co/license/
- 官方 LLM 说明：https://mixkit.co/llm-info

---

## 6. GameSounds.xyz

- 网址：https://gamesounds.xyz
- 授权：**聚合站** - 所有内容来自 Kenney (CC0) 和 Sonniss GDC (Royalty-free)
- 署名：不需要
- 格式：WAV、OGG
- 风格：游戏专用
- 注册：不需要

### 内容说明

GameSounds.xyz 本质上是 **Kenney 音频包 + Sonniss GDC 历年音效包** 的镜像聚合站，提供方便的批量浏览和下载。

### 目录结构

```
Kenney's Sound Pack/
  ├── Casino Audio
  ├── Digital Audio
  ├── Foley Sounds
  ├── Impact Sounds
  ├── Interface Sounds
  ├── Music Jingles
  ├── Music Loops
  ├── RPG Audio
  ├── Retro Sounds 1 & 2
  ├── Sci-Fi Sounds
  ├── Synth Voice 1 & 2
  ├── UI Audio
  ├── Voiceover Pack
  └── Voiceover Pack Fighter

Sonniss.com - GDC 2015~2023 Game Audio Bundle/
  （每年 GDC 大包，共数百 GB）
```

### 优势

- 一个地方批量下载所有 CC0/免署名游戏音效
- 无需翻墙到多个站点
- 文件列表式浏览，方便快速查找

### 源链接
- 主页：https://gamesounds.xyz
- Kenney 包：https://gamesounds.xyz?dir=Kenney%27s+Sound+Pack

---

## 7. Sonniss GDC Game Audio Bundle

- 网址：https://sonniss.com/gameaudiogdc
- 授权：**Royalty-free，永久商业许可**
- 署名：**不需要**
- 格式：WAV（高采样率，通常 96kHz/24bit 或 48kHz/24bit）
- 风格：**专业电影/游戏级音效**
- 注册：不需要

### 许可核心条款

**你可以：**
- 用于游戏、电影、电视、播客、YouTube、VR/AR、移动应用、广告等
- 商业项目和无限制项目数量
- 永久许可，不过期
- 无需署名

**你不可以：**
- 用于 AI/ML 训练（明确禁止）
- 单独转售音效文件

### 规模

| 年份 | 大小 | 状态 |
|------|------|------|
| GDC 2026 | 7.47 GB+ | 最新版，2026年3月发布 |
| GDC 2015-2023 | 累计 200 GB+ | 全部可下载 |
| **总计** | **200+ GB** | 347+ 文件包 |

### 内容质量

这是**最高质量的免费音效来源**。所有音效来自商业音效库厂商捐赠（如 SoundBits、Epic Stock Media、Just Sound Effects 等），属于真正的工业级音效。

### RTS 适用内容

从 Sonniss 包中可以找到：
- 武器音效（剑/刀/弓/锤等冷兵器）
- 爆炸/破坏音效
- 环境声（森林/战场/城市）
- UI/界面音效
- 脚步/移动音效
- 魔法/能量音效
- 怪物/生物叫声

### 下载方式

- 直接从官网下载，每年一个大 ZIP 文件
- 官方存档：https://sonniss.com/gameaudiogdc
- 也可从 GameSounds.xyz 批量下载历史包

### 源链接
- 2026 主页：https://gdc.sonniss.com
- 历年存档：https://sonniss.com/gameaudiogdc
- 许可详情：https://gdc.sonniss.com（页面底部 "Read the full licence"）

---

## 8. NASA Space Sounds

- 网址：
  - https://www.nasa.gov/audio-and-ringtones/
  - https://www.nasa.gov/historical-sounds/
  - https://www.nasa.gov/sounds-from-beyond/
  - SoundCloud: https://soundcloud.com/nasa
- 授权：**Public Domain（公共领域）**
- 署名：不需要（但不能使用 NASA logo 或暗示 NASA 背书）
- 格式：MP3、M4R
- 风格：太空/科幻/历史
- 注册：不需要

### 内容列表

| 类别 | 内容 |
|------|------|
| **Apollo & Mercury** | 任务控制通信、发射音频 |
| **Shuttle & Station** | 航天飞机发射、空间站音频 |
| **Missions** | 各任务音频 |
| **Sounds from Beyond** | 宇宙声音（行星数据转化音频、火星风声等） |

### RTS 适用性

对于你的奇幻 RTS，NASA 音效的适用性**有限**，主要可用于：
- 指挥官技能中的科幻特效（如果有的话）
- 环境音中的特殊氛围（如火星风声可做荒漠地图环境）
- "One small step" 等历史语音可做彩蛋

### 重要提醒

NASA 音频本身是公共领域的，但：
- NASA SoundCloud 上标注了 CC-BY-NC，这**很可能是一个标注错误**（因为联邦政府作品天然属于公共领域）
- 使用 NASA 名称、logo 或暗示官方背书是被禁止的
- 为安全起见，如果担心商业风险，优先选择明确的 CC0 来源

### 源链接
- 音频主页：https://www.nasa.gov/audio-and-ringtones/
- 历史声音：https://www.nasa.gov/historical-sounds/
- 来自太空的声音：https://www.nasa.gov/sounds-from-beyond
- SoundCloud：https://soundcloud.com/nasa
- Archive.org 更全的合集：搜索 "NASA audio"

---

## 9. Incompetech / Kevin MacLeod

- 网址：https://incompetech.com
- 授权：**CC-BY 4.0**（或付费 $30/首免署名）
- 署名：CC-BY 必须，格式见下
- 格式：MP3（免费）、WAV（付费）
- 风格：极其多样（古典/奇幻/史诗/悬疑/喜剧/世界音乐）
- 注册：不需要

### 许可核心条款

**CC-BY 4.0 免费方案：**
- 可商用
- 必须署名
- 可修改/改编

**付费方案（Standard License）：**
- $30/首，一次性费用
- 不需要署名
- 适合无法署名的场景（广告等）

### 署名格式

```
[曲目名] Kevin MacLeod (incompetech.com)
Licensed under Creative Commons: By Attribution 4.0
http://creativecommons.org/licenses/by/4.0/
```

### RTS 适用音乐推荐

Kevin MacLeod 的曲库中有大量适合 RTS 的音乐：

| 类型 | 推荐曲目/专辑 |
|------|-------------|
| **史诗战斗** | "Heroic Age", "Ride of the Valkyries", "Hitman", "The Descent" |
| **中世纪/奇幻** | "Medieval", "Tavern", "Lord of the Land", "Long Note Four" |
| **悬疑/紧张** | "The Path of the Goblin King", "Volatile Reaction" |
| **胜利/庆典** | "Fanfare for Space", "Rocket", "Cipher" |
| **环境/氛围** | "Night Cave", "Mystery", "Cylinder Five" |

### 曲库规模

约 **800+ 首曲目**，涵盖几乎所有风格和情绪。是全球使用最广泛的免费音乐库之一。

### 2026 年更新

- 新增了 YouTube Content ID 保护系统（2026年4月）
- Spotify 播客和音乐上线
- 新增了 Hurdy Gurdy 调音器工具
- 网站同时提供各种实用工具（图纸生成器等）

### 源链接
- 主页：https://incompetech.com
- 音乐授权：https://incompetech.com/music/royalty-free/licenses
- FAQ：https://incompetech.com/music/royalty-free/faq.html

---

## 10. Scott Buckley Music Library

- 网址：https://www.scottbuckley.com.au/library/
- 授权：**CC-BY 4.0**（或付费免署名）
- 署名：CC-BY 必须
- 格式：MP3（免费）
- 风格：**电影级管弦乐/史诗/氛围/动作**
- 注册：不需要

### 许可核心条款

**CC-BY 4.0 免费方案：**
- 可商用
- 必须署名
- 可以修改/改编

**付费方案：**
- $40 AUD/首（单项目）
- $75 AUD/首（扩展许可）
- $300 AUD/首（全平台）
- 不需要署名

### 署名格式

```
[Music by] / [Track Title] by Scott Buckley
released under CC-BY 4.0
www.scottbuckley.com.au
```

### RTS 适用音乐推荐

| 类型 | 推荐曲目 |
|------|---------|
| **史诗战斗** | "Simulacra"（高能混合管弦动作，适合 Boss 战） |
| **史诗奇幻** | "Song Of The Forge"（矮人战歌，适合锻造/建造） |
| **太空/科幻** | "Starfire"（希望史诗管弦乐） |
| **情感/剧情** | "Amberlight"（温暖的钢琴管弦乐） |
| **探索/冒险** | "Ride The Wind" |
| **氛围/深邃** | "Memories Of Stone"（探索古代遗迹） |
| **悲伤/反思** | "Wildflowers" |
| **太空/悬疑** | "Aphelion" |

### 优势

- 质量极高，真正电影级别的管弦乐制作
- 持续更新（每周在 Twitch 直播作曲过程）
- 特别适合奇幻/史诗风格 RTS
- Patreon 社区支持

### 源链接
- 音乐库：https://www.scottbuckley.com.au/library
- 使用说明：https://www.scottbuckley.com.au/library/using-this-music
- 付费授权：https://www.scottbuckley.com.au/library/licensing

---

## 11. ZapSplat

- 网址：https://www.zapsplat.com
- 授权：**Standard License（免费需署名）/ Gold License（付费免署名）**
- 署名：免费版必须署名 "ZapSplat"
- 格式：免费版仅 MP3，Gold 版可下载 WAV
- 风格：极其多样（超过 100,000+ 音效）
- 注册：**需要免费注册**

### Standard License 核心条款（2026年5月更新版）

**你可以：**
- 用于商业和非商业项目
- 无限项目数量、全球永久
- 免费版只能下载 MP3 格式

**条件：**
- **必须署名**：在合理位置注明 "ZapSplat"（如结尾字幕、说明文档）
- 可通过升级 Gold 账户（任意金额捐赠）移除署名要求

**你不可以：**
- 将音效作为主要价值独立分发（如音效App）
- 未经许可共享/再分发原始文件

### RTS 适用性

ZapSplat 拥有超过 **100,000+ 音效和音乐曲目**，覆盖：
- 武器/战斗音效
- UI/界面音效
- 环境音效（自然/城市/幻想）
- 脚步/服装拟音
- 动物/生物叫声
- 车辆/机械音效

### 优缺点

| 优点 | 缺点 |
|------|------|
| 庞大的音效库 | 免费版只有 MP3（无 WAV） |
| 质量不错 | 必须署名（或付费免署名） |
| 分类细致 | 需要注册 |
| 有下载量限制 | 免费版有每日下载上限 |

### 源链接
- 主页：https://www.zapsplat.com
- Standard License：https://www.zapsplat.com/license-type/standard-license/
- 使用 FAQ：https://www.zapsplat.com/can-i-use-your-sound-effects-in-my-project

---

## 12. 其他补充资源

### Fesliyan Studios

- 网址：https://www.fesliyanstudios.com
- 授权：自有许可（非商用免费，商用需捐赠）
- 署名：不需要
- 格式：MP3（免费）/ WAV + STEM（付费）
- 风格：奇幻/史诗/氛围/动作/恐怖
- 特色：大量奇幻主题音乐，特别适合 RPG/策略游戏

### Free-Stock-Music.com

- 网址：https://www.free-stock-music.com
- 授权：**CC-BY 4.0**（或 $20/首免署名）
- 署名：CC-BY 必须
- 格式：MP3 320kbps（免费）/ WAV（付费）
- 风格：电影感/奇幻/Celtic/史诗
- 特色：有专门的奇幻/中世纪分类，质量高

### Patrick de Arteaga

- 网址：https://patrickdearteaga.com/en/epic-orchestral-fantasy-medieval-music
- 授权：CC-BY（署名 Patrick de Arteaga + 链接）
- 格式：MP3
- 风格：中世纪/奇幻/史诗管弦乐
- 特色：专为游戏设计的中世纪奇幻音乐

### FiftySounds

- 网址：https://www.fiftysounds.com
- 授权：**免费商用，无需署名，无注册**
- 格式：MP3 320kbps
- 风格：多种风格
- 特色：简单直接的免费音乐站

### Hove Audio (itch.io)

- 网址：https://hoveaudio.itch.io/
- 授权：免费版 CC0（无需署名），付费完整版
- 格式：WAV
- 特色：专业的剑战斗音效包（Slash/Stab/Collision/Whoosh/Voice）

### ccMixter

- 网址：https://ccmixter.org
- 授权：每个文件不同（CC-BY / CC-BY-NC）
- 风格：独立音乐人混音/原创
- 特色：社区驱动，有大量可商用音乐

### Free Music Archive (FMA)

- 网址：https://freemusicarchive.org
- 授权：每个文件不同（**大量 NC 文件**，必须逐个检查）
- 特色：历史悠久的免费音乐平台，需谨慎筛选

### BBC Sound Effects

- 网址：https://soundeffects.bbcrewind.co.uk
- 授权：**RemArc License - 仅限非商用**
- 特色：33,000+ 高质量 BBC 音效
- **注意：不可用于商业游戏！仅适合原型开发**

### OpenGameArt JC Sounds Fantasy SFX Pack

- 网址：https://opengameart.org/content/jc-sounds-fantasy-sfx-pack-vol-1
- 授权：**CC-BY 4.0**（2026年2月发布）
- 内容：58 个专业奇幻音效
  - 火/冰/电魔法（Buildup/Launch/Impact/Loop）
  - 治疗增益/黑暗魔法/传送/魔法盾
  - 重剑/标准剑/匕首 挥砍和金属碰撞
  - 弓箭 拉弓/射击/命中
- **非常适合你的 RTS 奇幻战斗**

---

## 推荐组合

### 方案 A：CC0 全部白嫖不署名（最省心）

适合：独立开发者、不想管理署名、追求零法律风险

| 需求 | 来源 | 授权 |
|------|------|------|
| **UI 点击/选择** | Kenney Interface Sounds + UI Audio | CC0 |
| **战斗命中** | Kenney Impact Sounds + OpenGameArt CC0 packs | CC0 |
| **剑/弓/魔法** | OpenGameArt CC0 SFX（80 CC0 RPG SFX 等） | CC0 |
| **环境音** | Kenney Foley Sounds + OpenGameArt CC0 | CC0 |
| **建造/升级提示** | Kenney Music Jingles | CC0 |
| **背景音乐** | OpenGameArt CC0 Fantasy Music + Kenney Music Loops | CC0 |
| **大量专业音效** | Sonniss GDC Bundle（200+ GB） | Royalty-free，无需署名 |
| **补充特效** | Pixabay SFX（Pixabay License 等效 CC0） | Pixabay License |
| **快速补缺** | Mixkit Game SFX | Mixkit Free License |

**优点**：零署名管理成本，完全不用担心法律问题  
**缺点**：音乐选择面较窄，CC0 高质量管弦乐较少

---

### 方案 B：不在乎署名，追求最佳质量（推荐）

适合：愿意在游戏内加 credits 界面的开发者

| 需求 | 来源 | 授权 |
|------|------|------|
| **所有方案 A 内容** | 方案 A 全部保留 | CC0/Royalty-free |
| **背景音乐（史诗战斗）** | Scott Buckley（CC-BY 4.0） | 需署名 |
| **背景音乐（多样风格）** | Incompetech / Kevin MacLeod（CC-BY 4.0） | 需署名 |
| **背景音乐（中世纪奇幻）** | Patrick de Arteaga（CC-BY） | 需署名 |
| **战斗音效补充** | JC Sounds Fantasy SFX Pack（CC-BY 4.0） | 需署名 |
| **大量音效补充** | ZapSplat（Standard License，需署名） | 需署名 |
| **高质量奇幻音乐** | Free-Stock-Music.com（CC-BY 4.0） | 需署名 |
| **奇幻/氛围音乐** | Fesliyan Studios（商用需捐赠） | 需捐赠 |

**署名方式**：在游戏内添加 Credits/致谢界面，列出所有 CC-BY 素材：

```
== Music ==
"Simulacra" by Scott Buckley - CC-BY 4.0 - scottbuckley.com.au
"Heroic Age" by Kevin MacLeod - CC-BY 4.0 - incompetech.com
"Goliath's Foe" by Patrick de Arteaga - CC-BY - patrickdearteaga.com

== Sound Effects ==
Fantasy SFX Pack Vol 1 by JC Sounds - CC-BY 4.0 - opengameart.org
Additional SFX by ZapSplat - zapsplat.com
```

**优点**：音乐选择面大幅扩展，质量显著提升  
**缺点**：需要维护 credits 列表，稍微增加管理成本

---

### 方案 C：商业游戏 + 最大化音质（推荐+）

适合：计划上架 Steam 等平台的商业项目，追求工业级音质

| 需求 | 来源 | 授权 | 费用 |
|------|------|------|------|
| **工业级音效主体** | **Sonniss GDC 2026 + 历年包**（200+ GB） | Royalty-free | 免费 |
| **游戏就绪音效** | **Kenney 全部音频包** | CC0 | 免费 |
| **UI/点击音效** | Mixkit Game SFX | Mixkit Free | 免费 |
| **奇幻战斗音效** | JC Sounds Fantasy SFX（CC-BY） | 需署名 | 免费 |
| **剑战斗音效** | Hove Audio Sword Combat Pack Free | CC0 | 免费 |
| **环境音补充** | Freesound CC0 + OpenGameArt CC0 | CC0 | 免费 |
| **史诗管弦配乐** | **Scott Buckley**（CC-BY 或 $40 AUD/首免署名） | CC-BY 或付费 | 免费~$40 AUD/首 |
| **多样风格配乐** | **Incompetech**（CC-BY 或 $30/首免署名） | CC-BY 或付费 | 免费~$30/首 |
| **奇幻氛围音乐** | **Fesliyan Studios**（需捐赠） | 需捐赠 | 任意金额 |
| **中世纪配乐** | **Free-Stock-Music.com**（CC-BY 或 $20/首） | CC-BY 或付费 | 免费~$20/首 |
| **补充音效** | Pixabay SFX + ZapSplat | 各自许可 | 免费 |

**策略**：
1. 优先使用 Sonniss GDC 的工业级音效作为主力
2. Kenney CC0 补充游戏 UI 和基础音效
3. Scott Buckley 的管弦乐作为战斗/Boss 配乐
4. Kevin MacLeod 补充多样风格
5. 如果有几首特别想要的曲子不想署名，花 $30-40 AUD 单首付费

**优点**：最佳音质 + 最大灵活性 + 可控成本  
**缺点**：需要花时间筛选 Sonniss 的海量内容

---

## Godot 集成建议

### 格式选择

| 用途 | 推荐格式 | 原因 |
|------|---------|------|
| 短音效（UI/命中/脚步） | **WAV** | 低延迟，Godot 加载快 |
| 背景音乐 | **OGG Vorbis** | 文件小，流式播放 |
| 循环音乐 | **OGG Vorbis** | 设置 loop=true |
| 语音 | **WAV 或 OGG** | 看长度决定 |

### 目录结构建议

```
res://
├── assets/
│   └── audio/
│       ├── sfx/           # 音效
│       │   ├── ui/        # UI 点击/选择/错误
│       │   ├── combat/    # 战斗音效
│       │   │   ├── melee/   # 近战（剑击/盾牌）
│       │   │   ├── ranged/  # 远程（弓箭/投掷）
│       │   │   └── magic/   # 魔法（火球/冰冻/闪电）
│       │   ├── units/     # 单位语音
│       │   │   ├── swordsman/
│       │   │   ├── archer/
│       │   │   └── necromancer/
│       │   ├── buildings/ # 建筑音效
│       │   └── ambient/   # 环境音
│       ├── music/         # 背景音乐
│       │   ├── menu/      # 菜单音乐
│       │   ├── battle/    # 战斗音乐
│       │   ├── peaceful/  # 和平时期
│       │   └── victory/   # 胜利/失败
│       └── credits.txt    # 署名文件（CC-BY 必需）
```

### AudioStreamPlayer 使用建议

```gdscript
# 单位语音系统示例
enum VoiceType { CONFIRM, MOVE, ATTACK, DEATH }

var voice_samples: Dictionary = {
    VoiceType.CONFIRM: [preload("res://assets/audio/sfx/units/swordsman/confirm_1.wav"),
                        preload("res://assets/audio/sfx/units/swordsman/confirm_2.wav")],
    VoiceType.MOVE: [preload("res://assets/audio/sfx/units/swordsman/move_1.wav")],
    VoiceType.ATTACK: [preload("res://assets/audio/sfx/units/swordsman/attack_1.wav"),
                       preload("res://assets/audio/sfx/units/swordsman/attack_2.wav")],
    VoiceType.DEATH: [preload("res://assets/audio/sfx/units/swordsman/death_1.wav")]
}

func play_voice(type: VoiceType) -> void:
    var samples = voice_samples.get(type, [])
    if samples.size() > 0:
        var sample = samples[randi() % samples.size()]
        $VoicePlayer.stream = sample
        $VoicePlayer.play()
```

### 音频总线设置

```
Master
├── SFX
│   ├── Combat
│   ├── UI
│   ├── Units
│   └── Ambient
└── Music
```

---

## 总结对比

| 维度 | 最佳来源 |
|------|---------|
| **CC0 音效（零风险）** | Kenney + OpenGameArt CC0 |
| **工业级音效（最佳质量）** | Sonniss GDC Bundle |
| **CC0 音乐（零风险）** | OpenGameArt CC0 Fantasy Music + Kenney Music Loops |
| **CC-BY 音乐（最佳质量）** | Scott Buckley + Incompetech |
| **UI 音效** | Kenney Interface Sounds + Mixkit |
| **奇幻战斗音效** | JC Sounds Fantasy SFX + Hove Audio + Sonniss |
| **批量下载** | GameSounds.xyz（聚合站） |
| **快速搜索补充** | Pixabay + Freesound(CC0) |

---

*报告完成。如需具体到某个音效文件的选择建议，或需要帮助配置 Godot AudioStreamPlayer 系统，请随时询问。*

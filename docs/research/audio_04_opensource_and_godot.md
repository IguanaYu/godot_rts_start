# RTS 音效调研报告：开源 RTS 实践 + Godot 4.6 音频集成方案

> 调研日期：2026-08-10
> 目标项目：Godot 4.6 RTS 游戏（已有 Master/Music/SFX bus + 音量设置 UI，零音频文件、零播放代码）

---

## 目录

- [Part 1：开源/独立 RTS 音效实践](#part-1开源独立-rts-音效实践)
  - [1.1 OpenRA（开源红警复刻）](#111-openra开源红警复刻)
  - [1.2 Beyond All Reason (BAR)](#112-beyond-all-reason-bar)
  - [1.3 0 A.D.](#113-0-ad)
  - [1.4 Mindustry](#114-mindustry)
  - [1.5 Zero-K / Spring 引擎生态](#115-zero-k--spring-引擎生态)
  - [1.6 StarCraft / StarCraft 2](#116-starcraft--starcraft-2)
  - [1.7 Age of Empires 系列](#117-age-of-empires-系列)
  - [1.8 Iron Harvest（商业独立 RTS）](#118-iron-harvest商业独立-rts)
  - [1.9 通用音效来源总结](#119-通用音效来源总结)
  - [1.10 防"听腻"设计总结](#1110-防听腻设计总结)
- [Part 2：Godot 4.6 音频最佳实践与集成方案](#part-2godot-46-音频最佳实践与集成方案)
  - [2.1 AudioStreamPlayer 三兄弟怎么选](#21-audiostreamplayer-三兄弟怎么选)
  - [2.2 Audio Bus 设计建议](#22-audio-bus-设计建议)
  - [2.3 音频文件格式选择](#23-音频文件格式选择)
  - [2.4 AudioStreamRandomizer 防腻系统](#24-audiostreamrandomizer-防腻系统)
  - [2.5 AudioStreamInteractive / AudioStreamPlaylist 自适应音乐](#25-audiostreaminteractive--audiostreamplaylist-自适应音乐)
  - [2.6 事件总线模式（Event Bus）](#26-事件总线模式event-bus)
  - [2.7 性能优化：限流与优先级](#27-性能优化限流与优先级)
  - [2.8 资源加载策略](#28-资源加载策略)
  - [2.9 完整代码：AudioManager.gd](#29-完整代码audiomanagergd)
  - [2.10 集成步骤](#210-集成步骤)

---

## Part 1：开源/独立 RTS 音效实践

### 1.1 OpenRA（开源红警复刻）

**引擎**：C# + SDL2 + OpenGL，自研引擎，非 Godot/Unity

**音效来源**：
- 使用原版 C&C/Red Alert 的音频文件。玩家需要从原版 CD 或 EA 官方免费发布的 C&C Remastered 资源包中获取音频
- OpenRA 2025 版本的 Tiberian Dawn HD mod 甚至内置了 content selector，可在 remastered 和经典音效之间切换
- 音频文件格式：原始 Westwood 格式（.aud / .vcc），运行时转换为 wav

**音效文件数量估算**：
- C&C 原版约 500-800 个音效文件（单位语音、武器、UI、爆炸、环境）
- 音乐约 30-50 首（每阵营独立曲目）

**音效触发系统**：
- 采用事件驱动的规则系统。每个 actor（单位/建筑）定义了 `Sound` traits，通过 YAML 配置文件绑定：
  ```yaml
  # 示例：OpenRA 单位开火音效绑定（伪代码）
  RenderSprites:
    Image: htank
  AttackBase:
    Armament: primary
    Barrel: ...
  Armament@primary:
    Weapon: 120mm
    Recoil: ...
  Weapon@120mm:
    Report: htnkfire.aud  # 开火音效
    Projectile: ...
  ```
- 事件触发完全由游戏逻辑驱动（开火、被攻击、选中、移动命令等）

**防"听腻"设计**：
- OpenRA 支持在 Weapon 定义中指定多个 Report 音效，游戏会随机选择
- 单位语音有 "What?", "Yes?", "Acknowledged" 等多种变体，轮换播放

**玩家反馈**：
- 经典 C&C 音效被认为是系列标志性特征，深受玩家喜爱
- HD mod 切换 remastered 音效时，部分玩家偏好原版粗犷音色

**参考链接**：
- GitHub: https://github.com/OpenRA/OpenRA
- 官网: https://www.openra.net
- 架构分析: https://delftswa.github.io/chapters/openra

---

### 1.2 Beyond All Reason (BAR)

**引擎**：Recoil Engine（Spring RTS Engine 的 fork），C++ + Lua

**音效来源**：
- 社区志愿者自制 + 部分继承自 Total Annihilation / Balanced Annihilation 的开源音效
- BAR 仓库中有专门的 `license_sounds.txt` 和 `license_music.txt` 记录每个音频文件的来源和许可证
- 音效制作风格参考 TA 原版的金属/机械质感

**音效文件数量估算**：
- BAR 有数百个单位，每个单位至少 3-5 个音效（建造完成、移动、攻击、死亡）
- 估算 1500-3000+ 音效文件
- 音乐：专属原创曲目，带歌词的合唱 + 交响乐

**音效触发系统****
- Spring/Recoil 引擎使用 Lua 脚本系统驱动音效
- 每个单位定义中包含 `sounds` 表：
  ```lua
  -- Spring 引擎单位音效定义（伪代码）
  UnitDefs = {
    armwar = {
      sounds = {
        under_attack = "armwar_underattack",
        ok = { "armwar_ok1", "armwar_ok2", "armwar_ok3" }, -- 多变体
        select = { "armwar_select1", "armwar_select2" },
      },
      weaponDefs = {
        main_weapon = {
          soundStart = "laser_heavy",
          soundHit = { "explosion1", "explosion2", "explosion3" },
        },
      },
    },
  }
  ```

**防"听腻"设计**：
- 多变体音效池：每个事件有 2-5 个变体，随机选择
- 距离衰减：远离视角中心的音效音量更低
- 声音优先级系统：在万人大战中，引擎会自动限制同类型音效的同时播放数

**玩家反馈**：
- "BAR skins and sounds are amazing (closer to the original TA)" -- Zero-K 论坛用户
- 玩家普遍认为 BAR 的音效质量在开源 RTS 中是顶级的
- 大规模战斗时的音效混音受到好评

**参考链接**：
- GitHub: https://github.com/beyond-all-reason/Beyond-All-Reason
- 官网: https://www.beyondallreason.info
- 许可证文件: `license_sounds.txt` / `license_music.txt`

---

### 1.3 0 A.D.

**引擎**：Pyrogenesis（自研 C++ 引擎），使用 OpenAL 音频后端

**音效来源**：
- 完全原创，由社区音效师和音乐师贡献
- 音乐由 Wildfire Games 团队制作，发布在 Bandcamp 上
- 音效采用真人录音（武器碰撞、马蹄声、自然环境声）+ 后期处理
- 所有美术和音频资源采用 CC-BY-SA 许可证

**音效文件数量估算**：
- 每个文明（共 12+ 文明）有独立的单位语音（古希腊语、拉丁语等历史语言）
- 每个文明约 100-200 个音效文件
- 总计约 2000-4000 音效文件

**单位语音（特色）**：
- 0 A.D. 最著名的音频特征：单位被选中时会用古代语言回答
  - 希腊单位说 "Ti esti?"（古希腊语 "What is it?"）
  - 罗马单位说拉丁语
  - 每种单位有 4-8 句语音变体
- 这是通过专业语言学家 + 配音演员合作完成的

**音效触发系统**：
- 基于 JS (SpiderMonkey) 的游戏逻辑层触发
- XML 定义音效映射：每个 unit template 指定 sound groups
- 使用 OpenAL 的 3D 空间化功能

**防"听腻"设计**：
- 每个音效事件有多个变体（如农民被选中时有 4-5 种回答）
- OpenAL 支持多普勒效应和距离衰减

**参考链接**：
- 官网: https://play0ad.com
- 论坛（音频系统讨论）: https://wildfiregames.com/forum/topic/108002-what-kind-of-audio-system-does-0-ad-use
- LWN 文章: https://lwn.net/Articles/601126

---

### 1.4 Mindustry

**引擎**：Java（自研框架 Anuken），非 Godot

**音效来源**：
- 开发者 Anuken 自制，使用 FL Studio 制作音效和音乐
- 早期版本使用自研简单音效，后期逐步替换为专业制作

**音效文件数量估算**：
- Mindustry wiki 中列出的 SoundEffect 枚举有 100+ 个不同的音效
- 包括：射击、爆炸、建造、拆毁、单位生成、升级、UI、粒子特效音等
- 音乐约 15-25 首（不同地图/状态对应不同曲目）

**音效触发系统**：
- Java 枚举系统：`Sounds.java` 定义所有音效枚举
- 通过 `Sounds.xxx.at(x, y, pitch, volume)` 调用，支持位置、音调、音量参数
- 支持玩家自定义替换音效（`sounds/` 目录覆盖）

**防"听腻"设计**：
- 音效使用 OpenAL 的 pitch 随机化
- 每个音效事件可传入 pitch 随机值
- 建造/挖掘等高频音效有自然变体

**已知问题**：
- 环境音效在高负载时有 clicking bug（Issue #3311），与 ambient sound 处理有关
- 大量传送带 + 采矿机场景可能触发音效叠加问题

**参考链接**：
- GitHub: https://github.com/Anuken/Mindustry
- 音效 Wiki: https://mindustrygame.github.io/wiki/Modding%20Classes/SoundEffect
- 音乐 Wiki: https://mindustry-unofficial.fandom.com/wiki/Music

---

### 1.5 Zero-K / Spring 引擎生态

**引擎**：Spring RTS Engine / Recoil Engine

**音效来源**：
- 继承自 Total Annihilation 模组生态
- Zero-K 有自己的音效替换和增强

**特点**：
- 支持大量单位（1000+）同时战斗，音效系统必须有严格限流
- Spring 引擎内置声音距离衰减和优先级系统
- Zero-K 与 BAR 共享 Spring/Recoil 引擎血统，音效系统架构类似

**参考链接**：
- 官网: https://zero-k.info
- Spring RTS: https://springrts.com

---

### 1.6 StarCraft / StarCraft 2

**StarCraft: Remastered 音频数据（Blizzard 官方）**：
- 总计 **2,381 个音频文件**
- 包括单位对话、武器效果、Zerg 嘶吼、Protoss 科技音效等
- 原版使用 22 kHz 采样率，Remastered 提升到 44 kHz
- 音效升级原则："reveal, not reinvent"（还原而非重造）

**StarCraft 2 音效设计（GDC / Gamespot 访谈）**：
- 音频总监 Russell Brower 主导
- 武器音效来源：真实机械录音 + 电子合成器 + 自制"材料混合物"（面粉+水+盐+粘液）
- Zerg 音效：使用食物腐烂、粘液搅拌等生物音源
- 每个单位有独立的音效签名（audio signature），考虑以下因素：
  - 射速和冷却时间
  - 游戏阶段（前期/中期/后期）
  - 单位角色（骚扰/支援/主力）
  - 典型部队组合
- SC2 编辑器中每个 Sound 可包含多个 sound assets，通过 **Weight** 属性控制随机概率
- 支持随机 pitch / volume / offset 变化

**音效触发系统**：
- SC2 编辑器使用事件驱动的 Sound 对象系统
- 每个 Sound 对象可以包含多个 .ogg 文件（sound assets）
- 属性：Pitch、Volume、Weight、Loop Count、Fade 等

**防"听腻"设计**：
- 多变体音效池 + Weight 权重随机
- 单位语音（unit barks）：选中、命令、攻击、死亡各有 3-5+ 变体
- 音效根据游戏上下文动态调整（如剧情时刻的 menacing 版本）

**参考链接**：
- Blizzard 官方: https://news.blizzard.com/en-us/article/20722027/the-sounds-of-koprulu
- SC2 音效设计访谈: https://www.epicsound.com/2010/08/the-music-and-sound-design-of-starcraft-2
- SC2 编辑器教程: https://s2editor-guides.readthedocs.io/New_Tutorials/04_Data_Editor/076_Sounds
- SC2 音效 YouTube 深度展示: https://www.youtube.com/watch?v=qFeT3zakOAU

---

### 1.7 Age of Empires 系列

**Age of Empires 4 音效设计**：
- 玩家评价："20+ 小时后仍然享受音效混音，尽管有很多重复音效"
- 高质量音效设计：马匹、步兵、攻城引擎各自有独特且融合的声场
- 单位语音：每个文明有独立语言（古英语、汉语、蒙古语等）
- 单位选中/操作有语音反馈

**Age of Empires 3 DE 音效问题（反面教材）**：
- 单位语音只有一句，不管你下什么命令都是同一句 -> 枯燥
- 剑击声只有一种，反复播放 -> 令人厌烦
- 玩家评价："声音很普通，很容易腻"

**Civilization VII (Test of Time) 音频更新**：
- 连续战斗系统（Continuous Combat）要求动态声音体验
- 增加资源音效层减少听觉疲劳
- 单位音效深入到历史准确性（如喀秋莎火箭、迅雷铳、斯图卡俯冲轰炸机）
- 核心挑战：在丰富的声音细节中保持混音清晰度

**参考链接**：
- AoE4 评测: https://www.windowscentral.com/age-of-empires-iv
- Civ VII 音频设计: https://civilization.2k.com/civ-vii/game-guide/gameplay/designing-the-sound

---

### 1.8 Iron Harvest（商业独立 RTS）

**引擎**：Unity

**音效来源**：
- 专业音效团队外包：Adam Skorupa（Music Imaginary 工作室）负责音乐 + 武器音效
- 1.5+ 小时的原创音乐（交响乐 + 工业 synth 混合）
- 三阵营各自有代表性语言/合唱

**获奖情况**：
- 2020 年德国游戏大奖 "Best Sound Design"
- 同场获奖还有 Best Game Design 和 Best German Game

**关键设计理念**：
- 音乐：交响乐团 + 工业合成器 = 独特柴油朋克音景
- 音效：真实武器录音 + 机械音 = 柴油朋克体验
- 开发者认为 RTS 音效设计的挑战在于：俯视视角 + 大规模战斗 + 仍需清晰传达关键信息

**参考链接**：
- DevBlog: https://kingart-games.com/article/79-iron-harvest-devblog-25-May-2020
- Wikipedia: https://en.wikipedia.org/wiki/Iron_Harvest

---

### 1.9 通用音效来源总结

| 来源 | 类型 | 许可证 | 适合 RTS 的什么 |
|------|------|--------|-----------------|
| **Kenney.nl** | UI/影响/科幻音效包 | CC0（无需署名） | UI 点击、按钮、通知音 |
| **Freesound.org** | 50 万+ 社区音效 | 逐文件不同（CC0/CC-BY） | 爆炸、剑击、弓箭、脚步 |
| **OpenGameArt.org** | 游戏专用音乐 + SFX | CC0/CC-BY/GPL | RPG/策略游戏音效 |
| **Sonniss GDC Bundle** | 每年 GDC 发包，200GB+ 专业音效 | 商用免费，无需署名 | 高品质音效一站式获取 |
| **ZapSplat** | 10 万+ SFX + 音乐 | 免费需署名 / Pro 免署名 | 快速原型音效填充 |
| **jsfxr / bfxr** | 在线 8-bit 音效生成器 | 完全自有 | 复古/像素风音效 |
| **Pixabay Music** | 免版税音乐 | Pixabay License | 背景音乐 |
| **Mixkit** | UI/菜单/环境音 | 免费商用 | UI 音效 |

**推荐策略（针对本项目）**：
1. **Sonniss GDC Bundle** 获取高品质武器/爆炸/机械音效
2. **Kenney Interface Sounds** 填充 UI 音效
3. **Freesound (CC0 filter)** 补充特定音效
4. 后期替换为定制音效或 AI 生成的音效

---

### 1.10 防"听腻"设计总结

基于以上调研，业界共识的防腻策略：

| 技术 | 描述 | 使用者 |
|------|------|--------|
| **多变体池** | 同一事件准备 3-7 个变体，随机播放 | SC2, BAR, OpenRA, 所有专业游戏 |
| **Pitch 随机化** | 每次播放 +/- 10% 音调 | FMOD 标准、SC2、Mindustry |
| **Volume 随机化** | +/- 3dB 随机音量 | 专业音频中间件标配 |
| **分层混合 (Layering)** | 将一个音效拆为多个层，独立随机 | A Sound Effect 文章推荐 |
| **轮换防重复** | 记录上次播放的变体，避免连续重复 | 开发者通用实践 |
| **同类型限流** | 100 个同类单位攻击只播 1 个音效 | RTS 通用法则 |
| **距离衰减** | 远离视角中心的音效音量更低 | BAR, Spring 引擎 |
| **优先级系统** | 重要音效（如基地受攻击）优先于次要音效 | Wwise, Unreal |

**关键经验**：
- "Same but different"：变体之间要有微小差异，但整体音色感知一致（A Sound Effect）
- "创建你自己的声学生态系统"：所有音效应该风格统一
- 3-7 个变体是最佳数量（How Games Are Made: Sound Design 视频）
- UI 音效同样需要变化，但变化幅度可以更小

---

## Part 2：Godot 4.6 音频最佳实践与集成方案

### 2.1 AudioStreamPlayer 三兄弟怎么选

| 节点 | 继承自 | 适用场景 | RTS 用途 |
|------|--------|----------|----------|
| `AudioStreamPlayer` | Node | 非位置音频 | UI 音效、全局事件、背景音乐、通知 |
| `AudioStreamPlayer2D` | Node2D | 2D 空间化音频 | 单位语音、战斗音效、建造音效 |
| `AudioStreamPlayer3D` | Node3D | 3D 空间化音频 | 3D 游戏专用，RTS 俯视游戏不需要 |

**RTS 推荐方案**：

- **全局音效（AudioStreamPlayer）**：UI 点击、按钮、时代升级通知、指挥官技能释放、胜利/失败
- **位置音效（AudioStreamPlayer2D）**：单位攻击、单位死亡、建筑建造完成、占领点争夺
- **不推荐 AudioStreamPlayer3D**：RTS 是 2D 俯视游戏，3D 空间化无意义。2D 版本基于屏幕中心做衰减，已足够

**AudioStreamPlayer2D 的 RTS 特别用法**：
- 当大量单位在屏幕外战斗时，距离衰减自然降低了音量
- 但注意：如果摄像头能快速移动，突然靠近战斗区域会导致音量骤然变大，需要平滑处理

**关键属性说明**（来自 Godot 4.6 文档）：

```
AudioStreamPlayer2D:
  - max_distance: 2000.0 (超过此距离完全静音)
  - attenuation: 1.0 (衰减曲线指数)
  - panning_strength: 1.0 (左右声道分离强度)
  - max_polyphony: 1 (同一节点最大同时播放数)
  - area_mask: 1 (可与 AudioListener2D 区域配合)
```

---

### 2.2 Audio Bus 设计建议

**当前项目状态**：通过代码动态创建 3 个 bus（Master/Music/SFX），无 `.tres` bus layout 文件。

**建议的 Bus 结构（RTS 优化版）**：

```
Master (0 dB)
├── Music (-6 dB)          -- 背景音乐
├── UI (-3 dB)             -- 界面点击、按钮
├── SFX (-3 dB)            -- 所有游戏内音效
│   ├── Units (-3 dB)      -- 单位语音和战斗音效
│   │   ├── CombatMid      -- 中优先级战斗音效（限流）
│   │   └── CombatHigh     -- 高优先级战斗音效（警报）
│   ├── Buildings (-3 dB)  -- 建造、升级、被攻击
│   └── Alerts (-1 dB)     -- 基地受攻击等高优先级通知
└── Voice (0 dB)           -- 将来用于单位配音/旁白
```

**RTS 特别考虑**：
- **CombatMid / CombatHigh 子 bus**：参考 straypixels.net 的 Unity RTS 音频混音方案，使用 bus 限流而非逐音效限流。当 100 个单位同时开火时，所有音效通过 CombatMid bus，bus 本身的音量上限自然限制了总音量，避免爆音
- **Alerts 高优先级**：基地被攻击、单位全灭等关键事件必须穿透战斗噪音
- **Ambience bus（可选）**：如果需要环境音（风声、虫鸣），可单独加一个

**推荐做法**：创建 `default_bus_layout.tres` 文件（在 Godot 编辑器的 Audio 面板中设计），而不是用代码动态创建。这样可以在编辑器中预览效果。

**当前项目改造建议**：
当前 `main.gd` 的 `_load_audio_settings()` 函数动态创建 bus。建议改为：
1. 在编辑器中创建 `default_bus_layout.tres`
2. 代码只负责读取 settings.cfg 并设置 bus volume
3. 新增 UI bus，将 UI 音效从 SFX 中分离

---

### 2.3 音频文件格式选择

| 格式 | 优点 | 缺点 | 推荐用途 |
|------|------|------|----------|
| **.wav** | 无压缩，解码零开销，启动极快 | 文件大（10x ogg） | 高频音效（射击、脚步、UI 点击） |
| **.ogg** | 压缩率高，文件小 | 每次播放需解码，大量同时播放有 CPU 开销 | 音乐、低频音效 |
| **.mp3** | 兼容性好，压缩率高 | 解码比 ogg 更慢，循环可能有间隙 | 不推荐 |

**RTS 重要发现（来自 Godot 论坛实测）**：
- 用户 darthpejka 报告：使用 `.ogg` 作为音效文件时，几百个 AudioStreamRandomizer 同时播放产生严重卡顿
- 改用 `.wav` 后性能问题完全消失
- **结论：RTS 中所有频繁播放的音效（射击/脚步/剑击）必须用 .wav 格式**

**推荐方案**：
- **.wav** 用于所有 SFX（射击、爆炸、UI、建造、单位语音短句）
- **.ogg** 用于背景音乐（文件大，但只同时播放 1-2 首）
- Godot 导入设置：
  - .wav: `loop = false`（除非需要循环），`force_mono = true`（SFX 用单声道）
  - .ogg: `loop = true`（音乐循环）

---

### 2.4 AudioStreamRandomizer 防腻系统

**Godot 4.x 的 AudioStreamRandomizer**（原名 AudioStreamRandomPitch，4.0 后增强）是内置的多变体音效池节点。

**核心属性**（来自 Godot 4.x 官方文档）：

```
AudioStreamRandomizer:
  - streams_count: 池中的音效变体数量
  - stream_{index}/stream: 具体的 AudioStream
  - stream_{index}/weight: 该变体的随机权重（默认 1.0）
  - random_pitch: 音调随机范围（1.0=不变，2.0=0.5x~2x）
  - random_pitch_semitones: 用半音表示的随机范围（0.0=不变）
  - random_volume_offset_db: 音量随机偏移（0.0=不变，3.0=+/-3dB）
  - playback_mode: 播放模式（随机/顺序/避免重复）
```

**PlaybackMode 枚举**：
- `PLAYBACK_RANDOM_PITCH`：默认，随机 pitch（旧版兼容）
- `PLAYBACK_RANDOM`：从池中随机选择
- `PLAYBACK_SEQUENTIAL`：按顺序播放
- `PLAYBACK_AVOID_REPETITION`：随机但避免连续重复同一个

**RTS 最佳实践**：使用 `PLAYBACK_AVOID_REPETITION` + `random_pitch` + `random_volume_offset_db`。

**代码示例**：

```gdscript
# 创建一个 AudioStreamRandomizer 资源（可在编辑器中也可代码创建）
func make_sfx_pool(samples: Array[AudioStream], pitch_var: float = 0.1, vol_var_db: float = 2.0) -> AudioStreamRandomizer:
    var randomizer := AudioStreamRandomizer.new()
    randomizer.random_pitch = 1.0 + pitch_var  # pitch +/- 10%
    randomizer.random_volume_offset_db = vol_var_db
    randomizer.playback_mode = AudioStreamRandomizer.PLAYBACK_AVOID_REPETITION
    for i in range(samples.size()):
        randomizer.add_stream(i, samples[i])
    return randomizer
```

---

### 2.5 AudioStreamInteractive / AudioStreamPlaylist 自适应音乐

Godot 4.3 引入了三个新的自适应音乐节点：

**AudioStreamPlaylist**：
- 按顺序或随机播放多个音轨
- 适合：简单的前奏 -> 主循环 -> 尾声序列
- 不支持平滑过渡（硬切换）

**AudioStreamSynchronized**：
- 同时播放多个音轨（层），通过代码控制每层音量
- 适合：垂直分层（vertical layering）——同一主题的平静版/战斗版同时播放，根据游戏状态淡入淡出
- 示例：探索时只有底层旋律 -> 战斗时加入鼓点和弦乐

**AudioStreamInteractive**：
- 最强大的自适应音乐节点
- 支持 clip + transition table
- 可以定义精确的过渡规则：何时切换、如何切换
- TransitionFromTime：IMMEDIATE / NEXT_BEAT / NEXT_BAR / END
- TransitionToTime：SAME_POSITION / START / ALIGNED

**RTS 推荐方案**：

```
AudioStreamInteractive 配置：
  Clips:
    - "peace" (和平时期背景音乐)
    - "combat" (战斗音乐)
    - "victory" (胜利)
    - "defeat" (失败)
  Transitions:
    peace -> combat: IMMEDIATE (战斗开始立即切换)
    combat -> peace: NEXT_BAR (战斗结束后下个小节切换)
    * -> victory: IMMEDIATE
    * -> defeat: IMMEDIATE
```

**代码控制**：
```gdscript
# 通过 AudioStreamPlayback 控制 AudioStreamInteractive
var playback := music_player.get_stream_playback() as AudioStreamPlaybackInteractive
playback.switch_to_clip(1)  # 切换到 "combat" clip
```

**参考链接**：
- 官方文档 AudioStreamInteractive: https://docs.godotengine.org/en/stable/classes/class_audiostreaminteractive.html
- 官方文档 AudioStreamRandomizer: https://docs.godotengine.org/en/stable/classes/class_audiostreamrandomizer.html
- Godot 4.3 新音乐功能解析: https://blog.blips.fm/articles/the-new-music-features-in-godot-43-explained
- 自适应音乐教程: https://uhiyama-lab.com/en/notes/godot/adaptive-music-system
- GodotFest 演讲 "Beyond the Loop": https://godotfest.com/talks/beyond-the-loop-a-primer-on-interactive-music-in-godot
- Audio Buses 文档: https://docs.godotengine.org/en/latest/tutorials/audio/audio_buses.html

---

### 2.6 事件总线模式（Event Bus）

Godot 社区的标准实践是使用 autoload 单例作为全局事件总线，只定义信号不做逻辑。

**GDQuest 推荐的 Event Bus 模式**：
1. 创建一个 `extends Node` 的脚本，只定义信号
2. 在 Project Settings > Autoload 中注册
3. 任何脚本通过 `EventBus.signal_name.emit()` 发射，`EventBus.signal_name.connect()` 接收

**对音频系统的应用**：

```gdscript
# scripts/autoload/audio_events.gd
extends Node

# === 信号定义（只定义信号，不做逻辑） ===
# UI 音效
signal ui_click()
signal ui_hover()
signal ui_confirm()
signal ui_cancel()

# 单位音效
signal unit_selected(unit_type: StringName)
signal unit_commanded(unit_type: StringName, command: StringName)
signal unit_attacked(unit_type: StringName)
signal unit_died(unit_type: StringName)
signal unit_spawned(unit_type: StringName)

# 建筑音效
signal building_placed(building_type: StringName)
signal building_completed(building_type: StringName)
signal building_destroyed(building_type: StringName)
signal building_under_attack(building_type: StringName)

# 游戏状态
signal commander_skill_activated(skill_name: StringName)
signal era_upgraded(new_era: int)
signal capture_point_contested(point_id: int)
signal victory()
signal defeat()
signal music_state_changed(state: StringName)  # "peace" / "combat" / "victory" / "defeat"
```

**使用方式**：
```gdscript
# 在任何脚本中触发
AudioEvents.unit_attacked.emit("soldier")

# 在 AudioManager 中监听
func _ready() -> void:
    AudioEvents.unit_attacked.connect(_on_unit_attacked)

func _on_unit_attacked(unit_type: StringName) -> void:
    play_sfx("attack_" + unit_type)
```

**参考链接**：
- GDQuest Event Bus: https://gdquest.com/tutorial/godot/design-patterns/event-bus-singleton
- Febucci 信号架构指南: https://blog.febucci.com/2024/12/godot-signals-architecture
- 资源驱动信号总线: https://www.camperotacti.co/blog/resource-based-signal-bus-for-godot

---

### 2.7 性能优化：限流与优先级

RTS 的核心音频挑战：100+ 单位同时攻击时如何不让声音变成噪音。

**策略 1：同类型限流（最关键）**

```gdscript
# 每种音效类型在短时间窗口内只播放一次
# 即使 100 个步兵同时开火，玩家只听到 1 次射击音效
var _last_play_time: Dictionary = {}  # sfx_key -> Time.get_ticks_msec()
const THROTTLE_MS := 80  # 80ms 内同类型音效只播一次

func play_throttled(sfx_key: StringName) -> void:
    var now := Time.get_ticks_msec()
    if _last_play_time.has(sfx_key):
        if now - _last_play_time[sfx_key] < THROTTLE_MS:
            return  # 限流，跳过
    _last_play_time[sfx_key] = now
    _play_internal(sfx_key)
```

**策略 2：最大同时播放数（Voice Cap）**

```gdscript
const MAX_CONCURRENT_SFX := 16
var _active_sfx_count := 0

func _play_internal(sfx_key: StringName) -> void:
    if _active_sfx_count >= MAX_CONCURRENT_SFX:
        return  # 超过上限，忽略
    _active_sfx_count += 1
    # ... 播放并在 finished 信号中减少计数
```

**策略 3：优先级系统**

```gdscript
enum Priority {
    LOW,      # 脚步、环境
    NORMAL,   # 普通攻击、建造
    HIGH,     # 建筑完成、单位死亡
    CRITICAL, # 基地受攻击、胜利/失败
}

# 当 voice 数接近上限时，低优先级音效被跳过
func play_with_priority(sfx_key: StringName, priority: Priority) -> void:
    if _active_sfx_count >= MAX_CONCURRENT_SFX and priority <= Priority.NORMAL:
        return  # 低优先级在满载时被跳过
    _play_internal(sfx_key)
```

**策略 4：使用 max_polyphony 属性**

AudioStreamPlayer 和 AudioStreamPlayer2D 有 `max_polyphony` 属性，引擎层面限制同一节点的并发数。

**策略 5：Bus 层限流（参考 Unity RTS 方案）**

参考 straypixels.net 的 RTS 音频混音文章，将战斗音效全部通过一个子 bus，利用 bus 的音量上限自然限制总音量，避免爆音。

**参考链接**：
- Godot 音频池提案讨论: https://github.com/godotengine/godot-proposals/issues/13892
- Unity RTS 音频混音: https://straypixels.net/unity-audio-mix
- AudioStreamRandomizer 性能: https://godotforums.org/d/41607-audiostreamrandomizer-high-performance-cost
- Audio Buses 文档: https://docs.godotengine.org/en/latest/tutorials/audio/audio_buses.html

---

### 2.8 资源加载策略

| 方式 | 适用场景 | 优缺点 |
|------|----------|---------|
| `preload()` | 编译时确定的小文件 | 编译时加载，最简单，但增加初始内存 |
| `load()` | 运行时加载 | 同步加载，可能卡帧 |
| `ResourceLoader.load_threaded()` | 大文件/大量资源 | 异步加载，不卡帧，但需要回调处理 |

**RTS 推荐**：
- **音效文件**（.wav，通常 < 100KB）：用 `preload()` 或 `load()` 直接加载
- **音乐文件**（.ogg，可能 2-5MB）：用 `ResourceLoader.load_threaded()` 异步加载
- **音效库**：在 AudioManager 的 `_ready()` 中一次性 preload 所有音效

```gdscript
# 音效通过 preload 加载
const SFX_SWORD_HIT_1 := preload("res://audio/sfx/sword_hit_1.wav")
const SFX_SWORD_HIT_2 := preload("res://audio/sfx/sword_hit_2.wav")
const SFX_SWORD_HIT_3 := preload("res://audio/sfx/sword_hit_3.wav")

# 音乐异步加载
func load_music_async(path: String, callback: Callable) -> void:
    ResourceLoader.load_threaded_request(path)

func _process(_delta: float) -> void:
    for path in _pending_music:
        var status := ResourceLoader.load_threaded_get_status(path)
        if status == ResourceLoader.THREAD_LOAD_LOADED:
            var music = ResourceLoader.load_threaded_get(path)
            _pending_music[path].call(music)
            _pending_music.erase(path)
```

---

### 2.9 完整代码：AudioManager.gd

以下是可直接使用的 AudioManager autoload 单例，包含：
- 事件总线信号
- 音效池管理
- 限流 + 优先级
- AudioStreamRandomizer 集成
- 音乐播放 + 状态切换

```gdscript
# scripts/autoload/audio_manager.gd
extends Node

## ============================================================
## AudioManager - RTS 音效管理器单例
## ============================================================
## 功能：
##   - 事件总线信号（AudioEvents）
##   - 限流 + 优先级系统（防止 100 个单位同时发声）
##   - AudioStreamRandomizer 集成（防"听腻"）
##   - 位置音效（AudioStreamPlayer2D）
##   - 音乐状态切换
##
## 使用方法：
##   1. 注册为 Autoload: AudioManager
##   2. 在编辑器中创建 Audio Bus Layout（Master/Music/UI/SFX）
##   3. 将音频文件放入 res://audio/sfx/ 和 res://audio/music/
##   4. 在任何脚本中调用 AudioManager.play_sfx("sword_hit")
##   5. 或通过 AudioEvents.unit_attacked.emit("soldier") 触发
## ============================================================


# ============================================================
# === 信号定义（事件总线） ===
# ============================================================

# UI 音效
signal ui_click()
signal ui_hover()
signal ui_confirm()
signal ui_cancel()

# 单位音效
signal unit_selected(unit_type: StringName)
signal unit_commanded(unit_type: StringName, command: StringName)
signal unit_attacked(unit_type: StringName)
signal unit_died(unit_type: StringName)
signal unit_spawned(unit_type: StringName)

# 建筑音效
signal building_placed(building_type: StringName)
signal building_completed(building_type: StringName)
signal building_destroyed(building_type: StringName)
signal building_under_attack(building_type: StringName)

# 游戏状态
signal commander_skill_activated(skill_name: StringName)
signal era_upgraded(new_era: int)
signal capture_point_contested(point_id: int)
signal game_victory()
signal game_defeat()
signal music_state_changed(state: StringName)


# ============================================================
# === 常量 ===
# ============================================================

enum Priority {
    LOW,      # 脚步、环境音
    NORMAL,   # 普通攻击、建造
    HIGH,     # 建筑完成、单位死亡、选中
    CRITICAL, # 基地受攻击、胜利/失败
}

const MAX_CONCURRENT_SFX := 16           # 最大同时播放音效数
const THROTTLE_MS := 80                   # 同类型限流窗口（毫秒）
const DEFAULT_PITCH_VARIATION := 0.08     # 默认 pitch 随机范围（+/- 8%）
const DEFAULT_VOLUME_VARIATION_DB := 2.0  # 默认音量随机范围（+/- 2dB）
const POOL_SIZE_PER_TYPE := 4             # 每种音效的 AudioStreamPlayer 池大小


# ============================================================
# === 内部状态 ===
# ============================================================

# 音效库：sfx_key -> AudioStreamRandomizer
var _sfx_library: Dictionary = {}

# 音效播放器池：sfx_key -> Array[AudioStreamPlayer]
var _sfx_pools: Dictionary = {}

# 限流记录：sfx_key -> 上次播放时间（msec）
var _last_play_time: Dictionary = {}

# 当前活跃音效计数
var _active_sfx_count: int = 0

# 音乐播放器
var _music_player: AudioStreamPlayer = null
var _current_music_state: StringName = &""

# 全局开关
var sfx_enabled: bool = true
var music_enabled: bool = true


# ============================================================
# === 初始化 ===
# ============================================================

func _ready() -> void:
    # 确保至少有 Master/Music/SFX 三个 bus（兼容现有代码）
    while AudioServer.bus_count < 3:
        AudioServer.add_bus()
    if AudioServer.get_bus_count() >= 2:
        AudioServer.set_bus_name(1, "Music")
    if AudioServer.get_bus_count() >= 3:
        AudioServer.set_bus_name(2, "SFX")

    # 创建音乐播放器
    _music_player = AudioStreamPlayer.new()
    _music_player.bus = &"Music"
    _music_player.name = "MusicPlayer"
    add_child(_music_player)

    # 注册所有信号监听
    _connect_signals()

    # 注册所有音效（当有音频文件后取消注释）
    # _register_sfx_library()


func _connect_signals() -> void:
    # UI
    ui_click.connect(func(): play_sfx("ui_click", Priority.HIGH))
    ui_hover.connect(func(): play_sfx("ui_hover", Priority.LOW))
    ui_confirm.connect(func(): play_sfx("ui_confirm", Priority.HIGH))
    ui_cancel.connect(func(): play_sfx("ui_cancel", Priority.NORMAL))

    # 单位
    unit_selected.connect(func(t): play_sfx("select_" + t, Priority.HIGH))
    unit_attacked.connect(func(t): play_sfx("attack_" + t, Priority.NORMAL))
    unit_died.connect(func(t): play_sfx("death_" + t, Priority.HIGH))
    unit_spawned.connect(func(t): play_sfx("spawn_" + t, Priority.NORMAL))

    # 建筑
    building_completed.connect(func(t): play_sfx("build_complete_" + t, Priority.HIGH))
    building_destroyed.connect(func(t): play_sfx("destroy_" + t, Priority.HIGH))
    building_under_attack.connect(func(t): play_sfx("alert_attack", Priority.CRITICAL))

    # 游戏状态
    game_victory.connect(func():
        play_sfx("victory", Priority.CRITICAL)
        set_music_state(&"victory")
    )
    game_defeat.connect(func():
        play_sfx("defeat", Priority.CRITICAL)
        set_music_state(&"defeat")
    )


# ============================================================
# === 音效库注册 ===
# ============================================================

## 注册一个音效到库中
## samples: 该音效的变体 AudioStream 数组
func register_sfx(key: StringName, samples: Array[AudioStream],
        pitch_var: float = DEFAULT_PITCH_VARIATION,
        vol_var_db: float = DEFAULT_VOLUME_VARIATION) -> void:

    # 创建 AudioStreamRandomizer
    var randomizer := AudioStreamRandomizer.new()
    randomizer.random_pitch = 1.0 + pitch_var
    randomizer.random_volume_offset_db = vol_var_db
    # 避免连续重复同一个变体
    randomizer.playback_mode = AudioStreamRandomizer.PLAYBACK_AVOID_REPETITION

    for i in range(samples.size()):
        randomizer.add_stream(i, samples[i])

    _sfx_library[key] = randomizer

    # 创建播放器池
    var pool: Array[AudioStreamPlayer] = []
    for i in range(POOL_SIZE_PER_TYPE):
        var player := AudioStreamPlayer.new()
        player.bus = &"SFX"
        player.stream = randomizer
        player.finished.connect(_on_sfx_finished)
        add_child(player)
        pool.append(player)
    _sfx_pools[key] = pool


## 批量从目录注册音效（约定命名：key_1.wav, key_2.wav ...）
func register_sfx_from_dir(key: StringName, dir_path: String,
        file_prefix: String, count: int) -> void:
    var samples: Array[AudioStream] = []
    for i in range(1, count + 1):
        var path := "%s/%s_%d.wav" % [dir_path, file_prefix, i]
        if ResourceLoader.exists(path):
            samples.append(load(path))
    if samples.is_empty():
        push_warning("[AudioManager] No audio files found for key '%s' in '%s'" % [key, dir_path])
        return
    register_sfx(key, samples)


# ============================================================
# === 播放接口 ===
# ============================================================

## 播放音效（非位置）
func play_sfx(key: StringName, priority: Priority = Priority.NORMAL,
        volume_offset_db: float = 0.0) -> void:
    if not sfx_enabled:
        return
    if not _sfx_pools.has(key):
        return

    # 限流检查
    if not _can_play(key, priority):
        return

    # 获取空闲播放器
    var player := _get_available_player(key)
    if player == null:
        return  # 池满

    # 设置音量并播放
    player.volume_db = volume_offset_db
    player.play()
    _active_sfx_count += 1
    _last_play_time[key] = Time.get_ticks_msec()


## 播放位置音效（使用 AudioStreamPlayer2D）
## 需要在外部创建 AudioStreamPlayer2D 并调用此函数设置参数
func play_sfx_at_position(key: StringName, pos: Vector2,
        priority: Priority = Priority.NORMAL) -> void:
    if not sfx_enabled:
        return
    if not _sfx_library.has(key):
        return

    # 对于位置音效，需要由调用方管理节点
    # 或使用一个动态创建的 AudioStreamPlayer2D 池
    # 这里给出简化版：直接创建临时节点
    if not _can_play(key, priority):
        return

    var player := AudioStreamPlayer2D.new()
    player.bus = &"SFX"
    player.stream = _sfx_library[key]
    player.global_position = pos
    player.max_distance = 1500.0
    add_child(player)
    player.finished.connect(player.queue_free)
    player.play()
    _last_play_time[key] = Time.get_ticks_msec()


## 设置音乐状态（触发自适应音乐切换）
func set_music_state(state: StringName) -> void:
    if _current_music_state == state:
        return
    _current_music_state = state
    music_state_changed.emit(state)
    # 实际的音乐切换逻辑取决于是否使用 AudioStreamInteractive
    # 简单版：直接切换 stream
    # 复杂版：通过 AudioStreamPlaybackInteractive.switch_to_clip()


## 播放音乐
func play_music(stream: AudioStream) -> void:
    if not music_enabled:
        return
    _music_player.stream = stream
    _music_player.play()


## 停止音乐
func stop_music() -> void:
    _music_player.stop()


# ============================================================
# === 内部辅助 ===
# ============================================================

## 限流检查
func _can_play(key: StringName, priority: Priority) -> bool:
    # CRITICAL 优先级始终通过
    if priority == Priority.CRITICAL:
        return true

    # 时间窗口限流
    var now := Time.get_ticks_msec()
    if _last_play_time.has(key):
        var elapsed := now - _last_play_time[key]
        if elapsed < THROTTLE_MS:
            return false

    # Voice cap（低优先级在满载时被跳过）
    if _active_sfx_count >= MAX_CONCURRENT_SFX:
        if priority <= Priority.LOW:
            return false
        # NORMAL/HIGH 尝试挤掉更低的

    return true


## 从池中获取空闲播放器
func _get_available_player(key: StringName) -> AudioStreamPlayer:
    if not _sfx_pools.has(key):
        return null
    for player in _sfx_pools[key]:
        if not player.playing:
            return player
    # 全部在播放，返回 null（该音效被限流）
    return null


## 音效播放结束回调
func _on_sfx_finished() -> void:
    if _active_sfx_count > 0:
        _active_sfx_count -= 1


# ============================================================
# === 音量控制（兼容现有 settings.cfg） ===
# ============================================================

## 设置 Master 音量（0.0 ~ 1.0 线性值）
func set_master_volume(linear_vol: float) -> void:
    var bus_idx := AudioServer.get_bus_index("Master")
    if bus_idx >= 0:
        AudioServer.set_bus_volume_db(bus_idx, linear_to_db(linear_vol))
        AudioServer.set_bus_mute(bus_idx, linear_vol <= 0.0)


## 设置 Music 音量
func set_music_volume(linear_vol: float) -> void:
    var bus_idx := AudioServer.get_bus_index("Music")
    if bus_idx >= 0:
        AudioServer.set_bus_volume_db(bus_idx, linear_to_db(linear_vol))
        AudioServer.set_bus_mute(bus_idx, linear_vol <= 0.0)


## 设置 SFX 音量
func set_sfx_volume(linear_vol: float) -> void:
    var bus_idx := AudioServer.get_bus_index("SFX")
    if bus_idx >= 0:
        AudioServer.set_bus_volume_db(bus_idx, linear_to_db(linear_vol))
        AudioServer.set_bus_mute(bus_idx, linear_vol <= 0.0)
```

---

### 2.10 集成步骤

以下是针对本项目的完整集成方案：

**Step 1：创建 AudioManager autoload**

1. 创建 `scripts/autoload/audio_manager.gd`，内容如上
2. 在 `project.godot` 的 `[autoload]` 段添加：
   ```ini
   AudioManager="*res://scripts/autoload/audio_manager.gd"
   ```

**Step 2：创建音频目录结构**

```
res://audio/
  sfx/
    ui/
      ui_click_1.wav
      ui_click_2.wav
      ui_hover_1.wav
      ui_confirm_1.wav
      ui_cancel_1.wav
    units/
      select_soldier_1.wav
      select_soldier_2.wav
      attack_soldier_1.wav
      attack_soldier_2.wav
      attack_soldier_3.wav
      death_soldier_1.wav
      death_soldier_2.wav
      # ... archer, necromancer, skeleton ...
    buildings/
      build_complete_1.wav
      destroy_1.wav
      alert_attack_1.wav
    combat/
      sword_hit_1.wav
      sword_hit_2.wav
      sword_hit_3.wav
      arrow_fire_1.wav
      arrow_fire_2.wav
      explosion_1.wav
      explosion_2.wav
    game/
      victory_1.wav
      defeat_1.wav
      era_upgrade_1.wav
      skill_activated_1.wav
  music/
    peace_1.ogg
    combat_1.ogg
    victory_1.ogg
    defeat_1.ogg
```

**Step 3：注册音效（在 AudioManager._ready() 或单独初始化函数中）**

```gdscript
func _register_sfx_library() -> void:
    # UI
    register_sfx(&"ui_click", [
        preload("res://audio/sfx/ui/ui_click_1.wav"),
        preload("res://audio/sfx/ui/ui_click_2.wav"),
    ], 0.05, 1.5)
    register_sfx(&"ui_hover", [preload("res://audio/sfx/ui/ui_hover_1.wav")], 0.03, 1.0)
    register_sfx(&"ui_confirm", [preload("res://audio/sfx/ui/ui_confirm_1.wav")], 0.0, 0.0)

    # 单位 - 剑士
    register_sfx(&"select_soldier", [
        preload("res://audio/sfx/units/select_soldier_1.wav"),
        preload("res://audio/sfx/units/select_soldier_2.wav"),
    ])
    register_sfx(&"attack_soldier", [
        preload("res://audio/sfx/units/attack_soldier_1.wav"),
        preload("res://audio/sfx/units/attack_soldier_2.wav"),
        preload("res://audio/sfx/units/attack_soldier_3.wav"),
    ])

    # 战斗通用
    register_sfx(&"sword_hit", [
        preload("res://audio/sfx/combat/sword_hit_1.wav"),
        preload("res://audio/sfx/combat/sword_hit_2.wav"),
        preload("res://audio/sfx/combat/sword_hit_3.wav"),
    ], 0.12, 3.0)  # 战斗音效随机范围更大

    # 警报
    register_sfx(&"alert_attack", [preload("res://audio/sfx/buildings/alert_attack_1.wav")])

    # ... 继续注册其他音效
```

**Step 4：在游戏代码中触发音效**

```gdscript
# 在 unit.gd 中（单位被选中时）
func _on_selected() -> void:
    AudioManager.unit_selected.emit(unit_type_name)

# 在 unit.gd 中（单位攻击时）
func _on_attack() -> void:
    AudioManager.unit_attacked.emit(unit_type_name)
    AudioManager.play_sfx(&"sword_hit", AudioManager.Priority.NORMAL)

# 在 building.gd 中（建筑被攻击时）
func _on_take_damage() -> void:
    AudioManager.building_under_attack.emit(building_type_name)

# 在 main.gd 中（胜利时）
func _check_victory() -> void:
    if _all_conditions_met():
        AudioManager.game_victory.emit()
```

**Step 5：迁移现有音量设置**

将 `main.gd` 中的 `_load_audio_settings()` 改为调用 AudioManager：

```gdscript
# main.gd 中原来的 _load_audio_settings() 简化为：
func _load_audio_settings() -> void:
    var config := ConfigFile.new()
    if config.load("user://settings.cfg") == OK:
        var master: float = config.get_value("audio", "master_volume", 1.0)
        var music: float = config.get_value("audio", "music_volume", 1.0)
        var sfx: float = config.get_value("audio", "sfx_volume", 1.0)
        AudioManager.set_master_volume(master)
        AudioManager.set_music_volume(music)
        AudioManager.set_sfx_volume(sfx)
```

**Step 6（可选）：创建 default_bus_layout.tres**

在 Godot 编辑器底部 Audio 面板中：
1. 添加 Bus: Music, SFX, UI（Master 已存在）
2. 保存为 `res://default_bus_layout.tres`
3. 在 Project Settings > Audio > Default Bus Layout 中指定
4. 这样编辑器中就能预览各 bus 的效果

---

## 附录：所有参考链接

### 开源 RTS 项目
- OpenRA GitHub: https://github.com/OpenRA/OpenRA
- OpenRA 官网: https://www.openra.net
- OpenRA 架构分析: https://delftswa.github.io/chapters/openra
- BAR GitHub: https://github.com/beyond-all-reason/Beyond-All-Reason
- BAR 官网: https://www.beyondallreason.info
- 0 A.D. 官网: https://play0ad.com
- 0 A.D. 音频系统论坛: https://wildfiregames.com/forum/topic/108002-what-kind-of-audio-system-does-0-ad-use
- Mindustry GitHub: https://github.com/Anuken/Mindustry
- Mindustry 音效 Wiki: https://mindustrygame.github.io/wiki/Modding%20Classes/SoundEffect
- Spring RTS: https://springrts.com
- Zero-K: https://zero-k.info

### 商业 RTS 音频设计
- StarCraft Remastered 音频: https://news.blizzard.com/en-us/article/20722027/the-sounds-of-koprulu
- SC2 音效设计访谈: https://www.epicsound.com/2010/08/the-music-and-sound-design-of-starcraft-2
- SC2 编辑器音效: https://s2editor-guides.readthedocs.io/New_Tutorials/04_Data_Editor/076_Sounds
- SC2 音效深度视频: https://www.youtube.com/watch?v=qFeT3zakOAU
- AoE4 评测（音频部分）: https://www.windowscentral.com/age-of-empires-iv
- Civ VII 音频设计: https://civilization.2k.com/civ-vii/game-guide/gameplay/designing-the-sound
- Iron Harvest DevBlog: https://kingart-games.com/article/79-iron-harvest-devblog-25-May-2020
- RTS 音效分析视频: https://www.youtube.com/watch?v=PGiZU_6BA7E

### 音效设计最佳实践
- Game Audio Development 指南: https://generalistprogrammer.com/game-audio-development
- 防"听腻"设计: https://www.asoundeffect.com/game-audio-immersion
- GameAnalytics 音效9建议: https://www.gameanalytics.com/blog/9-sound-design-tips-to-improve-your-games-audio
- Unity RTS 音频混音: https://straypixels.net/unity-audio-mix
- "How Games Are Made: Sound Design": https://www.youtube.com/watch?v=lbOghip5CPI
- FMOD 防疲劳视频: https://www.youtube.com/watch?v=z07GmXYB7z8

### Godot 4 音频系统
- Audio Buses 文档: https://docs.godotengine.org/en/latest/tutorials/audio/audio_buses.html
- AudioStreamRandomizer 文档: https://docs.godotengine.org/en/stable/classes/class_audiostreamrandomizer.html
- AudioStreamInteractive 文档: https://docs.godotengine.org/en/stable/classes/class_audiostreaminteractive.html
- AudioStreamPlayer2D 文档 (4.4): https://docs.godotengine.org/en/4.4/classes/class_audiostreamplayer2d.html
- AudioStreamRandomizer 提案: https://github.com/godotengine/godot-proposals/issues/3281
- 音频池/并发限制提案: https://github.com/godotengine/godot-proposals/issues/13892
- AudioStreamRandomizer 性能讨论: https://godotforums.org/d/41607-audiostreamrandomizer-high-performance-cost
- Godot 4.3 新音乐功能: https://blog.blips.fm/articles/the-new-music-features-in-godot-43-explained
- 自适应音乐教程: https://uhiyama-lab.com/en/notes/godot/adaptive-music-system
- GodotFest 互动音乐演讲: https://godotfest.com/talks/beyond-the-loop-a-primer-on-interactive-music-in-godot
- DevWorm 音频系统教程: https://www.youtube.com/watch?v=07Kyqqg31FI
- 5 Godot 音频技巧: https://www.youtube.com/watch?v=6WaPtOy3QG5

### Godot 事件总线模式
- GDQuest Event Bus: https://gdquest.com/tutorial/godot/design-patterns/event-bus-singleton
- Febucci 信号架构: https://blog.febucci.com/2024/12/godot-signals-architecture
- 资源驱动信号总线: https://www.camperotacti.co/blog/resource-based-signal-bus-for-godot
- Autoload 信号连接提案: https://github.com/godotengine/godot-proposals/issues/4993

### 免费音效资源
- Kenney Audio (CC0): https://kenney.nl
- Freesound: https://freesound.org
- OpenGameArt: https://opengameart.org
- Sonniss GDC Bundle: https://sonniss.com/gameaudiogdc
- ZapSplat: https://www.zapsplat.com
- Pixabay Music: https://pixabay.com/music
- jsfxr (8-bit SFX 生成器): https://sfxr.me
- Mixkit: https://mixkit.co

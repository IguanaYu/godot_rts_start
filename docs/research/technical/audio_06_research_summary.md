# RTS 游戏音效调研方案总结

> 调研日期：2026-08-10
> 项目：Godot 4.6 RTS（帝国时代+红警+奇幻）
> 目标：为游戏搭建完整音效系统，从资源获取到 AI 生成到 Godot 集成
> 配套详细报告：[audio_00_overview.md](audio_00_overview.md)（入口）、[audio_01-04](audio_01_free_resources.md)（专题）

---

## 1. 调研背景

### 1.1 项目现状
- Godot 4.6 RTS 游戏，已完成核心玩法（单位战斗、建筑生产、指挥官技能、时代升级、占领点胜利）
- 已有 **Master/Music/SFX 三总线**（[main.gd:1901](../../scripts/main.gd#L1901)）+ **音量设置 UI**（[game_ui.gd:1335](../../scripts/systems/game_ui.gd#L1335)）
- **零音频文件、零播放代码** —— 一张白纸，方案可以放开选
- 项目风格：奇幻+现代混合（剑士/弓箭手/Necromancer 召唤骷髅/指挥官技能）

### 1.2 核心需求
- UI 音效（点击、选择、错误）
- 战斗音效（剑击、弓箭、爆炸、魔法、召唤）
- 单位配音（选中、移动、攻击、死亡）
- 建筑音效（建造、生产、被攻击、摧毁）
- 环境音（鸟叫、风声、火焰）
- 背景音乐（史诗/奇幻/战斗/和平）
- 状态音乐切换（peace ↔ combat ↔ victory）

---

## 2. 调研覆盖范围

### 2.1 免费音效资源（13 个站）
Kenney / Freesound / OpenGameArt / Pixabay / Mixkit / GameSounds.xyz / **Sonniss GDC Bundle**（200GB+ 工业级）/ NASA / Incompetech / Scott Buckley / ZapSplat / Fesliyan / Free-Stock-Music

### 2.2 AI 音效生成工具（14 个）
ElevenLabs SFX / Stable Audio / Suno / UDIO / Replica Studios / Meta AudioCraft / AudioLDM 2 / Suno Bark / Hume AI / PlayHT / Adobe Firefly / MyEdit / Canva / SFX Engine / Flixly

### 2.3 AI 语音生成工具（17 个）
ElevenLabs / Replica Studios（已关停）/ PlayHT（已关停）/ Resemble AI / Murf.ai / WellSaid Labs / OpenAI TTS / Google Cloud TTS / Microsoft Azure TTS / MiniMax / Coqui XTTS v2 / Suno Bark / Fish Speech / CosyVoice 3 / ChatTTS / GPT-SoVITS / Cartesia

### 2.4 开源 RTS 实践
OpenRA / Beyond All Reason / 0 A.D. / Mindustry / Zero-K / Spring RTS / StarCraft 1+2 / Age of Empires 4 / Iron Harvest / Civilization VII

---

## 3. 关键发现（必读）

### 3.1 隐藏宝藏：Sonniss GDC Bundle

**这是独立开发者的核武器级资源**：
- 每年 GDC 发布一包，**累计 200GB+**
- 商业音效库厂商捐赠（SoundBits、Epic Stock Media 等）
- **商用免费、免署名、永久许可**
- 唯一限制：不能用于 AI 训练、不能单独转售
- 下载：https://gdc.sonniss.com（无需注册）

### 3.2 AI 工具的"赢家通吃"

**ElevenLabs 几乎垄断了高质量 AI 音效 + 配音市场**：
- 战斗音效、UI 音效质量最高（v2 模型 48kHz）
- 英文 TTS 行业最强，情感控制粒度无可匹敌
- 已用 SynthID 水印，版权风险相对低
- Creator 套餐 $22/月，1 个月即可完成全套音效

### 3.3 中文 TTS 的开源逆袭

**CosyVoice 3（阿里开源）超越人类水平**：
- 中文 CER **0.81%**（人类水平 1.26%）
- Apache 2.0 许可，**完全可商用**
- 需要 Linux/WSL + NVIDIA GPU（推荐 8GB+ VRAM）
- 150ms 流式延迟
- 9 种主要语言 + 18 种中文方言

### 3.4 平台存续风险（重要警告）

**两个曾经的明星平台 2025 年关停**：
- **Replica Studios**（2025-06-30）：曾经的"游戏专用 AI 配音"先驱，与 SAG-AFTRA 首签 AI 协议
- **PlayHT / Play.ai**（2025-12-31）：被 Meta 收购后关停，所有用户数据删除，无导出工具，付费不退款

**铁律**：生成后**立即下载所有音频文件到本地**，绝不依赖平台云存储。

### 3.5 RTS 音效设计铁律

来自 OpenRA / BAR / SC2 / AoE 的共识：

| 法则 | 说明 |
|------|------|
| **同类型限流** | 100 个步兵同时开火只播 1 次射击音效（不是 bug，是设计） |
| **多变体池** | 每个事件准备 3-7 个变体，避免连续重复 |
| **Pitch 随机 ±8~12%** | 每次播放音调微变，听起来不机械 |
| **Volume 随机 ±2~3 dB** | 音量微变 |
| **优先级系统** | CRITICAL（基地受攻击）穿透所有声音；LOW（脚步）满载时跳过 |
| **格式选择** | 所有 SFX 用 **.wav**（ogg 在数百并发时严重卡顿） |
| **节点选择** | 全局/UI 用 `AudioStreamPlayer`，战斗/建造用 `AudioStreamPlayer2D`，**不需要 3D** |
| **Bus 限流** | 所有战斗音效走 CombatMid 子 bus，bus 自然限制总音量避免爆音 |

StarCraft: Remastered 共 **2,381 个音频文件**，可作为参考量级。

---

## 4. 三档推荐方案

### 方案 A：零成本白嫖（先跑通）

**总成本：$0**

| 来源 | 用途 |
|------|------|
| Sonniss GDC 2015-2026（200GB+） | 工业级音效主体（武器/爆炸/环境） |
| Kenney 全音频包 | CC0 UI/通用音效 |
| OpenGameArt CC0 + Hove Audio | CC0 奇幻战斗音效 |
| Pixabay Music | 免署名 BGM |
| CosyVoice 3 本地（Apache 2.0） | 中文单位配音 |
| Suno Bark 本地（MIT） | 死亡惨叫/非语言声音 |

**适用**：项目初期、原型、不想花钱、有 GPU 跑本地 TTS。
**劣势**：筛选 200GB 内容耗时；中文配音需 WSL + GPU。

---

### 方案 B：中等预算 AI 加持（推荐）

**总成本：~$44/月**（一次性 1 个月即可完成）

| 工具 | 月费 | 用途 | 预计产出 |
|------|------|------|---------|
| **ElevenLabs Creator** | $22 | 战斗音效 + UI + 英文单位配音 | 60+ 音效 + 100 句英文语音 |
| **Stable Audio Pro** | $12 | 环境/建筑/声景 | 25+ 音效 |
| **Suno Pro** | $10 | 背景音乐 | 3-5 首 BGM |
| **CC0 补充** | $0 | Sonniss + Kenney + Pixabay | 剩余音效 |

**适用**：项目正式化、Steam 商店页面、想要独特风格。
**风险**：Suno 有训练数据诉讼，ElevenLabs 用 SynthID 相对安全。

---

### 方案 C：商业级混合方案

**总成本：$100-300** 一次性

| 来源 | 费用 | 用途 |
|------|------|------|
| Sonniss GDC 2026 | 免费 | 工业级音效主体 |
| ElevenLabs Pro | $99（1 个月） | 完整英文配音 + Boss 情感 |
| MiniMax Speech 2.8 HD | ~$0.50 按量 | 中文配音（86.2% 听众认可） |
| Scott Buckley | $0 / $40 AUD/首 | 史诗管弦 BGM |
| Kevin MacLeod | $0 / $30/首 | 多样风格 BGM |
| JC Sounds Fantasy SFX | $0（CC-BY） | 奇幻战斗 |

**适用**：商业发行、追求工业级品质。

---

## 5. 必须避开的坑

### 5.1 不可商用工具

| 工具 | 许可证 | 问题 |
|------|--------|------|
| Meta AudioCraft 模型权重 | CC-BY-NC 4.0 | 禁止商用 |
| Coqui XTTS v2 模型权重 | CPML | 禁止商用 |
| UDIO | 训练数据诉讼 | 下载功能已禁用 |
| Replica Studios | 已关停 | 不可用 |
| ElevenLabs/Suno 免费层 | 不可商用 | 必须升级到付费层 |
| BBC Sound Effects | RemArc | 仅非商用 |

### 5.2 Steam AI 披露政策（2026-01 更新）

- AI 生成的预录制音频打包到游戏中**必须披露**
- 披露位置：Steam 商店页面的 "About This Game"
- 需要做法律证明：拥有 AI 生成内容的版权
- 2025 上半年已有 **20% 新游戏**披露 AI 使用
- AI 编码助手（Claude/Copilot）**不需要披露**
- 示例文案：
  > "This game uses AI-generated voice acting for unit dialogue, created using commercially licensed TTS services."

### 5.3 声音克隆法律风险

- 美国 12+ 州有声音克隆法律
- **必须获得声音本人的书面同意**
- 安全策略：克隆自己的声音 / 用平台预置声音 / 避免克隆名人

---

## 6. Godot 集成路线图

详细代码见 [audio_04_opensource_and_godot.md §2.9](audio_04_opensource_and_godot.md)。

### Step 1：创建 AudioManager autoload 单例
- 把 `scripts/autoload/audio_manager.gd`（约 300 行，已写好）注册到 project.godot
- 包含：事件总线信号、限流系统、AudioStreamRandomizer 音效池、音乐切换

### Step 2：扩展 Audio Bus
- 当前：Master / Music / SFX（3 个，动态创建）
- 建议：增加 **UI bus**（界面音独立调节），可选加 **Voice bus**（单位配音）
- 推荐：编辑器中创建 `default_bus_layout.tres`，而非代码动态创建

```
Master
├── Music
├── UI
├── SFX
│   ├── CombatMid   # 普通战斗音效（限流）
│   ├── CombatHigh  # 高优先级警报
│   └── Units       # 单位语音/战斗
└── Voice           # 单位配音（可选）
```

### Step 3：建立目录结构
```
res://audio/
  sfx/
    ui/           # ui_click_1.wav, ui_hover_1.wav ...
    units/        # select_soldier_1.wav, attack_archer_2.wav ...
    buildings/    # build_complete_1.wav, alert_attack_1.wav ...
    combat/       # sword_hit_1.wav, arrow_fire_1.wav, explosion_1.wav ...
    game/         # victory_1.wav, defeat_1.wav, era_upgrade_1.wav ...
  music/
    peace_1.ogg
    combat_1.ogg
    victory_1.ogg
    defeat_1.ogg
```

### Step 4：注册音效到 AudioManager
- 在 `_register_sfx_library()` 中按 key 注册每个音效池
- 每种音效准备 **3-5 个变体**（防腻）
- 战斗音效 pitch 随机 ±10%，volume 随机 ±2 dB

### Step 5：在游戏代码中触发音效
```gdscript
# unit.gd（单位被选中）
AudioManager.unit_selected.emit(unit_type_name)

# unit.gd（单位攻击）
AudioManager.unit_attacked.emit(unit_type_name)

# building.gd（建筑被攻击）
AudioManager.building_under_attack.emit(building_type_name)

# main.gd（胜利）
AudioManager.game_victory.emit()
```

### Step 6：迁移现有音量设置
把 [main.gd:1901](../../scripts/main.gd#L1901) 的 `_load_audio_settings()` 简化为调用 `AudioManager.set_master_volume()` 等。

### Step 7：自适应音乐（可选进阶）
- 用 Godot 4.3 的 `AudioStreamInteractive` 做 peace ↔ combat ↔ victory 状态切换
- 战斗开始时立即切到 combat clip
- 战斗结束后下个小节切回 peace

---

## 7. 工具配置速查

### 7.1 ElevenLabs（方案 B/C 首选）
1. 注册 https://elevenlabs.io，升级到 Creator ($22/月)
2. 在 Voice Library 选音色，记录 Voice ID（如 necromancer=`xxx`, soldier=`yyy`）
3. 获取 API Key（Profile → API Keys）
4. Python 脚本批量生成（台词表 CSV → API → .mp3 文件）
5. 用 Audacity 后处理（归一化 -3 dB，48 kHz，降噪）

### 7.2 Azure TTS（中文配音云端方案）
1. 注册 Azure 账号，订阅 Speech Service（**每月 500 万字符免费**）
2. 在 Voice Gallery 试听选择（推荐 Xiaoxiao/Yunxiao Dragon HD）
3. 注意**每个汉字按 2 字符计费**
4. Custom Neural Voice 需要微软伦理审核，建议用预置声音

### 7.3 CosyVoice 3（中文配音本地零成本）
1. 需要 Linux/WSL2 + NVIDIA GPU（推荐 8GB+ VRAM）
2. `git clone https://github.com/FunAudioLLM/CosyVoice`
3. 按 README 安装依赖（Conda + Python 3.10）
4. 准备 10 秒目标声音参考音频
5. Apache 2.0 许可，**完全可商用**

### 7.4 Sonniss GDC Bundle（所有方案的基础）
1. 访问 https://gdc.sonniss.com（2026 版 7.47GB+）
2. 历年存档：https://sonniss.com/gameaudiogdc（200GB+）
3. 无需注册，直接下载每年一个大 ZIP
4. 解压后**按分类挑选**（武器/爆炸/环境/UI）

---

## 8. 推进路径建议

### 阶段 1：跑通基础设施（1 天）
- 集成 AudioManager.gd 到项目
- 建立 res://audio/ 目录结构
- 创建 default_bus_layout.tres

### 阶段 2：白嫖填充（1-2 天）
- 下载 Sonniss GDC 2026 + Kenney 全音频包
- 按清单（见 [audio_05_sound_inventory.md](audio_05_sound_inventory.md)）筛选音效
- 在 _register_sfx_library() 中注册
- 接入 5-10 个核心事件（UI 点击、单位选中、剑击、爆炸、胜利）做验证

### 阶段 3：补全音效（2-3 天）
- 按优先级（CRITICAL → LOW）逐步接入所有事件
- 调整 pitch/volume 随机化参数
- 用 AudioStreamInteractive 配置自适应音乐

### 阶段 4（可选）：AI 个性化（按预算）
- 方案 B：$44 订阅 1 个月 ElevenLabs + Stable Audio + Suno
- 生成定制音效替换 CC0 通用音效
- 生成英文/中文单位配音

### 阶段 5：合规与发布
- 在游戏内加 Credits 界面（CC-BY 素材署名）
- Steam 商店页面披露 AI 使用
- 保留所有生成工具的订阅凭证和许可证据

---

## 9. 配套文档清单

| 文件 | 用途 |
|------|------|
| [audio_00_overview.md](audio_00_overview.md) | 入口文档：决策矩阵 + 三档方案 + 合规要点 |
| [audio_01_free_resources.md](audio_01_free_resources.md) | 13 个免费资源站详细分析 |
| [audio_02_ai_sfx_tools.md](audio_02_ai_sfx_tools.md) | 14 个 AI 音效工具对比 |
| [audio_03_ai_voice.md](audio_03_ai_voice.md) | 17 个 AI 语音工具 + SAG-AFTRA + Steam 政策 |
| [audio_04_opensource_and_godot.md](audio_04_opensource_and_godot.md) | 开源 RTS 实践 + AudioManager.gd 完整代码 |
| [audio_05_sound_inventory.md](audio_05_sound_inventory.md) | 精确音效清单（基于游戏实际内容） |
| **audio_06_research_summary.md**（本文档） | 调研方案总结 |

---

## 10. 一句话决策

**最稳的路径**：先用方案 A（白嫖 Sonniss + Kenney + CosyVoice 本地）跑通基础设施和验证 → 不够再升级到方案 B（ElevenLabs Creator $22 一次性）→ 商业发行再考虑方案 C。

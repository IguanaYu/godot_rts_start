# RTS 游戏音效方案总览（汇总入口）

> 调研日期：2026-08-10
> 项目：Godot 4.6 RTS（帝国时代+红警+奇幻，含 Necromancer 召唤骷髅/指挥官技能/时代升级）
> 现状：已有 Master/Music/SFX 三总线 + 音量 UI，**零音频文件、零播放代码**

---

## 详细报告索引

| # | 主题 | 文件 |
|---|------|------|
| 01 | 免费音效资源库（CC0/CC-BY，13 个站） | [audio_01_free_resources.md](audio_01_free_resources.md) |
| 02 | AI 音效生成工具（14 个，含开源） | [audio_02_ai_sfx_tools.md](audio_02_ai_sfx_tools.md) |
| 03 | AI 语音生成（17 个工具 + SAG-AFTRA + Steam 政策） | [audio_03_ai_voice.md](audio_03_ai_voice.md) |
| 04 | 开源 RTS 实践 + Godot 集成（含可直接使用的 AudioManager.gd） | [audio_04_opensource_and_godot.md](audio_04_opensource_and_godot.md) |

---

## 决策矩阵：什么需求 → 用什么

| 音效类型 | 零成本（白嫖） | 中等预算（AI） | 商业级（混合） |
|---------|---------------|---------------|---------------|
| UI 点击/选择 | Kenney Interface Sounds (CC0) | ElevenLabs SFX | Sonniss GDC + Kenney |
| 剑击/近战 | OpenGameArt CC0 / Hove Audio | ElevenLabs SFX | Sonniss GDC 武器包 |
| 弓箭/远程 | Freesound CC0 | ElevenLabs SFX | JC Sounds Fantasy (CC-BY) |
| 爆炸/魔法 | Pixabay SFX | ElevenLabs SFX + Stable Audio | Sonniss GDC |
| 环境音 | Kenney Foley | Stable Audio Pro | Sonniss GDC + 录制 |
| 建造/生产 | Kenney Music Jingles | Stable Audio Pro | Sonniss GDC |
| 背景音乐（史诗） | OpenGameArt CC0 Fantasy | Suno Pro ($10/月) | Scott Buckley (CC-BY) |
| 背景音乐（多样） | Pixabay Music | Suno Pro | Kevin MacLeod (CC-BY) |
| 单位语音（英文） | ElevenLabs Free（不可商用） | ElevenLabs Creator $22 | ElevenLabs Pro + 真人校对 |
| 单位语音（中文） | CosyVoice 3 本地 (Apache 2.0) | Azure Dragon HD / MiniMax HD | MiniMax HD + 真人录音 |
| 死亡惨叫 | Bark 本地 (MIT) | ElevenLabs + 后处理 | 真人声优录制 |
| 胜利/失败 | Pixabay Music | Suno Pro 定制 | Scott Buckley 付费授权 |

---

## 三档推荐方案

### 方案 A：零成本白嫖（先跑通）

**总成本：$0**（用现成 CC0 + 开源 TTS）

| 类别 | 来源 | 备注 |
|------|------|------|
| 工业级音效主体 | **Sonniss GDC Bundle 2015-2026**（200GB+） | 商用免费、免署名、含武器/爆炸/环境全套 |
| UI/通用 | Kenney 全音频包 | CC0，Godot Asset Library 可直接装 |
| 奇幻战斗 | OpenGameArt CC0 SFX + Hove Audio 剑斗包 | CC0 |
| 中文单位配音 | **CosyVoice 3** 本地部署（Apache 2.0） | 中文 CER 0.81% 超越人类水平 |
| 死亡惨叫/非语言 | **Bark** 本地部署（MIT） | 可生成笑声/叹气/咆哮 |
| 背景音乐 | OpenGameArt CC0 Fantasy + Pixabay Music | 免署名 |

**适用场景**：项目初期验证、原型、不想花钱、有 GPU 跑本地 TTS。
**劣势**：筛选 200GB 内容耗时；中文配音需要 Linux/WSL + GPU 跑 CosyVoice。

---

### 方案 B：中等预算 AI 加持（推荐）

**总成本：~$44/月**，一次性订阅 1 个月即可完成全套

| 工具 | 月费 | 用途 | 预计产出 |
|------|------|------|---------|
| **ElevenLabs Creator** | $22 | 战斗音效 + UI + 英文单位配音 | ~60 个音效 + 100 句英文语音 |
| **Stable Audio Pro** | $12 | 环境/建筑/声景 | ~25 个音效 |
| **Suno Pro** | $10 | 背景音乐 | 3-5 首 BGM |
| **CC0 补充** | $0 | Sonniss + Kenney + Pixabay | 剩余音效 |

**配置步骤**：
1. 注册 ElevenLabs 升级到 Creator，在 Voice Library 为每个单位类型选好音色
2. 写好台词表 CSV（unit, action, text, emotion），调用 ElevenLabs API 批量生成
3. Stable Audio 生成环境音（森林/战场/建造）
4. Suno Pro 生成 BGM（"epic fantasy battle"、"medieval town ambient" 等 prompt）
5. 用 Audacity 统一处理：归一化到 -3 dB，48 kHz，降噪
6. 导入 Godot（详见下方集成步骤）

**适用场景**：项目正式化、Steam 商店页面、想要独特风格。
**风险**：Suno 有训练数据诉讼，ElevenLabs 用 SynthID 水印相对安全。

---

### 方案 C：商业级混合方案

**总成本：$100-300** 一次性 + 后续升级

| 来源 | 费用 | 用途 |
|------|------|------|
| **Sonniss GDC 2026** | 免费 | 工业级音效主体 |
| **ElevenLabs Pro** | $99（1 个月） | 完整英文配音 + Boss 复杂情感 |
| **MiniMax Speech 2.8 HD** | ~$0.50 按量 | 中文配音（86.2% 听众认可） |
| **Scott Buckley** | $0（CC-BY）或 $40 AUD/首（免署名） | 史诗管弦 BGM |
| **Kevin MacLeod** | $0（CC-BY）或 $30/首（免署名） | 多样风格 BGM |
| **JC Sounds Fantasy SFX** | $0（CC-BY） | 奇幻战斗音效 |
| **Hove Audio 剑斗包** | $0（CC0） | 金属剑击 |

**适用场景**：商业发行、追求工业级品质。
**优势**：所有内容都有清晰版权，Steam 披露无障碍。

---

## 风险与合规要点（必读）

### 1. 平台存续风险（重要！）

| 平台 | 状态 | 教训 |
|------|------|------|
| **Replica Studios** | 2025-06-30 已关停 | 曾经的"游戏专用 AI 配音"先驱 |
| **PlayHT / Play.ai** | 2025-12-31 已关停（Meta 收购） | API 突然下线，所有数据删除，无导出 |
| **Coqui 公司** | 2024-01 关闭 | XTTS v2 模型权重 CPML 非商用 |

**铁律**：生成后**立即下载所有音频文件**到本地，绝不依赖平台云存储。

### 2. 不可商用工具（务必避开）

| 工具 | 许可证 | 问题 |
|------|--------|------|
| Meta AudioCraft（AudioGen/MusicGen 权重） | CC-BY-NC 4.0 | 禁止商用 |
| Coqui XTTS v2 模型权重 | CPML | 禁止商用 |
| UDIO | 训练数据诉讼 | 下载功能已禁用 |
| Replica Studios | 已关停 | 不可用 |
| ElevenLabs/Suno 免费层 | 不可商用 | 必须升级到付费层 |

### 3. Steam AI 披露政策（2026-01 更新）

- AI 生成的预录制音频打包到游戏中**必须披露**
- 披露出现在 Steam 商店页面的 "About This Game"
- 需要做法律证明：拥有 AI 生成内容的版权
- 2025 上半年已有 20% 新游戏披露 AI 使用
- 示例文案："This game uses AI-generated voice acting for unit dialogue, created using commercially licensed TTS services."
- AI 编码助手（Claude/Copilot）**不需要披露**

### 4. 声音克隆法律风险

- 美国 12+ 州有声音克隆法律
- **必须获得声音本人的书面同意**
- 最安全：克隆自己的声音 / 用平台预置声音 / 完全避免克隆名人

### 5. SAG-AFTRA 影响（背景知识）

- 罢工已于 2025-07-09 结束（95% 赞成票）
- 独立开发者（非工会项目）不受直接约束
- 但克隆真人声音仍需同意

---

## Godot 集成路线图（落地步骤）

详细代码见 [audio_04_opensource_and_godot.md §2.9](audio_04_opensource_and_godot.md)。简要步骤：

### Step 1：创建 AudioManager autoload 单例
- 把 `scripts/autoload/audio_manager.gd`（约 300 行，已写好）注册到 project.godot
- 包含：事件总线信号、限流系统、AudioStreamRandomizer 音效池、音乐切换

### Step 2：扩展 Audio Bus
- 当前：Master / Music / SFX（3 个）
- 建议增加：**UI bus**（界面音独立调节），可选加 **Voice bus**（单位配音）
- 推荐做法：编辑器中创建 `default_bus_layout.tres`，而非代码动态创建

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
- 每种音效准备 **3-5 个变体**（防腻），战斗音效 pitch 随机 ±10%

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
把 `main.gd:1901` 的 `_load_audio_settings()` 简化为调用 `AudioManager.set_master_volume()` 等。

### Step 7：自适应音乐（可选进阶）
- 用 Godot 4.3 的 `AudioStreamInteractive` 做 peace ↔ combat ↔ victory 状态切换
- 战斗开始时立即切到 combat clip，战斗结束后下个小节切回 peace

---

## RTS 音效设计核心法则（来自开源 RTS 实践）

1. **同类型限流**：100 个步兵同时开火只播 1 次射击音效（BAR/SC2/AoE 共识）
2. **多变体池**：每个事件 3-7 个变体，避免连续重复（StarCraft: Remastered 共 2,381 个音频文件）
3. **Pitch 随机 ±8~12%** + **Volume 随机 ±2~3 dB**（FMOD 标准做法）
4. **优先级系统**：CRITICAL（基地受攻击）→ HIGH（建筑完成）→ NORMAL（普通攻击）→ LOW（脚步/环境）
5. **格式选择**：所有 SFX 用 **.wav**（Godot 论坛实测 ogg 在数百并发时严重卡顿）；音乐用 .ogg
6. **节点选择**：全局/UI 用 `AudioStreamPlayer`，战斗/建造用 `AudioStreamPlayer2D`（距离衰减），**不需要 3D**
7. **Bus 限流**：所有战斗音效走 CombatMid 子 bus，bus 自然限制总音量避免爆音

---

## 用户配置相关信息

### ElevenLabs 配置（如果选方案 B/C）
1. 注册 https://elevenlabs.io，升级到 Creator ($22/月)
2. 在 Voice Library 选音色，记录 Voice ID（如 necromancer=`xxx`, soldier=`yyy`）
3. 获取 API Key（Profile → API Keys）
4. 用 Python 脚本批量生成（台词表 CSV → API → .mp3 文件）

### Azure TTS 配置（中文配音）
1. 注册 Azure 账号，订阅 Speech Service（每月 500 万字符免费）
2. 在 Voice Gallery 试听选择（推荐 Xiaoxiao/Yunxiao Dragon HD）
3. 注意**每个汉字按 2 字符计费**
4. Custom Neural Voice 需要微软伦理审核，建议用预置声音

### CosyVoice 3 本地部署（零成本中文）
1. 需要 Linux/WSL2 + NVIDIA GPU（推荐 8GB+ VRAM）
2. `git clone https://github.com/FunAudioLLM/CosyVoice`
3. 准备 10 秒目标声音参考音频
4. Apache 2.0 许可，**完全可商用**

### Sonniss GDC Bundle 下载
1. 访问 https://gdc.sonniss.com（2026 版 7.47GB+）
2. 历年存档：https://sonniss.com/gameaudiogdc（200GB+）
3. 无需注册，直接下载每年一个大 ZIP
4. 解压后**按分类挑选**（武器/爆炸/环境/UI）

---

## 一句话总结

**最快上手**：先跑方案 A（白嫖 Sonniss + Kenney + CosyVoice 本地）→ 验证 AudioManager 集成 → 不够再升级到方案 B（ElevenLabs Creator $22 一次性）→ 商业发行再考虑方案 C。

**所有 4 份详细报告在 `docs/research/audio_0X_*.md`，含完整源链接和代码示例。**

# AI 语音生成用于游戏单位配音 - 深度调研报告

> 调研日期：2026-08-10
> 适用项目：Godot 4.6 RTS 游戏（帝国时代+红警+星际风格，含 Necromancer、指挥官技能、时代升级）
> 核心需求：5-10 个单位 x 10-20 句/单位 = 100-200 句单位配音

---

## 目录

1. [行业背景：SAG-AFTRA 罢工与 AI 配音伦理格局](#1-行业背景sag-aftra-罢工与-ai-配音伦理格局)
2. [Steam 平台 AI 内容披露政策](#2-steam-平台-ai-内容披露政策)
3. [工具逐项评估](#3-工具逐项评估)
   - 3.1 [ElevenLabs](#31-elevenlabs)
   - 3.2 [Replica Studios（已关停）](#32-replica-studios已关停)
   - 3.3 [PlayHT / Play.ai（已被 Meta 收购关停）](#33-playht--playai已被-meta-收购关停)
   - 3.4 [Resemble AI](#34-resemble-ai)
   - 3.5 [Murf.ai](#35-murfai)
   - 3.6 [WellSaid Labs](#36-wellsaid-labs)
   - 3.7 [OpenAI TTS](#37-openai-tts)
   - 3.8 [Google Cloud TTS](#38-google-cloud-tts)
   - 3.9 [Microsoft Azure TTS](#39-microsoft-azure-tts)
   - 3.10 [MiniMax TTS](#310-minimax-tts)
   - 3.11 [Coqui XTTS v2（开源）](#311-coqui-xtts-v2开源)
   - 3.12 [Suno Bark（开源）](#312-suno-bark开源)
   - 3.13 [Fish Speech（开源）](#313-fish-speech开源)
   - 3.14 [CosyVoice / CosyVoice 3（阿里开源）](#314-cosyvoice--cosyvoice-3阿里开源)
   - 3.15 [ChatTTS（开源）](#315-chattts开源)
   - 3.16 [GPT-SoVITS（开源）](#316-gpt-sovits开源)
   - 3.17 [其他值得关注的新工具](#317-其他值得关注的新工具)
4. [场景化推荐](#4-场景化推荐)
5. [成本估算：100 句单位语音的总成本](#5-成本估算100-句单位语音的总成本)
6. [完整工作流 Pipeline](#6-完整工作流-pipeline)
7. [风险与伦理](#7-风险与伦理)
8. [本项目的具体建议](#8-本项目的具体建议)
9. [参考来源汇总](#9-参考来源汇总)

---

## 1. 行业背景：SAG-AFTRA 罢工与 AI 配音伦理格局

### 1.1 罢工时间线

SAG-AFTRA（演员工会）于 **2024 年 7 月 26 日** 发起针对电子游戏公司的罢工，持续近 11 个月，至 **2025 年 7 月 9 日** 正式批准新合同结束。

- **罢工核心原因**：AI 数字复制品（digital replicas）的使用条款，特别是动捕演员的工作被归类为"数据"而非"表演"
- **涉及公司**：Activision、Disney Character Voices、EA、Epic Games、Insomniac Games、Take-Two、WB Games 等
- **影响范围**：约 2,600 名 SAG-AFTRA 成员，涵盖配音、动捕、歌唱、舞蹈等表演者
- **对《原神》的影响**：2025 年 3 月起，HoYoverse 多个英文配音被替换，引发社区争议

### 1.2 新合同关键条款（2025 年 7 月批准）

- 以 **95.04%** 赞成票通过
- **薪酬提升**：批准即涨 15.17%，之后 2025-2027 年每年再涨 3%
- **AI 保护条款**：
  - 要求 **同意权和披露权**（consent and disclosure requirements）
  - 表演者可在罢工期间 **暂停同意** 生成新内容
  - 必须向 SAG-AFTRA 提交数字复制品使用报告
- **独立本地化协议**：为非美国 IP 方提供项目级协议

### 1.3 关键争议事件

- **Epic Games / Fortnite 达斯·维达事件**：2025 年 5 月，SAG-AFTRA 指控 Epic 旗下 Llama Productions 未通知演员就使用 AI 生成达斯·维达配音
- **《古墓丽影》重制版事件**：Aspyr Media 使用 AI 复制 1996 年原版 Lara Croft 声优的声音，原声优表示不满
- **Embark Studios / The Finals / Arc Raiders**：使用 AI TTS 配音但获得了声优同意，玩家反应混合——部分认可"更伦理"的做法，部分担忧这是替代人类声优的 slippery slope

> **对本项目的启示**：作为独立开发者制作非工会项目（Low Budget Tiered Interactive Media Agreement 豁免），不受 SAG-AFTRA 罢工直接约束，但如果使用克隆真人声音，仍需要获得明确同意。

---

## 2. Steam 平台 AI 内容披露政策

### 2.1 政策演进

- **2024 年 1 月**：Valve 首次要求开发者披露生成式 AI 的使用
- **2024 全年**：约 1,000 款游戏披露 AI 使用
- **2025 上半年**：约 8,000 款游戏披露（暴增 8 倍），约占新发行游戏的 20%
- **2026 年 1 月 17 日**：Valve 大幅重写规则，明确分类

### 2.2 最新规则（2026 年 1 月更新）

**两类需要披露的 AI 内容**：

1. **预生成 AI 内容（Pre-generated）**：在开发期间用 AI 生成的、包含在游戏中的艺术、音乐、对话等
2. **实时生成 AI 内容（Live-generated）**：游戏运行时由 AI 实时生成的图片、音频、文本等

**不需要披露的**：
- AI 编码助手（如 GitHub Copilot）
- AI 辅助的内部工作流程工具
- 只要 AI 产出不直接包含在玩家看到/听到的游戏文件中

### 2.3 对 AI 配音的要求

- 如果使用 AI TTS 生成的语音 **打包在游戏中**（即预录制好的 .wav/.ogg），**必须披露**
- 披露内容出现在 Steam 商店页面的 "About This Game" 部分
- 开发者需做出 **法律证明（legal attestation）**：确认拥有 AI 生成内容的版权
- Valve 不承担版权责任，全部由开发者负责
- 玩家可通过 Steam Overlay 举报"非法 AI 生成内容"

### 2.4 Epic Games Store 对比

- **不要求** AI 披露
- CEO Tim Sweeney 公开批评 Steam 的 AI 标签政策

---

## 3. 工具逐项评估

### 3.1 ElevenLabs

**定位**：当前最顶级的 TTS 平台，音质和情感表现行业领先。

| 维度 | 详情 |
|------|------|
| **音色库** | 数百种预置音色，支持 Voice Marketplace 社区音色 |
| **声音克隆** | Instant Voice Cloning（30 秒样本）、Professional Voice Cloning（3+ 小时训练数据，达到录音室级品质） |
| **多语言** | 32 种语言，包括中文（zh），但**非英语质量明显下降** |
| **情感控制** | v3 模型支持情感标签、微停顿、呼吸声等，是所有工具中最强的 |
| **音质** | 最高 44.1kHz PCM / 192kbps（Pro 及以上） |
| **API** | 完善的 REST API，支持流式传输，并发数取决于套餐 |
| **批量生成** | 支持，Studio 工具可管理多场景多角色 |
| **时长限制** | 套餐制：10K 字符/月（Free）到 11M 字符/月（Business） |
| **生成速度** | 较快，但高质量模型需要数秒 |

**定价（2026 年最新）**：

| 套餐 | 月费 | 字符/月 | 商用权 | 声音克隆 | 音质 |
|------|------|---------|--------|----------|------|
| Free | $0 | 10K | 无（需署名） | 否 | 128kbps |
| Starter | $5 | 30K | 有 | Instant | 128kbps |
| Creator | $22（首月$11） | 100K | 有 | Professional（1个） | 192kbps |
| Pro | $99 | 500K-600K | 有 | Professional（1个） | 44.1kHz PCM |
| Scale | $299-330 | 1.8M-2M | 有 | Professional（3个） | 192kbps |
| Business | $990-1,320 | 6M-11M | 有 | Professional（10个） | 192kbps |

**超额费用**：Creator $0.30/1K 字符，Pro $0.24/1K，Scale $0.18/1K，Business $0.12/1K

**授权/版权**：
- 付费套餐：**完全商业使用权**，生成的音频归你所有，可用于游戏、广告、有声书等
- 免费版：**不可商用**，必须署名 ElevenLabs
- 声音克隆需要声音主人的明确同意
- ElevenLabs 保留对上传声音数据的永久许可（用于模型改进），原始录音 3 年不活跃后删除

**中文质量评估**：
- 支持中文但质量不如英文，存在语调不自然的问题
- 不如专门的中文 TTS（MiniMax、CosyVoice）地道
- 对于 RTS 短句（"准备就绪！""出击！"）基本可用

**实际游戏使用案例**：
- 被多家独立游戏开发者用于 NPC 配音
- 2026 年 StraySpark 工作室评估认为：**不适合用于主角配音**（长篇对话情感不足），但**适合用于 NPC、单位短句**

**来源**：
- [ElevenLabs 官方定价](https://elevenlabs.io/pricing)
- [Terms.Law 法律分析](https://terms.law/ai-output-rights/elevenlabs)
- [StraySpark 游戏配音评估](https://www.strayspark.studio/blog/ai-voice-acting-indie-games-elevenlabs-2026)

---

### 3.2 Replica Studios（已关停）

**定位**：曾是最知名的**游戏专用** AI 配音平台。

**状态**：**已于 2025 年 6 月 30 日关停**。网站显示告别信息。

**历史重要性**：
- 2024 年 1 月，与 SAG-AFTRA 签署了**业界首份 AI 配音协议**
- 获得 120 名演员的授权声音，支持 1,000+ 情感语调
- 推出 "Style Morphing" 功能，支持 1,000+ 情绪变体
- 被 PlaySide Studios（Age of Darkness: Final Stand）等游戏使用
- 2024 年 3 月与 Google Cloud、GlobalLogic 合作推出 "Living Games" 概念

**关停原因**：无法在 AI 市场中与最大玩家竞争，尽管有伦理优势

**教训**：
- 与 SAG-AFTRA 的合同已于 2025 年 9 月 24 日终止
- 选择 AI 配音工具时，**平台存续风险**是重要考量因素
- 建议生成后**立即下载所有音频文件并本地保存**

**来源**：
- [Replica Studios 告别页面](https://www.replicastudios.com)
- [SAG-AFTRA 合同终止声明](https://www.sagaftra.org/sag-aftra-and-replica-studios-introduce-groundbreaking-ai-voice-agreement-ces)
- [MultiLingual Media 报道](https://www.linkedin.com/posts/multilingual-media_replica-studios-is-shutting-down-what-does-activity-7335757512618528768-7p5E)

---

### 3.3 PlayHT / Play.ai（已被 Meta 收购关停）

**状态**：**已于 2025 年 12 月 31 日永久关停**。

**关停过程**：
- 2025 年 7 月：Meta 收购 PlayAI 团队
- 2025 年 7 月 26 日：API 提前下线（早于公告时间线）
- 2025 年 12 月 31 日：平台正式关闭
- 所有账号、音频、声音克隆、API 密钥被永久删除，无导出工具
- 付费订阅不退款
- play.ht 和 play.ai 域名均不再解析

**历史定价**（仅供参考）：$31.20-$99/月，600+ 声音，142 语言

**教训**：即使有大量用户和知名度的平台也可能被收购关停。**数据可移植性至关重要**。

**迁移替代方案**：
- FreeTTS PRO（$19/月，100 万字符）
- ElevenLabs（克隆质量最佳）
- SpeechGeneration AI（$5/月起）

**来源**：
- [PlayHT 关停迁移指南](https://speechgeneration.ai/compare/speechgenerationai-vs-playht)
- [FreeTTS 替代方案分析](https://freetts.org/play-ht-alternative)

---

### 3.4 Resemble AI

**定位**：企业级 AI 语音平台，同时提供 Deepfake 检测服务。

| 维度 | 详情 |
|------|------|
| **音色库** | 200+ 预置声音，支持 Marketplace |
| **声音克隆** | Rapid Clone（10 秒样本，1 分钟完成）/ Professional Clone（10-25 分钟样本，约 40 分钟训练） |
| **多语言** | 40+ 语言，含中文 |
| **情感控制** | 支持喜悦/悲伤/愤怒/恐惧等情绪参数 |
| **音质** | 高清音频，支持 Watermarking |
| **API** | 完善，支持 REST（40 req/s）和 WebSocket（20 并发） |
| **游戏集成** | **提供 Unity 插件**，曾有多家游戏工作室使用 |

**定价（2026 年 Flex Plan）**：

| 项目 | 价格 |
|------|------|
| TTS | $0.0005/秒（约 $1.8/小时） |
| 语音代理 | $0.001/秒 |
| Rapid Voice Clone | $2/月/声音 |
| Professional Voice Clone | $5/月/声音 |
| Team Seats | $20/月/用户 |
| Deepfake 检测（音频） | $0.04/秒 |

**授权**：付费即可商用，无单独非商用层

**优势**：
- 按秒计费模式，对短句批量生成友好
- 有 Unity 插件，方便游戏集成
- 情绪控制粒度较细

**劣势**：
- 音质整体评分（3.5/5）不如 ElevenLabs（4.0+/5）
- 声音市场较小
- 中文质量未有突出的基准测试表现

**来源**：
- [Resemble AI 定价分析](https://checkthat.ai/brands/resemble-ai/pricing)
- [VoiceFlow 评测](https://www.voiceflow.com/blog/resemble-ai)

---

### 3.5 Murf.ai

**定位**：面向内容创作者和企业培训的 TTS 平台。

| 维度 | 详情 |
|------|------|
| **音色库** | 200+ 声音（1,100+ 含变体），35+ 语言 |
| **声音克隆** | 企业版支持 |
| **中文支持** | 支持普通话和粤语，有男声女声，99.38% 发音准确率 |
| **情感控制** | 有限，评分 6.5/10（低于 ElevenLabs） |
| **音质** | 8kHz-48kHz，16-bit，支持 MP3/WAV/FLAC |
| **API** | Falcon API，$0.01/分钟，55ms 模型延迟，10,000 并发 |
| **游戏适用性** | 一般——更偏向 e-learning 和营销 |

**定价**：

| 套餐 | 月费（年付） | 生成额度 | 商用权 |
|------|-------------|---------|--------|
| Free | $0 | 10 分钟（终身） | 否 |
| Creator | $19 | 24 小时/年 | 有 |
| Business | $66 | 96 小时/年 | 有 |
| Enterprise | 定制 | 无限 | 有 |

**中文评估**：Murf 的中文 TTS 基于 Falcon 引擎，延迟低且发音准确率高，但**自然度和情感表现力不足以满足游戏单位配音需求**

**来源**：
- [Murf 中文 TTS 页面](https://murf.ai/text-to-speech/chinese)
- [Murf 定价分析](https://max-productive.ai/ai-tools/murf-ai)

---

### 3.6 WellSaid Labs

**定位**：企业级高端 TTS，主打企业培训和营销内容。

| 维度 | 详情 |
|------|------|
| **音色库** | 120+ 声音（"Voice Avatars"） |
| **多语言** | 支持英语、日语、中文、韩语等 |
| **情感控制** | 有限 |
| **音质** | 最高 96kHz（企业版），公认高保真 |
| **API** | 有，评分 86%（WellSaid 自评） |
| **游戏适用性** | **低**——定位企业市场，价格偏高 |

**定价**：

| 套餐 | 月费 | 下载数量 | 商用权 |
|------|------|---------|--------|
| Trial | 免费 | 试用 | 否 |
| Starter | $10 | 有限 | 有 |
| Pro | $33 | 更多 | 有 |
| Business | $160/用户 | 团队功能 | 有 |
| Enterprise | 定制 | 无限 | 有 |

**评估**：WellSaid 每小时成本约 $1.84（行业最低之一），但**语言覆盖面窄，中文质量未经充分验证，不适合 RTS 游戏配音**

**来源**：
- [WellSaid 定价](https://www.wellsaid.io/ai-voice-pricing)
- [WellSaid vs Murf 对比](https://www.fahimai.com/murf-ai-vs-wellsaid-labs)

---

### 3.7 OpenAI TTS

**定位**：OpenAI 生态内的 TTS，与 GPT 模型集成。

| 维度 | 详情 |
|------|------|
| **音色库** | 13 个预置声音（Alloy, Ash, Coral, Echo, Fable, Nova, Onyx, Sage, Shimmer + Ballad, Verse, Marin, Cedar） |
| **声音克隆** | **不支持** |
| **多语言** | 支持 Whisper 支持的所有语言（含中文） |
| **情感控制** | gpt-4o-mini-tts 支持基于 prompt 的风格控制 |
| **音质** | TTS Standard 和 TTS HD 两档 |

**定价**：

| 模型 | 价格 |
|------|------|
| TTS Standard | $15/百万字符 |
| TTS HD | $30/百万字符 |
| gpt-4o-mini-tts | $0.015/分钟（约 $0.90/小时） |

**优势**：
- gpt-4o-mini-tts 极其便宜（$0.015/分钟）
- 中文支持较好（基于 Whisper 语言模型）
- API 简单易用

**劣势**：
- **仅 13 个声音，无克隆功能**——不适合需要多角色差异化的 RTS
- 无法自定义声音特征
- 情感控制有限

**适用场景**：旁白/教练/单一角色游戏，**不适合多单位 RTS**

**来源**：
- [OpenAI TTS API 定价](https://costgoat.com/pricing/openai-tts)
- [OpenAI API 文档](https://developers.openai.com/api/docs/guides/text-to-speech)

---

### 3.8 Google Cloud TTS

**定位**：企业级云 TTS，语言覆盖最广。

| 维度 | 详情 |
|------|------|
| **音色库** | 380+ 声音，75+ 语言 |
| **声音克隆** | Instant Custom Voice（10 秒样本） |
| **中文支持** | 多种中文声音（普通话、粤语），质量中等偏上 |
| **情感控制** | Chirp 3 HD 和 Gemini TTS 支持情感 |
| **SSML** | 完善的 SSML 支持 |
| **免费额度** | 最慷慨 |

**定价**：

| 模型 | 免费额度 | 超出后价格 |
|------|---------|-----------|
| Standard | 4M 字符/月 | $4/百万字符 |
| WaveNet / Neural2 | 1M 字符/月 | $16/百万字符 |
| Chirp 3 HD | 1M 字符/月 | $30/百万字符 |
| Studio | 1M 字符/月 | $160/百万字符 |
| Instant Custom Voice | 无 | $60/百万字符 |
| Gemini 2.5 Flash TTS | 无 | 文本 $0.50/百万 token + 音频 $10/百万 token |
| Gemini 3.1 Flash TTS | 无 | 文本 $1/百万 token + 音频 $20/百万 token |

**中文优势**：
- 标准中文声音免费可用（4M 字符/月）
- WaveNet 中文质量尚可
- Chirp 3 HD 中文质量更好

**劣势**：
- 声音克隆质量不如 ElevenLabs
- 多层定价复杂
- 音质整体低于 ElevenLabs

**适用场景**：大量旁白/教程/基础配音，**RTS 单位短句尚可但缺乏个性**

**来源**：
- [Google Cloud TTS 定价](https://cloud.google.com/text-to-speech/pricing)
- [ElevenLabs vs Google Cloud TTS 对比](https://aloa.co/ai/comparisons/ai-voice-comparison/elevenlabs-vs-google-cloud-tts)

---

### 3.9 Microsoft Azure TTS

**定位**：语言覆盖最广的企业 TTS，中文表现突出。

| 维度 | 详情 |
|------|------|
| **音色库** | 600+ 神经声音，150+ 语言/区域 |
| **中文声音** | 丰富——Xiaoxiao、Yunxiao、Xiaochen、Yunyi 等，含 DragonHD 系列 |
| **声音克隆** | Custom Neural Voice（需要审核批准，约 10-30 计算小时训练） |
| **情感控制** | 支持 SSML 情感标签（cheerful, sad, angry, fearful, etc.） |
| **Dragon HD Omni** | 2025 年 12 月新发布，统一多声音模型 |
| **免费额度** | 每月 500 万字符免费（Neural） |

**定价**：

| 项目 | 价格 |
|------|------|
| Neural（标准） | $15/百万字符（每汉字算 2 字符） |
| Neural HD | ~$30/百万字符（2026 年 3 月降价） |
| Custom Voice 训练 | ~$45/计算小时 |
| Custom Voice 托管 | ~$3.5/小时（部署期间持续计费） |
| Custom Voice 合成 | ~$30/百万字符（HD 约 $40） |

**中文优势**：
- **中文声音数量业界最多**，涵盖普通话、粤语、多种方言
- Dragon HD 中文声音（如 Xiaoxiao、Yunxiao）质量很高
- 支持精细的 SSML 情感和韵律控制
- 微软在中文 NLP 方面积累深厚

**注意**：
- **每个汉字按 2 字符计费**——100 句中文配音的实际计费字符数会翻倍
- Custom Voice 需要通过微软的伦理审核
- Custom Voice 托管按小时计费（即使不使用也在计费）——建议预生成后立即取消部署

**适用场景**：**中文配音的首选云方案之一**，特别是如果需要多种情感变体

**来源**：
- [Azure TTS 定价](https://azure.microsoft.com/en-us/pricing/details/speech)
- [Azure TTS 发行说明](https://learn.microsoft.com/en-us/azure/ai-services/speech-service/releasenotes)

---

### 3.10 MiniMax TTS

**定位**：中国 AI 公司（阿里/腾讯投资），**中文 TTS 质量业界顶尖**。

| 维度 | 详情 |
|------|------|
| **音色库** | 300+ 声音，40+ 语言 |
| **声音克隆** | 10 秒样本，99% 相似度 |
| **多语言** | 中文最强（含粤语、方言），英文也达到高水准 |
| **长文本模式** | 单次最多 200,000 字符 |
| **情感控制** | Speech 2.8 支持原生声音标签如 (laughs) |
| **延迟** | 2.5 版本 ~325ms（turbo） |

**定价**：

| 模型 | 价格 |
|------|------|
| speech-2.8-turbo | $60/百万字符 |
| speech-2.8-hd | $100/百万字符 |
| Voice Cloning | $1.50/声音 |
| Voice Design | $3.00/声音 |

**中文质量评估**：
- 2026 年 10,000 听众基准测试中获 **86.2% 认可率**
- 被广泛认为是**中文 TTS 第一梯队**
- 擅长自然语调和微妙的口音处理
- 中英混说表现出色

**授权**：
- 标准 API 付费即可商用
- **无公开的声音克隆验证机制**——用户需自行确保克隆权利
- 中国和国际端点不同，注意数据驻留

**适用场景**：**中文游戏配音的首选**，尤其是需要自然中文对白的场景

**来源**：
- [MiniMax API 定价](https://developer.puter.com/tutorials/minimax-api-pricing)
- [MiniMax Speech 评测](https://invideo.io/blog/minimax-ai-voice-models)
- [Vapi Humanness Index](https://humannessindex.vapi.ai/models/minimax-tts)

---

### 3.11 Coqui XTTS v2（开源）

**定位**：开源多语言 TTS + 零样本声音克隆的黄金标准。

| 维度 | 详情 |
|------|------|
| **参数量** | ~467M |
| **语言** | 17 种，含中文（zh-cn） |
| **声音克隆** | 6 秒样本即可克隆，支持零样本 |
| **克隆质量** | 5/5 星（开源最佳） |
| **VRAM 需求** | 最低 4GB，推荐 4-6GB |
| **CPU 运行** | 可以，但较慢 |
| **GitHub Stars** | 35K+（Coqui TTS 仓库） |

**许可证问题（重要！）**：

| 组件 | 许可证 | 商用？ |
|------|--------|--------|
| Coqui TTS 工具包代码 | MPL 2.0 | 有条件商用 |
| XTTS v2 模型权重 | **CPML（Coqui Public Model License）** | **不可商用** |

> XTTS v2 模型权重是 **非商用许可**。如需商用，需要联系 Coqui 获取商业许可。但 Coqui 公司已于 2024 年 1 月关闭，社区在 Idiap 研究所维护 `coqui-tts` 包。

**优势**：
- 开源最佳的零样本声音克隆
- 可以本地运行，完全控制数据
- 17 种语言，中文支持
- 社区活跃

**劣势**：
- **CPML 非商用许可限制了商业游戏使用**
- 中文克隆质量不如 CosyVoice
- 公司已关闭，长期维护不确定

**替代方案**（商用友好的开源 TTS）：
- **Kokoro**（82M 参数，Apache 2.0，可商用，但不支持克隆）
- **Piper**（MIT，极轻量，适合嵌入式）
- **StyleTTS 2**（MIT，可商用）

**来源**：
- [Coqui XTTS v2 HuggingFace](https://huggingface.co/coqui/XTTS-v2)
- [XTTS v2 许可证分析](https://localaimaster.com/models/coqui-tts)
- [开源 TTS 对比](https://docs.clore.ai/guides/comparisons/tts-comparison)

---

### 3.12 Suno Bark（开源）

**定位**：高度表达力的 TTS，支持非语言声音。

| 维度 | 详情 |
|------|------|
| **参数量** | 未公开（基于 Transformer） |
| **语言** | 多语言，含中文 |
| **声音克隆** | 不支持（仅预置声音） |
| **特色** | 可生成笑声、叹气、音乐、音效 |
| **VRAM** | 8GB |
| **GitHub Stars** | 38K+ |

**许可证**：**MIT** - 可商用

**优势**：
- 高度表达力，适合角色表演
- 可生成非语言声音（笑声、叹气等）——对 RTS 死亡惨叫有用
- MIT 许可，完全可商用

**劣势**：
- **不支持声音克隆**
- 推理较慢
- 声音一致性控制不如 XTTS
- 输出质量不稳定

**来源**：
- [Bark GitHub](https://github.com/suno-ai/bark)
- [开源 TTS 对比](https://docs.clore.ai/guides/comparisons/tts-comparison)

---

### 3.13 Fish Speech（开源）

**定位**：中文开源 TTS，TTS Arena 排名靠前。

| 维度 | 详情 |
|------|------|
| **版本** | S1/S2（最新 S2 Pro，~0.5B+ 参数） |
| **训练数据** | 1000 万+ 小时多语言音频 |
| **声音克隆** | 10 秒样本，5/5 星质量 |
| **延迟** | ~100ms TTFA（托管 API） |
| **中文质量** | 开源最佳之一 |

**许可证**：
- **Fish Audio Research License（代码）+ CC-BY-NC-SA-4.0（部分模型权重）**
- **商用风险较大**：不同版本许可不同，必须仔细检查
- S2 Pro 托管 API：~$15/百万字符

**优势**：
- 中文克隆质量顶尖
- 情感标签支持（[whisper]、[pitch up]、[excited]）
- Dual-AR 架构，推理效率高

**劣势**：
- **许可证复杂，商用需逐版本确认**
- 需要 GPU（4B 参数）
- 两步推理流程（语义 token -> wav），不如其他工具直接

**来源**：
- [Fish Speech 开源分析](https://neosophie.com/en/blog/20260317-tts)
- [开源 TTS 对比](https://docs.clore.ai/guides/comparisons/tts-comparison)

---

### 3.14 CosyVoice / CosyVoice 3（阿里开源）

**定位**：阿里巴巴 FunAudioLLM 项目，**中文 TTS SOTA（当前最佳）**。

| 维度 | 详情 |
|------|------|
| **最新版本** | Fun-CosyVoice 3（0.5B 和 1.5B 参数） |
| **中文 CER** | 0.81%（RL 版本），接近人类水平（1.26%） |
| **说话人相似度** | 78.0%，接近人类水平（75.5%） |
| **语言** | 9 种主要语言 + 18 种中文方言 |
| **声音克隆** | 零样本克隆 |
| **流式延迟** | 150ms（超低） |
| **情感控制** | 支持，支持发音纠正 |

**许可证**：**Apache 2.0** - **完全可商用**

**性能对比（CER%，越低越好）**：

| 模型 | 中文 CER | 英文 WER |
|------|---------|---------|
| F5-TTS | 1.52 | 2.00 |
| GPT-SoVITS | 7.34 | 12.5 |
| CosyVoice 2 | 1.45 | 2.57 |
| CosyVoice 3 (0.5B) | 1.21 | 2.24 |
| CosyVoice 3 (0.5B, RL) | **0.81** | **1.68** |
| 人类 | 1.26 | 2.14 |

**优势**：
- **中文 TTS 开源绝对王者**，超越人类水平
- **Apache 2.0 许可，完全可商用**
- 支持方言（粤语、四川话、上海话、天津话）
- 150ms 超低延迟
- 情感控制、发音纠正功能
- 阿里巴巴生产环境验证

**劣势**：
- 英文质量不是顶尖（WER 1.68% vs 专门英文模型）
- 需要 GPU（推荐 NVIDIA CUDA）
- 安装配置需要 Linux + Python 3.10 + Conda
- 中文方言支持还有提升空间

**对本项目的重要性**：**如果游戏需要中文配音，CosyVoice 3 是最佳开源选择**

**来源**：
- [CosyVoice 2025 完整指南](https://deepwiki.directory/blog/2025-cosyvoice-complete-guide)
- [CosyVoice 3 论文](https://arxiv.org/html/2505.17589v2)
- [开源 TTS 评测](https://neosophie.com/en/blog/20260317-tts)

---

### 3.15 ChatTTS（开源）

**定位**：专为对话场景设计的 TTS。

| 维度 | 详情 |
|------|------|
| **训练数据** | ~10 万小时中英文数据 |
| **语言** | 中文 + 英文 |
| **声音克隆** | 有限支持（社区 UI 版本） |
| **特色** | 自然对话风格，适合聊天机器人 |

**许可证**：需确认（未明确标注 Apache 或 MIT）

**优势**：
- 对话风格自然
- 中英双语

**劣势**：
- 声音克隆能力不如 CosyVoice / GPT-SoVITS
- 更适合对话而非角色配音
- 社区评测认为综合能力不如 CosyVoice

**来源**：
- [BentoML 开源 TTS 评测](https://www.bentoml.com/blog/exploring-the-world-of-open-source-text-to-speech-models)
- [JCHub 中文 TTS 评测](https://blog.jianchihu.net/voice-clone-tts-simple-research.html)

---

### 3.16 GPT-SoVITS（开源）

**定位**：中文少样本声音克隆"黑马"。

| 维度 | 详情 |
|------|------|
| **语言** | 中文、英文、日语、韩语 |
| **声音克隆** | 支持少样本克隆 |
| **特色** | 中文/粤语少样本克隆效果优秀 |
| **社区评价** | "最全面、最方便后续微调、综合表现最佳" |

**许可证**：需确认

**性能**（CosyVoice 3 论文基准）：
- 中文 CER：7.34%（不如 CosyVoice 3 的 0.81%）
- 英文 WER：12.5%

**优势**：
- 少样本克隆（粤语表现突出）
- 有完整的 WebUI 和 Gradio 界面
- 社区活跃，不断更新

**劣势**：
- 准确度不如 CosyVoice 3
- 需要手动微调流程

**来源**：
- [CosyVoice 3 对比基准](https://arxiv.org/html/2505.17589v2)
- [JCHub 评测](https://blog.jianchihu.net/voice-clone-tts-simple-research.html)

---

### 3.17 其他值得关注的新工具

#### Cartesia
- **特色**：超低延迟（~40ms TTFB），实时 TTS
- **定价**：Free（10K 字符）→ Pro $49/月（1.25M 字符）→ Startup $299/月
- **适用**：需要实时对话的游戏

#### Smallest.ai
- **特色**：高质量克隆 + 多语言 + 有竞争力定价
- **定价**：Free（30 分钟）→ $5/月（3 小时 + 8 克隆）→ $29/月（25 小时 + 25 克隆）

#### Hume AI
- **特色**：情感智能 TTS，基于 LLM 的韵律生成
- **适用**：需要真实情感表达的内容

#### Chatterbox
- **许可证**：MIT（完全可商用）
- **特色**：开源、可商用、有声音克隆

#### Qwen3-TTS（阿里通义千问 TTS）
- **许可证**：Apache 2.0（可商用）
- **特色**：2026 年新出，质量与 CosyVoice 3 接近

---

## 4. 场景化推荐

### 4.1 英文单位配音（选中/移动/攻击/死亡）

| 推荐级别 | 工具 | 理由 |
|---------|------|------|
| **首选** | **ElevenLabs Creator ($22/月)** | 英文 TTS 质量最高，情感控制最强，声音克隆可创建统一角色音色 |
| 次选 | OpenAI TTS ($15/M 字符) | 便宜，但仅 13 个声音无法克隆 |
| 预算极低 | Azure TTS Neural ($15/M 字符) | 免费额度大，声音多 |

**推荐理由**：ElevenLabs Professional Voice Cloning 可以用一个角色声音生成所有台词，保证 100+ 句语音风格一致。每次只需 $22（Creator 月费），即可获得 100K 字符（约 2 小时音频），完全够用。

### 4.2 中文单位配音

| 推荐级别 | 工具 | 理由 |
|---------|------|------|
| **首选（商用）** | **Azure TTS Dragon HD** | 中文声音最丰富，SSML 情感控制精细，免费额度大 |
| **首选（质量）** | **MiniMax Speech 2.8 HD** | 中文自然度最高，86.2% 听众认可率 |
| **首选（免费/本地）** | **CosyVoice 3** | 开源 SOTA 中文 TTS，Apache 2.0 可商用 |
| 次选 | Google Cloud TTS Chirp 3 HD | 中文质量尚可，免费额度大 |

**推荐理由**：
- 如果游戏上 Steam 要做中文配音：Azure Dragon HD（如 Xiaoxiao、Yunxiao 声音）
- 如果追求最高中文质量：MiniMax Speech 2.8 HD
- 如果想完全免费且本地运行：CosyVoice 3（Apache 2.0）

### 4.3 反派 Boss 配音

| 推荐级别 | 工具 | 理由 |
|---------|------|------|
| **首选** | **ElevenLabs Pro ($99/月)** | 最强的情感表现力，可以做阴险、愤怒、嘲讽等复杂情绪 |
| 次选 | MiniMax HD | 中文 Boss 角色表现力强 |
| 创意选择 | Suno Bark (MIT 开源) | 可生成非语言声音（咆哮、低吼），适合怪物类 Boss |

**推荐理由**：Boss 角色需要丰富的情感层次（嘲讽、暴怒、死亡惨叫），ElevenLabs v3 模型的情感控制能力无可匹敌。

### 4.4 旁白/指挥官

| 推荐级别 | 工具 | 理由 |
|---------|------|------|
| **首选** | **Azure TTS Dragon HD** 或 **ElevenLabs** | 旁白需要稳定、大气的声音 |
| 次选 | WellSaid Labs | 专攻企业旁白，但价格较高 |
| 中文 | Azure Yunxiao (DragonHD) | 成稳的中文男声 |

### 4.5 Necromancer 召唤语音（特殊需求）

| 需求 | 推荐工具 |
|------|---------|
| 邪恶低语/咒语 | ElevenLabs（情感控制 + whisper 模式） |
| 召唤音效/非人声 | Suno Bark（可生成非语言声音） |
| 中文咒语 | MiniMax HD + 情感标签 |

---

## 5. 成本估算：100 句单位语音的总成本

### 5.1 前提假设

- 5 个单位 x 平均 20 句 = 100 句语音
- 每句平均 5-10 个词（英文）或 5-15 个字（中文）
- 英文：平均 50 字符/句 = 5,000 字符总量
- 中文：平均 12 字/句 = 1,200 字（Azure 计费按 2,400 字符）
- 每句生成 2-3 个变体供筛选 = 实际使用 10,000-15,000 字符
- 每句平均 2-3 秒音频 = 总计约 200-300 秒（3.3-5 分钟）

### 5.2 各方案成本对比

| 方案 | 英文成本 | 中文成本 | 备注 |
|------|---------|---------|------|
| **ElevenLabs Creator** | $22（1 个月） | $22（1 个月） | 100K 字符足够 10x 用量 |
| **ElevenLabs Starter** | $5 | $5 | 30K 字符，刚好够用 |
| **MiniMax Turbo** | ~$0.30 | ~$0.15 | 按量计费，5K 字符仅 $0.30 |
| **MiniMax HD** | ~$0.50 | ~$0.25 | HD 质量 |
| **Azure Neural** | ~$0.08 | ~$0.04 | 在免费额度内 |
| **Azure Dragon HD** | ~$0.15 | ~$0.07 | 在免费额度内 |
| **Google Chirp 3 HD** | ~$0.15 | ~$0.07 | 在免费额度内 |
| **OpenAI TTS Standard** | ~$0.08 | ~$0.08 | 极便宜 |
| **Resemble AI Flex** | ~$0.15 | ~$0.15 | 按秒计费 |
| **CosyVoice 3（本地）** | $0（电费） | $0（电费） | 需要 GPU |
| **Murf Creator** | $19 | $19 | 24h/年额度足够 |

### 5.3 推荐的最低成本方案

**纯英文配音**：
- ElevenLabs Starter $5/月 -- 1 个月完成所有语音
- **总成本：$5**

**中文配音**：
- Azure TTS Neural -- 免费额度内
- **总成本：$0**（利用 500 万字符/月免费额度）

**最高质量双语配音**：
- ElevenLabs Creator ($22) + MiniMax HD ($0.25)
- **总成本：$22.25**

**完全免费方案**：
- CosyVoice 3 本地部署 + Bark 用于死亡惨叫
- **总成本：$0**（仅电费和 GPU 折旧）

---

## 6. 完整工作流 Pipeline

### 6.1 设计阶段

```
1. 角色设定
   ├── 确定每个单位的性格（如：Necromancer = 阴森、低沉）
   ├── 编写台词表（选中/移动/攻击/死亡/彩蛋）
   └── 标注每句的情感标签（normal/angry/whisper/dying）

2. 声音选型
   ├── 英文：在 ElevenLabs Voice Library 中试听选择
   ├── 中文：在 Azure Voice Gallery 或 MiniMax 中试听选择
   └── 记录每个单位使用的 Voice ID
```

### 6.2 生成阶段

```
3. 批量生成
   ├── 方法 A：使用平台 Web Studio 逐句生成
   ├── 方法 B：通过 API 脚本批量生成（推荐）
   │   ├── 编写 Python 脚本读取台词表 CSV
   │   ├── 为每句生成 3 个变体（不同 seed/参数）
   │   └── 自动命名保存（unit_select_01_v1.wav）
   └── 每个 Voice ID 保持一致

4. 筛选与迭代
   ├── 人工试听所有变体
   ├── 选出最佳版本
   ├── 对不满意的重试（调整参数或改写文本）
   └── 注意：有些工具对相同文本可能需要加 [pause] 或标点调整
```

### 6.3 后期处理

```
5. 音频后处理
   ├── 工具：Audacity（免费）/ Reaper / Adobe Audition
   ├── 标准化响度：-16 LUFS（游戏语音标准）
   ├── 降噪（如有背景噪声）
   ├── 裁剪首尾静音
   ├── 如需要：添加角色特效（radio 滤波、reverb、phone 效果）
   └── 输出格式：Godot 推荐 .ogg（压缩）或 .wav（无损）

6. 批量处理脚本（Python + pydub）
   ├── 读取所有音频文件
   ├── 应用标准化
   ├── 统一格式和采样率（22050Hz 或 44100Hz）
   └── 输出到 res://audio/voices/{unit_type}/{action}/
```

### 6.4 Godot 集成

```
7. 游戏集成
   ├── 文件组织
   │   └── res://audio/voices/
   │       ├── necromancer/
   │       │   ├── select_01.ogg
   │       │   ├── select_02.ogg
   │       │   ├── move_01.ogg
   │       │   ├── attack_01.ogg
   │       │   └── death.ogg
   │       ├── soldier/
   │       └── archer/
   │
   ├── 代码实现（unit.gd）
   │   ├── 预加载音频流
   │   ├── _on_selected() -> 随机播放 select 音频
   │   ├── _on_command_move() -> 随机播放 move 音频
   │   ├── _on_command_attack() -> 随机播放 attack 音频
   │   └── _on_death() -> 播放 death 音频
   │
   └── 重复点击彩蛋
       ├── 记录连续选中次数
       └── 第 N 次播放特殊搞笑台词
```

### 6.5 推荐的生成脚本模板（伪代码）

```python
# generate_voices.py
import csv
from elevenlabs import generate, save, set_api_key

set_api_key("your-api-key")

VOICE_MAP = {
    "necromancer": "voice-id-xxx",
    "soldier":     "voice-id-yyy",
    "archer":      "voice-id-zzz",
}

with open("voice_lines.csv") as f:
    reader = csv.DictReader(f)
    for row in reader:
        unit = row["unit"]
        action = row["action"]
        text = row["text"]
        emotion = row.get("emotion", "normal")

        for variant in range(3):  # 生成 3 个变体
            audio = generate(
                text=text,
                voice=VOICE_MAP[unit],
                model="eleven_multilingual_v2",
            )
            filename = f"output/{unit}_{action}_{variant+1}.mp3"
            save(audio, filename)
            print(f"Generated: {filename}")
```

---

## 7. 风险与伦理

### 7.1 玩家对 AI 配音的接受度

**当前行业态势（2025-2026）**：

- **Arc Raiders / The Finals**（Embark Studios）：使用 AI TTS 配音但获得了声优同意。玩家反应**混合**——部分认可"更伦理"的做法，部分担忧这是替代人类声优的 slippery slope
- **2025 年 Steam 数据**：约 20% 新发行游戏披露使用 AI，说明已成为主流
- **玩家社区分化**：
  - 一部分玩家不在意 AI 配音，只要质量够好
  - 一部分玩家强烈反对，认为降低了游戏品质
  - 独立游戏的接受度高于 3A 大作（玩家理解成本限制）

**建议策略**：
- **透明披露**：在 Steam 页面诚实标注 AI 配音使用
- **质量优先**：宁可少用，也要确保用到的每句都质量过关
- **混合策略**：重要角色用真人配音，普通单位用 AI

### 7.2 声音克隆的法律风险

**美国法律状态**：
- 至少 12 个州已通过声音克隆法律
- 需要声音主人的明确同意
- 联邦层面：SAG-AFTRA 新合同要求同意权和披露权

**最佳实践**：
- **克隆自己的声音**（最安全）
- 如果克隆他人：获取书面授权
- 使用平台预置声音（无法律风险）
- 避免克隆名人/演员声音

**工具选择影响**：
- ElevenLabs：有严格的克隆政策，要求验证
- MiniMax：无公开验证机制，用户全责
- Azure Custom Voice：需要微软伦理审核

### 7.3 Steam 平台合规

**必须做到**：
- 在 Steamworks Content Survey 中勾选 AI 使用
- 披露说明：简洁描述 AI 用于生成语音
- 示例文案："This game uses AI-generated voice acting for unit dialogue, created using commercially licensed TTS services with either pre-built or self-recorded voice models."
- 确保使用的工具的商业许可有效

**版权注意**：
- AI 生成的纯内容在美国**可能无法获得版权保护**（Allen v. U.S. Copyright Office, 2024）
- 但作为游戏的一部分（包含人类创作元素），整体游戏仍受保护
- 不要声称对单个 AI 语音文件拥有独立版权

### 7.4 平台存续风险

**已关停的重要平台**：

| 平台 | 关停时间 | 原因 |
|------|---------|------|
| Replica Studios | 2025 年 6 月 | 市场竞争失败 |
| PlayHT / Play.ai | 2025 年 12 月 | Meta 收购 |
| Coqui（公司） | 2024 年 1 月 | 公司关闭 |

**风险缓解**：
- **生成后立即下载所有音频文件**
- 不要依赖任何平台的云端存储
- 保留原始文本和参数记录，便于在其他平台重新生成
- 优先选择大公司（Azure、Google、OpenAI）或完全本地运行的开源方案

---

## 8. 本项目的具体建议

### 8.1 推荐方案：分层配音策略

基于项目特点（Godot 4.6 RTS，含 Necromancer、指挥官技能、时代升级），推荐以下策略：

**第一层：核心角色 -- 真人录音**
- 指挥官（如果有重要剧情）
- Necromancer（需要特殊邪恶声线）

**第二层：普通单位 -- AI 配音**
- 推荐工具：ElevenLabs Creator ($22/月)
- 英文单位：直接用 ElevenLabs 预置声音
- 中文单位（如需要）：用 Azure Dragon HD 或 MiniMax

**第三层：效果音 -- 开源 TTS**
- 死亡惨叫：Bark（可生成非语言声音）
- 召唤音效：CosyVoice 3 + 后期处理

### 8.2 配置方式

**ElevenLabs 方案配置**：
1. 注册 ElevenLabs 账号，升级到 Creator ($22/月)
2. 在 Voice Library 中为每个单位类型选定声音：
   - Necromancer: 选低沉阴森的男声
   - Soldier: 选铿锵有力的男声
   - Archer: 选干练的女声
   - Cavalry: 选豪迈的男声
   - Worker: 选平凡的中性声音
3. 记录每个 Voice ID
4. 编写台词表 CSV（unit, action, text, emotion）
5. 运行 Python 批量生成脚本
6. 在 Audacity 中后处理
7. 导入 Godot 项目

**CosyVoice 3 本地方案配置（免费）**：
1. 需要 Linux 环境（WSL2 或 Docker）+ NVIDIA GPU
2. `git clone https://github.com/FunAudioLLM/CosyVoice`
3. 按官方文档安装依赖
4. 准备目标声音的 10 秒参考音频
5. 使用 Python API 批量生成
6. Apache 2.0 许可，完全可商用

### 8.3 Godot 集成代码示例

```gdscript
# unit_audio.gd - 挂载到 Unit 节点上
extends Node
class_name UnitAudio

@export var voice_directory: String = "res://audio/voices/soldier/"

var _select_sounds: Array[AudioStream] = []
var _move_sounds: Array[AudioStream] = []
var _attack_sounds: Array[AudioStream] = []
var _death_sounds: Array[AudioStream] = []
var _select_count: int = 0

@onready var _audio_player: AudioStreamPlayer3D = $AudioStreamPlayer3D

func _ready():
    _load_sounds("select", _select_sounds)
    _load_sounds("move", _move_sounds)
    _load_sounds("attack", _attack_sounds)
    _load_sounds("death", _death_sounds)

func _load_sounds(action: String, array: Array[AudioStream]):
    var dir = DirAccess.open(voice_directory)
    if dir:
        dir.list_dir_begin()
        var file = dir.get_next()
        while file != "":
            if file.begins_with(action + "_") and file.ends_with(".ogg"):
                array.append(load(voice_directory + file))
            file = dir.get_next()

func play_select():
    if _select_sounds.is_empty():
        return
    _select_count += 1
    # 重复点击 5 次以上播放彩蛋台词
    var index = randi() % _select_sounds.size() if _select_count < 5 else 0
    _audio_player.stream = _select_sounds[index]
    _audio_player.play()

func play_move():
    _play_random(_move_sounds)

func play_attack():
    _play_random(_attack_sounds)

func play_death():
    if not _death_sounds.is_empty():
        _audio_player.stream = _death_sounds[randi() % _death_sounds.size()]
        _audio_player.play()

func _play_random(sounds: Array[AudioStream]):
    if sounds.is_empty():
        return
    _audio_player.stream = sounds[randi() % sounds.size()]
    _audio_player.play()
```

### 8.4 文件组织建议

```
res://audio/voices/
├── necromancer/
│   ├── select_01.ogg
│   ├── select_02.ogg
│   ├── select_03.ogg
│   ├── move_01.ogg
│   ├── move_02.ogg
│   ├── attack_01.ogg
│   ├── attack_02.ogg
│   ├── death.ogg
│   └── easter_egg_01.ogg    # 重复点击彩蛋
├── soldier/
│   ├── select_01.ogg
│   └── ...
├── archer/
│   └── ...
├── cavalry/
│   └── ...
└── worker/
    └── ...
```

---

## 9. 参考来源汇总

### 定价与功能

- [ElevenLabs 官方定价](https://elevenlabs.io/pricing) - 最新 2026 年套餐和 API 定价
- [ElevenLabs 定价详细分析 - affmaven](https://affmaven.com/elevenlabs-pricing) - 全方位定价评测
- [ElevenLabs 定价分析 - bigvu.tv](https://bigvu.tv/blog/elevenlabs-pricing-2026-plans-credits-commercial-rights-api-costs) - 商用权和 API 费用分析
- [ElevenLabs 评测 - qcall.ai](https://qcall.ai/elevenlabs-review) - 包含实际使用成本分析
- [ElevenLabs API 定价 - goodvibecode](https://www.goodvibecode.com/text-to-speech/elevenlabs-api-pricing-explained) - 面向开发者的 API 定价详解
- [Google Cloud TTS 定价](https://cloud.google.com/text-to-speech/pricing) - 官方定价页
- [Google Cloud TTS 定价分析 - diyai.io](https://diyai.io/ai-tools/audio-generation/google-cloud-text-to-speech-pricing) - 2026 定价详解
- [Azure TTS 定价](https://azure.microsoft.com/en-us/pricing/details/speech) - 官方定价
- [Azure TTS 发行说明](https://learn.microsoft.com/en-us/azure/ai-services/speech-service/releasenotes) - 最新功能更新
- [OpenAI TTS 定价计算器 - costgoat](https://costgoat.com/pricing/openai-tts) - 交互式成本计算
- [OpenAI API 定价 - aipricing.guru](https://www.aipricing.guru/openai-pricing) - 2026 年 8 月完整定价
- [MiniMax API 定价 - Puter](https://developer.puter.com/tutorials/minimax-api-pricing) - 2026 年 6 月定价
- [MiniMax Speech 评测 - invideo](https://invideo.io/blog/minimax-ai-voice-models) - 语音模型家族全解析
- [Resemble AI 定价 - checkthat.ai](https://checkthat.ai/brands/resemble-ai/pricing) - 2026 Flex Plan 详解
- [Murf AI 定价 - max-productive](https://max-productive.ai/ai-tools/murf-ai) - 2026 年完整评测
- [WellSaid Labs 定价](https://www.wellsaid.io/ai-voice-pricing) - 官方定价页

### 法律与授权

- [ElevenLabs 商用权法律分析 - Terms.Law](https://terms.law/ai-output-rights/elevenlabs) - 律师撰写的详细分析
- [Steam AI 政策详解 - LegalMovesLawFirm](https://legalmoveslawfirm.com/steam-ai-policy) - 游戏律师解读
- [Steam AI 披露政策更新 - remio.ai](https://www.remio.ai/post/steam-ai-disclosure-policy-updated-efficiency-tools-now-exempt) - 2026 年 1 月更新分析
- [Steam AI 披露数据 - tech-insider](https://tech-insider.org/steam-ai-disclosure-2026) - 20% 游戏披露 AI
- [AI 生成内容在游戏中的法律问题 - Clyde & Co](https://www.clydeco.com/en/insights/2025/07/ai-generated-content-in-gaming) - 法律事务所分析

### SAG-AFTRA 与行业

- [2024-2025 SAG-AFTRA 罢工 - Wikipedia](https://en.wikipedia.org/wiki/2024%E2%80%932025_SAG-AFTRA_video_game_strike) - 完整时间线
- [SAG-AFTRA 合同批准 - Variety](https://variety.com/2025/gaming/news/video-game-actors-strike-contract-ratified-sag-aftra-1236451291) - 95.04% 批准
- [罢工结束报道 - BBC](https://www.bbc.com/news/articles/c5ykx117keqo) - AI 协议达成
- [SAG-AFTRA & Replica Studios AI 协议 - GamesIndustry.biz](https://www.gamesindustry.biz/sag-aftra-and-replica-studios-pen-ai-voice-agreement) - 首份 AI 配音协议
- [SAG-AFTRA 的 AI 伦理影响 - Voices.com](https://www.voices.com/blog/sag-aftra-ai-voice) - 2024 年 12 月分析
- [游戏 AI 语音伦理演进 - Keywords Studios](https://www.keywordsstudios.com/en/about-us/news-events/news/the-ethical-evolution-of-ai-voice-in-gaming-2026) - 2026 年行业视角
- [AI 在游戏中的争议 - YouTube](https://www.youtube.com/watch?v=8eVxIHM-f3Y) - AI Slop 系列

### 开源 TTS

- [Coqui XTTS v2 - HuggingFace](https://huggingface.co/coqui/XTTS-v2) - 官方模型页
- [XTTS v2 商用指南 - LocalAIMaster](https://localaimaster.com/models/coqui-tts) - 许可证详解
- [XTTS v2 许可证分析 - PromptQuorum](https://www.promptquorum.com/power-local-llm/local-tts-voice-cloning-piper-coqui-xtts) - CPML 非商用说明
- [CosyVoice 3 论文 - arXiv](https://arxiv.org/html/2505.17589v2) - 含完整基准测试
- [CosyVoice 完整指南 - DeepWiki](https://deepwiki.directory/blog/2025-cosyvoice-complete-guide) - 安装和使用教程
- [开源 TTS 对比 - Clore.ai](https://docs.clore.ai/guides/comparisons/tts-comparison) - 5 大模型对比
- [2026 开源 TTS 综述 - Neosophie](https://neosophie.com/en/blog/20260317-tts) - Chatterbox/Fish/CosyVoice/Qwen3 对比
- [BentoML 开源 TTS 综述](https://www.bentoml.com/blog/exploring-the-world-of-open-source-text-to-speech-models) - ChatTTS/Kokoro/Fish 等
- [中文 TTS 评测 - JCHub](https://blog.jianchihu.net/voice-clone-tts-simple-research.html) - 完整中文方案对比
- [本地 TTS 模型列表 - LocalClaw](https://localclaw.io/tts-list) - 2026 最新

### 工具迁移与关停

- [Replica Studios 告别页面](https://www.replicastudios.com) - 已关停
- [PlayHT 关停迁移指南 - SpeechGeneration](https://speechgeneration.ai/compare/speechgenerationai-vs-playht) - PlayHT 已关停
- [PlayHT 替代方案 - FreeTTS](https://freetts.org/play-ht-alternative) - 7 个替代方案
- [PlayHT 迁移 - AnySpeech](https://anyspeech.io/playht-alternative) - 2026 年替代

### 游戏行业应用

- [AI 配音在独立游戏中的应用 - StraySpark](https://www.strayspark.studio/blog/ai-voice-acting-indie-games-elevenlabs-2026) - 实践指南
- [TTS API 对比 2026 - Speechmatics](https://www.speechmatics.com/company/articles-and-news/best-tts-apis-in-2025-top-12-text-to-speech-services-for-developers) - 12 大 TTS API
- [Resemble AI vs PlayHT - Aloa](https://aloa.co/ai/comparisons/ai-voice-comparison/resemble-vs-playht) - 详细对比
- [MiniMax 中文 TTS 测试 - Medium](https://medium.com/@colaflyfly/three-years-later-re-testing-the-chinese-tts-tools-with-taiwanese-accent-ea4980df4dbb) - 中文方言测试

### 游戏案例

- [AI 语音合成在游戏中的争议 - The Guardian](https://www.theguardian.com/technology/2023/may/14/ai-voice-synthesising-is-being-hailed-as-the-future-of-video-games-but-at-what-cost) - Replica Studios 早期报道
- [Replica Studios 游戏开发者功能 - GamesPress](https://www.gamespress.com/Replica-Studios-Launches-Update-that-Enables-Writers-and-Game-Designer) - Projects and Scenes 功能
- [Replica Studios Style Morphing - PRNewswire](https://www.prnewswire.com/news-releases/replica-studios-new-style-morphing-feature-gives-game-developers-access-to-over-1-000-emotions-for-ai-synthesized-voices-301817996.html) - 1000+ 情绪
- [Voice Cloning Ethics - Respeecher](https://www.respeecher.com/news/ethics-in-ai-making-voice-cloning-safe) - 伦理实践

---

> **报告结束**
>
> 本报告基于 2026 年 8 月的公开信息编写。AI 语音领域变化极快（Replica Studios 和 PlayHT 都在 2025 年关停），建议在做最终决策前重新验证工具的最新状态和定价。

# AI 音效生成工具深度调研报告 (2025-2026)

> 调研目标：评估能否用 AI 生成一套完整的 RTS 游戏音效（剑击、爆炸、魔法、UI、环境等约 100 个）
> 调研时间：2026 年 8 月
> 项目背景：Godot 4.6 RTS 游戏（帝国时代+红警混合，奇幻+现代）

---

## 目录

1. [ElevenLabs Sound Effects](#1-elevenlabs-sound-effects)
2. [Stable Audio (Stability AI)](#2-stable-audio-stability-ai)
3. [Suno (Suno Sounds)](#3-suno-suno-sounds)
4. [UDIO](#4-udio)
5. [Replica Studios -- 已关闭](#5-replica-studios--已关闭)
6. [Meta AudioCraft (AudioGen)](#6-meta-audiocraft-audiogen)
7. [AudioLDM 2](#7-audioldm-2)
8. [Suno Bark](#8-suno-bark)
9. [Hume AI / PlayHT](#9-hume-ai--playht)
10. [Adobe Firefly SFX / Project Sound Lift](#10-adobe-firefly-sfx--project-sound-lift)
11. [MyEdit (CyberLink)](#11-myedit-cyberlink)
12. [Canva AI Sound Effects](#12-canva-ai-sound-effects)
13. [SFX Engine](#13-sfx-engine)
14. [Flixly AI](#14-flixly-ai)
15. [场景化推荐](#场景化推荐)
16. [成本对比表](#成本对比表100-个-rts-音效)
17. [风险提示](#风险提示)
18. [批量生成工作流建议](#批量生成工作流建议)

---

## 1. ElevenLabs Sound Effects

**官网**: <https://elevenlabs.io/sound-effects>

### 能做什么
- 文字生成音效（text-to-SFX）
- 环境音、拟音、UI 音效、战斗音效
- v2 模型支持最长 30 秒片段，支持无缝循环
- 同时支持 TTS（语音）、音乐生成

### 输入方式
- 文字描述（prompt）
- 可指定时长（让 AI 决定或手动设定）
- 每次生成产出 4 个候选音效

### 技术规格
- **采样率**: 48 kHz（v2 模型）
- **声道**: 官方未明确标注，实测以单声道为主
- **时长上限**: 30 秒（v2）
- **生成速度**: 数秒到十几秒
- **已知问题**: 部分用户报告背景有 artifacts（噪声/伪影），需要后期处理

来源: [The Decoder - ElevenLabs v2](https://the-decoder.com/elevenlabs-releases-version-2-of-its-ai-sound-effects-model-with-longer-clips-and-better-audio-quality/), [Reddit artifacts 讨论](https://www.reddit.com/r/ElevenLabs/comments/1mle7bz/audio_artefacts_in_the_background/)

### 授权/版权
- **免费层**: 无商用授权
- **付费层（Starter $5/月起）**: 包含商用授权，生成内容免版税
- 生成内容归用户使用，ElevenLabs 不主张所有权
- 已集成 SynthID 水印标识 AI 生成内容

来源: [ElevenLabs Pricing](https://elevenlabs.io/pricing), [ElevenLabs SynthID](https://elevenlabs.io/blog/synthid)

### 价格

**Web 平台（Creative Studio）**:
| 计划 | 月费 | 额度 | 商用 |
|------|------|------|------|
| Free | $0 | 10,000 字符/月 | 否 |
| Starter | $5 | 30,000 字符 | 是 |
| Creator | $22 | 100,000 字符 | 是 |
| Pro | $99 | 500,000 字符 | 是 |
| Scale | $330 | 3,000,000 字符 | 是 |

**API（程序化生成）**:
- 音效按次计费，每次生成 = 100 credits
- API 定价: **$0.12/分钟**
- 超量: $0.12/分钟 -> Scale 层 $0.096/分钟
- Pay-as-you-go (PAYG) 已推出，适合不固定的使用量

来源: [ElevenLabs API Pricing](https://elevenlabs.io/pricing/api), [FlexPrice](https://flexprice.io/blog/elevenlabs-pricing-breakdown), [BIGVU 2026 Pricing](https://bigvu.tv/blog/elevenlabs-pricing-2026-plans-credits-commercial-rights-api-costs/)

### API 可用性
- 有 REST API，支持程序化批量生成
- 文档: <https://elevenlabs.io/docs/eleven-creative/playground/sound-effects>
- 有 Unity 编辑器插件集成

### 适用场景
- **战斗音效（剑击/爆炸/魔法）**: 最强项，逼真度高
- **UI 音效**: 优秀
- **环境音**: 优秀
- **音乐**: 一般（不是主要定位）

### 实际案例
- Reddit 独立开发者证实: "ElevenLabs can generate a good amount of various effects, some of them are as good as naturally recorded." -- [来源](https://www.reddit.com/r/artificial/comments/1f81gxg/utilizing_ai_in_solo_game_development_my/)
- YouTube: "AI Created All the SFX, Voices & Music for My Game" -- [来源](https://www.youtube.com/watch?v=sI3FccyNF5k)

---

## 2. Stable Audio (Stability AI)

**官网**: <https://stableaudio.com/>

### 能做什么
- 文字生成音乐、音效、声景（soundscape）
- 最新 Stable Audio 3.0（约 2026 年 5 月发布）包含四个模型:
  - Small + Small SFX（移动/设备端优化，含专用 SFX 变体）
  - Medium（更高质量）
- 声音转音频变换（vocal-to-audio）

### 输入方式
- 文字描述
- 参考音频变换

### 技术规格
- **时长上限**: 免费版 45 秒；付费版 90 秒
- **生成速度**: 数秒
- **采样率**: 未明确公布，推测 44.1 kHz / 48 kHz
- **开源版本**: Stable Audio 3 在 GitHub 上 MIT 许可

### 授权/版权 -- 双轨制

**1. Web 平台 (stableaudio.com)**:
| 计划 | 月费 | 生成量 | 商用 |
|------|------|--------|------|
| Free | $0 | 20 次 x 45 秒/月 | 否 |
| Pro | $11.99 | 500 次 x 90 秒 | 是 |
| Max | 更高层级 | 2,500 次/月 | 是 |
| Enterprise | 定制 | 灵活部署 | 是 |

**2. 开源权重模型**:
- **Stable Audio Open 1.0**: Stability AI Community License，年收入 < $1M 可免费商用
- **Stable Audio 3 (GitHub)**: **MIT 许可**，几乎无限制
- GitHub: <https://github.com/Stability-AI/stable-audio-3>
- HuggingFace: <https://huggingface.co/stabilityai/stable-audio-open-1.0>

来源: [Stable Audio Pricing](https://stableaudio.com/pricing), [Stability AI License](https://stability.ai/license), [Stable Audio 3 GitHub](https://github.com/Stability-AI/stable-audio-3/blob/main/LICENSE)

### API 可用性
- Web 平台提供生成界面
- 开源模型可本地部署或通过 HuggingFace Diffusers 调用
- 可编写 Python 脚本批量生成

### 适用场景
- **音效**: 良好（Small SFX 专门优化）
- **环境音/声景**: 优秀
- **音乐**: 优秀
- **UI 音效**: 一般

### 本地部署成本
- 需要 GPU: 推荐 8GB+ VRAM
- Stable Audio Small 可在移动设备运行

---

## 3. Suno (Suno Sounds)

**官网**: <https://suno.com/>

### 能做什么
- **主要定位**: AI 音乐生成（含人声歌曲）
- **Suno Sounds**（实验功能）: 生成独立音效、乐器采样、环境噪音
- 在歌曲中可用 `*thunder rumbling*` 等标签内嵌音效

### 输入方式
- 文字描述
- Suno Studio 的 Create 标签页可切换到 Sounds 模式

来源: [Suno Sounds 官方文档](https://help.suno.com/en/articles/10625537), [Suno Sounds 指南](https://jackrighteous.com/en-us/blogs/guides-using-suno-ai-music-creation/suno-sounds-ai-sound-effects-guide)

### 技术规格
- 音效功能仍在实验阶段
- 时长和采样率未公开详细规格

### 授权/版权
| 计划 | 月费 | 额度 | 商用 |
|------|------|------|------|
| Free | $0 | 50 credits/天（约 10 首/天） | 否 |
| Pro | $10（年付 $8） | 2,500 credits/月 | 是 |
| Premier | $30（年付 $24） | 10,000 credits/月 | 是 |

来源: [Suno Pricing](https://suno.com/pricing)

### API 可用性
- Suno 目前**无公开的 SFX API**
- 主要通过 Web 界面操作

### 适用场景
- **音乐**: 极强（最强 AI 音乐工具之一）
- **音效**: 实验阶段，不如 ElevenLabs 专业
- **环境音**: 可以但不是强项

### 注意
- Suno 的核心优势是音乐/歌曲生成
- Sounds 功能是附加的，音效质量和可控性不如专业 SFX 工具
- 社区评价: "Suno AI is amazing for general music, but it's not built for games"

来源: [Reddit r/gamedev](https://www.reddit.com/r/gamedev/comments/1lxwe4w/thinking_about_building_an_ai_for_game_audio/)

---

## 4. UDIO

**官网**: <https://www.udio.com/>

### 能做什么
- AI 音乐生成（与 Suno 竞争）
- **不提供独立的音效生成功能**
- 2026 年状态: 因训练数据诉讼和解，**已禁用已生成曲目的下载**

### 输入方式
- 文字描述（仅音乐）

### 授权/版权
| 计划 | 月费 | 额度 | 商用 |
|------|------|------|------|
| Free | $0 | 10 credits/天 | 否 |
| Standard | $10 | 更多 credits | 付费层可用 |

### 重要警告
- **下载功能已禁用**（诉讼和解结果）
- **训练数据版权争议严重** -- 这是最重大的风险
- 不推荐用于游戏音效项目

来源: [Udio 2026 条款分析](https://musicmake.ai/blog/udio-terms-of-service-commercial-use-2026), [Reddit - Udio vs Suno](https://www.reddit.com/r/SunoAI/comments/1olqy3o/udio_vs_suno_implications_license_distributions/), [AI 音乐版权指南](https://pract.is/blog/ai-music-2026-suno-udio-copyright-licensing-guide)

### 适用场景
- **不推荐用于 RTS 游戏音效**
- 版权风险过高，功能不匹配

---

## 5. Replica Studios -- 已关闭

> **重要**: Replica Studios 已正式关闭运营。网站显示告别信息。
>
> "Replica Studios has officially signed off."

- 与 SAG-AFTRA 的 AI 语音协议已于 **2025 年 9 月 24 日** 终止
- 曾与 Google Cloud 合作 "Living Games" 项目（用 Gemini Pro 动态生成游戏语音）
- **不再可用**，本项目排除

来源: [Replica Studios 官网](https://www.replicastudios.com/), [SAG-AFTRA 协议终止](https://www.sagaftra.org/sag-aftra-and-replica-studios-introduce-groundbreaking-ai-voice-agreement-ces)

---

## 6. Meta AudioCraft (AudioGen)

**官网**: <https://ai.meta.com/resources/models-and-libraries/audiocraft/>
**GitHub**: <https://github.com/facebookresearch/audiocraft>

### 能做什么
- **AudioGen**: 文字生成音效（environmental sounds, sound effects）
- **MusicGen**: 文字生成音乐
- **EnCodec**: 音频压缩
- 单一代码库，覆盖音乐、音效、压缩

### 输入方式
- 文字描述
- AudioGen 专门用于音效生成，在公开音效数据上训练

### 技术规格
- 采样率: 16 kHz（AudioGen）/ 32 kHz（MusicGen）
- 时长: 可配置，通常 5-30 秒
- 单声道

### 授权/版权 -- 双重许可（重要!）

| 组件 | 许可证 | 商用? |
|------|--------|-------|
| **代码（GitHub 仓库）** | MIT | 是 |
| **模型权重（MusicGen, AudioGen）** | **CC-BY-NC 4.0** | **否** |

- **模型权重是非商业许可**，不能直接用于商业游戏
- 商用需要与 Meta 单独协商许可，或用自己的数据从头训练
- 社区评价: CC-BY-NC "effectively a nonlicense" for commercial purposes

来源: [AudioCraft GitHub](https://github.com/facebookresearch/audiocraft), [InfoQ](https://www.infoq.com/news/2023/08/meta-text-to-music-generative-ai/), [Ars Technica](https://arstechnica.com/information-technology/2023/08/open-source-audiocraft-can-make-dogs-bark-and-symphonies-soar-from-text-using-ai/)

### 本地部署
- GPU 需求: 8GB+ VRAM（AudioGen），16GB+（MusicGen Medium/Large）
- Python 环境，HuggingFace 集成
- 可通过 Diffusers 库调用

### 适用场景
- **研究和原型**: 免费，适合试验
- **商业项目**: 不适合（除非获得商业许可）
- **音效质量**: 一般，采样率较低（16 kHz）

---

## 7. AudioLDM 2

**项目页**: <https://audioldm.github.io/audioldm2/>
**GitHub**: <https://github.com/haoheliu/AudioLDM>
**HuggingFace**: <https://huggingface.co/docs/diffusers/en/api/pipelines/audioldm2>

### 能做什么
- 文字生成音效、语音、音乐
- 基于潜在扩散模型（latent diffusion model）
- 支持声音模仿（vocal imitation -> sound effect）

### 输入方式
- 文字描述
- 声音模仿输入（哼唱 -> 对应音效）

### 技术规格
- 采样率: 16 kHz / 48 kHz（取决于模型变体）
- 时长: 默认 ~10 秒，可配置
- 单声道

### 授权/版权
- **代码**: MIT 许可
- **模型权重**: 需要确认具体许可证（HuggingFace 模型卡）
- 可用于研究和个人项目

来源: [AudioLDM GitHub](https://github.com/haoheliu/AudioLDM), [HuggingFace Blog](https://huggingface.co/blog/audioldm2), [HuggingFace Diffusers](https://huggingface.co/docs/diffusers/en/api/pipelines/audioldm2)

### 本地部署 GPU 需求
| 配置 | VRAM | 备注 |
|------|------|------|
| 官方推荐 | **8 GB** | 基本运行 |
| 实测最低 (RTX 3060) | ~5 GB | 降低参数可运行 |
| 舒适/批量 | **12 GB+** | 推荐配置 |

来源: [AudioLDM GitHub](https://github.com/haoheliu/AudioLDM), [Python Plain English 实测](https://python.plainenglish.io/introduction-to-audioldm2-5d42f50601ed)

### API 可用性
- 无官方 API 服务
- 通过 HuggingFace Diffusers 库本地调用
- 可编写 Python 脚本批量生成

### 适用场景
- **音效**: 良好（设计目标就是 SFX + 语音 + 音乐）
- **研究用途**: 非常适合
- **商业游戏**: 需要确认模型权重许可

### OpenVINO 加速
- 可以通过 OpenVINO 在 Intel 硬件上加速推理
- 文档: <https://docs.openvino.ai/2023.3/notebooks/270-sound-generation-audioldm2-with-output.html>

---

## 8. Suno Bark

**GitHub**: <https://github.com/suno-ai/bark>
**HuggingFace**: <https://huggingface.co/suno/bark>

### 能做什么
- 文字生成多语言语音（主要功能）
- 附带能力: 音乐、背景噪音、简单音效、非语言声音（笑声、叹息等）
- **不是专门的音效生成器**，而是 TTS 模型附带了音效能力

### 输入方式
- 文字描述
- 可在文本中嵌入音效标签，如 `[clears throat]`, `[laughter]`, `[music]`

### 技术规格
- 基于 Transformer 架构
- 可生成较长音频片段（13 秒，可扩展）

### 授权/版权
- **MIT 许可**（代码和模型权重）
- **可商用**

来源: [Bark GitHub](https://github.com/suno-ai/bark), [Bark HuggingFace](https://huggingface.co/suno/bark), [本地部署指南](https://localaimaster.com/blog/bark-tts-local-setup)

### 本地部署
- GPU 需求: 8GB+ VRAM 推荐
- 支持 Windows / Mac / Linux
- 已集成到 HuggingFace Transformers 库

### 适用场景
- **语音/TTS**: 极强（主要用途）
- **简单音效**: 可用（笑声、掌声等非语言声音）
- **复杂游戏音效（剑击/爆炸）**: **不适合**
- **魔法吟唱声**: 有潜力

---

## 9. Hume AI / PlayHT

### Hume AI
**官网**: <https://www.hume.ai/>

- **主要定位**: 情感语音 AI、对话式 AI 表达测量
- **不提供独立的音效生成功能**
- 擅长带有情感的 AI 语音合成
- 有与 ElevenLabs 的对比评测，但比较的是语音质量而非音效

来源: [Hume AI 官网](https://www.hume.ai/), [Hume AI 博客](https://www.hume.ai/blog/the-8-best-ai-voice-generators-in-2025)

**结论**: 不适用于 RTS 游戏音效项目。

### PlayHT
**官网**: <https://play.ht/>

- **主要定位**: AI 语音合成（TTS）、语音克隆
- 可用于游戏 NPC 配音
- **不提供专门的音效生成功能**
- 有 API 可用

**结论**: 适用于游戏配音，不适用于音效生成。

---

## 10. Adobe Firefly SFX / Project Sound Lift

### Adobe Firefly SFX
**官网**: <https://www.adobe.com/products/firefly/features/sound-effect-generator.html>

- 2025 Adobe MAX 展示了 Firefly 的音效生成能力
- 文字描述 -> 生成音效
- 面向视频/播客创作者
- 免费使用（Firefly 框架内）

### Project Sound Lift
- **不是音效生成工具**，而是音频分离/清理工具
- AI 分离语音和背景噪音
- 可以从嘈杂录音中提取干净音效
- 2026 年社区仍在请求更多功能（如说话人分离）

来源: [Adobe Blog - Sound Lift](https://blog.adobe.com/en/publish/2023/11/15/adobe-previews-new-ai-powered-audio-tool-revolutionize-voice-processing-video-creation), [Adobe Firefly SFX](https://www.adobe.com/products/firefly/features/sound-effect-generator.html)

### 适用场景
- Firefly SFX: 可作为辅助工具，但游戏音效不是其强项
- Sound Lift: 适合清理自己录制的音效素材
- Adobe 生态绑定，导出独立音频文件用于游戏需注意许可条款

---

## 11. MyEdit (CyberLink)

**官网**: <https://myedit.online/en/audio-editor/ai-sound-effect-generator>

### 能做什么
- 文字生成音效（fart sounds, screams, bells 等）
- 浏览器端运行，无需安装
- 生成免版税音效

### 输入方式
- 文字描述

### 技术规格
- 2026 年仍在活跃运营（页面标注 (c) 2026 CyberLink Corp.）
- 具体采样率/声道未公开

### 授权/版权
- 生成内容声称免版税
- 属于 CyberLink 的在线创作套件

来源: [MyEdit SFX Generator](https://myedit.online/en/audio-editor/ai-sound-effect-generator), [MyEdit 主页](https://myedit.online/en), [台湾精品奖](https://www.taiwanexcellence.org/en/award/product/1140024)

### 价格
- 免费增值模式（Freemium）
- 具体定价未在搜索结果中明确

### 适用场景
- 快速简单音效
- 不适合需要高一致性的批量音效集
- 下载后需手动同步到游戏项目

---

## 12. Canva AI Sound Effects

**官网**: <https://www.canva.com/features/ai-sound-effect-generator/>

### 能做什么
- 文字生成音效
- 集成在 Canva 设计平台中
- 自然音景、城市噪音、人声等各类声音

### 输入方式
- 文字描述

### 授权/版权
- 免费层可用基础功能
- Canva Pro（~$15/月）解锁更多 credits 和功能
- 商用权利一般对 Canva Pro 用户开放
- 但许可面向设计/嵌入使用，独立游戏资源使用需审查条款

来源: [Canva SFX](https://www.canva.com/features/ai-sound-effect-generator/), [Canva Help](https://www.canva.com/help/generate-ai-music-sound-effects-and-voiceovers/)

### 适用场景
- 社交媒体内容设计
- 不太适合独立游戏音效开发（平台定位不匹配）

---

## 13. SFX Engine

**官网**: <https://sfxengine.com/>

### 能做什么
- AI 驱动的音效生成器
- 面向视频、游戏、播客、音乐制作
- 无需经验即可使用

### 授权/版权
- 声称可生成无限独特音效
- 具体许可条款需查看官网

### 适用场景
- 游戏音效的专门工具之一
- 质量和一致性待实际验证

来源: [SFX Engine](https://sfxengine.com/)

---

## 14. Flixly AI

**官网**: <https://www.flixly.ai/>

### 能做什么
- AI 游戏音效生成
- **Unity 集成**（直接在引擎中使用）
- 2026 年定位的游戏向 AI 音频工具

### 适用场景
- 游戏开发专用，Unity 集成
- 对于 Godot 项目，需要导出音频文件后手动导入
- 较新平台，成熟度和质量需要评估

来源: [Flixly Blog](https://www.flixly.ai/blog/ai-sound-design-for-games-2026)

---

## 场景化推荐

### RTS 游戏音效分类推荐

| 音效类型 | 首选工具 | 备选工具 | 理由 |
|----------|----------|----------|------|
| **剑击/近战** | ElevenLabs SFX | Stable Audio Pro | ElevenLabs v2 在金属碰撞、打击感方面表现最好 |
| **爆炸** | ElevenLabs SFX | Stable Audio Pro | 爆炸声的低频和动态范围 ElevenLabs 表现优 |
| **魔法/特效** | ElevenLabs SFX | Stable Audio (开源) | 魔法声需要创意描述，ElevenLabs 理解力最强 |
| **弓箭/远程** | ElevenLabs SFX | AudioLDM 2 (本地) | 弓弦声、飞行声等细节音 ElevenLabs 更清晰 |
| **UI 点击/确认** | ElevenLabs SFX | MyEdit | UI 声通常简短清晰，多数工具可胜任 |
| **建筑/建造** | Stable Audio | ElevenLabs SFX | 环境声和机械声 Stable Audio 表现好 |
| **环境音/背景** | Stable Audio Pro | ElevenLabs SFX | Stable Audio 在声景方面有优势 |
| **背景音乐** | Suno Pro | Stable Audio Pro | Suno 是最强的 AI 音乐工具 |
| **Necromancer 召唤** | ElevenLabs SFX | Bark (吟唱部分) | 需要诡异/超自然音效 + 可能的语音吟唱 |
| **单位语音/指挥官** | Hume AI / PlayHT | ElevenLabs TTS | 语音合成需要专门的 TTS 工具 |
| **脚步声** | ElevenLabs SFX | AudioLDM 2 | 拟音类音效 ElevenLabs 表现好 |

### 综合推荐排名（针对 RTS 游戏音效）

1. **ElevenLabs Sound Effects** -- 音效质量最高，API 支持批量生成，商用授权清晰
2. **Stable Audio Pro** -- 环境声/音乐补充，开源版本可本地部署
3. **Suno Pro** -- 背景音乐最佳选择
4. **AudioLDM 2** -- 免费本地部署备选（需确认商用许可）
5. **Suno Bark** -- 魔法吟唱等非语言声音可尝试

---

## 成本对比表：100 个 RTS 音效

### 方案 A: ElevenLabs Web 平台（推荐）

| 项目 | 数量 | 单价 | 小计 |
|------|------|------|------|
| Creator 月费 | 1 月 | $22 | $22 |
| 音效生成 | ~150 次（含迭代） | 包含在月费中 | $0 |
| 后期处理时间 | -- | -- | -- |
| **总计** | | | **~$22** |

注意: Creator 层的 credits 主要用于 TTS，音效生成的 credits 消耗需要实测确认。如果 credits 不够，升级到 Pro ($99/月)。

### 方案 B: ElevenLabs API（程序化批量）

| 项目 | 数量 | 单价 | 小计 |
|------|------|------|------|
| API 调用（PAYG） | 150 次 | ~$0.12/分钟 | ~$18-30 |
| 每次生成 4 个候选 | | | |
| 实际有效音效 | ~100 个 | | |
| **总计** | | | **~$18-30** |

### 方案 C: Stable Audio Pro（Web 平台）

| 项目 | 数量 | 单价 | 小计 |
|------|------|------|------|
| Pro 月费 | 1 月 | $11.99 | $11.99 |
| 生成量 | 500 次 x 90 秒 | 包含 | $0 |
| **总计** | | | **~$12** |

### 方案 D: Stable Audio 3 开源（本地部署）

| 项目 | 成本 |
|------|------|
| 软件 | 免费 (MIT) |
| GPU（已有 RTX 3060+） | $0 |
| 电费 | 可忽略 |
| **总计** | **$0**（但需技术能力） |

### 方案 E: 混合方案（推荐最佳实践）

| 工具 | 用途 | 月费 | 音效数量 |
|------|------|------|----------|
| ElevenLabs SFX | 战斗/UI/核心音效 | $22 (Creator) | ~60 个 |
| Stable Audio Pro | 环境/建筑音效 | $12 | ~25 个 |
| Suno Pro | 背景音乐 | $10 | 3-5 首背景音乐 |
| **总计** | | **~$44/月** | **~85 音效 + BGM** |

### 方案 F: 零成本开源方案

| 工具 | 用途 | 成本 | 限制 |
|------|------|------|------|
| Stable Audio 3 (MIT) | 音效 | $0 | 需本地 GPU，质量略低 |
| AudioLDM 2 | 音效 | $0 | 确认商用许可 |
| Suno Bark (MIT) | 语音/吟唱 | $0 | 非专门音效工具 |
| **总计** | | **$0** | 质量和一致性风险较高 |

---

## 风险提示

### 1. 版权风险

| 风险等级 | 工具 | 说明 |
|----------|------|------|
| 低 | ElevenLabs (付费) | 明确商用授权，royalty-free |
| 低 | Stable Audio Pro/Max | 明确商用授权 |
| 低 | Stable Audio 3 (MIT) | MIT 许可几乎无限制 |
| 低 | Suno Bark (MIT) | MIT 许可可商用 |
| 中 | AudioLDM 2 | 需确认模型权重具体许可 |
| **高** | Meta AudioCraft | CC-BY-NC 4.0，**禁止商用** |
| **高** | UDIO | 训练数据诉讼，下载已禁用 |
| **高** | Suno/UDIO 免费层 | 明确禁止商用 |

### 2. 风格一致性风险

- **音色漂移**: AI 每次生成的音色可能不一致，同类音效（如多次剑击）音色/混响差异大
- **缓解策略**:
  - 使用固定、详细的 prompt 模板
  - 对同类音效使用相同 prompt + 微调参数
  - 在 DAW（如 Audacity/Godot 内置编辑器）中进行统一 EQ/混响处理
  - 一次批量生成同类型音效，选择最一致的几个

### 3. 质量风险

- **背景 artifacts**: ElevenLabs 部分生成有背景噪声（Reddit 多人报告）
- **采样率**: AudioCraft/AudioLDM 2 默认 16 kHz，不够游戏级标准
- **音量不一致**: 不同生成结果音量差异大，需要归一化
- **建议后处理**:
  - 使用 Audacity（免费）进行归一化、降噪
  - 统一采样率到 44.1 kHz 或 48 kHz
  - 统一音量到 -3 dB 到 -6 dB
  - 可以用 Soothe2 等插件清理 artifacts

### 4. 可用性风险

| 工具 | 状态 | 风险 |
|------|------|------|
| ElevenLabs | 活跃，融资充足 | 低 |
| Stable Audio | 活跃，Stability AI 运营 | 中（Stability AI 曾有经营波动） |
| Suno | 活跃 | 中（诉讼风险） |
| UDIO | 活跃但功能受限 | **高**（下载已禁用） |
| Replica Studios | **已关闭** | 不可用 |
| AudioCraft | Meta 维护，研究项目 | 低（代码不会消失） |

### 5. 训练数据合法性

- **ElevenLabs**: 使用 SynthID 水印，声称训练数据合法
- **Suno/UDIO**: 均面临音乐公司训练数据版权诉讼
- **Stable Audio Open**: 训练数据来自公开许可的音频
- **AudioCraft (Meta)**: AudioGen 在公开音效数据上训练

---

## 批量生成工作流建议

### 推荐工作流（基于 ElevenLabs + Stable Audio）

```
1. 准备阶段
   |- 列出所有需要的音效清单（约 100 个）
   |- 按类型分组（战斗/UI/环境/建筑）
   |- 为每组编写 prompt 模板

2. 批量生成
   |- 方式 A: ElevenLabs Web 界面手动生成
   |   - 每次输入 prompt，获得 4 个候选
   |   - 选择最佳 1-2 个
   |- 方式 B: ElevenLabs API 脚本批量生成
   |   - Python 脚本读取 prompt 清单
   |   - 自动调用 API，保存音频文件
   |   - 按类型分文件夹存储

3. 后处理（Audacity 或 Godot）
   |- 降噪（如果需要）
   |- 归一化音量（-3 dB target）
   |- 统一采样率（48 kHz）
   |- 裁剪头尾静音
   |- 添加淡入淡出（如果用于循环）

4. 导入 Godot
   |- .import 配置
   |- 按类型组织 AudioStreamPlayer 节点
   |- 测试实际游戏中的表现
   |- 微调 prompt 重新生成不满意的部分
```

### Prompt 模板示例

```
# 战斗音效
"Sharp metal sword clash, steel against steel, bright ringing resonance, close-up recording, no background noise"
"Heavy explosion, deep bass impact, debris scattering, cinematic, resonant decay"

# UI 音效
"Soft digital UI click, clean, short, modern interface sound, subtle"
"Magical spell confirmation chime, ethereal, ascending notes, fantasy game UI"

# 魔法音效
"Dark necromantic energy surge, whispering spirits, bone rattling, supernatural, eerie"
"Fireball cast, whoosh ignition, crackling flames, magical combustion"

# 环境
"Medieval battlefield ambient, distant clashing, occasional shouting, wind, atmospheric"
```

---

## 工具速查总结表

| 工具 | 类型 | 专长 | 商用 | API | 价格 | 推荐? |
|------|------|------|------|-----|------|-------|
| ElevenLabs SFX | 云服务 | 音效 | 付费可 | 有 | $5-99/月 | **强烈推荐** |
| Stable Audio Pro | 云服务 | 音乐+音效 | 付费可 | 否 | $12/月 | **推荐** |
| Stable Audio 3 | 开源 | 音效 | 可(MIT) | 本地 | 免费 | 推荐(技术向) |
| Suno Pro | 云服务 | 音乐 | 付费可 | 否 | $10/月 | 推荐(BGM) |
| UDIO | 云服务 | 音乐 | 受限 | 否 | $10/月 | 不推荐 |
| Replica Studios | -- | -- | -- | -- | -- | **已关闭** |
| AudioCraft | 开源 | 音效 | **不可** | 本地 | 免费 | 研究用 |
| AudioLDM 2 | 开源 | 音效 | 需确认 | 本地 | 免费 | 备选 |
| Suno Bark | 开源 | 语音+简单音效 | 可(MIT) | 本地 | 免费 | 辅助 |
| Hume AI | 云服务 | 语音 | 付费可 | 有 | 未公开 | 不适用 |
| PlayHT | 云服务 | 语音 | 付费可 | 有 | 未公开 | 配音用 |
| Adobe Firefly | 云服务 | 音效 | 需确认 | 否 | 免费 | 辅助 |
| MyEdit | 云服务 | 音效 | 声称可 | 否 | 免费/付费 | 辅助 |
| Canva | 云服务 | 音效 | Pro可 | 否 | 免费/$15 | 不推荐 |
| SFX Engine | 云服务 | 音效 | 声称可 | 否 | 免费 | 待验证 |
| Flixly | 云服务 | 游戏音效 | 需确认 | Unity | 未公开 | 待验证 |

---

## 参考来源汇总

### 工具官方页面
- [ElevenLabs Sound Effects](https://elevenlabs.io/sound-effects)
- [ElevenLabs Pricing](https://elevenlabs.io/pricing)
- [ElevenLabs API Pricing](https://elevenlabs.io/pricing/api)
- [Stable Audio](https://stableaudio.com/)
- [Stable Audio Pricing](https://stableaudio.com/pricing)
- [Stability AI License](https://stability.ai/license)
- [Stable Audio 3 GitHub (MIT)](https://github.com/Stability-AI/stable-audio-3/blob/main/LICENSE)
- [Suno Pricing](https://suno.com/pricing)
- [Suno Sounds 文档](https://help.suno.com/en/articles/10625537)
- [AudioCraft - Meta AI](https://ai.meta.com/resources/models-and-libraries/audiocraft/)
- [AudioCraft GitHub](https://github.com/facebookresearch/audiocraft)
- [AudioLDM GitHub](https://github.com/haoheliu/AudioLDM)
- [AudioLDM 2 HuggingFace](https://huggingface.co/blog/audioldm2)
- [AudioLDM 2 Diffusers Docs](https://huggingface.co/docs/diffusers/en/api/pipelines/audioldm2)
- [Suno Bark GitHub](https://github.com/suno-ai/bark)
- [Suno Bark HuggingFace](https://huggingface.co/suno/bark)
- [Hume AI](https://www.hume.ai/)
- [Adobe Firefly SFX](https://www.adobe.com/products/firefly/features/sound-effect-generator.html)
- [MyEdit SFX](https://myedit.online/en/audio-editor/ai-sound-effect-generator)
- [Canva SFX](https://www.canva.com/features/ai-sound-effect-generator/)
- [SFX Engine](https://sfxengine.com/)
- [Flixly AI](https://www.flixly.ai/blog/ai-sound-design-for-games-2026)

### 评测与对比文章
- [Envato - Best AI SFX Generators 2026](https://elements.envato.com/learn/best-ai-sound-effect-generators)
- [getimg.ai - 6 Tools Compared](https://getimg.ai/blog/best-ai-sound-effect-generator)
- [Curious Refuge - Best AI SFX for 2026](https://curiousrefuge.com/blog/best-ai-sound-effects-generator-for-2026)
- [PixVerse - 9 Tools Compared](https://pixverse.ai/en/blog/best-ai-sound-effect-generator)
- [Summer Engine - AI SFX for Games](https://www.summerengine.com/blog/ai-sound-effect-generator-for-games)
- [Undetectr - 7 SFX Tools](https://undetectr.com/blog/ai-sound-effect-generator)
- [BIGVU - ElevenLabs Pricing 2026](https://bigvu.tv/blog/elevenlabs-pricing-2026-plans-credits-commercial-rights-api-costs/)
- [FlexPrice - ElevenLabs Breakdown](https://flexprice.io/blog/elevenlabs-pricing-breakdown)
- [The Decoder - ElevenLabs v2](https://the-decoder.com/elevenlabs-releases-version-2-of-its-ai-sound-effects-model-with-longer-clips-and-better-audio-quality/)

### 社区讨论与案例
- [Reddit r/gamedev - AI for game audio](https://www.reddit.com/r/gamedev/comments/1lxwe4w/thinking_about_building_an_ai_for_game_audio/)
- [Reddit r/artificial - Solo dev AI experience](https://www.reddit.com/r/artificial/comments/1f81gxg/utilizing_ai_in_solo_game_development_my/)
- [Reddit r/gamedev - Generative AI SFX in Indie Games](https://www.reddit.com/r/gamedev/comments/1tcw0xa/generative_ai_use_for_sound_effects_in_indie_games/)
- [YouTube - AI Created All SFX for Game](https://www.youtube.com/watch?v=sI3FccyNF5k)
- [YouTube - ElevenLabs SFX 2 Demo](https://www.youtube.com/watch?v=ZFrZ8Rc3CV4)
- [HuggingFace - Sound Generation Course](https://huggingface.co/learn/ml-games-course/en/unit2/sound-generation)

### 版权与法律
- [Udio 2026 Terms Analysis](https://musicmake.ai/blog/udio-terms-of-service-commercial-use-2026)
- [AI Music Copyright Guide 2026](https://pract.is/blog/ai-music-2026-suno-udio-copyright-licensing-guide)
- [InfoQ - AudioCraft License Analysis](https://www.infoq.com/news/2023/08/meta-text-to-music-generative-ai/)
- [Replica Studios 关闭](https://www.replicastudios.com/)
- [SAG-AFTRA 协议终止](https://www.sagaftra.org/sag-aftra-and-replica-studios-introduce-groundbreaking-ai-voice-agreement-ces)

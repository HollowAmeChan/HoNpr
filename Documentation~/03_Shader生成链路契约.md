# HoNpr Shader 生成链路契约

本文定义从 HoRP 契约到最终 shader 的分层职责。

HoNpr 的主线不是“写一个更复杂的 shader”，而是把材质能力、语义、依赖、UI、导出和最终 shader 生成拆成可声明、可解析、可审查的链路。

```text
HoRP Contract
  -> Material Semantic / Capability Model
  -> Include Registry
  -> Feature Block Declaration
  -> Template Declaration
  -> Preset Declaration
  -> ShaderLibrary Implementation
  -> Assembly / Stable Entry Layer
  -> Generator
  -> Semantic Export Resolve
  -> Generated Shader
  -> Material UI
```

## 1. HoRP Contract

HoNpr 消费 HoRP，不 fork HoRP。

HoNpr 可以引用：

- HoRP pass 名。
- HoRP resource / semantic。
- HoRP material surface ABI。
- HoRP AOV ABI。
- HoRP OIT ABI。
- HoRP object semantic ABI。

HoNpr 不可以：

- 新增 HoRP resource 名并假装已经由 RP 注册。
- 私自定义 RenderGraph 生命周期。
- 把旧 `_lilHoAov*`、`_HoAov*`、`HoAOV` 当长期 ABI。
- 让材质 shader 通过全局纹理副作用创建跨 pass 数据链路。

所有上游引用必须能在 `ShaderSystem/Contract/HORP_CONTRACT_INDEX.md` 找到索引。

## 2. Include Registry

`ShaderSystem/Includes/INCLUDE_REGISTRY.honprinclude` 负责把 include 路径注册为稳定别名。

允许：

```text
include HoNpr.ToonLobes = "Packages/com.hollow.honpr/Shaders/ShaderLibrary/StylizedSurface/HoNprToonLobes.hlsl";
```

禁止让 block 直接散落裸 include 路径。include 顺序由 generator 或 assembly 统一处理。

## 3. Feature Block

`*.honprblock` 是功能块声明，不是 HLSL 主体。

必须声明：

- `Block ID`
- domain / category / stage
- 输入 semantic、texture、property、resource
- 输出 surface field、lobe、semantic、resource
- required include alias
- capability token
- producer / consumer 关系
- 参数、默认值和 UI profile 引用
- variant policy
- legacy source
- debug view 或验证锚点

可以声明：

```text
requires include HoNpr.ToonLobes;
requires capability ParticipatesSemanticPost;
produces semantic Aov.SurfaceData;
legacy source lilToon;
```

禁止：

```hlsl
#include "..."
#define HONPR_HAS_TOON_DIFFUSE_RAMP 1
#pragma shader_feature ...
```

block 是事实声明；include 排序、宏命名、assembly 选择和 entry 绑定由后续层处理。

FeatureBlock 不一定要求所有文件物理集中在一个目录，但逻辑上必须满足 Feature Ownership：打开一个 feature 的声明，应能追踪它的实现入口、参数、默认值、UI、依赖、capability、导出和调试锚点。任何只能靠命名习惯、RT 槽位或 keyword 推断的关系都不合格。

## 4. Template

Template 描述 ShaderLab 和 pass 骨架。

允许：

- shader name slot。
- properties slot。
- `SubShader` / `Pass`。
- `Tags` / `LightMode`。
- `Cull` / `Blend` / `ZWrite` / `ZTest` / `ColorMask`。
- `HLSLINCLUDE` include slot。
- `#pragma target`。
- `#pragma vertex` / `#pragma fragment` entry slot。
- 基于 preset pass token 生成或跳过 pass。

禁止：

- 内联大量 HLSL 主体。
- 直接写 lobe accumulation 主链路。
- 依赖 UI 参数改变 pass 结构。
- 继承旧 hidden shader 壳。
- 用大量 `HONPR_HAS_*` 在最终 shader 中拼结构。

Template 应该像骨架，不应该像算法实现。

## 5. Preset

Preset 是静态材质组合，是 shader 结构的主要事实来源。

必须声明：

- domain。
- archetype。
- tier。
- templates。
- feature blocks。
- passes。
- generator。
- generated shader path。
- capability。
- phase policy。
- material UI profile。
- 状态：active / prototype / deprecated / planned。

示例：

```text
preset MaterialPreset.Character_Toon_Standard
{
    domain Character;
    archetype Toon;
    tier Standard;
    templates MaterialTemplate.CharacterForward MaterialTemplate.CharacterOutline MaterialTemplate.CharacterAov;
    blocks MaterialBlock.BaseColorTexture MaterialBlock.ToonDiffuseRampLilToon ...;
    passes UniversalForward ForwardOutlineLilToon HoUrpAovOutput DepthOnly ShadowCaster;
    generator CharacterToonTemplate;
    shader "Shaders/Generated/Character/Character_Toon_Standard.shader";
}
```

禁止：

- 表达任意用户开关组合。
- 让材质实例增加 block。
- 让 UI 临时把 `Standard` 改成 `Rich` 结构。
- 用细碎 block 列表替代 domain / archetype / tier 的粗粒度设计。

判断规则：

```text
改变 pass / block / ABI / HoRP resource / assembly 的差异 = 新 preset。
只改变数值、贴图、颜色、强度 = 材质参数。
```

## 6. ShaderLibrary

`Shaders/ShaderLibrary` 是手写实现层。

允许：

- HLSL struct、helper、sampler、宏工具。
- 多个算法版本。
- 平台差异和 URP include 差异。
- 内部 `#if` 降低重复。
- 兼容旧行为的实现细节。

禁止：

- 重命名 HoRP 语义或 resource。
- 直接依赖材质 UI 状态。
- 长期依赖旧 lilToon include。
- 把旧 `_lil*` property 当新 ABI。
- 让单个 feature helper 决定 pass 是否存在。

ShaderLibrary 中的宏是实现细节，不是用户材质结构开关。

## 7. Assembly / Stable Entry Layer

Assembly 层负责把 ShaderLibrary 的复杂实现收束成 preset 级入口。

目标：

- 固化 lobe 顺序。
- 固化 forward / aov / oit / outline / depth / shadow 入口。
- 固化 Lite / Standard / Rich / Transparent 的结构差异。
- 把内部宏限制在 assembly 和 ShaderLibrary。
- 给 generated shader 一个稳定 include 和稳定 entry。

`DiffuseLobe` / `SpecularLobe` / `StylizedLobe` 是执行阶段和 lobe 类别，不是唯一 slot。同一 preset 可以包含多个可累加外观组分；唯一性仍按 `MaterialBlock.*`、shader property owner、以及独占语义写入判断。

可累加外观组分可以暴露材质实例级 blend mode，但该参数只影响 `HoNprLobeOutput` 的累加方式，不改变 block 是否存在、pass 结构、render state、include、define、keyword 或 variant。内置模式为 `Add`、`Screen`、`Max`、`Replace`，默认值必须保持向后兼容表现，除非 preset 明确声明迁移破坏。

建议路径：

```text
Shaders/ShaderLibrary/Assemblies/CharacterToon/
  HoNprCharacterToonCommon.hlsl
  HoNprCharacterToonLite.hlsl
  HoNprCharacterToonStandard.hlsl
  HoNprCharacterToonRich.hlsl
  HoNprCharacterToonTransparent.hlsl
```

Assembly 不应：

- 放在 `Shaders/Generated`。
- 由生成器每次生成隐藏大包。
- 依赖材质实例值决定结构。
- 输出还需要 generated shader 再用 `HONPR_HAS_*` 拼装的半成品。

## 8. Generator

Generator 负责装配和校验，不负责创造架构事实。

允许：

- 读取 include registry、template、block、preset、UI 声明和 HoRP contract index。
- 校验引用、capability、pass、entry、source mapping。
- 生成派生表。
- 根据 preset 选择 template 和 assembly。
- 写最终 `.shader`。
- 统一行尾和编码。

禁止：

- 读取材质 Inspector 当前状态决定结构。
- 按 preset 名称硬编码 pass / block / render state。
- 生成 `Shaders/Generated/*.hlsl` 隐藏大包。
- 在 C# 中按 block 顺序拼完整 fragment 主体。
- 把大量 `HONPR_HAS_*` 发射到最终 shader。

允许的 C# 分支是“选择组装器类型”，例如 `CharacterToonTemplate`；不允许在 C# 中写 `if Lite then remove specular` 这类结构事实。

## 9. Generated Shader

Generated shader 是 Unity 编译入口和人类审查产物。

合格形态应接近：

```hlsl
// Generated by HoNprShaderGenerator.
// SourcePreset: MaterialPreset.Character_Toon_Standard
// Templates: MaterialTemplate.CharacterForward, MaterialTemplate.CharacterAov
// Assembly: HoNpr.CharacterToon.Standard
// Blocks: MaterialBlock.BaseColorTexture, MaterialBlock.ToonDiffuseRampLilToon, ...
// Do not edit this file manually.

Shader "HoNpr/Character/Toon_Standard"
{
    Properties
    {
        ...
    }

    SubShader
    {
        HLSLINCLUDE
        #include "Packages/com.hollow.honpr/Shaders/ShaderLibrary/Assemblies/CharacterToon/HoNprCharacterToonStandard.hlsl"
        ENDHLSL

        Pass
        {
            Name "UniversalForward"
            Tags { "LightMode" = "UniversalForward" }

            HLSLPROGRAM
            #pragma target 4.5
            #pragma vertex HoNprCharacterToonVert
            #pragma fragment HoNprCharacterToonStandardForward
            ENDHLSL
        }
    }
}
```

Generated shader 禁止：

- 完整 forward fragment 主体。
- 大量结构宏。
- 大量 block 条件分支。
- 隐藏中间 include 大包。
- 旧 ABI 名称泄漏。
- 通过 material keyword 重新打开未声明能力。

## 10. Material UI

UI 消费 preset 和 `.honprui`。

UI 可以：

- 显示当前 preset。
- 显示只读 block / pass 摘要。
- 编辑白名单参数。
- 绑定 texture / ramp atlas。
- 显示迁移提示。

UI 不可以：

- 作为结构事实来源。
- 决定 generated shader path。
- 写 shader keyword 作为结构开关。
- 添加或删除 feature block。
- 暴露自由 render state 控件。

## 11. Material Semantic / Capability Model

材质系统声明“能生产什么语义”，pass 声明“需要什么语义”。shader 只是这个解析结果的后端输出。

材质参数不应只被理解成 shader uniform：

```hlsl
float _RimIntensity;
```

它还必须能追踪到材质语义：

```yaml
Parameter:
  Name: RimIntensity
  Type: Float
  Semantic: Lighting.Rim.Intensity
```

这样 UI、debug、文档、capability resolve 和 export 才能共享同一事实来源。

材质侧允许声明：

```yaml
Supports:
  - Lighting.Rim
  - Stylized.Shadow

Produces:
  - Surface.BaseColor
  - Lighting.Rim
```

pass 侧允许声明：

```yaml
Need:
  - Lighting.Rim
```

禁止：

- 让 RenderFeature 理解 Rim、MatCap、AnimeShadow、HairShift 等材质内部 feature。
- 让材质长期保存 runtime export slot、RT 名或 binding 状态。
- 用固定 RT 槽位暗示 semantic。
- 用 keyword 暗示 capability。

capability、producer、consumer、export 都必须是显式声明，不能从 shader property、UI 分组或 pass 名称反推。

## 12. Material Context

Feature 的实现不应直接把中间结果散落到临时全局变量或固定 AOV 槽位里。长期方向是统一的 material context，由 feature 写入语义化字段，最终由 assembly 固化 compose 顺序。

示例：

```hlsl
struct MaterialContext
{
    float3 diffuse;
    float3 specular;
    float3 rim;
    float shadowMask;
};
```

规则：

- Feature 写入 context 或声明 produces semantic。
- Assembly 固化 lobe / compose 顺序。
- Export resolve 决定哪些 context 字段需要临时暴露给 pass。
- Generated shader 不直接拼 feature 内部数据流。

## 13. Query-driven Export 与 Frame-local Resolve

AOV / export 的长期模型是 query-driven，而不是全局固定 AOV 表。

解析顺序：

```text
Cull
  -> Gather visible material capabilities
  -> Build frame-local semantic set
  -> Resolve pass requests
  -> Build transient export bindings
  -> Build RenderGraph
```

规则：

- AOV 是 Material Semantic Flow 的可访问化，不是固定 RenderTexture ABI。
- `Semantic -> RT` 只能是当前 frame / pass 的临时解析结果。
- RenderGraph 的价值在于把数据流显式化，不负责拥有材质 feature 语义。
- pass 只能请求 semantic，不能依赖某个材质 feature 的实现细节。
- generated shader 不能通过全局纹理副作用创建未声明的跨 pass 数据链路。

Material UI 的 render state 展示必须跟生成结构一致。多 pass 状态写在 `*.honprui` 的单条 `renderState` statement 中，用 `; ` 分隔 pass / 阶段，用 ` / ` 分隔并列 pass 集合，用 `, ` 分隔同一阶段内的 state 子项。Inspector 会按这些分隔符优化成多行显示，因此不要把多 pass 状态压成不可解析的自然语言，也不要把 render state 暴露为可编辑 property。

如果某个设计需要“所有材质全局注册所有 semantic”或“所有 AOV 永久绑定固定 RT”，应视为状态空间失控风险，先退回 capability query 和 frame-local resolve。

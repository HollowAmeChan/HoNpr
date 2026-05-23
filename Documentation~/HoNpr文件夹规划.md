# HoNpr 文件夹规划

> 本文只规划 `HoNpr` 仓库的材质 / shader / 生成系统目录，不重新定义 RP 侧契约。RP 侧语义、资源、Feature、Debug、Capability 的事实来源仍在 [`HoUrp-Extensions`](../../HoUrp-Extensions)。
>
> 先读：
>
> - [`rp设计哲学底线.md`](../../HoUrp-Extensions/Documentation~/rp设计哲学底线.md)
> - [`材质重构初步大纲.md`](../../HoUrp-Extensions/Documentation~/材质重构初步大纲.md)
> - [`材质组分链路对照与HoRP契约草案.md`](../../HoUrp-Extensions/Documentation~/材质组分链路对照与HoRP契约草案.md)
> - [`旧实现快速定位索引.md`](../../HoUrp-Extensions/Documentation~/旧实现快速定位索引.md)
>
> 旧材质参考仓库：
>
> - [`lilToon`](../../lilToon)
> - [`lilPBR`](../../lilPBR)
> - [`lilToon-URP-Extensions`](../../lilToon-URP-Extensions)

---

## 0. 定位

`HoNpr` 是 HoRP 的统一材质 / shader 包。NPR 是主方向；PBR 只作为 `HoStandardSurface`、BRDF/PBR lobe、资产导入和退化路径存在，不再拆独立 `HoPbr` 包。

`HoNpr` 不负责：

- 定义新的 RP 语义名。
- 定义新的 RP 资源名。
- 分配 RenderGraph 资源。
- 建立旧 `lilToon/lilPBR` 长期桥接层。
- 让材质 UI 决定 shader pass / feature block / keyword 结构。
- 通过反射 shader 属性自动推导材质 UI 或动态分叉编译。
- 让材质 UI 直接暴露原始 render state，例如 queue offset、Blend、Stencil、ZWrite、ZTest、Cull。

`HoNpr` 负责：

- 按 HoRP 契约组织材质模板、Feature Block、Preset、生成器和生成产物。
- 生产 `UniversalForward`、`HoUrpAovOutput`、`HoUrpOitAccumulation` 等 HoRP pass 所需 shader。
- 输出 `Material.*`、`Shading.*`、`Aov.*`、`Oit.*` 等上游已登记语义 / 资源所需数据。
- 维护旧材质能力到新组件的对照表和迁移判定。
- 为 HoNpr 材质实例提供极简参数 UI 包装，只做参数分组、命名、范围和默认提示，不改变 shader 结构。

---

## 1. 顶层目录

建议第一版顶层结构：

```text
HoNpr/
  Documentation~/
  Runtime/
  Editor/
  ShaderSystem/
  Shaders/
  Textures/
  Samples~/
  Tests/
```

| 目录 | 职责 | 是否进入运行时 | 说明 |
| --- | --- | --- | --- |
| `Documentation~/` | 规划、契约说明、旧实现对照、人类/AI 快速索引 | 否 | Unity package 文档目录 |
| `Runtime/` | C# 运行时定义、材质实例轻量数据、asset 类型 | 是 | 不放 shader 生成器核心逻辑 |
| `Editor/` | Inspector、导入器、生成器入口、校验窗口 | 否 | UI 只展示 preset 和参数，不决定结构 |
| `ShaderSystem/` | 模板、Feature Block、Preset、生成规则、机器可读声明 | 是/否混合 | 材质系统核心事实来源 |
| `Shaders/` | Unity 实际可编译 shader、include、隐藏工具 shader | 是 | `Generated/` 只放可 diff 产物 |
| `Textures/` | ramp、halftone、默认贴图、迁移参考贴图 | 是 | 按用途分组 |
| `Samples~/` | 示例材质、示例 ramp、验证场景 | 否 | 后续补 |
| `Tests/` | EditMode 测试、生成器测试、声明表一致性测试 | 否 | 第一版应优先做表格校验 |

---

## 2. 显式声明底线

用户和 AI 都必须能在文件夹里直接看懂“这里有什么、谁消费谁、谁生成谁”。所以每个关键文件夹都要有声明文件，而不是只靠文件名和代码约定。

### 2.1 关键目录保留自动生成索引表

| 目录类型 | 声明 / 派生文件 | 人类用途 | AI/工具用途 |
| --- | --- | --- | --- |
| 模板目录 | `*.honprtemplate` -> `TEMPLATE_TABLE.md` | 看 pass 骨架、输入输出、生成目标 | 从 DSL 校验模板引用，表格只做派生预览 |
| Feature Block 目录 | `*.honprblock` -> `FEATURE_BLOCK_TABLE.md` | 看每个 block 的 Domain、输入、输出、变体策略 | 从 DSL 校验 block 引用和 include alias |
| Preset 目录 | `*.honprpreset` -> `PRESET_TABLE.md` | 看每个 preset 启用哪些 block 和 pass | 从 DSL 生成 shader 和校验组合合法性 |
| Material UI 目录 | `*.honprui` -> `MATERIAL_UI_TABLE.md` | 看每个 preset 的参数分组、标签、控件和范围 | 校验 UI 只引用已声明参数，不触发结构变化 |
| Generated 目录 | 生成 shader 头部 provenance | 看生成产物来源和是否可手改 | 不放面向用户的索引文档，产物可删除重生 |
| Legacy 对照目录 | `LEGACY_MAPPING_TABLE.md` | 看旧符号迁移到哪里 | 防止旧 ABI 偷偷进入新核心 |
| 资产目录 | `ASSET_TABLE.md` | 看默认贴图/ramp/atlas 用途 | 导入器和校验器读取 |

### 2.2 表格字段要稳定

`FEATURE_BLOCK_TABLE.md` 建议字段：

| 字段 | 说明 |
| --- | --- |
| `Id` | 例如 `MaterialBlock.ToonDiffuseRampLilToon` |
| `Domain` | `MaterialDomain` / `ShadingDomain` / `CompositeDomain` 等 |
| `Stage` | `SurfaceInput` / `LightingInput` / `Lobe` / `SemanticProducer` / `Composite` |
| `Consumes` | 消费的 ABI 字段、语义、纹理 |
| `Produces` | 生产的 ABI 字段、lobe、语义、资源 |
| `Includes` | 需要的 include |
| `CompatiblePresets` | 可用 preset |
| `VariantPolicy` | `AlwaysCompiled` / `PresetStatic` / `DebugOnly` / `Unsupported` |
| `DebugViews` | 对应 debug view |
| `LegacyReference` | 旧实现参考链接 |
| `Decision` | `KeepConcept` / `Rename` / `Cut` / `PrototypeOnly` |

`PRESET_TABLE.md` 建议字段：

| 字段 | 说明 |
| --- | --- |
| `PresetId` | 例如 `MaterialPreset.Character_Toon_Standard` |
| `Template` | 使用的模板 |
| `FeatureBlocks` | 静态 block 列表 |
| `Passes` | `UniversalForward` / `HoUrpAovOutput` / `HoUrpOitAccumulation` 等 |
| `ProducesSemantics` | 生产的 HoRP 语义 |
| `RequiredCapabilities` | 需要的 capability |
| `PhasePolicy` | 透明 / OIT / 普通 forward 策略 |
| `GeneratedShader` | 生成产物路径 |
| `Status` | `Prototype` / `Active` / `Deprecated` |

---

## 3. ShaderSystem 规划

建议结构：

```text
ShaderSystem/
  README.md
  Contract/
  Templates/
  FeatureBlocks/
  Presets/
  Generator/
  LegacyInterop/
```

| 子目录 | 职责 | 必须声明 |
| --- | --- | --- |
| `Contract/` | HoNpr 对 HoRP 上游契约的本地索引 | `HORP_CONTRACT_INDEX.md` |
| `Templates/` | shader pass 骨架，不写复杂业务 | `*.honprtemplate`，派生 `TEMPLATE_TABLE.md` |
| `FeatureBlocks/` | 材质功能块 HLSL / 描述 | `*.honprblock`，派生 `FEATURE_BLOCK_TABLE.md` |
| `Presets/` | 静态组合定义 | `*.honprpreset`，派生 `PRESET_TABLE.md` |
| `Generator/` | 生成器代码和规则 | `GENERATOR_RULES.md` |
| `LegacyInterop/` | 旧实现对照表、迁移判定 | `LEGACY_MAPPING_TABLE.md` |

### 3.1 Contract

`Contract/` 只建立索引，不复制 RP 契约。第一版链接：

- [`HoUrpMaterialContracts.cs`](../../HoUrp-Extensions/Runtime/Semantic/HoUrpMaterialContracts.cs)
- [`MaterialFeatureBlockDefinition.cs`](../../HoUrp-Extensions/Runtime/Semantic/MaterialFeatureBlockDefinition.cs)
- [`MaterialPresetDefinition.cs`](../../HoUrp-Extensions/Runtime/Semantic/MaterialPresetDefinition.cs)
- [`HoUrpBuiltInNames.cs`](../../HoUrp-Extensions/Runtime/Core/HoUrpBuiltInNames.cs)
- [`HoUrpShaderPropertyIds.cs`](../../HoUrp-Extensions/Runtime/Core/HoUrpShaderPropertyIds.cs)
- [`HoUrpMaterialSurface.hlsl`](../../HoUrp-Extensions/Runtime/Shaders/ShaderLibrary/HoUrpMaterialSurface.hlsl)
- [`HoUrpMaterialAov.hlsl`](../../HoUrp-Extensions/Runtime/Shaders/ShaderLibrary/HoUrpMaterialAov.hlsl)
- [`HoUrpMaterialOit.hlsl`](../../HoUrp-Extensions/Runtime/Shaders/ShaderLibrary/HoUrpMaterialOit.hlsl)
- [`HoUrpObjectSemantic.hlsl`](../../HoUrp-Extensions/Runtime/Shaders/ShaderLibrary/HoUrpObjectSemantic.hlsl)

`HoNpr` 可以有本地 wrapper include，但 wrapper 只能做路径收敛和版本注释，不改语义。

### 3.2 Templates

建议第一版模板：

```text
Templates/
  TEMPLATE_TABLE.md
  Character/
    CharacterForward.honprtemplate
    CharacterAov.honprtemplate
    CharacterDepth.honprtemplate
    CharacterShadow.honprtemplate
    CharacterOit.honprtemplate
  Environment/
    EnvironmentForward.honprtemplate
    EnvironmentAov.honprtemplate
  Utility/
    DebugLit.honprtemplate
```

模板只允许定义：

- pass 名。
- Tags / LightMode。
- pragma 基线。
- include 插槽。
- ABI 入口函数。
- source mapping 注释格式。

模板不允许：

- 自行判断启用哪个 feature block。
- 写旧 `_lil*` / `_HoAov*` 兼容逻辑。
- 因 UI 参数改变 pass 结构。

### 3.3 FeatureBlocks

建议结构：

```text
FeatureBlocks/
  FEATURE_BLOCK_TABLE.md
  SurfaceInput/
  LightingInput/
  DiffuseLobe/
  SpecularLobe/
  StylizedLobe/
  Subsurface/
  SemanticAov/
  Transparency/
  Composite/
  Debug/
```

第一版最小 block：

| Block | 目录 | 说明 |
| --- | --- | --- |
| `BaseColorTexture` | `SurfaceInput/` | 生产 base color / alpha |
| `NormalMap` | `SurfaceInput/` | 生产 normal |
| `MaterialMapPacked` | `SurfaceInput/` | metallic / roughness / AO |
| `StyleRampAtlas` | `SurfaceInput/` | ramp 采样输入 |
| `ToonDiffuseRampLilToon` | `DiffuseLobe/` | toon 漫反射，来源 lilToon |
| `PbrDiffuse` | `DiffuseLobe/` | PBR 漫反射 |
| `PbrSpecularGGX` | `SpecularLobe/` | 标准 PBR 高光 |
| `ToonSpecularLilToon` | `SpecularLobe/` | toon 高光，来源 lilToon |
| `HairSpecularPrimary` | `SpecularLobe/` | 发丝主高光 |
| `HairSpecularSecondary` | `SpecularLobe/` | 发丝副高光 |
| `MatCapLilToon` | `StylizedLobe/` | 风格化材质光，来源 lilToon |
| `RimLightLilToon` | `StylizedLobe/` | 加亮边缘，来源 lilToon |
| `RimShadeLilToon` | `StylizedLobe/` | 乘暗边缘，来源 lilToon |
| `BackfaceColorLilToon` | `StylizedLobe/` | 背面着色，来源 lilToon |
| `ForwardThinSss` | `Subsurface/` | forward 假 SSS |
| `SssSourceProducer` | `Subsurface/` | 生产 `Shading.SssSourceColor` / `Shading.SssWeight` |
| `MaterialSemanticProducer` | `SemanticAov/` | 生产 `Material.*` |
| `AovOutputStandard` | `SemanticAov/` | 编码 HoRP AOV |
| `OitAccumulationOutput` | `Transparency/` | 生产 OIT accumulation 输入 |
| `ForwardSkipWhenOit` | `Transparency/` | phase policy，不是旧 `_lilOITActive` |
| `FinalColorComposite` | `Composite/` | 唯一允许组合 final color 的常规 block |

### 3.4 Presets

建议结构：

```text
Presets/
  PRESET_TABLE.md
  Character/
    Character_Toon_Lite.honprpreset
    Character_Toon_Standard.honprpreset
    Character_Toon_Rich.honprpreset
    Character_Toon_Transparent.honprpreset
    Character_Toon_Core.honprpreset        # 过渡兼容，不作为新材质主入口
    Character_Skin_SSS.honprpreset
    Hair_Toon.honprpreset
  Environment/
    Environment_PBR.honprpreset
  Transparent/
    Transparent_OIT.honprpreset
  Debug/
    Character_DebugLit_SSS_OITReady.honprpreset
```

第一版 preset：

| Preset | 目的 | 必须 pass |
| --- | --- | --- |
| `Character_DebugLit_SSS_OITReady` | 对齐 RP 侧原型契约 | `UniversalForward`, `HoUrpAovOutput`, `HoUrpOitAccumulation` |
| `Character_Toon_Lite` | 轻量 toon 角色 / 配件 | `UniversalForward`, `HoUrpAovOutput`, `DepthOnly`, `ShadowCaster` |
| `Character_Toon_Standard` | 默认 toon 角色，包含常用 stylized lobe 和 outline | `ForwardOutlineLilToon`, `UniversalForward`, `HoUrpAovOutput`, `DepthOnly`, `ShadowCaster` |
| `Character_Toon_Rich` | 完整 lilToon 来源外观组合，包含二级 matcap、glitter、distance fade 等 | `ForwardOutlineLilToon`, `UniversalForward`, `HoUrpAovOutput`, `DepthOnly`, `ShadowCaster` |
| `Character_Toon_Transparent` | 半透明 / OIT toon，透明结构由 preset 固定 | `UniversalForward`, `HoUrpAovOutput`, `HoUrpOitAccumulation` |
| `Character_Toon_Core` | 旧规划遗留的过渡 preset，不再作为新增材质推荐入口 | `UniversalForward`, `HoUrpAovOutput`, `DepthOnly`, `ShadowCaster` |
| `Character_Skin_SSS` | 皮肤 SSS 生产者 | `UniversalForward`, `HoUrpAovOutput`, `DepthOnly`, `ShadowCaster` |
| `Hair_Toon` | 头发 | `UniversalForward`, `HoUrpAovOutput`, `DepthOnly`, `ShadowCaster` |
| `Environment_PBR` | 场景 PBR 子集 | `UniversalForward`, `DepthOnly`, `ShadowCaster`，AOV 可选 |
| `Transparent_OIT` | OIT 半透明 | `UniversalForward`, `HoUrpAovOutput`, `HoUrpOitAccumulation` |

Preset 只列静态组合。材质实例只能改参数、贴图、ramp、少量 scalar；不能增删 block。

### 3.5 Material UI

Material UI 是 HoNpr 材质实例的极简包装层，只解决“参数怎么给人看、怎么编辑、怎么少犯错，以及常用小工具怎么安全操作参数”。它不是生成器输入，也不是 shader 结构来源。

建议结构：

```text
ShaderSystem/
  MaterialUi/
    MATERIAL_UI_TABLE.md
    Common/
      StandardSurface.honprui
      Transparency.honprui
      SemanticAov.honprui
    Character/
      Character_Toon_Lite.honprui
      Character_Toon_Standard.honprui
      Character_Toon_Rich.honprui
      Character_Toon_Transparent.honprui
      Character_Toon_Core.honprui
      Character_Skin_SSS.honprui
      Hair_Toon.honprui
    Environment/
      Environment_PBR.honprui
    Debug/
      Character_DebugLit_SSS_OITReady.honprui
```

`*.honprui` 只允许声明：

- 绑定到哪个 preset。
- 参数分组和折叠状态。
- 显示名、说明、单位、范围、默认值提示。
- 控件类型，例如 color、texture、slider、toggle、enum、ramp atlas、vector。
- 小工具类型，例如复制、粘贴、重置、归一化、从贴图取默认值。
- 提示和警告，例如 info、warning、error、HoRP contract box。
- 只读 render state 摘要，例如当前 preset 固定的 queue、blend、depth、stencil 策略。
- 参数可见条件，但只能基于同一个材质实例的普通参数值做 UI 显隐。
- 迁移提示，例如旧属性名映射到新属性名。

`*.honprui` 禁止声明：

- pass、template、feature block、include、define、pragma、keyword。
- 任何会改变 shader variant 或 pass 存在性的逻辑。
- 通过 shader reflection 自动枚举属性并生成面板。
- 根据 UI 状态写回 preset 或生成新的 `.honprpreset`。
- 直接引用旧 `_lil*`、`_HoAov*` 属性作为新 ABI。旧名只能写在迁移提示里。
- 跨材质复制结构信息，例如 preset、shader、pass、block、keyword、render queue override。
- 直接编辑原始 render state，例如 `Queue`、`Blend`、`Stencil`、`ZWrite`、`ZTest`、`Cull`、`ColorMask`。

UI 参数来源分三层：

| 层级 | 事实来源 | 用途 |
| --- | --- | --- |
| Shader property | 生成 shader 的 `Properties` 与 HoRP property ID | Unity 材质实际存储 |
| UI descriptor | `*.honprui` | 人类可读的分组、标签、控件、范围 |
| Material instance | `.mat` 或后续轻量 asset | 保存用户实际参数值 |

第一阶段只做白名单式 UI，不做反射：

- `Base`：base color、base map、alpha。
- `Normal`：normal map、normal scale。
- `Style`：ramp atlas、toon ramp index、matcap。
- `Lighting`：rim、rim shade、specular、hair highlight。
- `SSS`：sss profile、thickness、curvature、sss weight。
- `Semantic / AOV`：material class、custom0-3，只显示必要字段。
- `Transparency`：alpha、coverage、OIT 参与开关，只表达参数，不决定 pass。

`MATERIAL_UI_TABLE.md` 建议字段：

| 字段 | 说明 |
| --- | --- |
| `PresetId` | 绑定的 preset |
| `Group` | UI 分组 |
| `Property` | shader property 或 HoRP property ID |
| `Label` | 中文显示名 |
| `Control` | 控件类型 |
| `Range` | 数值范围或枚举值 |
| `DefaultHint` | 默认值提示 |
| `Visibility` | 仅 UI 显隐条件 |
| `Tools` | 允许绘制的小工具 |
| `Messages` | 允许绘制的提示 / 警告 |
| `ContractBox` | HoRP 契约区域，例如 HoAOV、OIT、Semantic |
| `RenderStateView` | 只读 render state 摘要 |
| `CopyScope` | 可复制的参数范围 |
| `MigrationHint` | 旧属性迁移提示 |
| `StructuralEffect` | 固定为 `None` |

核心规则：

- UI descriptor 可以缺字段，缺了就不显示；不能靠 reflection 补全。
- UI descriptor 可以把多个底层属性包装成一个“简化表达”，但写入时必须落回明确的 shader property。
- UI descriptor 的校验只检查属性存在、类型匹配、范围合法、没有结构字段。
- Inspector 只能显示当前材质 shader 已经固定的 preset，不提供切换到另一个 preset 后自动换 shader 的隐式行为。
- 如果需要切 preset，必须走显式命令：创建/替换材质 shader，保留可迁移参数，记录迁移日志。

#### 3.5.1 小工具与复制粘贴

UI 小工具是 Material UI 的一部分，但只能操作材质参数值。它们不能参与生成器，也不能成为结构配置来源。

第一阶段允许的小工具：

| 工具 | 作用范围 | 说明 |
| --- | --- | --- |
| `CopyGroup` | 当前 UI group | 复制该组内白名单 property 的值 |
| `PasteGroup` | 当前 UI group | 粘贴同名或映射后的 property 值 |
| `CopyProperty` | 单个 property | 复制单项参数 |
| `PasteProperty` | 单个 property | 粘贴单项参数，类型必须匹配 |
| `ResetGroup` | 当前 UI group | 恢复 descriptor 默认值提示对应的值 |
| `NormalizeVector` | vector/color | 归一化方向、权重或颜色权重类参数 |
| `PickTextureDefaults` | texture group | 从贴图导入设置或默认资源填充缺省参数 |
| `CopyMigrationLog` | 当前材质 | 复制迁移/粘贴日志，方便排查 |

复制粘贴使用显式 payload，不直接依赖 Unity clipboard 里的自由文本作为事实来源：

```text
HoNprMaterialParameterClipboard
PresetId: MaterialPreset.Character_Toon_Standard
Group: Style
Properties:
  _HoNprRampAtlas: <asset-guid>
  _HoNprRampIndex: 2
  _HoNprMatCapLilToonMask: 0.65
```

payload 规则：

- 必须记录来源 `PresetId`、group、property 名、类型和值。
- 可以跨材质粘贴，但只粘贴目标 `*.honprui` 明确允许的 property。
- 同 preset 粘贴走同名 property。
- 不同 preset 粘贴必须经过 `CopyScope` 或 `MigrationHint` 映射，无法映射的字段跳过并记录日志。
- 贴图、ramp、atlas 这类对象引用按 GUID / local file id 记录，粘贴前必须确认资源存在。
- 数值粘贴必须 clamp 到目标 descriptor 的 `Range`。
- enum 粘贴必须按目标 descriptor 的枚举名匹配，不能只按 int 值硬塞。
- color / vector 粘贴必须匹配维度，允许显式声明 swizzle，否则跳过。
- 粘贴不能修改 shader、preset、render queue、keyword、pass、block、material tag。

推荐的复制范围：

| CopyScope | 内容 |
| --- | --- |
| `Property` | 单个 property |
| `Group` | 一个 UI group 内的 property |
| `PresetCompatibleGroup` | 不同 preset 之间通过映射表允许迁移的 group |
| `MaterialValuesOnly` | 当前材质所有白名单参数值，不含结构信息 |

Inspector 需要在粘贴前给出简短预览：

- 将写入哪些 property。
- 哪些字段因目标材质不支持而跳过。
- 哪些字段被 clamp 或 enum remap。
- 是否包含对象引用缺失。

#### 3.5.2 警告信息与 HoRP 契约区域

Material UI 可以绘制明显的提示和警告区域，尤其是 HoRP 相关设置。HoAOV、OIT、Semantic、RenderGraph resource 这些概念属于 RP 契约，视觉上必须和普通材质外观参数区分开。

推荐将这类区域命名为 `ContractBox`，第一阶段支持：

| ContractBox | 用途 | 典型内容 |
| --- | --- | --- |
| `HoRP.AOV` | HoAOV / semantic output 相关设置 | material class、mask id、normal depth、surface data、sss source |
| `HoRP.OIT` | OIT 参与和透明输出相关设置 | participates OIT、accumulation input、revealage input、coverage |
| `HoRP.Semantic` | Material / Shading 语义生产状态 | `Material.*`、`Shading.*` 是否由当前 preset 生产 |
| `HoRP.Contract` | 上游契约版本和缺失项提示 | HoUrp 契约索引、缺失 property、过期字段 |
| `Migration` | 旧材质迁移提示 | `_lil*` / `_HoAov*` 到新 property 的映射结果 |

`ContractBox` 绘制规则：

- 使用明显 box，而不是混在普通参数组里。
- 标题必须写清楚这是 HoRP / RP 契约相关区域。
- 可以展示当前 preset 会输出到哪些 HoRP pass / semantic。
- 可以展示 warning / error / info 三种级别。
- 可以提供“打开契约文档”“复制诊断信息”“复制迁移日志”这类工具。
- 可以提供“填入推荐默认值”这类参数级修复动作。
- 不能提供“启用 AOV pass”“关闭 OIT pass”“切换 RenderGraph resource”这类结构动作。

警告来源分三类：

| 来源 | 示例 | 允许动作 |
| --- | --- | --- |
| Descriptor 静态规则 | 参数缺失、范围不合法、对象引用缺失 | 显示 warning，允许定位 property |
| HoRP 契约校验 | 当前 preset 声明输出 AOV，但关键 semantic 参数为空 | 显示 warning/error，允许填默认值或打开文档 |
| 迁移 / 粘贴结果 | 旧属性无法映射、粘贴字段被跳过 | 显示 info/warning，允许复制日志 |

HoAOV 相关区域要特别显眼：

- 单独使用 `HoRP.AOV` box。
- 明确列出当前材质会写入的 AOV semantic。
- 明确列出哪些参数只是 AOV metadata，不是外观参数。
- 如果 AOV 参数来自对象语义或 RenderGraph 资源，不要伪装成普通材质参数。
- 如果某个输出由 HoRP 侧决定，UI 只显示只读说明和契约链接。

#### 3.5.3 Render State 暴露策略

队列偏移、混合模式、模板设置、深度写入、深度测试、剔除模式这类设置要按“结构状态”处理，而不是按普通材质参数处理。默认结论：不直接暴露给普通用户编辑。

这些状态的归属：

| 状态 | 归属 | UI 策略 |
| --- | --- | --- |
| Render queue / queue offset | template / preset / HoRP phase policy | 默认只读显示，不提供自由 slider |
| Blend / BlendOp | template / preset | 只读显示；透明策略通过 preset 固定 |
| Stencil | HoRP pass / feature contract | 只读显示；不允许材质实例编辑 |
| ZWrite / ZTest | template / pass state | 只读显示；不允许材质实例编辑 |
| Cull | template / preset | 默认只读；双面需求必须走明确 preset 或受控参数 |
| ColorMask / MRT layout | HoRP pass / AOV contract | 只读显示；不允许材质实例编辑 |
| RenderType / LightMode / Tags | template / generated shader | 只读显示；不允许材质实例编辑 |

为什么不开放：

- 这些值改变的是渲染路径、排序、pass 行为或 RP 资源写入，不是材质外观参数。
- 一旦开放，UI 就会重新变成旧包那种“材质面板决定结构”的入口。
- `Blend` / `Stencil` / `Queue` 的错误组合会破坏 HoAOV、OIT、Depth、Shadow、SemanticPost 的时序假设。
- 跨材质复制粘贴如果携带这些值，会把一个材质的结构策略污染到另一个材质。

允许的例外必须满足两个条件：HoRP 或 HoNpr preset 已经显式声明这个策略，并且 UI 只在受控枚举里切换。

第一阶段建议只保留以下受控表达：

| 受控表达 | 可编辑性 | 说明 |
| --- | --- | --- |
| `SurfaceKind` | 不建议第一阶段编辑 | Opaque / Cutout / Transparent / OIT 应优先由 preset 固定 |
| `AlphaClipThreshold` | 可编辑 | 这是材质阈值参数，不是 pass 开关；对应 pass 是否存在仍由 preset 决定 |
| `TransparentSortBias` | 谨慎，默认隐藏 | 仅在 HoRP 侧明确支持材质排序 bias 时可开放小范围 enum，不开放任意 queue offset |
| `DoubleSidedNormalMode` | 谨慎 | 双面渲染应优先走 preset；如开放，只能影响 normal 处理参数，不能直接改 `Cull` |
| `OitParticipation` | 可显示，谨慎编辑 | 只表达材质是否参与 OIT 语义；`HoUrpOitAccumulation` pass 是否存在由 preset 决定 |

UI 可以绘制 `RenderStateView` 只读 box：

- 显示当前 preset 固定的 queue、blend、depth、stencil、cull 摘要。
- 标出这些状态来自 template / preset，不来自材质实例。
- 如果材质实际 render queue 被 Unity 用户手动 override，显示 warning。
- 如果检测到材质 tag / queue 与 generated shader 预期不一致，显示 error，并提供“恢复推荐值”这种参数级或 Unity material setting 级修复；不得生成新 preset。

强制规则：

- `*.honprui` 不能声明 `QueueOffsetSlider`、`BlendModeDropdown`、`StencilPanel` 这类自由 render state 控件。
- 复制粘贴 payload 不能包含 render queue、shader tag、blend、stencil、depth、cull。
- 如果确实需要新的透明、遮罩、模板或排序策略，新增 preset / template，而不是在 UI 上加开关。

### 3.6 Generator

建议结构：

```text
Generator/
  GENERATOR_RULES.md
  SourceMapping.md
  ValidationRules.md
  HoNprShaderGenerator.cs
  HoNprPresetValidator.cs
```

Generator 必须提供类似 `lilToon` 的编辑器强制刷新按钮。现有 HoToon 小模块已经有 [`Assets/HoNpr/HoToon/[Shader] 刷新 Shader`](../Editor/HoNprHoToonEditorUtils.cs)；新生成系统的入口位置应放得接近，避免人和 AI 到处找。

推荐菜单：

```text
Assets/HoNpr/生成器/[材质] 强制刷新 Shader 与材质 UI
Assets/HoNpr/生成器/[Shader] 刷新生成的 Shader 资源
Assets/HoNpr/生成器/[校验] 校验 Shader 系统声明
Assets/HoNpr/生成器/[文档] 重建声明表
```

推荐优先级：

```text
HoToon menu priority: 1100
Generator menu priority: 1120-1140
```

这样 `HoToon` 的迁移期刷新和 HoNpr 正式生成系统入口会自然排在一起。

生成器规则：

- 生成前读取 `*.honprpreset`、`*.honprblock`、`*.honprtemplate` 和 include registry。
- 从 DSL 校验每个 preset 引用的 block / template 都存在。
- 校验每个 block 的 `VariantPolicy` 允许当前 preset 使用。
- 校验 pass 由模板决定，不能由 UI 参数决定。
- 生成 `.shader` 时写入 source mapping 注释。
- 生成产物必须可读、可 diff、可删除重生。
- 强制刷新按钮必须重建声明表、执行 DSL 声明校验、重跑生成器、刷新 `Shaders/Generated/`，并通过 `AssetDatabase.ImportAsset(..., ForceUpdate | ForceSynchronousImport)` 导入生成结果；随后重建并校验 `MATERIAL_UI_TABLE.md`，刷新材质 UI 描述缓存。
- 强制刷新不能读取材质 Inspector 当前状态来决定结构；它只能读取 template / block / preset / include registry。

生成产物头部建议：

```text
// 由 HoNprShaderGenerator 生成。
// SourcePreset: MaterialPreset.Character_Toon_Standard
// Template: MaterialTemplate.CharacterForward
// Blocks: BaseColorTexture, NormalMap, ToonDiffuseRampLilToon, AovOutputStandard
// 不要手动修改生成体。请改 template / block / preset。
```

### 3.7 LegacyInterop

建议结构：

```text
LegacyInterop/
  LEGACY_MAPPING_TABLE.md
  lilToon/
  lilPBR/
  HoUrpExtensions/
```

必须明确写入旧符号只能作为迁移参考：

| 旧符号 | 新位置 | 判定 |
| --- | --- | --- |
| `HoAOV` | `HoUrpAovOutput` | 改名，不继承 |
| `HoAOVSSS` | `SssSourceProducer` + `HoUrpAovOutput` | 拆分概念 |
| `lilToonOIT` | `HoUrpOitAccumulation` | 改名，不继承 |
| `_lilHoAov*` | `_HoUrpAov*` / Resource registry | 不进入新材质 ABI |
| `_HoAov*` | `Material.*` / `_HoUrpMaterial*` | 改名 |
| `_lilOITActive` | phase policy | 不继承全局状态名 |
| `lilFragData` | `HoStandardSurfaceData` / `HoStylizedSurfaceData` / `HoLobeOutput` | 拆分 |
| `ShadingParams` | `HoStandardSurfaceData` / `HoLightingContext` / `HoLobeOutput` | 拆分 |

---

## 4. Shaders 规划

建议结构：

```text
Shaders/
  README.md
  ShaderLibrary/
  Generated/
  Hidden/
  HoToon/
```

| 子目录 | 职责 |
| --- | --- |
| `ShaderLibrary/` | 手写 include，服务 `ShaderSystem/FeatureBlocks` |
| `Generated/` | 生成器产物，Unity 实际编译入口 |
| `Hidden/` | editor/debug/import/helper shader |
| `HoToon/` | 迁移期 HoToon 小模块 |

### 4.1 ShaderLibrary

建议结构：

```text
Shaders/ShaderLibrary/
  README.md
  HoNprCommon.hlsl
  StandardSurface/
  StylizedSurface/
  SemanticSurface/
  Lighting/
  Transparency/
  Debug/
```

`StandardSurface/` 放可交换 PBR 子集，例如 baseColor、metallic、roughness、normal、occlusion、emission。

`StylizedSurface/` 放 HoNpr 扩展层，例如 ramp、matcap、rim、hair、face shadow。

`SemanticSurface/` 放材质语义 producer，例如 `Material.Class`、`Material.SssProfile`、`Shading.SssSourceColor`。

### 4.2 Generated

建议结构：

```text
Shaders/Generated/
  Character/
  Environment/
  Transparent/
  Debug/
```

`Generated/` 下的 shader 可以提交到版本控制，因为它们要可 diff、可查来源、可用于 Unity 编译稳定性验证。

规则：

- 不手改生成产物主体。
- 必须有 source mapping。
- 每个生成 shader 头部必须写入 source mapping。
- 生成器重跑后 diff 应该稳定。

### 4.3 HoToon 小模块

当前已有：

- [`Shaders/HoToon/URP/HalfToonURP.shader`](../Shaders/HoToon/URP/HalfToonURP.shader)
- [`Shaders/HoToon/URP/README.md`](../Shaders/HoToon/URP/README.md)
- [`Textures/Halftone/`](../Textures/Halftone)
- [`Editor/HoNprHoToonTextureImportSettings.cs`](../Editor/HoNprHoToonTextureImportSettings.cs)
- [`Editor/HoNprHoToonEditorUtils.cs`](../Editor/HoNprHoToonEditorUtils.cs)

建议移动到更清晰的位置：

```text
Modules/
  HoToon/
    README.md
    Shaders/URP/HalfToonURP.shader
    Textures/Halftone/
    Editor/
    LEGACY_STATUS.md
```

移动原因：

- `HoToon` 是迁移期小模块，不是最终 `ShaderSystem` 主线。
- 半调贴图和导入工具应跟模块放在一起，便于后续整体保留、替换或删除。
- `Shaders/` 顶层应留给 HoNpr 新材质系统和生成产物。

如果暂时不移动，至少在 `Shaders/HoToon/URP/README.md` 和 `Textures/Halftone/ASSET_TABLE.md` 写明：这是 `PrototypeOnly` / `LegacyReference`，不能作为新材质系统目录样板。

---

## 5. Runtime / Editor 规划

### 5.1 Runtime

建议结构：

```text
Runtime/
  HoNpr.Runtime.asmdef
  Materials/
  Presets/
  MaterialUi/
  Assets/
  Validation/
```

| 子目录 | 职责 |
| --- | --- |
| `Materials/` | 材质实例运行时轻量数据，不定义 pass 结构 |
| `Presets/` | ScriptableObject 形式的 preset asset 类型 |
| `MaterialUi/` | 参数 UI descriptor 的运行时数据结构，不包含 Editor 绘制代码 |
| `Assets/` | ramp atlas、材质贴图集、默认资源引用类型 |
| `Validation/` | 运行时可复用的声明校验逻辑 |

### 5.2 Editor

建议结构：

```text
Editor/
  HoNpr.Editor.asmdef
  Inspectors/
  MaterialUi/
  Generator/
  Importers/
  Validation/
  HoToon/
```

| 子目录 | 职责 |
| --- | --- |
| `Inspectors/` | 轻量 preset/material 面板 |
| `MaterialUi/` | `*.honprui` 解析、UI descriptor 校验、材质参数绘制 helper、小工具、警告 box、HoRP contract box 与复制粘贴 helper |
| `Generator/` | 生成菜单、生成器 editor 入口 |
| `Importers/` | 贴图/ramp/atlas 导入规则 |
| `Validation/` | 表格、preset、generated shader 一致性检查 |
| `HoToon/` | HoToon 小模块 editor 工具，若模块未移动则暂放 |

Editor UI 底线：

- 可以选择 preset。
- 可以显示 block 列表。
- 可以显示 validation 结果。
- 可以绘制 warning / error / info 提示。
- 可以绘制明显的 HoRP contract box，例如 HoAOV、OIT、Semantic。
- 可以绘制只读 render state 摘要，说明 queue / blend / stencil / depth / cull 来自 preset 或 template。
- 可以编辑少量参数、贴图槽、ramp atlas。
- 可以绘制参数小工具，例如复制、粘贴、重置、归一化、迁移日志。
- 不能新增/删除 feature block。
- 不能动态决定 pass 是否存在。
- 不能扫描 inspector 属性反向生成 keyword。
- 不能用 shader reflection 自动生成完整 UI。
- 不能根据 UI 折叠组或 toggle 改写 preset、block、template。
- 不能通过复制粘贴修改 shader、preset、keyword、render queue、pass 或 block。
- 不能把 HoRP contract box 里的 warning 修复按钮做成结构开关。
- 不能把 queue offset、Blend、Stencil、ZWrite、ZTest、Cull 暴露成普通材质参数。
- 不能通过 warning 修复按钮修改 pass state；只能恢复 Unity material setting 的推荐值或提示换 preset。

Inspector 第一版行为：

- 读取材质当前 shader 头部或固定 property，识别 `SourcePreset`。
- 按 `SourcePreset` 找到对应 `*.honprui`。
- 只绘制 `*.honprui` 白名单里的参数。
- 只绘制 `*.honprui` 白名单里的小工具。
- 只绘制 `*.honprui` 白名单里的 warning / contract box。
- 绘制只读 `RenderStateView`，用于解释当前 preset 的 queue / blend / stencil / depth / cull。
- 缺失参数显示只读 warning，不自动创建隐藏属性。
- 未声明参数折叠到“高级 / 原始属性”只读区，便于排查但不鼓励编辑。
- 提供 group/property 级复制粘贴，并在写入前显示预览。
- 提供“复制迁移日志”按钮，记录旧属性到新属性的手动映射结果、跳过字段和 clamp/remap 结果。
- HoRP.AOV / HoRP.OIT / HoRP.Semantic 区域用明显 box 绘制，标题写清楚“HoRP 契约”。

---

## 6. Textures / Assets 规划

建议结构：

```text
Textures/
  README.md
  ASSET_TABLE.md
  Ramps/
  Halftone/
  Defaults/
  LegacyReference/
```

| 子目录 | 职责 |
| --- | --- |
| `Ramps/` | `StyleRampAtlas`、shadow/rim/spec/sss ramp |
| `Halftone/` | HoToon 半调贴图，若模块迁移则移到 `Modules/HoToon/Textures/` |
| `Defaults/` | white/black/normal/default packed maps |
| `LegacyReference/` | 从旧包复制或引用的对照贴图，不能默认参与新材质 |

`ASSET_TABLE.md` 字段：

| 字段 | 说明 |
| --- | --- |
| `AssetId` | 资产稳定 ID |
| `Path` | 路径 |
| `Type` | Ramp / Halftone / Default / LegacyReference |
| `ColorSpace` | sRGB / Linear |
| `ImporterPolicy` | 导入规则 |
| `UsedBy` | 使用它的 preset/block |
| `Status` | Active / PrototypeOnly / LegacyReference |

---

## 7. Tests 规划

建议结构：

```text
Tests/
  HoNpr.Tests.asmdef
  Editor/
  Runtime/
```

第一批测试不急着测画面，先测声明和生成稳定性：

| 测试 | 目的 |
| --- | --- |
| `FeatureBlockTableTests` | 表格里的 block 都来自 `.honprblock` |
| `PresetTableTests` | preset 引用的 block 都存在 |
| `GeneratedShaderProvenanceTests` | generated shader 头部来源可追踪 |
| `LegacySymbolGuardTests` | 新生成 shader 不含 `_lil*`、`_HoAov*`、`HoAOV`、`lilToonOIT` |
| `HoUrpContractReferenceTests` | HoNpr 引用的语义/pass/resource 在 HoUrp 契约中存在 |
| `MaterialUiDescriptorTests` | `*.honprui` 只引用已存在参数，且 `StructuralEffect` 固定为 `None` |
| `MaterialUiNoReflectionTests` | Inspector 路径不通过 shader reflection 生成参数列表 |
| `MaterialUiClipboardTests` | 复制粘贴 payload 只包含白名单参数值，不包含结构字段 |
| `MaterialUiPasteValidationTests` | 跨材质粘贴会执行类型、范围、enum、资源引用校验 |
| `MaterialUiContractBoxTests` | HoRP contract box 只显示契约状态和参数级修复，不提供结构开关 |
| `MaterialUiWarningTests` | warning / error / info 来源可追踪，且不依赖 shader reflection |
| `MaterialUiRenderStateTests` | `*.honprui` 不能声明自由 render state 控件，只能声明只读 `RenderStateView` 或受控策略 |

---

## 8. 第一阶段落地顺序

1. 建 `Documentation~/`、`ShaderSystem/`、`Shaders/Generated/` 的 README 和 DSL 声明目录。
2. 建 `ShaderSystem/Contract/HORP_CONTRACT_INDEX.md`，链接 RP 侧契约。
3. 建 `ShaderSystem/FeatureBlocks/*.honprblock`，先登记最小原型 blocks。
4. 建 `ShaderSystem/Presets/*.honprpreset`，先登记 `Character_DebugLit_SSS_OITReady`。
5. 建 `ShaderSystem/LegacyInterop/LEGACY_MAPPING_TABLE.md`，冻结旧符号迁移判定。
6. 建 `ShaderSystem/MaterialUi/*.honprui` 和 `MATERIAL_UI_TABLE.md`，先覆盖 `Character_DebugLit_SSS_OITReady` 的最小参数 UI。
7. 决定是否移动 HoToon 小模块到 `Modules/HoToon/`。移动前保留 `.meta`，不要破坏 Unity GUID。
8. 再做生成器和第一份 `Generated` shader。
9. 最后做极简 Inspector：只读 preset、按 `*.honprui` 绘制白名单参数和小工具，不做反射和结构分叉。

---

## 9. 验收问题

每次新增材质能力前，先问：

- 能否从目录里的表格看出它属于哪个 Domain？
- 能否看出它消费哪些 ABI 字段、语义、资源？
- 能否看出它生产哪些 lobe、语义、资源？
- 能否看出它能被哪些 preset 使用？
- 能否看出它的 variant policy？
- 能否从 generated shader 追溯到 template / block / preset？
- 是否没有新增 `_lil*`、`_HoAov*`、`HoAOV`、`HoAOVSSS`、`lilToonOIT`？
- 是否没有让 UI 决定 pass 或 block？
- 是否没有让 UI descriptor 声明 keyword、define、include 或 variant？
- 是否没有通过 shader reflection 自动生成参数 UI？
- 是否能从 `*.honprui` 看出每个可编辑参数的来源、范围、控件和迁移提示？
- 是否能从 `*.honprui` 看出每个小工具的作用范围和允许写入的 property？
- 是否能从 `*.honprui` 看出 HoRP contract box 的来源、级别、文档链接和允许动作？
- 跨材质复制粘贴是否只传递参数值，不传递 shader / preset / keyword / pass / block？
- 粘贴前是否能看到写入、跳过、clamp、enum remap 和缺失资源的预览？
- HoAOV / OIT / Semantic 相关设置是否被明显标成 HoRP 契约区域，而不是普通外观参数？
- warning 修复按钮是否只改参数或打开文档，不改 pass、block、keyword 或 RenderGraph resource？
- queue offset、Blend、Stencil、ZWrite、ZTest、Cull 是否只读显示或由 preset/template 固定，而不是普通材质参数？
- 如果确实需要新的透明、模板或排序策略，是否走新增 preset/template，而不是 UI 开关？
- 是否仍然对齐 `HoUrp-Extensions` 的正式契约？

一句话底线：`HoNpr` 的目录不是“shader 文件分类”，而是材质系统的显式声明面。任何生成、模板、迁移、调试入口都必须有表格和链接，让人类和 AI 能在不猜代码的情况下理解它的生产、消费和生命周期。
---

## 10. 组分来源命名底线

HoNpr 的 Feature Block 不只要说明“做什么”，还必须说明“从哪里来”。凡是从旧实现迁移、复刻或以旧实现作为行为验收基线的组分，都必须把来源写进组分身份。

必须执行：

- Feature Block ID 带来源后缀，例如 `OutlineLilToon`、`SecondaryMatCapLilToon`、`GlitterLilToon`。
- Entry 函数、DebugView、生成 shader 属性名、属性显示名、UI 标签和表格行也要能看出来源。
- 来源后缀只表示算法来源和迁移责任，不表示继承旧 ABI。
- 旧来源组分不能伪装成 HoNpr 原生通用组分；如果未来重写成 HoNpr 原生行为，应新建或重命名为无来源后缀的正式 block，并保留迁移记录。

禁止执行：

- 把 lilToon 的行为搬入 `MatCap`、`Glitter`、`EmissionSecondary` 这类无来源后缀的模糊 block。
- 只在注释里写来源，实际 ID / UI / 表格看不出来源。
- 用 `LilToon` 后缀作为兼容承诺，继续引入 `_lil*`、旧 inspector、旧 include 或旧 pass 名。

一句话：**组分名必须携带来源责任；来源可追踪，ABI 不继承。**

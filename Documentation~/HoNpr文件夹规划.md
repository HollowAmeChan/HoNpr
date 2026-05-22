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

`HoNpr` 负责：

- 按 HoRP 契约组织材质模板、Feature Block、Preset、生成器和生成产物。
- 生产 `UniversalForward`、`HoUrpAovOutput`、`HoUrpOitAccumulation` 等 HoRP pass 所需 shader。
- 输出 `Material.*`、`Shading.*`、`Aov.*`、`Oit.*` 等上游已登记语义 / 资源所需数据。
- 维护旧材质能力到新组件的对照表和迁移判定。

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
| Generated 目录 | 生成 shader 头部 provenance | 看生成产物来源和是否可手改 | 不放面向用户的索引文档，产物可删除重生 |
| Legacy 对照目录 | `LEGACY_MAPPING_TABLE.md` | 看旧符号迁移到哪里 | 防止旧 ABI 偷偷进入新核心 |
| 资产目录 | `ASSET_TABLE.md` | 看默认贴图/ramp/atlas 用途 | 导入器和校验器读取 |

### 2.2 表格字段要稳定

`FEATURE_BLOCK_TABLE.md` 建议字段：

| 字段 | 说明 |
| --- | --- |
| `Id` | 例如 `MaterialBlock.ToonDiffuseRamp` |
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
| `PresetId` | 例如 `MaterialPreset.Character_Toon_Core` |
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
| `ToonDiffuseRamp` | `DiffuseLobe/` | toon 漫反射 |
| `PbrDiffuse` | `DiffuseLobe/` | PBR 漫反射 |
| `PbrSpecularGGX` | `SpecularLobe/` | 标准 PBR 高光 |
| `ToonSpecular` | `SpecularLobe/` | toon 高光 |
| `HairSpecularPrimary` | `SpecularLobe/` | 发丝主高光 |
| `HairSpecularSecondary` | `SpecularLobe/` | 发丝副高光 |
| `MatCap` | `StylizedLobe/` | 风格化材质光 |
| `RimLight` | `StylizedLobe/` | 加亮边缘 |
| `RimShade` | `StylizedLobe/` | 乘暗边缘 |
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
    Character_Toon_Core.honprpreset
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
| `Character_Toon_Core` | 普通 toon 角色 | `UniversalForward`, `HoUrpAovOutput`, `DepthOnly`, `ShadowCaster` |
| `Character_Skin_SSS` | 皮肤 SSS 生产者 | `UniversalForward`, `HoUrpAovOutput`, `DepthOnly`, `ShadowCaster` |
| `Hair_Toon` | 头发 | `UniversalForward`, `HoUrpAovOutput`, `DepthOnly`, `ShadowCaster` |
| `Environment_PBR` | 场景 PBR 子集 | `UniversalForward`, `DepthOnly`, `ShadowCaster`，AOV 可选 |
| `Transparent_OIT` | OIT 半透明 | `UniversalForward`, `HoUrpAovOutput`, `HoUrpOitAccumulation` |

Preset 只列静态组合。材质实例只能改参数、贴图、ramp、少量 scalar；不能增删 block。

### 3.5 Generator

建议结构：

```text
Generator/
  GENERATOR_RULES.md
  SourceMapping.md
  ValidationRules.md
  HoNprShaderGenerator.cs
  HoNprPresetValidator.cs
```

Generator 必须提供类似 `lilToon` 的编辑器强制刷新按钮。现有 HoToon 小模块已经有 [`Assets/HoNpr/HoToon/[Shader] Refresh shaders`](../Editor/HoNprHoToonEditorUtils.cs)；新生成系统的入口位置应放得接近，避免人和 AI 到处找。

推荐菜单：

```text
Assets/HoNpr/Generator/[Shader] Force regenerate generated shaders
Assets/HoNpr/Generator/[Shader] Refresh generated shader assets
Assets/HoNpr/Generator/[Validation] Validate shader system declarations
Assets/HoNpr/Generator/[Documentation] Rebuild declaration tables
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
- 强制刷新按钮必须重建声明表、执行 DSL 声明校验、重跑生成器、刷新 `Shaders/Generated/`，并通过 `AssetDatabase.ImportAsset(..., ForceUpdate | ForceSynchronousImport)` 导入生成结果。
- 强制刷新不能读取材质 Inspector 当前状态来决定结构；它只能读取 template / block / preset / include registry。

生成产物头部建议：

```text
// 由 HoNprShaderGenerator 生成。
// SourcePreset: MaterialPreset.Character_Toon_Core
// Template: MaterialTemplate.CharacterForward
// Blocks: BaseColorTexture, NormalMap, ToonDiffuseRamp, AovOutputStandard
// 不要手动修改生成体。请改 template / block / preset。
```

### 3.6 LegacyInterop

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
  Assets/
  Validation/
```

| 子目录 | 职责 |
| --- | --- |
| `Materials/` | 材质实例运行时轻量数据，不定义 pass 结构 |
| `Presets/` | ScriptableObject 形式的 preset asset 类型 |
| `Assets/` | ramp atlas、材质贴图集、默认资源引用类型 |
| `Validation/` | 运行时可复用的声明校验逻辑 |

### 5.2 Editor

建议结构：

```text
Editor/
  HoNpr.Editor.asmdef
  Inspectors/
  Generator/
  Importers/
  Validation/
  HoToon/
```

| 子目录 | 职责 |
| --- | --- |
| `Inspectors/` | 轻量 preset/material 面板 |
| `Generator/` | 生成菜单、生成器 editor 入口 |
| `Importers/` | 贴图/ramp/atlas 导入规则 |
| `Validation/` | 表格、preset、generated shader 一致性检查 |
| `HoToon/` | HoToon 小模块 editor 工具，若模块未移动则暂放 |

Editor UI 底线：

- 可以选择 preset。
- 可以显示 block 列表。
- 可以显示 validation 结果。
- 可以编辑少量参数、贴图槽、ramp atlas。
- 不能新增/删除 feature block。
- 不能动态决定 pass 是否存在。
- 不能扫描 inspector 属性反向生成 keyword。

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

---

## 8. 第一阶段落地顺序

1. 建 `Documentation~/`、`ShaderSystem/`、`Shaders/Generated/` 的 README 和 DSL 声明目录。
2. 建 `ShaderSystem/Contract/HORP_CONTRACT_INDEX.md`，链接 RP 侧契约。
3. 建 `ShaderSystem/FeatureBlocks/*.honprblock`，先登记最小原型 blocks。
4. 建 `ShaderSystem/Presets/*.honprpreset`，先登记 `Character_DebugLit_SSS_OITReady`。
5. 建 `ShaderSystem/LegacyInterop/LEGACY_MAPPING_TABLE.md`，冻结旧符号迁移判定。
6. 决定是否移动 HoToon 小模块到 `Modules/HoToon/`。移动前保留 `.meta`，不要破坏 Unity GUID。
7. 再做生成器和第一份 `Generated` shader。

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
- 是否仍然对齐 `HoUrp-Extensions` 的正式契约？

一句话底线：`HoNpr` 的目录不是“shader 文件分类”，而是材质系统的显式声明面。任何生成、模板、迁移、调试入口都必须有表格和链接，让人类和 AI 能在不猜代码的情况下理解它的生产、消费和生命周期。

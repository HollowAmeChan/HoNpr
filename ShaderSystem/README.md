# HoNpr Shader System

这个目录是 HoNpr 材质生成系统的显式声明层。

HoNpr 不定义 HoRP 语义、资源、shader pass 名称或 RenderGraph 生命周期。这些契约来自 `HoUrp-Extensions`；本目录只声明 HoNpr 的模板、功能块、preset、生成 shader 和旧实现映射如何消费上游契约。

## 目录

| 目录 | 职责 |
| --- | --- |
| `Contract/` | 上游 HoRP 材质和 shader 契约的本地索引。 |
| `Includes/` | 功能块声明使用的 include 别名注册表。 |
| `Features/` | 以文件夹作为 feature identity，集中放组分声明、参数、默认值、UI 归属和说明。 |
| `Templates/` | `.honprtemplate` shader pass 骨架声明。pass 结构由模板决定，不由 UI 决定。 |
| `Presets/` | 生成器使用的 `.honprpreset` 静态材质组合。 |
| `MaterialUi/` | `MATERIAL_UI_TABLE.md` 派生浏览表。UI 源声明在 `Features/`。 |
| `Generator/` | 生成器规则、source mapping 策略和 Editor 入口。 |
| `LegacyInterop/` | 旧符号映射和迁移判定。 |

## 规则

每个生成 shader 都必须能从下面这条链路解释：

```text
HoRP contract -> feature folder / block -> template -> preset -> generated shader
```

`Features/**/*.honprblock`、`Features/**/*.honprparams`、`Features/**/*.honprui`、`*.honprtemplate`、`*.honprpreset` 和 `Includes/INCLUDE_REGISTRY.honprinclude` 是人工维护的源声明。材质声明链路不再使用手写 JSON 作为胶水格式。

`TEMPLATE_TABLE.md`、`FEATURE_BLOCK_TABLE.md`、`PRESET_TABLE.md` 和 `MATERIAL_UI_TABLE.md` 由这些源声明自动生成，只用于快速浏览。

## Features

`ShaderSystem/Features/` 以文件夹作为 feature identity。一个 feature 的身份不再由散落在 `FeatureBlocks/`、UI、preset 和 HLSL 里的命名约定拼出。

推荐结构：

```text
Features/<Domain>/<FeatureId>/
  Block.honprblock
  Parameters.honprparams
  Defaults.honprdefaults
  Ui.honprui
```

规则：

- 文件夹名是 feature 的稳定身份边界。
- `Block.honprblock` 声明结构事实、依赖、capability、producer / consumer 和实现入口。
- `Parameters.honprparams` 记录该 feature 拥有的参数、默认值和 semantic。
- `*.honprui` 或 preset UI 文件只能引用 feature 拥有的参数，不能创建 feature 结构。
- 旧 `FeatureBlocks/` 目录已废弃，不能再新增或保留 block 源声明。

已保留说明的 feature：

| Feature | 说明 | 不负责 |
| --- | --- | --- |
| `Debug/DebugLitMinimal` | 调试用 feature family，用于在生产 preset 前验证 HoRP 材质契约。当前连接 `MaterialPreset.Character_DebugLit_SSS_OITReady`、`MaterialTemplate.DebugLitMinimal`、`DebugLitMinimal` 生成器和 `Shaders/Generated/Debug/Character_DebugLit_SSS_OITReady.shader`。 | 用户默认材质入口；反向定义 HoRP AOV / OIT 契约。 |
| `Diffuse/ToonDiffuseRampLilToon` | lilToon 来源的 toon diffuse ramp feature，把 surface、lighting 和 style ramp 输入收敛为 diffuse lobe。 | specular、rim、matcap 等其他 stylized lobe；pass 或 shader 类型选择；ramp atlas 资源生命周期。 |
| `Geometry/OutlineLilToon` | lilToon 来源的几何描边 feature，拥有 outline pass 所需的宽度、纹理、vector map、z bias 和 lighting 参数。 | 是否生成 outline pass；forward pass 中的外观 lobe。 |
| `Semantic/MaterialSemanticProducer` | 材质语义 producer，把材质分类、SSS profile、厚度、曲率和 custom 数据声明为 HoRP material semantic。 | object semantic；AOV RT 绑定；pass 请求解析。 |
| `Surface/BaseColorTexture` | 基础色贴图 feature，拥有 base map、base tint，以及写入 `HoUrpSurfaceData.baseColor` / `alpha` 的入口。 | toon ramp 采样；region / semantic mask；pass 是否存在。 |
| `Stylized/MatCapLilToon` | lilToon 来源的 primary matcap feature，拥有 primary matcap color / mask 参数，并写入 specular lobe。 | secondary matcap；matcap texture atlas 管理；pass 是否存在。 |
| `Stylized/RimLightLilToon` | lilToon 来源的 rim light feature，只声明发光侧 rim lobe。 | rim shade 暗部 lobe；pass 是否存在；outline rim 或后处理描边。 |

## Templates

`ShaderSystem/Templates/` 定义 shader pass 骨架：

- `Character/`：角色材质使用的 forward、AOV、depth、shadow 和 OIT pass 骨架。`CharacterToonLilToonSource.shader.template` 与 `CharacterToonLilToonSourceInline.hlsl.template` 是 lilToon 来源语义的迁移期组装模板，可以生成 `Character_Toon_*` 用户 shader；文件名保留 `LilToonSource`，避免被误读为通用 Character Toon ABI。
- `Environment/`：场景材质使用的 PBR 子集 pass 骨架。
- `Utility/`：debug 和原型 shader 骨架，用于验证 HoRP 材质契约。

## Presets

`ShaderSystem/Presets/` 定义生成器使用的静态材质组合：

- `Character/`：toon、skin fSSS、hair 以及相关角色材质。`Character_LilToonSourceAlgorithmAssembly` 是迁移期原型，参考 lilToon 成品 shader 的 pass 壳和 `lil_pass_forward_normal.hlsl` 的组装顺序，但只使用 HoNpr/HoRP block、pass 和属性命名。长期用户入口不要继续扩张这个大 shader；第一批角色 shader 类型拆为 `Character_Toon_Lite`、`Character_Toon_Standard`、`Character_Toon_Rich`、`Character_Toon_Transparent` 和 `Character_Skin_fSSS`。
- `Debug/`：在生成生产 preset 前验证上游 HoRP 材质契约。
- `Environment/`：场景材质使用的 HoNpr PBR 子集。
- `Transparent/`：显式透明和 OIT-ready 的材质组合。

## Material UI

`*.honprui` 只描述参数如何显示、哪些小工具可以绘制、哪些 HoRP 契约提示需要醒目展示。它不参与 shader 结构、pass、include、define、keyword 或 variant 决策。

UI 源声明放在 `ShaderSystem/Features/**/*.honprui`。`ShaderSystem/MaterialUi/` 只保留 `MATERIAL_UI_TABLE.md` 派生表；该表由 `*.honprui` 自动生成，不要手动编辑表格行。

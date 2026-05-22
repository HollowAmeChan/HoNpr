# 旧实现映射表

旧实现只作为行为参考和迁移辅助，不定义新的 HoNpr ABI。

| 旧符号 | 旧来源 | 新目标 | 判定 | 备注 |
| --- | --- | --- | --- | --- |
| `HoAOV` | [`lilToon` / `lilPBR` passes](../../../HoUrp-Extensions/Documentation~/旧实现快速定位索引.md#10-旧-liltoon-材质侧接入) | `HoUrpAovOutput` | Rename | 不保留旧 pass 名。 |
| `HoAOVSSS` | 旧 SSS source pass | `SssSourceProducer` + `HoUrpAovOutput` | Split | SSS source 是组件，不是第二套旧 pass ABI。 |
| `lilToonOIT` | 旧 OIT pass | `HoUrpOitAccumulation` | Rename | 新 OIT pass 名必须来自 HoRP。 |
| `_lilHoAov*` | 旧 AOV global | `_HoUrpAov*` / resource registry | Cut | 旧 global 名不能进入生成 shader。 |
| `_HoAov*` | 旧材质属性 | `Material.*` / `_HoUrpMaterial*` | Rename | 只有 HoRP 声明过的含义才保留。 |
| `_lilOITActive` | 旧全局 OIT phase 标志 | `MaterialPhasePolicy` / phase policy | Rename | 不作为材质 ABI 暴露。 |
| `lilFragData` | lilToon 单体 fragment 状态 | `HoStandardSurfaceData`, `HoStylizedSurfaceData`, `HoLobeOutput` | Split | 只参考字段。 |
| `ShadingParams` | lilPBR 单体 shading 状态 | `HoStandardSurfaceData`, `HoLightingContext`, `HoLobeOutput` | Split | 只参考公式。 |
| `lil_pass_forward_normal.hlsl` forward 链 | lilToon toon 主链 | `BaseColorTexture`, `NormalMap`, `StyleRampAtlas`, `ToonDiffuseRamp`, `ToonSpecular`, `RimShade`, `RimLight`, `Backlight`, `MatCap`, `EmissionPrimary`, `FinalColorComposite` | Split | 只继承执行经验；不继承单体 fragment state。 |
| `lts.shader` / `ltspass_*.shader` pass 壳 | lilToon 成品 shader 组装 | `Character_LilToonSourceAlgorithmAssembly` | PrototypeOnly | 新 shader 名明确标注源自 lilToon 算法与组合；pass 名改为 HoRP 契约。 |
| `lilGetShading()` shadow 参数族 | lilToon toon shadow | `StyleRampAtlas`, `ToonDiffuseRamp`, `RegionMask` | Compress | 多套 shadow color/border/blur/mask 收敛为 ramp atlas 和少量 preset 参数。 |
| `lilCalcSpecular()` toon specular | lilToon specular | `ToonSpecular`, `HairSpecularPrimary`, `HairSpecularSecondary` | Split | 普通 toon 高光和发丝高光分离。 |
| `lilMatCap` / `lilCalcRim` / emission 层 | lilToon stylized lobes | `MatCap`, `RimLight`, `RimShade`, `Backlight`, `EmissionPrimary` | KeepConcept | lobe 只生产 `HoNprLobeOutput`，不直接写 final color。 |
| `pbr_core.hlsl` `Shading()` | lilPBR 主链 | `BaseColorTexture`, `NormalMap`, `MaterialMapPacked`, `PbrDiffuse`, `PbrSpecularGGX`, `PbrSpecularAnisotropic`, `ClearCoatSpecular`, `FinalColorComposite` | Split | PBR 数学可参考；UI/keyword/channel selector 不继承。 |
| `pbr.hlsl` `SpecularTermAniso()` | lilPBR anisotropy | `PbrSpecularAnisotropic` | KeepConcept | 作为 PBR lobe 子集，不作为材质面板任意开关。 |
| lilPBR clear coat pass-through | lilPBR clear coat | `ClearCoatSpecular` | KeepConcept | 固定 preset 组合，不允许 UI 动态插入 lobe。 |
| lilToon/lilPBR SSAO receive | 旧 forward lighting | `ScreenAoReceiver` | Rename | 作为 LightingInput 写入 `HoNprLightingContext`。 |
| `HoShadowCastAttenuation(positionWS)` | 旧材质 forward 阴影接收 | `HoShadowReceiver` | Rename | 只保留“接收 HoShadow term”的概念；采样资源由 HoRP lighting/shadow 契约约束。 |
| `_ShadowColor*` / `_ShadowBorder*` | lilToon shadow UI | `StyleRampAtlas` + `ToonDiffuseRamp` | Compress | 旧 UI 大量 slider 不进入第一版 HoNpr ABI。 |
| `_SSSThicknessMap` / `_SubsurfaceMap` | lilToon/lilPBR SSS 输入 | `SemanticMap` + `SssSourceProducer` | Rename | forward fake SSS 和 screen-space SSS source 分离。 |
| `_UseAnisotropy` / `_Anisotropy*` | lilToon/lilPBR 各向异性 | `HairSpecularPrimary`, `HairSpecularSecondary`, `PbrSpecularAnisotropic` | Split | 头发 toon 与 PBR anisotropy 不共用一个旧开关。 |
| `_MatCapBlendMode` 等 matcap 混合枚举 | lilToon MatCap UI | `MatCap` preset policy | Cut | 第一版不继承多 blend mode 暴露。 |
| `_lilOITEnabled` | 旧材质 OIT 参与开关 | `SupportsOit`, `ParticipatesOit`, `TransparentComposite`, `OitAccumulationOutput` | Rename | pass 存在由 preset 决定；材质只表达参与参数。 |
| `_Cutoff` / dither transparency | 旧 alpha/cutout | `AlphaClipPolicy`, `TransparentComposite` | Rename | alpha 阈值是参数，不是 pass 结构开关。 |
| Built-in/LWRP/HDRP 分支 | 旧 shader 兼容层 | None | Cut | HoNpr 仅支持 URP。 |
| VRChat/AudioLink/Udon 分支 | 旧兼容层 | None | Cut | 只能作为历史事实记录。 |

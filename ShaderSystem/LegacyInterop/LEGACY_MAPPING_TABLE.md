# 旧实现映射表

旧实现只作为行为参考和迁移辅助，不定义新的 HoNpr ABI。

| 旧符号 | 旧来源 | 新目标 | 判定 | 备注 |
| --- | --- | --- | --- | --- |
| `HoAOV` | lilToon / lilPBR pass | `HoUrpAovOutput` | Rename | 不保留旧 pass 名。 |
| `HoAOVSSS` | 旧 SSS source pass | `SssSourceProducer` + `HoUrpAovOutput` | Split | SSS source 是组分，不是第二套旧 pass ABI。 |
| `lilToonOIT` | 旧 OIT pass | `HoUrpOitAccumulation` | Rename | 新 OIT pass 名来自 HoRP 契约。 |
| `_lilHoAov*` | 旧 AOV global | `_HoUrpAov*` / resource registry | Cut | 旧 global 名不能进入生成 shader。 |
| `_HoAov*` | 旧材质属性 | `Material.*` / `_HoUrpMaterial*` | Rename | 只有 HoRP 声明过的含义才保留。 |
| `_lilOITActive` | 旧全局 OIT phase 标志 | `MaterialPhasePolicy` / phase policy | Rename | 不作为材质 ABI 暴露。 |
| `lilFragData` | lilToon 单体 fragment state | `HoStandardSurfaceData`, `HoStylizedSurfaceData`, `HoLobeOutput` | Split | 只参考字段需求。 |
| `ShadingParams` | lilPBR 单体 shading state | `HoStandardSurfaceData`, `HoLightingContext`, `HoLobeOutput` | Split | 只参考公式。 |
| `lil_pass_forward_normal.hlsl` forward 链 | lilToon toon 主链 | `BaseColorTexture`, `NormalMap`, `StyleRampAtlas`, `ToonDiffuseRampLilToon`, `ToonSpecularLilToon`, `RimShadeLilToon`, `RimLightLilToon`, `BacklightLilToon`, `MatCapLilToon`, `EmissionPrimaryLilToon`, `FinalColorComposite` | Split | 只继承执行经验；不继承单体 fragment state。 |
| `lts.shader` / `ltspass_*.shader` pass 壳 | lilToon 成品 shader 组装 | `Character_LilToonSourceAlgorithmAssembly` | PrototypeOnly | shader 名明确标注源自 lilToon 算法与组合；pass 名改为 HoRP 契约。 |
| `FORWARD_OUTLINE` / `LIL_OUTLINE` / `lil_vert_outline.hlsl` / `OVERRIDE_OUTLINE_COLOR` | lilToon outline pass | `MaterialBlock.OutlineLilToon` + `ForwardOutlineLilToon` | SimplifyFirst | 使用 lilToon 算法变体：外扩、宽度遮罩、vector map、顶点色方向/宽度模式、outline texture、简化 lighting 和 z bias；不引入 lilToon include 或旧属性 ABI。 |
| `lilGetShading()` shadow 参数族 | lilToon toon shadow | `StyleRampAtlas`, `ToonDiffuseRampLilToon`, `RegionMask` | Compress | 多套 shadow color/border/blur/mask 收敛为 ramp atlas 和少量 preset 参数。 |
| `lilCalcSpecular()` toon specular | lilToon specular | `ToonSpecularLilToon`, `HairSpecularPrimary`, `HairSpecularSecondary` | Split | 普通 toon 高光和发丝高光分离。 |
| `lilMatCap` / `lilCalcRim` / emission 层 / `_BackfaceColor` | lilToon stylized lobes | `MatCapLilToon`, `RimLightLilToon`, `RimShadeLilToon`, `BacklightLilToon`, `BackfaceColorLilToon`, `EmissionPrimaryLilToon` | KeepConcept | lobe 只生产 `HoNprLobeOutput`，不直接写 final color；背面策略由 preset/template 固定。 |
| `pbr_core.hlsl` `Shading()` | lilPBR 主链 | `BaseColorTexture`, `NormalMap`, `LilPbrMaterialMapPacked`, `LilPbrDiffuse`, `LilPbrSpecularGGX`, `LilPbrSpecularAnisotropic`, `LilPbrClearCoatSpecular`, `FinalColorComposite` | Split | PBR 数学可参考；UI/keyword/channel selector 不继承。 |
| `pbr.hlsl` `SpecularTermAniso()` | lilPBR anisotropy | `LilPbrSpecularAnisotropic` | KeepConcept | 作为 PBR lobe 子集，不作为材质面板任意开关。 |
| lilPBR clear coat pass-through | lilPBR clear coat | `LilPbrClearCoatSpecular` | KeepConcept | 固定 preset 组合，不允许 UI 动态插入 lobe。 |
| lilToon/lilPBR SSAO receive | 旧 forward lighting | `ScreenAoReceiver` | Rename | 作为 LightingInput 写入 `HoNprLightingContext`。 |
| `HoShadowCastAttenuation(positionWS)` | 旧材质 forward 阴影接收 | `HoShadowReceiver` | Rename | 只保留“接收 HoShadow term”的概念；采样资源由 HoRP lighting/shadow 契约约束。 |
| `_ShadowColor*` / `_ShadowBorder*` | lilToon shadow UI | `StyleRampAtlas` + `ToonDiffuseRampLilToon` | Compress | 旧 UI 大量 slider 不进入第一版 HoNpr ABI。 |
| `_SSSThicknessMap` / `_SubsurfaceMap` | lilToon/lilPBR SSS 输入 | `SemanticMap` + `SssSourceProducer` | Rename | forward fake SSS 和 screen-space SSS source 分离。 |
| `_UseAnisotropy` / `_Anisotropy*` | lilToon/lilPBR anisotropy | `HairSpecularPrimary`, `HairSpecularSecondary`, `LilPbrSpecularAnisotropic` | Split | 头发 toon 与 PBR anisotropy 不共用旧开关。 |
| `_MatCapBlendMode` 等 matcap 混合枚举 | lilToon MatCap UI | `MatCapLilToon` preset policy | Cut | 第一版不继承多 blend mode 暴露。 |
| `_lilOITEnabled` | 旧材质 OIT 参与开关 | `SupportsOit`, `ParticipatesOit`, `TransparentComposite`, `OitAccumulationOutput` | Rename | pass 存在由 preset 决定；材质只表达参与参数。 |
| `_Cutoff` / dither transparency | 旧 alpha/cutout | `AlphaClipPolicy`, `TransparentComposite` | Rename | alpha 阈值是参数，不是 pass 结构开关。 |
| Built-in/LWRP/HDRP 分支 | 旧 shader 兼容层 | None | Cut | HoNpr 仅支持 URP。 |
| VRChat/AudioLink/Udon 分支 | 旧兼容层 | None | Cut | 只能作为历史事实记录。 |

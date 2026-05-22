# Feature Block Table

Each block must explicitly declare domain, stage, inputs, outputs, compatible presets, and variant policy.

| Id | Domain | Stage | Consumes | Produces | Includes | CompatiblePresets | VariantPolicy | DebugViews | LegacyReference | Decision |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `MaterialBlock.BaseColorTexture` | MaterialDomain | SurfaceInput | `BaseMap`, `BaseColorTint` | `HoStandardSurfaceData.baseColor`, `TransparentColor`, `TransparentAlpha` | `HoUrpMaterialSurface.hlsl` | `Character_Toon_Core`, `Character_Skin_SSS`, `Hair_Toon`, `Environment_PBR`, `Transparent_OIT` | PresetStatic | Surface.BaseColor | [`lilToon/lilPBR main textures`](../../../HoUrp-Extensions/Documentation~/材质组分链路对照与HoRP契约草案.md#51-surface-input-组件) | KeepConcept |
| `MaterialBlock.NormalMap` | GeometryDomain | SurfaceInput | `NormalMap`, tangent basis | `HoStandardSurfaceData.normalWS`, `Geometry.WorldNormal` | `HoUrpMaterialSurface.hlsl` | Character and environment presets | PresetStatic | Geometry.Normal | same as above | KeepConcept |
| `MaterialBlock.MaterialMapPacked` | MaterialDomain | SurfaceInput | `MaterialMap` | metallic, roughness, occlusion | `HoUrpMaterialSurface.hlsl` | `Environment_PBR`, optional character presets | PresetStatic | Surface.MaterialMap | [`lilPBR _PBRMap`](../../../HoUrp-Extensions/Documentation~/材质组分链路对照与HoRP契约草案.md#71-pbr-基础) | Rename |
| `MaterialBlock.StyleRampAtlas` | ShadingDomain | SurfaceInput | `StyleRampAtlas` | ramp coordinates / sampled ramp colors | HoNpr stylized include | toon, hair, skin presets | PresetStatic | Style.Ramp | [`lilToon shadow/rim/spec ramp concepts`](../../../HoUrp-Extensions/Documentation~/材质组分链路对照与HoRP契约草案.md#63-ramp-atlas-替代旧参数) | KeepConcept |
| `MaterialBlock.ToonDiffuseRamp` | ShadingDomain | Lobe | surface, lighting, ramp | `HoLobeOutput.diffuse` | HoNpr stylized include | `Character_Toon_Core`, `Character_Skin_SSS`, `Hair_Toon` | PresetStatic | Lobe.Diffuse | lilToon toon shadow | KeepConcept |
| `MaterialBlock.PbrDiffuse` | ShadingDomain | Lobe | surface, lighting | `HoLobeOutput.diffuse` | HoNpr standard include | `Environment_PBR` | PresetStatic | Lobe.Diffuse | lilPBR `GetDiffuse()` | KeepConcept |
| `MaterialBlock.PbrSpecularGGX` | ShadingDomain | Lobe | surface, lighting | `HoLobeOutput.specular` | HoNpr standard include | `Environment_PBR` | PresetStatic | Lobe.Specular | lilPBR `GetSpecular()` | KeepConcept |
| `MaterialBlock.ToonSpecular` | ShadingDomain | Lobe | surface, lighting, ramp | `HoLobeOutput.specular` | HoNpr stylized include | character presets | PresetStatic | Lobe.Specular | lilToon toon specular | KeepConcept |
| `MaterialBlock.HairSpecularPrimary` | ShadingDomain | Lobe | normal, tangent, hair mask | `HoLobeOutput.specular` | HoNpr stylized include | `Hair_Toon` | PresetStatic | Lobe.HairSpecular | lilToon anisotropy primary | KeepConcept |
| `MaterialBlock.HairSpecularSecondary` | ShadingDomain | Lobe | normal, tangent, hair mask | `HoLobeOutput.specular` | HoNpr stylized include | `Hair_Toon` | PresetStatic | Lobe.HairSpecular | lilToon anisotropy secondary | KeepConcept |
| `MaterialBlock.MatCap` | ShadingDomain | Lobe | matcap texture, normal, view | `HoLobeOutput.specular` or stylized output | HoNpr stylized include | character presets | PresetStatic | Lobe.MatCap | lilToon matcap | KeepConcept |
| `MaterialBlock.RimLight` | ShadingDomain | Lobe | normal, view, ramp/mask | `HoLobeOutput.emission` or stylized output | HoNpr stylized include | character presets | PresetStatic | Lobe.Rim | lilToon rim light | KeepConcept |
| `MaterialBlock.RimShade` | ShadingDomain | Lobe | normal, view, ramp/mask | `HoLobeOutput.diffuse` modifier | HoNpr stylized include | character presets | PresetStatic | Lobe.Rim | lilToon rim shade | KeepConcept |
| `MaterialBlock.ForwardThinSss` | ShadingDomain | Lobe | surface, lighting, semantic map | `HoLobeOutput.transmission` | HoNpr subsurface include | `Character_Skin_SSS` | PresetStatic | Lobe.SSS | lilToon fake SSS | Rename |
| `MaterialBlock.SssSourceProducer` | ShadingDomain | SemanticProducer | surface, semantic map | `Shading.SssSourceColor`, `Shading.SssWeight`, `Aov.SssSource` | `HoUrpMaterialAov.hlsl` | `Character_Skin_SSS`, prototype debug preset | PresetStatic | Semantic.SSS | HoAOVSSS source | Rename |
| `MaterialBlock.MaterialSemanticProducer` | MaterialDomain | SemanticProducer | material params, semantic map | `Material.Class`, `Material.SssProfile`, `Material.Thickness`, `Material.Curvature`, `Material.Utility`, `Material.Custom0-3` | `HoUrpMaterialSurface.hlsl` | AOV-capable presets | PresetStatic | Semantic.Material | old HoAOV material fields | Rename |
| `MaterialBlock.AovOutputStandard` | MaterialDomain | SemanticProducer | material semantics, object semantics | `Aov.MaskId`, `Aov.NormalDepth`, `Aov.SurfaceData`, `Aov.MaterialCustom0_3`, `Aov.SssSource` | `HoUrpObjectSemantic.hlsl`, `HoUrpMaterialAov.hlsl` | AOV-capable presets | PresetStatic | AOV.Standard | old HoAOV | Rename |
| `MaterialBlock.OitAccumulationOutput` | CompositeDomain | Transparency | transparent color/alpha/coverage | `OitAccumulationInput`, `OitRevealageInput` | `HoUrpMaterialOit.hlsl` | `Transparent_OIT`, prototype debug preset | PresetStatic | OIT.Accumulation | old `lilToonOIT` | Rename |
| `MaterialBlock.ForwardSkipWhenOit` | CompositeDomain | Transparency | phase policy | forward skip decision | none | `Transparent_OIT` | PresetStatic | OIT.Phase | old `_lilOITActive` behavior | Rename |
| `MaterialBlock.FinalColorComposite` | CompositeDomain | Composite | lobe outputs, transparency | final color / alpha | HoNpr composite include | forward presets | AlwaysCompiled | Composite.FinalColor | old final color chains | KeepConcept |

## Rules

- Lobe blocks must not directly write final color.
- ObjectDomain semantics are read-only for material shaders.
- `MaterialInstanceToggle` is discouraged in the first version.


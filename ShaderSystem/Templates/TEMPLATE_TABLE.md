# 模板表

由 `*.honprtemplate` 自动生成。不要手动编辑表格行。

| 模板 ID | 路径 | Pass | Include 插槽 | 状态 | 说明 |
| --- | --- | --- | --- | --- | --- |
| `MaterialTemplate.CharacterAov` | `ShaderSystem/Templates/Character/CharacterAov.honprtemplate` | `HoUrpAovOutput` | `SurfaceInput`, `SemanticAov` | 已声明 | HoNpr 角色材质的 AOV 输出 pass 骨架。 |
| `MaterialTemplate.CharacterDepth` | `ShaderSystem/Templates/Character/CharacterDepth.honprtemplate` | `DepthOnly` | `SurfaceInput`, `Transparency` | 已声明 | HoNpr 角色材质的 depth pass 骨架。 |
| `MaterialTemplate.CharacterForward` | `ShaderSystem/Templates/Character/CharacterForward.honprtemplate` | `UniversalForward` | `SurfaceInput`, `LightingInput`, `DiffuseLobe`, `SpecularLobe`, `StylizedLobe`, `Subsurface`, `Composite` | 已声明 | HoNpr 角色材质的 forward pass 骨架。 |
| `MaterialTemplate.CharacterOit` | `ShaderSystem/Templates/Character/CharacterOit.honprtemplate` | `HoUrpOitAccumulation` | `SurfaceInput`, `Transparency` | 已声明 | HoNpr 透明角色材质的 OIT 累积 pass 骨架。 |
| `MaterialTemplate.CharacterOutline` | `ShaderSystem/Templates/Character/CharacterOutline.honprtemplate` | `ForwardOutlineLilToonSource` | `SurfaceInput`, `StylizedLobe`, `Transparency` | 已声明 | HoNpr character outline pass shell for lilToon-source algorithm assembly. |
| `MaterialTemplate.CharacterShadow` | `ShaderSystem/Templates/Character/CharacterShadow.honprtemplate` | `ShadowCaster` | `SurfaceInput`, `Transparency` | 已声明 | HoNpr 角色材质的 shadow caster pass 骨架。 |
| `MaterialTemplate.DebugLitMinimal` | `ShaderSystem/Templates/Utility/DebugLit.honprtemplate` | `UniversalForward`, `HoUrpAovOutput`, `HoUrpOitAccumulation` | `SurfaceInput`, `SemanticAov`, `Transparency` | 已生成 | 匹配当前 HoURP 生成材质契约的 HoNpr 原型模板。 |
| `MaterialTemplate.EnvironmentAov` | `ShaderSystem/Templates/Environment/EnvironmentAov.honprtemplate` | `HoUrpAovOutput` | `SurfaceInput`, `SemanticAov` | 已声明 | HoNpr 环境材质的可选 AOV 输出 pass 骨架。 |
| `MaterialTemplate.EnvironmentForward` | `ShaderSystem/Templates/Environment/EnvironmentForward.honprtemplate` | `UniversalForward`, `DepthOnly`, `ShadowCaster` | `SurfaceInput`, `LightingInput`, `DiffuseLobe`, `SpecularLobe`, `Composite` | 已声明 | HoNpr 环境 PBR 子集材质的 forward pass 骨架。 |

# Legacy Mapping Table

Old implementations are behavior references and migration aids. They do not define the new HoNpr ABI.

| OldSymbol | OldSource | NewTarget | Decision | Notes |
| --- | --- | --- | --- | --- |
| `HoAOV` | [`lilToon` / `lilPBR` passes](../../../HoUrp-Extensions/Documentation~/旧实现快速定位索引.md#10-旧-liltoon-材质侧接入) | `HoUrpAovOutput` | Rename | Do not keep old pass name. |
| `HoAOVSSS` | old SSS source pass | `SssSourceProducer` + `HoUrpAovOutput` | Split | SSS source is a component, not a second old pass ABI. |
| `lilToonOIT` | old OIT pass | `HoUrpOitAccumulation` | Rename | New OIT pass name must come from HoRP. |
| `_lilHoAov*` | old AOV globals | `_HoUrpAov*` / resource registry | Cut | Old global names must not enter generated shaders. |
| `_HoAov*` | old material properties | `Material.*` / `_HoUrpMaterial*` | Rename | Keep meaning only where HoRP declares it. |
| `_lilOITActive` | old global OIT phase flag | `MaterialPhasePolicy` / phase policy | Rename | Do not expose as material ABI. |
| `lilFragData` | lilToon monolithic fragment state | `HoStandardSurfaceData`, `HoStylizedSurfaceData`, `HoLobeOutput` | Split | Reference fields only. |
| `ShadingParams` | lilPBR monolithic shading state | `HoStandardSurfaceData`, `HoLightingContext`, `HoLobeOutput` | Split | Reference formulas only. |
| Built-in/LWRP/HDRP branches | old shader compatibility | None | Cut | HoNpr is URP-only. |
| VRChat/AudioLink/Udon branches | old compatibility | None | Cut | Can be documented as legacy facts only. |


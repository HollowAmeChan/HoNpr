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
| Built-in/LWRP/HDRP 分支 | 旧 shader 兼容层 | None | Cut | HoNpr 仅支持 URP。 |
| VRChat/AudioLink/Udon 分支 | 旧兼容层 | None | Cut | 只能作为历史事实记录。 |

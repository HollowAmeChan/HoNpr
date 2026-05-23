# HoURP 联合推进第十四步

> 本文记录 HoNpr 在 HoURP 第十四步中的事实状态、缺口和执行边界。HoNpr 已经有材质大系统；本阶段不是重建它，而是让它真实消费 HoUrp-Extensions 的 runtime。

## 1. 当前事实

HoNpr 已经具备：

- Feature Block DSL：`ShaderSystem/Features/**/*.honprblock`
- Preset DSL：`ShaderSystem/Presets/**/*.honprpreset`
- Template DSL：`ShaderSystem/Templates/**/*.honprtemplate`
- Include alias：`ShaderSystem/Includes/INCLUDE_REGISTRY.honprinclude`
- 上游契约索引：`ShaderSystem/Contract/HORP_CONTRACT_INDEX.md`
- HLSL 实现层：`Shaders/ShaderLibrary/`
- Assembly 层：`Shaders/ShaderLibrary/Assemblies/`
- Generated shader：`Shaders/Generated/`
- Material UI：`Editor/MaterialUi/` 与 `ShaderSystem/MaterialUi/`

当前可审查的 generated shader 包括：

- `HoNpr/Debug/LitSSS_OIT`
- `HoNpr/Character_LilToon_Lite`
- `HoNpr/Character_LilToon_Standard`
- `HoNpr/Character_LilToon_Rich`
- `HoNpr/Character_LilToon_Transparent`
- `HoNpr/Character_LilToon_Skin_fSSS`
- `HoNpr/Hair_LilToon`
- `HoNpr/Environment_LilPBR`

## 2. 已接入 HoURP 的契约

HoNpr generated shader 已经使用：

- `HoUrpAovOutput`
- `HoUrpOitAccumulation`
- `ShadowCaster`
- `HoUrpMaterialSurface.hlsl`
- `HoUrpMaterialAov.hlsl`
- `HoUrpMaterialOit.hlsl`

这表示 AOV、OIT、ShadowCaster、基础 surface / semantic ABI 已经有接入基础。

## 3. 必须修正的边界

### 3.1 fSSS 不是 screen-space SSS

`MaterialPreset.Character_LilToon_Skin_fSSS` 当前用于 forward/fake SSS 验证。它可以包含：

- `MaterialBlock.ForwardThinSss`
- `MaterialBlock.SssSourceProducer`

但它不能作为真 HoURP screen-space SSS runtime 的验收终点。第十四步需要新增清晰身份：

- `MaterialBlock.ScreenSpaceSssSourceProducer`
- `MaterialPreset.Character_LilToon_Skin_SSS`

真 SSS 验收必须确认 `Aov.SssSource` 被 HoURP `SubsurfaceScatteringRendererFeature` 消费。

### 3.2 HoShadowReceiver 不能保持常量占位

当前 HoNpr assembly 中存在：

```hlsl
lighting = HoNprResolveHoShadowReceiver(lighting, 1.0h);
```

第十四步需要改为调用 HoURP ShadowCast sampling：

```hlsl
half hoShadow = HoUrpSampleShadowCastAttenuation(positionWS, normalWS);
lighting = HoNprResolveHoShadowReceiver(lighting, hoShadow);
```

HoCast 必须保留在 `HoNprLightingContext.hoShadow`，不能写入 `mainLightShadow`。

## 4. HoNpr 执行顺序

1. 补 `ScreenSpaceSssSourceProducer` block。
2. 补真 SSS skin preset。
3. 重新生成 feature table、preset table、UI table 和 generated shader。
4. 验证真 SSS preset 通过 AOV SSS source 被 HoURP SSS runtime 消费。
5. 接入 HoShadowReceiver 真 sampling。
6. 重新生成 shader。
7. 扫描 generated shader 与 assembly，确认没有旧 ABI 与占位 receiver。
8. 和 HoUrp-Extensions 一起做 AOV / SSS / OIT / ShadowCast 联合验收。

## 5. 验收底线

- 不手改 generated shader。
- 不把 fSSS 视觉效果当成真 SSS runtime。
- 不 fork HoURP contract。
- 不让 HoNpr 私有风格 block 反向污染 HoURP runtime。
- 不把 HoCast 写入 URP main light shadow。
- 不裸采 ShadowCast atlas；通过 HoURP sampling include 或 wrapper。

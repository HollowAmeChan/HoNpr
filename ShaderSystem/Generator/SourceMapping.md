# 来源映射

每个生成 shader 都必须以来源头开始。

```text
// 由 HoNprShaderGenerator 生成。
// SourcePreset: MaterialPreset.Character_Toon_Core
// Template: MaterialTemplate.CharacterForward
// Blocks: BaseColorTexture, NormalMap, ToonDiffuseRampLilToon, AovOutputStandard
// 不要手动修改生成体。请改 template / block / preset。
```

生成体也应该在模板插槽前后写短注释，方便定位来源：

```text
// <HoNpr:Block MaterialBlock.ToonDiffuseRampLilToon>
...
// </HoNpr:Block MaterialBlock.ToonDiffuseRampLilToon>
```

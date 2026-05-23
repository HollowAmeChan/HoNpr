# DebugLitMinimal

DebugLitMinimal 是调试用 feature family，可以保留硬编码外观和最小 pass 组合，但它的身份仍然属于 feature 文件夹，而不是生成器主体。

当前状态：

- Preset: `MaterialPreset.Character_DebugLit_SSS_OITReady`
- Template: `MaterialTemplate.DebugLitMinimal`
- Generator: `DebugLitMinimal`
- Shader output: `Shaders/Generated/Debug/Character_DebugLit_SSS_OITReady.shader`

重构目标：

- 生成器只选择 `DebugLitMinimal` 组装器。
- shader 主体下沉到 `ShaderSystem/Templates/Utility/` 或 `Shaders/ShaderLibrary/Debug/`。
- Debug 参数和语义留在本 feature 文件夹中说明。

不负责：

- 作为用户默认材质入口。
- 反向定义 HoRP AOV / OIT 契约。

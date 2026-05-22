# HoRP 契约索引

本文件只索引上游 HoRP 材质契约。不要把这些定义复制或 fork 到 HoNpr。

| 契约 | 上游来源 | HoNpr 用途 |
| --- | --- | --- |
| 材质契约注册表 | [`HoUrpMaterialContracts.cs`](../../../HoUrp-Extensions/Runtime/Semantic/HoUrpMaterialContracts.cs) | 原型 template/block/preset 名称。 |
| 功能块定义 | [`MaterialFeatureBlockDefinition.cs`](../../../HoUrp-Extensions/Runtime/Semantic/MaterialFeatureBlockDefinition.cs) | HoNpr block 声明结构。 |
| Preset 定义 | [`MaterialPresetDefinition.cs`](../../../HoUrp-Extensions/Runtime/Semantic/MaterialPresetDefinition.cs) | HoNpr preset 声明结构。 |
| 内置名称 | [`HoUrpBuiltInNames.cs`](../../../HoUrp-Extensions/Runtime/Core/HoUrpBuiltInNames.cs) | 语义、资源、capability、pass 名称。 |
| Shader 属性 ID | [`HoUrpShaderPropertyIds.cs`](../../../HoUrp-Extensions/Runtime/Core/HoUrpShaderPropertyIds.cs) | 稳定 shader 绑定。 |
| 材质 surface ABI | [`HoUrpMaterialSurface.hlsl`](../../../HoUrp-Extensions/Runtime/Shaders/ShaderLibrary/HoUrpMaterialSurface.hlsl) | Surface 和材质数据 ABI。 |
| 材质 AOV ABI | [`HoUrpMaterialAov.hlsl`](../../../HoUrp-Extensions/Runtime/Shaders/ShaderLibrary/HoUrpMaterialAov.hlsl) | AOV 编解码契约。 |
| 材质 OIT ABI | [`HoUrpMaterialOit.hlsl`](../../../HoUrp-Extensions/Runtime/Shaders/ShaderLibrary/HoUrpMaterialOit.hlsl) | OIT 累积契约。 |
| Object semantic ABI | [`HoUrpObjectSemantic.hlsl`](../../../HoUrp-Extensions/Runtime/Shaders/ShaderLibrary/HoUrpObjectSemantic.hlsl) | 对象语义读取契约。 |

## 本地边界

HoNpr 可以增加 wrapper include，用于缩短 include 路径或记录版本假设。wrapper 不能重命名语义、重新解释资源，也不能为 HoRP 契约创建私有替代品。

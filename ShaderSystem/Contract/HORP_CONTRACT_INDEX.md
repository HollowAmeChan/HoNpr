# HoRP Contract Index

This file indexes the upstream HoRP material contract. Do not copy or fork those definitions into HoNpr.

| Contract | Upstream Source | HoNpr Usage |
| --- | --- | --- |
| Material contract registry | [`HoUrpMaterialContracts.cs`](../../../HoUrp-Extensions/Runtime/Semantic/HoUrpMaterialContracts.cs) | Prototype template/block/preset names. |
| Feature block definition | [`MaterialFeatureBlockDefinition.cs`](../../../HoUrp-Extensions/Runtime/Semantic/MaterialFeatureBlockDefinition.cs) | Shape of HoNpr block declarations. |
| Preset definition | [`MaterialPresetDefinition.cs`](../../../HoUrp-Extensions/Runtime/Semantic/MaterialPresetDefinition.cs) | Shape of HoNpr preset declarations. |
| Built-in names | [`HoUrpBuiltInNames.cs`](../../../HoUrp-Extensions/Runtime/Core/HoUrpBuiltInNames.cs) | Semantics, resources, capabilities, pass names. |
| Shader property IDs | [`HoUrpShaderPropertyIds.cs`](../../../HoUrp-Extensions/Runtime/Core/HoUrpShaderPropertyIds.cs) | Stable shader bindings. |
| Material surface ABI | [`HoUrpMaterialSurface.hlsl`](../../../HoUrp-Extensions/Runtime/Shaders/ShaderLibrary/HoUrpMaterialSurface.hlsl) | Surface and material data ABI. |
| Material AOV ABI | [`HoUrpMaterialAov.hlsl`](../../../HoUrp-Extensions/Runtime/Shaders/ShaderLibrary/HoUrpMaterialAov.hlsl) | AOV encode/decode contract. |
| Material OIT ABI | [`HoUrpMaterialOit.hlsl`](../../../HoUrp-Extensions/Runtime/Shaders/ShaderLibrary/HoUrpMaterialOit.hlsl) | OIT accumulation contract. |
| Object semantic ABI | [`HoUrpObjectSemantic.hlsl`](../../../HoUrp-Extensions/Runtime/Shaders/ShaderLibrary/HoUrpObjectSemantic.hlsl) | Object semantic read contract. |

## Local Boundary

HoNpr may add wrapper includes to shorten include paths or document version assumptions. A wrapper must not rename semantics, reinterpret resources, or create private replacements for HoRP contracts.


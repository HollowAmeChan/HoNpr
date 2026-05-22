# HoNpr Shader System

This folder is the explicit declaration surface for HoNpr material generation.

HoNpr does not define HoRP semantics, resources, shader pass names, or RenderGraph lifetimes. Those contracts come from `HoUrp-Extensions`; this folder declares how HoNpr templates, feature blocks, presets, generated shaders, and legacy mappings consume that upstream contract.

## Folders

| Folder | Responsibility |
| --- | --- |
| `Contract/` | Local index of upstream HoRP material and shader contracts. |
| `Templates/` | Shader pass skeletons. Templates decide pass structure, not UI. |
| `FeatureBlocks/` | Material feature block declarations and future block implementations. |
| `Presets/` | Static material combinations used by the generator. |
| `Generator/` | Generator rules, source mapping policy, and editor entry points. |
| `GeneratedManifests/` | Generated shader provenance manifests. |
| `LegacyInterop/` | Old symbol mapping and migration decisions. |

## Rule

Every generated shader must be explainable from:

```text
HoRP contract -> template -> feature blocks -> preset -> generated manifest -> generated shader
```


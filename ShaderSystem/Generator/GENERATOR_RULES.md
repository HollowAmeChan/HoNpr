# Generator Rules

The generator is responsible for structure. Inspectors are responsible only for display and parameter editing.

## Editor Menu

Generator actions must be exposed near the existing HoToon refresh menu:

```text
Assets/HoNpr/Generator/[Shader] Force regenerate generated shaders
Assets/HoNpr/Generator/[Shader] Refresh generated shader assets
Assets/HoNpr/Generator/[Validation] Validate shader system tables
Assets/HoNpr/Generator/[Manifest] Rebuild generated manifests
```

The HoToon menu currently starts at priority `1100`; Generator entries should use `1120-1140`.

## Force Regenerate

The forced regeneration command must:

1. Validate declaration tables.
2. Read templates, feature block declarations, presets, and manifests.
3. Regenerate all shader files listed by active presets.
4. Rebuild generated manifests.
5. Import generated shader assets with `ForceUpdate | ForceSynchronousImport`.
6. Call `AssetDatabase.SaveAssets()` and `AssetDatabase.Refresh()`.

The first generator stage only emits `Character_DebugLit_SSS_OITReady`. Production presets may be declared before they are generated, but they must still pass template/block reference validation.

## Prohibited Inputs

The generator must not read material inspector current state to decide:

- Pass list.
- Feature block list.
- Keyword set.
- Generated shader file path.

Allowed structural inputs:

- `TEMPLATE_TABLE.md`.
- `FEATURE_BLOCK_TABLE.md`.
- `PRESET_TABLE.md`.
- `*.preset.json`.
- generated manifests.
- upstream HoRP contract index.

# Template Table

Templates define shader pass skeletons, include slots, and source mapping comments. Templates do not decide feature combinations.

| TemplateId | Path | Passes | RequiredHoRpPasses | IncludeSlots | Status | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| `MaterialTemplate.CharacterForward` | `Character/CharacterForward.template` | Forward | `UniversalForward` | SurfaceInput, LightingInput, Lobes, Composite | Planned | Character forward skeleton. |
| `MaterialTemplate.CharacterAov` | `Character/CharacterAov.template` | AOV | `HoUrpAovOutput` | SurfaceInput, SemanticAov | Planned | Standard material semantic output. |
| `MaterialTemplate.CharacterDepth` | `Character/CharacterDepth.template` | Depth | `DepthOnly` | SurfaceInput, AlphaClip | Planned | Depth/cutout skeleton. |
| `MaterialTemplate.CharacterShadow` | `Character/CharacterShadow.template` | Shadow | `ShadowCaster` | SurfaceInput, AlphaClip | Planned | Shadow caster skeleton. |
| `MaterialTemplate.CharacterOit` | `Character/CharacterOit.template` | OIT | `HoUrpOitAccumulation` | SurfaceInput, Transparency | Planned | OIT accumulation skeleton. |
| `MaterialTemplate.EnvironmentForward` | `Environment/EnvironmentForward.template` | Forward | `UniversalForward` | SurfaceInput, LightingInput, Lobes, Composite | Planned | Environment PBR subset. |
| `MaterialTemplate.EnvironmentAov` | `Environment/EnvironmentAov.template` | AOV | `HoUrpAovOutput` | SurfaceInput, SemanticAov | Planned | Optional environment AOV output. |
| `MaterialTemplate.DebugLitMinimal` | `Utility/DebugLit.template` | Forward, AOV, OIT | `UniversalForward`, `HoUrpAovOutput`, `HoUrpOitAccumulation` | Prototype | Indexed upstream | Mirrors the current HoURP prototype contract. |

## Rules

- Pass structure comes from template and preset, not from material inspector state.
- Templates must not contain `_lil*`, `_HoAov*`, `HoAOV`, `HoAOVSSS`, or `lilToonOIT`.
- Templates may contain source mapping placeholders for the generator.


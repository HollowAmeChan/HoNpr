# Template Table

Templates define shader pass skeletons, include slots, and source mapping comments. Templates do not decide feature combinations.

| TemplateId | Path | Passes | RequiredHoRpPasses | IncludeSlots | GeneratorStatus | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| `MaterialTemplate.CharacterForward` | `Character/CharacterForward.template` | Forward | `UniversalForward` | SurfaceInput, LightingInput, DiffuseLobe, SpecularLobe, StylizedLobe, Subsurface, Composite | Declared | Character forward skeleton. Not generated yet. |
| `MaterialTemplate.CharacterAov` | `Character/CharacterAov.template` | AOV | `HoUrpAovOutput` | SurfaceInput, SemanticAov | Declared | Standard material semantic output. Not generated yet. |
| `MaterialTemplate.CharacterDepth` | `Character/CharacterDepth.template` | Depth | `DepthOnly` | SurfaceInput, Transparency | Declared | Depth/cutout skeleton. Not generated yet. |
| `MaterialTemplate.CharacterShadow` | `Character/CharacterShadow.template` | Shadow | `ShadowCaster` | SurfaceInput, Transparency | Declared | Shadow caster skeleton. Not generated yet. |
| `MaterialTemplate.CharacterOit` | `Character/CharacterOit.template` | OIT | `HoUrpOitAccumulation` | SurfaceInput, Transparency | Declared | OIT accumulation skeleton. Not generated yet. |
| `MaterialTemplate.EnvironmentForward` | `Environment/EnvironmentForward.template` | Forward | `UniversalForward` | SurfaceInput, LightingInput, DiffuseLobe, SpecularLobe, Composite | Declared | Environment PBR subset. Not generated yet. |
| `MaterialTemplate.EnvironmentAov` | `Environment/EnvironmentAov.template` | AOV | `HoUrpAovOutput` | SurfaceInput, SemanticAov | Declared | Optional environment AOV output. Not generated yet. |
| `MaterialTemplate.DebugLitMinimal` | `Utility/DebugLit.template` | Forward, AOV, OIT | `UniversalForward`, `HoUrpAovOutput`, `HoUrpOitAccumulation` | SurfaceInput, SemanticAov, Transparency | Generated | Mirrors the current HoURP prototype contract. |

## Rules

- Pass structure comes from template and preset, not from material inspector state.
- Templates must not contain `_lil*`, `_HoAov*`, `HoAOV`, `HoAOVSSS`, or `lilToonOIT`.
- Templates may contain source mapping placeholders for the generator.
- `Declared` means the template is a contract manifest and validation target. `Generated` means the current generator can emit a shader from it.

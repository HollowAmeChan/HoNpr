# Validation Rules

Minimum validation set:

| Rule | Failure |
| --- | --- |
| Every preset feature block exists in `FEATURE_BLOCK_TABLE.md`. | Error |
| Every preset template exists in `TEMPLATE_TABLE.md`. | Error |
| Every generated shader has a generated manifest entry. | Error once generator is active |
| Generated shader source must not contain `_lil`, `_HoAov`, `HoAOV`, `HoAOVSSS`, or `lilToonOIT`. | Error |
| Feature block `VariantPolicy` must allow use by the preset. | Error |
| `MaterialInstanceToggle` must be explicitly approved. | Warning |
| Generated shader provenance header must exist. | Error once generator is active |


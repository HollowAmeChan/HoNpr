# HoNpr

HoNpr is Hollow's URP-oriented Unity package for NPR material shaders.

The package is written for Unity `6000.3+`. It intentionally does not declare
`com.unity.render-pipelines.universal` in `package.json`, because the target
workspace uses a locally modified URP package.

## Package Identity

- Package name: `com.hollow.honpr`
- Display name: `HoNpr`
- Author: `Hollow`
- Unity version: `6000.3+`
- Render pipeline target: URP-compatible projects
- Manifest dependencies: none

## Layout

- `Shaders/URP/`: reserved for URP NPR material shader entries.
- `Shaders/ShaderLibrary/`: reserved for shared shader includes.
- `Editor/`: reserved for material inspectors and shader tooling.
- `Samples~/Materials/`: reserved for sample materials.

## Installation

Add the package by local path in the Unity project's `Packages/manifest.json`:

```json
{
  "dependencies": {
    "com.hollow.honpr": "file:D:/Unity_Fork/HoNpr"
  }
}
```

URP must be available in the Unity project, but this package does not force the
URP dependency through its own package manifest.

## Shader Notes

Shader source is intentionally not included yet.

When shader source is added, it can use URP include paths directly while keeping
the package independent at the manifest level.

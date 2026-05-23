# HoNpr

HoNpr 是 Hollow 后续统一 HoRP 材质系统的 Unity 包。NPR 是主方向；PBR 只作为 `HoStandardSurface`、BRDF/PBR lobe、资产导入与退化路径存在，不再拆独立 `HoPbr` 包。

`HoToon` 的 URP 小材质已经合入本包，作为 `HoToon` 小模块保留：它提供现有半调 toon shader、半调贴图和导入工具，用于迁移期快速验证，不代表最终材质系统的完整架构。

本包明确只支持 URP，不支持 Built-in Render Pipeline，也不支持 HDRP。目标 Unity
版本为 `6000.3+`。由于目标工作区使用的是本地魔改版 URP，`package.json` 里刻意
不声明 `com.unity.render-pipelines.universal` 依赖。

## 包信息

- 包名：`com.hollow.honpr`
- 显示名：`HoNpr`
- 作者：`Hollow`
- Unity 版本：`6000.3+`
- 渲染管线：仅 URP
- Manifest 依赖：无

## 目录结构

- `Shaders/`：用于放置 URP-only HoRP 材质 shader 及其共享 include。
- `Shaders/HoToon/URP/`：从独立 `HoToon` 包迁入的 URP-only 半调 toon 小模块。
- `Shaders/ShaderLibrary/StandardSurface/`：规划中的可交换 surface 子集和 PBR lobe 基础。
- `Shaders/ShaderLibrary/StylizedSurface/`：规划中的 toon、hair、rim、matcap、ramp 等 NPR 组件。
- `Shaders/ShaderLibrary/SemanticSurface/`：规划中的 AOV、SSS source、material class、debug producer。
- `Textures/Halftone/`：从 `HoToon` 迁入的半调图案贴图。
- `Editor/`：半调贴图导入设置和刷新工具。

当前可用 shader：

- `HoNpr/HoToon/URP/HalfToon_Outline`

Editor 菜单：

- `Assets > HoNpr > HoToon > [Shader] 刷新 Shader`
- `Assets > HoNpr > HoToon > [贴图] 应用导入设置`
- `Assets > HoNpr > HoToon > [贴图] 选择贴图文件夹`
- `Assets > HoNpr > 生成器 > [材质] 强制刷新 Shader 与材质 UI`

## 安装

在 Unity 项目的 `Packages/manifest.json` 中通过本地路径添加：

```json
{
  "dependencies": {
    "com.hollow.honpr": "file:D:/Unity_Fork/HoNpr"
  }
}
```

项目中需要有可用的 URP，但本包不会通过自己的 manifest 强制声明 URP 依赖，方便
接入本地魔改版 URP。

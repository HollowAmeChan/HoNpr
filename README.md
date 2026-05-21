# HoNpr

HoNpr 是 Hollow 用于存放 NPR 材质 shader 的 Unity 包，面向 URP 项目使用。

本包面向 Unity `6000.3+`。由于目标工作区使用的是本地魔改版 URP，`package.json`
里刻意不声明 `com.unity.render-pipelines.universal` 依赖。

## 包信息

- 包名：`com.hollow.honpr`
- 显示名：`HoNpr`
- 作者：`Hollow`
- Unity 版本：`6000.3+`
- 渲染管线目标：URP 兼容项目
- Manifest 依赖：无

## 目录结构

- `Shaders/URP/`：预留给 URP NPR 材质 shader 入口文件。
- `Shaders/ShaderLibrary/`：预留给共享 shader include。
- `Editor/`：预留给材质 Inspector 和 shader 工具。
- `Samples~/Materials/`：预留给示例材质。

## 安装

在 Unity 项目的 `Packages/manifest.json` 中通过本地路径添加：

```json
{
  "dependencies": {
    "com.hollow.honpr": "file:D:/Unity_Fork/HoNpr"
  }
}
```

项目中需要有可用的 URP，但本包不会通过自己的 manifest 强制声明 URP 依赖。

## Shader 说明

当前仓库暂时不包含 shader 源码。

后续添加 shader 时，可以直接使用 URP include 路径；包层面仍然保持不声明 URP
依赖，方便接入本地魔改版 URP。

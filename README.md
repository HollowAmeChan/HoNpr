# HoNpr

HoNpr 是 Hollow 用于存放 NPR 材质 shader 的 Unity 包。

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

- `Shaders/`：用于放置 URP NPR 材质 shader 及其共享 include。

当前仓库暂时不包含 shader 源码。

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

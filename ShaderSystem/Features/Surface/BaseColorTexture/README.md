# BaseColorTexture

基础色贴图 feature。它拥有 base map、base tint，以及写入 `HoUrpSurfaceData.baseColor` / `alpha` 的入口。

不负责：

- toon ramp 采样。
- region / semantic mask。
- pass 是否存在。

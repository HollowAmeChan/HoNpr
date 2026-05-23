# HoNpr Shader Library

本目录存放 HoNpr feature block 使用的手写 HLSL。

HoRP 材质 ABI 仍归 `HoUrp-Extensions` 管理。本目录文件可以消费上游 HoURP struct 和 helper，但不能重命名 HoRP 语义，也不能为 HoRP 资源创建私有替代品。

Feature block 声明不直接引用这些文件的原始路径，而是从 `ShaderSystem/Includes/INCLUDE_REGISTRY.honprinclude` 请求别名。include 排序、去重以及后续 macro/variant 发射都由生成器负责。

## Assemblies

`Assemblies/` 是预编译组装层，用来把底层实现和内部宏收束成 preset 级具名入口。最终 `Shaders/Generated/*.shader` 可以 include assembly，但不应再次暴露大量 `HONPR_HAS_*` 结构宏或内联大段 fragment 主体。

详细边界见 [`Documentation~/HoNpr材质Shader边界契约.md`](../../Documentation~/HoNpr材质Shader边界契约.md)。

# HoNpr Shader Library

本目录存放 HoNpr feature block 使用的手写 HLSL。

HoRP 材质 ABI 仍归 `HoUrp-Extensions` 管理。本目录文件可以消费上游 HoURP struct 和 helper，但不能重命名 HoRP 语义，也不能为 HoRP 资源创建私有替代品。

Feature block 声明不直接引用这些文件的原始路径，而是从 `ShaderSystem/Includes/INCLUDE_REGISTRY.honprinclude` 请求别名。include 排序、去重以及后续 macro/variant 发射都由生成器负责。

# 校验规则

最小校验集合：

| 规则 | 失败级别 |
| --- | --- |
| 每个 preset 引用的 feature block 都必须存在对应 `*.honprblock` 声明。 | Error |
| 每个 preset 引用的 template 都必须存在对应 `*.honprtemplate` 声明。 | Error |
| 每个 feature block 引用的 include alias 都必须存在于 `ShaderSystem/Includes/INCLUDE_REGISTRY.honprinclude`。 | Error |
| `*.honprblock` 和 `*.honprpreset` 禁止裸写 `#include`、`#define` 和 `#pragma`；block 只能声明式请求 alias、define 和 variant。 | Error |
| `TEMPLATE_TABLE.md`、`FEATURE_BLOCK_TABLE.md` 和 `PRESET_TABLE.md` 由 DSL 派生，不能手动编辑表格行。 | CI 增加表格漂移测试后按 Error 处理 |
| 生成 shader 源码不能包含 `_lil`、`_HoAov`、`HoAOV`、`HoAOVSSS` 或 `lilToonOIT`。 | Error |
| feature block 的 `VariantPolicy` 必须允许当前 preset 使用。 | Error |
| `MaterialInstanceToggle` 必须显式批准后才能使用。 | Warning |
| 生成 shader 必须包含来源头。 | 生成器正式启用后按 Error 处理 |

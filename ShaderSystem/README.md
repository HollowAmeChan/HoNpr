# HoNpr Shader System

这个目录是 HoNpr 材质生成系统的显式声明层。

HoNpr 不定义 HoRP 语义、资源、shader pass 名称或 RenderGraph 生命周期。这些契约来自 `HoUrp-Extensions`；本目录只声明 HoNpr 的模板、功能块、preset、生成 shader 和旧实现映射如何消费上游契约。

## 目录

| 目录 | 职责 |
| --- | --- |
| `Contract/` | 上游 HoRP 材质和 shader 契约的本地索引。 |
| `Includes/` | 功能块声明使用的 include 别名注册表。 |
| `Features/` | 以文件夹作为 feature identity，集中放组分声明、参数、默认值、UI 归属和说明。 |
| `Templates/` | `.honprtemplate` shader pass 骨架声明。pass 结构由模板决定，不由 UI 决定。 |
| `Presets/` | 生成器使用的 `.honprpreset` 静态材质组合。 |
| `MaterialUi/` | `MATERIAL_UI_TABLE.md` 派生浏览表。UI 源声明在 `Features/`。 |
| `Generator/` | 生成器规则、source mapping 策略和 Editor 入口。 |
| `LegacyInterop/` | 旧符号映射和迁移判定。 |

## 规则

每个生成 shader 都必须能从下面这条链路解释：

```text
HoRP contract -> feature folder / block -> template -> preset -> generated shader
```

`Features/**/*.honprblock`、`Features/**/*.honprparams`、`Features/**/*.honprui`、`*.honprtemplate`、`*.honprpreset` 和 `Includes/INCLUDE_REGISTRY.honprinclude` 是人工维护的源声明。材质声明链路不再使用手写 JSON 作为胶水格式。

`TEMPLATE_TABLE.md`、`FEATURE_BLOCK_TABLE.md`、`PRESET_TABLE.md` 和 `MATERIAL_UI_TABLE.md` 由这些源声明自动生成，只用于快速浏览。

# 生成器规则

生成器负责结构；Inspector 只负责显示和参数编辑。

## Editor 菜单

生成器入口需要放在现有 HoToon 刷新菜单附近：

```text
Assets/HoNpr/生成器/[材质] 强制刷新 Shader 与材质 UI
Assets/HoNpr/生成器/[Shader] 刷新生成的 Shader 资源
Assets/HoNpr/生成器/[校验] 校验 Shader 系统声明
Assets/HoNpr/生成器/[文档] 重建声明表
```

HoToon 菜单目前从 priority `1100` 开始；Generator 入口使用 `1120-1140`。

## 强制重新生成

强制重新生成命令必须：

1. 从 HoNpr DSL 重建声明表。
2. 校验 HoNpr DSL 声明。
3. 读取 include 别名、模板、功能块声明和 preset。
4. 重新生成 active preset 列出的所有 shader 文件。
5. 使用 `ForceUpdate | ForceSynchronousImport` 导入生成的 shader 资源。
6. 重建并校验 `MATERIAL_UI_TABLE.md`，刷新材质 UI 描述缓存。
7. 调用 `AssetDatabase.SaveAssets()` 和 `AssetDatabase.Refresh()`。

第一阶段生成器只输出 `Character_DebugLit_SSS_OITReady`。生产 preset 可以先声明、后生成，但仍必须通过 template/block 引用校验。

## 禁止输入

生成器不能读取材质 Inspector 的当前状态来决定：

- Pass 列表。
- 功能块列表。
- Keyword 集合。
- 生成 shader 文件路径。

允许作为结构输入的内容：

- `ShaderSystem/Includes/INCLUDE_REGISTRY.honprinclude`.
- `*.honprtemplate`.
- `*.honprblock`.
- `*.honprpreset`.
- 上游 HoRP 契约索引。

派生文档：

- `TEMPLATE_TABLE.md`.
- `FEATURE_BLOCK_TABLE.md`.
- `PRESET_TABLE.md`.
- `MATERIAL_UI_TABLE.md`.

这些表由 DSL 生成，不能成为第二份事实来源。

## HoNpr DSL

人工维护的声明使用贴近 shader 风格的文本文件，不再使用手写 JSON：

```text
template MaterialTemplate.CharacterForward { ... }
block MaterialBlock.ToonDiffuseRampLilToon : DiffuseLobe in ShadingDomain { ... }
preset MaterialPreset.Character_Toon_Core { ... }
```

功能块可以声明自己需要的 include 别名和 capability define：

```text
requires include HoNpr.ToonLobes;
requires define HONPR_HAS_TOON_DIFFUSE_RAMP;
```

最终 include 顺序、define 发射和 variant 展开都由生成器负责。block 声明里不能直接写裸 `#include`、`#define` 或 `#pragma` 行。

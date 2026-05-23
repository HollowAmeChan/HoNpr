# 生成器规则

生成器负责结构；Inspector 只负责显示和参数编辑。

生成器易错约束另见 [`Documentation~/生成器注释事项.md`](../../Documentation~/生成器注释事项.md)。材质 shader 分层边界另见 [`Documentation~/HoNpr材质Shader边界契约.md`](../../Documentation~/HoNpr材质Shader边界契约.md)。

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
3. 读取 include 别名、feature 文件夹中的功能块声明、模板和 preset。
4. 重新生成 active preset 列出的所有 shader 文件。
5. 使用 `ForceUpdate | ForceSynchronousImport` 导入生成的 shader 资源。
6. 重建并校验 `MATERIAL_UI_TABLE.md`，刷新材质 UI 描述缓存。
7. 调用 `AssetDatabase.SaveAssets()` 和 `AssetDatabase.Refresh()`。

第一阶段生成器先输出 `Character_DebugLit_SSS_OITReady` 和迁移原型 `Character_LilToonSourceAlgorithmAssembly`。

第一批面向用户的 toon 生成目标是：

- `MaterialPreset.Character_Toon_Lite`
- `MaterialPreset.Character_Toon_Standard`
- `MaterialPreset.Character_Toon_Rich`
- `MaterialPreset.Character_Toon_Transparent`

`Character_Toon_Core` 是旧规划遗留的过渡 preset，不能作为新增材质的默认生成目标。生成器后续选择 active preset 时，应优先生成上述四个用途明确的 shader 类型；`Deprecated` preset 只在兼容或回归需求下显式生成。

## 禁止输入

生成器不能读取材质 Inspector 的当前状态来决定：

- Pass 列表。
- 功能块列表。
- Keyword 集合。
- 生成 shader 文件路径。

允许作为结构输入的内容：

- `ShaderSystem/Includes/INCLUDE_REGISTRY.honprinclude`.
- `ShaderSystem/Features/**/*.honprblock`.
- `ShaderSystem/Features/**/*.honprparams`.
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
preset MaterialPreset.Character_Toon_Standard { ... }
```

新 feature 应优先放在文件夹边界里：

```text
ShaderSystem/Features/Stylized/RimLightLilToon/
  README.md
  Block.honprblock
  Parameters.honprparams
```

文件夹就是 feature identity。不要再新增平铺在旧 `FeatureBlocks/` 下的 block；旧目录已废弃。

需要落盘生成 shader 的 preset 必须显式声明生成器，而不是依赖 C# 按 preset 名称白名单选择：

```text
preset MaterialPreset.Character_Toon_Standard {
    templates MaterialTemplate.CharacterForward MaterialTemplate.CharacterOutline MaterialTemplate.CharacterAov;
    generator CharacterToonTemplate;
    ...
}
```

`generator` 只选择组装器；具体 pass、block、assembly、entry、属性和 render state 必须继续来自 `templates` / `blocks` / `passes` / `preset` 声明与模板条件，不能在 C# 中按 `Character_Toon_*`、`Lite`、`Rich` 等名称分支硬编码。

功能块可以声明自己需要的 include 别名和 capability define：

```text
requires include HoNpr.ToonLobes;
requires define HONPR_HAS_TOON_DIFFUSE_RAMP;
```

最终 include 顺序、assembly 选择和 entry 绑定都由生成器负责。block 声明里不能直接写裸 `#include`、`#define` 或 `#pragma` 行。最终 generated shader 不应残留大量 `HONPR_HAS_*` 结构宏；复杂宏和开关应收束在 `Shaders/ShaderLibrary` 或 `Shaders/ShaderLibrary/Assemblies` 内部。

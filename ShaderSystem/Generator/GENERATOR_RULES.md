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
4. 重新生成所有允许落盘的 preset shader 文件。
5. 使用 `ForceUpdate | ForceSynchronousImport` 导入生成的 shader 资源。
6. 重建并校验 `MATERIAL_UI_TABLE.md`，刷新材质 UI 描述缓存。
7. 调用 `AssetDatabase.SaveAssets()` 和 `AssetDatabase.Refresh()`。

当前生成器已经不只输出 `Debug_LitSSS_OIT` 和迁移原型 `Character_LilToon_SourceAssembly`。实际落盘规则是：preset 非 `Deprecated`，并且显式声明了 `generator`，即可生成对应 shader。`Planned` 表示还没按当前阶段的表面标准放行，不表示不会生成。

当前已经有 generated shader 审查产物的主要入口包括：

- `MaterialPreset.Character_LilToon_Lite`
- `MaterialPreset.Character_LilToon_Standard`
- `MaterialPreset.Character_LilToon_Rich`
- `MaterialPreset.Character_LilToon_Transparent`
- `MaterialPreset.Character_LilToon_Skin_fSSS`
- `MaterialPreset.Hair_LilToon`
- `MaterialPreset.Environment_LilPBR`

`Character_LilToon_Core` 是旧规划遗留的过渡 preset，不能作为新增材质的默认生成目标。`Deprecated` preset 只在兼容或回归需求下显式生成。把某个 preset 升级为默认用户入口时，应先把 status 调整为 `Active`，并确认 generated shader、参数模块、UI profile、LegacyInterop 和语义归属在表面上都对得上；每个光照组分的视觉正确性另按后续渲染质量任务处理。

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
block MaterialBlock.LilToonDiffuseRamp : DiffuseLobe in ShadingDomain { ... }
preset MaterialPreset.Character_LilToon_Standard { ... }
```

新 feature 应优先放在文件夹边界里：

```text
ShaderSystem/Features/Stylized/LilToonRimLight/
  Block.honprblock
  Parameters.honprparams
```

文件夹就是 feature identity。不要再新增平铺在旧 `FeatureBlocks/` 下的 block；旧目录已废弃。

Feature leaf 目录必须有 `Block.honprblock`，除非它位于 `Features/PresetUi/` 并只承载 preset UI profile。不要再新增 per-feature `README.md`；跨 feature 的说明放在 `ShaderSystem/README.md`，浏览表由 DSL 自动生成。

需要落盘生成 shader 的 preset 必须显式声明生成器，而不是依赖 C# 按 preset 名称白名单选择：

```text
preset MaterialPreset.Character_LilToon_Standard {
    templates MaterialTemplate.CharacterForward MaterialTemplate.CharacterOutline MaterialTemplate.CharacterAov;
    generator CharacterLilToonTemplate;
    ...
}
```

`generator` 只选择组装器；具体 pass、block、assembly、entry、属性和 render state 必须继续来自 `templates` / `blocks` / `passes` / `preset` 声明与模板条件，不能在 C# 中按 `Character_LilToon_*`、`Lite`、`Rich` 等名称分支硬编码。

`generatedShader` 路径用于审查生成物来源，不作为用户 shader 菜单 ABI。来源型 shader 应在路径里显式标注来源，例如 lilToon 来源角色 shader 写入 `Shaders/Generated/LilToon/`，lilPBR 来源环境 shader 写入 `Shaders/Generated/LilPBR/`。文件名不重复写已经由目录表达的 `Character_`、`Environment_` 前缀。

功能块可以声明自己需要的 include 别名和 capability define：

```text
requires include HoNpr.ToonLobes;
requires define HONPR_HAS_TOON_DIFFUSE_RAMP;
```

最终 include 顺序、assembly 选择和 entry 绑定都由生成器负责。block 声明里不能直接写裸 `#include`、`#define` 或 `#pragma` 行。最终 generated shader 不应输出 `HONPR_HAS_*` 结构宏；复杂宏和开关应收束在 `Shaders/ShaderLibrary` 或 `Shaders/ShaderLibrary/Assemblies` 内部。

当前 `CharacterLilToon` 仍处于迁移期：`Generated/LilToon/*.shader` 只 include 对应具名 assembly；具名 assembly 自己声明 `HONPR_HAS_*`，其中仍有一部分结构由 shared assembly 宏裁剪。后续工作应优先把这些差异下沉到 Lite / Standard / Rich / Transparent / Skin / Hair 等具名 assembly，减少 shared assembly 内部条件分支。

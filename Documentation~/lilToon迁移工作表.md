# lilToon 迁移工作表

> 这张表用于跟踪 `lilToon` 能力迁移到 `HoNpr` 的进度。这里的“迁移”只表示能力和算法经验进入 HoNpr 的模板、Feature Block、Preset、生成 shader 或 UI descriptor；不表示继承 lilToon 的旧 ABI、旧属性名、旧 inspector、旧 include 或多管线兼容层。

## 迁移边界

- 目标包：`D:\Unity_Fork\HoNpr`
- 旧参考：`D:\Unity_Fork\lilToon`
- RP 契约事实来源：`D:\Unity_Fork\HoUrp-Extensions`
- 新材质结构：`ShaderSystem/Templates`、`ShaderSystem/FeatureBlocks`、`ShaderSystem/Presets`、`Shaders/ShaderLibrary`、`Shaders/Generated`
- 禁止直接搬运：`_lil*`、`HoAOV`、`HoAOVSSS`、`lilToonOIT`、旧 inspector 反射逻辑、Built-in/LWRP/HDRP/VRC 兼容分支

## 组分来源命名规则

从旧实现迁移来的组分，来源必须进入组分身份，而不是只写在注释里：

- Feature Block ID 必须带来源后缀，例如 `SecondaryMatCapLilToon`、`GlitterLilToon`。
- Entry 函数、DebugView、生成 shader 属性名、属性显示名和 UI 标签也要能看出来源，例如 `HoNprEvaluateGlitterLilToon`、`Lobe.GlitterLilToon`、`_HoNprGlitterLilToonColor`、`Glitter-lilToon Color`。
- 只有已经重写为 HoNpr 原生、并且不再以某个旧实现行为为验收基线的组分，才允许去掉来源后缀。
- 来源后缀不是兼容承诺。`LilToon` 表示算法来源和迁移参考，不表示继承 lilToon 的 ABI、属性名、inspector 或 include。
- 如果一个通用概念既有 HoNpr 原生版本又有旧实现迁移版本，必须拆成两个 block，例如 `MatCap` 和 `SecondaryMatCapLilToon`，不能用一个模糊 block 同时承担两种身份。

## 工作表

| 序号 | lilToon 来源能力 | 旧参考入口 | HoNpr 目标 | 迁移方式 | 状态 | 当前落点 |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | Forward 主链路顺序 | `lil_pass_forward_normal.hlsl` | `Character_LilToonSourceAlgorithmAssembly` preset / generated shader | 按 HoNpr lobe 顺序重组，不继承 `lilFragData` | 已开始 | `ShaderSystem/Presets/Character/Character_LilToonSourceAlgorithmAssembly.honprpreset` |
| 2 | Toon shadow ramp | `lil_common_frag.hlsl` / `lilGetShading` | `ToonDiffuseRampLilToon` + `StyleRampAtlas` | 保留 ramp 思路，裁剪大量 `_Shadow*` slider | 已开始 | `HoNprToonLobes.hlsl` |
| 3 | Toon specular | `lilCalcSpecular` | `ToonSpecularLilToon` | 作为独立 specular lobe | 已开始 | `HoNprToonLobes.hlsl` |
| 4 | Outline | `FORWARD_OUTLINE` / `lil_vert_outline.hlsl` | `OutlineLilToon` | 迁移几何外扩和 outline lighting 经验，改 HoNpr 属性 | 已开始 | `HoNprOutline.hlsl` |
| 5 | MatCap 1 | `lilCalcMatCap` | `MatCapLilToon` | 作为 stylized specular lobe | 已开始 | `HoNprStylizedLobes.hlsl` |
| 6 | MatCap 2 | `lilCalcMatCap` second layer | `SecondaryMatCapLilToon` | 作为第二 stylized lobe，默认弱化 | 本轮开始 | `StylizedLobe/SecondaryMatCapLilToon.honprblock` |
| 7 | Rim light / rim shade | rim / rim shade block | `RimLightLilToon` / `RimShadeLilToon` | 拆成 emission 和 negative diffuse lobe | 已开始 | `HoNprStylizedLobes.hlsl` |
| 8 | Backlight | backlight block | `BacklightLilToon` | 作为 emission lobe | 已开始 | `HoNprStylizedLobes.hlsl` |
| 9 | Emission 1 | emission block | `EmissionPrimaryLilToon` | 作为 emission lobe | 已开始 | `HoNprStylizedLobes.hlsl` |
| 10 | Emission 2 | second emission block | `EmissionSecondaryLilToon` | 保留第二层概念，不继承旧 blend mode 爆炸 | 本轮开始 | `StylizedLobe/EmissionSecondaryLilToon.honprblock` |
| 11 | Glitter | glitter block | `GlitterLilToon` | 先做程序化 sparse lobe；后续再决定贴图/噪声输入 | 本轮开始 | `StylizedLobe/GlitterLilToon.honprblock` |
| 12 | Distance fade | distance fade block | `DistanceFadeLilToon` | 作为 composite/lobe 调制输入；不暴露旧 render state | 本轮开始 | `StylizedLobe/DistanceFadeLilToon.honprblock` |
| 13 | Backface color | `_BackfaceColor` / facing branch | `BackfaceColorLilToon` | 保留双面着色概念；pass/cull 策略仍由 preset/template 固定，不开放旧 render state UI | 本轮开始 | `StylizedLobe/BackfaceColorLilToon.honprblock` |
| 14 | Forward fake SSS | `lilSSS()` | `ForwardThinSss` | 与 screen-space SSS source producer 分离 | 已登记 | `Subsurface/ForwardThinSss.honprblock` |
| 15 | HoAOV 输出 | `lil_pass_hoaov.hlsl` | `HoUrpAovOutput` + `AovOutputStandard` | 改用 HoRP 正式语义和资源名 | 已开始 | `SemanticAov/AovOutputStandard.honprblock` |
| 16 | OIT 输出 | `lil_oit.hlsl` | `HoUrpOitAccumulation` + `OitAccumulationOutput` | 改名并使用 HoRP phase policy | 已开始 | `Transparency/OitAccumulationOutput.honprblock` |
| 17 | Refraction / refblur | refraction / refblur pass | `RefractionLobe` 或 `TransparentRefraction` | 需要 RP 侧资源输入确认后再做 | 待评估 | 未落地 |
| 18 | Fur | fur forward pass | `FurShell` / `HairShell` | 涉及几何/多 pass，先不塞进普通 lobe | 待评估 | 未落地 |
| 19 | Gem | gem forward pass | `GemSurface` | 作为独立 preset 候选 | 待评估 | 未落地 |
| 20 | Fake shadow | fake shadow pass | `CharacterFakeShadow` | 更接近角色 composite/lighting policy，先不进材质核心 | 待评估 | 未落地 |
| 21 | lilToon shader 家族拆分 | `ltsl*` / `lts*` / `*_trans` / `ltsmulti*` | `Character_Toon_Lite` / `Character_Toon_Standard` / `Character_Toon_Rich` / `Character_Toon_Transparent` | 用少量用途明确 preset 替代单个宽泛 shader；UI descriptor 只声明参数白名单，不决定结构 | 本轮开始 | `ShaderSystem/Presets/Character/Character_Toon_*.honprpreset`、`ShaderSystem/MaterialUi/Character/Character_Toon_*.honprui` |

## 本轮执行范围

本轮已推进第 6、10、11、12、13 项，并开始第 21 项：

- 新增 `SecondaryMatCapLilToon`、`EmissionSecondaryLilToon`、`GlitterLilToon`、`DistanceFadeLilToon`、`BackfaceColorLilToon` Feature Block 声明。
- 在 `HoNprStylizedLobes.hlsl` 中补对应 lobe 函数。
- 把 `Character_LilToonSourceAlgorithmAssembly` 原型 preset / generated shader 接入这些 block 和参数。
- 更新原型 UI descriptor，不改旧 ABI，不接 lilToon include，不把 UI 作为结构来源。
- 新增 `Character_Toon_Lite`、`Character_Toon_Standard`、`Character_Toon_Rich`、`Character_Toon_Transparent` 的 preset / UI descriptor 声明。
- 将 `Character_Toon_Core` 降级为兼容/过渡 preset，避免它继续作为新增材质的主入口。

## 下一轮候选

1. `Refraction`：需要先确认 HoRP 侧 camera color copy / transparent resource 读取契约，避免 shader 私读 camera color。
2. `Fur`：应作为几何/多 pass preset，而不是普通 stylized lobe。
3. `Gem`：应作为独立 preset 候选，避免把折射、反射和透明策略塞进普通 character lobe。

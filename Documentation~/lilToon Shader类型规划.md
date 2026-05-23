# lilToon Shader 类型规划

> 目的：把 lilToon 的 shader 家族和开关组合，压缩成 HoNpr 可维护的 shader 类型。HoNpr 不按每个 UI 开关生成一个 shader；需要把常用能力打包成少量明确用途的 preset / generated shader。

## 结论

现有 `Character_LilToonSourceAlgorithmAssembly` 是迁移期厨房水槽原型，名字和能力边界都不适合作为用户长期选择的 shader。它应保留为对照和回归验证用，不应成为默认材质入口。

HoNpr 需要新增两层声明：

- **用户 shader 类型**：以 HoNpr 语义命名，例如 `Character_Toon_Lite`、`Character_Toon_Standard`、`Character_Toon_Rich`。
- **来源组分**：继续显式带来源后缀，例如 `ToonDiffuseRampLilToon`、`MatCapLilToon`、`GlitterLilToon`。

也就是说，shader 名可以是 HoNpr 的用途名；block / entry / DebugView / shader property 仍然保留 `LilToon` 来源身份。

## lilToon 文件族归纳

| lilToon 文件族 | 代表文件 | 组合意图 | HoNpr 处理 |
| --- | --- | --- | --- |
| Lite | `ltsl*.shader`、`ltspass_lite_*` | 轻量 toon：主色、shadow、少量 matcap/rim/emission | 做 `Character_Toon_Lite` |
| Standard | `lts*.shader`、`ltspass_opaque/cutout/transparent` | 常规角色 toon：多 stylized lobe、outline、透明模式、dissolve、AOV 等 | 拆成 `Character_Toon_Standard`、`Character_Toon_Rich`、透明专用 shader |
| Multi | `ltsmulti*.shader` | 多层主色/多组材质表达，比 Standard 更宽 | 不直接做成默认；作为 `Character_Toon_Rich` 或后续 `LayeredToon` 的来源 |
| Outline variants | `*_o.shader`、`*_oo.shader` | 轮廓是否参与主 shader 的结构组合 | HoNpr 不做 UI 开关；拆成带 outline 的 preset |
| Transparency variants | `*_trans`、`*_onetrans`、`*_twotrans`、`*_overlay` | 透明渲染路径和 pass 数不同 | 拆成透明 shader 类型，不用一个 shader 运行时切换 |
| Refraction | `lts_ref*`、`ltsmulti_ref` | 折射/模糊折射，需要 camera color 输入 | 等 HoRP 资源契约明确后做 `Character_Toon_Refraction` |
| Fur | `lts_fur*`、`ltsmulti_fur` | fur shell / 多 pass 几何效果 | 做独立 `Character_FurShell`，不塞进普通 toon |
| Gem | `lts_gem`、`ltsmulti_gem` | 宝石/玻璃类特化材质 | 做独立 `Character_Gem` |
| Tessellation | `lts_tess*`、`ltspass_tess_*` | 细分版本 | 先不迁移；Unity/URP 版本和平台边界单独评估 |
| Fake shadow | `lts_fakeshadow` | 投影/角色影子辅助 | 做独立 utility shader，不混入角色主材质 |
| Hidden pass shaders | `ltspass_*` | pass 复用壳 | HoNpr 用 template/preset 表达，不继承 hidden shader 壳 |

## HoNpr 第一批 Shader 类型

| HoNpr preset | 目标 shader 名 | 用途 | 包含能力 | 不包含能力 |
| --- | --- | --- | --- | --- |
| `MaterialPreset.Character_Toon_Lite` | `HoNpr/Character/Toon_Lite` | 低成本角色/配件 toon | Base、Normal、Ramp Diffuse、Main/Indirect/AO、RimLight、Primary Emission、AOV、Depth、Shadow | Outline、secondary matcap、glitter、distance fade、OIT |
| `MaterialPreset.Character_Toon_Standard` | `HoNpr/Character/Toon_Standard` | 默认角色 toon | Lite + ToonSpecular、RimShade、Backlight、MatCap、Outline、Semantic/AOV | Glitter、secondary matcap、secondary emission、distance fade、OIT |
| `MaterialPreset.Character_Toon_Rich` | `HoNpr/Character/Toon_Rich` | 需要 lilToon 风格完整外观的角色 | Standard + SecondaryMatCap、Glitter、SecondaryEmission、DistanceFade、BackfaceColor | Refraction、Fur、Gem |
| `MaterialPreset.Character_Toon_Transparent` | `HoNpr/Character/Toon_Transparent` | 半透明 toon | Standard 核心 + AlphaClip/TransparentComposite/OIT 输出 | Refraction blur、fur、gem |
| `MaterialPreset.Character_Skin_SSS` | `HoNpr/Character/Skin_SSS` | 皮肤/SSS 角色材质 | 现有 skin SSS preset，后续合并命名 | Glitter、fur、gem |
| `MaterialPreset.Hair_Toon` | `HoNpr/Character/Hair_Toon` | 头发 toon | 现有 hair specular 双 lobe | Gem、refraction |

## 第二批候选

| HoNpr preset | 依赖 | 说明 |
| --- | --- | --- |
| `MaterialPreset.Character_Toon_Refraction` | HoRP camera color / transparent input contract | 需要明确资源读取，不允许 shader 私自读 camera color |
| `MaterialPreset.Character_FurShell` | Fur shell template / pass policy | 是几何和 pass 问题，不是普通 lobe |
| `MaterialPreset.Character_Gem` | Gem surface block / transparent policy | 作为独立材质族 |
| `MaterialPreset.Character_FakeShadow` | Utility template | 角色辅助投影，不作为主材质 |
| `MaterialPreset.Character_Toon_Layered` | 多主色层 block | 如果 Multi 需求明确，再做分层材质 |

## 默认参数规则

lilToon 通过 UI 开关隐藏/显示大量能力；HoNpr 不让 UI 开关决定 shader 结构。因此默认参数必须符合 preset 名称：

- Lite：默认关闭昂贵 stylized lobe，只有基础 toon 外观。
- Standard：默认能得到完整常规角色 toon，但二级/特效 lobe 不存在。
- Rich：可以默认存在二级/特效 lobe，但强度为 0，不作为变体开关。
- Transparent：透明路径由 preset 固定，不由 `_TransparentMode` 之类参数切换。
- Refraction/Fur/Gem：必须独立 shader，不作为 `Character_Toon_Rich` 的 UI 开关。

## 迁移执行顺序

1. 先新增 `Character_Toon_Lite`、`Character_Toon_Standard`、`Character_Toon_Rich`、`Character_Toon_Transparent` preset 声明。
2. 把 `Character_LilToonSourceAlgorithmAssembly` 标为 migration prototype，不再作为默认目标。
3. 生成器后续按 preset 生成对应 shader，而不是继续扩张单个大 shader。
4. 再评估 Refraction/Fur/Gem 的 template 和 HoRP 资源依赖。

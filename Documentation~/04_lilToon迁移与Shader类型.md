# lilToon 迁移与 HoNpr Shader 类型

本文定义 lilToon 来源能力如何进入 HoNpr。迁移目标不是复刻 lilToon shader 家族，而是把来源能力收敛成 HoNpr 的长期类型。

## 迁移原则

1. Shader 名称使用 HoNpr 用途语义。
2. Block 名称保留来源身份，例如 `MatCapLilToon`。
3. 旧 property / keyword 只进入 `LegacyInterop` 映射，不成为新 ABI。
4. 旧 hidden pass shader 不继承，改由 template / preset 表达。
5. 会改变 pass 或资源依赖的能力必须成为独立 preset。
6. 迁移原型可以存在，但必须标记为 prototype，不能成为默认入口。

## 当前迁移定位

`MaterialPreset.Character_LilToonSourceAlgorithmAssembly` 是迁移验证原型。

用途：

- 对照 lilToon 算法行为。
- 回归测试来源 block。
- 帮助确认迁移差异。

限制：

- 不作为用户默认 shader。
- 不作为新增材质入口。
- 不作为长期命名范式。
- 不把所有 lilToon 能力打包成 HoNpr 的最终结构。

## lilToon 文件族归类

| lilToon 来源 | 典型含义 | HoNpr 处理 |
| --- | --- | --- |
| Lite | 轻量 toon，基础色、阴影、少量 rim / emission | 收敛到 `Character_Toon_Lite`。 |
| Standard | 常规角色 toon，多 stylized lobe、outline、AOV | 拆成 `Character_Toon_Standard`、`Character_Toon_Rich`、透明专用类型。 |
| Multi | 多层主色或多层材质表达 | 先不作为默认；后续按需求进入 `Character_Toon_Layered`。 |
| Outline variants | 是否带轮廓 pass | 由 preset 固定，不做 UI 结构开关。 |
| Transparent variants | 透明路径和 pass 数不同 | 独立为 `Character_Toon_Transparent` 或更专用类型。 |
| Refraction | 依赖 camera color 或透明输入 | 等 HoRP 资源契约明确后做 `Character_Toon_Refraction`。 |
| Fur | fur shell / 多 pass 几何效果 | 独立为 `Character_FurShell`。 |
| Gem | 宝石、玻璃特化材质 | 独立为 `Character_Gem`。 |
| Tessellation | 细分版本 | 暂不迁移，需单独评估 Unity/URP 平台边界。 |
| Fake shadow | 角色辅助阴影 | 独立 utility shader，不混入主材质。 |
| Hidden pass shaders | pass 复用壳 | 用 template / preset 表达，不继承旧壳。 |

## 第一批用户 shader 类型

| Preset | Shader | 用途 | 应包含 | 不包含 |
| --- | --- | --- | --- | --- |
| `MaterialPreset.Character_Toon_Lite` | `HoNpr/Character_Toon_Lite` | 低成本角色或配件 toon | BaseColor、Normal、Ramp Diffuse、Main Light、Indirect、AO、RimLight、PrimaryEmission、AOV、Depth、Shadow | Outline、SecondaryMatCap、Glitter、DistanceFade、OIT |
| `MaterialPreset.Character_Toon_Standard` | `HoNpr/Character_Toon_Standard` | 默认角色 toon | Lite + ToonSpecular、RimShade、Backlight、MatCap、Outline、Semantic/AOV | Glitter、SecondaryMatCap、SecondaryEmission、DistanceFade、OIT |
| `MaterialPreset.Character_Toon_Rich` | `HoNpr/Character_Toon_Rich` | 完整 stylized 角色外观 | Standard + SecondaryMatCap、Glitter、SecondaryEmission、DistanceFade、BackfaceColor | Refraction、Fur、Gem |
| `MaterialPreset.Character_Toon_Transparent` | `HoNpr/Character_Toon_Transparent` | 半透明 toon | Standard 核心 + AlphaClip、TransparentComposite、OIT 输出 | Refraction blur、Fur、Gem |
| `MaterialPreset.Character_Skin_SSS` | `HoNpr/Character_Skin_SSS` | 皮肤或 SSS 角色材质 | SSS source、thin SSS、semantic/AOV | Glitter、Fur、Gem |
| `MaterialPreset.Hair_Toon` | `HoNpr/Hair_Toon` | 头发 toon | HairSpecularPrimary、HairSpecularSecondary、toon diffuse、rim、AOV | Gem、Refraction |
| `MaterialPreset.Environment_PBR` | `HoNpr/Environment_PBR` | 场景 PBR | PBR diffuse、GGX、anisotropic、clear coat、AOV | 角色 stylized lobe |

## 第二批候选

| Preset | 前置条件 | 说明 |
| --- | --- | --- |
| `MaterialPreset.Character_Toon_Refraction` | HoRP camera color / transparent input contract 明确 | shader 不能私自读取未声明 camera color。 |
| `MaterialPreset.Character_FurShell` | Fur shell template 和 pass policy 明确 | 几何和 pass 问题，不是普通 lobe。 |
| `MaterialPreset.Character_Gem` | Gem surface 和 transparent policy 明确 | 独立材质，不混入 Rich。 |
| `MaterialPreset.Character_FakeShadow` | Utility template 明确 | 角色辅助投影，不作为主材质。 |
| `MaterialPreset.Character_Toon_Layered` | 多层材质需求明确 | 从 Multi 来源迁移，先证明需求再实现。 |

## 默认参数规则

HoNpr 的默认参数必须符合 preset 名称：

- Lite 默认表现为基础 toon，不暗含高级 lobe。
- Standard 默认能得到常规完整角色 toon。
- Rich 可以包含二级或特效 lobe，但默认强度可以为 0；结构仍由 preset 固定。
- Transparent 的透明路径由 preset 固定，不用 `_TransparentMode` 切换结构。
- Refraction、Fur、Gem 必须独立 shader，不作为 Rich 的 UI toggle。

## 迁移映射规则

旧符号处理：

- 旧 property 进入 `ShaderSystem/LegacyInterop/LEGACY_MAPPING_TABLE.md`。
- 新 property 应使用 HoNpr 语义命名。
- 旧 keyword 只用于导入时判断来源，不写入新 shader 结构。
- 旧 shader 名只用于选择迁移目标 preset。

Block 命名：

- 来源型 block 可以带 `LilToon` 后缀。
- 用户 shader 和 preset 不带 `LilToon`，除非它是 prototype。
- 如果算法被重写为 HoNpr 原生语义，可以新增不带来源后缀的 block。

## 执行顺序

1. 保留 `Character_LilToonSourceAlgorithmAssembly` 作为 prototype。
2. 维护四个第一批用户 toon preset：Lite、Standard、Rich、Transparent。
3. 为每个用户 preset 维护对应 `.honprui` 白名单。
4. 生成器只生成 active 或显式指定的 prototype。
5. 把大模板中的算法主体逐步下沉到 ShaderLibrary / Assembly。
6. 在 `LegacyInterop` 中补齐旧 property 到新参数的迁移规则。
7. 再评估 Refraction、Fur、Gem、Layered 等第二批类型。

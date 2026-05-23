# 角色 Preset

角色 preset 定义 toon、skin SSS、hair 以及相关角色材质的静态 block 组合。

`Character_LilToonSourceAlgorithmAssembly` 是迁移期原型：它参考 lilToon 成品 shader 的 pass 壳和 `lil_pass_forward_normal.hlsl` 的组装顺序，但只使用 HoNpr/HoRP block、pass 和属性命名。

长期用户入口不要继续扩张这个大 shader。第一批角色 shader 类型拆为：

- `Character_Toon_Lite`：低成本 toon，接近 lilToon Lite 的组合意图。
- `Character_Toon_Standard`：默认角色 toon，包含 outline 和常用 stylized lobe。
- `Character_Toon_Rich`：完整 stylized 角色材质，包含二级 matcap、glitter、二级 emission、distance fade、backface color。
- `Character_Toon_Transparent`：透明/OIT 专用 toon，不通过 UI 开关切透明结构。

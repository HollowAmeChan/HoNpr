# 角色模板

角色材质模板定义 HoRP 角色 shader 使用的 forward、AOV、depth、shadow 和 OIT pass 骨架。

`CharacterToonLilToonSource.shader.template` 和 `CharacterToonLilToonSourceInline.hlsl.template` 是 lilToon 来源语义的迁移期组装模板。它们可以生成 `Character_Toon_*` 用户 shader，但文件名必须保留 `LilToonSource`，避免把来源算法误读为通用 Character Toon ABI。

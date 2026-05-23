# Material UI

本目录存放 HoNpr 材质 Inspector 的极简 UI 声明。

`*.honprui` 只描述参数如何显示、哪些小工具可以绘制、哪些 HoRP 契约提示需要醒目展示。它不参与 shader 结构、pass、include、define、keyword 或 variant 决策。

UI 源声明放在 `ShaderSystem/Features/**/*.honprui`。本目录只保留 `MATERIAL_UI_TABLE.md` 派生表和说明。

`MATERIAL_UI_TABLE.md` 由 `*.honprui` 自动生成。不要手动编辑表格行。

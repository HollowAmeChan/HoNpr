# Feature 文件夹契约

`ShaderSystem/Features/` 以文件夹作为 feature identity。一个 feature 的身份不再由散落在 `FeatureBlocks/`、UI、preset 和 HLSL 里的命名约定拼出来。

推荐结构：

```text
Features/<Domain>/<FeatureId>/
  README.md
  Block.honprblock
  Parameters.honprparams
  Defaults.honprdefaults
  Ui.honprui
```

当前生成器会扫描 `Features/**/*.honprblock` 和旧 `FeatureBlocks/**/*.honprblock`。迁移期内，旧目录仍可保留未迁移 block；一旦某个 block 迁入 `Features/`，旧目录中不能再保留同 ID 的副本。

规则：

- 文件夹名就是 feature 的稳定身份边界。
- `Block.honprblock` 声明结构事实、依赖、capability、producer / consumer 和实现入口。
- `Parameters.honprparams` 记录该 feature 拥有的参数、默认值和 semantic。
- `Ui.honprui` 或 preset UI 文件只能引用 feature 拥有的参数，不能创造 feature 结构。
- README 解释来源、用途、迁移状态和不负责事项。

using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using UnityEditor;
using UnityEngine;

namespace Hollow.HoNpr.Editor
{
    internal static class HoNprGeneratorEditorUtils
    {
        private const string MenuPathAssets = "Assets/HoNpr/Generator/";
        private const string MenuPathForceRegenerate = MenuPathAssets + "[Shader] Force regenerate generated shaders";
        private const string MenuPathRefreshGenerated = MenuPathAssets + "[Shader] Refresh generated shader assets";
        private const string MenuPathValidateDeclarations = MenuPathAssets + "[Validation] Validate shader system declarations";
        private const string MenuPathRebuildDeclarationTables = MenuPathAssets + "[Documentation] Rebuild declaration tables";
        private const int MenuPriorityGenerator = 1120;
        private const int MenuPriorityRefresh = MenuPriorityGenerator + 1;
        private const int MenuPriorityValidation = MenuPriorityGenerator + 10;
        private const int MenuPriorityDocumentation = MenuPriorityGenerator + 20;
        private const string ScriptName = "HoNprGeneratorEditorUtils";

        private static readonly string[] RequiredFolders =
        {
            "ShaderSystem",
            "ShaderSystem/Contract",
            "ShaderSystem/Includes",
            "ShaderSystem/Templates",
            "ShaderSystem/FeatureBlocks",
            "ShaderSystem/Presets",
            "ShaderSystem/Generator",
            "ShaderSystem/LegacyInterop",
            "Shaders/Generated"
        };

        private static readonly string[] RequiredFiles =
        {
            "ShaderSystem/README.md",
            "ShaderSystem/Contract/HORP_CONTRACT_INDEX.md",
            "ShaderSystem/Includes/INCLUDE_REGISTRY.honprinclude",
            "ShaderSystem/Generator/GENERATOR_RULES.md",
            "ShaderSystem/Generator/SourceMapping.md",
            "ShaderSystem/Generator/ValidationRules.md",
            "ShaderSystem/LegacyInterop/LEGACY_MAPPING_TABLE.md",
        };

        [MenuItem(MenuPathForceRegenerate, false, MenuPriorityGenerator)]
        private static void ForceRegenerateGeneratedShaders()
        {
            string packageRoot = FindPackageRoot();
            if (string.IsNullOrEmpty(packageRoot))
            {
                Debug.LogWarning("[HoNpr.Generator] Could not find the package root.");
                return;
            }

            RebuildDeclarationTables(packageRoot, false);
            bool valid = ValidateShaderSystem(packageRoot, false);
            int generatedCount = GeneratePrototypeShaders(packageRoot);
            int importedCount = RefreshGeneratedShaderAssets(packageRoot, false);

            AssetDatabase.SaveAssets();
            AssetDatabase.Refresh();

            if (valid)
            {
                Debug.Log($"[HoNpr.Generator] Force regenerate completed. Generated {generatedCount} shader assets and imported {importedCount} generated assets.");
            }
            else
            {
                Debug.LogWarning($"[HoNpr.Generator] Force regenerate completed with validation warnings. Generated {generatedCount} shader assets and imported {importedCount} generated assets.");
            }
        }

        [MenuItem(MenuPathRefreshGenerated, false, MenuPriorityRefresh)]
        private static void RefreshGeneratedShaderAssets()
        {
            string packageRoot = FindPackageRoot();
            if (string.IsNullOrEmpty(packageRoot))
            {
                Debug.LogWarning("[HoNpr.Generator] Could not find the package root.");
                return;
            }

            int importedCount = RefreshGeneratedShaderAssets(packageRoot, true);
            AssetDatabase.SaveAssets();
            AssetDatabase.Refresh();
            Debug.Log($"[HoNpr.Generator] Refreshed {importedCount} generated shader assets.");
        }

        [MenuItem(MenuPathValidateDeclarations, false, MenuPriorityValidation)]
        private static void ValidateShaderSystemDeclarations()
        {
            string packageRoot = FindPackageRoot();
            if (string.IsNullOrEmpty(packageRoot))
            {
                Debug.LogWarning("[HoNpr.Generator] Could not find the package root.");
                return;
            }

            ValidateShaderSystem(packageRoot, true);
        }

        [MenuItem(MenuPathRebuildDeclarationTables, false, MenuPriorityDocumentation)]
        private static void RebuildDeclarationTables()
        {
            string packageRoot = FindPackageRoot();
            if (string.IsNullOrEmpty(packageRoot))
            {
                Debug.LogWarning("[HoNpr.Generator] Could not find the package root.");
                return;
            }

            RebuildDeclarationTables(packageRoot, true);
            AssetDatabase.SaveAssets();
            AssetDatabase.Refresh();
        }

        private static bool ValidateShaderSystem(string packageRoot, bool logSuccess)
        {
            var missing = new List<string>();
            var errors = new List<string>();

            foreach (string folder in RequiredFolders)
            {
                string path = $"{packageRoot}/{folder}";
                if (!AssetDatabase.IsValidFolder(path))
                    missing.Add(path);
            }

            foreach (string file in RequiredFiles)
            {
                string path = $"{packageRoot}/{file}";
                if (!AssetExists(path))
                    missing.Add(path);
            }

            ValidateDeclarationReferences(packageRoot, errors);

            if (missing.Count > 0)
            {
                Debug.LogWarning("[HoNpr.Generator] Shader system validation failed. Missing:\n" + string.Join("\n", missing));
                return false;
            }

            if (errors.Count > 0)
            {
                Debug.LogWarning("[HoNpr.Generator] Shader system validation failed. Invalid declarations:\n" + string.Join("\n", errors));
                return false;
            }

            if (logSuccess)
            Debug.Log("[HoNpr.Generator] Shader system declarations are valid.");

            return true;
        }

        private static void ValidateDeclarationReferences(string packageRoot, List<string> errors)
        {
            var includeRegistry = LoadIncludeRegistry(packageRoot, errors);
            var declarations = LoadShaderSystemDeclarations(packageRoot, includeRegistry, errors);
            var templates = new HashSet<string>(declarations.templates.Select(template => template.id));
            var blocks = new HashSet<string>(declarations.blocks.Select(block => block.id));

            foreach (FeatureBlockDeclaration block in declarations.blocks)
                ValidateIncludeAliases(block.requiredIncludes, includeRegistry, block.id, errors);

            foreach (PrototypePreset preset in declarations.presets)
            {
                var presetTemplates = new HashSet<string>();
                if (!string.IsNullOrEmpty(preset.template))
                    presetTemplates.Add(preset.template);

                if (preset.templates != null)
                {
                    foreach (string template in preset.templates)
                    {
                        if (!string.IsNullOrEmpty(template))
                            presetTemplates.Add(template);
                    }
                }

                foreach (string template in presetTemplates)
                {
                    if (!templates.Contains(template))
                        errors.Add($"{preset.presetId} references missing template {template}.");
                }

                if (preset.featureBlocks == null || preset.featureBlocks.Length == 0)
                {
                    errors.Add($"{preset.presetId} has no feature blocks.");
                    continue;
                }

                foreach (string block in preset.featureBlocks)
                {
                    if (!blocks.Contains(block))
                        errors.Add($"{preset.presetId} references missing feature block {block}.");
                }
            }
        }

        private static ShaderSystemDeclarations LoadShaderSystemDeclarations(string packageRoot, IncludeRegistry includeRegistry, List<string> errors)
        {
            var declarations = new ShaderSystemDeclarations();
            var templates = new HashSet<string>();
            var blocks = new HashSet<string>();
            var presets = new HashSet<string>();

            foreach (string path in FindFiles(packageRoot, "ShaderSystem/Templates", "*.honprtemplate"))
            {
                ShaderTemplateDeclaration declaration = LoadTemplateDeclaration(packageRoot, path, errors);
                if (declaration == null || string.IsNullOrEmpty(declaration.id))
                {
                    errors.Add($"Template is missing id: {path}");
                    continue;
                }

                declaration.path = ToPackageRelativePath(packageRoot, path);
                if (!templates.Add(declaration.id))
                    errors.Add($"Duplicate template id {declaration.id}: {path}");
                else
                    declarations.templates.Add(declaration);
            }

            foreach (string path in FindFiles(packageRoot, "ShaderSystem/FeatureBlocks", "*.honprblock"))
            {
                ValidateNoRawShaderDirectives(path, errors);
                FeatureBlockDeclaration declaration = LoadFeatureBlockDeclaration(packageRoot, path, errors);
                if (declaration == null || string.IsNullOrEmpty(declaration.id))
                {
                    errors.Add($"Feature block is missing id: {path}");
                    continue;
                }

                declaration.path = ToPackageRelativePath(packageRoot, path);
                declaration.includePaths = ResolveIncludePaths(declaration.requiredIncludes, includeRegistry);
                if (!blocks.Add(declaration.id))
                    errors.Add($"Duplicate feature block id {declaration.id}: {path}");
                else
                    declarations.blocks.Add(declaration);
            }

            foreach (string path in FindFiles(packageRoot, "ShaderSystem/Presets", "*.honprpreset"))
            {
                ValidateNoRawShaderDirectives(path, errors);
                PrototypePreset preset = LoadPresetDeclaration(packageRoot, path, errors);
                if (preset == null || string.IsNullOrEmpty(preset.presetId))
                {
                    errors.Add($"Preset is missing presetId: {path}");
                    continue;
                }

                preset.path = ToPackageRelativePath(packageRoot, path);
                if (!presets.Add(preset.presetId))
                    errors.Add($"Duplicate preset id {preset.presetId}: {path}");
                else
                    declarations.presets.Add(preset);
            }

            declarations.templates.Sort((a, b) => string.CompareOrdinal(a.id, b.id));
            declarations.blocks.Sort((a, b) => string.CompareOrdinal(a.id, b.id));
            declarations.presets.Sort((a, b) => string.CompareOrdinal(a.presetId, b.presetId));
            return declarations;
        }

        private static string[] ResolveIncludePaths(IReadOnlyList<string> aliases, IncludeRegistry includeRegistry)
        {
            if (aliases == null)
                return Array.Empty<string>();

            var paths = new List<string>();
            foreach (string alias in aliases)
            {
                if (includeRegistry.aliasToPath.TryGetValue(alias, out string includePath))
                    paths.Add(includePath);
            }

            return paths.ToArray();
        }

        private static string ToPackageRelativePath(string packageRoot, string assetPath)
        {
            string prefix = packageRoot.TrimEnd('/') + "/";
            return assetPath.StartsWith(prefix, StringComparison.Ordinal) ? assetPath.Substring(prefix.Length) : assetPath;
        }

        private static IEnumerable<string> FindFiles(string packageRoot, string relativeFolder, string searchPattern)
        {
            string assetFolder = $"{packageRoot}/{relativeFolder}";
            var yielded = new HashSet<string>();

            if (AssetDatabase.IsValidFolder(assetFolder))
            {
                string[] guids = AssetDatabase.FindAssets(string.Empty, new[] { assetFolder });
                foreach (string guid in guids)
                {
                    string path = AssetDatabase.GUIDToAssetPath(guid);
                    if (!string.IsNullOrEmpty(path) && MatchesSearchPattern(path, searchPattern) && yielded.Add(path))
                        yield return path;
                }
            }

            string packageAbsoluteRoot = PackageAssetPathToAbsolutePath(packageRoot);
            string absoluteFolder = Path.Combine(packageAbsoluteRoot, NormalizeRelativePath(relativeFolder));
            if (!Directory.Exists(absoluteFolder))
                yield break;

            foreach (string absolutePath in Directory.EnumerateFiles(absoluteFolder, searchPattern, SearchOption.AllDirectories))
            {
                string relativePath = Path.GetRelativePath(packageAbsoluteRoot, absolutePath)
                    .Replace(Path.DirectorySeparatorChar, '/')
                    .Replace(Path.AltDirectorySeparatorChar, '/');
                string assetPath = $"{packageRoot}/{relativePath}";
                if (yielded.Add(assetPath))
                    yield return assetPath;
            }
        }

        private static bool MatchesSearchPattern(string path, string searchPattern)
        {
            if (searchPattern.StartsWith("*", StringComparison.Ordinal))
                return path.EndsWith(searchPattern.Substring(1), StringComparison.OrdinalIgnoreCase);

            return string.Equals(Path.GetFileName(path), searchPattern, StringComparison.OrdinalIgnoreCase);
        }

        private static bool AssetExists(string path)
        {
            if (AssetDatabase.LoadAssetAtPath<UnityEngine.Object>(path) != null)
                return true;

            string absolutePath = AssetPathToAbsolutePath(path);
            return File.Exists(absolutePath);
        }

        private static IncludeRegistry LoadIncludeRegistry(string packageRoot, List<string> errors)
        {
            string path = $"{packageRoot}/ShaderSystem/Includes/INCLUDE_REGISTRY.honprinclude";
            string text = ReadAssetText(path);
            var registry = new IncludeRegistry();

            if (string.IsNullOrEmpty(text))
            {
                errors.Add($"Include registry is empty or missing: {path}");
                return registry;
            }

            text = StripLineComments(text);
            foreach (DslStatement statement in ParseStatements(text, path, errors))
            {
                if (!statement.NameEquals("include"))
                    continue;

                string alias = statement.Arguments.Count > 0 ? statement.Arguments[0] : null;
                string includePath = statement.Value;
                if (string.IsNullOrEmpty(alias) || string.IsNullOrEmpty(includePath))
                {
                    errors.Add($"Include declaration must be `include <Alias> = \"path\";`: {path}");
                    continue;
                }

                if (registry.aliasToPath.ContainsKey(alias))
                    errors.Add($"Duplicate include alias {alias}: {path}");
                else
                    registry.aliasToPath.Add(alias, includePath);
            }

            return registry;
        }

        private static void ValidateIncludeAliases(IReadOnlyList<string> aliases, IncludeRegistry registry, string ownerId, List<string> errors)
        {
            if (aliases == null)
                return;

            foreach (string alias in aliases)
            {
                if (!registry.aliasToPath.ContainsKey(alias))
                    errors.Add($"{ownerId} references missing include alias {alias}.");
            }
        }

        private static void RebuildDeclarationTables(string packageRoot, bool logSuccess)
        {
            var errors = new List<string>();
            IncludeRegistry includeRegistry = LoadIncludeRegistry(packageRoot, errors);
            ShaderSystemDeclarations declarations = LoadShaderSystemDeclarations(packageRoot, includeRegistry, errors);

            string absolutePackageRoot = PackageAssetPathToAbsolutePath(packageRoot);
            WriteTextFile(Path.Combine(absolutePackageRoot, "ShaderSystem", "Templates", "TEMPLATE_TABLE.md"), BuildTemplateTable(declarations));
            WriteTextFile(Path.Combine(absolutePackageRoot, "ShaderSystem", "FeatureBlocks", "FEATURE_BLOCK_TABLE.md"), BuildFeatureBlockTable(declarations));
            WriteTextFile(Path.Combine(absolutePackageRoot, "ShaderSystem", "Presets", "PRESET_TABLE.md"), BuildPresetTable(declarations));

            var importedPaths = new List<string>();
            ImportAssets($"{packageRoot}/ShaderSystem/Templates", "TEMPLATE_TABLE", importedPaths, false);
            ImportAssets($"{packageRoot}/ShaderSystem/FeatureBlocks", "FEATURE_BLOCK_TABLE", importedPaths, false);
            ImportAssets($"{packageRoot}/ShaderSystem/Presets", "PRESET_TABLE", importedPaths, false);

            if (errors.Count > 0)
            {
                Debug.LogWarning("[HoNpr.Generator] Rebuilt declaration tables with validation warnings:\n" + string.Join("\n", errors));
                return;
            }

            if (logSuccess)
                Debug.Log($"[HoNpr.Generator] Rebuilt declaration tables from HoNpr DSL. Imported {importedPaths.Count} table assets.");
        }

        private static string BuildTemplateTable(ShaderSystemDeclarations declarations)
        {
            var builder = new StringBuilder();
            builder.AppendLine("# 模板表");
            builder.AppendLine();
            builder.AppendLine("由 `*.honprtemplate` 自动生成。不要手动编辑表格行。");
            builder.AppendLine();
            builder.AppendLine("| 模板 ID | 路径 | Pass | Include 插槽 | 状态 | 说明 |");
            builder.AppendLine("| --- | --- | --- | --- | --- | --- |");

            foreach (ShaderTemplateDeclaration template in declarations.templates)
            {
                builder.Append("| ");
                builder.Append(Code(template.id));
                builder.Append(" | ");
                builder.Append(Code(template.path));
                builder.Append(" | ");
                builder.Append(CodeList(template.passes));
                builder.Append(" | ");
                builder.Append(CodeList(template.requiredSlots));
                builder.Append(" | ");
                builder.Append(template.id == "MaterialTemplate.DebugLitMinimal" ? "已生成" : "已声明");
                builder.Append(" | ");
                builder.Append(MarkdownCell(template.description));
                builder.AppendLine(" |");
            }

            return builder.ToString();
        }

        private static string BuildFeatureBlockTable(ShaderSystemDeclarations declarations)
        {
            var compatiblePresetMap = BuildCompatiblePresetMap(declarations);
            var builder = new StringBuilder();
            builder.AppendLine("# 功能块表");
            builder.AppendLine();
            builder.AppendLine("由 `*.honprblock` 自动生成。不要手动编辑表格行。");
            builder.AppendLine();
            builder.AppendLine("| ID | Domain | Stage | 消费 | 生产 | Include 别名 | Define | 入口 | 兼容 Preset | Variant 策略 | Debug 视图 |");
            builder.AppendLine("| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |");

            foreach (FeatureBlockDeclaration block in declarations.blocks)
            {
                builder.Append("| ");
                builder.Append(Code(block.id));
                builder.Append(" | ");
                builder.Append(MarkdownCell(block.domain));
                builder.Append(" | ");
                builder.Append(MarkdownCell(block.stage));
                builder.Append(" | ");
                builder.Append(CodeList(block.requiredInputs));
                builder.Append(" | ");
                builder.Append(CodeList(block.producedFields));
                builder.Append(" | ");
                builder.Append(CodeList(block.requiredIncludes));
                builder.Append(" | ");
                builder.Append(CodeList(block.requiredDefines));
                builder.Append(" | ");
                builder.Append(Code(block.entry));
                builder.Append(" | ");
                builder.Append(CodeList(compatiblePresetMap.TryGetValue(block.id, out var presets) ? presets : Array.Empty<string>()));
                builder.Append(" | ");
                builder.Append(MarkdownCell(DisplayVariantPolicy(block.variantPolicy)));
                builder.Append(" | ");
                builder.Append(MarkdownCell(block.debugView));
                builder.AppendLine(" |");
            }

            return builder.ToString();
        }

        private static string BuildPresetTable(ShaderSystemDeclarations declarations)
        {
            var builder = new StringBuilder();
            builder.AppendLine("# Preset 表");
            builder.AppendLine();
            builder.AppendLine("由 `*.honprpreset` 自动生成。不要手动编辑表格行。");
            builder.AppendLine();
            builder.AppendLine("| Preset ID | 路径 | 模板 | 功能块 | Pass | 生产语义 | 需要的 Capability | Phase 策略 | 生成 Shader | 状态 |");
            builder.AppendLine("| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |");

            foreach (PrototypePreset preset in declarations.presets)
            {
                builder.Append("| ");
                builder.Append(Code(preset.presetId));
                builder.Append(" | ");
                builder.Append(Code(preset.path));
                builder.Append(" | ");
                builder.Append(CodeList(GetPresetTemplates(preset)));
                builder.Append(" | ");
                builder.Append(CodeList(preset.featureBlocks));
                builder.Append(" | ");
                builder.Append(CodeList(preset.passes));
                builder.Append(" | ");
                builder.Append(CodeList(preset.producedSemantics));
                builder.Append(" | ");
                builder.Append(CodeList(preset.requiredCapabilities));
                builder.Append(" | ");
                builder.Append(MarkdownCell(DisplayPhasePolicy(preset.phasePolicy)));
                builder.Append(" | ");
                builder.Append(Code(preset.generatedShader));
                builder.Append(" | ");
                builder.Append(MarkdownCell(DisplayPresetStatus(preset.status)));
                builder.AppendLine(" |");
            }

            return builder.ToString();
        }

        private static string DisplayVariantPolicy(string value)
        {
            switch (value)
            {
                case "AlwaysCompiled":
                    return "总是编译";
                case "PresetStatic":
                    return "Preset 静态";
                case "DebugOnly":
                    return "仅 Debug";
                case "Unsupported":
                    return "不支持";
                default:
                    return value;
            }
        }

        private static string DisplayPhasePolicy(string value)
        {
            switch (value)
            {
                case "Forward":
                    return "Forward";
                case "OitOnly":
                    return "仅 OIT";
                default:
                    return value;
            }
        }

        private static string DisplayPresetStatus(string value)
        {
            switch (value)
            {
                case "Prototype":
                    return "原型";
                case "Planned":
                    return "规划中";
                case "Active":
                    return "已启用";
                case "Deprecated":
                    return "已废弃";
                default:
                    return value;
            }
        }

        private static Dictionary<string, string[]> BuildCompatiblePresetMap(ShaderSystemDeclarations declarations)
        {
            var map = new Dictionary<string, List<string>>();
            foreach (PrototypePreset preset in declarations.presets)
            {
                if (preset.featureBlocks == null)
                    continue;

                foreach (string block in preset.featureBlocks)
                {
                    if (!map.TryGetValue(block, out List<string> presets))
                    {
                        presets = new List<string>();
                        map.Add(block, presets);
                    }

                    presets.Add(preset.presetId);
                }
            }

            var result = new Dictionary<string, string[]>();
            foreach (KeyValuePair<string, List<string>> entry in map)
                result.Add(entry.Key, entry.Value.OrderBy(value => value, StringComparer.Ordinal).ToArray());

            return result;
        }

        private static string[] GetPresetTemplates(PrototypePreset preset)
        {
            if (preset.templates != null && preset.templates.Length > 0)
                return preset.templates;

            return string.IsNullOrEmpty(preset.template) ? Array.Empty<string>() : new[] { preset.template };
        }

        private static void WriteTextFile(string path, string content)
        {
            Directory.CreateDirectory(Path.GetDirectoryName(path));
            File.WriteAllText(path, content, System.Text.Encoding.UTF8);
        }

        private static string CodeList(IReadOnlyList<string> values)
        {
            if (values == null || values.Count == 0)
                return string.Empty;

            return string.Join(", ", values.Where(value => !string.IsNullOrEmpty(value)).Select(Code));
        }

        private static string Code(string value)
        {
            return string.IsNullOrEmpty(value) ? string.Empty : $"`{MarkdownCell(value)}`";
        }

        private static string MarkdownCell(string value)
        {
            return string.IsNullOrEmpty(value) ? string.Empty : value.Replace("|", "\\|").Replace("\r", " ").Replace("\n", " ");
        }

        private static void ValidateNoRawShaderDirectives(string path, List<string> errors)
        {
            string text = ReadAssetText(path);
            if (string.IsNullOrEmpty(text))
                return;

            using (var reader = new StringReader(text))
            {
                string line;
                int lineNumber = 0;
                while ((line = reader.ReadLine()) != null)
                {
                    lineNumber++;
                    string trimmed = line.TrimStart();
                    if (trimmed.StartsWith("#include", StringComparison.Ordinal) ||
                        trimmed.StartsWith("#define", StringComparison.Ordinal) ||
                        trimmed.StartsWith("#pragma", StringComparison.Ordinal))
                    {
                        errors.Add($"Raw shader directive is not allowed in DSL declarations: {path}:{lineNumber}");
                    }
                }
            }
        }

        private static ShaderTemplateDeclaration LoadTemplateDeclaration(string packageRoot, string path, List<string> errors)
        {
            string text = ReadAssetText(path);
            if (string.IsNullOrEmpty(text))
                return null;

            foreach (DslBlock block in ParseBlocks(text, path, errors))
            {
                if (!block.KindEquals("template"))
                    continue;

                var declaration = new ShaderTemplateDeclaration
                {
                    id = block.Id,
                    passes = Array.Empty<string>(),
                    requiredSlots = Array.Empty<string>()
                };

                foreach (DslStatement statement in block.Statements)
                {
                    if (statement.NameEquals("display"))
                        declaration.displayName = statement.Value;
                    else if (statement.NameEquals("description"))
                        declaration.description = statement.Value;
                    else if (statement.NameEquals("passes"))
                        declaration.passes = statement.Arguments.ToArray();
                    else if (statement.NameEquals("requires") && statement.ArgumentEquals(0, "slots"))
                        declaration.requiredSlots = statement.ArgumentsFrom(1).ToArray();
                    else if (statement.NameEquals("shaderNamePattern"))
                        declaration.shaderNamePattern = statement.Value;
                }

                return declaration;
            }

            return null;
        }

        private static FeatureBlockDeclaration LoadFeatureBlockDeclaration(string packageRoot, string path, List<string> errors)
        {
            string text = ReadAssetText(path);
            if (string.IsNullOrEmpty(text))
                return null;

            foreach (DslBlock block in ParseBlocks(text, path, errors))
            {
                if (!block.KindEquals("block"))
                    continue;

                var declaration = new FeatureBlockDeclaration
                {
                    id = block.Id,
                    domain = block.Domain,
                    stage = block.Stage,
                    requiredInputs = Array.Empty<string>(),
                    producedFields = Array.Empty<string>(),
                    requiredIncludes = Array.Empty<string>(),
                    requiredDefines = Array.Empty<string>(),
                    variants = Array.Empty<string>()
                };

                foreach (DslStatement statement in block.Statements)
                {
                    if (statement.NameEquals("consumes"))
                        declaration.requiredInputs = statement.Arguments.ToArray();
                    else if (statement.NameEquals("produces"))
                        declaration.producedFields = statement.Arguments.ToArray();
                    else if (statement.NameEquals("requires") && statement.ArgumentEquals(0, "include"))
                        declaration.requiredIncludes = statement.ArgumentsFrom(1).ToArray();
                    else if (statement.NameEquals("requires") && statement.ArgumentEquals(0, "define"))
                        declaration.requiredDefines = statement.ArgumentsFrom(1).ToArray();
                    else if (statement.NameEquals("entry"))
                        declaration.entry = statement.Arguments.Count > 0 ? statement.Arguments[0] : statement.Value;
                    else if (statement.NameEquals("variantPolicy"))
                        declaration.variantPolicy = statement.Arguments.Count > 0 ? statement.Arguments[0] : statement.Value;
                    else if (statement.NameEquals("variant"))
                        declaration.variants = statement.Arguments.ToArray();
                    else if (statement.NameEquals("debug"))
                        declaration.debugView = statement.Arguments.Count > 0 ? statement.Arguments[0] : statement.Value;
                }

                return declaration;
            }

            return null;
        }

        private static PrototypePreset LoadPresetDeclaration(string packageRoot, string path, List<string> errors)
        {
            string text = ReadAssetText(path);
            if (string.IsNullOrEmpty(text))
                return null;

            foreach (DslBlock block in ParseBlocks(text, path, errors))
            {
                if (!block.KindEquals("preset"))
                    continue;

                var declaration = new PrototypePreset
                {
                    presetId = block.Id,
                    templates = Array.Empty<string>(),
                    featureBlocks = Array.Empty<string>(),
                    passes = Array.Empty<string>(),
                    producedSemantics = Array.Empty<string>(),
                    requiredCapabilities = Array.Empty<string>()
                };

                foreach (DslStatement statement in block.Statements)
                {
                    if (statement.NameEquals("display"))
                        declaration.displayName = statement.Value;
                    else if (statement.NameEquals("template"))
                        declaration.template = statement.Arguments.Count > 0 ? statement.Arguments[0] : statement.Value;
                    else if (statement.NameEquals("templates"))
                        declaration.templates = statement.Arguments.ToArray();
                    else if (statement.NameEquals("shaderName"))
                        declaration.shaderName = statement.Value;
                    else if (statement.NameEquals("generatedShader"))
                        declaration.generatedShader = statement.Value;
                    else if (statement.NameEquals("blocks"))
                        declaration.featureBlocks = statement.Arguments.ToArray();
                    else if (statement.NameEquals("passes"))
                        declaration.passes = statement.Arguments.ToArray();
                    else if (statement.NameEquals("produces"))
                        declaration.producedSemantics = statement.Arguments.ToArray();
                    else if (statement.NameEquals("requires") && statement.ArgumentEquals(0, "capability"))
                        declaration.requiredCapabilities = statement.ArgumentsFrom(1).ToArray();
                    else if (statement.NameEquals("phase"))
                        declaration.phasePolicy = statement.Arguments.Count > 0 ? statement.Arguments[0] : statement.Value;
                    else if (statement.NameEquals("status"))
                        declaration.status = statement.Arguments.Count > 0 ? statement.Arguments[0] : statement.Value;
                }

                if (string.IsNullOrEmpty(declaration.template) && declaration.templates.Length > 0)
                    declaration.template = declaration.templates[0];

                return declaration;
            }

            return null;
        }

        private static int RefreshGeneratedShaderAssets(string packageRoot, bool logSkippedFolders)
        {
            var importedPaths = new List<string>();
            ImportAssets($"{packageRoot}/Shaders/Generated", "t:Shader", importedPaths, logSkippedFolders);
            ImportAssets($"{packageRoot}/Shaders/Generated", "t:TextAsset", importedPaths, logSkippedFolders);
            return importedPaths.Count;
        }

        private static int GeneratePrototypeShaders(string packageRoot)
        {
            var errors = new List<string>();
            string presetPath = $"{packageRoot}/ShaderSystem/Presets/Debug/Character_DebugLit_SSS_OITReady.honprpreset";
            PrototypePreset preset = LoadPresetDeclaration(packageRoot, presetPath, errors);
            if (preset == null)
            {
                Debug.LogWarning($"[HoNpr.Generator] Could not find preset at {presetPath}.");
                return 0;
            }

            if (preset == null || string.IsNullOrEmpty(preset.generatedShader) || string.IsNullOrEmpty(preset.shaderName))
            {
                Debug.LogWarning($"[HoNpr.Generator] Preset is missing generated shader metadata: {presetPath}.");
                return 0;
            }

            if (errors.Count > 0)
            {
                Debug.LogWarning("[HoNpr.Generator] Preset parse warnings:\n" + string.Join("\n", errors));
            }

            string absolutePackageRoot = PackageAssetPathToAbsolutePath(packageRoot);
            string shaderAbsolutePath = Path.Combine(absolutePackageRoot, NormalizeRelativePath(preset.generatedShader));
            Directory.CreateDirectory(Path.GetDirectoryName(shaderAbsolutePath));

            File.WriteAllText(shaderAbsolutePath, BuildDebugLitShader(preset), System.Text.Encoding.UTF8);
            return 1;
        }

        private static string PackageAssetPathToAbsolutePath(string packageRoot)
        {
            return AssetPathToAbsolutePath(packageRoot);
        }

        private static string AssetPathToAbsolutePath(string assetPath)
        {
            string normalizedAssetPath = assetPath.Replace('\\', '/');
            if (normalizedAssetPath.StartsWith("Packages/", StringComparison.Ordinal))
            {
                UnityEditor.PackageManager.PackageInfo packageInfo = UnityEditor.PackageManager.PackageInfo.FindForAssetPath(normalizedAssetPath);
                if (packageInfo != null && !string.IsNullOrEmpty(packageInfo.resolvedPath))
                {
                    string packageAssetRoot = packageInfo.assetPath.TrimEnd('/');
                    if (normalizedAssetPath.Equals(packageAssetRoot, StringComparison.Ordinal))
                        return packageInfo.resolvedPath;

                    if (normalizedAssetPath.StartsWith(packageAssetRoot + "/", StringComparison.Ordinal))
                    {
                        string relativePath = normalizedAssetPath.Substring(packageAssetRoot.Length + 1);
                        return Path.GetFullPath(Path.Combine(packageInfo.resolvedPath, NormalizeRelativePath(relativePath)));
                    }
                }
            }

            return Path.GetFullPath(Path.Combine(Directory.GetCurrentDirectory(), NormalizeRelativePath(normalizedAssetPath)));
        }

        private static string NormalizeRelativePath(string path)
        {
            return path.Replace('/', Path.DirectorySeparatorChar).Replace('\\', Path.DirectorySeparatorChar);
        }

        private static string ReadAssetText(string path)
        {
            TextAsset asset = AssetDatabase.LoadAssetAtPath<TextAsset>(path);
            if (asset != null)
                return asset.text;

            string absolutePath = AssetPathToAbsolutePath(path);
            return File.Exists(absolutePath) ? File.ReadAllText(absolutePath) : null;
        }

        private static IEnumerable<DslBlock> ParseBlocks(string text, string path, List<string> errors)
        {
            text = StripLineComments(text);

            foreach (Match match in Regex.Matches(text, @"\b(block|preset|template)\s+([A-Za-z0-9_.]+)(?:\s*:\s*([A-Za-z0-9_]+)\s+in\s+([A-Za-z0-9_]+))?\s*\{", RegexOptions.Multiline))
            {
                int bodyStart = match.Index + match.Length;
                int bodyEnd = FindMatchingBrace(text, bodyStart - 1);
                if (bodyEnd < 0)
                {
                    errors.Add($"Unclosed {match.Groups[1].Value} declaration {match.Groups[2].Value}: {path}");
                    continue;
                }

                string body = text.Substring(bodyStart, bodyEnd - bodyStart);
                yield return new DslBlock
                {
                    kind = match.Groups[1].Value,
                    Id = match.Groups[2].Value,
                    Stage = match.Groups[3].Success ? match.Groups[3].Value : null,
                    Domain = match.Groups[4].Success ? match.Groups[4].Value : null,
                    Statements = ParseStatements(body, path, errors)
                };
            }
        }

        private static List<DslStatement> ParseStatements(string text, string path, List<string> errors)
        {
            var statements = new List<DslStatement>();

            foreach (string rawStatement in SplitStatements(text))
            {
                string statementText = rawStatement.Trim();
                if (string.IsNullOrEmpty(statementText))
                    continue;

                int equalsIndex = statementText.IndexOf('=');
                if (equalsIndex >= 0)
                {
                    string left = statementText.Substring(0, equalsIndex).Trim();
                    string right = statementText.Substring(equalsIndex + 1).Trim();
                    statements.Add(new DslStatement
                    {
                        Name = FirstToken(left),
                        Arguments = Tokens(left, skipFirst: true),
                        Value = Unquote(right)
                    });
                    continue;
                }

                List<string> tokens = Tokens(statementText, skipFirst: false);
                if (tokens.Count == 0)
                    continue;

                string name = tokens[0];
                tokens.RemoveAt(0);
                statements.Add(new DslStatement
                {
                    Name = name,
                    Arguments = tokens,
                    Value = tokens.Count == 1 ? tokens[0] : null
                });
            }

            return statements;
        }

        private static IEnumerable<string> SplitStatements(string text)
        {
            var builder = new StringBuilder();
            bool inString = false;

            foreach (char c in text)
            {
                if (c == '"')
                    inString = !inString;

                if (c == ';' && !inString)
                {
                    yield return builder.ToString();
                    builder.Length = 0;
                }
                else
                {
                    builder.Append(c);
                }
            }

            if (builder.Length > 0)
                yield return builder.ToString();
        }

        private static string StripLineComments(string text)
        {
            var builder = new StringBuilder(text.Length);
            using (var reader = new StringReader(text))
            {
                string line;
                while ((line = reader.ReadLine()) != null)
                {
                    int commentIndex = FindLineCommentIndex(line);
                    builder.AppendLine(commentIndex >= 0 ? line.Substring(0, commentIndex) : line);
                }
            }

            return builder.ToString();
        }

        private static int FindLineCommentIndex(string line)
        {
            bool inString = false;
            for (int i = 0; i < line.Length - 1; i++)
            {
                if (line[i] == '"')
                    inString = !inString;
                else if (!inString && line[i] == '/' && line[i + 1] == '/')
                    return i;
            }

            return -1;
        }

        private static int FindMatchingBrace(string text, int openBraceIndex)
        {
            int depth = 0;
            bool inString = false;

            for (int i = openBraceIndex; i < text.Length; i++)
            {
                char c = text[i];
                if (c == '"')
                    inString = !inString;

                if (inString)
                    continue;

                if (c == '{')
                    depth++;
                else if (c == '}')
                {
                    depth--;
                    if (depth == 0)
                        return i;
                }
            }

            return -1;
        }

        private static string FirstToken(string text)
        {
            List<string> tokens = Tokens(text, skipFirst: false);
            return tokens.Count > 0 ? tokens[0] : string.Empty;
        }

        private static List<string> Tokens(string text, bool skipFirst)
        {
            var tokens = new List<string>();
            foreach (Match match in Regex.Matches(text, @"""([^""]*)""|[A-Za-z0-9_.\-/]+"))
            {
                string value = match.Groups[1].Success ? match.Groups[1].Value : match.Value;
                tokens.Add(value.Trim());
            }

            if (skipFirst && tokens.Count > 0)
                tokens.RemoveAt(0);

            return tokens;
        }

        private static string Unquote(string value)
        {
            value = value.Trim();
            if (value.Length >= 2 && value[0] == '"' && value[value.Length - 1] == '"')
                return value.Substring(1, value.Length - 2);

            return value;
        }

        private static string BuildDebugLitShader(PrototypePreset preset)
        {
            string blockList = preset.featureBlocks == null ? string.Empty : string.Join(", ", preset.featureBlocks);
            return
$@"// 由 HoNprShaderGenerator 生成。
// SourcePreset: {preset.presetId}
// Template: {preset.template}
// Blocks: {blockList}
// 不要手动修改生成体。请改 template / block / preset。
Shader ""{preset.shaderName}""
{{
    Properties
    {{
        _HoUrpBaseColor(""Base Color"", Color) = (1, 1, 1, 1)
        // Only material-owned semantics are exposed here. Object/RSUV fields are resolved
        // through HoUrpObjectSemantic.hlsl and should be authored by ObjectSemanticAuthoring.
        _HoUrpGeneratedMaterialClass(""Material Class"", Float) = 1
        _HoUrpGeneratedMaterialSssProfile(""SSS Profile"", Float) = 1
        _HoUrpGeneratedMaterialThickness(""Thickness"", Range(0, 1)) = 0.5
        _HoUrpGeneratedMaterialCurvature(""Curvature"", Range(-1, 1)) = 0
        _HoUrpGeneratedMaterialCustom0_3(""Material Custom 0-3"", Vector) = (0, 0, 0, 0)
        _HoUrpGeneratedSssSourceColor(""SSS Source Color"", Color) = (1, 0.75, 0.6, 1)
        _HoUrpGeneratedSssWeight(""SSS Weight"", Range(0, 1)) = 0.5
        _HoUrpSupportsOit(""Supports OIT"", Float) = 1
        _HoUrpParticipatesOit(""Participates OIT"", Float) = 1
    }}

    SubShader
    {{
        Tags {{ ""RenderPipeline"" = ""UniversalPipeline"" ""RenderType"" = ""Transparent"" ""Queue"" = ""Transparent"" }}

        Pass
        {{
            Name ""UniversalForward""
            Tags {{ ""LightMode"" = ""UniversalForward"" }}

            Cull Back
            ZWrite Off
            ZTest LEqual
            Blend SrcAlpha OneMinusSrcAlpha

            HLSLPROGRAM
            #pragma target 4.5
            #pragma vertex Vert
            #pragma fragment FragForward

            #include ""Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl""
            #include ""Packages/com.hollow.hourp-extensions/Runtime/Shaders/ShaderLibrary/HoUrpMaterialSurface.hlsl""

            struct Attributes
            {{
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            }};

            struct Varyings
            {{
                float4 positionCS : SV_POSITION;
                half3 normalWS : TEXCOORD0;
                UNITY_VERTEX_OUTPUT_STEREO
            }};

            half4 _HoUrpBaseColor;

            Varyings Vert(Attributes input)
            {{
                Varyings output;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                VertexPositionInputs positionInputs = GetVertexPositionInputs(input.positionOS.xyz);
                VertexNormalInputs normalInputs = GetVertexNormalInputs(input.normalOS);
                output.positionCS = positionInputs.positionCS;
                output.normalWS = NormalizeNormalPerVertex(normalInputs.normalWS);
                return output;
            }}

            half4 FragForward(Varyings input) : SV_Target
            {{
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                HoUrpSurfaceData surface = HoUrpCreateSurfaceData(_HoUrpBaseColor.rgb, _HoUrpBaseColor.a, input.normalWS);
                half ndotl = saturate(dot(normalize(surface.normalWS), normalize(half3(0.3h, 0.6h, 0.7h))));
                half3 debugLighting = surface.baseColor * (0.25h + 0.75h * ndotl);
                return half4(debugLighting, surface.alpha);
            }}
            ENDHLSL
        }}

        Pass
        {{
            Name ""HoUrpAovOutput""
            Tags {{ ""LightMode"" = ""HoUrpAovOutput"" }}

            Cull Back
            ZWrite Off
            ZTest LEqual

            HLSLPROGRAM
            #pragma target 4.5
            #pragma vertex Vert
            #pragma fragment FragAov

            #include ""Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl""
            #include ""Packages/com.hollow.hourp-extensions/Runtime/Shaders/ShaderLibrary/HoUrpObjectSemantic.hlsl""
            #include ""Packages/com.hollow.hourp-extensions/Runtime/Shaders/ShaderLibrary/HoUrpMaterialSurface.hlsl""
            #include ""Packages/com.hollow.hourp-extensions/Runtime/Shaders/ShaderLibrary/HoUrpMaterialAov.hlsl""

            struct Attributes
            {{
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            }};

            struct Varyings
            {{
                float4 positionCS : SV_POSITION;
                half3 normalWS : TEXCOORD0;
                float2 depthZW : TEXCOORD1;
                UNITY_VERTEX_OUTPUT_STEREO
            }};

            struct AovOutput
            {{
                half4 maskId : SV_Target0;
                half4 normalDepth : SV_Target1;
                half4 objectCustom0 : SV_Target2;
                half4 objectCustom1 : SV_Target3;
                half4 surfaceData : SV_Target4;
                half4 materialCustom0 : SV_Target5;
                half4 sssSource : SV_Target6;
            }};

            half4 _HoUrpBaseColor;
            float _HoUrpGeneratedMaterialClass;
            float _HoUrpGeneratedMaterialSssProfile;
            float _HoUrpGeneratedMaterialThickness;
            float _HoUrpGeneratedMaterialCurvature;
            float4 _HoUrpGeneratedMaterialCustom0_3;
            float4 _HoUrpGeneratedSssSourceColor;
            float _HoUrpGeneratedSssWeight;

            Varyings Vert(Attributes input)
            {{
                Varyings output;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                VertexPositionInputs positionInputs = GetVertexPositionInputs(input.positionOS.xyz);
                VertexNormalInputs normalInputs = GetVertexNormalInputs(input.normalOS);
                output.positionCS = positionInputs.positionCS;
                output.normalWS = NormalizeNormalPerVertex(normalInputs.normalWS);
                output.depthZW = positionInputs.positionCS.zw;
                return output;
            }}

            AovOutput FragAov(Varyings input)
            {{
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                HoUrpObjectSemanticData objectSemantic = HoUrpResolveObjectSemanticData();
                half maskWeight = objectSemantic.maskWeight;
                half3 normalWS = normalize(input.normalWS);
                float rawDepth = input.depthZW.x / max(input.depthZW.y, 1.0e-6);
                half linear01Depth = half(saturate(Linear01Depth(rawDepth, _ZBufferParams)));

                HoUrpMaterialSemanticData semantic = HoUrpCreateMaterialSemanticData(
                    half(_HoUrpGeneratedMaterialClass),
                    half(_HoUrpGeneratedMaterialSssProfile),
                    half(_HoUrpGeneratedMaterialThickness),
                    half(_HoUrpGeneratedMaterialCurvature),
                    half4(_HoUrpGeneratedMaterialCustom0_3),
                    half3(_HoUrpGeneratedSssSourceColor.rgb),
                    half(_HoUrpGeneratedSssWeight));
                HoUrpAovOutputData materialAov = HoUrpEncodeMaterialAov(semantic, maskWeight);

                AovOutput output;
                output.maskId = HoUrpEncodeObjectMaskId(objectSemantic);
                output.normalDepth = half4(normalWS * 0.5h + 0.5h, linear01Depth);
                output.objectCustom0 = HoUrpEncodeObjectCustom0_3(objectSemantic);
                output.objectCustom1 = HoUrpEncodeObjectCustom4_7(objectSemantic);
                output.surfaceData = materialAov.surfaceData;
                output.materialCustom0 = materialAov.materialCustom0_3;
                output.sssSource = materialAov.sssSource;
                return output;
            }}
            ENDHLSL
        }}

        Pass
        {{
            Name ""HoUrpOitAccumulation""
            Tags {{ ""LightMode"" = ""HoUrpOitAccumulation"" }}

            Cull Back
            ZWrite Off
            ZTest LEqual
            Blend One One, Zero OneMinusSrcAlpha

            HLSLPROGRAM
            #pragma target 4.5
            #pragma vertex Vert
            #pragma fragment FragOit

            #include ""Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl""
            #include ""Packages/com.hollow.hourp-extensions/Runtime/Shaders/ShaderLibrary/HoUrpMaterialSurface.hlsl""
            #include ""Packages/com.hollow.hourp-extensions/Runtime/Shaders/ShaderLibrary/HoUrpMaterialOit.hlsl""

            struct Attributes
            {{
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            }};

            struct Varyings
            {{
                float4 positionCS : SV_POSITION;
                half3 normalWS : TEXCOORD0;
                UNITY_VERTEX_OUTPUT_STEREO
            }};

            struct OitOutput
            {{
                half4 accumulation : SV_Target0;
                half revealage : SV_Target1;
            }};

            half4 _HoUrpBaseColor;
            float _HoUrpSupportsOit;
            float _HoUrpParticipatesOit;

            Varyings Vert(Attributes input)
            {{
                Varyings output;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                VertexPositionInputs positionInputs = GetVertexPositionInputs(input.positionOS.xyz);
                VertexNormalInputs normalInputs = GetVertexNormalInputs(input.normalOS);
                output.positionCS = positionInputs.positionCS;
                output.normalWS = NormalizeNormalPerVertex(normalInputs.normalWS);
                return output;
            }}

            OitOutput FragOit(Varyings input)
            {{
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                HoUrpSurfaceData surface = HoUrpCreateSurfaceData(_HoUrpBaseColor.rgb, _HoUrpBaseColor.a, input.normalWS);
                HoUrpTransparentOutputData transparentData = HoUrpCreateTransparentOutputData(
                    surface,
                    half(_HoUrpSupportsOit),
                    half(_HoUrpParticipatesOit));
                transparentData.alpha *= transparentData.supportsOit * transparentData.participatesOit;

                HoUrpOitAccumulationData accumulation = HoUrpEncodeOitAccumulation(transparentData);
                OitOutput output;
                output.accumulation = half4(accumulation.weightedColor, accumulation.weightedAlpha);
                output.revealage = accumulation.revealage;
                return output;
            }}
            ENDHLSL
        }}
    }}
}}
";
        }

        [System.Serializable]
        private sealed class PrototypePreset
        {
            public string path;
            public string presetId;
            public string displayName;
            public string template;
            public string[] templates;
            public string shaderName;
            public string generatedShader;
            public string[] featureBlocks;
            public string[] passes;
            public string[] producedSemantics;
            public string[] requiredCapabilities;
            public string phasePolicy;
            public string status;
        }

        private sealed class ShaderTemplateDeclaration
        {
            public string path;
            public string id;
            public string displayName;
            public string description;
            public string[] passes;
            public string[] requiredSlots;
            public string shaderNamePattern;
        }

        private sealed class FeatureBlockDeclaration
        {
            public string path;
            public string id;
            public string domain;
            public string stage;
            public string[] requiredInputs;
            public string[] producedFields;
            public string[] requiredIncludes;
            public string[] includePaths;
            public string[] requiredDefines;
            public string[] variants;
            public string entry;
            public string variantPolicy;
            public string debugView;
        }

        private sealed class IncludeRegistry
        {
            public readonly Dictionary<string, string> aliasToPath = new Dictionary<string, string>();
        }

        private sealed class ShaderSystemDeclarations
        {
            public readonly List<ShaderTemplateDeclaration> templates = new List<ShaderTemplateDeclaration>();
            public readonly List<FeatureBlockDeclaration> blocks = new List<FeatureBlockDeclaration>();
            public readonly List<PrototypePreset> presets = new List<PrototypePreset>();
        }

        private sealed class DslBlock
        {
            public string kind;
            public string Id;
            public string Stage;
            public string Domain;
            public List<DslStatement> Statements;

            public bool KindEquals(string value)
            {
                return string.Equals(kind, value, StringComparison.OrdinalIgnoreCase);
            }
        }

        private sealed class DslStatement
        {
            public string Name;
            public List<string> Arguments = new List<string>();
            public string Value;

            public bool NameEquals(string value)
            {
                return string.Equals(Name, value, StringComparison.OrdinalIgnoreCase);
            }

            public bool ArgumentEquals(int index, string value)
            {
                return Arguments.Count > index && string.Equals(Arguments[index], value, StringComparison.OrdinalIgnoreCase);
            }

            public IEnumerable<string> ArgumentsFrom(int index)
            {
                for (int i = index; i < Arguments.Count; i++)
                    yield return Arguments[i];
            }
        }

        private static string FindPackageRoot()
        {
            string[] guids = AssetDatabase.FindAssets($"{ScriptName} t:MonoScript", new[] { "Packages" });
            foreach (string guid in guids)
            {
                string path = AssetDatabase.GUIDToAssetPath(guid);
                const string marker = "/Editor/HoNprGeneratorEditorUtils.cs";
                if (path.EndsWith(marker))
                    return path.Substring(0, path.Length - marker.Length);
            }

            return null;
        }

        private static void ImportAssets(string root, string filter, List<string> importedPaths, bool logSkippedFolders)
        {
            if (!AssetDatabase.IsValidFolder(root))
            {
                if (logSkippedFolders)
                    Debug.LogWarning($"[HoNpr.Generator] Could not find folder at {root}.");
                return;
            }

            string[] guids = AssetDatabase.FindAssets(filter, new[] { root });
            foreach (string guid in guids)
            {
                string path = AssetDatabase.GUIDToAssetPath(guid);
                if (string.IsNullOrEmpty(path))
                    continue;

                AssetDatabase.ImportAsset(path, ImportAssetOptions.ForceUpdate | ImportAssetOptions.ForceSynchronousImport);
                importedPaths.Add(path);
            }
        }
    }
}

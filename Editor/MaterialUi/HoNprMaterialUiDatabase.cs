using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using UnityEditor;
using UnityEngine;

namespace Hollow.HoNpr.Editor.MaterialUi
{
    internal static class HoNprMaterialUiDatabase
    {
        private const string PackageRootMarker = "/Editor/MaterialUi/HoNprMaterialUiDatabase.cs";

        private static readonly Dictionary<string, HoNprMaterialUiDescriptor> CacheByPreset = new Dictionary<string, HoNprMaterialUiDescriptor>();
        private static bool cacheBuilt;

        public static HoNprMaterialUiDescriptor GetForPreset(string presetId)
        {
            EnsureCache();
            return string.IsNullOrEmpty(presetId) ? null : CacheByPreset.TryGetValue(presetId, out HoNprMaterialUiDescriptor descriptor) ? descriptor : null;
        }

        public static IReadOnlyList<string> ValidateAll()
        {
            var errors = new List<string>();
            string packageRoot = FindPackageRoot();
            if (string.IsNullOrEmpty(packageRoot))
            {
                errors.Add("找不到 HoNpr package root。");
                return errors;
            }

            foreach (HoNprMaterialUiDescriptor descriptor in LoadAll(packageRoot, errors))
                ValidateDescriptor(descriptor, packageRoot, errors);

            return errors;
        }

        public static void RebuildTable()
        {
            var errors = new List<string>();
            string packageRoot = FindPackageRoot();
            if (string.IsNullOrEmpty(packageRoot))
            {
                Debug.LogWarning("[HoNpr.MaterialUI] 找不到 HoNpr package root。");
                return;
            }

            List<HoNprMaterialUiDescriptor> descriptors = LoadAll(packageRoot, errors);
            foreach (HoNprMaterialUiDescriptor descriptor in descriptors)
                ValidateDescriptor(descriptor, packageRoot, errors);

            string absoluteRoot = PackageAssetPathToAbsolutePath(packageRoot);
            string tablePath = Path.Combine(absoluteRoot, "ShaderSystem", "MaterialUi", "MATERIAL_UI_TABLE.md");
            Directory.CreateDirectory(Path.GetDirectoryName(tablePath));
            File.WriteAllText(tablePath, BuildTable(descriptors), Encoding.UTF8);
            AssetDatabase.ImportAsset($"{packageRoot}/ShaderSystem/MaterialUi/MATERIAL_UI_TABLE.md", ImportAssetOptions.ForceUpdate | ImportAssetOptions.ForceSynchronousImport);

            if (errors.Count > 0)
                Debug.LogWarning("[HoNpr.MaterialUI] Material UI 表已重建，但存在校验警告：\n" + string.Join("\n", errors));
            else
                Debug.Log($"[HoNpr.MaterialUI] Material UI 表已重建。UI={descriptors.Count}");

            cacheBuilt = false;
        }

        private static void EnsureCache()
        {
            if (cacheBuilt)
                return;

            CacheByPreset.Clear();
            var errors = new List<string>();
            string packageRoot = FindPackageRoot();
            if (!string.IsNullOrEmpty(packageRoot))
            {
                foreach (HoNprMaterialUiDescriptor descriptor in LoadAll(packageRoot, errors))
                {
                    if (!string.IsNullOrEmpty(descriptor.presetId))
                        CacheByPreset[descriptor.presetId] = descriptor;
                }
            }

            cacheBuilt = true;
            if (errors.Count > 0)
                Debug.LogWarning("[HoNpr.MaterialUI] 载入 Material UI 声明时存在警告：\n" + string.Join("\n", errors));
        }

        private static List<HoNprMaterialUiDescriptor> LoadAll(string packageRoot, List<string> errors)
        {
            var descriptors = new List<HoNprMaterialUiDescriptor>();
            foreach (string path in FindFiles(packageRoot, "ShaderSystem/MaterialUi", "*.honprui"))
            {
                HoNprMaterialUiDescriptor descriptor = LoadDescriptor(path, errors);
                if (descriptor != null)
                    descriptors.Add(descriptor);
            }

            descriptors.Sort((a, b) => string.CompareOrdinal(a.id, b.id));
            return descriptors;
        }

        private static HoNprMaterialUiDescriptor LoadDescriptor(string assetPath, List<string> errors)
        {
            string text = ReadAssetText(assetPath);
            if (string.IsNullOrWhiteSpace(text))
            {
                errors.Add($"空 Material UI 声明：{assetPath}");
                return null;
            }

            if (Regex.IsMatch(text, @"(?m)^\s*#(?:include|define|pragma)\b"))
                errors.Add($"{assetPath} 包含禁止的 shader directive。");

            text = StripLineComments(text);
            Match header = Regex.Match(text, @"\bui\s+([A-Za-z0-9_.-]+)\s+for\s+([A-Za-z0-9_.-]+)\s*\{(?<body>.*)\}\s*$", RegexOptions.Singleline);
            if (!header.Success)
            {
                errors.Add($"无法解析 Material UI 声明头：{assetPath}");
                return null;
            }

            var descriptor = new HoNprMaterialUiDescriptor
            {
                id = header.Groups[1].Value,
                presetId = header.Groups[2].Value,
                path = assetPath
            };

            foreach (DslStatement statement in ParseStatements(header.Groups["body"].Value))
            {
                switch (statement.Name)
                {
                    case "group":
                        ParseGroup(descriptor, statement, assetPath, errors);
                        break;
                    case "property":
                        ParseProperty(descriptor, statement, assetPath, errors);
                        break;
                    case "contractBox":
                        ParseContractBox(descriptor, statement, assetPath, errors);
                        break;
                    case "renderState":
                        ParseRenderState(descriptor, statement);
                        break;
                    default:
                        errors.Add($"{assetPath} 包含未知 Material UI statement：{statement.Name}");
                        break;
                }
            }

            return descriptor;
        }

        private static void ParseGroup(HoNprMaterialUiDescriptor descriptor, DslStatement statement, string assetPath, List<string> errors)
        {
            if (statement.Arguments.Count < 2)
            {
                errors.Add($"{assetPath} 的 group 声明缺少 id 或 label。");
                return;
            }

            descriptor.groups.Add(new HoNprMaterialUiGroup
            {
                id = statement.Arguments[0],
                label = statement.Arguments[1]
            });
        }

        private static void ParseProperty(HoNprMaterialUiDescriptor descriptor, DslStatement statement, string assetPath, List<string> errors)
        {
            if (statement.Arguments.Count < 4 || statement.Arguments[1] != "in")
            {
                errors.Add($"{assetPath} 的 property 声明格式错误。");
                return;
            }

            var property = new HoNprMaterialUiProperty
            {
                name = statement.Arguments[0],
                groupId = statement.Arguments[2],
                structuralEffect = "None"
            };

            for (int i = 3; i < statement.Arguments.Count; i++)
            {
                string token = statement.Arguments[i];
                switch (token)
                {
                    case "label":
                        property.label = ReadNext(statement.Arguments, ref i);
                        break;
                    case "control":
                        property.control = ReadNext(statement.Arguments, ref i);
                        break;
                    case "range":
                        property.rangeMin = ReadFloat(ReadNext(statement.Arguments, ref i));
                        property.rangeMax = ReadFloat(ReadNext(statement.Arguments, ref i));
                        break;
                    case "default":
                        property.defaultHint = ReadNext(statement.Arguments, ref i);
                        break;
                    case "copy":
                        property.copyScope = ReadNext(statement.Arguments, ref i);
                        break;
                    case "tools":
                        property.tools.AddRange(statement.Arguments.Skip(i + 1));
                        i = statement.Arguments.Count;
                        break;
                }
            }

            descriptor.properties.Add(property);
        }

        private static void ParseContractBox(HoNprMaterialUiDescriptor descriptor, DslStatement statement, string assetPath, List<string> errors)
        {
            if (statement.Arguments.Count < 3 || statement.Arguments[1] != "in")
            {
                errors.Add($"{assetPath} 的 contractBox 声明格式错误。");
                return;
            }

            var box = new HoNprMaterialUiContractBox
            {
                id = statement.Arguments[0],
                groupId = statement.Arguments[2],
                severity = "info"
            };

            for (int i = 3; i < statement.Arguments.Count; i++)
            {
                switch (statement.Arguments[i])
                {
                    case "title":
                        box.title = ReadNext(statement.Arguments, ref i);
                        break;
                    case "severity":
                        box.severity = ReadNext(statement.Arguments, ref i);
                        break;
                    case "message":
                        box.message = ReadNext(statement.Arguments, ref i);
                        break;
                }
            }

            descriptor.contractBoxes.Add(box);
        }

        private static void ParseRenderState(HoNprMaterialUiDescriptor descriptor, DslStatement statement)
        {
            for (int i = 0; i < statement.Arguments.Count; i++)
            {
                string key = statement.Arguments[i];
                string value = ReadNext(statement.Arguments, ref i);
                switch (key)
                {
                    case "queue":
                        descriptor.renderState.queue = value;
                        break;
                    case "blend":
                        descriptor.renderState.blend = value;
                        break;
                    case "depth":
                        descriptor.renderState.depth = value;
                        break;
                    case "stencil":
                        descriptor.renderState.stencil = value;
                        break;
                    case "cull":
                        descriptor.renderState.cull = value;
                        break;
                }
            }
        }

        private static void ValidateDescriptor(HoNprMaterialUiDescriptor descriptor, string packageRoot, List<string> errors)
        {
            var groupIds = new HashSet<string>(descriptor.groups.Select(group => group.id));
            HashSet<string> shaderProperties = LoadShaderPropertyNames(descriptor, packageRoot, errors);
            foreach (HoNprMaterialUiProperty property in descriptor.properties)
            {
                if (!groupIds.Contains(property.groupId))
                    errors.Add($"{descriptor.id} 的 property {property.name} 引用了不存在的 group {property.groupId}。");
                if (shaderProperties != null && !shaderProperties.Contains(property.name))
                    errors.Add($"{descriptor.id} 的 property {property.name} 没有出现在对应 generated shader 的 Properties 块。");
                if (!string.Equals(property.structuralEffect, "None", StringComparison.Ordinal))
                    errors.Add($"{descriptor.id} 的 property {property.name} StructuralEffect 必须为 None。");
                if (IsForbiddenRenderStateProperty(property.name))
                    errors.Add($"{descriptor.id} 不允许把 render state 暴露为普通参数：{property.name}");
            }

            foreach (HoNprMaterialUiContractBox box in descriptor.contractBoxes)
            {
                if (!groupIds.Contains(box.groupId))
                    errors.Add($"{descriptor.id} 的 contractBox {box.id} 引用了不存在的 group {box.groupId}。");
            }
        }

        private static HashSet<string> LoadShaderPropertyNames(HoNprMaterialUiDescriptor descriptor, string packageRoot, List<string> errors)
        {
            Shader shader = null;
            string shaderPath = FindGeneratedShaderPath(descriptor, packageRoot);
            if (!string.IsNullOrEmpty(shaderPath))
                shader = AssetDatabase.LoadAssetAtPath<Shader>(shaderPath);

            if (shader == null)
                shader = Shader.Find(DeriveGeneratedShaderName(descriptor.presetId));

            if (shader == null)
            {
                errors.Add($"{descriptor.id} 找不到对应 generated shader，无法校验 UI property 白名单。");
                return null;
            }

            var names = new HashSet<string>();
            int propertyCount = shader.GetPropertyCount();
            for (int i = 0; i < propertyCount; i++)
                names.Add(shader.GetPropertyName(i));

            return names;
        }

        private static string FindGeneratedShaderPath(HoNprMaterialUiDescriptor descriptor, string packageRoot)
        {
            string marker = $"// SourcePreset: {descriptor.presetId}";
            foreach (string shaderPath in FindFiles(packageRoot, "Shaders/Generated", "*.shader"))
            {
                string text = ReadAssetText(shaderPath);
                if (!string.IsNullOrEmpty(text) && text.Contains(marker))
                    return shaderPath;
            }

            return null;
        }

        private static string DeriveGeneratedShaderName(string presetId)
        {
            const string prefix = "MaterialPreset.";
            string localName = presetId != null && presetId.StartsWith(prefix, StringComparison.Ordinal)
                ? presetId.Substring(prefix.Length)
                : presetId;
            return "HoNpr/Generated/" + localName;
        }

        private static bool IsForbiddenRenderStateProperty(string name)
        {
            string lower = name.ToLowerInvariant();
            return lower.Contains("queue") || lower.Contains("blend") || lower.Contains("stencil") || lower.Contains("zwrite") ||
                   lower.Contains("ztest") || lower.Contains("cull") || lower.Contains("colormask") || lower.Contains("lightmode");
        }

        private static string BuildTable(IEnumerable<HoNprMaterialUiDescriptor> descriptors)
        {
            var builder = new StringBuilder();
            builder.AppendLine("# Material UI 表");
            builder.AppendLine();
            builder.AppendLine("由 `*.honprui` 自动生成。不要手动编辑表格行。");
            builder.AppendLine();
            builder.AppendLine("| UI ID | Preset | Group | Property | Label | Control | Range | Tools | ContractBox | CopyScope | StructuralEffect |");
            builder.AppendLine("| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |");

            foreach (HoNprMaterialUiDescriptor descriptor in descriptors)
            {
                foreach (HoNprMaterialUiProperty property in descriptor.properties)
                {
                    HoNprMaterialUiGroup group = descriptor.groups.FirstOrDefault(item => item.id == property.groupId);
                    string contractBoxes = string.Join(", ", descriptor.contractBoxes.Where(box => box.groupId == property.groupId).Select(box => Code(box.id)));
                    builder.Append("| ");
                    builder.Append(Code(descriptor.id));
                    builder.Append(" | ");
                    builder.Append(Code(descriptor.presetId));
                    builder.Append(" | ");
                    builder.Append(MarkdownCell(group == null ? property.groupId : group.label));
                    builder.Append(" | ");
                    builder.Append(Code(property.name));
                    builder.Append(" | ");
                    builder.Append(MarkdownCell(property.label));
                    builder.Append(" | ");
                    builder.Append(MarkdownCell(property.control));
                    builder.Append(" | ");
                    builder.Append(MarkdownCell(property.HasRange ? $"{property.rangeMin:g}..{property.rangeMax:g}" : string.Empty));
                    builder.Append(" | ");
                    builder.Append(string.Join(", ", property.tools.Select(Code)));
                    builder.Append(" | ");
                    builder.Append(contractBoxes);
                    builder.Append(" | ");
                    builder.Append(MarkdownCell(property.copyScope));
                    builder.Append(" | None |");
                    builder.AppendLine();
                }
            }

            return builder.ToString();
        }

        private static IEnumerable<string> FindFiles(string packageRoot, string relativeFolder, string searchPattern)
        {
            string packageAbsoluteRoot = PackageAssetPathToAbsolutePath(packageRoot);
            string absoluteFolder = Path.Combine(packageAbsoluteRoot, relativeFolder.Replace('/', Path.DirectorySeparatorChar));
            if (!Directory.Exists(absoluteFolder))
                yield break;

            foreach (string absolutePath in Directory.EnumerateFiles(absoluteFolder, searchPattern, SearchOption.AllDirectories))
            {
                string relativePath = Path.GetRelativePath(packageAbsoluteRoot, absolutePath)
                    .Replace(Path.DirectorySeparatorChar, '/')
                    .Replace(Path.AltDirectorySeparatorChar, '/');
                yield return $"{packageRoot}/{relativePath}";
            }
        }

        private static string FindPackageRoot()
        {
            string[] guids = AssetDatabase.FindAssets("HoNprMaterialUiDatabase t:MonoScript", new[] { "Packages" });
            foreach (string guid in guids)
            {
                string path = AssetDatabase.GUIDToAssetPath(guid);
                if (path.EndsWith(PackageRootMarker, StringComparison.Ordinal))
                    return path.Substring(0, path.Length - PackageRootMarker.Length);
            }

            string localPath = "Assets/HoNpr/Editor/MaterialUi/HoNprMaterialUiDatabase.cs";
            if (File.Exists(AssetPathToAbsolutePath(localPath)))
                return "Assets/HoNpr";

            return "Packages/com.hollow.honpr";
        }

        private static string PackageAssetPathToAbsolutePath(string packageRoot)
        {
            UnityEditor.PackageManager.PackageInfo info = UnityEditor.PackageManager.PackageInfo.FindForAssetPath(packageRoot);
            if (info != null && string.Equals(info.assetPath, packageRoot, StringComparison.OrdinalIgnoreCase))
                return info.resolvedPath;

            return AssetPathToAbsolutePath(packageRoot);
        }

        private static string AssetPathToAbsolutePath(string assetPath)
        {
            string projectRoot = Directory.GetParent(Application.dataPath).FullName;
            return Path.GetFullPath(Path.Combine(projectRoot, assetPath));
        }

        private static string ReadAssetText(string assetPath)
        {
            TextAsset asset = AssetDatabase.LoadAssetAtPath<TextAsset>(assetPath);
            if (asset != null)
                return asset.text;

            string absolutePath = AssetPathToAbsolutePath(assetPath);
            return File.Exists(absolutePath) ? File.ReadAllText(absolutePath, Encoding.UTF8) : null;
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

        private static List<DslStatement> ParseStatements(string body)
        {
            var statements = new List<DslStatement>();
            foreach (string part in SplitStatements(body))
            {
                List<string> tokens = Tokens(part);
                if (tokens.Count == 0)
                    continue;

                statements.Add(new DslStatement { Name = tokens[0], Arguments = tokens.Skip(1).ToList() });
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

        private static List<string> Tokens(string text)
        {
            var tokens = new List<string>();
            foreach (Match match in Regex.Matches(text, @"""([^""]*)""|[A-Za-z0-9_.\-/<>]+|\([^)]+\)"))
            {
                string value = match.Groups[1].Success ? match.Groups[1].Value : match.Value;
                tokens.Add(value.Trim());
            }

            return tokens;
        }

        private static string ReadNext(IReadOnlyList<string> values, ref int index)
        {
            index++;
            return index < values.Count ? values[index] : string.Empty;
        }

        private static float ReadFloat(string value)
        {
            return float.TryParse(value, NumberStyles.Float, CultureInfo.InvariantCulture, out float result) ? result : 0f;
        }

        private static string Code(string value)
        {
            return string.IsNullOrEmpty(value) ? string.Empty : $"`{MarkdownCell(value)}`";
        }

        private static string MarkdownCell(string value)
        {
            return string.IsNullOrEmpty(value) ? string.Empty : value.Replace("|", "\\|").Replace("\r", " ").Replace("\n", " ");
        }

        private sealed class DslStatement
        {
            public string Name;
            public List<string> Arguments;
        }
    }

    internal sealed class HoNprMaterialUiDescriptor
    {
        public string id;
        public string presetId;
        public string path;
        public readonly List<HoNprMaterialUiGroup> groups = new List<HoNprMaterialUiGroup>();
        public readonly List<HoNprMaterialUiProperty> properties = new List<HoNprMaterialUiProperty>();
        public readonly List<HoNprMaterialUiContractBox> contractBoxes = new List<HoNprMaterialUiContractBox>();
        public readonly HoNprMaterialUiRenderState renderState = new HoNprMaterialUiRenderState();
    }

    internal sealed class HoNprMaterialUiGroup
    {
        public string id;
        public string label;
    }

    internal sealed class HoNprMaterialUiProperty
    {
        public string name;
        public string groupId;
        public string label;
        public string control;
        public string copyScope;
        public string defaultHint;
        public string structuralEffect;
        public float rangeMin;
        public float rangeMax;
        public readonly List<string> tools = new List<string>();
        public bool HasRange => !Mathf.Approximately(rangeMin, rangeMax);
    }

    internal sealed class HoNprMaterialUiContractBox
    {
        public string id;
        public string groupId;
        public string title;
        public string severity;
        public string message;
    }

    internal sealed class HoNprMaterialUiRenderState
    {
        public string queue;
        public string blend;
        public string depth;
        public string stencil;
        public string cull;
    }
}

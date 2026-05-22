using System.Collections.Generic;
using System.IO;
using UnityEditor;
using UnityEngine;

namespace Hollow.HoNpr.Editor
{
    internal static class HoNprGeneratorEditorUtils
    {
        private const string MenuPathAssets = "Assets/HoNpr/Generator/";
        private const string MenuPathForceRegenerate = MenuPathAssets + "[Shader] Force regenerate generated shaders";
        private const string MenuPathRefreshGenerated = MenuPathAssets + "[Shader] Refresh generated shader assets";
        private const string MenuPathValidateTables = MenuPathAssets + "[Validation] Validate shader system tables";
        private const string MenuPathRebuildManifests = MenuPathAssets + "[Manifest] Rebuild generated manifests";
        private const int MenuPriorityGenerator = 1120;
        private const int MenuPriorityRefresh = MenuPriorityGenerator + 1;
        private const int MenuPriorityValidation = MenuPriorityGenerator + 10;
        private const int MenuPriorityManifest = MenuPriorityGenerator + 20;
        private const string ScriptName = "HoNprGeneratorEditorUtils";

        private static readonly string[] RequiredFolders =
        {
            "ShaderSystem",
            "ShaderSystem/Contract",
            "ShaderSystem/Templates",
            "ShaderSystem/FeatureBlocks",
            "ShaderSystem/Presets",
            "ShaderSystem/Generator",
            "ShaderSystem/GeneratedManifests",
            "ShaderSystem/LegacyInterop",
            "Shaders/Generated"
        };

        private static readonly string[] RequiredFiles =
        {
            "ShaderSystem/README.md",
            "ShaderSystem/Contract/HORP_CONTRACT_INDEX.md",
            "ShaderSystem/Templates/TEMPLATE_TABLE.md",
            "ShaderSystem/FeatureBlocks/FEATURE_BLOCK_TABLE.md",
            "ShaderSystem/Presets/PRESET_TABLE.md",
            "ShaderSystem/Generator/GENERATOR_RULES.md",
            "ShaderSystem/Generator/SourceMapping.md",
            "ShaderSystem/Generator/ValidationRules.md",
            "ShaderSystem/GeneratedManifests/GENERATED_TABLE.md",
            "ShaderSystem/LegacyInterop/LEGACY_MAPPING_TABLE.md",
            "Shaders/Generated/GENERATED_TABLE.md"
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

            bool valid = ValidateShaderSystem(packageRoot, false);
            int generatedCount = GeneratePrototypeShaders(packageRoot);
            RebuildGeneratedManifests(packageRoot, false);
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

        [MenuItem(MenuPathValidateTables, false, MenuPriorityValidation)]
        private static void ValidateShaderSystemTables()
        {
            string packageRoot = FindPackageRoot();
            if (string.IsNullOrEmpty(packageRoot))
            {
                Debug.LogWarning("[HoNpr.Generator] Could not find the package root.");
                return;
            }

            ValidateShaderSystem(packageRoot, true);
        }

        [MenuItem(MenuPathRebuildManifests, false, MenuPriorityManifest)]
        private static void RebuildGeneratedManifests()
        {
            string packageRoot = FindPackageRoot();
            if (string.IsNullOrEmpty(packageRoot))
            {
                Debug.LogWarning("[HoNpr.Generator] Could not find the package root.");
                return;
            }

            RebuildGeneratedManifests(packageRoot, true);
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
                if (AssetDatabase.LoadAssetAtPath<TextAsset>(path) == null)
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
                Debug.Log("[HoNpr.Generator] Shader system declaration tables are present.");

            return true;
        }

        private static void ValidateDeclarationReferences(string packageRoot, List<string> errors)
        {
            var templates = new HashSet<string>();
            var blocks = new HashSet<string>();

            foreach (string path in FindFiles(packageRoot, "ShaderSystem/Templates", "*.template"))
            {
                IdDeclaration declaration = LoadJsonAsset<IdDeclaration>(path);
                if (declaration == null || string.IsNullOrEmpty(declaration.id))
                    errors.Add($"Template is missing id: {path}");
                else
                    templates.Add(declaration.id);
            }

            foreach (string path in FindFiles(packageRoot, "ShaderSystem/FeatureBlocks", "*.block.json"))
            {
                IdDeclaration declaration = LoadJsonAsset<IdDeclaration>(path);
                if (declaration == null || string.IsNullOrEmpty(declaration.id))
                    errors.Add($"Feature block is missing id: {path}");
                else
                    blocks.Add(declaration.id);
            }

            foreach (string path in FindFiles(packageRoot, "ShaderSystem/Presets", "*.preset.json"))
            {
                PrototypePreset preset = LoadJsonAsset<PrototypePreset>(path);
                if (preset == null || string.IsNullOrEmpty(preset.presetId))
                {
                    errors.Add($"Preset is missing presetId: {path}");
                    continue;
                }

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

        private static IEnumerable<string> FindFiles(string packageRoot, string relativeFolder, string searchPattern)
        {
            string absoluteFolder = Path.Combine(PackageAssetPathToAbsolutePath(packageRoot), NormalizeRelativePath(relativeFolder));
            if (!Directory.Exists(absoluteFolder))
                yield break;

            foreach (string absolutePath in Directory.EnumerateFiles(absoluteFolder, searchPattern, SearchOption.AllDirectories))
            {
                string relativePath = Path.GetRelativePath(PackageAssetPathToAbsolutePath(packageRoot), absolutePath)
                    .Replace(Path.DirectorySeparatorChar, '/')
                    .Replace(Path.AltDirectorySeparatorChar, '/');
                yield return $"{packageRoot}/{relativePath}";
            }
        }

        private static IEnumerable<string> FindTextAssets(string root, string filter)
        {
            if (!AssetDatabase.IsValidFolder(root))
                yield break;

            string[] guids = AssetDatabase.FindAssets(filter, new[] { root });
            foreach (string guid in guids)
            {
                string path = AssetDatabase.GUIDToAssetPath(guid);
                if (!string.IsNullOrEmpty(path))
                    yield return path;
            }
        }

        private static T LoadJsonAsset<T>(string path)
        {
            TextAsset asset = AssetDatabase.LoadAssetAtPath<TextAsset>(path);
            if (asset != null)
                return JsonUtility.FromJson<T>(asset.text);

            string absolutePath = Path.Combine(Directory.GetCurrentDirectory(), path.Replace('/', Path.DirectorySeparatorChar));
            if (!File.Exists(absolutePath))
                return default;

            return JsonUtility.FromJson<T>(File.ReadAllText(absolutePath));
        }

        private static int RefreshGeneratedShaderAssets(string packageRoot, bool logSkippedFolders)
        {
            var importedPaths = new List<string>();
            ImportAssets($"{packageRoot}/Shaders/Generated", "t:Shader", importedPaths, logSkippedFolders);
            ImportAssets($"{packageRoot}/Shaders/Generated", "t:TextAsset", importedPaths, logSkippedFolders);
            ImportAssets($"{packageRoot}/ShaderSystem/GeneratedManifests", "t:TextAsset", importedPaths, logSkippedFolders);
            return importedPaths.Count;
        }

        private static int GeneratePrototypeShaders(string packageRoot)
        {
            string presetPath = $"{packageRoot}/ShaderSystem/Presets/Debug/Character_DebugLit_SSS_OITReady.preset.json";
            TextAsset presetAsset = AssetDatabase.LoadAssetAtPath<TextAsset>(presetPath);
            if (presetAsset == null)
            {
                Debug.LogWarning($"[HoNpr.Generator] Could not find preset at {presetPath}.");
                return 0;
            }

            PrototypePreset preset = JsonUtility.FromJson<PrototypePreset>(presetAsset.text);
            if (preset == null || string.IsNullOrEmpty(preset.generatedShader) || string.IsNullOrEmpty(preset.shaderName))
            {
                Debug.LogWarning($"[HoNpr.Generator] Preset is missing generated shader metadata: {presetPath}.");
                return 0;
            }

            string absolutePackageRoot = PackageAssetPathToAbsolutePath(packageRoot);
            string shaderAbsolutePath = Path.Combine(absolutePackageRoot, NormalizeRelativePath(preset.generatedShader));
            Directory.CreateDirectory(Path.GetDirectoryName(shaderAbsolutePath));

            File.WriteAllText(shaderAbsolutePath, BuildDebugLitShader(preset), System.Text.Encoding.UTF8);
            WriteGeneratedManifest(absolutePackageRoot, preset);
            return 1;
        }

        private static void WriteGeneratedManifest(string absolutePackageRoot, PrototypePreset preset)
        {
            string manifestAbsolutePath = Path.Combine(
                absolutePackageRoot,
                "ShaderSystem",
                "GeneratedManifests",
                "Character_DebugLit_SSS_OITReady.generated.md");
            Directory.CreateDirectory(Path.GetDirectoryName(manifestAbsolutePath));

            string blockList = preset.featureBlocks == null ? string.Empty : string.Join(", ", preset.featureBlocks);
            string content =
                "# Character DebugLit SSS OITReady Generated Manifest\n\n" +
                $"| Field | Value |\n" +
                $"| --- | --- |\n" +
                $"| Preset | `{preset.presetId}` |\n" +
                $"| Template | `{preset.template}` |\n" +
                $"| Generated Shader | `{preset.generatedShader}` |\n" +
                $"| Feature Blocks | `{blockList}` |\n" +
                $"| Generator | `HoNprGeneratorEditorUtils` |\n" +
                $"| Status | `{preset.status}` |\n";

            File.WriteAllText(manifestAbsolutePath, content, System.Text.Encoding.UTF8);
        }

        private static string PackageAssetPathToAbsolutePath(string packageRoot)
        {
            string normalizedRoot = packageRoot.Replace('/', Path.DirectorySeparatorChar);
            return Path.GetFullPath(Path.Combine(Directory.GetCurrentDirectory(), normalizedRoot));
        }

        private static string NormalizeRelativePath(string path)
        {
            return path.Replace('/', Path.DirectorySeparatorChar).Replace('\\', Path.DirectorySeparatorChar);
        }

        private static void RebuildGeneratedManifests(string packageRoot, bool logSuccess)
        {
            var importedPaths = new List<string>();
            ImportAssets($"{packageRoot}/ShaderSystem/GeneratedManifests", "t:TextAsset", importedPaths, false);

            if (logSuccess)
                Debug.Log($"[HoNpr.Generator] Rebuilt generated manifest index placeholder. Imported {importedPaths.Count} manifest assets.");
        }

        private static string BuildDebugLitShader(PrototypePreset preset)
        {
            string blockList = preset.featureBlocks == null ? string.Empty : string.Join(", ", preset.featureBlocks);
            return
$@"// Generated by HoNprShaderGenerator.
// SourcePreset: {preset.presetId}
// Template: {preset.template}
// Blocks: {blockList}
// Manifest: ShaderSystem/GeneratedManifests/Character_DebugLit_SSS_OITReady.generated.md
// Do not edit generated body by hand. Edit template/block/preset instead.
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

        [System.Serializable]
        private sealed class IdDeclaration
        {
            public string id;
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

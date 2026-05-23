using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

namespace Hollow.HoNpr.Editor
{
    internal static class HoNprHoToonEditorUtils
    {
        private const string MenuPathAssets = "Assets/HoNpr/HoToon/";
        private const string MenuPathRefreshShaders = MenuPathAssets + "[Shader] 刷新 Shader";
        private const string MenuPathApplyTextureSettings = MenuPathAssets + "[贴图] 应用导入设置";
        private const string MenuPathSelectTextures = MenuPathAssets + "[贴图] 选择贴图文件夹";
        private const int MenuPriorityAssets = 1100;
        private const int MenuPriorityTextureSettings = MenuPriorityAssets + 10;
        private const int MenuPriorityTextures = MenuPriorityAssets + 11;
        private const string ScriptName = "HoNprHoToonEditorUtils";

        [MenuItem(MenuPathRefreshShaders, false, MenuPriorityAssets)]
        private static void RefreshShaders()
        {
            string packageRoot = FindPackageRoot();
            if (string.IsNullOrEmpty(packageRoot))
            {
                Debug.LogWarning("[HoNpr.HoToon] 找不到 HoNpr package root。");
                return;
            }

            string shaderRoot = $"{packageRoot}/Shaders";
            string textureRoot = $"{packageRoot}/Textures/Halftone";
            var importedPaths = new List<string>();

            ImportAssets(shaderRoot, "t:Shader", importedPaths);
            ImportAssets(shaderRoot, "t:TextAsset", importedPaths);
            ImportAssets(textureRoot, "t:Texture", importedPaths);

            AssetDatabase.SaveAssets();
            AssetDatabase.Refresh();

            Debug.Log($"[HoNpr.HoToon] 已刷新 {importedPaths.Count} 个包资源。");
        }

        [MenuItem(MenuPathApplyTextureSettings, false, MenuPriorityTextureSettings)]
        private static void ApplyTextureImportSettings()
        {
            string packageRoot = FindPackageRoot();
            if (string.IsNullOrEmpty(packageRoot))
            {
                Debug.LogWarning("[HoNpr.HoToon] 找不到 HoNpr package root。");
                return;
            }

            string textureRoot = $"{packageRoot}/Textures/Halftone";
            if (!AssetDatabase.IsValidFolder(textureRoot))
            {
                Debug.LogWarning($"[HoNpr.HoToon] 找不到贴图目录：{textureRoot}");
                return;
            }

            int count = 0;
            string[] guids = AssetDatabase.FindAssets("t:Texture", new[] { textureRoot });
            foreach (string guid in guids)
            {
                string path = AssetDatabase.GUIDToAssetPath(guid);
                TextureImporter importer = AssetImporter.GetAtPath(path) as TextureImporter;
                if (importer == null)
                    continue;

                HoNprHoToonTextureImportSettings.Apply(importer);
                importer.SaveAndReimport();
                count++;
            }

            AssetDatabase.SaveAssets();
            AssetDatabase.Refresh();
            Debug.Log($"[HoNpr.HoToon] 已为 {count} 个贴图资源应用导入设置。");
        }

        [MenuItem(MenuPathSelectTextures, false, MenuPriorityTextures)]
        private static void SelectTexturesFolder()
        {
            string packageRoot = FindPackageRoot();
            if (string.IsNullOrEmpty(packageRoot))
            {
                Debug.LogWarning("[HoNpr.HoToon] 找不到 HoNpr package root。");
                return;
            }

            string textureRoot = $"{packageRoot}/Textures/Halftone";
            Object textureFolder = AssetDatabase.LoadAssetAtPath<Object>(textureRoot);
            if (textureFolder == null)
            {
                Debug.LogWarning($"[HoNpr.HoToon] 找不到贴图目录：{textureRoot}");
                return;
            }

            Selection.activeObject = textureFolder;
            EditorGUIUtility.PingObject(textureFolder);
        }

        private static string FindPackageRoot()
        {
            string[] guids = AssetDatabase.FindAssets($"{ScriptName} t:MonoScript", new[] { "Packages" });
            foreach (string guid in guids)
            {
                string path = AssetDatabase.GUIDToAssetPath(guid);
                const string marker = "/Editor/HoNprHoToonEditorUtils.cs";
                if (path.EndsWith(marker))
                    return path.Substring(0, path.Length - marker.Length);
            }

            return null;
        }

        private static void ImportAssets(string root, string filter, List<string> importedPaths)
        {
            if (!AssetDatabase.IsValidFolder(root))
                return;

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

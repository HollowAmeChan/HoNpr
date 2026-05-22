using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

namespace Hollow.HoNpr.Editor
{
    internal static class HoNprHoToonEditorUtils
    {
        private const string MenuPathAssets = "Assets/HoNpr/HoToon/";
        private const string MenuPathRefreshShaders = MenuPathAssets + "[Shader] Refresh shaders";
        private const string MenuPathApplyTextureSettings = MenuPathAssets + "[Texture] Apply import settings";
        private const string MenuPathSelectTextures = MenuPathAssets + "[Texture] Select textures folder";
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
                Debug.LogWarning("[HoNpr.HoToon] Could not find the package root.");
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

            Debug.Log($"[HoNpr.HoToon] Refreshed {importedPaths.Count} package assets.");
        }

        [MenuItem(MenuPathApplyTextureSettings, false, MenuPriorityTextureSettings)]
        private static void ApplyTextureImportSettings()
        {
            string packageRoot = FindPackageRoot();
            if (string.IsNullOrEmpty(packageRoot))
            {
                Debug.LogWarning("[HoNpr.HoToon] Could not find the package root.");
                return;
            }

            string textureRoot = $"{packageRoot}/Textures/Halftone";
            if (!AssetDatabase.IsValidFolder(textureRoot))
            {
                Debug.LogWarning($"[HoNpr.HoToon] Could not find texture folder at {textureRoot}.");
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
            Debug.Log($"[HoNpr.HoToon] Applied import settings to {count} texture assets.");
        }

        [MenuItem(MenuPathSelectTextures, false, MenuPriorityTextures)]
        private static void SelectTexturesFolder()
        {
            string packageRoot = FindPackageRoot();
            if (string.IsNullOrEmpty(packageRoot))
            {
                Debug.LogWarning("[HoNpr.HoToon] Could not find the package root.");
                return;
            }

            string textureRoot = $"{packageRoot}/Textures/Halftone";
            Object textureFolder = AssetDatabase.LoadAssetAtPath<Object>(textureRoot);
            if (textureFolder == null)
            {
                Debug.LogWarning($"[HoNpr.HoToon] Could not find texture folder at {textureRoot}.");
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

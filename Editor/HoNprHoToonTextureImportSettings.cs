using UnityEditor;

namespace Hollow.HoNpr.Editor
{
    internal static class HoNprHoToonTextureImportSettings
    {
        private static readonly string[] PlatformNames =
        {
            "DefaultTexturePlatform",
            "Standalone",
            "Android",
            "iPhone",
            "WebGL"
        };

        internal static bool IsHoToonHalftoneTexture(string assetPath)
        {
            if (string.IsNullOrEmpty(assetPath) || !assetPath.EndsWith(".png"))
                return false;

            string normalizedPath = assetPath.Replace('\\', '/');
            return normalizedPath.Contains("/Textures/Halftone/");
        }

        internal static void Apply(TextureImporter importer)
        {
            importer.textureType = TextureImporterType.SingleChannel;
            SetSingleChannelComponentRed(importer);
            importer.mipmapEnabled = false;
            importer.sRGBTexture = false;
            importer.alphaSource = TextureImporterAlphaSource.None;
            importer.alphaIsTransparency = false;
            importer.npotScale = TextureImporterNPOTScale.None;
            importer.filterMode = UnityEngine.FilterMode.Point;
            importer.wrapMode = UnityEngine.TextureWrapMode.Repeat;
            importer.anisoLevel = 0;
            importer.mipmapFilter = TextureImporterMipFilter.BoxFilter;
            importer.textureCompression = TextureImporterCompression.Uncompressed;
            importer.crunchedCompression = false;
            importer.compressionQuality = 100;
            importer.maxTextureSize = 8192;

            foreach (string platformName in PlatformNames)
            {
                SetPlatform(importer, platformName);
            }

            importer.ClearPlatformTextureSettings("iOS");
        }

        private static void SetPlatform(TextureImporter importer, string platformName)
        {
            TextureImporterPlatformSettings settings = importer.GetPlatformTextureSettings(platformName);
            settings.name = platformName;
            settings.overridden = true;
            settings.maxTextureSize = 8192;
            settings.resizeAlgorithm = TextureResizeAlgorithm.Mitchell;
            settings.format = TextureImporterFormat.Automatic;
            settings.textureCompression = TextureImporterCompression.Uncompressed;
            settings.compressionQuality = 100;
            settings.crunchedCompression = false;
            importer.SetPlatformTextureSettings(settings);
        }

        private static void SetSingleChannelComponentRed(TextureImporter importer)
        {
            var serializedImporter = new SerializedObject(importer);
            SerializedProperty component = serializedImporter.FindProperty("singleChannelComponent");
            if (component == null)
                return;

            component.intValue = 1;
            serializedImporter.ApplyModifiedPropertiesWithoutUndo();
        }
    }

    internal sealed class HoNprHoToonTexturePostprocessor : AssetPostprocessor
    {
        private void OnPreprocessTexture()
        {
            if (!HoNprHoToonTextureImportSettings.IsHoToonHalftoneTexture(assetPath))
                return;

            HoNprHoToonTextureImportSettings.Apply((TextureImporter)assetImporter);
        }
    }
}

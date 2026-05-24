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

        internal static bool IsHoToonTextureWithFixedImportSettings(string assetPath)
        {
            if (string.IsNullOrEmpty(assetPath) || !assetPath.EndsWith(".png"))
                return false;

            return IsHoToonHalftoneTexture(assetPath) || IsHoToonRampTexture(assetPath);
        }

        internal static bool IsHoToonHalftoneTexture(string assetPath)
        {
            string normalizedPath = assetPath.Replace('\\', '/');
            return normalizedPath.Contains("/Textures/Halftone/");
        }

        internal static bool IsHoToonRampTexture(string assetPath)
        {
            string normalizedPath = assetPath.Replace('\\', '/');
            return normalizedPath.Contains("/Textures/Ramps/");
        }

        internal static void Apply(string assetPath, TextureImporter importer)
        {
            bool isRamp = IsHoToonRampTexture(assetPath);
            if (IsHoToonHalftoneTexture(assetPath))
            {
                importer.textureType = TextureImporterType.SingleChannel;
                SetSingleChannelComponentRed(importer);
                importer.wrapMode = UnityEngine.TextureWrapMode.Repeat;
            }
            else
            {
                importer.textureType = TextureImporterType.Default;
                SetSingleChannelComponentRgb(importer);
                importer.wrapMode = UnityEngine.TextureWrapMode.Clamp;
            }

            importer.mipmapEnabled = false;
            importer.sRGBTexture = false;
            importer.alphaSource = TextureImporterAlphaSource.None;
            importer.alphaIsTransparency = false;
            importer.npotScale = TextureImporterNPOTScale.None;
            importer.filterMode = isRamp ? UnityEngine.FilterMode.Bilinear : UnityEngine.FilterMode.Point;
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

        internal static void Apply(TextureImporter importer)
        {
            Apply("/Textures/Halftone/", importer);
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
            SetSingleChannelComponent(importer, 1);
        }

        private static void SetSingleChannelComponentRgb(TextureImporter importer)
        {
            SetSingleChannelComponent(importer, 0);
        }

        private static void SetSingleChannelComponent(TextureImporter importer, int value)
        {
            var serializedImporter = new SerializedObject(importer);
            SerializedProperty component = serializedImporter.FindProperty("singleChannelComponent");
            if (component == null)
                return;

            component.intValue = value;
            serializedImporter.ApplyModifiedPropertiesWithoutUndo();
        }
    }

    internal sealed class HoNprHoToonTexturePostprocessor : AssetPostprocessor
    {
        private void OnPreprocessTexture()
        {
            if (!HoNprHoToonTextureImportSettings.IsHoToonTextureWithFixedImportSettings(assetPath))
                return;

            HoNprHoToonTextureImportSettings.Apply(assetPath, (TextureImporter)assetImporter);
        }
    }
}

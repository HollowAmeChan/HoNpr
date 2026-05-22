using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

namespace Hollow.HoNpr.Editor.MaterialUi
{
    internal static class HoNprMaterialUiEditorUtils
    {
        private const string MenuPathAssets = "Assets/HoNpr/Material UI/";
        private const int MenuPriority = 1160;

        [MenuItem(MenuPathAssets + "[Documentation] Rebuild material UI table", false, MenuPriority)]
        private static void RebuildMaterialUiTable()
        {
            HoNprMaterialUiDatabase.RebuildTable();
            AssetDatabase.SaveAssets();
            AssetDatabase.Refresh();
        }

        [MenuItem(MenuPathAssets + "[Validation] Validate material UI declarations", false, MenuPriority + 10)]
        private static void ValidateMaterialUiDeclarations()
        {
            IReadOnlyList<string> errors = HoNprMaterialUiDatabase.ValidateAll();
            if (errors.Count == 0)
            {
                Debug.Log("[HoNpr.MaterialUI] Material UI 声明有效。");
                return;
            }

            Debug.LogWarning("[HoNpr.MaterialUI] Material UI 声明存在问题：\n" + string.Join("\n", errors));
        }
    }
}

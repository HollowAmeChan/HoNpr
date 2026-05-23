using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

namespace Hollow.HoNpr.Editor.MaterialUi
{
    internal static class HoNprMaterialUiEditorUtils
    {
        private const string MenuPathAssets = "Assets/HoNpr/材质 UI/";
        private const int MenuPriority = 1160;

        [MenuItem(MenuPathAssets + "[文档] 重建材质 UI 表", false, MenuPriority)]
        private static void RebuildMaterialUiTable()
        {
            HoNprMaterialUiDatabase.RebuildTable();
            AssetDatabase.SaveAssets();
            AssetDatabase.Refresh();
        }

        [MenuItem(MenuPathAssets + "[校验] 校验材质 UI 声明", false, MenuPriority + 10)]
        private static void ValidateMaterialUiDeclarations()
        {
            IReadOnlyList<string> errors = HoNprMaterialUiDatabase.ValidateAll();
            if (errors.Count == 0)
            {
                Debug.Log("[HoNpr.MaterialUI] 材质 UI 声明有效。");
                return;
            }

            Debug.LogWarning("[HoNpr.MaterialUI] 材质 UI 声明存在问题：\n" + string.Join("\n", errors));
        }
    }
}

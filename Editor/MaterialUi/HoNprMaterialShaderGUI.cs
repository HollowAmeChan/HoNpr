using System;
using System.Collections.Generic;
using System.Globalization;
using System.Text;
using UnityEditor;
using UnityEngine;

namespace Hollow.HoNpr.Editor.MaterialUi
{
    public sealed class HoNprMaterialShaderGUI : ShaderGUI
    {
        private const string SourcePresetPrefix = "MaterialPreset.";
        private const string ShowPerPropertyToolsKey = "HoNpr.MaterialUI.ShowPerPropertyTools";
        private const string FoldoutKeyPrefix = "HoNpr.MaterialUI.Foldout.";
        private const float FoldoutHeaderHeight = 30f;
        private const float SectionSpacing = 0f;
        private const float ContractHeaderWidthRatio = 0.72f;
        private const float ContractHeaderMinWidth = 300f;
        private const float ContractHeaderMaxWidth = 560f;
        private const float ToolButtonWidth = 22f;
        private const float GroupToolButtonWidth = 24f;
        private const float HeaderToggleWidth = 24f;
        private const float HeaderButtonSpacing = 4f;

        private static bool showPerPropertyTools = EditorPrefs.GetBool(ShowPerPropertyToolsKey, false);
        private static GUIStyle foldoutHeaderLabelStyle;
        private static GUIStyle compactBoxStyle;
        private static GUIStyle compactContentStyle;

        private enum MaterialUiIcon
        {
            Copy,
            Paste,
            Reset,
            Tools
        }

        public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
        {
            Material material = materialEditor.target as Material;
            if (material == null)
            {
                base.OnGUI(materialEditor, properties);
                return;
            }

            string presetId = GetPresetId(material);
            HoNprMaterialUiDescriptor descriptor = HoNprMaterialUiDatabase.GetForPreset(presetId);
            if (descriptor == null)
            {
                EditorGUILayout.HelpBox($"找不到 {presetId} 对应的 HoNpr 材质 UI 声明。", MessageType.Warning);
                base.OnGUI(materialEditor, properties);
                return;
            }

            DrawHeader(descriptor);

            var drawn = new HashSet<string>();
            foreach (HoNprMaterialUiGroup group in descriptor.groups)
                DrawGroup(materialEditor, material, properties, descriptor, group, drawn);

            DrawUndeclaredProperties(materialEditor, properties, drawn);
            DrawRenderState(material, descriptor);
        }

        private static void DrawHeader(HoNprMaterialUiDescriptor descriptor)
        {
            EditorGUILayout.BeginHorizontal();
            EditorGUILayout.LabelField("HoNpr 材质 UI", EditorStyles.boldLabel);

            if (DrawFlatIconButton(MaterialUiIcon.Tools, HeaderToggleWidth, showPerPropertyTools, "显示/隐藏每个参数旁边的复制/粘贴按钮。"))
            {
                showPerPropertyTools = !showPerPropertyTools;
                EditorPrefs.SetBool(ShowPerPropertyToolsKey, showPerPropertyTools);
            }

            EditorGUILayout.EndHorizontal();
            EditorGUILayout.LabelField(new GUIContent("Preset", "pass、block、keyword、render state 由 preset / template 固定。"), new GUIContent(descriptor.presetId));
        }

        private static void DrawRenderState(Material material, HoNprMaterialUiDescriptor descriptor)
        {
            EditorGUILayout.Space(SectionSpacing);
            EditorGUILayout.BeginVertical(GetCompactBoxStyle());
            Color headerColor = StableColor("renderstate:" + descriptor.presetId);
            bool expanded = DrawFoldoutHeader(
                "renderstate:" + descriptor.presetId,
                "Render State View（只读）",
                headerColor,
                true,
                "由 preset / template 固定；这里仅显示当前声明的渲染状态。");
            if (!expanded)
            {
                EditorGUILayout.EndVertical();
                return;
            }

            BeginTintedContent(headerColor);
            DrawRenderStateField("Queue", descriptor.renderState.queue, false);
            DrawRenderStateField("Blend", descriptor.renderState.blend, true);
            DrawRenderStateField("Depth", descriptor.renderState.depth, true);
            DrawRenderStateField("Stencil", descriptor.renderState.stencil, true);
            DrawRenderStateField("Cull", descriptor.renderState.cull, false);

            if (material.renderQueue != -1)
                EditorGUILayout.HelpBox($"当前材质实例存在 render queue override：{material.renderQueue}。这是材质实例覆盖，不是 preset render state 声明；HoNpr 建议让 queue 由 preset/template 固定。", MessageType.Warning);
            EndTintedContent();

            EditorGUILayout.EndVertical();
        }

        private static void DrawRenderStateField(string label, string value, bool expand)
        {
            value = string.IsNullOrEmpty(value) ? "未声明" : value;
            if (!expand)
            {
                EditorGUILayout.LabelField(label, value);
                return;
            }

            string[] parts = SplitRenderStateValue(value);
            EditorGUILayout.BeginHorizontal();
            EditorGUILayout.LabelField(label, GUILayout.Width(EditorGUIUtility.labelWidth - 4f));
            EditorGUILayout.BeginVertical();
            foreach (string part in parts)
            {
                GUIContent content = new GUIContent(parts.Length > 1 ? "• " + part : part);
                Rect rect = EditorGUILayout.GetControlRect(false, EditorStyles.wordWrappedLabel.CalcHeight(content, EditorGUIUtility.currentViewWidth - EditorGUIUtility.labelWidth - 28f));
                EditorGUI.LabelField(rect, content, EditorStyles.wordWrappedLabel);
            }
            EditorGUILayout.EndVertical();
            EditorGUILayout.EndHorizontal();
        }

        private static string[] SplitRenderStateValue(string value)
        {
            string[] rawParts = value.Split(new[] { "; ", " / ", ", " }, StringSplitOptions.RemoveEmptyEntries);
            for (int i = 0; i < rawParts.Length; i++)
                rawParts[i] = rawParts[i].Trim();

            return rawParts.Length == 0 ? new[] { value } : rawParts;
        }

        private static void DrawGroup(
            MaterialEditor materialEditor,
            Material material,
            MaterialProperty[] properties,
            HoNprMaterialUiDescriptor descriptor,
            HoNprMaterialUiGroup group,
            HashSet<string> drawn)
        {
            EditorGUILayout.Space(SectionSpacing);
            EditorGUILayout.BeginVertical(GetCompactBoxStyle());
            bool canCopyGroup = GroupHasTool(descriptor, group, "CopyProperty");
            bool canPasteGroup = GroupHasTool(descriptor, group, "PasteProperty");
            bool canResetGroup = GroupHasTool(descriptor, group, "ResetGroup");
            bool groupHasContract = GroupHasContract(descriptor, group);
            Color headerColor = groupHasContract ? StableColor(group.id) : NeutralHeaderColor();
            bool expanded = DrawFoldoutHeader(
                "group:" + descriptor.presetId + ":" + group.id,
                group.label,
                headerColor,
                true,
                "材质参数分组。",
                false,
                (ref Rect rect) =>
                {
                    if (canCopyGroup && DrawHeaderIconButton(ref rect, MaterialUiIcon.Copy, "复制整组参数"))
                        CopyGroup(material, descriptor, group);
                    if (canPasteGroup && DrawHeaderIconButton(ref rect, MaterialUiIcon.Paste, "粘贴整组参数"))
                        PasteGroup(material, descriptor, group);
                    if (canResetGroup && DrawHeaderIconButton(ref rect, MaterialUiIcon.Reset, "按声明默认值重置整组"))
                        ResetGroup(material, descriptor, group);
                },
                CountHeaderButtons(canCopyGroup, canPasteGroup, canResetGroup));

            if (!expanded)
            {
                MarkGroupPropertiesAsDeclared(properties, descriptor, group, drawn);
                EditorGUILayout.EndVertical();
                return;
            }

            foreach (HoNprMaterialUiContractBox box in descriptor.contractBoxes)
            {
                if (box.groupId == group.id)
                    DrawContractBox(box, headerColor);
            }

            BeginTintedContent(headerColor, groupHasContract);
            foreach (HoNprMaterialUiProperty property in descriptor.properties)
            {
                if (property.groupId != group.id)
                    continue;

                MaterialProperty materialProperty = FindMaterialProperty(property.name, properties);
                if (materialProperty == null)
                {
                    EditorGUILayout.HelpBox($"缺少属性：{property.name}", MessageType.Warning);
                    continue;
                }

                DrawProperty(materialEditor, materialProperty, property);
                drawn.Add(materialProperty.name);
            }
            EndTintedContent();

            EditorGUILayout.EndVertical();
        }

        private static void MarkGroupPropertiesAsDeclared(
            MaterialProperty[] properties,
            HoNprMaterialUiDescriptor descriptor,
            HoNprMaterialUiGroup group,
            HashSet<string> drawn)
        {
            foreach (HoNprMaterialUiProperty property in descriptor.properties)
            {
                if (property.groupId == group.id && FindMaterialProperty(property.name, properties) != null)
                    drawn.Add(property.name);
            }
        }

        private static bool GroupHasTool(HoNprMaterialUiDescriptor descriptor, HoNprMaterialUiGroup group, string tool)
        {
            foreach (HoNprMaterialUiProperty property in descriptor.properties)
            {
                if (property.groupId == group.id && HasTool(property, tool))
                    return true;
            }

            return false;
        }

        private static bool GroupHasContract(HoNprMaterialUiDescriptor descriptor, HoNprMaterialUiGroup group)
        {
            foreach (HoNprMaterialUiContractBox box in descriptor.contractBoxes)
            {
                if (box.groupId == group.id)
                    return true;
            }

            return false;
        }

        private static bool HasTool(HoNprMaterialUiProperty property, string tool)
        {
            return property.tools.Contains(tool);
        }

        private static MaterialProperty FindMaterialProperty(string name, MaterialProperty[] properties)
        {
            foreach (MaterialProperty property in properties)
            {
                if (property != null && property.name == name)
                    return property;
            }

            return null;
        }

        private static void DrawContractBox(HoNprMaterialUiContractBox box, Color inheritedColor)
        {
            MessageType type = ToMessageType(box.severity);
            string title = string.IsNullOrEmpty(box.title) ? box.id : box.title;

            EditorGUILayout.Space(SectionSpacing);
            EditorGUILayout.BeginVertical(GetCompactBoxStyle());
            DrawContractHeader(
                title,
                inheritedColor,
                string.IsNullOrEmpty(box.message) ? box.id : box.message,
                true,
                (ref Rect rect) =>
                {
                    if (DrawHeaderIconButton(ref rect, MaterialUiIcon.Copy, "复制诊断信息"))
                        EditorGUIUtility.systemCopyBuffer = $"{box.id}: {box.message}";
                },
                1);

            if (type != MessageType.Info && !string.IsNullOrEmpty(box.message))
            {
                DrawContractMessage(box.message, type, inheritedColor);
            }
            EditorGUILayout.EndVertical();
        }

        private static bool DrawFoldoutHeader(string key, string title, Color color, bool defaultExpanded, string tooltip)
        {
            return DrawFoldoutHeader(key, title, color, defaultExpanded, tooltip, false, null, 0);
        }

        private static void DrawContractHeader(
            string title,
            Color color,
            string tooltip,
            bool compact,
            HeaderButtonDrawer drawButtons,
            int buttonCount)
        {
            DrawHeaderBar(title, color, tooltip, compact, drawButtons, buttonCount, null);
        }

        private static bool DrawFoldoutHeader(
            string key,
            string title,
            Color color,
            bool defaultExpanded,
            string tooltip,
            bool compact,
            HeaderButtonDrawer drawButtons,
            int buttonCount)
        {
            EnsureFoldoutHeaderStyles();
            string prefKey = FoldoutKeyPrefix + key;
            bool expanded = EditorPrefs.GetBool(prefKey, defaultExpanded);
            DrawHeaderBar(
                title,
                color,
                tooltip,
                compact,
                drawButtons,
                buttonCount,
                (rect, foldoutRect, reservedWidth) =>
                {
                    Event currentEvent = Event.current;
                    bool nextExpanded = EditorGUI.Foldout(foldoutRect, expanded, GUIContent.none, true);
                    if (nextExpanded != expanded)
                    {
                        expanded = nextExpanded;
                        EditorPrefs.SetBool(prefKey, expanded);
                    }

                    if (currentEvent.type == EventType.MouseDown
                        && rect.Contains(currentEvent.mousePosition)
                        && !foldoutRect.Contains(currentEvent.mousePosition)
                        && (buttonCount <= 0 || currentEvent.mousePosition.x < rect.xMax - reservedWidth))
                    {
                        expanded = !expanded;
                        EditorPrefs.SetBool(prefKey, expanded);
                        currentEvent.Use();
                    }
                });

            return expanded;
        }

        private static void DrawHeaderBar(
            string title,
            Color color,
            string tooltip,
            bool compact,
            HeaderButtonDrawer drawButtons,
            int buttonCount,
            Action<Rect, Rect, float> drawFoldout)
        {
            EnsureFoldoutHeaderStyles();
            Rect layoutRect = EditorGUILayout.GetControlRect(false, FoldoutHeaderHeight);
            Rect rect = compact ? CompactHeaderRect(layoutRect) : layoutRect;
            Event currentEvent = Event.current;
            bool hover = rect.Contains(currentEvent.mousePosition);
            if (compact)
                EditorGUI.DrawRect(layoutRect, GetContentColor(color, true));
            EditorGUI.DrawRect(rect, GetHeaderColor(color, hover, false));

            Rect foldoutRect = new Rect(rect.x + 5f, rect.y + 7f, 14f, EditorGUIUtility.singleLineHeight);
            drawFoldout?.Invoke(rect, foldoutRect, buttonCount <= 0 ? 0f : buttonCount * GroupToolButtonWidth + (buttonCount - 1) * HeaderButtonSpacing + 8f);

            float reservedWidth = buttonCount <= 0 ? 0f : buttonCount * GroupToolButtonWidth + (buttonCount - 1) * HeaderButtonSpacing + 8f;
            float labelX = drawFoldout == null ? rect.x + 12f : rect.x + 24f;
            float labelRightPadding = drawFoldout == null ? 16f : 28f;
            Rect labelRect = new Rect(labelX, rect.y + 5f, rect.width - labelX + rect.x - labelRightPadding - reservedWidth, 20f);
            GUI.Label(labelRect, new GUIContent(title, tooltip), foldoutHeaderLabelStyle);

            if (drawButtons != null)
            {
                Rect buttonRect = new Rect(rect.xMax - reservedWidth + 4f, rect.y + 5f, GroupToolButtonWidth, 20f);
                drawButtons(ref buttonRect);
            }
        }

        private static Rect CompactHeaderRect(Rect layoutRect)
        {
            float width = Mathf.Clamp(layoutRect.width * ContractHeaderWidthRatio, Mathf.Min(ContractHeaderMinWidth, layoutRect.width), Mathf.Min(ContractHeaderMaxWidth, layoutRect.width));
            float x = layoutRect.xMax - width;
            return new Rect(x, layoutRect.y, width, layoutRect.height);
        }

        private delegate void HeaderButtonDrawer(ref Rect rect);

        private static void EnsureFoldoutHeaderStyles()
        {
            if (foldoutHeaderLabelStyle != null)
                return;

            foldoutHeaderLabelStyle = new GUIStyle(EditorStyles.boldLabel)
            {
                alignment = TextAnchor.MiddleLeft,
                clipping = TextClipping.Clip
            };
        }

        private static GUIStyle GetCompactBoxStyle()
        {
            if (compactBoxStyle == null)
            {
                compactBoxStyle = new GUIStyle(EditorStyles.helpBox)
                {
                    padding = new RectOffset(0, 0, 0, 0),
                    margin = new RectOffset(0, 0, 0, 0)
                };
            }

            return compactBoxStyle;
        }

        private static GUIStyle GetCompactContentStyle()
        {
            if (compactContentStyle == null)
            {
                compactContentStyle = new GUIStyle
                {
                    padding = new RectOffset(6, 6, 3, 3),
                    margin = new RectOffset(0, 0, 0, 0)
                };
            }

            return compactContentStyle;
        }

        private static void BeginTintedContent(Color baseColor)
        {
            BeginTintedContent(baseColor, true);
        }

        private static void BeginTintedContent(Color baseColor, bool tint)
        {
            Rect rect = EditorGUILayout.BeginVertical(GetCompactContentStyle());
            if (tint && Event.current.type == EventType.Repaint)
                EditorGUI.DrawRect(rect, GetContentColor(baseColor, false));
        }

        private static void EndTintedContent()
        {
            EditorGUILayout.EndVertical();
        }

        private static void DrawContractMessage(string message, MessageType type, Color baseColor)
        {
            GUIContent content = new GUIContent(message);
            float height = Mathf.Max(
                EditorGUIUtility.singleLineHeight * 2f,
                EditorStyles.helpBox.CalcHeight(content, ContractContentWidth()));
            Rect layoutRect = EditorGUILayout.GetControlRect(false, height);
            if (Event.current.type == EventType.Repaint)
                EditorGUI.DrawRect(layoutRect, GetContentColor(baseColor, true));

            Rect messageRect = CompactHeaderRect(layoutRect);
            EditorGUI.HelpBox(messageRect, message, type);
        }

        private static float ContractContentWidth()
        {
            float viewWidth = EditorGUIUtility.currentViewWidth;
            float maxWidth = Mathf.Min(ContractHeaderMaxWidth, viewWidth);
            float minWidth = Mathf.Min(ContractHeaderMinWidth, maxWidth);
            return Mathf.Clamp(viewWidth * ContractHeaderWidthRatio, minWidth, maxWidth);
        }

        private static Color GetHeaderColor(Color baseColor, bool hover, bool childRow)
        {
            Color neutral = EditorGUIUtility.isProSkin
                ? new Color(0.16f, 0.17f, 0.18f)
                : new Color(0.93f, 0.93f, 0.93f);
            float strength = childRow ? 0.18f : 0.34f;
            if (hover)
                strength += 0.08f;

            Color color = Color.Lerp(neutral, baseColor, Mathf.Clamp01(strength));
            color.a = 1f;
            return color;
        }

        private static Color GetContentColor(Color baseColor, bool stronger)
        {
            Color neutral = EditorGUIUtility.isProSkin
                ? new Color(0.16f, 0.17f, 0.18f)
                : new Color(0.93f, 0.93f, 0.93f);
            Color color = Color.Lerp(neutral, baseColor, stronger ? 0.16f : 0.12f);
            color.a = 1f;
            return color;
        }

        private static Color NeutralHeaderColor()
        {
            return EditorGUIUtility.isProSkin
                ? new Color(0.28f, 0.28f, 0.28f)
                : new Color(0.78f, 0.78f, 0.78f);
        }

        private static int CountHeaderButtons(params bool[] enabled)
        {
            int count = 0;
            foreach (bool value in enabled)
            {
                if (value)
                    count++;
            }

            return count;
        }

        private static Color StableColor(string key)
        {
            Color[] palette =
            {
                new Color(0.25f, 0.56f, 0.93f),
                new Color(0.20f, 0.66f, 0.43f),
                new Color(0.84f, 0.45f, 0.21f),
                new Color(0.62f, 0.43f, 0.86f),
                new Color(0.80f, 0.36f, 0.50f),
                new Color(0.30f, 0.63f, 0.70f),
            };

            unchecked
            {
                int hash = 17;
                for (int i = 0; i < key.Length; i++)
                    hash = hash * 31 + key[i];

                return palette[(hash & int.MaxValue) % palette.Length];
            }
        }

        private static void DrawProperty(MaterialEditor materialEditor, MaterialProperty materialProperty, HoNprMaterialUiProperty descriptor)
        {
            if (descriptor.control == "vector")
            {
                DrawVectorPropertyRow(materialEditor, materialProperty, descriptor);
                return;
            }

            EditorGUILayout.BeginHorizontal();
            GUIContent label = new GUIContent(string.IsNullOrEmpty(descriptor.label) ? materialProperty.displayName : descriptor.label);
            switch (descriptor.control)
            {
                case "slider":
                    if (descriptor.HasRange)
                        DrawSlider(materialEditor, materialProperty, descriptor, label);
                    else
                        materialEditor.FloatProperty(materialProperty, label.text);
                    break;
                case "toggle":
                    DrawToggle(materialEditor, materialProperty, label);
                    break;
                case "enum":
                    DrawEnumPopup(materialEditor, materialProperty, descriptor, label);
                    break;
                case "color":
                    materialEditor.ColorProperty(materialProperty, label.text);
                    break;
                case "texture":
                    materialEditor.TexturePropertySingleLine(label, materialProperty);
                    break;
                default:
                    materialEditor.ShaderProperty(materialProperty, label);
                    break;
            }

            if (showPerPropertyTools)
            {
                if (HasTool(descriptor, "CopyProperty") && DrawFlatIconButton(MaterialUiIcon.Copy, ToolButtonWidth, false, "复制此参数"))
                    CopyProperty(materialProperty);
                if (HasTool(descriptor, "PasteProperty") && DrawFlatIconButton(MaterialUiIcon.Paste, ToolButtonWidth, false, "粘贴此参数"))
                    PasteProperty(materialEditor, materialProperty, descriptor);
            }

            EditorGUILayout.EndHorizontal();
        }

        private static void DrawVectorPropertyRow(MaterialEditor materialEditor, MaterialProperty materialProperty, HoNprMaterialUiProperty descriptor)
        {
            GUIContent label = new GUIContent(string.IsNullOrEmpty(descriptor.label) ? materialProperty.displayName : descriptor.label);
            EditorGUILayout.BeginHorizontal();
            EditorGUILayout.LabelField(label, EditorStyles.label);
            if (showPerPropertyTools)
            {
                if (HasTool(descriptor, "CopyProperty") && DrawFlatIconButton(MaterialUiIcon.Copy, ToolButtonWidth, false, "复制此参数"))
                    CopyProperty(materialProperty);
                if (HasTool(descriptor, "PasteProperty") && DrawFlatIconButton(MaterialUiIcon.Paste, ToolButtonWidth, false, "粘贴此参数"))
                    PasteProperty(materialEditor, materialProperty, descriptor);
            }
            EditorGUILayout.EndHorizontal();
            DrawVector4Fields(materialEditor, materialProperty, label);
        }

        private static void DrawVector4Fields(MaterialEditor materialEditor, MaterialProperty materialProperty, GUIContent label)
        {
            if (materialProperty.propertyType != UnityEngine.Rendering.ShaderPropertyType.Vector)
            {
                materialEditor.ShaderProperty(materialProperty, label);
                return;
            }

            EditorGUILayout.BeginVertical(GetCompactContentStyle());
            EditorGUI.indentLevel++;
            EditorGUI.BeginChangeCheck();
            Vector4 value = materialProperty.vectorValue;
            value.x = EditorGUILayout.FloatField("X", value.x);
            value.y = EditorGUILayout.FloatField("Y", value.y);
            value.z = EditorGUILayout.FloatField("Z", value.z);
            value.w = EditorGUILayout.FloatField("W", value.w);
            if (EditorGUI.EndChangeCheck())
            {
                materialEditor.RegisterPropertyChangeUndo(label.text);
                materialProperty.vectorValue = value;
            }
            EditorGUI.indentLevel--;
            EditorGUILayout.EndVertical();
        }

        private static bool DrawFlatIconButton(MaterialUiIcon icon, float width, bool active, string tooltip)
        {
            Rect rect = GUILayoutUtility.GetRect(width, EditorGUIUtility.singleLineHeight, GUILayout.Width(width), GUILayout.Height(EditorGUIUtility.singleLineHeight));
            return DrawFlatIconButton(rect, icon, active, tooltip);
        }

        private static bool DrawFlatIconButton(Rect rect, MaterialUiIcon icon, bool active, string tooltip)
        {
            Event currentEvent = Event.current;
            bool hover = rect.Contains(currentEvent.mousePosition);
            GUI.Label(rect, new GUIContent(string.Empty, tooltip));
            if (hover || active)
            {
                Color background = EditorGUIUtility.isProSkin
                    ? new Color(1f, 1f, 1f, active ? 0.16f : 0.08f)
                    : new Color(0f, 0f, 0f, active ? 0.12f : 0.06f);
                EditorGUI.DrawRect(rect, background);
            }

            DrawLineIcon(rect, icon, active || hover);

            if (currentEvent.type == EventType.MouseDown && currentEvent.button == 0 && hover)
            {
                currentEvent.Use();
                return true;
            }

            return false;
        }

        private static bool DrawHeaderIconButton(ref Rect rect, MaterialUiIcon icon, string tooltip)
        {
            bool clicked = DrawFlatIconButton(rect, icon, false, tooltip);
            rect.x += GroupToolButtonWidth + HeaderButtonSpacing;
            return clicked;
        }

        private static void DrawLineIcon(Rect rect, MaterialUiIcon icon, bool active)
        {
            Rect iconRect = new Rect(rect.x + 4f, rect.y + 3f, rect.width - 8f, rect.height - 6f);
            Color color = EditorGUIUtility.isProSkin
                ? new Color(0.92f, 0.94f, 0.96f, active ? 1f : 0.78f)
                : new Color(0.12f, 0.14f, 0.16f, active ? 1f : 0.72f);

            Handles.BeginGUI();
            Color oldColor = Handles.color;
            Handles.color = color;
            switch (icon)
            {
                case MaterialUiIcon.Copy:
                    DrawCopyIcon(iconRect);
                    break;
                case MaterialUiIcon.Paste:
                    DrawPasteIcon(iconRect);
                    break;
                case MaterialUiIcon.Reset:
                    DrawResetIcon(iconRect);
                    break;
                case MaterialUiIcon.Tools:
                    DrawToolsIcon(iconRect);
                    break;
            }

            Handles.color = oldColor;
            Handles.EndGUI();
        }

        private static void DrawCopyIcon(Rect rect)
        {
            DrawRoundedRectSvg(rect, 7f, 7f, 14f, 14f, 2.7f);
            DrawSvgPolyline(rect, (4f, 16.7f), (3f, 15f), (3f, 5f), (5f, 3f), (15f, 3f), (16.5f, 4f));
        }

        private static void DrawPasteIcon(Rect rect)
        {
            DrawSvgPolyline(rect, (9f, 5f), (7f, 5f), (5f, 7f), (5f, 19f), (7f, 21f), (17f, 21f), (19f, 19f), (19f, 7f), (17f, 5f), (15f, 5f));
            DrawRoundedRectSvg(rect, 9f, 3f, 6f, 4f, 2f);
        }

        private static void DrawResetIcon(Rect rect)
        {
            DrawSvgArc(rect, 12f, 12f, 8f, 198f, 354f);
            DrawSvgPolyline(rect, (4f, 5f), (4f, 9f), (8f, 9f));
            DrawSvgArc(rect, 12f, 12f, 8f, 18f, 174f);
            DrawSvgPolyline(rect, (20f, 19f), (20f, 15f), (16f, 15f));
        }

        private static void DrawToolsIcon(Rect rect)
        {
            DrawSvgCircle(rect, 14f, 6f, 2f);
            DrawSvgPolyline(rect, (4f, 6f), (12f, 6f));
            DrawSvgPolyline(rect, (16f, 6f), (20f, 6f));
            DrawSvgCircle(rect, 8f, 12f, 2f);
            DrawSvgPolyline(rect, (4f, 12f), (6f, 12f));
            DrawSvgPolyline(rect, (10f, 12f), (20f, 12f));
            DrawSvgCircle(rect, 17f, 18f, 2f);
            DrawSvgPolyline(rect, (4f, 18f), (15f, 18f));
            DrawSvgPolyline(rect, (19f, 18f), (20f, 18f));
        }

        private static void DrawSvgPolyline(Rect rect, params (float x, float y)[] points)
        {
            var vectors = new Vector3[points.Length];
            for (int i = 0; i < points.Length; i++)
                vectors[i] = SvgPoint(rect, points[i].x, points[i].y);

            Handles.DrawAAPolyLine(2f, vectors);
        }

        private static void DrawRoundedRectSvg(Rect rect, float x, float y, float width, float height, float radius)
        {
            Vector3 center = SvgPoint(rect, x + width * 0.5f, y + height * 0.5f);
            Vector2 size = new Vector2(rect.width * width / 24f, rect.height * height / 24f);
            float scaledRadius = Mathf.Min(rect.width, rect.height) * radius / 24f;
            Handles.DrawAAPolyLine(2f, RoundedRectPoints(center, size, scaledRadius));
        }

        private static Vector3[] RoundedRectPoints(Vector3 center, Vector2 size, float radius)
        {
            var points = new List<Vector3>(36);
            float left = center.x - size.x * 0.5f;
            float right = center.x + size.x * 0.5f;
            float top = center.y - size.y * 0.5f;
            float bottom = center.y + size.y * 0.5f;
            AddCorner(points, new Vector2(right - radius, top + radius), radius, -90f, 0f);
            AddCorner(points, new Vector2(right - radius, bottom - radius), radius, 0f, 90f);
            AddCorner(points, new Vector2(left + radius, bottom - radius), radius, 90f, 180f);
            AddCorner(points, new Vector2(left + radius, top + radius), radius, 180f, 270f);
            points.Add(points[0]);
            return points.ToArray();
        }

        private static void AddCorner(List<Vector3> points, Vector2 center, float radius, float startDegrees, float endDegrees)
        {
            const int segments = 4;
            for (int i = 0; i <= segments; i++)
            {
                float t = Mathf.Lerp(startDegrees, endDegrees, i / (float)segments) * Mathf.Deg2Rad;
                points.Add(new Vector3(center.x + Mathf.Cos(t) * radius, center.y + Mathf.Sin(t) * radius));
            }
        }

        private static void DrawSvgCircle(Rect rect, float x, float y, float radius)
        {
            Vector3 center = SvgPoint(rect, x, y);
            DrawCirclePolyline(center, Mathf.Min(rect.width, rect.height) * radius / 24f);
        }

        private static void DrawSvgArc(Rect rect, float centerX, float centerY, float radius, float startDegrees, float endDegrees)
        {
            const int segments = 18;
            var points = new Vector3[segments + 1];
            for (int i = 0; i <= segments; i++)
            {
                float angle = Mathf.Lerp(startDegrees, endDegrees, i / (float)segments) * Mathf.Deg2Rad;
                points[i] = SvgPoint(rect, centerX + Mathf.Cos(angle) * radius, centerY + Mathf.Sin(angle) * radius);
            }

            Handles.DrawAAPolyLine(2f, points);
        }

        private static void DrawCirclePolyline(Vector3 center, float radius)
        {
            const int segments = 18;
            var points = new Vector3[segments + 1];
            for (int i = 0; i <= segments; i++)
            {
                float angle = Mathf.PI * 2f * i / segments;
                points[i] = center + new Vector3(Mathf.Cos(angle) * radius, Mathf.Sin(angle) * radius);
            }

            Handles.DrawAAPolyLine(2f, points);
        }

        private static Vector3 SvgPoint(Rect rect, float x, float y)
        {
            return new Vector3(rect.x + rect.width * x / 24f, rect.y + rect.height * y / 24f);
        }

        private static void DrawSlider(
            MaterialEditor materialEditor,
            MaterialProperty materialProperty,
            HoNprMaterialUiProperty descriptor,
            GUIContent label)
        {
            if (materialProperty.propertyType == UnityEngine.Rendering.ShaderPropertyType.Float || materialProperty.propertyType == UnityEngine.Rendering.ShaderPropertyType.Range)
            {
                EditorGUI.BeginChangeCheck();
                float value = EditorGUILayout.Slider(label, materialProperty.floatValue, descriptor.rangeMin, descriptor.rangeMax);
                if (EditorGUI.EndChangeCheck())
                {
                    materialEditor.RegisterPropertyChangeUndo(label.text);
                    materialProperty.floatValue = value;
                }

                return;
            }

            materialEditor.ShaderProperty(materialProperty, label);
        }

        private static void DrawToggle(MaterialEditor materialEditor, MaterialProperty materialProperty, GUIContent label)
        {
            if (materialProperty.propertyType == UnityEngine.Rendering.ShaderPropertyType.Float || materialProperty.propertyType == UnityEngine.Rendering.ShaderPropertyType.Range)
            {
                EditorGUI.BeginChangeCheck();
                bool value = EditorGUILayout.Toggle(label, !Mathf.Approximately(materialProperty.floatValue, 0f));
                if (EditorGUI.EndChangeCheck())
                {
                    materialEditor.RegisterPropertyChangeUndo(label.text);
                    materialProperty.floatValue = value ? 1f : 0f;
                }

                return;
            }

            materialEditor.ShaderProperty(materialProperty, label);
        }

        private static void DrawEnumPopup(
            MaterialEditor materialEditor,
            MaterialProperty materialProperty,
            HoNprMaterialUiProperty descriptor,
            GUIContent label)
        {
            if ((materialProperty.propertyType != UnityEngine.Rendering.ShaderPropertyType.Float
                    && materialProperty.propertyType != UnityEngine.Rendering.ShaderPropertyType.Range)
                || descriptor.optionLabels.Count == 0
                || descriptor.optionLabels.Count != descriptor.optionValues.Count)
            {
                materialEditor.ShaderProperty(materialProperty, label);
                return;
            }

            int selected = 0;
            float current = materialProperty.floatValue;
            for (int i = 0; i < descriptor.optionValues.Count; i++)
            {
                if (Mathf.Abs(current - descriptor.optionValues[i]) < 0.5f)
                {
                    selected = i;
                    break;
                }
            }

            EditorGUI.BeginChangeCheck();
            int next = EditorGUILayout.Popup(label, selected, descriptor.optionLabels.ToArray());
            if (EditorGUI.EndChangeCheck())
            {
                materialEditor.RegisterPropertyChangeUndo(label.text);
                materialProperty.floatValue = descriptor.optionValues[next];
            }
        }

        private static void DrawUndeclaredProperties(MaterialEditor materialEditor, MaterialProperty[] properties, HashSet<string> drawn)
        {
            List<MaterialProperty> undeclared = new List<MaterialProperty>();
            foreach (MaterialProperty property in properties)
            {
                if (!drawn.Contains(property.name))
                    undeclared.Add(property);
            }

            if (undeclared.Count == 0)
                return;

            EditorGUILayout.Space(SectionSpacing);
            EditorGUILayout.BeginVertical(GetCompactBoxStyle());
            Color headerColor = StableColor("undeclared");
            bool expanded = DrawFoldoutHeader(
                "undeclared",
                "高级 / 原始属性（未声明 UI）",
                headerColor,
                false,
                "这些属性没有出现在 *.honprui 白名单里，仅用于排查。");
            if (!expanded)
            {
                EditorGUILayout.EndVertical();
                return;
            }

            BeginTintedContent(headerColor);
            EditorGUILayout.HelpBox("这些属性没有出现在 *.honprui 白名单里。第一版仅用于排查，不建议作为常规编辑入口。", MessageType.Info);
            using (new EditorGUI.DisabledScope(true))
            {
                foreach (MaterialProperty property in undeclared)
                    materialEditor.ShaderProperty(property, property.displayName);
            }
            EndTintedContent();
            EditorGUILayout.EndVertical();
        }

        private static string GetPresetId(Material material)
        {
            string shaderName = material.shader == null ? string.Empty : material.shader.name;
            if (shaderName.EndsWith("Character_DebugLit_SSS_OITReady", StringComparison.Ordinal))
                return "MaterialPreset.Character_DebugLit_SSS_OITReady";

            if (TryGetSemanticPresetId(shaderName, out string presetId))
                return presetId;

            const string generatedPrefix = "HoNpr/Generated/";
            if (shaderName.StartsWith(generatedPrefix, StringComparison.Ordinal))
                return SourcePresetPrefix + shaderName.Substring(generatedPrefix.Length).Replace("/", "_");

            return SourcePresetPrefix + shaderName.Replace("/", "_");
        }

        private static bool TryGetSemanticPresetId(string shaderName, out string presetId)
        {
            presetId = null;
            return TryGetSemanticPresetId(shaderName, "HoNpr/Character/", "Character_", out presetId)
                || TryGetSemanticPresetId(shaderName, "HoNpr/Environment/", "Environment_", out presetId)
                || TryGetSemanticPresetId(shaderName, "HoNpr/Transparent/", "Transparent_", out presetId)
                || TryGetSemanticPresetId(shaderName, "HoNpr/Hair/", "Hair_", out presetId);
        }

        private static bool TryGetSemanticPresetId(string shaderName, string shaderPrefix, string presetPrefix, out string presetId)
        {
            presetId = null;
            if (!shaderName.StartsWith(shaderPrefix, StringComparison.Ordinal))
                return false;

            string suffix = shaderName.Substring(shaderPrefix.Length);
            if (string.IsNullOrEmpty(suffix))
                return false;

            presetId = SourcePresetPrefix + presetPrefix + suffix.Replace("/", "_");
            return true;
        }

        private static void CopyProperty(MaterialProperty property)
        {
            EditorGUIUtility.systemCopyBuffer = BuildClipboardPayload(null, null, new[] { property });
        }

        private static void PasteProperty(MaterialEditor materialEditor, MaterialProperty target, HoNprMaterialUiProperty descriptor)
        {
            Dictionary<string, string> values = ParseClipboardPayload(EditorGUIUtility.systemCopyBuffer);
            if (!values.TryGetValue(target.name, out string value))
            {
                Debug.LogWarning($"[HoNpr.MaterialUI] 剪贴板里没有 {target.name}。");
                return;
            }

            materialEditor.RegisterPropertyChangeUndo("Paste HoNpr material parameter");
            ApplyValue(target, descriptor, value);
        }

        private static void CopyGroup(Material material, HoNprMaterialUiDescriptor descriptor, HoNprMaterialUiGroup group)
        {
            var builder = new StringBuilder();
            builder.AppendLine("HoNprMaterialParameterClipboard");
            builder.AppendLine("PresetId: " + descriptor.presetId);
            builder.AppendLine("Group: " + group.id);
            builder.AppendLine("Properties:");
            foreach (HoNprMaterialUiProperty property in descriptor.properties)
            {
                if (property.groupId != group.id || !material.HasProperty(property.name))
                    continue;

                builder.AppendLine("  " + property.name + ": " + ReadMaterialValue(material, property.name));
            }

            EditorGUIUtility.systemCopyBuffer = builder.ToString();
        }

        private static void PasteGroup(Material material, HoNprMaterialUiDescriptor descriptor, HoNprMaterialUiGroup group)
        {
            Dictionary<string, string> values = ParseClipboardPayload(EditorGUIUtility.systemCopyBuffer);
            int applied = 0;
            int skipped = 0;
            Undo.RecordObject(material, "Paste HoNpr material parameter group");
            foreach (HoNprMaterialUiProperty property in descriptor.properties)
            {
                if (property.groupId != group.id)
                    continue;

                if (!values.TryGetValue(property.name, out string value) || !material.HasProperty(property.name))
                {
                    skipped++;
                    continue;
                }

                ApplyMaterialValue(material, property, value);
                applied++;
            }

            Debug.Log($"[HoNpr.MaterialUI] 粘贴组 {group.label}：写入 {applied}，跳过 {skipped}。");
            if (applied > 0)
                EditorUtility.SetDirty(material);
        }

        private static void ResetGroup(Material material, HoNprMaterialUiDescriptor descriptor, HoNprMaterialUiGroup group)
        {
            int applied = 0;
            int skipped = 0;
            Undo.RecordObject(material, "Reset HoNpr material parameter group");
            foreach (HoNprMaterialUiProperty property in descriptor.properties)
            {
                if (property.groupId != group.id || !material.HasProperty(property.name))
                    continue;

                if (string.IsNullOrEmpty(property.defaultHint))
                {
                    skipped++;
                    continue;
                }

                ApplyMaterialValue(material, property, property.defaultHint);
                applied++;
            }

            Debug.Log($"[HoNpr.MaterialUI] 重置组 {group.label}：写入 {applied}，跳过 {skipped}。");
            if (applied > 0)
                EditorUtility.SetDirty(material);
        }

        private static string BuildClipboardPayload(string presetId, string group, IEnumerable<MaterialProperty> properties)
        {
            var builder = new StringBuilder();
            builder.AppendLine("HoNprMaterialParameterClipboard");
            if (!string.IsNullOrEmpty(presetId))
                builder.AppendLine("PresetId: " + presetId);
            if (!string.IsNullOrEmpty(group))
                builder.AppendLine("Group: " + group);
            builder.AppendLine("Properties:");
            foreach (MaterialProperty property in properties)
                builder.AppendLine("  " + property.name + ": " + ReadPropertyValue(property));

            return builder.ToString();
        }

        private static Dictionary<string, string> ParseClipboardPayload(string text)
        {
            var values = new Dictionary<string, string>();
            if (string.IsNullOrWhiteSpace(text) || !text.StartsWith("HoNprMaterialParameterClipboard", StringComparison.Ordinal))
                return values;

            using (var reader = new System.IO.StringReader(text))
            {
                string line;
                while ((line = reader.ReadLine()) != null)
                {
                    string trimmed = line.Trim();
                    if (!trimmed.StartsWith("_", StringComparison.Ordinal))
                        continue;

                    int colon = trimmed.IndexOf(':');
                    if (colon <= 0)
                        continue;

                    values[trimmed.Substring(0, colon).Trim()] = trimmed.Substring(colon + 1).Trim();
                }
            }

            return values;
        }

        private static string ReadPropertyValue(MaterialProperty property)
        {
            switch (property.propertyType)
            {
                case UnityEngine.Rendering.ShaderPropertyType.Color:
                    return FormatVector(property.colorValue);
                case UnityEngine.Rendering.ShaderPropertyType.Vector:
                    return FormatVector(property.vectorValue);
                case UnityEngine.Rendering.ShaderPropertyType.Float:
                case UnityEngine.Rendering.ShaderPropertyType.Range:
                    return property.floatValue.ToString(CultureInfo.InvariantCulture);
                case UnityEngine.Rendering.ShaderPropertyType.Texture:
                    return property.textureValue == null ? "null" : AssetDatabase.AssetPathToGUID(AssetDatabase.GetAssetPath(property.textureValue));
                default:
                    return string.Empty;
            }
        }

        private static string ReadMaterialValue(Material material, string property)
        {
            Shader shader = material.shader;
            int propertyIndex = shader == null ? -1 : shader.FindPropertyIndex(property);
            if (propertyIndex < 0)
                return string.Empty;

            UnityEngine.Rendering.ShaderPropertyType type = shader.GetPropertyType(propertyIndex);
            switch (type)
            {
                case UnityEngine.Rendering.ShaderPropertyType.Color:
                    return FormatVector(material.GetColor(property));
                case UnityEngine.Rendering.ShaderPropertyType.Vector:
                    return FormatVector(material.GetVector(property));
                case UnityEngine.Rendering.ShaderPropertyType.Float:
                case UnityEngine.Rendering.ShaderPropertyType.Range:
                    return material.GetFloat(property).ToString(CultureInfo.InvariantCulture);
                case UnityEngine.Rendering.ShaderPropertyType.Texture:
                    Texture texture = material.GetTexture(property);
                    return texture == null ? "null" : AssetDatabase.AssetPathToGUID(AssetDatabase.GetAssetPath(texture));
                default:
                    return string.Empty;
            }
        }

        private static void ApplyValue(MaterialProperty target, HoNprMaterialUiProperty descriptor, string value)
        {
            switch (target.propertyType)
            {
                case UnityEngine.Rendering.ShaderPropertyType.Color:
                    target.colorValue = ParseVector(value, target.colorValue);
                    break;
                case UnityEngine.Rendering.ShaderPropertyType.Vector:
                    target.vectorValue = ParseVector(value, target.vectorValue);
                    break;
                case UnityEngine.Rendering.ShaderPropertyType.Float:
                case UnityEngine.Rendering.ShaderPropertyType.Range:
                    target.floatValue = Clamp(descriptor, ParseFloat(value, target.floatValue));
                    break;
                case UnityEngine.Rendering.ShaderPropertyType.Texture:
                    string path = AssetDatabase.GUIDToAssetPath(value);
                    Texture texture = string.IsNullOrEmpty(path) ? null : AssetDatabase.LoadAssetAtPath<Texture>(path);
                    if (texture != null || value == "null")
                        target.textureValue = texture;
                    break;
            }
        }

        private static void ApplyMaterialValue(Material material, HoNprMaterialUiProperty descriptor, string value)
        {
            Shader shader = material.shader;
            int propertyIndex = shader == null ? -1 : shader.FindPropertyIndex(descriptor.name);
            if (propertyIndex < 0)
                return;

            UnityEngine.Rendering.ShaderPropertyType type = shader.GetPropertyType(propertyIndex);
            switch (type)
            {
                case UnityEngine.Rendering.ShaderPropertyType.Color:
                    material.SetColor(descriptor.name, ParseVector(value, material.GetColor(descriptor.name)));
                    break;
                case UnityEngine.Rendering.ShaderPropertyType.Vector:
                    material.SetVector(descriptor.name, ParseVector(value, material.GetVector(descriptor.name)));
                    break;
                case UnityEngine.Rendering.ShaderPropertyType.Float:
                case UnityEngine.Rendering.ShaderPropertyType.Range:
                    material.SetFloat(descriptor.name, Clamp(descriptor, ParseFloat(value, material.GetFloat(descriptor.name))));
                    break;
                case UnityEngine.Rendering.ShaderPropertyType.Texture:
                    string path = AssetDatabase.GUIDToAssetPath(value);
                    Texture texture = string.IsNullOrEmpty(path) ? null : AssetDatabase.LoadAssetAtPath<Texture>(path);
                    if (texture != null || value == "null")
                        material.SetTexture(descriptor.name, texture);
                    break;
            }
        }

        private static float Clamp(HoNprMaterialUiProperty descriptor, float value)
        {
            return descriptor.HasRange ? Mathf.Clamp(value, descriptor.rangeMin, descriptor.rangeMax) : value;
        }

        private static float ParseFloat(string value, float fallback)
        {
            return float.TryParse(value, NumberStyles.Float, CultureInfo.InvariantCulture, out float result) ? result : fallback;
        }

        private static Vector4 ParseVector(string value, Vector4 fallback)
        {
            string trimmed = value.Trim().Trim('(', ')');
            string[] parts = trimmed.Split(',');
            if (parts.Length < 4)
                return fallback;

            return new Vector4(
                ParseFloat(parts[0], fallback.x),
                ParseFloat(parts[1], fallback.y),
                ParseFloat(parts[2], fallback.z),
                ParseFloat(parts[3], fallback.w));
        }

        private static string FormatVector(Vector4 value)
        {
            return string.Format(CultureInfo.InvariantCulture, "({0}, {1}, {2}, {3})", value.x, value.y, value.z, value.w);
        }

        private static MessageType ToMessageType(string severity)
        {
            switch (severity)
            {
                case "warning":
                    return MessageType.Warning;
                case "error":
                    return MessageType.Error;
                case "info":
                default:
                    return MessageType.Info;
            }
        }
    }
}

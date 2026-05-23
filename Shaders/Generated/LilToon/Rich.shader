// 由 HoNprShaderGenerator 生成。
// SourcePreset: MaterialPreset.Character_LilToon_Rich
// Template: MaterialTemplate.CharacterForward + MaterialTemplate.CharacterOutline + MaterialTemplate.CharacterAov + MaterialTemplate.CharacterDepth + MaterialTemplate.CharacterShadow
// Blocks: MaterialBlock.BaseColorTexture, MaterialBlock.NormalMap, MaterialBlock.SemanticMap, MaterialBlock.RegionMask, MaterialBlock.StyleRampAtlas, MaterialBlock.LilToonOutline, MaterialBlock.UrpMainLightInput, MaterialBlock.UrpAdditionalLightInput, MaterialBlock.IndirectLightInput, MaterialBlock.ScreenAoReceiver, MaterialBlock.HoShadowReceiver, MaterialBlock.LilToonDiffuseRamp, MaterialBlock.LilToonSpecular, MaterialBlock.LilToonRimShade, MaterialBlock.LilToonRimLight, MaterialBlock.LilToonBacklight, MaterialBlock.LilToonBackfaceColor, MaterialBlock.LilToonMatCap, MaterialBlock.LilToonSecondaryMatCap, MaterialBlock.LilToonGlitter, MaterialBlock.LilToonEmissionPrimary, MaterialBlock.LilToonEmissionSecondary, MaterialBlock.LilToonDistanceFade, MaterialBlock.MaterialSemanticProducer, MaterialBlock.AovOutputStandard, MaterialBlock.FinalColorComposite
// 不要手动修改生成体。请改 template / block / preset。
Shader "HoNpr/Character_LilToon_Rich"
{
    Properties
    {
        _HoNprBaseMap("Base Map", 2D) = "white" {}
        _HoUrpBaseColor("Base Color", Color) = (1, 1, 1, 1)
        _HoNprNormalMap("Normal Map", 2D) = "bump" {}

        _HoNprSemanticMap("Semantic Map", 2D) = "white" {}

        _HoNprRegionMap("Region Map", 2D) = "white" {}
        _HoNprStyleRampAtlas("Style Ramp Atlas", 2D) = "white" {}
        _HoNprLilToonDiffuseRampThreshold("lilToon Diffuse Ramp Threshold", Range(0, 1)) = 0.48
        _HoNprLilToonDiffuseRampSoftness("lilToon Diffuse Ramp Softness", Range(0.001, 1)) = 0.08
        _HoNprRampRow("Ramp Row", Float) = 0
        _HoNprRampRows("Ramp Rows", Float) = 8

        _HoNprOutlineColor("Outline-lilToon Color", Color) = (0.6, 0.56, 0.73, 1)
        _HoNprOutlineTex("Outline-lilToon Texture", 2D) = "white" {}
        _HoNprOutlineLitColor("Outline-lilToon Lit Color", Color) = (1, 0.2, 0, 0)
        _HoNprOutlineLitApplyTex("Outline-lilToon Lit Apply Texture", Float) = 0
        _HoNprOutlineLitScale("Outline-lilToon Lit Scale", Float) = 10
        _HoNprOutlineLitOffset("Outline-lilToon Lit Offset", Float) = -8
        _HoNprOutlineWidth("Outline-lilToon Width", Range(0, 1)) = 0.08
        _HoNprOutlineWidthMask("Outline-lilToon Width Mask", 2D) = "white" {}
        _HoNprOutlineFixWidth("Outline-lilToon Fix Width", Range(0, 1)) = 0.5
        _HoNprOutlineZBias("Outline-lilToon Z Bias", Range(0, 0.02)) = 0
        _HoNprOutlineVertexWidthMode("Outline-lilToon Vertex Width Mode", Float) = 0
        _HoNprOutlineVectorMap("Outline-lilToon Vector Map", 2D) = "bump" {}
        _HoNprOutlineVectorScale("Outline-lilToon Vector Scale", Range(-10, 10)) = 1
        _HoNprOutlineEnableLighting("Outline-lilToon Enable Lighting", Range(0, 1)) = 1


        _HoNprLilToonSpecularThreshold("lilToon Specular Threshold", Range(0, 1)) = 0.72
        _HoNprLilToonSpecularSoftness("lilToon Specular Softness", Range(0.001, 1)) = 0.08
        _HoNprLilToonSpecularMask("lilToon Specular Mask", Range(0, 1)) = 0.6
        [Enum(Add,0,Screen,1,Max,2,Replace,3)] _HoNprLilToonSpecularBlendMode("lilToon Specular Blend Mode", Float) = 0




        _HoNprLilToonRimShadeColor("lilToon RimShade Color", Color) = (0.15, 0.16, 0.2, 1)
        [Enum(Add,0,Screen,1,Max,2,Replace,3)] _HoNprLilToonRimShadeBlendMode("lilToon RimShade Blend Mode", Float) = 0


        _HoNprLilToonBacklightColor("lilToon Backlight Color", Color) = (0.7, 0.5, 0.35, 1)
        _HoNprLilToonBacklightPower("lilToon Backlight Power", Range(0.1, 12)) = 2
        [Enum(Add,0,Screen,1,Max,2,Replace,3)] _HoNprLilToonBacklightBlendMode("lilToon Backlight Blend Mode", Float) = 0


        _HoNprLilToonMatCapColor("lilToon MatCap Color", Color) = (0.25, 0.25, 0.3, 1)
        _HoNprLilToonMatCapMask("lilToon MatCap Mask", Range(0, 1)) = 0.25
        [Enum(Add,0,Screen,1,Max,2,Replace,3)] _HoNprLilToonMatCapBlendMode("lilToon MatCap Blend Mode", Float) = 0


        _HoNprLilToonRimLightColor("lilToon RimLight Color", Color) = (0.75, 0.9, 1, 1)
        [Enum(Add,0,Screen,1,Max,2,Replace,3)] _HoNprLilToonRimLightBlendMode("lilToon RimLight Blend Mode", Float) = 0


        _HoNprLilToonRimPower("lilToon Rim Power", Range(0.1, 12)) = 3
        _HoNprLilToonRimMask("lilToon Rim Mask", Range(0, 1)) = 0.5


        _HoNprLilToonBackfaceColor("lilToon Backface Color", Color) = (0, 0, 0, 0)
        [Enum(Add,0,Screen,1,Max,2,Replace,3)] _HoNprLilToonBackfaceColorBlendMode("lilToon Backface Color Blend Mode", Float) = 0


        _HoNprLilToonSecondaryMatCapColor("lilToon Secondary MatCap Color", Color) = (0.08, 0.1, 0.14, 1)
        _HoNprLilToonSecondaryMatCapMask("lilToon Secondary MatCap Mask", Range(0, 1)) = 0
        [Enum(Add,0,Screen,1,Max,2,Replace,3)] _HoNprLilToonSecondaryMatCapBlendMode("lilToon Secondary MatCap Blend Mode", Float) = 0


        _HoNprLilToonGlitterColor("lilToon Glitter Color", Color) = (1, 0.92, 0.72, 1)
        _HoNprLilToonGlitterMask("lilToon Glitter Mask", Range(0, 1)) = 0
        _HoNprLilToonGlitterDensity("lilToon Glitter Density", Range(1, 256)) = 48
        _HoNprLilToonGlitterThreshold("lilToon Glitter Threshold", Range(0, 1)) = 0.94
        _HoNprLilToonGlitterPower("lilToon Glitter Power", Range(1, 128)) = 32
        [Enum(Add,0,Screen,1,Max,2,Replace,3)] _HoNprLilToonGlitterBlendMode("lilToon Glitter Blend Mode", Float) = 0


        _HoNprLilToonEmissionPrimaryColor("lilToon Primary Emission Color", Color) = (0, 0, 0, 1)
        _HoNprLilToonEmissionPrimaryIntensity("lilToon Primary Emission Intensity", Range(0, 16)) = 0
        [Enum(Add,0,Screen,1,Max,2,Replace,3)] _HoNprLilToonEmissionPrimaryBlendMode("lilToon Primary Emission Blend Mode", Float) = 0


        _HoNprLilToonEmissionSecondaryColor("lilToon Secondary Emission Color", Color) = (0, 0, 0, 1)
        _HoNprLilToonEmissionSecondaryIntensity("lilToon Secondary Emission Intensity", Range(0, 16)) = 0
        [Enum(Add,0,Screen,1,Max,2,Replace,3)] _HoNprLilToonEmissionSecondaryBlendMode("lilToon Secondary Emission Blend Mode", Float) = 0


        _HoNprLilToonDistanceFadeColor("lilToon Distance Fade Color", Color) = (0, 0, 0, 1)
        _HoNprLilToonDistanceFadeStart("lilToon Distance Fade Start", Float) = 50
        _HoNprLilToonDistanceFadeEnd("lilToon Distance Fade End", Float) = 80
        _HoNprLilToonDistanceFadeStrength("lilToon Distance Fade Strength", Range(0, 1)) = 0
        [Enum(Add,0,Screen,1,Max,2,Replace,3)] _HoNprLilToonDistanceFadeBlendMode("lilToon Distance Fade Blend Mode", Float) = 0

        _HoUrpGeneratedMaterialClass("Material Class", Float) = 1

        _HoUrpGeneratedMaterialCustom0_3("Material Custom 0-3", Vector) = (0, 0, 0, 0)



    }

    HLSLINCLUDE
    #define HONPR_HAS_BASE_COLOR_TEXTURE 1
    #define HONPR_HAS_FINAL_COLOR_COMPOSITE 1
    #define HONPR_HAS_HORP_SHADOW_RECEIVER 1
    #define HONPR_HAS_INDIRECT_LIGHT 1
    #define HONPR_HAS_LILTOON_BACKFACE_COLOR 1
    #define HONPR_HAS_LILTOON_BACKLIGHT 1
    #define HONPR_HAS_LILTOON_DIFFUSE_RAMP 1
    #define HONPR_HAS_LILTOON_DISTANCE_FADE 1
    #define HONPR_HAS_LILTOON_EMISSION_PRIMARY 1
    #define HONPR_HAS_LILTOON_EMISSION_SECONDARY 1
    #define HONPR_HAS_LILTOON_GLITTER 1
    #define HONPR_HAS_LILTOON_MATCAP 1
    #define HONPR_HAS_LILTOON_OUTLINE 1
    #define HONPR_HAS_LILTOON_RIM_LIGHT 1
    #define HONPR_HAS_LILTOON_RIM_SHADE 1
    #define HONPR_HAS_LILTOON_SECONDARY_MATCAP 1
    #define HONPR_HAS_LILTOON_SPECULAR 1
    #define HONPR_HAS_MATERIAL_SEMANTICS 1
    #define HONPR_HAS_NORMAL_MAP 1
    #define HONPR_HAS_REGION_MASK 1
    #define HONPR_HAS_SCREEN_AO_RECEIVER 1
    #define HONPR_HAS_SEMANTIC_MAP 1
    #define HONPR_HAS_STANDARD_AOV 1
    #define HONPR_HAS_STYLE_RAMP_ATLAS 1
    #define HONPR_HAS_URP_ADDITIONAL_LIGHTS 1
    #define HONPR_HAS_URP_MAIN_LIGHT 1





#include "Packages/com.hollow.honpr/Shaders/ShaderLibrary/Assemblies/CharacterToon/HoNprCharacterToonRich.hlsl"



    ENDHLSL

    SubShader
    {


        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Opaque" "Queue" = "Geometry" }



        Pass
        {
            Name "ForwardLilToonOutline"
            Tags { "LightMode" = "SRPDefaultUnlit" }
            Cull Front
            ZWrite On
            ZTest Less
            Blend SrcAlpha OneMinusSrcAlpha

            HLSLPROGRAM
            #pragma target 4.5
            #pragma vertex HoNprCharacterVertOutline
            #pragma fragment HoNprCharacterFragOutline
            ENDHLSL
        }


        Pass
        {
            Name "UniversalForward"
            Tags { "LightMode" = "UniversalForward" }

            Cull Off




            ZWrite On

            ZTest LEqual


            HLSLPROGRAM
            #pragma target 4.5
            #pragma vertex HoNprCharacterVert
            #pragma fragment HoNprCharacterFragForward
            ENDHLSL
        }


        Pass
        {
            Name "HoUrpAovOutput"
            Tags { "LightMode" = "HoUrpAovOutput" }
            Cull Back
            ZWrite Off
            ZTest LEqual

            HLSLPROGRAM
            #pragma target 4.5
            #pragma vertex HoNprCharacterVert
            #pragma fragment HoNprCharacterFragAov
            ENDHLSL
        }



        Pass
        {
            Name "DepthOnly"
            Tags { "LightMode" = "DepthOnly" }
            Cull Back
            ZWrite On
            ZTest LEqual
            ColorMask 0

            HLSLPROGRAM
            #pragma target 4.5
            #pragma vertex HoNprCharacterDepthVert
            #pragma fragment HoNprCharacterDepthFrag
            ENDHLSL
        }



        Pass
        {
            Name "ShadowCaster"
            Tags { "LightMode" = "ShadowCaster" }
            Cull Back
            ZWrite On
            ZTest LEqual
            ColorMask 0

            HLSLPROGRAM
            #pragma target 4.5
            #pragma vertex HoNprCharacterDepthVert
            #pragma fragment HoNprCharacterDepthFrag
            ENDHLSL
        }



    }

    CustomEditor "Hollow.HoNpr.Editor.MaterialUi.HoNprMaterialShaderGUI"
}

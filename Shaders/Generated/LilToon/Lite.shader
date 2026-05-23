// 由 HoNprShaderGenerator 生成。
// SourcePreset: MaterialPreset.Character_LilToon_Lite
// Template: MaterialTemplate.CharacterForward + MaterialTemplate.CharacterAov + MaterialTemplate.CharacterDepth + MaterialTemplate.CharacterShadow
// Blocks: MaterialBlock.BaseColorTexture, MaterialBlock.NormalMap, MaterialBlock.RegionMask, MaterialBlock.StyleRampAtlas, MaterialBlock.UrpMainLightInput, MaterialBlock.IndirectLightInput, MaterialBlock.ScreenAoReceiver, MaterialBlock.HoShadowReceiver, MaterialBlock.LilToonDiffuseRamp, MaterialBlock.LilToonRimLight, MaterialBlock.LilToonEmissionPrimary, MaterialBlock.MaterialSemanticProducer, MaterialBlock.AovOutputStandard, MaterialBlock.FinalColorComposite
// 不要手动修改生成体。请改 template / block / preset。
Shader "HoNpr/Character_LilToon_Lite"
{
    Properties
    {
        _HoNprBaseMap("Base Map", 2D) = "white" {}
        _HoUrpBaseColor("Base Color", Color) = (1, 1, 1, 1)
        _HoNprNormalMap("Normal Map", 2D) = "bump" {}

        _HoNprRegionMap("Region Map", 2D) = "white" {}
        _HoNprStyleRampAtlas("Style Ramp Atlas", 2D) = "white" {}
        _HoNprLilToonDiffuseRampThreshold("lilToon Diffuse Ramp Threshold", Range(0, 1)) = 0.48
        _HoNprLilToonDiffuseRampSoftness("lilToon Diffuse Ramp Softness", Range(0.001, 1)) = 0.08
        _HoNprRampRow("Ramp Row", Float) = 0
        _HoNprRampRows("Ramp Rows", Float) = 8








        _HoNprLilToonRimLightColor("lilToon RimLight Color", Color) = (0.75, 0.9, 1, 1)
        [Enum(Add,0,Screen,1,Max,2,Replace,3)] _HoNprLilToonRimLightBlendMode("lilToon RimLight Blend Mode", Float) = 0


        _HoNprLilToonRimPower("lilToon Rim Power", Range(0.1, 12)) = 3
        _HoNprLilToonRimMask("lilToon Rim Mask", Range(0, 1)) = 0.5





        _HoNprLilToonEmissionPrimaryColor("lilToon Primary Emission Color", Color) = (0, 0, 0, 1)
        _HoNprLilToonEmissionPrimaryIntensity("lilToon Primary Emission Intensity", Range(0, 16)) = 0
        [Enum(Add,0,Screen,1,Max,2,Replace,3)] _HoNprLilToonEmissionPrimaryBlendMode("lilToon Primary Emission Blend Mode", Float) = 0



        _HoUrpGeneratedMaterialClass("Material Class", Float) = 1

        _HoUrpGeneratedMaterialCustom0_3("Material Custom 0-3", Vector) = (0, 0, 0, 0)



    }

    HLSLINCLUDE
    #define HONPR_HAS_BASE_COLOR_TEXTURE 1
    #define HONPR_HAS_FINAL_COLOR_COMPOSITE 1
    #define HONPR_HAS_HORP_SHADOW_RECEIVER 1
    #define HONPR_HAS_INDIRECT_LIGHT 1
    #define HONPR_HAS_LILTOON_DIFFUSE_RAMP 1
    #define HONPR_HAS_LILTOON_EMISSION_PRIMARY 1
    #define HONPR_HAS_LILTOON_RIM_LIGHT 1
    #define HONPR_HAS_MATERIAL_SEMANTICS 1
    #define HONPR_HAS_NORMAL_MAP 1
    #define HONPR_HAS_REGION_MASK 1
    #define HONPR_HAS_SCREEN_AO_RECEIVER 1
    #define HONPR_HAS_STANDARD_AOV 1
    #define HONPR_HAS_STYLE_RAMP_ATLAS 1
    #define HONPR_HAS_URP_MAIN_LIGHT 1


#include "Packages/com.hollow.honpr/Shaders/ShaderLibrary/Assemblies/CharacterToon/HoNprCharacterToonLite.hlsl"






    ENDHLSL

    SubShader
    {


        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Opaque" "Queue" = "Geometry" }



        Pass
        {
            Name "UniversalForward"
            Tags { "LightMode" = "UniversalForward" }


            Cull Back



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

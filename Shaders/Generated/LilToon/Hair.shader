// 由 HoNprShaderGenerator 生成。
// SourcePreset: MaterialPreset.Hair_LilToon
// Template: MaterialTemplate.CharacterForward + MaterialTemplate.CharacterAov + MaterialTemplate.CharacterDepth + MaterialTemplate.CharacterShadow
// Blocks: MaterialBlock.BaseColorTexture, MaterialBlock.NormalMap, MaterialBlock.RegionMask, MaterialBlock.StyleRampAtlas, MaterialBlock.UrpMainLightInput, MaterialBlock.UrpAdditionalLightInput, MaterialBlock.IndirectLightInput, MaterialBlock.ScreenAoReceiver, MaterialBlock.HoShadowReceiver, MaterialBlock.ToonDiffuseRampLilToon, MaterialBlock.HairSpecularPrimary, MaterialBlock.HairSpecularSecondary, MaterialBlock.RimLightLilToon, MaterialBlock.BacklightLilToon, MaterialBlock.MatCapLilToon, MaterialBlock.EmissionPrimaryLilToon, MaterialBlock.MaterialSemanticProducer, MaterialBlock.AovOutputStandard, MaterialBlock.FinalColorComposite
// 不要手动修改生成体。请改 template / block / preset。
Shader "HoNpr/Hair_LilToon"
{
    Properties
    {
        _HoNprBaseMap("Base Map", 2D) = "white" {}
        _HoUrpBaseColor("Base Color", Color) = (1, 1, 1, 1)
        _HoNprNormalMap("Normal Map", 2D) = "bump" {}

        _HoNprRegionMap("Region Map", 2D) = "white" {}
        _HoNprStyleRampAtlas("Style Ramp Atlas", 2D) = "white" {}
        _HoNprToonDiffuseRampLilToonThreshold("Toon Diffuse Ramp-lilToon Threshold", Range(0, 1)) = 0.48
        _HoNprToonDiffuseRampLilToonSoftness("Toon Diffuse Ramp-lilToon Softness", Range(0.001, 1)) = 0.08
        _HoNprRampRow("Ramp Row", Float) = 0
        _HoNprRampRows("Ramp Rows", Float) = 8



        _HoNprHairSpecularPrimaryShift("Hair Specular Primary Shift", Range(-1, 1)) = 0.08
        _HoNprHairSpecularPrimaryWidth("Hair Specular Primary Width", Range(1, 256)) = 48
        _HoNprHairSpecularPrimaryMask("Hair Specular Primary Mask", Range(0, 1)) = 0.6
        [Enum(Add,0,Screen,1,Max,2,Replace,3)] _HoNprHairSpecularPrimaryBlendMode("Hair Specular Primary Blend Mode", Float) = 0


        _HoNprHairSpecularSecondaryShift("Hair Specular Secondary Shift", Range(-1, 1)) = -0.12
        _HoNprHairSpecularSecondaryWidth("Hair Specular Secondary Width", Range(1, 256)) = 96
        _HoNprHairSpecularSecondaryMask("Hair Specular Secondary Mask", Range(0, 1)) = 0.35
        [Enum(Add,0,Screen,1,Max,2,Replace,3)] _HoNprHairSpecularSecondaryBlendMode("Hair Specular Secondary Blend Mode", Float) = 0



        _HoNprBacklightLilToonColor("Backlight-lilToon Color", Color) = (0.7, 0.5, 0.35, 1)
        _HoNprBacklightLilToonPower("Backlight-lilToon Power", Range(0.1, 12)) = 2
        [Enum(Add,0,Screen,1,Max,2,Replace,3)] _HoNprBacklightLilToonBlendMode("Backlight-lilToon Blend Mode", Float) = 0


        _HoNprMatCapLilToonColor("MatCap-lilToon Color", Color) = (0.25, 0.25, 0.3, 1)
        _HoNprMatCapLilToonMask("MatCap-lilToon Mask", Range(0, 1)) = 0.25
        [Enum(Add,0,Screen,1,Max,2,Replace,3)] _HoNprMatCapLilToonBlendMode("MatCap-lilToon Blend Mode", Float) = 0


        _HoNprRimLightLilToonColor("RimLight-lilToon Color", Color) = (0.75, 0.9, 1, 1)
        [Enum(Add,0,Screen,1,Max,2,Replace,3)] _HoNprRimLightLilToonBlendMode("RimLight-lilToon Blend Mode", Float) = 0


        _HoNprRimLilToonPower("Rim-lilToon Power", Range(0.1, 12)) = 3
        _HoNprRimLilToonMask("Rim-lilToon Mask", Range(0, 1)) = 0.5





        _HoNprEmissionPrimaryLilToonColor("EmissionPrimary-lilToon Color", Color) = (0, 0, 0, 1)
        _HoNprEmissionPrimaryLilToonIntensity("EmissionPrimary-lilToon Intensity", Range(0, 16)) = 0
        [Enum(Add,0,Screen,1,Max,2,Replace,3)] _HoNprEmissionPrimaryLilToonBlendMode("EmissionPrimary-lilToon Blend Mode", Float) = 0



        _HoUrpGeneratedMaterialClass("Material Class", Float) = 1

        _HoUrpGeneratedMaterialCustom0_3("Material Custom 0-3", Vector) = (0, 0, 0, 0)



    }

    HLSLINCLUDE
    #define HONPR_HAS_BACKLIGHT_LILTOON 1
    #define HONPR_HAS_BASE_COLOR_TEXTURE 1
    #define HONPR_HAS_EMISSION_PRIMARY_LILTOON 1
    #define HONPR_HAS_FINAL_COLOR_COMPOSITE 1
    #define HONPR_HAS_HAIR_SPECULAR_PRIMARY 1
    #define HONPR_HAS_HAIR_SPECULAR_SECONDARY 1
    #define HONPR_HAS_HORP_SHADOW_RECEIVER 1
    #define HONPR_HAS_INDIRECT_LIGHT 1
    #define HONPR_HAS_MATCAP_LILTOON 1
    #define HONPR_HAS_MATERIAL_SEMANTICS 1
    #define HONPR_HAS_NORMAL_MAP 1
    #define HONPR_HAS_REGION_MASK 1
    #define HONPR_HAS_RIM_LIGHT_LILTOON 1
    #define HONPR_HAS_SCREEN_AO_RECEIVER 1
    #define HONPR_HAS_STANDARD_AOV 1
    #define HONPR_HAS_STYLE_RAMP_ATLAS 1
    #define HONPR_HAS_TOON_DIFFUSE_RAMP_LILTOON 1
    #define HONPR_HAS_URP_ADDITIONAL_LIGHTS 1
    #define HONPR_HAS_URP_MAIN_LIGHT 1







#include "Packages/com.hollow.honpr/Shaders/ShaderLibrary/Assemblies/CharacterToon/HoNprCharacterToonHair.hlsl"

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

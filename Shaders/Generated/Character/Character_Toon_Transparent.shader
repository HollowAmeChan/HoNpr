// 由 HoNprShaderGenerator 生成。
// SourcePreset: MaterialPreset.Character_Toon_Transparent
// Template: MaterialTemplate.CharacterForward + MaterialTemplate.CharacterAov + MaterialTemplate.CharacterOit
// Blocks: MaterialBlock.BaseColorTexture, MaterialBlock.NormalMap, MaterialBlock.SemanticMap, MaterialBlock.RegionMask, MaterialBlock.StyleRampAtlas, MaterialBlock.UrpMainLightInput, MaterialBlock.IndirectLightInput, MaterialBlock.ScreenAoReceiver, MaterialBlock.HoShadowReceiver, MaterialBlock.ToonDiffuseRampLilToon, MaterialBlock.ToonSpecularLilToon, MaterialBlock.RimLightLilToon, MaterialBlock.BacklightLilToon, MaterialBlock.MatCapLilToon, MaterialBlock.EmissionPrimaryLilToon, MaterialBlock.MaterialSemanticProducer, MaterialBlock.AovOutputStandard, MaterialBlock.AlphaClipPolicy, MaterialBlock.TransparentComposite, MaterialBlock.OitAccumulationOutput
// 不要手动修改生成体。请改 template / block / preset。
Shader "HoNpr/Character/Toon_Transparent"
{
    Properties
    {
        _HoNprBaseMap("Base Map", 2D) = "white" {}
        _HoUrpBaseColor("Base Color", Color) = (1, 1, 1, 1)
        _HoNprNormalMap("Normal Map", 2D) = "bump" {}

        _HoNprSemanticMap("Semantic Map", 2D) = "white" {}

        _HoNprRegionMap("Region Map", 2D) = "white" {}
        _HoNprStyleRampAtlas("Style Ramp Atlas", 2D) = "white" {}
        _HoNprToonDiffuseRampLilToonThreshold("Toon Diffuse Ramp-lilToon Threshold", Range(0, 1)) = 0.48
        _HoNprToonDiffuseRampLilToonSoftness("Toon Diffuse Ramp-lilToon Softness", Range(0.001, 1)) = 0.08
        _HoNprRampRow("Ramp Row", Float) = 0
        _HoNprRampRows("Ramp Rows", Float) = 8


        _HoNprToonSpecularLilToonThreshold("Toon Specular-lilToon Threshold", Range(0, 1)) = 0.72
        _HoNprToonSpecularLilToonSoftness("Toon Specular-lilToon Softness", Range(0.001, 1)) = 0.08
        _HoNprToonSpecularLilToonMask("Toon Specular-lilToon Mask", Range(0, 1)) = 0.6
        [Enum(Add,0,Screen,1,Max,2,Replace,3)] _HoNprToonSpecularLilToonBlendMode("Toon Specular-lilToon Blend Mode", Float) = 0



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


        _HoNprAlphaClipThreshold("Alpha Clip Threshold", Range(0, 1)) = 0


        _HoUrpSupportsOit("Supports OIT", Float) = 1
        _HoUrpParticipatesOit("Participates OIT", Float) = 1

    }

    HLSLINCLUDE
    #define HONPR_HAS_ALPHA_CLIP_POLICY 1
    #define HONPR_HAS_BACKLIGHT_LILTOON 1
    #define HONPR_HAS_BASE_COLOR_TEXTURE 1
    #define HONPR_HAS_EMISSION_PRIMARY_LILTOON 1
    #define HONPR_HAS_HORP_SHADOW_RECEIVER 1
    #define HONPR_HAS_INDIRECT_LIGHT 1
    #define HONPR_HAS_MATCAP_LILTOON 1
    #define HONPR_HAS_MATERIAL_SEMANTICS 1
    #define HONPR_HAS_NORMAL_MAP 1
    #define HONPR_HAS_OIT_ACCUMULATION 1
    #define HONPR_HAS_REGION_MASK 1
    #define HONPR_HAS_RIM_LIGHT_LILTOON 1
    #define HONPR_HAS_SCREEN_AO_RECEIVER 1
    #define HONPR_HAS_SEMANTIC_MAP 1
    #define HONPR_HAS_STANDARD_AOV 1
    #define HONPR_HAS_STYLE_RAMP_ATLAS 1
    #define HONPR_HAS_TOON_DIFFUSE_RAMP_LILTOON 1
    #define HONPR_HAS_TOON_SPECULAR_LILTOON 1
    #define HONPR_HAS_TRANSPARENT_COMPOSITE 1
    #define HONPR_HAS_URP_MAIN_LIGHT 1





#include "Packages/com.hollow.honpr/Shaders/ShaderLibrary/Assemblies/CharacterToon/HoNprCharacterToonTransparent.hlsl"

    ENDHLSL

    SubShader
    {

        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Transparent" "Queue" = "Transparent" }




        Pass
        {
            Name "UniversalForward"
            Tags { "LightMode" = "UniversalForward" }


            Cull Back


            ZWrite Off


            ZTest LEqual

            Blend SrcAlpha OneMinusSrcAlpha


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
            Name "HoUrpOitAccumulation"
            Tags { "LightMode" = "HoUrpOitAccumulation" }
            Cull Back
            ZWrite Off
            ZTest LEqual
            Blend One One, Zero OneMinusSrcAlpha

            HLSLPROGRAM
            #pragma target 4.5
            #pragma vertex HoNprCharacterVert
            #pragma fragment HoNprCharacterFragOit
            ENDHLSL
        }


    }

    CustomEditor "Hollow.HoNpr.Editor.MaterialUi.HoNprMaterialShaderGUI"
}

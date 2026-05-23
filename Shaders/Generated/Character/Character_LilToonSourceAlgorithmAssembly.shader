// 由 HoNprShaderGenerator 生成。
// SourcePreset: MaterialPreset.Character_LilToonSourceAlgorithmAssembly
// Template: MaterialTemplate.CharacterForward + MaterialTemplate.CharacterOutline + MaterialTemplate.CharacterAov + MaterialTemplate.CharacterDepth + MaterialTemplate.CharacterShadow + MaterialTemplate.CharacterOit
// Blocks: MaterialBlock.BaseColorTexture, MaterialBlock.NormalMap, MaterialBlock.SemanticMap, MaterialBlock.RegionMask, MaterialBlock.StyleRampAtlas, MaterialBlock.OutlineLilToon, MaterialBlock.UrpMainLightInput, MaterialBlock.IndirectLightInput, MaterialBlock.ScreenAoReceiver, MaterialBlock.HoShadowReceiver, MaterialBlock.ToonDiffuseRampLilToon, MaterialBlock.ToonSpecularLilToon, MaterialBlock.RimShadeLilToon, MaterialBlock.RimLightLilToon, MaterialBlock.BacklightLilToon, MaterialBlock.BackfaceColorLilToon, MaterialBlock.MatCapLilToon, MaterialBlock.SecondaryMatCapLilToon, MaterialBlock.GlitterLilToon, MaterialBlock.EmissionPrimaryLilToon, MaterialBlock.EmissionSecondaryLilToon, MaterialBlock.DistanceFadeLilToon, MaterialBlock.MaterialSemanticProducer, MaterialBlock.SssSourceProducer, MaterialBlock.AovOutputStandard, MaterialBlock.AlphaClipPolicy, MaterialBlock.TransparentComposite, MaterialBlock.OitAccumulationOutput
// 不要手动修改生成体。请改 template / block / preset。
Shader "HoNpr/Character_LilToonSourceAlgorithmAssembly"
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


        _HoNprToonSpecularLilToonThreshold("Toon Specular-lilToon Threshold", Range(0, 1)) = 0.72
        _HoNprToonSpecularLilToonSoftness("Toon Specular-lilToon Softness", Range(0.001, 1)) = 0.08
        _HoNprToonSpecularLilToonMask("Toon Specular-lilToon Mask", Range(0, 1)) = 0.6
        [Enum(Add,0,Screen,1,Max,2,Replace,3)] _HoNprToonSpecularLilToonBlendMode("Toon Specular-lilToon Blend Mode", Float) = 0




        _HoNprRimShadeLilToonColor("RimShade-lilToon Color", Color) = (0.15, 0.16, 0.2, 1)
        [Enum(Add,0,Screen,1,Max,2,Replace,3)] _HoNprRimShadeLilToonBlendMode("RimShade-lilToon Blend Mode", Float) = 0


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


        _HoNprBackfaceColorLilToonColor("Backface Color-lilToon Color", Color) = (0, 0, 0, 0)
        [Enum(Add,0,Screen,1,Max,2,Replace,3)] _HoNprBackfaceColorLilToonBlendMode("Backface Color-lilToon Blend Mode", Float) = 0


        _HoNprSecondaryMatCapLilToonColor("Secondary MatCap-lilToon Color", Color) = (0.08, 0.1, 0.14, 1)
        _HoNprSecondaryMatCapLilToonMask("Secondary MatCap-lilToon Mask", Range(0, 1)) = 0
        [Enum(Add,0,Screen,1,Max,2,Replace,3)] _HoNprSecondaryMatCapLilToonBlendMode("Secondary MatCap-lilToon Blend Mode", Float) = 0


        _HoNprGlitterLilToonColor("Glitter-lilToon Color", Color) = (1, 0.92, 0.72, 1)
        _HoNprGlitterLilToonMask("Glitter-lilToon Mask", Range(0, 1)) = 0
        _HoNprGlitterLilToonDensity("Glitter-lilToon Density", Range(1, 256)) = 48
        _HoNprGlitterLilToonThreshold("Glitter-lilToon Threshold", Range(0, 1)) = 0.94
        _HoNprGlitterLilToonPower("Glitter-lilToon Power", Range(1, 128)) = 32
        [Enum(Add,0,Screen,1,Max,2,Replace,3)] _HoNprGlitterLilToonBlendMode("Glitter-lilToon Blend Mode", Float) = 0


        _HoNprEmissionPrimaryLilToonColor("EmissionPrimary-lilToon Color", Color) = (0, 0, 0, 1)
        _HoNprEmissionPrimaryLilToonIntensity("EmissionPrimary-lilToon Intensity", Range(0, 16)) = 0
        [Enum(Add,0,Screen,1,Max,2,Replace,3)] _HoNprEmissionPrimaryLilToonBlendMode("EmissionPrimary-lilToon Blend Mode", Float) = 0


        _HoNprEmissionSecondaryLilToonColor("Secondary Emission-lilToon Color", Color) = (0, 0, 0, 1)
        _HoNprEmissionSecondaryLilToonIntensity("Secondary Emission-lilToon Intensity", Range(0, 16)) = 0
        [Enum(Add,0,Screen,1,Max,2,Replace,3)] _HoNprEmissionSecondaryLilToonBlendMode("Secondary Emission-lilToon Blend Mode", Float) = 0


        _HoNprDistanceFadeLilToonColor("Distance Fade-lilToon Color", Color) = (0, 0, 0, 1)
        _HoNprDistanceFadeLilToonStart("Distance Fade-lilToon Start", Float) = 50
        _HoNprDistanceFadeLilToonEnd("Distance Fade-lilToon End", Float) = 80
        _HoNprDistanceFadeLilToonStrength("Distance Fade-lilToon Strength", Range(0, 1)) = 0
        [Enum(Add,0,Screen,1,Max,2,Replace,3)] _HoNprDistanceFadeLilToonBlendMode("Distance Fade-lilToon Blend Mode", Float) = 0

        _HoUrpGeneratedMaterialClass("Material Class", Float) = 1

        _HoUrpGeneratedMaterialSssProfile("SSS Profile", Float) = 0
        _HoUrpGeneratedMaterialThickness("Thickness", Range(0, 1)) = 0
        _HoUrpGeneratedMaterialCurvature("Curvature", Range(-1, 1)) = 0

        _HoUrpGeneratedMaterialCustom0_3("Material Custom 0-3", Vector) = (0, 0, 0, 0)

        _HoUrpGeneratedSssSourceColor("SSS Source Color", Color) = (1, 0.75, 0.6, 1)
        _HoUrpGeneratedSssWeight("SSS Weight", Range(0, 1)) = 0


        _HoNprAlphaClipThreshold("Alpha Clip Threshold", Range(0, 1)) = 0


        _HoUrpSupportsOit("Supports OIT", Float) = 1
        _HoUrpParticipatesOit("Participates OIT", Float) = 1

    }

    HLSLINCLUDE
    #define HONPR_HAS_ALPHA_CLIP_POLICY 1
    #define HONPR_HAS_BACKFACE_COLOR_LILTOON 1
    #define HONPR_HAS_BACKLIGHT_LILTOON 1
    #define HONPR_HAS_BASE_COLOR_TEXTURE 1
    #define HONPR_HAS_DISTANCE_FADE_LILTOON 1
    #define HONPR_HAS_EMISSION_PRIMARY_LILTOON 1
    #define HONPR_HAS_EMISSION_SECONDARY_LILTOON 1
    #define HONPR_HAS_GLITTER_LILTOON 1
    #define HONPR_HAS_HORP_SHADOW_RECEIVER 1
    #define HONPR_HAS_INDIRECT_LIGHT 1
    #define HONPR_HAS_MATCAP_LILTOON 1
    #define HONPR_HAS_MATERIAL_SEMANTICS 1
    #define HONPR_HAS_NORMAL_MAP 1
    #define HONPR_HAS_OIT_ACCUMULATION 1
    #define HONPR_HAS_OUTLINE_LILTOON 1
    #define HONPR_HAS_REGION_MASK 1
    #define HONPR_HAS_RIM_LIGHT_LILTOON 1
    #define HONPR_HAS_RIM_SHADE_LILTOON 1
    #define HONPR_HAS_SCREEN_AO_RECEIVER 1
    #define HONPR_HAS_SECONDARY_MATCAP_LILTOON 1
    #define HONPR_HAS_SEMANTIC_MAP 1
    #define HONPR_HAS_SSS_SOURCE 1
    #define HONPR_HAS_STANDARD_AOV 1
    #define HONPR_HAS_STYLE_RAMP_ATLAS 1
    #define HONPR_HAS_TOON_DIFFUSE_RAMP_LILTOON 1
    #define HONPR_HAS_TOON_SPECULAR_LILTOON 1
    #define HONPR_HAS_TRANSPARENT_COMPOSITE 1
    #define HONPR_HAS_URP_MAIN_LIGHT 1

#include "Packages/com.hollow.honpr/Shaders/ShaderLibrary/Assemblies/CharacterToon/HoNprCharacterToonLilToonSourceAlgorithmAssembly.hlsl"







    ENDHLSL

    SubShader
    {

        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Transparent" "Queue" = "Transparent" }




        Pass
        {
            Name "ForwardOutlineLilToon"
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

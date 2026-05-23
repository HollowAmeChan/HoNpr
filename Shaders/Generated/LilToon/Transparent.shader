// 由 HoNprShaderGenerator 生成。
// SourcePreset: MaterialPreset.Character_LilToon_Transparent
// Template: MaterialTemplate.CharacterForward + MaterialTemplate.CharacterAov + MaterialTemplate.CharacterOit
// Blocks: MaterialBlock.BaseColorTexture, MaterialBlock.NormalMap, MaterialBlock.SemanticMap, MaterialBlock.RegionMask, MaterialBlock.StyleRampAtlas, MaterialBlock.UrpMainLightInput, MaterialBlock.IndirectLightInput, MaterialBlock.ScreenAoReceiver, MaterialBlock.HoShadowReceiver, MaterialBlock.LilToonDiffuseRamp, MaterialBlock.LilToonSpecular, MaterialBlock.LilToonRimLight, MaterialBlock.LilToonBacklight, MaterialBlock.LilToonMatCap, MaterialBlock.LilToonEmissionPrimary, MaterialBlock.MaterialSemanticProducer, MaterialBlock.AovOutputStandard, MaterialBlock.AlphaClipPolicy, MaterialBlock.TransparentComposite, MaterialBlock.OitAccumulationOutput
// 不要手动修改生成体。请改 template / block / preset。
Shader "HoNpr/Character_LilToon_Transparent"
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


        _HoNprLilToonSpecularThreshold("lilToon Specular Threshold", Range(0, 1)) = 0.72
        _HoNprLilToonSpecularSoftness("lilToon Specular Softness", Range(0.001, 1)) = 0.08
        _HoNprLilToonSpecularMask("lilToon Specular Mask", Range(0, 1)) = 0.6
        [Enum(Add,0,Screen,1,Max,2,Replace,3)] _HoNprLilToonSpecularBlendMode("lilToon Specular Blend Mode", Float) = 0





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





        _HoNprLilToonEmissionPrimaryColor("lilToon Primary Emission Color", Color) = (0, 0, 0, 1)
        _HoNprLilToonEmissionPrimaryIntensity("lilToon Primary Emission Intensity", Range(0, 16)) = 0
        [Enum(Add,0,Screen,1,Max,2,Replace,3)] _HoNprLilToonEmissionPrimaryBlendMode("lilToon Primary Emission Blend Mode", Float) = 0



        _HoUrpGeneratedMaterialClass("Material Class", Float) = 1

        _HoUrpGeneratedMaterialCustom0_3("Material Custom 0-3", Vector) = (0, 0, 0, 0)


        _HoNprAlphaClipThreshold("Alpha Clip Threshold", Range(0, 1)) = 0


        _HoUrpSupportsOit("Supports OIT", Float) = 1
        _HoUrpParticipatesOit("Participates OIT", Float) = 1

    }

    HLSLINCLUDE






#include "Packages/com.hollow.honpr/Shaders/ShaderLibrary/Assemblies/CharacterLilToon/HoNprCharacterLilToonTransparent.hlsl"


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

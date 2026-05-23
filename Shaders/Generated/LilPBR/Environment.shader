// 由 HoNprShaderGenerator 生成。
// SourcePreset: MaterialPreset.Environment_LilPBR
// Template: MaterialTemplate.EnvironmentForward + MaterialTemplate.EnvironmentAov
// Blocks: MaterialBlock.BaseColorTexture, MaterialBlock.NormalMap, MaterialBlock.LilPbrMaterialMapPacked, MaterialBlock.UrpMainLightInput, MaterialBlock.UrpAdditionalLightInput, MaterialBlock.IndirectLightInput, MaterialBlock.ScreenAoReceiver, MaterialBlock.HoShadowReceiver, MaterialBlock.LilPbrDiffuse, MaterialBlock.LilPbrSpecularGGX, MaterialBlock.LilPbrSpecularAnisotropic, MaterialBlock.LilPbrClearCoatSpecular, MaterialBlock.MaterialSemanticProducer, MaterialBlock.AovOutputStandard, MaterialBlock.FinalColorComposite
// 不要手动修改生成体。请改 template / block / preset。
Shader "HoNpr/Environment_LilPBR"
{
    Properties
    {
        _HoNprBaseMap("Base Map", 2D) = "white" {}
        _HoUrpBaseColor("Base Color", Color) = (1, 1, 1, 1)
        _HoNprNormalMap("Normal Map", 2D) = "bump" {}
        _HoNprMaterialMap("Material Map", 2D) = "white" {}
        _HoNprMaterialMetallicScale("Metallic Scale", Range(0, 1)) = 1
        _HoNprMaterialRoughnessScale("Roughness Scale", Range(0.01, 2)) = 1
        _HoNprMaterialOcclusionStrength("Occlusion Strength", Range(0, 1)) = 1
        _HoNprAnisotropy("Anisotropy", Range(-1, 1)) = 0
        _HoNprAnisotropyMask("Anisotropy Mask", Range(0, 1)) = 0
        _HoNprClearCoatMask("Clear Coat Mask", Range(0, 1)) = 0
        _HoNprClearCoatRoughness("Clear Coat Roughness", Range(0.01, 1)) = 0.25
        _HoUrpGeneratedMaterialClass("Material Class", Float) = 2
        _HoUrpGeneratedMaterialSssProfile("SSS Profile", Float) = 0
        _HoUrpGeneratedMaterialThickness("Thickness", Range(0, 1)) = 0
        _HoUrpGeneratedMaterialCurvature("Curvature", Range(-1, 1)) = 0
        _HoUrpGeneratedMaterialCustom0_3("Material Custom 0-3", Vector) = (0, 0, 0, 0)
    }

    HLSLINCLUDE
    #include "Packages/com.hollow.honpr/Shaders/ShaderLibrary/Assemblies/EnvironmentLilPbr/HoNprEnvironmentLilPbr.hlsl"
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
            #pragma vertex HoNprEnvironmentVert
            #pragma fragment HoNprEnvironmentFragForward
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
            #pragma vertex HoNprEnvironmentVert
            #pragma fragment HoNprEnvironmentFragAov
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
            #pragma vertex HoNprEnvironmentDepthVert
            #pragma fragment HoNprEnvironmentDepthFrag
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
            #pragma vertex HoNprEnvironmentDepthVert
            #pragma fragment HoNprEnvironmentDepthFrag
            ENDHLSL
        }


    }

    CustomEditor "Hollow.HoNpr.Editor.MaterialUi.HoNprMaterialShaderGUI"
}

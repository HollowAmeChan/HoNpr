// 由 HoNprShaderGenerator 生成。
// SourcePreset: MaterialPreset.Character_Toon_Standard
// Template: MaterialTemplate.CharacterForward + MaterialTemplate.CharacterOutline + MaterialTemplate.CharacterAov + MaterialTemplate.CharacterDepth + MaterialTemplate.CharacterShadow
// Blocks: MaterialBlock.BaseColorTexture, MaterialBlock.NormalMap, MaterialBlock.RegionMask, MaterialBlock.StyleRampAtlas, MaterialBlock.OutlineLilToon, MaterialBlock.UrpMainLightInput, MaterialBlock.UrpAdditionalLightInput, MaterialBlock.IndirectLightInput, MaterialBlock.ScreenAoReceiver, MaterialBlock.HoShadowReceiver, MaterialBlock.ToonDiffuseRampLilToon, MaterialBlock.ToonSpecularLilToon, MaterialBlock.RimShadeLilToon, MaterialBlock.RimLightLilToon, MaterialBlock.BacklightLilToon, MaterialBlock.MatCapLilToon, MaterialBlock.EmissionPrimaryLilToon, MaterialBlock.MaterialSemanticProducer, MaterialBlock.AovOutputStandard, MaterialBlock.FinalColorComposite
// 不要手动修改生成体。请改 template / block / preset。
Shader "HoNpr/Character/Toon_Standard"
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
    #define HONPR_HAS_HORP_SHADOW_RECEIVER 1
    #define HONPR_HAS_INDIRECT_LIGHT 1
    #define HONPR_HAS_MATCAP_LILTOON 1
    #define HONPR_HAS_MATERIAL_SEMANTICS 1
    #define HONPR_HAS_NORMAL_MAP 1
    #define HONPR_HAS_OUTLINE_LILTOON 1
    #define HONPR_HAS_REGION_MASK 1
    #define HONPR_HAS_RIM_LIGHT_LILTOON 1
    #define HONPR_HAS_RIM_SHADE_LILTOON 1
    #define HONPR_HAS_SCREEN_AO_RECEIVER 1
    #define HONPR_HAS_STANDARD_AOV 1
    #define HONPR_HAS_STYLE_RAMP_ATLAS 1
    #define HONPR_HAS_TOON_DIFFUSE_RAMP_LILTOON 1
    #define HONPR_HAS_TOON_SPECULAR_LILTOON 1
    #define HONPR_HAS_URP_ADDITIONAL_LIGHTS 1
    #define HONPR_HAS_URP_MAIN_LIGHT 1
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.hollow.hourp-extensions/Runtime/Shaders/ShaderLibrary/HoUrpObjectSemantic.hlsl"
#include "Packages/com.hollow.hourp-extensions/Runtime/Shaders/ShaderLibrary/HoUrpMaterialSurface.hlsl"
#include "Packages/com.hollow.hourp-extensions/Runtime/Shaders/ShaderLibrary/HoUrpMaterialAov.hlsl"
#include "Packages/com.hollow.hourp-extensions/Runtime/Shaders/ShaderLibrary/HoUrpMaterialOit.hlsl"
#include "Packages/com.hollow.honpr/Shaders/ShaderLibrary/HoNprCommon.hlsl"
#include "Packages/com.hollow.honpr/Shaders/ShaderLibrary/StandardSurface/HoNprStandardSurface.hlsl"
#include "Packages/com.hollow.honpr/Shaders/ShaderLibrary/StylizedSurface/HoNprStylizedSurface.hlsl"
#include "Packages/com.hollow.honpr/Shaders/ShaderLibrary/StylizedSurface/HoNprToonLobes.hlsl"
#include "Packages/com.hollow.honpr/Shaders/ShaderLibrary/StylizedSurface/HoNprStylizedLobes.hlsl"
#include "Packages/com.hollow.honpr/Shaders/ShaderLibrary/StylizedSurface/HoNprOutline.hlsl"
#include "Packages/com.hollow.honpr/Shaders/ShaderLibrary/Composite/HoNprComposite.hlsl"

TEXTURE2D(_HoNprBaseMap);
SAMPLER(sampler_HoNprBaseMap);
TEXTURE2D(_HoNprStyleRampAtlas);
SAMPLER(sampler_HoNprStyleRampAtlas);
#if defined(HONPR_HAS_SEMANTIC_MAP)
TEXTURE2D(_HoNprSemanticMap);
SAMPLER(sampler_HoNprSemanticMap);
#endif
TEXTURE2D(_HoNprRegionMap);
SAMPLER(sampler_HoNprRegionMap);
#if defined(HONPR_HAS_OUTLINE_LILTOON)
TEXTURE2D(_HoNprOutlineTex);
SAMPLER(sampler_HoNprOutlineTex);
TEXTURE2D(_HoNprOutlineWidthMask);
SAMPLER(sampler_HoNprOutlineWidthMask);
TEXTURE2D(_HoNprOutlineVectorMap);
SAMPLER(sampler_HoNprOutlineVectorMap);
#endif

float4 _HoNprBaseMap_ST;
#if defined(HONPR_HAS_OUTLINE_LILTOON)
float4 _HoNprOutlineTex_ST;
float4 _HoNprOutlineWidthMask_ST;
float4 _HoNprOutlineVectorMap_ST;
#endif

half4 _HoUrpBaseColor;
half _HoNprToonDiffuseRampLilToonThreshold;
half _HoNprToonDiffuseRampLilToonSoftness;
half _HoNprRampRow;
half _HoNprRampRows;
#if defined(HONPR_HAS_TOON_SPECULAR_LILTOON)
half _HoNprToonSpecularLilToonThreshold;
half _HoNprToonSpecularLilToonSoftness;
half _HoNprToonSpecularLilToonMask;
half _HoNprToonSpecularLilToonBlendMode;
#endif
#if defined(HONPR_HAS_RIM_LIGHT_LILTOON)
half4 _HoNprRimLightLilToonColor;
half _HoNprRimLightLilToonBlendMode;
#endif
#if defined(HONPR_HAS_RIM_LIGHT_LILTOON) || defined(HONPR_HAS_RIM_SHADE_LILTOON)
half _HoNprRimLilToonPower;
half _HoNprRimLilToonMask;
#endif
#if defined(HONPR_HAS_RIM_SHADE_LILTOON)
half4 _HoNprRimShadeLilToonColor;
half _HoNprRimShadeLilToonBlendMode;
#endif
#if defined(HONPR_HAS_BACKLIGHT_LILTOON)
half4 _HoNprBacklightLilToonColor;
half _HoNprBacklightLilToonPower;
half _HoNprBacklightLilToonBlendMode;
#endif
#if defined(HONPR_HAS_BACKFACE_COLOR_LILTOON)
half4 _HoNprBackfaceColorLilToonColor;
half _HoNprBackfaceColorLilToonBlendMode;
#endif
#if defined(HONPR_HAS_MATCAP_LILTOON)
half4 _HoNprMatCapLilToonColor;
half _HoNprMatCapLilToonMask;
half _HoNprMatCapLilToonBlendMode;
#endif
#if defined(HONPR_HAS_SECONDARY_MATCAP_LILTOON)
half4 _HoNprSecondaryMatCapLilToonColor;
half _HoNprSecondaryMatCapLilToonMask;
half _HoNprSecondaryMatCapLilToonBlendMode;
#endif
#if defined(HONPR_HAS_GLITTER_LILTOON)
half4 _HoNprGlitterLilToonColor;
half _HoNprGlitterLilToonMask;
half _HoNprGlitterLilToonDensity;
half _HoNprGlitterLilToonThreshold;
half _HoNprGlitterLilToonPower;
half _HoNprGlitterLilToonBlendMode;
#endif
#if defined(HONPR_HAS_EMISSION_PRIMARY_LILTOON)
half4 _HoNprEmissionPrimaryLilToonColor;
half _HoNprEmissionPrimaryLilToonIntensity;
half _HoNprEmissionPrimaryLilToonBlendMode;
#endif
#if defined(HONPR_HAS_EMISSION_SECONDARY_LILTOON)
half4 _HoNprEmissionSecondaryLilToonColor;
half _HoNprEmissionSecondaryLilToonIntensity;
half _HoNprEmissionSecondaryLilToonBlendMode;
#endif
#if defined(HONPR_HAS_DISTANCE_FADE_LILTOON)
half4 _HoNprDistanceFadeLilToonColor;
half _HoNprDistanceFadeLilToonStart;
half _HoNprDistanceFadeLilToonEnd;
half _HoNprDistanceFadeLilToonStrength;
half _HoNprDistanceFadeLilToonBlendMode;
#endif
#if defined(HONPR_HAS_ALPHA_CLIP_POLICY)
half _HoNprAlphaClipThreshold;
#endif

#if defined(HONPR_HAS_OUTLINE_LILTOON)
half4 _HoNprOutlineColor;
half4 _HoNprOutlineLitColor;
half _HoNprOutlineLitApplyTex;
half _HoNprOutlineLitScale;
half _HoNprOutlineLitOffset;
float _HoNprOutlineWidth;
float _HoNprOutlineFixWidth;
float _HoNprOutlineZBias;
float _HoNprOutlineVertexWidthMode;
float _HoNprOutlineVectorScale;
half _HoNprOutlineEnableLighting;
#endif

float _HoUrpGeneratedMaterialClass;
#if defined(HONPR_HAS_SSS_SOURCE)
float _HoUrpGeneratedMaterialSssProfile;
float _HoUrpGeneratedMaterialThickness;
float _HoUrpGeneratedMaterialCurvature;
#endif
float4 _HoUrpGeneratedMaterialCustom0_3;
#if defined(HONPR_HAS_SSS_SOURCE)
float4 _HoUrpGeneratedSssSourceColor;
float _HoUrpGeneratedSssWeight;
#endif
#if defined(HONPR_HAS_OIT_ACCUMULATION)
float _HoUrpSupportsOit;
float _HoUrpParticipatesOit;
#endif

struct HoNprCharacterAttributes
{
    float4 positionOS : POSITION;
    float3 normalOS : NORMAL;
    float4 tangentOS : TANGENT;
    half4 color : COLOR;
    float2 uv : TEXCOORD0;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct HoNprCharacterVaryings
{
    float4 positionCS : SV_POSITION;
    float3 positionWS : TEXCOORD0;
    half3 normalWS : TEXCOORD1;
    float2 uv : TEXCOORD2;
    float2 depthZW : TEXCOORD3;
    UNITY_VERTEX_OUTPUT_STEREO
};

struct HoNprCharacterAovOutput
{
    half4 maskId : SV_Target0;
    half4 normalDepth : SV_Target1;
    half4 objectCustom0 : SV_Target2;
    half4 objectCustom1 : SV_Target3;
    half4 surfaceData : SV_Target4;
    half4 materialCustom0 : SV_Target5;
    half4 sssSource : SV_Target6;
};

#if defined(HONPR_HAS_OIT_ACCUMULATION)
struct HoNprCharacterOitOutput
{
    half4 accumulation : SV_Target0;
    half revealage : SV_Target1;
};
#endif

HoNprCharacterVaryings HoNprCharacterVert(HoNprCharacterAttributes input)
{
    HoNprCharacterVaryings output;
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);
    VertexPositionInputs positionInputs = GetVertexPositionInputs(input.positionOS.xyz);
    VertexNormalInputs normalInputs = GetVertexNormalInputs(input.normalOS);
    output.positionCS = positionInputs.positionCS;
    output.positionWS = positionInputs.positionWS;
    output.normalWS = NormalizeNormalPerVertex(normalInputs.normalWS);
    output.uv = input.uv * _HoNprBaseMap_ST.xy + _HoNprBaseMap_ST.zw;
    output.depthZW = positionInputs.positionCS.zw;
    return output;
}

HoNprSemanticMapData HoNprCharacterResolveSemanticMap(float2 uv)
{
#if defined(HONPR_HAS_SEMANTIC_MAP)
    return HoNprApplySemanticMap(SAMPLE_TEXTURE2D(_HoNprSemanticMap, sampler_HoNprSemanticMap, uv));
#else
    return HoNprCreateSemanticMapData(half4(0.0h, 1.0h, 1.0h, 1.0h));
#endif
}

half4 HoNprCharacterFragForward(HoNprCharacterVaryings input, FRONT_FACE_TYPE facing : FRONT_FACE_SEMANTIC) : SV_Target
{
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
    half4 baseSample = SAMPLE_TEXTURE2D(_HoNprBaseMap, sampler_HoNprBaseMap, input.uv);
    half4 regionSample = SAMPLE_TEXTURE2D(_HoNprRegionMap, sampler_HoNprRegionMap, input.uv);
    HoNprSemanticMapData semanticMap = HoNprCharacterResolveSemanticMap(input.uv);
    HoNprRegionMaskData regionMask = HoNprApplyRegionMask(regionSample);

    HoUrpSurfaceData surface = HoUrpCreateSurfaceData(_HoUrpBaseColor.rgb, _HoUrpBaseColor.a, input.normalWS);
    surface = HoNprApplyBaseColorTexture(surface, baseSample, _HoUrpBaseColor);
#if defined(HONPR_HAS_ALPHA_CLIP_POLICY)
    clip(surface.alpha - _HoNprAlphaClipThreshold);
#endif

    half3 viewDirWS = HoNprSafeNormalize(GetWorldSpaceViewDir(input.positionWS), surface.normalWS);
    half3 lightDirWS = HoNprSafeNormalize(half3(0.35h, 0.75h, 0.55h), half3(0.0h, 1.0h, 0.0h));
    HoNprLightingContext lighting = HoNprCreateLightingContext(lightDirWS, half3(1.0h, 0.94h, 0.86h));
    lighting = HoNprResolveIndirectLight(lighting, half3(0.12h, 0.13h, 0.16h), half3(0.04h, 0.04h, 0.05h));
    lighting = HoNprResolveScreenAoReceiver(lighting, lerp(1.0h, semanticMap.utility, 0.25h), 1.0h);
    lighting = HoNprResolveHoShadowReceiver(lighting, 1.0h);

    half ndotl = saturate(dot(HoNprSafeNormalize(surface.normalWS, half3(0.0h, 0.0h, 1.0h)), lighting.mainLightDirWS));
    half band = smoothstep(_HoNprToonDiffuseRampLilToonThreshold - _HoNprToonDiffuseRampLilToonSoftness, _HoNprToonDiffuseRampLilToonThreshold + _HoNprToonDiffuseRampLilToonSoftness, ndotl * HoNprCombinedShadow(lighting));
    HoNprStylizedSurfaceData stylized = HoNprCreateStylizedSurfaceData(_HoNprRampRow, 0.0h, 1.0h, regionMask.skin + regionMask.hair * 2.0h);
    half2 rampUv = HoNprComputeRampUv(band, stylized, _HoNprRampRows);
    half3 rampColor = HoNprSampleStyleRampAtlas(TEXTURE2D_ARGS(_HoNprStyleRampAtlas, sampler_HoNprStyleRampAtlas), rampUv);
    half frontFace = IS_FRONT_VFACE(facing, 1.0h, 0.0h);

    HoNprLobeOutput lobes = HoNprCreateLobeOutput();
    HoNprAccumulateLobe(lobes, HoNprEvaluateToonDiffuseRampLilToon(surface, lighting, stylized, rampColor));
#if defined(HONPR_HAS_TOON_SPECULAR_LILTOON)
    HoNprAccumulateLobeWithMode(lobes, HoNprEvaluateToonSpecularLilToon(surface, lighting, viewDirWS, _HoNprToonSpecularLilToonMask * semanticMap.specularMask, _HoNprToonSpecularLilToonThreshold, _HoNprToonSpecularLilToonSoftness), _HoNprToonSpecularLilToonBlendMode);
#endif
#if defined(HONPR_HAS_RIM_SHADE_LILTOON)
    HoNprAccumulateLobeWithMode(lobes, HoNprEvaluateRimShadeLilToon(surface, viewDirWS, _HoNprRimShadeLilToonColor.rgb, _HoNprRimLilToonMask * semanticMap.stylizedMask, _HoNprRimLilToonPower), _HoNprRimShadeLilToonBlendMode);
#endif
#if defined(HONPR_HAS_BACKLIGHT_LILTOON)
    HoNprAccumulateLobeWithMode(lobes, HoNprEvaluateBacklightLilToon(surface, lighting.mainLightDirWS, viewDirWS, _HoNprBacklightLilToonColor.rgb, semanticMap.stylizedMask, _HoNprBacklightLilToonPower), _HoNprBacklightLilToonBlendMode);
#endif
#if defined(HONPR_HAS_MATCAP_LILTOON)
    HoNprAccumulateLobeWithMode(lobes, HoNprEvaluateMatCapLilToon(surface, _HoNprMatCapLilToonColor.rgb, _HoNprMatCapLilToonMask * semanticMap.stylizedMask, band), _HoNprMatCapLilToonBlendMode);
#endif
#if defined(HONPR_HAS_BACKFACE_COLOR_LILTOON)
    HoNprAccumulateLobeWithMode(lobes, HoNprEvaluateBackfaceColorLilToon(frontFace, _HoNprBackfaceColorLilToonColor), _HoNprBackfaceColorLilToonBlendMode);
#endif
#if defined(HONPR_HAS_SECONDARY_MATCAP_LILTOON)
    HoNprAccumulateLobeWithMode(lobes, HoNprEvaluateSecondaryMatCapLilToon(surface, _HoNprSecondaryMatCapLilToonColor.rgb, _HoNprSecondaryMatCapLilToonMask * semanticMap.stylizedMask, band), _HoNprSecondaryMatCapLilToonBlendMode);
#endif
#if defined(HONPR_HAS_GLITTER_LILTOON)
    HoNprAccumulateLobeWithMode(lobes, HoNprEvaluateGlitterLilToon(surface, lighting.mainLightDirWS, viewDirWS, input.positionWS, _HoNprGlitterLilToonColor.rgb, _HoNprGlitterLilToonMask * semanticMap.stylizedMask, _HoNprGlitterLilToonDensity, _HoNprGlitterLilToonThreshold, _HoNprGlitterLilToonPower), _HoNprGlitterLilToonBlendMode);
#endif
#if defined(HONPR_HAS_RIM_LIGHT_LILTOON)
    HoNprAccumulateLobeWithMode(lobes, HoNprEvaluateRimLightLilToon(surface, viewDirWS, _HoNprRimLightLilToonColor.rgb, _HoNprRimLilToonMask * semanticMap.stylizedMask, _HoNprRimLilToonPower), _HoNprRimLightLilToonBlendMode);
#endif
#if defined(HONPR_HAS_EMISSION_PRIMARY_LILTOON)
    HoNprAccumulateLobeWithMode(lobes, HoNprEvaluateEmissionPrimaryLilToon(_HoNprEmissionPrimaryLilToonColor.rgb, _HoNprEmissionPrimaryLilToonIntensity, 1.0h), _HoNprEmissionPrimaryLilToonBlendMode);
#endif
#if defined(HONPR_HAS_EMISSION_SECONDARY_LILTOON)
    HoNprAccumulateLobeWithMode(lobes, HoNprEvaluateEmissionSecondaryLilToon(_HoNprEmissionSecondaryLilToonColor.rgb, _HoNprEmissionSecondaryLilToonIntensity, 1.0h), _HoNprEmissionSecondaryLilToonBlendMode);
#endif
#if defined(HONPR_HAS_DISTANCE_FADE_LILTOON)
    HoNprAccumulateLobeWithMode(lobes, HoNprEvaluateDistanceFadeLilToon(input.positionWS, _WorldSpaceCameraPos.xyz, _HoNprDistanceFadeLilToonColor.rgb, _HoNprDistanceFadeLilToonStart, _HoNprDistanceFadeLilToonEnd, _HoNprDistanceFadeLilToonStrength), _HoNprDistanceFadeLilToonBlendMode);
#endif
    HoNprCompositeOutput composite = HoNprCompositeFinalColor(surface, lobes);
    return half4(composite.color, composite.alpha);
}

HoNprCharacterAovOutput HoNprCharacterFragAov(HoNprCharacterVaryings input)
{
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
    HoUrpObjectSemanticData objectSemantic = HoUrpResolveObjectSemanticData();
    half3 normalWS = normalize(input.normalWS);
    float rawDepth = input.depthZW.x / max(input.depthZW.y, 1.0e-6);
    half linear01Depth = half(saturate(Linear01Depth(rawDepth, _ZBufferParams)));
    half materialSssProfile = 0.0h;
    half materialThickness = 0.0h;
    half materialCurvature = 0.0h;
    half3 sssSourceColor = half3(0.0h, 0.0h, 0.0h);
    half sssWeight = 0.0h;
#if defined(HONPR_HAS_SSS_SOURCE)
    materialSssProfile = half(_HoUrpGeneratedMaterialSssProfile);
    materialThickness = half(_HoUrpGeneratedMaterialThickness);
    materialCurvature = half(_HoUrpGeneratedMaterialCurvature);
    sssSourceColor = half3(_HoUrpGeneratedSssSourceColor.rgb);
    sssWeight = half(_HoUrpGeneratedSssWeight);
#endif
    HoUrpMaterialSemanticData semantic = HoUrpCreateMaterialSemanticData(
        half(_HoUrpGeneratedMaterialClass),
        materialSssProfile,
        materialThickness,
        materialCurvature,
        half4(_HoUrpGeneratedMaterialCustom0_3),
        sssSourceColor,
        sssWeight);
    HoUrpAovOutputData materialAov = HoUrpEncodeMaterialAov(semantic, objectSemantic.maskWeight);
    HoNprCharacterAovOutput output;
    output.maskId = HoUrpEncodeObjectMaskId(objectSemantic);
    output.normalDepth = half4(normalWS * 0.5h + 0.5h, linear01Depth);
    output.objectCustom0 = HoUrpEncodeObjectCustom0_3(objectSemantic);
    output.objectCustom1 = HoUrpEncodeObjectCustom4_7(objectSemantic);
    output.surfaceData = materialAov.surfaceData;
    output.materialCustom0 = materialAov.materialCustom0_3;
    output.sssSource = materialAov.sssSource;
    return output;
}

float4 HoNprCharacterDepthVert(HoNprCharacterAttributes input) : SV_POSITION
{
    UNITY_SETUP_INSTANCE_ID(input);
    return TransformObjectToHClip(input.positionOS.xyz);
}

half4 HoNprCharacterDepthFrag(float4 positionCS : SV_POSITION) : SV_Target
{
    return 0;
}

#if defined(HONPR_HAS_OIT_ACCUMULATION)
HoNprCharacterOitOutput HoNprCharacterFragOit(HoNprCharacterVaryings input)
{
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
    half4 baseSample = SAMPLE_TEXTURE2D(_HoNprBaseMap, sampler_HoNprBaseMap, input.uv) * _HoUrpBaseColor;
#if defined(HONPR_HAS_ALPHA_CLIP_POLICY)
    clip(baseSample.a - _HoNprAlphaClipThreshold);
#endif
    HoUrpSurfaceData surface = HoUrpCreateSurfaceData(baseSample.rgb, baseSample.a, input.normalWS);
    HoUrpTransparentOutputData transparentData = HoUrpCreateTransparentOutputData(surface, half(_HoUrpSupportsOit), half(_HoUrpParticipatesOit));
    transparentData.alpha *= transparentData.supportsOit * transparentData.participatesOit;
    HoUrpOitAccumulationData accumulation = HoUrpEncodeOitAccumulation(transparentData);
    HoNprCharacterOitOutput output;
    output.accumulation = half4(accumulation.weightedColor, accumulation.weightedAlpha);
    output.revealage = accumulation.revealage;
    return output;
}
#endif

#if defined(HONPR_HAS_OUTLINE_LILTOON)
struct HoNprCharacterOutlineVaryings
{
    float4 positionCS : SV_POSITION;
    float2 uv : TEXCOORD0;
    half3 normalWS : TEXCOORD1;
    UNITY_VERTEX_OUTPUT_STEREO
};

HoNprCharacterOutlineVaryings HoNprCharacterVertOutline(HoNprCharacterAttributes input)
{
    HoNprCharacterOutlineVaryings output;
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);
    float2 uv = input.uv * _HoNprOutlineWidthMask_ST.xy + _HoNprOutlineWidthMask_ST.zw;
    float2 vectorUv = input.uv * _HoNprOutlineVectorMap_ST.xy + _HoNprOutlineVectorMap_ST.zw;
    half widthMask = SAMPLE_TEXTURE2D_LOD(_HoNprOutlineWidthMask, sampler_HoNprOutlineWidthMask, uv, 0).r;
    half4 vectorSample = SAMPLE_TEXTURE2D_LOD(_HoNprOutlineVectorMap, sampler_HoNprOutlineVectorMap, vectorUv, 0);
    HoNprOutlineLilToonSettings outlineSettings;
    outlineSettings.width = _HoNprOutlineWidth;
    outlineSettings.widthMask = widthMask;
    outlineSettings.vertexWidthMode = _HoNprOutlineVertexWidthMode;
    outlineSettings.fixWidth = _HoNprOutlineFixWidth;
    outlineSettings.zBias = _HoNprOutlineZBias;
    outlineSettings.vectorScale = _HoNprOutlineVectorScale;
    output.positionCS = HoNprTransformOutlineLilToonToHClip(input.positionOS.xyz, input.normalOS, input.tangentOS, input.color, vectorSample, outlineSettings);
    output.uv = input.uv * _HoNprOutlineTex_ST.xy + _HoNprOutlineTex_ST.zw;
    output.normalWS = TransformObjectToWorldNormal(input.normalOS);
    return output;
}

half4 HoNprCharacterFragOutline(HoNprCharacterOutlineVaryings input) : SV_Target
{
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
    clip(_HoNprOutlineWidth - 0.0001);
    half4 outlineTex = SAMPLE_TEXTURE2D(_HoNprOutlineTex, sampler_HoNprOutlineTex, input.uv);
    Light mainLight = GetMainLight();
    half normalLenSq = dot(input.normalWS, input.normalWS);
    half3 normalWS = normalLenSq > 1.0e-4h ? input.normalWS * rsqrt(normalLenSq) : half3(0.0h, 0.0h, 1.0h);
    half3 outlineRgb = outlineTex.rgb * _HoNprOutlineColor.rgb;
    outlineRgb = HoNprApplyOutlineLilToonLighting(outlineRgb, outlineTex, _HoNprOutlineLitColor, _HoNprOutlineLitApplyTex, _HoNprOutlineLitScale, _HoNprOutlineLitOffset, _HoNprOutlineEnableLighting, normalWS, mainLight.direction, mainLight.color);
    return half4(outlineRgb, outlineTex.a * _HoNprOutlineColor.a);
}
#endif
    ENDHLSL

    SubShader
    {


        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Opaque" "Queue" = "Geometry" }



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

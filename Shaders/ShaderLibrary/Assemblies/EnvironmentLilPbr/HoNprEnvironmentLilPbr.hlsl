#ifndef HONPR_ENVIRONMENT_LILPBR_INCLUDED
#define HONPR_ENVIRONMENT_LILPBR_INCLUDED

#define HONPR_HAS_BASE_COLOR_TEXTURE 1
#define HONPR_HAS_FINAL_COLOR_COMPOSITE 1
#define HONPR_HAS_HORP_SHADOW_RECEIVER 1
#define HONPR_HAS_INDIRECT_LIGHT 1
#define HONPR_HAS_LILPBR_CLEAR_COAT_SPECULAR 1
#define HONPR_HAS_LILPBR_DIFFUSE 1
#define HONPR_HAS_LILPBR_MATERIAL_MAP_PACKED 1
#define HONPR_HAS_LILPBR_SPECULAR_ANISOTROPIC 1
#define HONPR_HAS_LILPBR_SPECULAR_GGX 1
#define HONPR_HAS_MATERIAL_SEMANTICS 1
#define HONPR_HAS_NORMAL_MAP 1
#define HONPR_HAS_SCREEN_AO_RECEIVER 1
#define HONPR_HAS_STANDARD_AOV 1
#define HONPR_HAS_URP_ADDITIONAL_LIGHTS 1
#define HONPR_HAS_URP_MAIN_LIGHT 1

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.hollow.hourp-extensions/Runtime/Shaders/ShaderLibrary/HoUrpObjectSemantic.hlsl"
#include "Packages/com.hollow.hourp-extensions/Runtime/Shaders/ShaderLibrary/HoUrpMaterialSurface.hlsl"
#include "Packages/com.hollow.hourp-extensions/Runtime/Shaders/ShaderLibrary/HoUrpMaterialAov.hlsl"
#include "Packages/com.hollow.honpr/Shaders/ShaderLibrary/HoNprCommon.hlsl"
#include "Packages/com.hollow.honpr/Shaders/ShaderLibrary/StandardSurface/HoNprStandardSurface.hlsl"
#include "Packages/com.hollow.honpr/Shaders/ShaderLibrary/StandardSurface/HoNprLilPbrLobes.hlsl"
#include "Packages/com.hollow.honpr/Shaders/ShaderLibrary/Lighting/HoNprHoUrpShadowReceiver.hlsl"
#include "Packages/com.hollow.honpr/Shaders/ShaderLibrary/Composite/HoNprComposite.hlsl"

TEXTURE2D(_HoNprBaseMap);
SAMPLER(sampler_HoNprBaseMap);
TEXTURE2D(_HoNprNormalMap);
SAMPLER(sampler_HoNprNormalMap);
TEXTURE2D(_HoNprMaterialMap);
SAMPLER(sampler_HoNprMaterialMap);

float4 _HoNprBaseMap_ST;
half4 _HoUrpBaseColor;
half _HoNprMaterialMetallicScale;
half _HoNprMaterialRoughnessScale;
half _HoNprMaterialOcclusionStrength;
half _HoNprAnisotropy;
half _HoNprAnisotropyMask;
half _HoNprClearCoatMask;
half _HoNprClearCoatRoughness;
float _HoUrpGeneratedMaterialClass;
float _HoUrpGeneratedMaterialSssProfile;
float _HoUrpGeneratedMaterialThickness;
float _HoUrpGeneratedMaterialCurvature;
float4 _HoUrpGeneratedMaterialCustom0_3;

struct HoNprEnvironmentAttributes
{
    float4 positionOS : POSITION;
    float3 normalOS : NORMAL;
    float4 tangentOS : TANGENT;
    float2 uv : TEXCOORD0;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct HoNprEnvironmentVaryings
{
    float4 positionCS : SV_POSITION;
    float3 positionWS : TEXCOORD0;
    half3 normalWS : TEXCOORD1;
    half3 tangentWS : TEXCOORD2;
    half3 bitangentWS : TEXCOORD3;
    float2 uv : TEXCOORD4;
    float2 depthZW : TEXCOORD5;
    UNITY_VERTEX_OUTPUT_STEREO
};

struct HoNprEnvironmentAovOutput
{
    half4 maskId : SV_Target0;
    half4 normalDepth : SV_Target1;
    half4 objectCustom0 : SV_Target2;
    half4 objectCustom1 : SV_Target3;
    half4 surfaceData : SV_Target4;
    half4 materialCustom0 : SV_Target5;
    half4 diffuse : SV_Target6;
};

HoNprEnvironmentVaryings HoNprEnvironmentVert(HoNprEnvironmentAttributes input)
{
    HoNprEnvironmentVaryings output;
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

    VertexPositionInputs positionInputs = GetVertexPositionInputs(input.positionOS.xyz);
    VertexNormalInputs normalInputs = GetVertexNormalInputs(input.normalOS, input.tangentOS);
    output.positionCS = positionInputs.positionCS;
    output.positionWS = positionInputs.positionWS;
    output.normalWS = NormalizeNormalPerVertex(normalInputs.normalWS);
    output.tangentWS = NormalizeNormalPerVertex(normalInputs.tangentWS);
    output.bitangentWS = NormalizeNormalPerVertex(normalInputs.bitangentWS);
    output.uv = input.uv * _HoNprBaseMap_ST.xy + _HoNprBaseMap_ST.zw;
    output.depthZW = positionInputs.positionCS.zw;
    return output;
}

HoUrpSurfaceData HoNprEnvironmentResolveSurface(HoNprEnvironmentVaryings input)
{
    half4 baseSample = SAMPLE_TEXTURE2D(_HoNprBaseMap, sampler_HoNprBaseMap, input.uv);
    half4 materialSample = SAMPLE_TEXTURE2D(_HoNprMaterialMap, sampler_HoNprMaterialMap, input.uv);

    HoUrpSurfaceData surface = HoUrpCreateSurfaceData(_HoUrpBaseColor.rgb, _HoUrpBaseColor.a, input.normalWS);
    surface = HoNprApplyBaseColorTexture(surface, baseSample, _HoUrpBaseColor);
#if defined(HONPR_HAS_NORMAL_MAP)
    half4 normalSample = SAMPLE_TEXTURE2D(_HoNprNormalMap, sampler_HoNprNormalMap, input.uv);
    half3 normalTS = HoNprSafeNormalize(normalSample.xyz * 2.0h - 1.0h, half3(0.0h, 0.0h, 1.0h));
    half3 normalWS = normalTS.x * input.tangentWS + normalTS.y * input.bitangentWS + normalTS.z * input.normalWS;
    surface = HoNprApplyNormalWS(surface, normalWS);
#endif
    surface = HoNprApplyLilPbrMaterialMapPacked(
        surface,
        materialSample,
        _HoNprMaterialMetallicScale,
        _HoNprMaterialRoughnessScale,
        _HoNprMaterialOcclusionStrength);
    return surface;
}

HoNprLightingContext HoNprEnvironmentResolveLighting(HoNprEnvironmentVaryings input, HoUrpSurfaceData surface)
{
    Light mainLight = GetMainLight();
    HoNprLightingContext lighting = HoNprCreateLightingContext(mainLight.direction, mainLight.color);
    lighting = HoNprResolveUrpMainLight(lighting, mainLight.direction, mainLight.color, mainLight.distanceAttenuation, mainLight.shadowAttenuation);
    lighting = HoNprResolveIndirectLight(lighting, SampleSH(surface.normalWS), half3(0.04h, 0.04h, 0.04h));
    lighting = HoNprResolveScreenAoReceiver(lighting, 1.0h, 1.0h);
    half hoShadow = HoNprSampleHoUrpShadowReceiver(input.positionWS, surface.normalWS);
    lighting = HoNprResolveHoShadowReceiver(lighting, hoShadow);
    return lighting;
}

half4 HoNprEnvironmentFragForward(HoNprEnvironmentVaryings input) : SV_Target
{
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

    HoUrpSurfaceData surface = HoNprEnvironmentResolveSurface(input);
    half3 viewDirWS = HoNprSafeNormalize(GetWorldSpaceViewDir(input.positionWS), surface.normalWS);
    HoNprLightingContext lighting = HoNprEnvironmentResolveLighting(input, surface);

    HoNprLobeOutput lobes = HoNprCreateLobeOutput();
#if defined(HONPR_HAS_LILPBR_DIFFUSE)
    HoNprAccumulateLobe(lobes, HoNprEvaluateLilPbrDiffuse(surface, lighting));
#endif
#if defined(HONPR_HAS_LILPBR_SPECULAR_GGX)
    HoNprAccumulateLobe(lobes, HoNprEvaluateLilPbrSpecularGGX(surface, lighting, viewDirWS));
#endif
#if defined(HONPR_HAS_LILPBR_SPECULAR_ANISOTROPIC)
    HoNprAccumulateLobe(lobes, HoNprEvaluateLilPbrSpecularAnisotropic(surface, lighting, viewDirWS, input.tangentWS, _HoNprAnisotropy, _HoNprAnisotropyMask));
#endif
#if defined(HONPR_HAS_LILPBR_CLEAR_COAT_SPECULAR)
    HoNprAccumulateLobe(lobes, HoNprEvaluateLilPbrClearCoatSpecular(surface, lighting, viewDirWS, _HoNprClearCoatMask, _HoNprClearCoatRoughness));
#endif

    HoNprCompositeOutput composite = HoNprCompositeFinalColor(surface, lobes);
    return half4(composite.color, composite.alpha);
}

HoNprEnvironmentAovOutput HoNprEnvironmentFragAov(HoNprEnvironmentVaryings input)
{
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

    HoUrpObjectSemanticData objectSemantic = HoUrpResolveObjectSemanticData();
    HoUrpSurfaceData surface = HoNprEnvironmentResolveSurface(input);
    half3 normalWS = HoNprSafeNormalize(surface.normalWS, half3(0.0h, 0.0h, 1.0h));
    float rawDepth = input.depthZW.x / max(input.depthZW.y, 1.0e-6);
    half linear01Depth = half(saturate(Linear01Depth(rawDepth, _ZBufferParams)));

    HoUrpMaterialSemanticData semantic = HoUrpCreateMaterialSemanticData(
        half(_HoUrpGeneratedMaterialClass),
        half(_HoUrpGeneratedMaterialSssProfile),
        half(_HoUrpGeneratedMaterialThickness),
        half(_HoUrpGeneratedMaterialCurvature),
        half4(_HoUrpGeneratedMaterialCustom0_3),
        half3(0.0h, 0.0h, 0.0h));
    HoUrpAovOutputData materialAov = HoUrpEncodeMaterialAov(semantic, objectSemantic.maskWeight);

    HoNprEnvironmentAovOutput output;
    output.maskId = HoUrpEncodeObjectMaskId(objectSemantic);
    output.normalDepth = half4(normalWS * 0.5h + 0.5h, linear01Depth);
    output.objectCustom0 = HoUrpEncodeObjectCustom0_3(objectSemantic);
    output.objectCustom1 = HoUrpEncodeObjectCustom4_7(objectSemantic);
    output.surfaceData = materialAov.surfaceData;
    output.materialCustom0 = materialAov.materialCustom0_3;
    output.diffuse = materialAov.diffuse;
    return output;
}

float4 HoNprEnvironmentDepthVert(HoNprEnvironmentAttributes input) : SV_POSITION
{
    UNITY_SETUP_INSTANCE_ID(input);
    return TransformObjectToHClip(input.positionOS.xyz);
}

half4 HoNprEnvironmentDepthFrag(float4 positionCS : SV_POSITION) : SV_Target
{
    return 0;
}

#endif

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
#include "Packages/com.hollow.honpr/Shaders/ShaderLibrary/StandardSurface/HoNprSubsurface.hlsl"
#include "Packages/com.hollow.honpr/Shaders/ShaderLibrary/StylizedSurface/HoNprOutline.hlsl"
#include "Packages/com.hollow.honpr/Shaders/ShaderLibrary/Composite/HoNprComposite.hlsl"

TEXTURE2D(_HoNprBaseMap);
SAMPLER(sampler_HoNprBaseMap);
#if defined(HONPR_HAS_NORMAL_MAP)
TEXTURE2D(_HoNprNormalMap);
SAMPLER(sampler_HoNprNormalMap);
#endif
TEXTURE2D(_HoNprStyleRampAtlas);
SAMPLER(sampler_HoNprStyleRampAtlas);
#if defined(HONPR_HAS_SEMANTIC_MAP)
TEXTURE2D(_HoNprSemanticMap);
SAMPLER(sampler_HoNprSemanticMap);
#endif
TEXTURE2D(_HoNprRegionMap);
SAMPLER(sampler_HoNprRegionMap);
#if defined(HONPR_HAS_LILTOON_OUTLINE)
TEXTURE2D(_HoNprOutlineTex);
SAMPLER(sampler_HoNprOutlineTex);
TEXTURE2D(_HoNprOutlineWidthMask);
SAMPLER(sampler_HoNprOutlineWidthMask);
TEXTURE2D(_HoNprOutlineVectorMap);
SAMPLER(sampler_HoNprOutlineVectorMap);
#endif

float4 _HoNprBaseMap_ST;
#if defined(HONPR_HAS_LILTOON_OUTLINE)
float4 _HoNprOutlineTex_ST;
float4 _HoNprOutlineWidthMask_ST;
float4 _HoNprOutlineVectorMap_ST;
#endif

half4 _HoUrpBaseColor;
half _HoNprLilToonDiffuseRampThreshold;
half _HoNprLilToonDiffuseRampSoftness;
half _HoNprRampRow;
half _HoNprRampRows;
#if defined(HONPR_HAS_LILTOON_SPECULAR)
half _HoNprLilToonSpecularThreshold;
half _HoNprLilToonSpecularSoftness;
half _HoNprLilToonSpecularMask;
half _HoNprLilToonSpecularBlendMode;
#endif
#if defined(HONPR_HAS_HAIR_SPECULAR_PRIMARY)
half _HoNprHairSpecularPrimaryShift;
half _HoNprHairSpecularPrimaryWidth;
half _HoNprHairSpecularPrimaryMask;
half _HoNprHairSpecularPrimaryBlendMode;
#endif
#if defined(HONPR_HAS_HAIR_SPECULAR_SECONDARY)
half _HoNprHairSpecularSecondaryShift;
half _HoNprHairSpecularSecondaryWidth;
half _HoNprHairSpecularSecondaryMask;
half _HoNprHairSpecularSecondaryBlendMode;
#endif
#if defined(HONPR_HAS_LILTOON_RIM_LIGHT)
half4 _HoNprLilToonRimLightColor;
half _HoNprLilToonRimLightBlendMode;
#endif
#if defined(HONPR_HAS_LILTOON_RIM_LIGHT) || defined(HONPR_HAS_LILTOON_RIM_SHADE)
half _HoNprLilToonRimPower;
half _HoNprLilToonRimMask;
#endif
#if defined(HONPR_HAS_LILTOON_RIM_SHADE)
half4 _HoNprLilToonRimShadeColor;
half _HoNprLilToonRimShadeBlendMode;
#endif
#if defined(HONPR_HAS_LILTOON_BACKLIGHT)
half4 _HoNprLilToonBacklightColor;
half _HoNprLilToonBacklightPower;
half _HoNprLilToonBacklightBlendMode;
#endif
#if defined(HONPR_HAS_LILTOON_BACKFACE_COLOR)
half4 _HoNprLilToonBackfaceColor;
half _HoNprLilToonBackfaceColorBlendMode;
#endif
#if defined(HONPR_HAS_LILTOON_MATCAP)
half4 _HoNprLilToonMatCapColor;
half _HoNprLilToonMatCapMask;
half _HoNprLilToonMatCapBlendMode;
#endif
#if defined(HONPR_HAS_LILTOON_SECONDARY_MATCAP)
half4 _HoNprLilToonSecondaryMatCapColor;
half _HoNprLilToonSecondaryMatCapMask;
half _HoNprLilToonSecondaryMatCapBlendMode;
#endif
#if defined(HONPR_HAS_LILTOON_GLITTER)
half4 _HoNprLilToonGlitterColor;
half _HoNprLilToonGlitterMask;
half _HoNprLilToonGlitterDensity;
half _HoNprLilToonGlitterThreshold;
half _HoNprLilToonGlitterPower;
half _HoNprLilToonGlitterBlendMode;
#endif
#if defined(HONPR_HAS_LILTOON_EMISSION_PRIMARY)
half4 _HoNprLilToonEmissionPrimaryColor;
half _HoNprLilToonEmissionPrimaryIntensity;
half _HoNprLilToonEmissionPrimaryBlendMode;
#endif
#if defined(HONPR_HAS_LILTOON_EMISSION_SECONDARY)
half4 _HoNprLilToonEmissionSecondaryColor;
half _HoNprLilToonEmissionSecondaryIntensity;
half _HoNprLilToonEmissionSecondaryBlendMode;
#endif
#if defined(HONPR_HAS_LILTOON_DISTANCE_FADE)
half4 _HoNprLilToonDistanceFadeColor;
half _HoNprLilToonDistanceFadeStart;
half _HoNprLilToonDistanceFadeEnd;
half _HoNprLilToonDistanceFadeStrength;
half _HoNprLilToonDistanceFadeBlendMode;
#endif
#if defined(HONPR_HAS_ALPHA_CLIP_POLICY)
half _HoNprAlphaClipThreshold;
#endif

#if defined(HONPR_HAS_LILTOON_OUTLINE)
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
    half3 tangentWS : TEXCOORD2;
    half3 bitangentWS : TEXCOORD3;
    float2 uv : TEXCOORD4;
    float2 depthZW : TEXCOORD5;
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
    half4 diffuse : SV_Target6;
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

HoNprSemanticMapData HoNprCharacterResolveSemanticMap(float2 uv)
{
#if defined(HONPR_HAS_SEMANTIC_MAP)
    return HoNprApplySemanticMap(SAMPLE_TEXTURE2D(_HoNprSemanticMap, sampler_HoNprSemanticMap, uv));
#else
    return HoNprCreateSemanticMapData(half4(0.0h, 1.0h, 1.0h, 1.0h));
#endif
}

HoUrpSurfaceData HoNprCharacterResolveSurface(HoNprCharacterVaryings input)
{
    half4 baseSample = SAMPLE_TEXTURE2D(_HoNprBaseMap, sampler_HoNprBaseMap, input.uv);
    HoUrpSurfaceData surface = HoUrpCreateSurfaceData(_HoUrpBaseColor.rgb, _HoUrpBaseColor.a, input.normalWS);
    surface = HoNprApplyBaseColorTexture(surface, baseSample, _HoUrpBaseColor);
#if defined(HONPR_HAS_NORMAL_MAP)
    half4 normalSample = SAMPLE_TEXTURE2D(_HoNprNormalMap, sampler_HoNprNormalMap, input.uv);
    half3 normalTS = HoNprSafeNormalize(normalSample.xyz * 2.0h - 1.0h, half3(0.0h, 0.0h, 1.0h));
    half3 normalWS = normalTS.x * input.tangentWS + normalTS.y * input.bitangentWS + normalTS.z * input.normalWS;
    surface = HoNprApplyNormalWS(surface, normalWS);
#endif
    return surface;
}

half4 HoNprCharacterFragForward(HoNprCharacterVaryings input, FRONT_FACE_TYPE facing : FRONT_FACE_SEMANTIC) : SV_Target
{
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
    half4 regionSample = SAMPLE_TEXTURE2D(_HoNprRegionMap, sampler_HoNprRegionMap, input.uv);
    HoNprSemanticMapData semanticMap = HoNprCharacterResolveSemanticMap(input.uv);
    HoNprRegionMaskData regionMask = HoNprApplyRegionMask(regionSample);

    HoUrpSurfaceData surface = HoNprCharacterResolveSurface(input);
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
    half band = smoothstep(_HoNprLilToonDiffuseRampThreshold - _HoNprLilToonDiffuseRampSoftness, _HoNprLilToonDiffuseRampThreshold + _HoNprLilToonDiffuseRampSoftness, ndotl * HoNprCombinedShadow(lighting));
    HoNprStylizedSurfaceData stylized = HoNprCreateStylizedSurfaceData(_HoNprRampRow, 0.0h, 1.0h, regionMask.skin + regionMask.hair * 2.0h);
    half2 rampUv = HoNprComputeRampUv(band, stylized, _HoNprRampRows);
    half3 rampColor = HoNprSampleStyleRampAtlas(TEXTURE2D_ARGS(_HoNprStyleRampAtlas, sampler_HoNprStyleRampAtlas), rampUv);
    half frontFace = IS_FRONT_VFACE(facing, 1.0h, 0.0h);

    HoNprLobeOutput lobes = HoNprCreateLobeOutput();
    HoNprAccumulateLobe(lobes, HoNprEvaluateLilToonDiffuseRamp(surface, lighting, stylized, rampColor));
#if defined(HONPR_HAS_LILTOON_SPECULAR)
    HoNprAccumulateLobeWithMode(lobes, HoNprEvaluateLilToonSpecular(surface, lighting, viewDirWS, _HoNprLilToonSpecularMask * semanticMap.specularMask, _HoNprLilToonSpecularThreshold, _HoNprLilToonSpecularSoftness), _HoNprLilToonSpecularBlendMode);
#endif
#if defined(HONPR_HAS_HAIR_SPECULAR_PRIMARY)
    HoNprAccumulateLobeWithMode(lobes, HoNprEvaluateHairSpecularPrimary(surface, lighting, viewDirWS, input.tangentWS, _HoNprHairSpecularPrimaryShift, _HoNprHairSpecularPrimaryWidth, _HoNprHairSpecularPrimaryMask * regionMask.hair), _HoNprHairSpecularPrimaryBlendMode);
#endif
#if defined(HONPR_HAS_HAIR_SPECULAR_SECONDARY)
    HoNprAccumulateLobeWithMode(lobes, HoNprEvaluateHairSpecularSecondary(surface, lighting, viewDirWS, input.tangentWS, _HoNprHairSpecularSecondaryShift, _HoNprHairSpecularSecondaryWidth, _HoNprHairSpecularSecondaryMask * regionMask.hair), _HoNprHairSpecularSecondaryBlendMode);
#endif
#if defined(HONPR_HAS_FORWARD_THIN_SSS)
    HoNprAccumulateLobe(lobes, HoNprEvaluateForwardThinSss(surface, lighting, viewDirWS, _HoUrpGeneratedMaterialThickness, _HoUrpGeneratedSssWeight * semanticMap.sssWeight, _HoUrpGeneratedSssSourceColor.rgb));
#endif
#if defined(HONPR_HAS_LILTOON_RIM_SHADE)
    HoNprAccumulateLobeWithMode(lobes, HoNprEvaluateLilToonRimShade(surface, viewDirWS, _HoNprLilToonRimShadeColor.rgb, _HoNprLilToonRimMask * semanticMap.stylizedMask, _HoNprLilToonRimPower), _HoNprLilToonRimShadeBlendMode);
#endif
#if defined(HONPR_HAS_LILTOON_BACKLIGHT)
    HoNprAccumulateLobeWithMode(lobes, HoNprEvaluateLilToonBacklight(surface, lighting.mainLightDirWS, viewDirWS, _HoNprLilToonBacklightColor.rgb, semanticMap.stylizedMask, _HoNprLilToonBacklightPower), _HoNprLilToonBacklightBlendMode);
#endif
#if defined(HONPR_HAS_LILTOON_MATCAP)
    HoNprAccumulateLobeWithMode(lobes, HoNprEvaluateLilToonMatCap(surface, _HoNprLilToonMatCapColor.rgb, _HoNprLilToonMatCapMask * semanticMap.stylizedMask, band), _HoNprLilToonMatCapBlendMode);
#endif
#if defined(HONPR_HAS_LILTOON_BACKFACE_COLOR)
    HoNprAccumulateLobeWithMode(lobes, HoNprEvaluateLilToonBackfaceColor(frontFace, _HoNprLilToonBackfaceColor), _HoNprLilToonBackfaceColorBlendMode);
#endif
#if defined(HONPR_HAS_LILTOON_SECONDARY_MATCAP)
    HoNprAccumulateLobeWithMode(lobes, HoNprEvaluateLilToonSecondaryMatCap(surface, _HoNprLilToonSecondaryMatCapColor.rgb, _HoNprLilToonSecondaryMatCapMask * semanticMap.stylizedMask, band), _HoNprLilToonSecondaryMatCapBlendMode);
#endif
#if defined(HONPR_HAS_LILTOON_GLITTER)
    HoNprAccumulateLobeWithMode(lobes, HoNprEvaluateLilToonGlitter(surface, lighting.mainLightDirWS, viewDirWS, input.positionWS, _HoNprLilToonGlitterColor.rgb, _HoNprLilToonGlitterMask * semanticMap.stylizedMask, _HoNprLilToonGlitterDensity, _HoNprLilToonGlitterThreshold, _HoNprLilToonGlitterPower), _HoNprLilToonGlitterBlendMode);
#endif
#if defined(HONPR_HAS_LILTOON_RIM_LIGHT)
    HoNprAccumulateLobeWithMode(lobes, HoNprEvaluateLilToonRimLight(surface, viewDirWS, _HoNprLilToonRimLightColor.rgb, _HoNprLilToonRimMask * semanticMap.stylizedMask, _HoNprLilToonRimPower), _HoNprLilToonRimLightBlendMode);
#endif
#if defined(HONPR_HAS_LILTOON_EMISSION_PRIMARY)
    HoNprAccumulateLobeWithMode(lobes, HoNprEvaluateLilToonEmissionPrimary(_HoNprLilToonEmissionPrimaryColor.rgb, _HoNprLilToonEmissionPrimaryIntensity, 1.0h), _HoNprLilToonEmissionPrimaryBlendMode);
#endif
#if defined(HONPR_HAS_LILTOON_EMISSION_SECONDARY)
    HoNprAccumulateLobeWithMode(lobes, HoNprEvaluateLilToonEmissionSecondary(_HoNprLilToonEmissionSecondaryColor.rgb, _HoNprLilToonEmissionSecondaryIntensity, 1.0h), _HoNprLilToonEmissionSecondaryBlendMode);
#endif
#if defined(HONPR_HAS_LILTOON_DISTANCE_FADE)
    HoNprAccumulateLobeWithMode(lobes, HoNprEvaluateLilToonDistanceFade(input.positionWS, _WorldSpaceCameraPos.xyz, _HoNprLilToonDistanceFadeColor.rgb, _HoNprLilToonDistanceFadeStart, _HoNprLilToonDistanceFadeEnd, _HoNprLilToonDistanceFadeStrength), _HoNprLilToonDistanceFadeBlendMode);
#endif
    HoNprCompositeOutput composite = HoNprCompositeFinalColor(surface, lobes);
    return half4(composite.color, composite.alpha);
}

HoNprCharacterAovOutput HoNprCharacterFragAov(HoNprCharacterVaryings input)
{
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
    HoUrpObjectSemanticData objectSemantic = HoUrpResolveObjectSemanticData();
    HoUrpSurfaceData surface = HoNprCharacterResolveSurface(input);
    half3 normalWS = normalize(surface.normalWS);
    float rawDepth = input.depthZW.x / max(input.depthZW.y, 1.0e-6);
    half linear01Depth = half(saturate(Linear01Depth(rawDepth, _ZBufferParams)));
    half materialSssProfile = 0.0h;
    half materialThickness = 0.0h;
    half materialCurvature = 0.0h;
    half3 sssSourceColor = half3(0.0h, 0.0h, 0.0h);
    half sssWeight = 0.0h;
#if defined(HONPR_HAS_SSS_SOURCE)
    HoNprSemanticMapData semanticMap = HoNprCharacterResolveSemanticMap(input.uv);
    materialSssProfile = half(_HoUrpGeneratedMaterialSssProfile);
    materialThickness = half(_HoUrpGeneratedMaterialThickness);
    materialCurvature = half(_HoUrpGeneratedMaterialCurvature);
    sssSourceColor = half3(_HoUrpGeneratedSssSourceColor.rgb);
    sssWeight = half(_HoUrpGeneratedSssWeight) * semanticMap.sssWeight;
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
    output.diffuse = materialAov.diffuse;
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
    HoUrpSurfaceData surface = HoNprCharacterResolveSurface(input);
#if defined(HONPR_HAS_ALPHA_CLIP_POLICY)
    clip(surface.alpha - _HoNprAlphaClipThreshold);
#endif
    HoUrpTransparentOutputData transparentData = HoUrpCreateTransparentOutputData(surface, half(_HoUrpSupportsOit), half(_HoUrpParticipatesOit));
    transparentData.alpha *= transparentData.supportsOit * transparentData.participatesOit;
    HoUrpOitAccumulationData accumulation = HoUrpEncodeOitAccumulation(transparentData);
    HoNprCharacterOitOutput output;
    output.accumulation = half4(accumulation.weightedColor, accumulation.weightedAlpha);
    output.revealage = accumulation.revealage;
    return output;
}
#endif

#if defined(HONPR_HAS_LILTOON_OUTLINE)
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
    HoNprLilToonOutlineSettings outlineSettings;
    outlineSettings.width = _HoNprOutlineWidth;
    outlineSettings.widthMask = widthMask;
    outlineSettings.vertexWidthMode = _HoNprOutlineVertexWidthMode;
    outlineSettings.fixWidth = _HoNprOutlineFixWidth;
    outlineSettings.zBias = _HoNprOutlineZBias;
    outlineSettings.vectorScale = _HoNprOutlineVectorScale;
    output.positionCS = HoNprTransformLilToonOutlineToHClip(input.positionOS.xyz, input.normalOS, input.tangentOS, input.color, vectorSample, outlineSettings);
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
    outlineRgb = HoNprApplyLilToonOutlineLighting(outlineRgb, outlineTex, _HoNprOutlineLitColor, _HoNprOutlineLitApplyTex, _HoNprOutlineLitScale, _HoNprOutlineLitOffset, _HoNprOutlineEnableLighting, normalWS, mainLight.direction, mainLight.color);
    return half4(outlineRgb, outlineTex.a * _HoNprOutlineColor.a);
}
#endif

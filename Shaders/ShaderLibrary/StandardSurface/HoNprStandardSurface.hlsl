#ifndef HONPR_STANDARD_SURFACE_INCLUDED
#define HONPR_STANDARD_SURFACE_INCLUDED

#include "../HoNprCommon.hlsl"

HoUrpSurfaceData HoNprApplyBaseColorTexture(HoUrpSurfaceData surface, half4 baseSample, half4 baseColorTint)
{
    surface.baseColor = max(0.0h, baseSample.rgb * baseColorTint.rgb);
    surface.alpha = saturate(baseSample.a * baseColorTint.a);
    return surface;
}

HoUrpSurfaceData HoNprApplyNormalWS(HoUrpSurfaceData surface, half3 normalWS)
{
    surface.normalWS = HoNprSafeNormalize(normalWS, half3(0.0h, 0.0h, 1.0h));
    return surface;
}

HoUrpSurfaceData HoNprApplyLilPbrMaterialMapPacked(HoUrpSurfaceData surface, half4 materialMapSample, half metallicScale, half roughnessScale, half occlusionStrength)
{
    surface.metallic = saturate(materialMapSample.r * metallicScale);
    surface.roughness = HoNprSafeRoughness(materialMapSample.g * roughnessScale);
    surface.occlusion = lerp(1.0h, saturate(materialMapSample.b), saturate(occlusionStrength));
    return surface;
}

HoNprSemanticMapData HoNprApplySemanticMap(half4 semanticMapSample)
{
    return HoNprCreateSemanticMapData(semanticMapSample);
}

HoNprRegionMaskData HoNprApplyRegionMask(half4 regionMapSample)
{
    return HoNprCreateRegionMaskData(regionMapSample);
}

#endif

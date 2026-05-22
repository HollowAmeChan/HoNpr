#ifndef HONPR_TRANSPARENCY_INCLUDED
#define HONPR_TRANSPARENCY_INCLUDED

#include "Packages/com.hollow.hourp-extensions/Runtime/Shaders/ShaderLibrary/HoUrpMaterialOit.hlsl"

HoUrpTransparentOutputData HoNprCreateTransparentData(HoUrpSurfaceData surface, half supportsOit, half participatesOit)
{
    return HoUrpCreateTransparentOutputData(surface, supportsOit, participatesOit);
}

HoUrpOitAccumulationData HoNprEncodeOitOutput(HoUrpTransparentOutputData transparentData)
{
    return HoUrpEncodeOitAccumulation(transparentData);
}

HoUrpSurfaceData HoNprApplyAlphaClipPolicy(HoUrpSurfaceData surface, half alphaClipThreshold)
{
    clip(surface.alpha - saturate(alphaClipThreshold));
    return surface;
}

HoUrpTransparentOutputData HoNprApplyTransparentComposite(
    HoUrpTransparentOutputData transparentData,
    half alphaMultiplier,
    half coverage)
{
    transparentData.alpha = saturate(transparentData.alpha * saturate(alphaMultiplier));
    transparentData.coverage = saturate(transparentData.coverage * saturate(coverage));
    return transparentData;
}

half HoNprShouldSkipForwardWhenOit(half supportsOit, half participatesOit, half oitPhaseActive)
{
    return saturate(supportsOit) * saturate(participatesOit) * saturate(oitPhaseActive);
}

#endif

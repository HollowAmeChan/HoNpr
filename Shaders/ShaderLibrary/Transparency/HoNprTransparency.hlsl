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

half HoNprShouldSkipForwardWhenOit(half supportsOit, half participatesOit, half oitPhaseActive)
{
    return saturate(supportsOit) * saturate(participatesOit) * saturate(oitPhaseActive);
}

#endif

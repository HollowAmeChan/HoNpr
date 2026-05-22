#ifndef HONPR_DEBUG_BLOCKS_INCLUDED
#define HONPR_DEBUG_BLOCKS_INCLUDED

#include "../HoNprCommon.hlsl"

half3 HoNprDebugNormalColor(half3 normalWS)
{
    return HoNprSafeNormalize(normalWS, half3(0.0h, 0.0h, 1.0h)) * 0.5h + 0.5h;
}

half3 HoNprDebugLobeEnergy(HoNprLobeOutput lobes)
{
    return saturate(abs(lobes.diffuse) + abs(lobes.specular) + abs(lobes.transmission) + abs(lobes.emission));
}

#endif

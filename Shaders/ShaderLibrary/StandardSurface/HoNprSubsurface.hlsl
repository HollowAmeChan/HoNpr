#ifndef HONPR_SUBSURFACE_INCLUDED
#define HONPR_SUBSURFACE_INCLUDED

#include "../Lighting/HoNprLightingInput.hlsl"

HoNprLobeOutput HoNprEvaluateForwardThinSss(HoUrpSurfaceData surface, HoNprLightingContext lighting, half3 viewDirWS, half thickness, half weight, half3 tint)
{
    HoNprLobeOutput output = HoNprCreateLobeOutput();
    half backlit = saturate(dot(-lighting.mainLightDirWS, HoNprSafeNormalize(viewDirWS, surface.normalWS)));
    half amount = saturate(thickness) * saturate(weight) * backlit * HoNprCombinedShadow(lighting);
    output.transmission = surface.baseColor * max(0.0h, tint) * amount;
    output.semanticWeight = saturate(weight);
    return output;
}

#endif

#ifndef HONPR_COMPOSITE_INCLUDED
#define HONPR_COMPOSITE_INCLUDED

#include "../HoNprCommon.hlsl"

HoNprCompositeOutput HoNprCompositeFinalColor(HoUrpSurfaceData surface, HoNprLobeOutput lobes)
{
    HoNprCompositeOutput output;
    half3 litColor = lobes.diffuse + lobes.specular + lobes.transmission;
    output.color = max(0.0h, litColor * saturate(lobes.energyWeight) + lobes.emission);
    output.alpha = saturate(surface.alpha * lobes.alpha);
    output.coverage = output.alpha;
    return output;
}

#endif

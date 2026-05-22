#ifndef HONPR_COMPOSITE_INCLUDED
#define HONPR_COMPOSITE_INCLUDED

#include "../HoNprCommon.hlsl"

HoNprCompositeOutput HoNprCompositeFinalColor(HoUrpSurfaceData surface, HoNprLobeOutput lobes)
{
    HoNprCompositeOutput output;
    output.color = max(0.0h, lobes.diffuse + lobes.specular + lobes.transmission + lobes.emission);
    output.alpha = saturate(surface.alpha * lobes.alpha);
    output.coverage = output.alpha;
    return output;
}

#endif

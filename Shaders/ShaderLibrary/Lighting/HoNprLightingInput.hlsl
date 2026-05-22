#ifndef HONPR_LIGHTING_INPUT_INCLUDED
#define HONPR_LIGHTING_INPUT_INCLUDED

#include "../HoNprCommon.hlsl"

struct HoNprLightingContext
{
    half3 mainLightDirWS;
    half3 mainLightColor;
    half mainLightDistanceAttenuation;
    half mainLightShadow;
    half3 indirectDiffuse;
    half3 indirectSpecular;
    half screenAoDirect;
    half screenAoIndirect;
    half hoShadow;
};

HoNprLightingContext HoNprCreateLightingContext(half3 lightDirWS, half3 lightColor)
{
    HoNprLightingContext context;
    context.mainLightDirWS = HoNprSafeNormalize(lightDirWS, half3(0.0h, 1.0h, 0.0h));
    context.mainLightColor = max(0.0h, lightColor);
    context.mainLightDistanceAttenuation = 1.0h;
    context.mainLightShadow = 1.0h;
    context.indirectDiffuse = half3(0.0h, 0.0h, 0.0h);
    context.indirectSpecular = half3(0.0h, 0.0h, 0.0h);
    context.screenAoDirect = 1.0h;
    context.screenAoIndirect = 1.0h;
    context.hoShadow = 1.0h;
    return context;
}

half HoNprCombinedShadow(HoNprLightingContext context)
{
    return saturate(context.mainLightDistanceAttenuation * context.mainLightShadow * context.hoShadow);
}

#endif

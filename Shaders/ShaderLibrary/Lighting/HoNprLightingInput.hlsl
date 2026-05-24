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

HoNprLightingContext HoNprResolveUrpMainLight(
    HoNprLightingContext context,
    half3 lightDirWS,
    half3 lightColor,
    half distanceAttenuation,
    half shadowAttenuation)
{
    context.mainLightDirWS = HoNprSafeNormalize(lightDirWS, context.mainLightDirWS);
    context.mainLightColor = max(0.0h, lightColor);
    context.mainLightDistanceAttenuation = saturate(distanceAttenuation);
    context.mainLightShadow = saturate(shadowAttenuation);
    return context;
}

HoNprLightingContext HoNprResolveAdditionalLight(
    HoNprLightingContext context,
    half3 lightColor,
    half distanceAttenuation,
    half shadowAttenuation)
{
    half visibility = saturate(distanceAttenuation) * saturate(shadowAttenuation);
    context.indirectDiffuse += max(0.0h, lightColor) * visibility;
    return context;
}

HoNprLightingContext HoNprResolveIndirectLight(
    HoNprLightingContext context,
    half3 indirectDiffuse,
    half3 indirectSpecular)
{
    context.indirectDiffuse = max(0.0h, indirectDiffuse);
    context.indirectSpecular = max(0.0h, indirectSpecular);
    return context;
}

HoNprLightingContext HoNprResolveScreenAoReceiver(
    HoNprLightingContext context,
    half directAo,
    half indirectAo)
{
    context.screenAoDirect = saturate(directAo);
    context.screenAoIndirect = saturate(indirectAo);
    return context;
}

HoNprLightingContext HoNprResolveHoShadowReceiver(HoNprLightingContext context, half hoShadow)
{
    context.hoShadow = saturate(hoShadow);
    return context;
}

half HoNprCombinedShadow(HoNprLightingContext context)
{
    return saturate(context.mainLightDistanceAttenuation * context.mainLightShadow * context.hoShadow * context.screenAoDirect);
}

half HoNprDirectVisibility(HoNprLightingContext context)
{
    return HoNprCombinedShadow(context);
}

half HoNprIndirectVisibility(HoNprLightingContext context, half surfaceOcclusion)
{
    return saturate(surfaceOcclusion * context.screenAoIndirect);
}

#endif

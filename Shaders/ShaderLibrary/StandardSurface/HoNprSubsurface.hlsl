#ifndef HONPR_SUBSURFACE_INCLUDED
#define HONPR_SUBSURFACE_INCLUDED

#include "../Lighting/HoNprLightingInput.hlsl"

HoNprLobeOutput HoNprEvaluateForwardThinSss(
    HoUrpSurfaceData surface,
    HoNprLightingContext lighting,
    half3 viewDirWS,
    half skinMask,
    half thickness,
    half weight,
    half3 tint)
{
    HoNprLobeOutput output = HoNprCreateLobeOutput();
    half3 normalWS = HoNprSafeNormalize(surface.normalWS, half3(0.0h, 0.0h, 1.0h));
    half3 viewWS = HoNprSafeNormalize(viewDirWS, normalWS);
    half3 lightWS = HoNprSafeNormalize(lighting.mainLightDirWS, normalWS);

    half ndotl = dot(normalWS, lightWS);
    half backSurface = saturate(-ndotl);
    half frontSuppression = 1.0h - saturate(ndotl);
    half viewRim = 1.0h - saturate(dot(normalWS, viewWS));
    viewRim *= viewRim;

    half forwardScatter = saturate(dot(-lightWS, viewWS));
    forwardScatter *= forwardScatter;

    half visibility = saturate(lighting.mainLightDistanceAttenuation * lighting.mainLightShadow * lighting.hoShadow);
    half ao = saturate(0.35h + 0.65h * lighting.screenAoDirect);
    half shape = saturate(backSurface * 0.65h + forwardScatter * 0.35h);
    shape *= lerp(0.35h, 1.0h, viewRim);
    shape *= frontSuppression;

    half amount = saturate(skinMask) * saturate(thickness) * saturate(weight) * shape * visibility * ao;
    half3 warmTint = max(tint, half3(0.0h, 0.0h, 0.0h));
    output.transmission = surface.baseColor * warmTint * amount * 0.65h;
    output.semanticWeight = amount;
    return output;
}

#endif

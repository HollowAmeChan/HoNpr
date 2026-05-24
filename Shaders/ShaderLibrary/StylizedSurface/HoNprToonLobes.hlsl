#ifndef HONPR_TOON_LOBES_INCLUDED
#define HONPR_TOON_LOBES_INCLUDED

#include "../Lighting/HoNprLightingInput.hlsl"
#include "HoNprStylizedSurface.hlsl"

HoNprLobeOutput HoNprEvaluateLilToonDiffuseRamp(HoUrpSurfaceData surface, HoNprLightingContext lighting, HoNprStylizedSurfaceData stylized, half3 rampColor)
{
    HoNprLobeOutput output = HoNprCreateLobeOutput();
    output.diffuse = surface.baseColor * max(0.0h, rampColor) * lighting.mainLightColor;
    output.diffuse += surface.baseColor * lighting.indirectDiffuse * HoNprIndirectVisibility(lighting, surface.occlusion);
    return output;
}

HoNprLobeOutput HoNprEvaluateLilToonSpecular(HoUrpSurfaceData surface, HoNprLightingContext lighting, half3 viewDirWS, half mask, half threshold, half softness)
{
    HoNprLobeOutput output = HoNprCreateLobeOutput();
    half3 normalWS = HoNprSafeNormalize(surface.normalWS, half3(0.0h, 0.0h, 1.0h));
    half3 viewWS = HoNprSafeNormalize(viewDirWS, normalWS);
    half3 halfDir = HoNprSafeNormalize(lighting.mainLightDirWS + viewWS, normalWS);
    half ndotl = saturate(dot(normalWS, lighting.mainLightDirWS));
    half specTerm = saturate(dot(normalWS, halfDir));
    half width = max(0.001h, abs(softness));
    half band = smoothstep(saturate(threshold - width), saturate(threshold + width), specTerm);
    output.specular = lighting.mainLightColor * band * ndotl * saturate(mask) * HoNprDirectVisibility(lighting);
    return output;
}

HoNprLobeOutput HoNprEvaluateHairSpecular(HoUrpSurfaceData surface, HoNprLightingContext lighting, half3 viewDirWS, half3 tangentWS, half shift, half width, half mask)
{
    HoNprLobeOutput output = HoNprCreateLobeOutput();
    half3 normalWS = HoNprSafeNormalize(surface.normalWS, half3(0.0h, 0.0h, 1.0h));
    half3 tangent = HoNprSafeNormalize(tangentWS - normalWS * dot(normalWS, tangentWS), half3(1.0h, 0.0h, 0.0h));
    half3 viewWS = HoNprSafeNormalize(viewDirWS, normalWS);
    half3 halfDir = HoNprSafeNormalize(lighting.mainLightDirWS + viewWS, normalWS);
    half ndotl = saturate(dot(normalWS, lighting.mainLightDirWS));
    half strand = saturate(1.0h - abs(dot(tangent, halfDir) + shift));
    half highlight = pow(strand, max(1.0h, width));
    output.specular = lighting.mainLightColor * highlight * ndotl * saturate(mask) * HoNprDirectVisibility(lighting);
    return output;
}

HoNprLobeOutput HoNprEvaluateHairSpecularPrimary(HoUrpSurfaceData surface, HoNprLightingContext lighting, half3 viewDirWS, half3 tangentWS, half shift, half width, half mask)
{
    return HoNprEvaluateHairSpecular(surface, lighting, viewDirWS, tangentWS, shift, width, mask);
}

HoNprLobeOutput HoNprEvaluateHairSpecularSecondary(HoUrpSurfaceData surface, HoNprLightingContext lighting, half3 viewDirWS, half3 tangentWS, half shift, half width, half mask)
{
    return HoNprEvaluateHairSpecular(surface, lighting, viewDirWS, tangentWS, shift, width, mask);
}

#endif

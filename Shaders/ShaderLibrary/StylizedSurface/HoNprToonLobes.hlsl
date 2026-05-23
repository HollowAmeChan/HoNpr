#ifndef HONPR_TOON_LOBES_INCLUDED
#define HONPR_TOON_LOBES_INCLUDED

#include "../Lighting/HoNprLightingInput.hlsl"
#include "HoNprStylizedSurface.hlsl"

HoNprLobeOutput HoNprEvaluateToonDiffuseRampLilToon(HoUrpSurfaceData surface, HoNprLightingContext lighting, HoNprStylizedSurfaceData stylized, half3 rampColor)
{
    HoNprLobeOutput output = HoNprCreateLobeOutput();
    half ndotl = saturate(dot(HoNprSafeNormalize(surface.normalWS, half3(0.0h, 0.0h, 1.0h)), lighting.mainLightDirWS));
    half rampCoord = HoNprComputeRampCoord(ndotl * HoNprCombinedShadow(lighting), stylized);
    output.diffuse = surface.baseColor * lerp(half3(0.0h, 0.0h, 0.0h), rampColor, rampCoord);
    output.diffuse += surface.baseColor * lighting.indirectDiffuse * surface.occlusion;
    return output;
}

HoNprLobeOutput HoNprEvaluateToonSpecularLilToon(HoUrpSurfaceData surface, HoNprLightingContext lighting, half3 viewDirWS, half mask, half threshold, half softness)
{
    HoNprLobeOutput output = HoNprCreateLobeOutput();
    half3 normalWS = HoNprSafeNormalize(surface.normalWS, half3(0.0h, 0.0h, 1.0h));
    half3 halfDir = HoNprSafeNormalize(lighting.mainLightDirWS + HoNprSafeNormalize(viewDirWS, normalWS), normalWS);
    half specTerm = saturate(dot(normalWS, halfDir));
    half band = smoothstep(threshold, saturate(threshold + max(0.001h, softness)), specTerm);
    output.specular = lighting.mainLightColor * band * saturate(mask) * HoNprCombinedShadow(lighting);
    return output;
}

HoNprLobeOutput HoNprEvaluateHairSpecular(HoUrpSurfaceData surface, HoNprLightingContext lighting, half3 viewDirWS, half3 tangentWS, half shift, half width, half mask)
{
    HoNprLobeOutput output = HoNprCreateLobeOutput();
    half3 tangent = HoNprSafeNormalize(tangentWS, half3(1.0h, 0.0h, 0.0h));
    half3 halfDir = HoNprSafeNormalize(lighting.mainLightDirWS + HoNprSafeNormalize(viewDirWS, surface.normalWS), surface.normalWS);
    half strand = saturate(1.0h - abs(dot(tangent, halfDir) + shift));
    half highlight = pow(strand, max(1.0h, width));
    output.specular = lighting.mainLightColor * highlight * saturate(mask) * HoNprCombinedShadow(lighting);
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

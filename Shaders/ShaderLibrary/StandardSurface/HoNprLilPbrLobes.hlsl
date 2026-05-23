#ifndef HONPR_LILPBR_LOBES_INCLUDED
#define HONPR_LILPBR_LOBES_INCLUDED

#include "../Lighting/HoNprLightingInput.hlsl"

HoNprLobeOutput HoNprEvaluateLilPbrDiffuse(HoUrpSurfaceData surface, HoNprLightingContext lighting)
{
    HoNprLobeOutput output = HoNprCreateLobeOutput();
    half ndotl = saturate(dot(HoNprSafeNormalize(surface.normalWS, half3(0.0h, 0.0h, 1.0h)), lighting.mainLightDirWS));
    half shadow = HoNprCombinedShadow(lighting);
    output.diffuse = surface.baseColor * lighting.mainLightColor * ndotl * shadow * surface.occlusion;
    output.diffuse += surface.baseColor * lighting.indirectDiffuse * surface.occlusion;
    return output;
}

HoNprLobeOutput HoNprEvaluateLilPbrSpecularGGX(HoUrpSurfaceData surface, HoNprLightingContext lighting, half3 viewDirWS)
{
    HoNprLobeOutput output = HoNprCreateLobeOutput();
    half3 normalWS = HoNprSafeNormalize(surface.normalWS, half3(0.0h, 0.0h, 1.0h));
    half3 halfDir = HoNprSafeNormalize(lighting.mainLightDirWS + HoNprSafeNormalize(viewDirWS, normalWS), normalWS);
    half ndoth = saturate(dot(normalWS, halfDir));
    half roughness = HoNprSafeRoughness(surface.roughness);
    half specPower = max(1.0h, (1.0h - roughness) * 128.0h);
    half spec = pow(ndoth, specPower) * (1.0h - roughness) * HoNprCombinedShadow(lighting);
    half3 f0 = lerp(half3(0.04h, 0.04h, 0.04h), surface.baseColor, saturate(surface.metallic));
    output.specular = f0 * lighting.mainLightColor * spec;
    output.specular += lighting.indirectSpecular * f0 * surface.occlusion;
    return output;
}

HoNprLobeOutput HoNprEvaluateLilPbrSpecularAnisotropic(
    HoUrpSurfaceData surface,
    HoNprLightingContext lighting,
    half3 viewDirWS,
    half3 tangentWS,
    half anisotropy,
    half mask)
{
    HoNprLobeOutput output = HoNprCreateLobeOutput();
    half3 normalWS = HoNprSafeNormalize(surface.normalWS, half3(0.0h, 0.0h, 1.0h));
    half3 tangent = HoNprSafeNormalize(tangentWS, half3(1.0h, 0.0h, 0.0h));
    half3 halfDir = HoNprSafeNormalize(lighting.mainLightDirWS + HoNprSafeNormalize(viewDirWS, normalWS), normalWS);
    half tangentTerm = saturate(1.0h - abs(dot(tangent, halfDir)) * saturate(abs(anisotropy)));
    half normalTerm = saturate(dot(normalWS, halfDir));
    half roughness = HoNprSafeRoughness(surface.roughness);
    half spec = pow(saturate(lerp(normalTerm, tangentTerm, saturate(abs(anisotropy)))), max(1.0h, (1.0h - roughness) * 128.0h));
    half3 f0 = lerp(half3(0.04h, 0.04h, 0.04h), surface.baseColor, saturate(surface.metallic));
    output.specular = f0 * lighting.mainLightColor * spec * saturate(mask) * HoNprCombinedShadow(lighting);
    return output;
}

HoNprLobeOutput HoNprEvaluateLilPbrClearCoatSpecular(
    HoUrpSurfaceData surface,
    HoNprLightingContext lighting,
    half3 viewDirWS,
    half coatMask,
    half coatRoughness)
{
    HoNprLobeOutput output = HoNprCreateLobeOutput();
    half3 normalWS = HoNprSafeNormalize(surface.normalWS, half3(0.0h, 0.0h, 1.0h));
    half3 halfDir = HoNprSafeNormalize(lighting.mainLightDirWS + HoNprSafeNormalize(viewDirWS, normalWS), normalWS);
    half ndoth = saturate(dot(normalWS, halfDir));
    half roughness = HoNprSafeRoughness(coatRoughness);
    half spec = pow(ndoth, max(1.0h, (1.0h - roughness) * 192.0h)) * saturate(coatMask) * HoNprCombinedShadow(lighting);
    output.specular = lighting.mainLightColor * half3(0.04h, 0.04h, 0.04h) * spec;
    return output;
}

#endif

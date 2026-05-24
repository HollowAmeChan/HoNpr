#ifndef HONPR_LILPBR_LOBES_INCLUDED
#define HONPR_LILPBR_LOBES_INCLUDED

#include "../Lighting/HoNprLightingInput.hlsl"

#define HONPR_PI 3.14159265h

half HoNprPerceptualRoughnessToAlpha(half roughness)
{
    half perceptual = HoNprSafeRoughness(roughness);
    return max(0.002h, perceptual * perceptual);
}

half3 HoNprFresnelSchlick(half cosTheta, half3 f0)
{
    half f = pow(1.0h - saturate(cosTheta), 5.0h);
    return f0 + (1.0h - f0) * f;
}

half HoNprD_GGX(half ndoth, half alpha)
{
    half a2 = alpha * alpha;
    half denom = ndoth * ndoth * (a2 - 1.0h) + 1.0h;
    return a2 / max(1.0e-4h, HONPR_PI * denom * denom);
}

half HoNprV_SmithJointGGX(half ndotl, half ndotv, half alpha)
{
    half a2 = alpha * alpha;
    half lambdaV = ndotl * sqrt(max(1.0e-4h, ndotv * (ndotv - ndotv * a2) + a2));
    half lambdaL = ndotv * sqrt(max(1.0e-4h, ndotl * (ndotl - ndotl * a2) + a2));
    return 0.5h / max(1.0e-4h, lambdaV + lambdaL);
}

half3 HoNprPbrF0(HoUrpSurfaceData surface)
{
    return lerp(half3(0.04h, 0.04h, 0.04h), surface.baseColor, saturate(surface.metallic));
}

HoNprLobeOutput HoNprEvaluateLilPbrDiffuse(HoUrpSurfaceData surface, HoNprLightingContext lighting)
{
    HoNprLobeOutput output = HoNprCreateLobeOutput();
    half3 normalWS = HoNprSafeNormalize(surface.normalWS, half3(0.0h, 0.0h, 1.0h));
    half ndotl = saturate(dot(normalWS, lighting.mainLightDirWS));
    half oneMinusMetallic = 1.0h - saturate(surface.metallic);
    half3 diffuseColor = surface.baseColor * oneMinusMetallic;
    output.diffuse = diffuseColor * lighting.mainLightColor * ndotl * HoNprDirectVisibility(lighting);
    output.diffuse += diffuseColor * lighting.indirectDiffuse * HoNprIndirectVisibility(lighting, surface.occlusion);
    return output;
}

HoNprLobeOutput HoNprEvaluateLilPbrSpecularGGX(HoUrpSurfaceData surface, HoNprLightingContext lighting, half3 viewDirWS)
{
    HoNprLobeOutput output = HoNprCreateLobeOutput();
    half3 normalWS = HoNprSafeNormalize(surface.normalWS, half3(0.0h, 0.0h, 1.0h));
    half3 viewWS = HoNprSafeNormalize(viewDirWS, normalWS);
    half3 lightWS = lighting.mainLightDirWS;
    half3 halfDir = HoNprSafeNormalize(lightWS + viewWS, normalWS);
    half ndotl = saturate(dot(normalWS, lightWS));
    half ndotv = saturate(dot(normalWS, viewWS));
    half ndoth = saturate(dot(normalWS, halfDir));
    half ldoth = saturate(dot(lightWS, halfDir));
    half alpha = HoNprPerceptualRoughnessToAlpha(surface.roughness);
    half spec = HoNprD_GGX(ndoth, alpha) * HoNprV_SmithJointGGX(ndotl, ndotv, alpha) * ndotl;
    half3 f0 = HoNprPbrF0(surface);
    output.specular = HoNprFresnelSchlick(ldoth, f0) * lighting.mainLightColor * spec * HoNprDirectVisibility(lighting);
    output.specular += lighting.indirectSpecular * f0 * HoNprIndirectVisibility(lighting, surface.occlusion);
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
    half3 tangent = HoNprSafeNormalize(tangentWS - normalWS * dot(normalWS, tangentWS), half3(1.0h, 0.0h, 0.0h));
    half3 bitangent = HoNprSafeNormalize(cross(normalWS, tangent), half3(0.0h, 0.0h, 1.0h));
    half3 viewWS = HoNprSafeNormalize(viewDirWS, normalWS);
    half3 lightWS = lighting.mainLightDirWS;
    half3 halfDir = HoNprSafeNormalize(lightWS + viewWS, normalWS);
    half ndotl = saturate(dot(normalWS, lightWS));
    half ndotv = saturate(dot(normalWS, viewWS));
    half ndoth = saturate(dot(normalWS, halfDir));
    half ldoth = saturate(dot(lightWS, halfDir));
    half alpha = HoNprPerceptualRoughnessToAlpha(surface.roughness);
    half aniso = clamp(anisotropy, -0.95h, 0.95h) * saturate(mask);
    half alphaT = max(0.002h, alpha * (1.0h + aniso));
    half alphaB = max(0.002h, alpha * (1.0h - aniso));
    half tdotH = dot(tangent, halfDir);
    half bdotH = dot(bitangent, halfDir);
    half denom = tdotH * tdotH / (alphaT * alphaT) + bdotH * bdotH / (alphaB * alphaB) + ndoth * ndoth;
    half d = 1.0h / max(1.0e-4h, HONPR_PI * alphaT * alphaB * denom * denom);
    half v = HoNprV_SmithJointGGX(ndotl, ndotv, sqrt(alphaT * alphaB));
    half3 f0 = HoNprPbrF0(surface);
    output.specular = HoNprFresnelSchlick(ldoth, f0) * lighting.mainLightColor * d * v * ndotl * saturate(mask) * HoNprDirectVisibility(lighting);
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
    half3 viewWS = HoNprSafeNormalize(viewDirWS, normalWS);
    half3 lightWS = lighting.mainLightDirWS;
    half3 halfDir = HoNprSafeNormalize(lightWS + viewWS, normalWS);
    half ndotl = saturate(dot(normalWS, lightWS));
    half ndotv = saturate(dot(normalWS, viewWS));
    half ndoth = saturate(dot(normalWS, halfDir));
    half ldoth = saturate(dot(lightWS, halfDir));
    half alpha = HoNprPerceptualRoughnessToAlpha(coatRoughness);
    half spec = HoNprD_GGX(ndoth, alpha) * HoNprV_SmithJointGGX(ndotl, ndotv, alpha) * ndotl;
    output.specular = HoNprFresnelSchlick(ldoth, half3(0.04h, 0.04h, 0.04h)) * lighting.mainLightColor * spec * saturate(coatMask) * HoNprDirectVisibility(lighting);
    return output;
}

#endif

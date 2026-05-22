#ifndef HONPR_STYLIZED_LOBES_INCLUDED
#define HONPR_STYLIZED_LOBES_INCLUDED

#include "../HoNprCommon.hlsl"

HoNprLobeOutput HoNprEvaluateMatCap(HoUrpSurfaceData surface, half3 matCapColor, half mask, half shadowInfluence)
{
    HoNprLobeOutput output = HoNprCreateLobeOutput();
    half influence = saturate(mask) * saturate(shadowInfluence);
    output.specular = matCapColor * influence;
    return output;
}

HoNprLobeOutput HoNprEvaluateRimLight(HoUrpSurfaceData surface, half3 viewDirWS, half3 rimColor, half mask, half power)
{
    HoNprLobeOutput output = HoNprCreateLobeOutput();
    half3 normalWS = HoNprSafeNormalize(surface.normalWS, half3(0.0h, 0.0h, 1.0h));
    half rim = pow(saturate(1.0h - dot(normalWS, HoNprSafeNormalize(viewDirWS, normalWS))), max(0.01h, power));
    output.emission = rimColor * rim * saturate(mask);
    return output;
}

HoNprLobeOutput HoNprEvaluateRimShade(HoUrpSurfaceData surface, half3 viewDirWS, half3 shadeColor, half mask, half power)
{
    HoNprLobeOutput output = HoNprCreateLobeOutput();
    half3 normalWS = HoNprSafeNormalize(surface.normalWS, half3(0.0h, 0.0h, 1.0h));
    half rim = pow(saturate(1.0h - dot(normalWS, HoNprSafeNormalize(viewDirWS, normalWS))), max(0.01h, power));
    output.diffuse = -surface.baseColor * shadeColor * rim * saturate(mask);
    return output;
}

HoNprLobeOutput HoNprEvaluateBacklight(HoUrpSurfaceData surface, half3 lightDirWS, half3 viewDirWS, half3 backlightColor, half mask, half power)
{
    HoNprLobeOutput output = HoNprCreateLobeOutput();
    half3 viewDir = HoNprSafeNormalize(viewDirWS, surface.normalWS);
    half3 lightDir = HoNprSafeNormalize(lightDirWS, -viewDir);
    half backlight = pow(saturate(dot(-lightDir, viewDir)), max(0.01h, power));
    output.emission = backlightColor * backlight * saturate(mask);
    return output;
}

HoNprLobeOutput HoNprEvaluateEmissionPrimary(half3 emissionColor, half intensity, half mask)
{
    HoNprLobeOutput output = HoNprCreateLobeOutput();
    output.emission = max(0.0h, emissionColor) * max(0.0h, intensity) * saturate(mask);
    return output;
}

#endif

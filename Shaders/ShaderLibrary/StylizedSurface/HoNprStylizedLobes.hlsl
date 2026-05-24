#ifndef HONPR_STYLIZED_LOBES_INCLUDED
#define HONPR_STYLIZED_LOBES_INCLUDED

#include "../HoNprCommon.hlsl"

HoNprLobeOutput HoNprEvaluateLilToonMatCap(HoUrpSurfaceData surface, half3 matCapColor, half mask, half shadowInfluence)
{
    HoNprLobeOutput output = HoNprCreateLobeOutput();
    half influence = saturate(mask) * saturate(shadowInfluence);
    output.specular = matCapColor * influence;
    return output;
}

HoNprLobeOutput HoNprEvaluateLilToonSecondaryMatCap(HoUrpSurfaceData surface, half3 matCapColor, half mask, half shadowInfluence)
{
    HoNprLobeOutput output = HoNprCreateLobeOutput();
    half influence = saturate(mask) * saturate(shadowInfluence);
    output.specular = matCapColor * influence;
    return output;
}

HoNprLobeOutput HoNprEvaluateLilToonRimLight(HoUrpSurfaceData surface, half3 viewDirWS, half3 rimColor, half mask, half power)
{
    HoNprLobeOutput output = HoNprCreateLobeOutput();
    half3 normalWS = HoNprSafeNormalize(surface.normalWS, half3(0.0h, 0.0h, 1.0h));
    half rim = pow(saturate(1.0h - dot(normalWS, HoNprSafeNormalize(viewDirWS, normalWS))), max(0.01h, power));
    output.emission = rimColor * rim * saturate(mask);
    return output;
}

HoNprLobeOutput HoNprEvaluateLilToonRimShade(HoUrpSurfaceData surface, half3 viewDirWS, half3 shadeColor, half mask, half power)
{
    HoNprLobeOutput output = HoNprCreateLobeOutput();
    half3 normalWS = HoNprSafeNormalize(surface.normalWS, half3(0.0h, 0.0h, 1.0h));
    half rim = pow(saturate(1.0h - dot(normalWS, HoNprSafeNormalize(viewDirWS, normalWS))), max(0.01h, power));
    output.diffuse = -surface.baseColor * shadeColor * rim * saturate(mask);
    return output;
}

HoNprLobeOutput HoNprEvaluateLilToonBacklight(HoUrpSurfaceData surface, half3 lightDirWS, half3 viewDirWS, half3 backlightColor, half mask, half power)
{
    HoNprLobeOutput output = HoNprCreateLobeOutput();
    half3 normalWS = HoNprSafeNormalize(surface.normalWS, half3(0.0h, 0.0h, 1.0h));
    half3 viewDir = HoNprSafeNormalize(viewDirWS, normalWS);
    half3 lightDir = HoNprSafeNormalize(lightDirWS, -viewDir);
    half wrap = saturate(dot(-normalWS, lightDir));
    half backlight = pow(saturate(dot(-lightDir, viewDir)), max(0.01h, power)) * wrap;
    output.emission = backlightColor * backlight * saturate(mask);
    return output;
}

HoNprLobeOutput HoNprEvaluateLilToonBackfaceColor(half frontFace, half4 backfaceColor)
{
    HoNprLobeOutput output = HoNprCreateLobeOutput();
    half backface = 1.0h - saturate(frontFace);
    output.diffuse = max(0.0h, backfaceColor.rgb) * saturate(backfaceColor.a) * backface;
    return output;
}

HoNprLobeOutput HoNprEvaluateLilToonEmissionPrimary(half3 emissionColor, half intensity, half mask)
{
    HoNprLobeOutput output = HoNprCreateLobeOutput();
    output.emission = max(0.0h, emissionColor) * max(0.0h, intensity) * saturate(mask);
    return output;
}

HoNprLobeOutput HoNprEvaluateLilToonEmissionSecondary(half3 emissionColor, half intensity, half mask)
{
    HoNprLobeOutput output = HoNprCreateLobeOutput();
    output.emission = max(0.0h, emissionColor) * max(0.0h, intensity) * saturate(mask);
    return output;
}

float HoNprGlitterHash(float3 value)
{
    return frac(sin(dot(value, float3(12.9898, 78.233, 37.719))) * 43758.5453);
}

HoNprLobeOutput HoNprEvaluateLilToonGlitter(HoUrpSurfaceData surface, half3 lightDirWS, half3 viewDirWS, float3 positionWS, half3 glitterColor, half mask, half density, half threshold, half power)
{
    HoNprLobeOutput output = HoNprCreateLobeOutput();
    half3 normalWS = HoNprSafeNormalize(surface.normalWS, half3(0.0h, 0.0h, 1.0h));
    half3 lightDir = HoNprSafeNormalize(lightDirWS, normalWS);
    half3 halfDir = HoNprSafeNormalize(lightDir + HoNprSafeNormalize(viewDirWS, normalWS), normalWS);
    half facing = pow(saturate(dot(normalWS, halfDir)), max(0.01h, power)) * saturate(dot(normalWS, lightDir));
    float sparkleCell = HoNprGlitterHash(floor(positionWS * max(1.0h, density)) + float3(normalWS));
    half sparkle = smoothstep(saturate(threshold), 1.0h, half(sparkleCell));
    output.specular = glitterColor * sparkle * facing * saturate(mask);
    return output;
}

HoNprLobeOutput HoNprEvaluateLilToonDistanceFade(float3 positionWS, float3 cameraPositionWS, half3 fadeColor, half fadeStart, half fadeEnd, half strength)
{
    HoNprLobeOutput output = HoNprCreateLobeOutput();
    half range = max(0.001h, fadeEnd - fadeStart);
    half fade = saturate(((half)distance(positionWS, cameraPositionWS) - fadeStart) / range);
    fade = saturate(fade * saturate(strength));
    output.emission = fadeColor * fade;
    output.energyWeight = 1.0h - fade;
    return output;
}

#endif

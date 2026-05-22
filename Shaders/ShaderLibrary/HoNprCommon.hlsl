#ifndef HONPR_COMMON_INCLUDED
#define HONPR_COMMON_INCLUDED

#include "Packages/com.hollow.hourp-extensions/Runtime/Shaders/ShaderLibrary/HoUrpMaterialSurface.hlsl"

struct HoNprLobeOutput
{
    half3 diffuse;
    half3 specular;
    half3 transmission;
    half3 emission;
    half alpha;
    half energyWeight;
    half semanticWeight;
};

struct HoNprCompositeOutput
{
    half3 color;
    half alpha;
    half coverage;
};

struct HoNprSemanticMapData
{
    half sssWeight;
    half specularMask;
    half stylizedMask;
    half utility;
};

struct HoNprRegionMaskData
{
    half skin;
    half hair;
    half cloth;
    half accessory;
};

HoNprLobeOutput HoNprCreateLobeOutput()
{
    HoNprLobeOutput output;
    output.diffuse = half3(0.0h, 0.0h, 0.0h);
    output.specular = half3(0.0h, 0.0h, 0.0h);
    output.transmission = half3(0.0h, 0.0h, 0.0h);
    output.emission = half3(0.0h, 0.0h, 0.0h);
    output.alpha = 1.0h;
    output.energyWeight = 1.0h;
    output.semanticWeight = 1.0h;
    return output;
}

HoNprSemanticMapData HoNprCreateSemanticMapData(half4 sample)
{
    HoNprSemanticMapData data;
    data.sssWeight = saturate(sample.r);
    data.specularMask = saturate(sample.g);
    data.stylizedMask = saturate(sample.b);
    data.utility = saturate(sample.a);
    return data;
}

HoNprRegionMaskData HoNprCreateRegionMaskData(half4 sample)
{
    HoNprRegionMaskData data;
    data.skin = saturate(sample.r);
    data.hair = saturate(sample.g);
    data.cloth = saturate(sample.b);
    data.accessory = saturate(sample.a);
    return data;
}

void HoNprAccumulateLobe(inout HoNprLobeOutput target, HoNprLobeOutput source)
{
    target.diffuse += source.diffuse;
    target.specular += source.specular;
    target.transmission += source.transmission;
    target.emission += source.emission;
    target.alpha *= source.alpha;
    target.energyWeight *= source.energyWeight;
    target.semanticWeight *= source.semanticWeight;
}

half HoNprSafeRoughness(half roughness)
{
    return max(0.045h, saturate(roughness));
}

half3 HoNprSafeNormalize(half3 value, half3 fallback)
{
    half lenSq = dot(value, value);
    return lenSq > 1.0e-4h ? value * rsqrt(lenSq) : fallback;
}

#endif

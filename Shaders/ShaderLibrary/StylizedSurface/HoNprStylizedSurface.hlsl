#ifndef HONPR_STYLIZED_SURFACE_INCLUDED
#define HONPR_STYLIZED_SURFACE_INCLUDED

#include "../HoNprCommon.hlsl"

struct HoNprStylizedSurfaceData
{
    half rampCoord;
    half rampRow;
    half rampBias;
    half rampScale;
    half region;
};

HoNprStylizedSurfaceData HoNprCreateStylizedSurfaceData(half rampRow, half rampBias, half rampScale, half region)
{
    HoNprStylizedSurfaceData data;
    data.rampCoord = 0.5h;
    data.rampRow = rampRow;
    data.rampBias = rampBias;
    data.rampScale = rampScale;
    data.region = region;
    return data;
}

half HoNprComputeRampCoord(half ndotl, HoNprStylizedSurfaceData stylized)
{
    return saturate(ndotl * stylized.rampScale + stylized.rampBias);
}

half2 HoNprComputeRampUv(half rampCoord, HoNprStylizedSurfaceData stylized, half atlasRowCount)
{
    half rowCount = max(1.0h, atlasRowCount);
    return half2(saturate(rampCoord), (floor(stylized.rampRow) + 0.5h) / rowCount);
}

half3 HoNprSampleStyleRampAtlas(TEXTURE2D_PARAM(rampAtlas, samplerRampAtlas), half2 rampUv)
{
    return SAMPLE_TEXTURE2D(rampAtlas, samplerRampAtlas, rampUv).rgb;
}

#endif

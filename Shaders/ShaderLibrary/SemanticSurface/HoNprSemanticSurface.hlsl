#ifndef HONPR_SEMANTIC_SURFACE_INCLUDED
#define HONPR_SEMANTIC_SURFACE_INCLUDED

#include "Packages/com.hollow.hourp-extensions/Runtime/Shaders/ShaderLibrary/HoUrpMaterialAov.hlsl"

HoUrpMaterialSemanticData HoNprCreateMaterialSemanticProducer(
    half materialClass,
    half sssProfile,
    half thickness,
    half curvature,
    half4 materialCustom0_3,
    half3 sssSourceColor,
    half sssWeight)
{
    return HoUrpCreateMaterialSemanticData(
        materialClass,
        sssProfile,
        thickness,
        curvature,
        materialCustom0_3,
        sssSourceColor,
        sssWeight);
}

HoUrpAovOutputData HoNprEncodeStandardAov(HoUrpMaterialSemanticData semantic, half maskWeight)
{
    return HoUrpEncodeMaterialAov(semantic, maskWeight);
}

#endif

#ifndef HONPR_OUTLINE_INCLUDED
#define HONPR_OUTLINE_INCLUDED

#include "../HoNprCommon.hlsl"

struct HoNprLilToonSourceOutlineSettings
{
    float width;
    float widthMask;
    float vertexWidthMode;
    float fixWidth;
    float zBias;
};

float HoNprSelectLilToonSourceOutlineVertexWidth(half4 vertexColor, float vertexWidthMode)
{
    if (vertexWidthMode > 1.5)
    {
        return vertexColor.a;
    }

    if (vertexWidthMode > 0.5)
    {
        return vertexColor.r;
    }

    return 1.0;
}

float HoNprApplyLilToonSourceOutlineFixWidth(float width, float3 positionWS, float fixWidth)
{
    float distanceToCamera = max(distance(GetCameraPositionWS(), positionWS), 1.0e-4);
    float fixedScale = saturate(distanceToCamera);
    return width * lerp(1.0, fixedScale, saturate(fixWidth));
}

float4 HoNprTransformLilToonSourceOutlineToHClip(
    float3 positionOS,
    float3 normalOS,
    half4 vertexColor,
    HoNprLilToonSourceOutlineSettings settings)
{
    float3 positionWS = TransformObjectToWorld(positionOS);
    float width = settings.width * settings.widthMask;
    width *= HoNprSelectLilToonSourceOutlineVertexWidth(vertexColor, settings.vertexWidthMode);
    width = HoNprApplyLilToonSourceOutlineFixWidth(width, positionWS, settings.fixWidth);

    float normalLenSq = dot(normalOS, normalOS);
    float3 outlineNormalOS = normalLenSq > 1.0e-6 ? normalOS * rsqrt(normalLenSq) : float3(0.0, 0.0, 1.0);
    positionOS += outlineNormalOS * width;

    positionWS = TransformObjectToWorld(positionOS);
    float3 viewDirWSRaw = GetWorldSpaceViewDir(positionWS);
    float viewLenSq = dot(viewDirWSRaw, viewDirWSRaw);
    float3 viewDirWS = viewLenSq > 1.0e-6 ? viewDirWSRaw * rsqrt(viewLenSq) : float3(0.0, 0.0, 1.0);
    positionWS -= viewDirWS * settings.zBias;

    return TransformWorldToHClip(positionWS);
}

#endif

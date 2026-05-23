#ifndef HONPR_OUTLINE_INCLUDED
#define HONPR_OUTLINE_INCLUDED

#include "../HoNprCommon.hlsl"

struct HoNprLilToonOutlineSettings
{
    float width;
    float widthMask;
    float vertexWidthMode;
    float fixWidth;
    float zBias;
    float vectorScale;
};

float HoNprSelectLilToonOutlineVertexWidth(half4 vertexColor, float vertexWidthMode)
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

float3 HoNprNormalizeOutlineVector(float3 value, float3 fallback)
{
    float lenSq = dot(value, value);
    return lenSq > 1.0e-6 ? value * rsqrt(lenSq) : fallback;
}

float3 HoNprDecodeLilToonOutlineVectorTS(half4 vectorSample, float vectorScale)
{
    float3 vectorTS;
    #if defined(UNITY_NO_DXT5nm)
        vectorTS = float3(vectorSample.rgb * 2.0h - 1.0h);
    #else
        #if !defined(UNITY_ASTC_NORMALMAP_ENCODING)
            vectorSample.a *= vectorSample.r;
        #endif
        vectorTS.xy = vectorSample.ag * 2.0h - 1.0h;
        vectorTS.z = sqrt(1.0 - saturate(dot(vectorTS.xy, vectorTS.xy)));
    #endif
    vectorTS.xy *= vectorScale;
    vectorTS.z = max(0.0, vectorTS.z);
    return HoNprNormalizeOutlineVector(vectorTS, float3(0.0, 0.0, 1.0));
}

float3 HoNprGetLilToonOutlineVertexColorVector(half4 vertexColor, float3 normalOS, float3x3 tbnOS)
{
    bool isDefaultBlack = all(vertexColor.rgb <= 0.0001h);
    bool isDefaultWhite = all(vertexColor.rgb >= 0.9999h);
    if (isDefaultBlack || isDefaultWhite)
    {
        return normalOS;
    }

    return mul(float3(vertexColor.rgb * 2.0h - 1.0h), tbnOS);
}

float3 HoNprGetLilToonOutlineDirectionOS(
    float3 normalOS,
    float4 tangentOS,
    half4 vertexColor,
    half4 vectorSample,
    HoNprLilToonOutlineSettings settings)
{
    float3 normal = HoNprNormalizeOutlineVector(normalOS, float3(0.0, 0.0, 1.0));
    float3 tangent = HoNprNormalizeOutlineVector(tangentOS.xyz, float3(1.0, 0.0, 0.0));
    float3 bitangent = HoNprNormalizeOutlineVector(cross(normal, tangent) * tangentOS.w, float3(0.0, 1.0, 0.0));
    float3x3 tbnOS = float3x3(tangent, bitangent, normal);

    if (settings.vertexWidthMode > 1.5)
    {
        return HoNprNormalizeOutlineVector(HoNprGetLilToonOutlineVertexColorVector(vertexColor, normal, tbnOS), normal);
    }

    float3 vectorTS = HoNprDecodeLilToonOutlineVectorTS(vectorSample, settings.vectorScale);
    return HoNprNormalizeOutlineVector(mul(vectorTS, tbnOS), normal);
}

float HoNprApplyLilToonOutlineFixWidth(float width, float3 positionWS, float fixWidth)
{
    float distanceToCamera = max(distance(GetCameraPositionWS(), positionWS), 1.0e-4);
    float fixedScale = saturate(distanceToCamera);
    return width * lerp(1.0, fixedScale, saturate(fixWidth));
}

float4 HoNprTransformLilToonOutlineToHClip(
    float3 positionOS,
    float3 normalOS,
    float4 tangentOS,
    half4 vertexColor,
    half4 vectorSample,
    HoNprLilToonOutlineSettings settings)
{
    float3 positionWS = TransformObjectToWorld(positionOS);
    float width = settings.width * 0.01 * settings.widthMask;
    width *= HoNprSelectLilToonOutlineVertexWidth(vertexColor, settings.vertexWidthMode);
    width = HoNprApplyLilToonOutlineFixWidth(width, positionWS, settings.fixWidth);

    float3 outlineNormalOS = HoNprGetLilToonOutlineDirectionOS(normalOS, tangentOS, vertexColor, vectorSample, settings);
    positionOS += outlineNormalOS * width;

    positionWS = TransformObjectToWorld(positionOS);
    float3 viewDirWSRaw = GetWorldSpaceViewDir(positionWS);
    float viewLenSq = dot(viewDirWSRaw, viewDirWSRaw);
    float3 viewDirWS = viewLenSq > 1.0e-6 ? viewDirWSRaw * rsqrt(viewLenSq) : float3(0.0, 0.0, 1.0);
    positionWS -= viewDirWS * settings.zBias;

    return TransformWorldToHClip(positionWS);
}

half3 HoNprApplyLilToonOutlineLighting(
    half3 outlineRgb,
    half4 outlineTexture,
    half4 litColor,
    half litApplyTexture,
    half litScale,
    half litOffset,
    half enableLighting,
    half3 normalWS,
    half3 lightDirWS,
    half3 lightColor)
{
    float2 normalVS = mul((float3x3)UNITY_MATRIX_V, float3(normalWS)).xy;
    float2 lightVS = mul((float3x3)UNITY_MATRIX_V, float3(lightDirWS)).xy;
    float normalLenSq = max(dot(normalVS, normalVS), 1.0e-6);
    float lightLenSq = max(dot(lightVS, lightVS), 1.0e-6);
    half outlineNdotL = half(dot(normalVS * rsqrt(normalLenSq), lightVS * rsqrt(lightLenSq)) * 0.5 + 0.5);

    half3 litTarget = lerp(litColor.rgb, outlineTexture.rgb * litColor.rgb, saturate(litApplyTexture));
    half litFactor = saturate(outlineNdotL * litScale + litOffset) * saturate(litColor.a);
    outlineRgb = lerp(outlineRgb, litTarget, litFactor);
    outlineRgb = lerp(outlineRgb, outlineRgb * max(lightColor, half3(0.0h, 0.0h, 0.0h)), saturate(enableLighting));
    return outlineRgb;
}

#endif

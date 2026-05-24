#ifndef HONPR_HOURP_SHADOW_RECEIVER_INCLUDED
#define HONPR_HOURP_SHADOW_RECEIVER_INCLUDED

#include "Packages/com.hollow.hourp-extensions/Runtime/Shaders/ShaderLibrary/HoUrpShadowCastSampling.hlsl"

half HoNprSampleHoUrpShadowReceiver(float3 positionWS, half3 normalWS)
{
    return HoUrpSampleShadowCastAttenuation(positionWS, normalWS);
}

#endif


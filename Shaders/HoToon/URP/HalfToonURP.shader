Shader "HoNpr/HoToon/URP/HalfToon_Outline"
{
    Properties
    {
        [Header(Base)]
        [NoScaleOffset] _MainTex ("主贴图", 2D) = "white" {}
        _Cutoff ("Alpha 裁剪", Range(0,1)) = 0.5
        _Color ("基础颜色", Color) = (1,1,1,1)
        [NoScaleOffset] _NormalMap ("法线贴图", 2D) = "bump" {}
        _NormalStength ("法线强度", Range(-1,1)) = 0.2

        [Space][Space][Space][Space][Space]

        [Header(PixelSettings)]
        [Header(WARNING_Set_Texture_Compression_To_None)]
        [Header(WARNING_Check_Texture_Filter_Mode)]
        [NoScaleOffset] _HalftoneTex ("网点图案", 2D) = "gray" {}
        _HalftoneScale ("网点缩放", Range(0.1,100)) = 0.1
        [Space]
        [Header(Halftone_Camera_Scaling)]
        [Toggle] _HalftoneCameraScale ("启用相机缩放", Float) = 0
        _HalftoneCameraRefDistance ("参考距离", Range(0.01,50)) = 2
        _HalftoneCameraScaleStrength ("距离缩放强度", Range(0,1)) = 1
        _HalftoneCameraScaleMin ("缩放下限", Range(0.05,1)) = 0.25
        _HalftoneCameraScaleMax ("缩放上限", Range(1,8)) = 4
        [Space]
        [Enum(Screen,0,ObjSpaceTriplanar,1,UVLightMap,2,UV0,3,UV1,4)] _PixelSpace ("像素空间", Float) = 1
        _GlobalPixelSize ("全局像素尺寸", Range(1,8192)) = 8192
        _HalftoneStrength ("网点强度", Range(0,1)) = 0.3

        [Space][Space][Space][Space][Space]

        [Header(Base_Lighting)]
        _ColorLevels ("色阶数量", Float) = 5
        _ShadowColor ("阴影颜色", Color) = (0.3,0.3,0.35,1)
        _MidColor ("中间色", Color) = (0.7,0.7,0.75,1)
        _LightColor ("亮部颜色", Color) = (1,1,1,1)
        _threshold1 ("光照阈值 1", Range(0,1)) = 0.3
        _threshold2 ("光照阈值 2", Range(0,1)) = 1
        _ShadowCasting ("阴影影响强度", Range(0,1)) = 1

        [Space][Space][Space][Space][Space]

        [Header(Highlights)]
        _Highlight ("高光强度", Range(0,1)) = 1
        _HighlightColor ("高光颜色", Color) = (1,1,1,1)
        _HightlightThreshold ("高光阈值", Range(0,1)) = 0.9
        _HighlightSoft ("高光柔和", Range(0,1)) = 0.3

        [Space][Space][Space][Space][Space]

        [Header(Rim)]
        _Rim ("边缘光强度", Range(0,1)) = 0
        _RimThreshold ("边缘光阈值", Range(0,1)) = 0.8
        _RimSoft ("边缘光柔和", Range(0,1)) = 0.2
        _RimColorInner ("边缘光内侧颜色", Color) = (1,1,1,1)
        _RimColorOuter ("边缘光外侧颜色", Color) = (1,1,1,1)
        [Toggle] _RimInvert ("反转边缘光", Float) = 0

        [Space][Space][Space][Space][Space]

        [Header(Matcap)]
        _Matcap ("Matcap 强度", Range(0,1)) = 0
        _MatcapExposure ("Matcap 曝光", Range(0,100)) = 1
        _MatcapPow ("Matcap 幂次", Range(0,3)) = 1
        _MatcapColor ("Matcap 颜色", Color) = (1,1,1,1)
        [NoScaleOffset] _MatcapTex ("Matcap 贴图", 2D) = "black" {}

        [Space][Space][Space][Space][Space]

        [Header(Outline)]
        _OutlineWidth ("描边宽度", Range(0,0.05)) = 0.005
        _OutlineColor ("描边颜色", Color) = (0,0,0,1)
        [NoScaleOffset] _OutlineMask ("描边遮罩", 2D) = "white" {}

        [Space][Space][Space][Space][Space]

        [Header(Effects)]
        _ExtraLight ("额外光强度", Range(0,1)) = 0
        _ExtraLightRotation ("额外光旋转", Vector) = (0,0,0,0)
        _ExtraLight_ShadowColor ("额外光阴影颜色", Color) = (0,1,0,0)
        _ExtraLight_MidColor ("额外光中间色", Color) = (0.7,0.7,0.75,1)
        _ExtraLight_LightColor ("额外光亮部颜色", Color) = (1,1,1,1)
        _ExtraLight_Threshold1 ("额外光阈值 1", Range(0,1)) = 0.4
        _ExtraLight_Threshold2 ("额外光阈值 2", Range(0,1)) = 0.75

        [Space][Space][Space][Space][Space]

        [Header(MainPass)]
        [Enum(UnityEngine.Rendering.BlendOp)] _BlendOp ("BlendOp", Float) = 0
        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend ("SrcBlend", Float) = 1
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlend ("DstBlend", Float) = 0
        [Enum(Off, 0, On, 1)] _ZWriteMode ("ZWriteMode", Float) = 1
        [Enum(UnityEngine.Rendering.CullMode)] _CullMode ("CullMode", Float) = 0
        [Enum(UnityEngine.Rendering.CompareFunction)] _ZTestMode ("ZTestMode", Float) = 4
        [Enum(UnityEngine.Rendering.ColorWriteMask)] _ColorMask ("ColorMask", Float) = 15
        [Header(Stencil)]
        [Enum(UnityEngine.Rendering.CompareFunction)] _StencilComp ("Comp", Float) = 8
        [IntRange] _StencilWriteMask ("WriteMask", Range(0,255)) = 255
        [IntRange] _StencilReadMask ("ReadMask", Range(0,255)) = 255
        [IntRange] _Stencil ("ref", Range(0,255)) = 0
        [Enum(UnityEngine.Rendering.StencilOp)] _StencilPass ("Pass", Float) = 0
        [Enum(UnityEngine.Rendering.StencilOp)] _StencilFail ("Fail", Float) = 0
        [Enum(UnityEngine.Rendering.StencilOp)] _StencilZFail ("ZFail", Float) = 0

        [Space][Space][Space][Space][Space]

        [Header(OutLinePass)]
        [Enum(UnityEngine.Rendering.BlendOp)] _OutlineBlendOp ("BlendOp", Float) = 0
        [Enum(UnityEngine.Rendering.BlendMode)] _OutlineSrcBlend ("SrcBlend", Float) = 1
        [Enum(UnityEngine.Rendering.BlendMode)] _OutlineDstBlend ("DstBlend", Float) = 0
        [Enum(Off, 0, On, 1)] _OutlineZWriteMode ("ZWriteMode", Float) = 1
        [Enum(UnityEngine.Rendering.CullMode)] _OutlineCull ("CullMode", Float) = 1
        [Enum(UnityEngine.Rendering.CompareFunction)] _OutlineZTestMode ("ZTestMode", Float) = 4
        [Enum(UnityEngine.Rendering.ColorWriteMask)] _OutlineColorMask ("ColorMask", Float) = 15
        [Header(Stencil)]
        [Enum(UnityEngine.Rendering.CompareFunction)] _OutlineStencilComp ("Comp", Float) = 8
        [IntRange] _OutlineStencilWriteMask ("WriteMask", Range(0,255)) = 255
        [IntRange] _OutlineStencilReadMask ("ReadMask", Range(0,255)) = 255
        [IntRange] _OutlineStencil ("ref", Range(0,255)) = 0
        [Enum(UnityEngine.Rendering.StencilOp)] _OutlineStencilPass ("Pass", Float) = 0
        [Enum(UnityEngine.Rendering.StencilOp)] _OutlineStencilFail ("Fail", Float) = 0
        [Enum(UnityEngine.Rendering.StencilOp)] _OutlineStencilZFail ("ZFail", Float) = 0
    }

    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
            "RenderPipeline" = "UniversalPipeline"
            "UniversalMaterialType" = "Lit"
        }
        LOD 200

        HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"

        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        TEXTURE2D(_NormalMap);
        SAMPLER(sampler_NormalMap);
        TEXTURE2D(_HalftoneTex);
        SAMPLER(sampler_HalftoneTex);
        TEXTURE2D(_MatcapTex);
        SAMPLER(sampler_MatcapTex);
        TEXTURE2D(_OutlineMask);
        SAMPLER(sampler_OutlineMask);

        CBUFFER_START(UnityPerMaterial)
            float4 _MainTex_ST;
            float4 _OutlineMask_ST;
            float4 _Color;
            float4 _ShadowColor;
            float4 _MidColor;
            float4 _LightColor;
            float4 _HighlightColor;
            float4 _RimColorInner;
            float4 _RimColorOuter;
            float4 _MatcapColor;
            float4 _OutlineColor;
            float4 _ExtraLightRotation;
            float4 _ExtraLight_ShadowColor;
            float4 _ExtraLight_MidColor;
            float4 _ExtraLight_LightColor;
            float _Cutoff;
            float _NormalStength;
            float _GlobalPixelSize;
            float _PixelSpace;
            float _HalftoneStrength;
            float _HalftoneScale;
            float _HalftoneCameraScale;
            float _HalftoneCameraRefDistance;
            float _HalftoneCameraScaleStrength;
            float _HalftoneCameraScaleMin;
            float _HalftoneCameraScaleMax;
            float _ColorLevels;
            float _threshold1;
            float _threshold2;
            float _ShadowCasting;
            float _Highlight;
            float _HightlightThreshold;
            float _HighlightSoft;
            float _Rim;
            float _RimThreshold;
            float _RimSoft;
            float _RimInvert;
            float _MatcapExposure;
            float _MatcapPow;
            float _Matcap;
            float _OutlineWidth;
            float _ExtraLight;
            float _ExtraLight_Threshold1;
            float _ExtraLight_Threshold2;
        CBUFFER_END

        float GetHalftoneCameraScale(float3 positionWS, float screenSpaceMode)
        {
            float cameraDistance = max(distance(GetCameraPositionWS(), positionWS), 1e-4);
            float referenceDistance = max(_HalftoneCameraRefDistance, 1e-4);
            float keepScreenSizeScale = referenceDistance / cameraDistance;
            float mimicSurfaceScale = cameraDistance / referenceDistance;
            float rawScale = lerp(keepScreenSizeScale, mimicSurfaceScale, screenSpaceMode);
            float minScale = min(_HalftoneCameraScaleMin, _HalftoneCameraScaleMax);
            float maxScale = max(_HalftoneCameraScaleMin, _HalftoneCameraScaleMax);
            float clampedScale = clamp(rawScale, minScale, maxScale);

            return lerp(1.0, clampedScale, saturate(_HalftoneCameraScale) * saturate(_HalftoneCameraScaleStrength));
        }

        float SampleHalftone(float2 pixelPos, float cameraScale)
        {
            float2 uv = pixelPos / max(_GlobalPixelSize, 1.0);
            uv *= _HalftoneScale * cameraScale;

            return SAMPLE_TEXTURE2D(_HalftoneTex, sampler_HalftoneTex, uv).r;
        }

        float4 ToonRamp(float t, float4 shadow, float4 mid, float4 light)
        {
            return lerp(
                lerp(shadow, mid, t * 2.0),
                light,
                saturate(t * 2.0 - 1.0)
            );
        }

        float4 SampleMatcap(float3 normalWS, float halftone, float exposure, float matcapPow)
        {
            float3 normalVS = mul((float3x3)UNITY_MATRIX_V, normalWS);
            float2 uv = normalVS.xy * 0.5 + 0.5;

            float4 mat = SAMPLE_TEXTURE2D(_MatcapTex, sampler_MatcapTex, uv);
            float lum = mat.r;
            lum *= exposure;
            lum = pow(max(lum, 0.0), matcapPow);
            lum += (halftone - 0.5) * _HalftoneStrength;

            float levels = max(1.0, floor(_ColorLevels));
            lum = floor(lum * levels) / levels;
            lum = saturate(lum);

            return _MatcapColor * lum * _Matcap;
        }
        ENDHLSL

        Pass
        {
            Name "OUTLINE"
            Tags { "LightMode" = "SRPDefaultUnlit" }

            Cull [_OutlineCull]
            Offset 1, 1
            BlendOp [_OutlineBlendOp]
            Blend [_OutlineSrcBlend] [_OutlineDstBlend]
            ZWrite [_OutlineZWriteMode]
            ZTest [_OutlineZTestMode]
            ColorMask [_OutlineColorMask]

            Stencil
            {
                Ref [_OutlineStencil]
                Comp [_OutlineStencilComp]
                ReadMask [_OutlineStencilReadMask]
                WriteMask [_OutlineStencilWriteMask]
                Pass [_OutlineStencilPass]
                Fail [_OutlineStencilFail]
                ZFail [_OutlineStencilZFail]
            }

            HLSLPROGRAM
            #pragma target 3.0
            #pragma vertex VertOutline
            #pragma fragment FragOutline

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            Varyings VertOutline(Attributes input)
            {
                Varyings output;

                float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);
                float4 positionVS = mul(UNITY_MATRIX_V, float4(positionWS, 1.0));
                float3 normalWS = TransformObjectToWorldNormal(input.normalOS);
                float3 normalVS = normalize(mul((float3x3)UNITY_MATRIX_V, normalWS));

                float outlineFactor = saturate(1.0 - abs(normalVS.z));
                float2 offsetDir = normalize(normalVS.xy + 1e-6);

                positionVS.xy += offsetDir * _OutlineWidth * outlineFactor;

                output.positionCS = mul(UNITY_MATRIX_P, positionVS);
                output.uv = TRANSFORM_TEX(input.uv, _OutlineMask);
                return output;
            }

            half4 FragOutline(Varyings input) : SV_Target
            {
                clip(_OutlineWidth - 0.0001);
                half mask = SAMPLE_TEXTURE2D(_OutlineMask, sampler_OutlineMask, input.uv).r;
                return half4(_OutlineColor.rgb, _OutlineColor.a * mask);
            }
            ENDHLSL
        }

        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode" = "UniversalForward" }

            Cull [_CullMode]
            BlendOp [_BlendOp]
            Blend [_SrcBlend] [_DstBlend]
            ZWrite [_ZWriteMode]
            ZTest [_ZTestMode]
            ColorMask [_ColorMask]

            Stencil
            {
                Ref [_Stencil]
                Comp [_StencilComp]
                ReadMask [_StencilReadMask]
                WriteMask [_StencilWriteMask]
                Pass [_StencilPass]
                Fail [_StencilFail]
                ZFail [_StencilZFail]
            }

            HLSLPROGRAM
            #pragma target 3.0
            #pragma vertex Vert
            #pragma fragment Frag
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            #pragma multi_compile_fragment _ _SHADOWS_SOFT

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float2 uv : TEXCOORD0;
                float2 uv1 : TEXCOORD1;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float2 uv1 : TEXCOORD1;
                float3 normalWS : TEXCOORD2;
                float4 screenPos : TEXCOORD3;
                float3 positionWS : TEXCOORD4;
                float3 positionOS : TEXCOORD5;
                float3 normalOS : TEXCOORD6;
                float4 shadowCoord : TEXCOORD7;
            };

            Varyings Vert(Attributes input)
            {
                Varyings output;

                VertexPositionInputs positionInputs = GetVertexPositionInputs(input.positionOS.xyz);
                VertexNormalInputs normalInputs = GetVertexNormalInputs(input.normalOS);

                output.positionCS = positionInputs.positionCS;
                output.uv = TRANSFORM_TEX(input.uv, _MainTex);
                output.uv1 = TRANSFORM_TEX(input.uv1, _MainTex);
                output.normalWS = normalInputs.normalWS;
                output.screenPos = ComputeScreenPos(output.positionCS);
                output.positionWS = positionInputs.positionWS;
                output.positionOS = input.positionOS.xyz;
                output.normalOS = input.normalOS;
                output.shadowCoord = TransformWorldToShadowCoord(positionInputs.positionWS);

                return output;
            }

            half4 Frag(Varyings input) : SV_Target
            {
                float4 tex = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv) * _Color;

                float3 normal = normalize(input.normalWS);
                float3 normalTex = UnpackNormal(SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, input.uv)) * _NormalStength;
                normal = normalize(normal + normalTex);

                Light mainLightData = GetMainLight(input.shadowCoord);
                float3 lightDir = normalize(mainLightData.direction);
                float3 viewDir = normalize(GetCameraPositionWS() - input.positionWS);

                float2 pixelPos;
                if (_PixelSpace < 0.5)
                {
                    float2 screenUV = input.screenPos.xy / input.screenPos.w;
                    float4 screenParams = GetScaledScreenParams();
                    float pixelScale = screenParams.x / max(_GlobalPixelSize, 1.0);
                    pixelPos = floor(screenUV * screenParams.xy / pixelScale + 0.5);
                }
                else if (_PixelSpace < 1.5)
                {
                    float pixelSize = 2.0 / max(_GlobalPixelSize, 1.0);
                    float3 p = input.positionOS;
                    float3 n = abs(input.normalOS);
                    n *= n;
                    n *= n;

                    if (n.z > n.x && n.z > n.y)
                        pixelPos = p.xy;
                    else if (n.x > n.y)
                        pixelPos = p.yz;
                    else
                        pixelPos = p.xz;

                    pixelPos = floor(pixelPos / pixelSize + 0.5);
                }
                else if (_PixelSpace < 2.5)
                {
                    float2 lightmapUV = input.uv1 * unity_LightmapST.xy + unity_LightmapST.zw;
                    pixelPos = floor(lightmapUV * _GlobalPixelSize + 0.5);
                }
                else if (_PixelSpace < 3.5)
                {
                    pixelPos = floor(input.uv * _GlobalPixelSize + 0.5);
                }
                else
                {
                    pixelPos = floor(input.uv1 * _GlobalPixelSize + 0.5);
                }

                float halftoneCameraScale = GetHalftoneCameraScale(input.positionWS, (_PixelSpace < 0.5) ? 1.0 : 0.0);
                float halftone = SampleHalftone(pixelPos, halftoneCameraScale);

                float atten = mainLightData.shadowAttenuation * mainLightData.distanceAttenuation;
                atten = smoothstep(0.0, 1.0, atten);

                float nDotL = dot(normal, lightDir);
                float lambert = nDotL * 0.5 + 0.5;
                lambert = smoothstep(_threshold1, _threshold2, lambert);
                lambert = saturate(lambert);
                lambert *= lerp(1.0, atten, _ShadowCasting);
                lambert += (halftone - 0.5) * _HalftoneStrength;

                float colorLevels = max(1.0, floor(_ColorLevels));
                float luminance = saturate(lambert);
                float clampedLight = floor(luminance * colorLevels) / colorLevels;
                float nextLight = ceil(luminance * colorLevels) / colorLevels;
                float lerpVal = frac(luminance * colorLevels);
                float stepper = step(halftone, lerpVal);
                float finalLuminance = clampedLight * (1.0 - stepper) + nextLight * stepper;
                float4 mainLight = ToonRamp(finalLuminance, _ShadowColor, _MidColor, _LightColor);

                float3 extraDir = normalize(lightDir + normalize(_ExtraLightRotation.xyz));
                float extraNdotL = dot(normal, extraDir);
                float extraLambert = extraNdotL * 0.5 + 0.5;
                extraLambert = saturate(extraLambert);
                extraLambert = smoothstep(_ExtraLight_Threshold1, _ExtraLight_Threshold2, extraLambert);
                extraLambert += (halftone - 0.5) * _HalftoneStrength;

                float extraLuminance = saturate(extraLambert);
                float extraClampedLight = floor(extraLuminance * colorLevels) / colorLevels;
                float extraNextLight = ceil(extraLuminance * colorLevels) / colorLevels;
                float extraLerpVal = frac(extraLuminance * colorLevels);
                float extraStepper = step(halftone, extraLerpVal);
                float extraFinalLuminance = extraClampedLight * (1.0 - extraStepper) + extraNextLight * extraStepper;
                float4 extraLight = ToonRamp(extraFinalLuminance, _ExtraLight_ShadowColor, _ExtraLight_MidColor, _ExtraLight_LightColor);
                extraLight *= _ExtraLight;

                float3 halfDir = normalize(lightDir + viewDir);
                float spec = pow(saturate(dot(normal, halfDir)), 32.0);
                spec *= lerp(1.0, atten, _ShadowCasting);
                float highlightThreshold = _HightlightThreshold + (halftone - 0.5) * _HalftoneStrength * _HighlightSoft;
                float highlightMask = step(highlightThreshold, spec) * _Highlight;
                float4 highlight = highlightMask * _HighlightColor;

                float rimDot = 1.0 - saturate(dot(viewDir, normal));
                float rimCoord = lerp(rimDot, 1.0 - rimDot, _RimInvert);
                float rimThreshold = _RimThreshold + (halftone - 0.5) * _HalftoneStrength * _RimSoft;
                float rimMask = step(rimThreshold, rimCoord) * _Rim;
                float rimGradient = saturate((rimCoord - rimThreshold) / max(_RimSoft, 1e-5));
                float4 rim = rimMask * lerp(_RimColorInner, _RimColorOuter, rimGradient);

                float4 matcap = SampleMatcap(normal, halftone, _MatcapExposure, _MatcapPow);

                float alpha = tex.a;
                alpha += (halftone - 0.5) * _HalftoneStrength;
                clip(alpha * _Color.a - _Cutoff);

                float3 color = tex.rgb * lerp(mainLight.rgb, float3(1.0, 1.0, 1.0), 1.0 - mainLight.a) + extraLight.rgb * extraLight.a;
                color += highlight.rgb * highlight.a;
                color += rim.rgb * rim.a;
                color += matcap.rgb * matcap.a;

                return half4(color, 1.0);
            }
            ENDHLSL
        }

        Pass
        {
            Name "ShadowCaster"
            Tags { "LightMode" = "ShadowCaster" }

            ZWrite On
            ZTest LEqual
            ColorMask 0
            Cull [_CullMode]

            HLSLPROGRAM
            #pragma target 3.0
            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment
            #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW

            float3 _LightDirection;
            float3 _LightPosition;

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            Varyings ShadowPassVertex(Attributes input)
            {
                Varyings output;

                VertexPositionInputs positionInputs = GetVertexPositionInputs(input.positionOS.xyz);
                VertexNormalInputs normalInputs = GetVertexNormalInputs(input.normalOS);

                #if _CASTING_PUNCTUAL_LIGHT_SHADOW
                    float3 lightDirectionWS = normalize(_LightPosition - positionInputs.positionWS);
                #else
                    float3 lightDirectionWS = _LightDirection;
                #endif

                float3 positionWS = ApplyShadowBias(positionInputs.positionWS, normalInputs.normalWS, lightDirectionWS);
                output.positionCS = TransformWorldToHClip(positionWS);

                #if UNITY_REVERSED_Z
                    output.positionCS.z = min(output.positionCS.z, UNITY_NEAR_CLIP_VALUE);
                #else
                    output.positionCS.z = max(output.positionCS.z, UNITY_NEAR_CLIP_VALUE);
                #endif

                output.uv = TRANSFORM_TEX(input.uv, _MainTex);
                return output;
            }

            half4 ShadowPassFragment(Varyings input) : SV_Target
            {
                float4 tex = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv) * _Color;
                clip(tex.a * _Color.a - _Cutoff);
                return 0;
            }
            ENDHLSL
        }

        Pass
        {
            Name "DepthOnly"
            Tags { "LightMode" = "DepthOnly" }

            ZWrite On
            ColorMask 0
            Cull [_CullMode]

            HLSLPROGRAM
            #pragma target 3.0
            #pragma vertex DepthOnlyVertex
            #pragma fragment DepthOnlyFragment

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            Varyings DepthOnlyVertex(Attributes input)
            {
                Varyings output;
                output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
                output.uv = TRANSFORM_TEX(input.uv, _MainTex);
                return output;
            }

            half4 DepthOnlyFragment(Varyings input) : SV_Target
            {
                float4 tex = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv) * _Color;
                clip(tex.a * _Color.a - _Cutoff);
                return 0;
            }
            ENDHLSL
        }
    }

    FallBack Off
}

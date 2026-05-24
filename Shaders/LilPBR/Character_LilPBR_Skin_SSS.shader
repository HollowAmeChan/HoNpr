Shader "HoNpr/Character_LilPBR_Skin_SSS"
{
    Properties
    {
        _BaseMap("Base Map", 2D) = "white" {}
        _BaseColorMap("Base Color Map", 2D) = "white" {}
        _MainTex("Main Tex", 2D) = "white" {}
        _Color("Base Color", Color) = (1, 0.96932113, 0.95911944, 1)
        _AlphaClip("Alpha Clip", Range(0, 1)) = 0
        _Cutoff("Alpha Cutoff", Range(0, 1)) = 0.5

        _PBRMap("PBR Map", 2D) = "white" {}
        _MetallicChannel("Metallic Channel", Float) = 0
        _OcclusionChannel("Occlusion Channel", Float) = 1
        _SmoothnessChannel("Smoothness Channel", Float) = 3
        _InvertSmoothness("Invert Smoothness", Float) = 0
        _Metallic("Metallic", Range(0, 1)) = 0
        _Smoothness("Smoothness", Range(0, 1)) = 1
        _Glossiness("Glossiness", Range(0, 1)) = 0.56
        _OcclusionStrength("Occlusion Strength", Range(0, 1)) = 1
        _Reflectance("Reflectance", Range(0, 1)) = 0.09

        _UseSSS("Use Legacy SSS", Float) = 0
        _UseSubsurfaceScattering("Use Subsurface Scattering", Float) = 0
        _SubsurfaceColor("Subsurface Color", Color) = (0.76729554, 0.65105885, 0.5863295, 1)
        _SubsurfaceAbsorptionColor("Subsurface Absorption Color", Color) = (0.96862745, 0.9016286, 0.8862745, 1)
        _SubsurfaceMap("Subsurface Map", 2D) = "white" {}
        _SSSThicknessMap("SSS Thickness Map", 2D) = "white" {}
        _SubsurfaceScattering("Subsurface Scattering", Range(0, 2)) = 1
        _SubsurfaceThickness("Subsurface Thickness", Range(0, 1)) = 0.219
        _SubsurfaceRim("Subsurface Rim", Range(0, 1)) = 0.52
        _SubsurfaceWrap("Subsurface Wrap", Range(0, 1)) = 0.829
        _SubsurfaceDirectStrength("Subsurface Direct Strength", Range(0, 8)) = 1.75
        _SubsurfaceEnvironmentStrength("Subsurface Environment Strength", Range(0, 8)) = 4
        _SubsurfacePower("Subsurface Power", Range(0.1, 16)) = 5.03
        _SubsurfaceAlbedoBlend("Subsurface Albedo Blend", Range(0, 1)) = 1
        _SubsurfaceAbsorptionStrength("Subsurface Absorption Strength", Range(0, 8)) = 8
        _SubsurfaceChannel("Subsurface Channel", Float) = 0
        _SubsurfaceInvert("Subsurface Invert", Float) = 0
        _SubsurfaceReceiveShadow("Subsurface Receive Shadow", Float) = 1

        _HoSSSProfileId("Ho SSS Profile Id", Float) = 5
        _HoSSSThicknessScale("Ho SSS Thickness Scale", Range(0, 8)) = 2.6
        _HoSSSTransmissionRadius("Ho SSS Transmission Radius", Range(0, 8)) = 2
        _HoSSSTransmissionStrength("Ho SSS Transmission Strength", Range(0, 8)) = 2

        _HoUrpGeneratedMaterialClass("Material Class", Float) = 1
        _HoUrpGeneratedMaterialSssProfile("SSS Profile", Float) = 5
        _HoUrpGeneratedMaterialThickness("HoURP Thickness", Range(0, 1)) = 0.219
        _HoUrpGeneratedMaterialCurvature("HoURP Curvature", Range(-1, 1)) = 0
        _HoUrpGeneratedMaterialCustom0_3("Material Custom 0-3", Vector) = (0, 0, 0, 0)
        _HoUrpGeneratedSssSourceColor("SSS Source Color Override", Color) = (0, 0, 0, 1)
    }

    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Opaque" "Queue" = "Geometry" }

        HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.hollow.hourp-extensions/Runtime/Shaders/ShaderLibrary/HoUrpObjectSemantic.hlsl"
        #include "Packages/com.hollow.hourp-extensions/Runtime/Shaders/ShaderLibrary/HoUrpMaterialAov.hlsl"

        TEXTURE2D(_BaseMap); SAMPLER(sampler_BaseMap);
        TEXTURE2D(_PBRMap); SAMPLER(sampler_PBRMap);
        TEXTURE2D(_SubsurfaceMap); SAMPLER(sampler_SubsurfaceMap);
        TEXTURE2D(_SSSThicknessMap); SAMPLER(sampler_SSSThicknessMap);

        float4 _BaseMap_ST;
        half4 _Color;
        half _AlphaClip;
        half _Cutoff;
        half _MetallicChannel;
        half _OcclusionChannel;
        half _SmoothnessChannel;
        half _InvertSmoothness;
        half _Metallic;
        half _Smoothness;
        half _Glossiness;
        half _OcclusionStrength;
        half _Reflectance;
        half _UseSSS;
        half _UseSubsurfaceScattering;
        half4 _SubsurfaceColor;
        half4 _SubsurfaceAbsorptionColor;
        half _SubsurfaceScattering;
        half _SubsurfaceThickness;
        half _SubsurfaceRim;
        half _SubsurfaceWrap;
        half _SubsurfaceDirectStrength;
        half _SubsurfaceEnvironmentStrength;
        half _SubsurfacePower;
        half _SubsurfaceAlbedoBlend;
        half _SubsurfaceAbsorptionStrength;
        half _SubsurfaceChannel;
        half _SubsurfaceInvert;
        half _SubsurfaceReceiveShadow;
        half _HoSSSProfileId;
        half _HoSSSThicknessScale;
        half _HoSSSTransmissionRadius;
        half _HoSSSTransmissionStrength;
        float _HoUrpGeneratedMaterialClass;
        float _HoUrpGeneratedMaterialSssProfile;
        float _HoUrpGeneratedMaterialThickness;
        float _HoUrpGeneratedMaterialCurvature;
        float4 _HoUrpGeneratedMaterialCustom0_3;
        half4 _HoUrpGeneratedSssSourceColor;
        float3 _LightDirection;
        float3 _LightPosition;

        struct Attributes
        {
            float4 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float2 uv : TEXCOORD0;
            UNITY_VERTEX_INPUT_INSTANCE_ID
        };

        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS : TEXCOORD0;
            half3 normalWS : TEXCOORD1;
            float2 uv : TEXCOORD2;
            float2 depthZW : TEXCOORD3;
            float4 shadowCoord : TEXCOORD4;
            UNITY_VERTEX_OUTPUT_STEREO
        };

        struct DepthVaryings
        {
            float4 positionCS : SV_POSITION;
            float2 uv : TEXCOORD0;
            UNITY_VERTEX_OUTPUT_STEREO
        };

        struct AovOutput
        {
            half4 maskId : SV_Target0;
            half4 normalDepth : SV_Target1;
            half4 objectCustom0 : SV_Target2;
            half4 objectCustom1 : SV_Target3;
            half4 surfaceData : SV_Target4;
            half4 materialCustom0 : SV_Target5;
            half4 diffuse : SV_Target6;
        };

        struct SurfaceSample
        {
            half3 baseColor;
            half alpha;
            half metallic;
            half smoothness;
            half occlusion;
            half sssEnabled;
            half subsurfaceMask;
            half subsurfaceThinness;
            half forwardSubsurfaceThickness;
            half3 subsurfaceColor;
            half thickness;
        };

        half3 SafeNormalize(half3 value, half3 fallback)
        {
            half lenSq = dot(value, value);
            return lenSq > 1.0e-4h ? value * rsqrt(lenSq) : fallback;
        }

        half SelectChannel(half4 value, half channel)
        {
            if (channel > 2.5h) return value.a;
            if (channel > 1.5h) return value.b;
            if (channel > 0.5h) return value.g;
            return value.r;
        }

        half ResolveSssEnabled()
        {
            return step(0.5h, max(_UseSubsurfaceScattering, _UseSSS)) * step(0.0001h, _SubsurfaceScattering);
        }

        Varyings Vert(Attributes input)
        {
            Varyings output;
            UNITY_SETUP_INSTANCE_ID(input);
            UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

            VertexPositionInputs positionInputs = GetVertexPositionInputs(input.positionOS.xyz);
            VertexNormalInputs normalInputs = GetVertexNormalInputs(input.normalOS);
            output.positionCS = positionInputs.positionCS;
            output.positionWS = positionInputs.positionWS;
            output.normalWS = NormalizeNormalPerVertex(normalInputs.normalWS);
            output.uv = TRANSFORM_TEX(input.uv, _BaseMap);
            output.depthZW = positionInputs.positionCS.zw;
            output.shadowCoord = TransformWorldToShadowCoord(positionInputs.positionWS);
            return output;
        }

        SurfaceSample SampleSurface(float2 uv)
        {
            SurfaceSample surface;
            half4 baseSample = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uv) * _Color;
            half4 packedPbr = SAMPLE_TEXTURE2D(_PBRMap, sampler_PBRMap, uv);
            half sampledSmoothness = SelectChannel(packedPbr, _SmoothnessChannel);
            sampledSmoothness = lerp(sampledSmoothness, 1.0h - sampledSmoothness, step(0.5h, _InvertSmoothness));

            surface.baseColor = max(0.0h, baseSample.rgb);
            surface.alpha = saturate(baseSample.a);
            surface.metallic = saturate(_Metallic * SelectChannel(packedPbr, _MetallicChannel));
            surface.smoothness = saturate(_Smoothness * _Glossiness * sampledSmoothness);
            surface.occlusion = lerp(1.0h, SelectChannel(packedPbr, _OcclusionChannel), saturate(_OcclusionStrength));
            surface.sssEnabled = ResolveSssEnabled();

            half subsurfaceMask = SelectChannel(SAMPLE_TEXTURE2D(_SubsurfaceMap, sampler_SubsurfaceMap, uv), _SubsurfaceChannel);
            subsurfaceMask = lerp(subsurfaceMask, 1.0h - subsurfaceMask, step(0.5h, _SubsurfaceInvert));
            half thicknessMask = SAMPLE_TEXTURE2D(_SSSThicknessMap, sampler_SSSThicknessMap, uv).r;
            surface.subsurfaceMask = saturate(subsurfaceMask);
            surface.subsurfaceThinness = pow(saturate(subsurfaceMask), max(0.1h, _SubsurfacePower)) * saturate(_SubsurfaceScattering) * surface.sssEnabled;
            surface.forwardSubsurfaceThickness = saturate(_SubsurfaceThickness * thicknessMask);
            surface.thickness = saturate(max(_SubsurfaceScattering * surface.sssEnabled * 0.2h, surface.subsurfaceThinness) * max(_HoSSSThicknessScale, 0.0h));
            surface.subsurfaceColor = lerp(_SubsurfaceColor.rgb, _SubsurfaceColor.rgb * surface.baseColor, saturate(_SubsurfaceAlbedoBlend));
            return surface;
        }

        void ApplyAlphaClip(half alpha)
        {
            clip(alpha - lerp(-1.0h, _Cutoff, step(0.5h, _AlphaClip)));
        }

        half3 EvaluateBaseDirectLight(SurfaceSample surface, half3 normalWS, half3 viewDirWS, Light light)
        {
            half3 lightDirWS = SafeNormalize(light.direction, half3(0.0h, 1.0h, 0.0h));
            half attenuation = saturate(light.distanceAttenuation * light.shadowAttenuation);
            half ndotl = saturate(dot(normalWS, lightDirWS));
            half oneMinusMetallic = 1.0h - surface.metallic;
            half3 diffuse = surface.baseColor * oneMinusMetallic * light.color * ndotl * attenuation;

            half3 halfDir = SafeNormalize(lightDirWS + viewDirWS, normalWS);
            half roughness = max(0.045h, 1.0h - surface.smoothness);
            half specPower = max(1.0h, (1.0h - roughness) * 128.0h);
            half specTerm = pow(saturate(dot(normalWS, halfDir)), specPower) * surface.smoothness * attenuation;
            half3 f0 = lerp(max(_Reflectance, 0.0h).xxx, surface.baseColor, surface.metallic);
            half3 specular = f0 * light.color * specTerm;
            return (diffuse + specular) * surface.occlusion;
        }

        half3 EvaluateFakeSubsurfaceDirect(SurfaceSample surface, half3 normalWS, half3 viewDirWS, Light light)
        {
            half3 lightDirWS = SafeNormalize(light.direction, half3(0.0h, 1.0h, 0.0h));
            half urpShadow = _SubsurfaceReceiveShadow > 0.5h ? light.shadowAttenuation : 1.0h;
            half attenuation = saturate(light.distanceAttenuation * urpShadow);
            half forwardScatter = pow(saturate(dot(-lightDirWS, viewDirWS)), rcp(max((1.0h - surface.forwardSubsurfaceThickness) * (1.0h - surface.forwardSubsurfaceThickness), 0.002h)));
            half wrappedDiffuse = saturate((dot(normalWS, lightDirWS) + _SubsurfaceWrap) / max(1.0h + _SubsurfaceWrap, 1.0e-3h));
            half scatter = lerp(forwardScatter, max(forwardScatter, wrappedDiffuse), saturate(_SubsurfaceWrap));
            return scatter * light.color * attenuation * _SubsurfaceDirectStrength;
        }

        half3 ResolveFakeSubsurface(SurfaceSample surface, half3 normalWS, half3 viewDirWS, float3 positionWS, Light mainLight)
        {
            half scatterDepth = saturate(1.0h - surface.forwardSubsurfaceThickness);
            half3 absorptionColor = pow(max(saturate(_SubsurfaceAbsorptionColor.rgb), 0.001h), _SubsurfaceAbsorptionStrength * scatterDepth);
            half3 subsurfaceColor = surface.subsurfaceColor * absorptionColor;
            half3 direct = EvaluateFakeSubsurfaceDirect(surface, normalWS, viewDirWS, mainLight);
            half3 environment = SampleSH(normalWS) * _SubsurfaceEnvironmentStrength * 0.12h;
            return (direct + environment) * subsurfaceColor * surface.occlusion;
        }

        half4 FragForward(Varyings input) : SV_Target
        {
            UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

            SurfaceSample surface = SampleSurface(input.uv);
            ApplyAlphaClip(surface.alpha);

            half3 normalWS = SafeNormalize(input.normalWS, half3(0.0h, 1.0h, 0.0h));
            half3 viewDirWS = SafeNormalize(GetWorldSpaceViewDir(input.positionWS), normalWS);
            Light mainLight = GetMainLight(input.shadowCoord);
            half3 color = EvaluateBaseDirectLight(surface, normalWS, viewDirWS, mainLight);
            color += SampleSH(normalWS) * surface.baseColor * surface.occlusion;

            half subsurfaceRim = lerp(1.0h, abs(dot(normalWS, viewDirWS)), saturate(_SubsurfaceRim));
            half forwardThickness = lerp(1.0h, surface.forwardSubsurfaceThickness * subsurfaceRim, surface.subsurfaceThinness);
            half fakeSssBlend = (1.0h - forwardThickness) * surface.sssEnabled;
            half3 fakeSss = ResolveFakeSubsurface(surface, normalWS, viewDirWS, input.positionWS, mainLight);
            color = lerp(color, max(color, fakeSss), fakeSssBlend);

            return half4(max(0.0h, color), surface.alpha);
        }

        AovOutput FragAov(Varyings input)
        {
            UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

            SurfaceSample surface = SampleSurface(input.uv);
            ApplyAlphaClip(surface.alpha);

            half3 normalWS = SafeNormalize(input.normalWS, half3(0.0h, 1.0h, 0.0h));
            float rawDepth = input.depthZW.x / max(input.depthZW.y, 1.0e-6);
            half linear01Depth = half(saturate(Linear01Depth(rawDepth, _ZBufferParams)));
            half sourceWeight = saturate(_SubsurfaceScattering) * surface.subsurfaceMask * surface.sssEnabled;
            half3 sourceColor = lerp(_SubsurfaceColor.rgb, _SubsurfaceColor.rgb * surface.baseColor, saturate(_SubsurfaceAlbedoBlend)) * sourceWeight;
            half3 sssSourceColor = max(_HoUrpGeneratedSssSourceColor.rgb, sourceColor);
            half curvature = max(saturate(abs(_HoUrpGeneratedMaterialCurvature)), saturate(_HoSSSTransmissionStrength - 1.0h) * step(0.0001h, sourceWeight));
            half utility = max(saturate(_HoUrpGeneratedMaterialCustom0_3.w), saturate((_HoSSSTransmissionRadius - 0.5h) / 1.5h) * step(0.0001h, sourceWeight));

            HoUrpObjectSemanticData objectSemantic = HoUrpResolveObjectSemanticData();
            HoUrpMaterialSemanticData semantic = HoUrpCreateMaterialSemanticData(
                half(_HoUrpGeneratedMaterialClass),
                half(max(_HoUrpGeneratedMaterialSssProfile, _HoSSSProfileId)),
                saturate(max(_HoUrpGeneratedMaterialThickness, surface.thickness)),
                curvature,
                half4(_HoUrpGeneratedMaterialCustom0_3.xyz, utility),
                sssSourceColor);
            HoUrpAovOutputData materialAov = HoUrpEncodeMaterialAov(semantic, objectSemantic.maskWeight);

            AovOutput output;
            output.maskId = HoUrpEncodeObjectMaskId(objectSemantic);
            output.normalDepth = half4(normalWS * 0.5h + 0.5h, linear01Depth);
            output.objectCustom0 = HoUrpEncodeObjectCustom0_3(objectSemantic);
            output.objectCustom1 = HoUrpEncodeObjectCustom4_7(objectSemantic);
            output.surfaceData = materialAov.surfaceData;
            output.materialCustom0 = materialAov.materialCustom0_3;
            output.diffuse = materialAov.diffuse;
            return output;
        }

        DepthVaryings DepthVert(Attributes input)
        {
            DepthVaryings output;
            UNITY_SETUP_INSTANCE_ID(input);
            UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);
            output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
            output.uv = TRANSFORM_TEX(input.uv, _BaseMap);
            return output;
        }

        DepthVaryings ShadowVert(Attributes input)
        {
            DepthVaryings output;
            UNITY_SETUP_INSTANCE_ID(input);
            UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

            VertexPositionInputs positionInputs = GetVertexPositionInputs(input.positionOS.xyz);
            VertexNormalInputs normalInputs = GetVertexNormalInputs(input.normalOS);

        #if _CASTING_PUNCTUAL_LIGHT_SHADOW
            float3 lightDirectionWS = normalize(_LightPosition - positionInputs.positionWS);
        #else
            float3 lightDirectionWS = _LightDirection;
        #endif

            float3 positionWS = ApplyShadowBias(positionInputs.positionWS, normalInputs.normalWS, lightDirectionWS);
            float4 positionCS = TransformWorldToHClip(positionWS);

        #if UNITY_REVERSED_Z
            positionCS.z = min(positionCS.z, UNITY_NEAR_CLIP_VALUE);
        #else
            positionCS.z = max(positionCS.z, UNITY_NEAR_CLIP_VALUE);
        #endif

            output.positionCS = positionCS;
            output.uv = TRANSFORM_TEX(input.uv, _BaseMap);
            return output;
        }

        half4 DepthFrag(DepthVaryings input) : SV_Target
        {
            UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
            SurfaceSample surface = SampleSurface(input.uv);
            ApplyAlphaClip(surface.alpha);
            return 0;
        }
        ENDHLSL

        Pass
        {
            Name "UniversalForward"
            Tags { "LightMode" = "UniversalForward" }
            Cull Back
            ZWrite On
            ZTest LEqual

            HLSLPROGRAM
            #pragma target 4.5
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            #pragma multi_compile_fragment _ _SHADOWS_SOFT
            #pragma vertex Vert
            #pragma fragment FragForward
            ENDHLSL
        }

        Pass
        {
            Name "HoUrpAovOutput"
            Tags { "LightMode" = "HoUrpAovOutput" }
            Cull Back
            ZWrite Off
            ZTest LEqual

            HLSLPROGRAM
            #pragma target 4.5
            #pragma vertex Vert
            #pragma fragment FragAov
            ENDHLSL
        }

        Pass
        {
            Name "DepthOnly"
            Tags { "LightMode" = "DepthOnly" }
            Cull Back
            ZWrite On
            ZTest LEqual
            ColorMask 0

            HLSLPROGRAM
            #pragma target 4.5
            #pragma vertex DepthVert
            #pragma fragment DepthFrag
            ENDHLSL
        }

        Pass
        {
            Name "ShadowCaster"
            Tags { "LightMode" = "ShadowCaster" }
            Cull Back
            ZWrite On
            ZTest LEqual
            ColorMask 0

            HLSLPROGRAM
            #pragma target 4.5
            #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
            #pragma vertex ShadowVert
            #pragma fragment DepthFrag
            ENDHLSL
        }
    }
}

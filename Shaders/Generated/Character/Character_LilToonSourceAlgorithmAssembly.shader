// Generated HoNpr assembly prototype.
// SourcePreset: MaterialPreset.Character_LilToonSourceAlgorithmAssembly
// Template: MaterialTemplate.CharacterForward + MaterialTemplate.CharacterAov + MaterialTemplate.CharacterDepth + MaterialTemplate.CharacterShadow + MaterialTemplate.CharacterOit
// SourceReference: lilToon lts/ltspass shader shell and lil_pass_forward_normal.hlsl component order.
// Blocks: BaseColorTexture, NormalMap, RegionMask, StyleRampAtlas, UrpMainLightInput, IndirectLightInput, ScreenAoReceiver, HoShadowReceiver, ToonDiffuseRamp, ToonSpecular, RimShade, RimLight, Backlight, MatCap, EmissionPrimary, MaterialSemanticProducer, AovOutputStandard, TransparentComposite, OitAccumulationOutput
// This shader intentionally does not include lilToon files or inherit lilToon ABI names.
Shader "HoNpr/Generated/Character_LilToonSourceAlgorithmAssembly"
{
    Properties
    {
        _HoNprBaseMap("Base Map", 2D) = "white" {}
        _HoUrpBaseColor("Base Color", Color) = (1, 1, 1, 1)
        _HoNprStyleRampAtlas("Style Ramp Atlas", 2D) = "white" {}
        _HoNprNormalMap("Normal Map", 2D) = "bump" {}
        _HoNprSemanticMap("Semantic Map", 2D) = "white" {}
        _HoNprRegionMap("Region Map", 2D) = "white" {}

        _HoNprShadowThreshold("Toon Shadow Threshold", Range(0, 1)) = 0.48
        _HoNprShadowSoftness("Toon Shadow Softness", Range(0.001, 1)) = 0.08
        _HoNprRampRow("Ramp Row", Float) = 0
        _HoNprRampRows("Ramp Rows", Float) = 8

        _HoNprSpecularThreshold("Toon Specular Threshold", Range(0, 1)) = 0.72
        _HoNprSpecularSoftness("Toon Specular Softness", Range(0.001, 1)) = 0.08
        _HoNprSpecularMask("Specular Mask", Range(0, 1)) = 0.6

        _HoNprRimColor("Rim Color", Color) = (0.75, 0.9, 1, 1)
        _HoNprRimPower("Rim Power", Range(0.1, 12)) = 3
        _HoNprRimMask("Rim Mask", Range(0, 1)) = 0.5
        _HoNprBacklightColor("Backlight Color", Color) = (0.7, 0.5, 0.35, 1)
        _HoNprBacklightPower("Backlight Power", Range(0.1, 12)) = 2
        _HoNprMatCapColor("MatCap Color", Color) = (0.25, 0.25, 0.3, 1)
        _HoNprMatCapMask("MatCap Mask", Range(0, 1)) = 0.25
        _HoNprEmissionColor("Emission Color", Color) = (0, 0, 0, 1)
        _HoNprEmissionIntensity("Emission Intensity", Range(0, 16)) = 0

        _HoUrpGeneratedMaterialClass("Material Class", Float) = 1
        _HoUrpGeneratedMaterialSssProfile("SSS Profile", Float) = 0
        _HoUrpGeneratedMaterialThickness("Thickness", Range(0, 1)) = 0
        _HoUrpGeneratedMaterialCurvature("Curvature", Range(-1, 1)) = 0
        _HoUrpGeneratedMaterialCustom0_3("Material Custom 0-3", Vector) = (0, 0, 0, 0)
        _HoUrpGeneratedSssSourceColor("SSS Source Color", Color) = (1, 0.75, 0.6, 1)
        _HoUrpGeneratedSssWeight("SSS Weight", Range(0, 1)) = 0

        _HoNprAlphaClipThreshold("Alpha Clip Threshold", Range(0, 1)) = 0
        _HoUrpSupportsOit("Supports OIT", Float) = 1
        _HoUrpParticipatesOit("Participates OIT", Float) = 0
    }

    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Transparent" "Queue" = "Transparent" }

        Pass
        {
            Name "UniversalForward"
            Tags { "LightMode" = "UniversalForward" }

            Cull Back
            ZWrite Off
            ZTest LEqual
            Blend SrcAlpha OneMinusSrcAlpha

            HLSLPROGRAM
            #pragma target 4.5
            #pragma vertex Vert
            #pragma fragment FragForward

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.hollow.hourp-extensions/Runtime/Shaders/ShaderLibrary/HoUrpMaterialSurface.hlsl"
            #include "Packages/com.hollow.honpr/Shaders/ShaderLibrary/HoNprCommon.hlsl"
            #include "Packages/com.hollow.honpr/Shaders/ShaderLibrary/StandardSurface/HoNprStandardSurface.hlsl"
            #include "Packages/com.hollow.honpr/Shaders/ShaderLibrary/StylizedSurface/HoNprStylizedSurface.hlsl"
            #include "Packages/com.hollow.honpr/Shaders/ShaderLibrary/StylizedSurface/HoNprToonLobes.hlsl"
            #include "Packages/com.hollow.honpr/Shaders/ShaderLibrary/StylizedSurface/HoNprStylizedLobes.hlsl"
            #include "Packages/com.hollow.honpr/Shaders/ShaderLibrary/Composite/HoNprComposite.hlsl"

            TEXTURE2D(_HoNprBaseMap);
            SAMPLER(sampler_HoNprBaseMap);
            TEXTURE2D(_HoNprStyleRampAtlas);
            SAMPLER(sampler_HoNprStyleRampAtlas);
            TEXTURE2D(_HoNprSemanticMap);
            SAMPLER(sampler_HoNprSemanticMap);
            TEXTURE2D(_HoNprRegionMap);
            SAMPLER(sampler_HoNprRegionMap);

            float4 _HoNprBaseMap_ST;
            half4 _HoUrpBaseColor;
            half _HoNprShadowThreshold;
            half _HoNprShadowSoftness;
            half _HoNprRampRow;
            half _HoNprRampRows;
            half _HoNprSpecularThreshold;
            half _HoNprSpecularSoftness;
            half _HoNprSpecularMask;
            half4 _HoNprRimColor;
            half _HoNprRimPower;
            half _HoNprRimMask;
            half4 _HoNprBacklightColor;
            half _HoNprBacklightPower;
            half4 _HoNprMatCapColor;
            half _HoNprMatCapMask;
            half4 _HoNprEmissionColor;
            half _HoNprEmissionIntensity;
            half _HoNprAlphaClipThreshold;

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
                UNITY_VERTEX_OUTPUT_STEREO
            };

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
                output.uv = input.uv * _HoNprBaseMap_ST.xy + _HoNprBaseMap_ST.zw;
                return output;
            }

            half4 FragForward(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                half4 baseSample = SAMPLE_TEXTURE2D(_HoNprBaseMap, sampler_HoNprBaseMap, input.uv);
                half4 semanticSample = SAMPLE_TEXTURE2D(_HoNprSemanticMap, sampler_HoNprSemanticMap, input.uv);
                half4 regionSample = SAMPLE_TEXTURE2D(_HoNprRegionMap, sampler_HoNprRegionMap, input.uv);
                HoNprSemanticMapData semanticMap = HoNprApplySemanticMap(semanticSample);
                HoNprRegionMaskData regionMask = HoNprApplyRegionMask(regionSample);

                HoUrpSurfaceData surface = HoUrpCreateSurfaceData(_HoUrpBaseColor.rgb, _HoUrpBaseColor.a, input.normalWS);
                surface = HoNprApplyBaseColorTexture(surface, baseSample, _HoUrpBaseColor);
                clip(surface.alpha - _HoNprAlphaClipThreshold);

                half3 viewDirWS = HoNprSafeNormalize(GetWorldSpaceViewDir(input.positionWS), surface.normalWS);
                half3 lightDirWS = HoNprSafeNormalize(half3(0.35h, 0.75h, 0.55h), half3(0.0h, 1.0h, 0.0h));
                HoNprLightingContext lighting = HoNprCreateLightingContext(lightDirWS, half3(1.0h, 0.94h, 0.86h));
                lighting = HoNprResolveIndirectLight(lighting, half3(0.12h, 0.13h, 0.16h), half3(0.04h, 0.04h, 0.05h));
                lighting = HoNprResolveScreenAoReceiver(lighting, lerp(1.0h, semanticMap.utility, 0.25h), 1.0h);
                lighting = HoNprResolveHoShadowReceiver(lighting, 1.0h);

                half ndotl = saturate(dot(HoNprSafeNormalize(surface.normalWS, half3(0.0h, 0.0h, 1.0h)), lighting.mainLightDirWS));
                half band = smoothstep(_HoNprShadowThreshold - _HoNprShadowSoftness, _HoNprShadowThreshold + _HoNprShadowSoftness, ndotl * HoNprCombinedShadow(lighting));
                HoNprStylizedSurfaceData stylized = HoNprCreateStylizedSurfaceData(_HoNprRampRow, 0.0h, 1.0h, regionMask.skin + regionMask.hair * 2.0h);
                half2 rampUv = HoNprComputeRampUv(band, stylized, _HoNprRampRows);
                half3 rampColor = HoNprSampleStyleRampAtlas(TEXTURE2D_ARGS(_HoNprStyleRampAtlas, sampler_HoNprStyleRampAtlas), rampUv);

                HoNprLobeOutput lobes = HoNprCreateLobeOutput();
                HoNprAccumulateLobe(lobes, HoNprEvaluateToonDiffuseRamp(surface, lighting, stylized, rampColor));
                HoNprAccumulateLobe(lobes, HoNprEvaluateToonSpecular(surface, lighting, viewDirWS, _HoNprSpecularMask * semanticMap.specularMask, _HoNprSpecularThreshold, _HoNprSpecularSoftness));
                HoNprAccumulateLobe(lobes, HoNprEvaluateRimShade(surface, viewDirWS, half3(0.18h, 0.20h, 0.25h), _HoNprRimMask * semanticMap.stylizedMask, _HoNprRimPower));
                HoNprAccumulateLobe(lobes, HoNprEvaluateBacklight(surface, lighting.mainLightDirWS, viewDirWS, _HoNprBacklightColor.rgb, semanticMap.stylizedMask, _HoNprBacklightPower));
                HoNprAccumulateLobe(lobes, HoNprEvaluateMatCap(surface, _HoNprMatCapColor.rgb, _HoNprMatCapMask * semanticMap.stylizedMask, band));
                HoNprAccumulateLobe(lobes, HoNprEvaluateRimLight(surface, viewDirWS, _HoNprRimColor.rgb, _HoNprRimMask * semanticMap.stylizedMask, _HoNprRimPower));
                HoNprAccumulateLobe(lobes, HoNprEvaluateEmissionPrimary(_HoNprEmissionColor.rgb, _HoNprEmissionIntensity, 1.0h));

                HoNprCompositeOutput composite = HoNprCompositeFinalColor(surface, lobes);
                return half4(composite.color, composite.alpha);
            }
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

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.hollow.hourp-extensions/Runtime/Shaders/ShaderLibrary/HoUrpObjectSemantic.hlsl"
            #include "Packages/com.hollow.hourp-extensions/Runtime/Shaders/ShaderLibrary/HoUrpMaterialSurface.hlsl"
            #include "Packages/com.hollow.hourp-extensions/Runtime/Shaders/ShaderLibrary/HoUrpMaterialAov.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                half3 normalWS : TEXCOORD0;
                float2 depthZW : TEXCOORD1;
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
                half4 sssSource : SV_Target6;
            };

            float _HoUrpGeneratedMaterialClass;
            float _HoUrpGeneratedMaterialSssProfile;
            float _HoUrpGeneratedMaterialThickness;
            float _HoUrpGeneratedMaterialCurvature;
            float4 _HoUrpGeneratedMaterialCustom0_3;
            float4 _HoUrpGeneratedSssSourceColor;
            float _HoUrpGeneratedSssWeight;

            Varyings Vert(Attributes input)
            {
                Varyings output;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                VertexPositionInputs positionInputs = GetVertexPositionInputs(input.positionOS.xyz);
                VertexNormalInputs normalInputs = GetVertexNormalInputs(input.normalOS);
                output.positionCS = positionInputs.positionCS;
                output.normalWS = NormalizeNormalPerVertex(normalInputs.normalWS);
                output.depthZW = positionInputs.positionCS.zw;
                return output;
            }

            AovOutput FragAov(Varyings input)
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                HoUrpObjectSemanticData objectSemantic = HoUrpResolveObjectSemanticData();
                half3 normalWS = normalize(input.normalWS);
                float rawDepth = input.depthZW.x / max(input.depthZW.y, 1.0e-6);
                half linear01Depth = half(saturate(Linear01Depth(rawDepth, _ZBufferParams)));

                HoUrpMaterialSemanticData semantic = HoUrpCreateMaterialSemanticData(
                    half(_HoUrpGeneratedMaterialClass),
                    half(_HoUrpGeneratedMaterialSssProfile),
                    half(_HoUrpGeneratedMaterialThickness),
                    half(_HoUrpGeneratedMaterialCurvature),
                    half4(_HoUrpGeneratedMaterialCustom0_3),
                    half3(_HoUrpGeneratedSssSourceColor.rgb),
                    half(_HoUrpGeneratedSssWeight));
                HoUrpAovOutputData materialAov = HoUrpEncodeMaterialAov(semantic, objectSemantic.maskWeight);

                AovOutput output;
                output.maskId = HoUrpEncodeObjectMaskId(objectSemantic);
                output.normalDepth = half4(normalWS * 0.5h + 0.5h, linear01Depth);
                output.objectCustom0 = HoUrpEncodeObjectCustom0_3(objectSemantic);
                output.objectCustom1 = HoUrpEncodeObjectCustom4_7(objectSemantic);
                output.surfaceData = materialAov.surfaceData;
                output.materialCustom0 = materialAov.materialCustom0_3;
                output.sssSource = materialAov.sssSource;
                return output;
            }
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
            #pragma vertex Vert
            #pragma fragment FragDepth
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes { float4 positionOS : POSITION; UNITY_VERTEX_INPUT_INSTANCE_ID };
            struct Varyings { float4 positionCS : SV_POSITION; UNITY_VERTEX_OUTPUT_STEREO };

            Varyings Vert(Attributes input)
            {
                Varyings output;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);
                output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
                return output;
            }

            half4 FragDepth(Varyings input) : SV_Target { return 0; }
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
            #pragma vertex Vert
            #pragma fragment FragShadow
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes { float4 positionOS : POSITION; UNITY_VERTEX_INPUT_INSTANCE_ID };
            struct Varyings { float4 positionCS : SV_POSITION; UNITY_VERTEX_OUTPUT_STEREO };

            Varyings Vert(Attributes input)
            {
                Varyings output;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);
                output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
                return output;
            }

            half4 FragShadow(Varyings input) : SV_Target { return 0; }
            ENDHLSL
        }

        Pass
        {
            Name "HoUrpOitAccumulation"
            Tags { "LightMode" = "HoUrpOitAccumulation" }

            Cull Back
            ZWrite Off
            ZTest LEqual
            Blend One One, Zero OneMinusSrcAlpha

            HLSLPROGRAM
            #pragma target 4.5
            #pragma vertex Vert
            #pragma fragment FragOit

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.hollow.hourp-extensions/Runtime/Shaders/ShaderLibrary/HoUrpMaterialSurface.hlsl"
            #include "Packages/com.hollow.hourp-extensions/Runtime/Shaders/ShaderLibrary/HoUrpMaterialOit.hlsl"

            TEXTURE2D(_HoNprBaseMap);
            SAMPLER(sampler_HoNprBaseMap);
            float4 _HoNprBaseMap_ST;
            half4 _HoUrpBaseColor;
            half _HoNprAlphaClipThreshold;
            float _HoUrpSupportsOit;
            float _HoUrpParticipatesOit;

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
                half3 normalWS : TEXCOORD0;
                float2 uv : TEXCOORD1;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            struct OitOutput
            {
                half4 accumulation : SV_Target0;
                half revealage : SV_Target1;
            };

            Varyings Vert(Attributes input)
            {
                Varyings output;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);
                VertexPositionInputs positionInputs = GetVertexPositionInputs(input.positionOS.xyz);
                VertexNormalInputs normalInputs = GetVertexNormalInputs(input.normalOS);
                output.positionCS = positionInputs.positionCS;
                output.normalWS = NormalizeNormalPerVertex(normalInputs.normalWS);
                output.uv = input.uv * _HoNprBaseMap_ST.xy + _HoNprBaseMap_ST.zw;
                return output;
            }

            OitOutput FragOit(Varyings input)
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                half4 baseSample = SAMPLE_TEXTURE2D(_HoNprBaseMap, sampler_HoNprBaseMap, input.uv) * _HoUrpBaseColor;
                clip(baseSample.a - _HoNprAlphaClipThreshold);

                HoUrpSurfaceData surface = HoUrpCreateSurfaceData(baseSample.rgb, baseSample.a, input.normalWS);
                HoUrpTransparentOutputData transparentData = HoUrpCreateTransparentOutputData(surface, half(_HoUrpSupportsOit), half(_HoUrpParticipatesOit));
                transparentData.alpha *= transparentData.supportsOit * transparentData.participatesOit;
                HoUrpOitAccumulationData accumulation = HoUrpEncodeOitAccumulation(transparentData);

                OitOutput output;
                output.accumulation = half4(accumulation.weightedColor, accumulation.weightedAlpha);
                output.revealage = accumulation.revealage;
                return output;
            }
            ENDHLSL
        }
    }

    CustomEditor "Hollow.HoNpr.Editor.MaterialUi.HoNprMaterialShaderGUI"
}

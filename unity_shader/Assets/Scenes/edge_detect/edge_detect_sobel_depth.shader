Shader "custom/edge_detect/sobel_depth"
{
Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        _TestColor("Test color", Color) = (1, 1, 1, 1) // For Testing, Mask the background color
        _EdgeColor("_EdgeColor", Color) = (0, 0, 0, 0)
        _Threshold("_Threshold", Range(0, 1)) = 0.5
        _BgFade("_BgFade", Range(0, 1)) = 0
        _SampleDistance("_SampleDistance", Range(1, 100)) = 1
        _Exponent("_Exponent", Range(1, 100)) = 1
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment fragColor
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            uniform sampler2D _MainTex;
            uniform sampler2D _MainTex_ST;
            uniform float4 _MainTex_TexelSize;
            sampler2D_float _CameraDepthTexture;
            sampler2D _CameraDepthNormalsTexture;

            uniform float4 _EdgeColor;
            //uniform float _Exponent;
            uniform float _SampleDistance; // To control the edge width
            //uniform float _FilterPower;
            uniform float _Threshold;
            uniform float _Exponent;
            uniform float4 _TestColor;
            uniform float _BgFade;
            //uniform float3 _LightDir; // For toon shading
            //uniform int _bToonShader;

            struct appdata
            {
                float4 vertex: POSITION;
                float4 normal: NORMAL;
                float2 uv: TEXCOORD0;
            };

            struct v2f
            {
                float2 uv: TEXCOORD0;
                float4 vertex: SV_POSITION;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float4 fragColor(v2f i) : COLOR
            {        
                float2 offsets[9] = {
                    float2(-1, 1),
                    float2(0, 1),
                    float2(1, 1),
                    float2(-1, 0),
                    float2(0, 0),
                    float2(1, 0),
                    float2(-1, -1),
                    float2(0, -1),
                    float2(1, -1)
                };

                const float4 horizontalDiagCoef = float4(-1, -1, 1, 1);
                const float4 horizontalAxialCoef = float4(0, -1, 0, 1);
                const float4 verticalDiagCoeff = float4(1, 1, -1, -1);
                const float verticalAxialCoef = float4(1, 0, -1, 0);
                // boardlands implementation of sobel filter
                // diagonal / axial values
                float4 depthDiag;
                float4 depthAxial;

                float2 distance = _SampleDistance * _MainTex_TexelSize.xy;

                depthDiag.x = Linear01Depth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv + offsets[6] * distance)); // (-1, -1)
                depthDiag.y = Linear01Depth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv + offsets[0] * distance)); // (-1, 1)
                depthDiag.z = Linear01Depth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv + offsets[2] * distance));// (1, 1)
                depthDiag.w = Linear01Depth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv + offsets[8] * distance)); // (1, -1)

                depthAxial.x = Linear01Depth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv + offsets[3] * distance)); // (-1, 0)
                depthAxial.y = Linear01Depth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv + offsets[1] * distance)); // (0, 1)
                depthAxial.z = Linear01Depth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv + offsets[5] * distance)); // (1, 0)
                depthAxial.w = Linear01Depth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv + offsets[7] * distance)); // (0, -1)

                float centerDepth = Linear01Depth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv));

                depthDiag /= centerDepth;
                depthAxial -= centerDepth;

                float4 sobelHorizontal = horizontalDiagCoef * depthDiag + horizontalAxialCoef * depthAxial;
                float4 sobelVertical = verticalDiagCoeff * depthDiag + verticalAxialCoef * depthAxial;

                float sobelH = dot(sobelHorizontal, float4(1, 1, 1, 1));
                float sobelV = dot(sobelVertical, float4(1, 1, 1, 1));

                float sobel = sqrt(sobelH * sobelH + sobelV * sobelV);
                sobel = 1.0 - pow(saturate(sobel), _Exponent);
                float4 color = tex2D(_MainTex, i.uv.xy);
                color = _EdgeColor * color * (1 - sobel) + sobel;
                color = color * lerp(tex2D(_MainTex, i.uv.xy), _TestColor, _BgFade);

                return color;

            }
            ENDCG
        }
    }
}

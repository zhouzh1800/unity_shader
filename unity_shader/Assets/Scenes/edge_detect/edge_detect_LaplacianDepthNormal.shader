Shader "custom/edge_detect/LaplacianDepthNormal"
{
Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        _TestColor("Test color", Color) = (1, 1, 1, 1) // For Testing, Mask the background color
        _EdgeColor("_EdgeColor", Color) = (0, 0, 0, 0)
        _Threshold("_Threshold", Range(0, 10)) = 2
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

            float4 GetPixelValue(in float2 uv)
            {
                half3 normal;
                float depth;
                DecodeDepthNormal(tex2D(_CameraDepthNormalsTexture, uv), depth, normal);
                return fixed4(normal, depth);
            }

            float4 fragColor(v2f i) : COLOR
            {        
                float4 col = tex2D(_MainTex, i.uv);
                float4 orValue = GetPixelValue(i.uv);
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

                float4 sampledValue = float4(0, 0, 0, 0);
                float3x3 laplacianOperator = float3x3(
                    0, 1, 0,
                    1, -4, 1,
                    0, 1, 0
                    );
                float2 sampleDist = _MainTex_TexelSize * _SampleDistance;
                for (int m = 0; m < 3; m++)
                    for (int n = 0; n < 3; n++)
                    {
                        sampledValue += GetPixelValue(i.uv + offsets[m * 3 + n] * sampleDist) * laplacianOperator[m][n];
                    }
                col = lerp(float4(1, 1, 1, 1), _EdgeColor, 1.0f - saturate(_Threshold - length(orValue - sampledValue)));
                col = col * lerp(tex2D(_MainTex, i.uv), _TestColor, _BgFade);

                return col;
            }
            ENDCG
        }
    }
}

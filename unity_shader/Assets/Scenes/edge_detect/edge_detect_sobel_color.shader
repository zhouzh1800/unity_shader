Shader "custom/edge_detect/sobel_color"
{
Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        _TestColor("Test color", Color) = (1, 1, 1, 1) // For Testing, Mask the background color
        _EdgeColor("_EdgeColor", Color) = (0, 0, 0, 0)
        _Threshold("_Threshold", Range(0, 1)) = 0.5
        _BgFade("_BgFade", Range(0, 1)) = 0
        _SampleDistance("_SampleDistance", Range(1, 100)) = 1
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
                        // Sample surrounding 9 pixels
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

                float3x3 sobelHorizontal = float3x3(
                    -1, 0, 1,
                    -2, 0, 2,
                    -1, 0, 1
                    );
                float3x3 sobelVertical = float3x3(
                    -1, -2, -1,
                    0, 0, 0,
                    1, 2, 1
                    );
                float4 sobelH = float4(0, 0, 0, 0);
                float4 sobelV = float4(0, 0, 0, 0);
                float2 adjacentPixel = _MainTex_TexelSize.xy * _SampleDistance;
                for (int m = 0; m < 3; m++)
                    for (int n = 0; n < 3; n++)
                    {
                        sobelH += tex2D(_MainTex, i.uv + offsets[m * 3 + n] * adjacentPixel) * sobelHorizontal[m][n];
                        sobelV += tex2D(_MainTex, i.uv + offsets[m * 3 + n] * adjacentPixel) * sobelVertical[m][n];
                    }

                float sobel = sqrt(sobelH * sobelH + sobelV * sobelV);
                        // Above steps calculate sobel result of color

                float4 sceneColor = tex2D(_MainTex, i.uv);
                // Get edge value based on sobel value and threshold
                float edgeMask = saturate(lerp(0.0f, sobel, _Threshold));
                float3 EdgeMaskColor = float3(edgeMask, edgeMask, edgeMask);
                sceneColor = lerp(sceneColor, _TestColor, _BgFade);

                float3 finalColor = saturate((EdgeMaskColor * _EdgeColor.rgb) + (sceneColor.rgb - EdgeMaskColor));
                return float4(finalColor, 1);

            }
            ENDCG
        }
    }
}

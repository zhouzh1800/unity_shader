Shader "custom/cartoon/cartoon1" {
    Properties {
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _Bump ("Bump", 2D) = "bump" {}
        _Tooniness ("Tooniness", Range(0.1,20)) = 4
    }
    SubShader {
        Tags { "RenderType"="Opaque" }
        LOD 200
 
        CGPROGRAM
        #pragma surface surf Lambert finalcolor:final
 
        sampler2D _MainTex;
        sampler2D _Bump;
        float _Tooniness;
 
        struct Input {
            float2 uv_MainTex;
            float2 uv_Bump;
        };
 
        void surf (Input IN, inout SurfaceOutput o) {
            half4 c = tex2D (_MainTex, IN.uv_MainTex);
            o.Normal = UnpackNormal( tex2D(_Bump, IN.uv_Bump));
            o.Albedo = c.rgb;
            o.Alpha = c.a;
        }
 
        void final(Input IN, SurfaceOutput o, inout fixed4 color) {
            color = floor(color * _Tooniness)/_Tooniness;
        }
 
        ENDCG
    } 
    FallBack "Diffuse"
}
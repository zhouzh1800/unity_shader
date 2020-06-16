Shader "custom/cartoon/cartoon3" {
    Properties {
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _Bump ("Bump", 2D) = "bump" {}
        _Ramp ("Ramp Texture", 2D) = "white" {}
        _Tooniness ("Tooniness", Range(0.1,20)) = 4
    }
    SubShader {
        Tags { "RenderType"="Opaque" }
        LOD 200
 
        CGPROGRAM
        #pragma surface surf Toon
 
        sampler2D _MainTex;
        sampler2D _Bump;
        sampler2D _Ramp;
        float _Tooniness;
        float _Outline;
 
        struct Input {
            float2 uv_MainTex;
            float2 uv_Bump;
        };
 
        void surf (Input IN, inout SurfaceOutput o) {
            half4 c = tex2D (_MainTex, IN.uv_MainTex);
            o.Normal = UnpackNormal( tex2D(_Bump, IN.uv_Bump));
            //o.Albedo = (floor(c.rgb * _Tooniness)/_Tooniness);
            o.Albedo = c.rgb;
            o.Alpha = c.a;
        }
 
        half4 LightingToon(SurfaceOutput s, fixed3 lightDir, half3 viewDir, fixed atten)
        {
            float difLight = dot (s.Normal, lightDir);
            //float dif_hLambert = difLight * 0.5 + 0.5; 
            float dif_hLambert = difLight;

            //float rimLight = dot (s.Normal, viewDir);  
            //float rim_hLambert = rimLight * 0.5 + 0.5; 
            
            float3 ramp = tex2D(_Ramp, float2(dif_hLambert, 0)).rgb;   
    
            float4 c;  
            c.rgb = s.Albedo * _LightColor0.rgb * ramp;
            c.a = s.Alpha;
            return c;
        }
 
        ENDCG
    } 
    FallBack "Diffuse"
}
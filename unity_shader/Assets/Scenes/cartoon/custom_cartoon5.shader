Shader "custom/cartoon/cartoon5" {
    Properties {
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _Bump ("Bump", 2D) = "bump" {}
        _Ramp ("Ramp Texture", 2D) = "white" {}
        _Tooniness ("Tooniness", Range(0.1,20)) = 4
        _Outline ("Outline", Range(0,1)) = 0.4
        _Amount ("Amount", Range(0,1)) = 0
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
            float3 viewDir;
        };
 
        void surf (Input IN, inout SurfaceOutput o) {
            half4 c = tex2D (_MainTex, IN.uv_MainTex);
            o.Normal = UnpackNormal( tex2D(_Bump, IN.uv_Bump));
            
            
            
            o.Albedo = c.rgb;
            o.Alpha = c.a;
        }
 
        half4 LightingToon(SurfaceOutput s, fixed3 lightDir, half3 viewDir, fixed atten)
        {
            float difLight = dot (s.Normal, lightDir);
            float dif_hLambert = difLight; 
            
            float rimLight = dot (s.Normal, viewDir);  
            float rim_hLambert = rimLight; 
            
            float3 ramp = tex2D(_Ramp, float2(rim_hLambert, dif_hLambert)).rgb;   
    
            float4 c;  
            c.rgb = s.Albedo * _LightColor0.rgb * ramp * 2;
            c.a = s.Alpha;
            return c;
        }
 
        ENDCG


        cull front

        CGPROGRAM
        #pragma surface surf Toon vertex:vert
 
        sampler2D _MainTex;
        sampler2D _Bump;
        sampler2D _Ramp;
        float _Tooniness;
        float _Outline;
 
        struct Input {
            float2 uv_MainTex;
            float2 uv_Bump;
            float3 viewDir;
        };

        float _Amount;
        void vert (inout appdata_full v) {
            v.vertex.xyz += v.normal * _Amount;
        }
 
        void surf (Input IN, inout SurfaceOutput o) {
        }
 
        half4 LightingToon(SurfaceOutput s, fixed3 lightDir, half3 viewDir, fixed atten)
        {
            return half4(0, 0, 0, 0);
        }
 
        ENDCG
        
    } 
    FallBack "Diffuse"
}
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "custom/cartoon/extendVertexByProjectionSpaceVertex" {
    Properties {
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _Bump ("Bump", 2D) = "bump" {}
        _Ramp ("Ramp Texture", 2D) = "white" {}
        _Tooniness ("Tooniness", Range(0.1,20)) = 4
        _Outline ("Outline", Range(0,1)) = 0.1
        _OutlineColor ("OutlineColor", Color) = (1, 1, 1, 1)
    }
    SubShader {
        Tags { "RenderType"="Opaque" }
        LOD 200
        
        Pass {
            Tags { "LightMode"="ForwardBase" }
            
            Cull Back 
            Lighting On
 
            CGPROGRAM
 
            #pragma vertex vert
            #pragma fragment frag
            
            #pragma multi_compile_fwdbase
 
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"
            #include "UnityShaderVariables.cginc"
 
            sampler2D _MainTex;
            sampler2D _Bump;
            sampler2D _Ramp;
 
            float4 _MainTex_ST;
            float4 _Bump_ST;
 
            float _Tooniness;
 
            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 texcoord : TEXCOORD0;
                float4 tangent : TANGENT;
            }; 
 
            struct v2f
            {
                float4 pos : POSITION;
                float2 uv : TEXCOORD0;
                float2 uv2 : TEXCOORD1;
                float3 lightDirection : TEXCOORD2;
                LIGHTING_COORDS(3,4)
            };
            
            v2f vert (a2v v)
            {
                v2f o;
                //Create a rotation matrix for tangent space
                TANGENT_SPACE_ROTATION; 
                //Store the light's direction in tangent space
                o.lightDirection = mul(rotation, ObjSpaceLightDir(v.vertex));
                //Transform the vertex to projection space
                o.pos = UnityObjectToClipPos( v.vertex); 
                //Get the UV coordinates
                o.uv = TRANSFORM_TEX (v.texcoord, _MainTex);  
                o.uv2 = TRANSFORM_TEX (v.texcoord, _Bump);
                
                // pass lighting information to pixel shader
                TRANSFER_VERTEX_TO_FRAGMENT(o);
                return o;
            }
            
            float4 frag(v2f i) : COLOR  
            { 
                //Get the color of the pixel from the texture
                float4 c = tex2D (_MainTex, i.uv);  
                //Merge the colours
                c.rgb = (floor(c.rgb*_Tooniness)/_Tooniness);
 
                //Get the normal from the bump map
                float3 n =  UnpackNormal(tex2D (_Bump, i.uv2)); 
 
                //Based on the ambient light
                float3 lightColor = UNITY_LIGHTMODEL_AMBIENT.xyz;
 
                //Work out this distance of the light
                float atten = LIGHT_ATTENUATION(i);
                //Angle to the light
                float diff = saturate (dot (n, normalize(i.lightDirection)));  
                //Perform our toon light mapping 
                diff = tex2D(_Ramp, float2(diff, 0.5));
                //Update the colour
                lightColor += _LightColor0.rgb * (diff * atten); 
                //Product the final color
                c.rgb = lightColor * c.rgb * 2;
                return c; 
 
            } 
 
            ENDCG
        }
        Pass {
            Tags { "LightMode"="ForwardBase" }
            
            Cull Front
            Lighting Off
            ZWrite On
 
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            fixed _Outline;
            fixed4 _OutlineColor;

            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 uv : TEXCOORD0;
            };

            v2f vert (appdata_full v)
            {
                v2f o;

                //位置从自身坐标系转换到投影空间
                //旧版本o.pos = mul(UNITY_MATRIX_MVP,v.vertex);
                o.pos = UnityObjectToClipPos(v.vertex);

                //方式二，扩张顶点位置
                //法线变换到投影空间
                //float3 normal = mul((float3x3)UNITY_MATRIX_IT_MV, v.normal);
                //得到投影空间的偏移
                //float2 offset = TransformViewToProjection(normal.xy);

                ////方式三，把顶点当做方向矢量，在方向矢量的方向偏移
                float3 dir = normalize(v.vertex.xyz);
                dir = mul((float3x3)UNITY_MATRIX_IT_MV, dir);
                //dir = mul ((float3x3)UNITY_MATRIX_IT_MV, v.normal);
                float2 offset = TransformViewToProjection(dir.xy);
                offset = normalize(offset);
                

                //有一些情况下，侧边看不到，所以把方式一和二的算法相结合
                //float3 dir = normalize(v.vertex.xyz);
                //float3 dir2 = v.normal;
                //float D = dot(dir, dir2);
                //D = (1 + D / _Outline) / (1 + 1 / _Outline);
                //dir = lerp(dir2, dir, D);
                //dir = mul((float3x3)UNITY_MATRIX_IT_MV, dir);
                //float2 offset = TransformViewToProjection(dir.xy);
                //offset = normalize(offset);

                

                //在xy两个方向上偏移顶点的位置
                o.pos.xy += offset * o.pos.z * _Outline;
                //o.pos.xy += offset * o.pos.w * _Outline;
                //o.pos.xy += offset * _Outline;

                return o;
            }
            
            float4 frag (v2f i) : COLOR
            {
                return _OutlineColor; //描边
            }
 
            ENDCG
        }
        
        
        Pass {
            Tags { "LightMode"="ForwardAdd" }
            
            Cull Back 
            Lighting On
            Blend One One
 
            CGPROGRAM
 
            #pragma vertex vert
            #pragma fragment frag
            
            #pragma multi_compile_fwdadd
 
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"
            #include "UnityShaderVariables.cginc"
 
            sampler2D _MainTex;
            sampler2D _Bump;
            sampler2D _Ramp;
 
            float4 _MainTex_ST;
            float4 _Bump_ST;
 
            float _Tooniness;
 
            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 texcoord : TEXCOORD0;
                float4 tangent : TANGENT;
            }; 
 
            struct v2f
            {
                float4 pos : POSITION;
                float2 uv : TEXCOORD0;
                float2 uv2 : TEXCOORD1;
                float3 lightDirection : TEXCOORD2;
                LIGHTING_COORDS(3,4)
            };
            
            v2f vert (a2v v)
            {
                v2f o;
                //Create a rotation matrix for tangent space
                TANGENT_SPACE_ROTATION; 
                //Store the light's direction in tangent space
                o.lightDirection = mul(rotation, ObjSpaceLightDir(v.vertex));
                //Transform the vertex to projection space
                o.pos = UnityObjectToClipPos( v.vertex); 
                //Get the UV coordinates
                o.uv = TRANSFORM_TEX (v.texcoord, _MainTex);  
                o.uv2 = TRANSFORM_TEX (v.texcoord, _Bump);
                
                // pass lighting information to pixel shader
                TRANSFER_VERTEX_TO_FRAGMENT(o);
                
                return o;
            }
            
            float4 frag(v2f i) : COLOR  
            { 
                //Get the color of the pixel from the texture
                float4 c = tex2D (_MainTex, i.uv);  
                //Merge the colours
                c.rgb = (floor(c.rgb*_Tooniness)/_Tooniness);
 
                //Get the normal from the bump map
                float3 n =  UnpackNormal(tex2D (_Bump, i.uv2)); 
 
                //Based on the ambient light
                float3 lightColor = float3(0, 0, 0);
 
                //Work out this distance of the light
                float atten = LIGHT_ATTENUATION(i);
                //Angle to the light
                float diff = saturate (dot (n, normalize(i.lightDirection)));  
                //Perform our toon light mapping 
                diff = tex2D(_Ramp, float2(diff, 0.5));
                //Update the colour
                lightColor += _LightColor0.rgb * (diff * atten); 
                //Product the final color
                c.rgb = lightColor * c.rgb * 2;
                return c; 
 
            } 
 
            ENDCG
        }
    }
    FallBack "Diffuse"      
}
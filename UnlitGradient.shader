Shader "Custom/Unlit Gradient"
{
    Properties
    {
        _Color1 ("Color 1", Color) = (1,0,0,1)
        _Color2 ("Color 2", Color) = (0,1,0,1)
        _Color3 ("Color 3", Color) = (0,0,1,1)
        _Speed ("Scrolling speed", Float) = 5
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            // Make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            // Variables
            fixed4 _Color1;
            fixed4 _Color2;
            fixed4 _Color3;
            float _Speed;

            // Structs
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };


            // Vertex program
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }


            // Pixel program
            fixed4 frag (v2f i) : SV_Target
            {
                // Offset UV based on time, wrap around using frac.
                i.uv.y = frac(i.uv.y + _Time.x * _Speed);

                // Smoothly step between 0 and 1.
                float gradientPosition = i.uv.y;

                // Gradient blend steps:
                float step1 = 0.0;
                float step2 = 0.33;
                float step3 = 0.66;
                float step4 = 1.0;

                // Blend colors to a gradient.
                float4 color = lerp(_Color1, _Color2, smoothstep(step1, step2, gradientPosition));
                       color = lerp( color,  _Color3, smoothstep(step2, step3, gradientPosition));
                       color = lerp( color,  _Color1, smoothstep(step3, step4, gradientPosition));

                // Apply fog.
                UNITY_APPLY_FOG(i.fogCoord, color);

                return color;
            }
            ENDCG
        }
    }
}

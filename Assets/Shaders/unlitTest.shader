//Directory of the shader
Shader "Deformation/unlitTest"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Color("Color", Color) = (1,1,1,1)
	}
	SubShader
	{
		//Rendering order of the shader (Because transparency has to come last, etc.)
		Tags { "RenderType"="Opaque" }
		LOD 100
			
			Pass
			{
				// indicate that our pass is the "base" pass in forward
				// rendering pipeline. It gets ambient and main directional
				// light data set up; light direction in _WorldSpaceLightPos0
				// and color in _LightColor0
				Tags{"LightMode" = "ForwardBase"}

				//Code starts at CGPROGRAM
				CGPROGRAM
	#pragma vertex vert
	#pragma fragment frag
				// make fog work
	#pragma multi_compile_fog

				//Allows methods to easily transfer world coordinates to screen, etc
	#include "UnityCG.cginc"
				//For _LightColor0
	#include "UnityLightingCommon.cginc" 

				struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
				float4 color : COLOR;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				fixed4 diff : COLOR0;
				UNITY_FOG_COORDS(1)
					float4 vertex : SV_POSITION;
			};


			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed4 _Color;

			v2f vert(appdata v) {
				v2f o;
				//Use v.vertex instead of o.vertex because o.vertex has already been modified
				float3 worldPos = mul(unity_ObjectToWorld , v.vertex);
				//Take the coordinates in object space, and match to screen space
				o.vertex = UnityObjectToClipPos(v.vertex);
				//Makes object oscilate with time on the y
				//o.vertex.y -= _SinTime.w;
				//Makes object vertex oscillate according to world position
				o.vertex.y += sin(worldPos.z + worldPos.x + _Time.w) * 2;

				// get vertex normal in world space
				half3 worldNormal = UnityObjectToWorldNormal(v.normal);
				// dot product between normal and light direction for
				// standard diffuse (Lambert) lighting
				half nl = max(0 , dot(worldNormal , _WorldSpaceLightPos0.xyz));
				// factor in the light color
				o.diff = nl * _LightColor0;
				// in addition to the diffuse lighting from the main light,
				// add illumination from ambient or light probes
				// ShadeSH9 function from UnityCG.cginc evaluates it,
				// using world space normal
				o.diff.rgb += ShadeSH9(half4(worldNormal , 1));

				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
			//Only render the plain color
			//float4 col = _Color;
			// apply fog
			UNITY_APPLY_FOG(i.fogCoord, col);
			// multiply by lighting
			col *= i.diff;
			return col;
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
}

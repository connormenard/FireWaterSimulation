Shader "Custom/New Water"
{
	Properties
	{
		_WaveScale("Wave scale", Range(0.02,0.15)) = 0.063
		_ReflDistort("Reflection distort", Range(0,1.5)) = 0.44
		_RefrDistort("Refraction distort", Range(0,1.5)) = 0.40
		_RefrColor("Refraction color", COLOR) = (.34, .85, .92, 1)
		[NoScaleOffset] _Fresnel("Fresnel (A) ", 2D) = "gray" {}
		[NoScaleOffset] _BumpMap("Normalmap ", 2D) = "bump" {}
		WaveSpeed("Wave speed (map1 x,y; map2 x,y)", Vector) = (19,9,-16,-7)
		[NoScaleOffset] _ReflectiveColor("Reflective color (RGB) fresnel (A) ", 2D) = "" {}
		_HorizonColor("Simple water horizon color", COLOR) = (.172, .463, .435, 1)
	}
	SubShader
	{
		Tags{"WaterMode" = "Refractive" "RenderType" = "Opaque"}

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag			
			#include "UnityCG.cginc"

			uniform float4 _WaveScale4;
			uniform float4 _WaveOffset;
			uniform float _ReflDistort;

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float4 ref : TEXCOORD0;
				float2 bumpuv0 : TEXCOORD1;
				float2 bumpuv1 : TEXCOORD2;
				float3 viewDir : TEXCOORD3;
			};
			
			v2f vert (appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				// scroll bump waves
				float4 temp;
				float4 wpos = mul(unity_ObjectToWorld , v.vertex);
				temp.xyzw = wpos.xzxz * _WaveScale4 + _WaveOffset;
				o.bumpuv0 = temp.xy;
				o.bumpuv1 = temp.wz;
				// object space view direction (will normalize per pixel)
				o.viewDir.xzy = WorldSpaceViewDir(v.vertex);
				return o;
			}
			
			sampler2D _ReflectionTex;
			sampler2D _ReflectiveColor;
			sampler2D _BumpMap;

			half4 frag (v2f i) : SV_Target
			{
			i.viewDir = normalize(i.viewDir);

			// combine two scrolling bumpmaps into one
			half3 bump1 = UnpackNormal(tex2D(_BumpMap, i.bumpuv0)).rgb;
			half3 bump2 = UnpackNormal(tex2D(_BumpMap, i.bumpuv1)).rgb;
			half3 bump = (bump1 + bump2) * 0.5;

			// fresnel factor
			half fresnelFac = dot(i.viewDir, bump);

			// perturb reflection/refraction UVs by bumpmap, and lookup colors
			float4 uv1 = i.ref; uv1.xy += bump * _ReflDistort;
			half4 refl = tex2Dproj(_ReflectionTex, UNITY_PROJ_COORD(uv1));

			// final color is between refracted and reflected based on fresnel
			half4 color;

			half4 water = tex2D(_ReflectiveColor, float2(fresnelFac,fresnelFac));
			color.rgb = lerp(water.rgb, refl.rgb, water.a);
			color.a = refl.a * water.a;

			return color;
			}
			ENDCG
		}
	}
}

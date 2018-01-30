//After much trial and tribulation, this site ended up helping me the most:
//http://diary.conewars.com/vertex-displacement-shader/
//In particular the bit explaining how to run a vertex shader with a surface one really helped

Shader "Custom/Water Final" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
		_Speed("Speed",Range(0.1,4)) = 1
		_Amount("Amount", Range(0.1,10)) = 3
		_Distance("Distance", Range( 0, 2 )) = 0.3
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		//This convenient line tells Unity to use the 'surf' function as a surface shader,
		//to use the standard lighting model to save lots and lots of work, and to
		//use the 'vert' function as the vertex shader
		#pragma surface surf Standard vertex:vert

		#pragma target 3.0

		//Albedo texture sampler
		sampler2D _MainTex;

		//You can't rename this one - it's a Unity default,
		//used for surface shaders
		struct Input {
			float2 uv_MainTex;
		};

		//Vars from above
		half _Glossiness;
		half _Metallic;
		fixed4 _Color;
		half _Speed;
		half _Amount;
		half _Distance;

		//Makes a vertex all wavy as a function of world position and time
		float4 WaveVertex(float4 v)
		{
			//Get world position
			float4 posWorld = mul(unity_ObjectToWorld , v);
			//Do math
			v.y += sin(_Distance * posWorld.z - (posWorld.x * _Amount) + _Time.y * _Speed) * _Distance;
			//Return result
			return v;
		}

		//Vertex shader
		//appdata_full is a built-in Unity struct
		void vert(inout appdata_full v)
		{
			//Update position
			float4 vertPosition = WaveVertex(v.vertex);

			//--These next calculations (and comments) are thanks to the site referenced above--
			// calculate the bitangent (sometimes called binormal) from the cross product of the normal and the tangent
			float4 bitangent = float4( cross( v.normal, v.tangent ), 0 );
			// how far we want to offset our vert position to calculate the new normal
			float vertOffset = 0.01;
			// now we can create new tangents and bitangents based on the deformed positions
			float4 newTangent = WaveVertex(v.vertex + v.tangent * vertOffset) - vertPosition;
			float4 newBitangent = WaveVertex(v.vertex + bitangent * vertOffset) - vertPosition;
			// recalculate the normal based on the new tangent & bitangent
			v.normal = cross( newTangent, newBitangent );

			//Finally set position
			v.vertex = vertPosition;
		}

		//Surface shader, a unique Unity thing
		//SurfaceOutputStandard is also a Unity default
		void surf (Input IN, inout SurfaceOutputStandard o) {
			//Sample texture to get color
			fixed4 col = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			//Assign to output albedo and alpha
			o.Albedo = col.rgb;
			o.Alpha = col.a;
			//Metallic and Smoothness are assigned in the inspector
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
		}
		ENDCG
	}
	FallBack "Diffuse"
}

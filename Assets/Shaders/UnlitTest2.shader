//This is the shader used for the demo in the day of the final presentation.
//It is mostly uncommented and is not that great.
//It also contains the code used for the old midterm presentation demo.

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'
Shader "Custom/UnlitTest2"
{
	Properties
	{
			//Unity defaults
			_Color("Color", Color) = (1,1,1,1)
			_MainTex("Albedo", 2D) = "white" {}

		_Cutoff("Alpha Cutoff", Range(0.0, 1.0)) = 0.5

			_Glossiness("Smoothness", Range(0.0, 1.0)) = 0.5
			_GlossMapScale("Smoothness Scale", Range(0.0, 1.0)) = 1.0
			[Enum(Metallic Alpha,0,Albedo Alpha,1)] _SmoothnessTextureChannel("Smoothness texture channel", Float) = 0

			[Gamma] _Metallic("Metallic", Range(0.0, 1.0)) = 0.0
			_MetallicGlossMap("Metallic", 2D) = "white" {}

		[ToggleOff] _SpecularHighlights("Specular Highlights", Float) = 1.0
			[ToggleOff] _GlossyReflections("Glossy Reflections", Float) = 1.0

			_BumpScale("Scale", Float) = 1.0
			_BumpMap("Normal Map", 2D) = "bump" {}
			_BumpMap2("Normal Map 2", 2D) = "bump" {}

		_Parallax("Height Scale", Range(0.005, 0.08)) = 0.02
			_ParallaxMap("Height Map", 2D) = "black" {}

		_OcclusionStrength("Strength", Range(0.0, 1.0)) = 1.0
			_OcclusionMap("Occlusion", 2D) = "white" {}

		_EmissionColor("Color", Color) = (0,0,0)
			_EmissionMap("Emission", 2D) = "white" {}

		_DetailMask("Detail Mask", 2D) = "white" {}

		_DetailAlbedoMap("Detail Albedo x2", 2D) = "grey" {}
		_DetailNormalMapScale("Scale", Float) = 1.0
			_DetailNormalMap("Normal Map", 2D) = "bump" {}

		[Enum(UV0,0,UV1,1)] _UVSec("UV Set for secondary textures", Float) = 0
	}
	SubShader
	{
			//Old stuff... not necessary
			//Tags{"RenderType" = "Opaque"}
			//LOD 100

			Pass	
			{
				//Basically gets light direction in _WorldSpaceLightPos0 and color in _LightColor0
				Tags{"LightMode" = "ForwardBase"}

				//More old stuff, these also aren't necessary
				//Blend[_SrcBlend][_DstBlend]
				//ZWrite[_ZWrite]

				CGPROGRAM
				#pragma target 3.0
				//Allows methods to easily transfer world coordinates to screen, etc
				#include "UnityCG.cginc"
				//For _LightColor0, which is the main light of the scene
				#include "UnityLightingCommon.cginc" 

				//Tell unity what the name of our shader functions are
				#pragma vertex vert
				#pragma fragment frag

				//For getting all the built in default shader stuff
				#include "UnityStandardCoreForward.cginc"

				//These structs match the ones that Unity devs made
				//since I'll be using parts of their shader code
				struct VertInput
				{
					float4 pos : POSITION;
					float2 uv : TEXCOORD0;
					float3 normal : NORMAL;
					float4 tangent : TANGENT;
					float4 color : COLOR;
				};
				struct VertOutput
				{
					float4 pos:SV_POSITION;
					float3 worldPos:POSITION1;
					float2 uv : TEXCOORD0;
					fixed4 diff : COLOR0;
				};

				VertexOutputForwardBase vert(VertexInput v) {
					UNITY_SETUP_INSTANCE_ID(v);
					v.uv0.x = 0;
					v.uv0.y = 0;
					VertexOutputForwardBase o;
					UNITY_INITIALIZE_OUTPUT(VertexOutputForwardBase , o);
					UNITY_TRANSFER_INSTANCE_ID(v , o);
					UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

					float4 posWorld = mul(unity_ObjectToWorld , v.vertex);
					
					#if UNITY_REQUIRE_FRAG_WORLDPOS
						#if UNITY_PACK_WORLDPOS_WITH_TANGENT
							o.tangentToWorldAndPackedData[0].w = posWorld.x;
							o.tangentToWorldAndPackedData[1].w = posWorld.y;
							o.tangentToWorldAndPackedData[2].w = posWorld.z;
						#else
							o.posWorld = posWorld.xyz;
						#endif
					#endif
					
					o.pos = UnityObjectToClipPos(v.vertex);
					//Oscilate according to world position
					o.pos.y += sin(1.2 * posWorld.z - (posWorld.x*22) + _Time.w) * 1.2f;

					o.tex = TexCoords(v);
					o.eyeVec = NormalizePerVertexNormal(posWorld.xyz - _WorldSpaceCameraPos);
					float3 normalWorld = UnityObjectToWorldNormal(v.normal);

					#ifdef _TANGENT_TO_WORLD
						float4 tangentWorld = float4(UnityObjectToWorldDir(v.tangent.xyz) , v.tangent.w);

						float3x3 tangentToWorld = CreateTangentToWorldPerVertex(normalWorld , tangentWorld.xyz , tangentWorld.w);
						o.tangentToWorldAndPackedData[0].xyz = tangentToWorld[0];
						o.tangentToWorldAndPackedData[1].xyz = tangentToWorld[1];
						o.tangentToWorldAndPackedData[2].xyz = tangentToWorld[2];
					#else
						o.tangentToWorldAndPackedData[0].xyz = 0;
						o.tangentToWorldAndPackedData[1].xyz = 0;
						o.tangentToWorldAndPackedData[2].xyz = normalWorld;
					#endif

					//We need this for shadow receving
					UNITY_TRANSFER_SHADOW(o , v.uv1);

					o.ambientOrLightmapUV = VertexGIForward(v , posWorld , normalWorld);

					#ifdef _PARALLAXMAP
						TANGENT_SPACE_ROTATION;
						half3 viewDirForParallax = mul(rotation , ObjSpaceViewDir(v.vertex));
						o.tangentToWorldAndPackedData[0].w = viewDirForParallax.x;
						o.tangentToWorldAndPackedData[1].w = viewDirForParallax.y;
						o.tangentToWorldAndPackedData[2].w = viewDirForParallax.z;
					#endif

					UNITY_TRANSFER_FOG(o , o.pos);
					return o;
					////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
					///Old
					///
					///Assumes using (VertInput v) and returning (VertOutput o)
					////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
					/*
					VertOutput o;
					//Use v.vertex instead of o.vertex because o.vertex has already been modified
					o.worldPos = mul(unity_ObjectToWorld , v.pos).xyz;
					//Take the coordinates in object space, and match to screen space
					o.pos = UnityObjectToClipPos(v.pos);
					//Makes object oscilate with time on the y
					//o.vertex.y -= _SinTime.w;
					//Makes object vertex oscillate according to world position
					o.pos.y += sin(o.worldPos.z + o.worldPos.x + _Time.w) * 2;

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

					o.uv = TRANSFORM_TEX(v.uv , _MainTex);

					return o;
					*/
					////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
				}

				half4 frag(VertexOutputForwardBase i) : SV_TARGET {
					UNITY_APPLY_DITHER_CROSSFADE(i.pos.xy);

					FRAGMENT_SETUP(s)

						UNITY_SETUP_INSTANCE_ID(i);
					UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);

					UnityLight mainLight = MainLight();
					UNITY_LIGHT_ATTENUATION(atten , i , s.posWorld);

					half occlusion = Occlusion(i.tex.xy);
					UnityGI gi = FragmentGI(s , occlusion , i.ambientOrLightmapUV , atten , mainLight);

					half4 c = UNITY_BRDF_PBS(s.diffColor , s.specColor , s.oneMinusReflectivity , s.smoothness , s.normalWorld , -s.eyeVec , gi.light , gi.indirect);
					c.rgb += Emission(i.tex.xy);

					UNITY_APPLY_FOG(i.fogCoord , c.rgb);
					return OutputForward(c , s.alpha);
				}

				//////////
				//Old frag shader
				//////////
				/*
				half4 frag(VertOutput i) : COLOR{
					//Sample the texture
					half4 col = tex2D(_MainTex, i.uv);
					//Multiply by diffuse lighting
					col *= i.diff;
					//Need to also consider alpha
					return half4(col.x , col.y , col.z * (i.worldPos.z - (floor(i.worldPos.z) / 2.0f)) , 1.0f);
				}*/
				ENDCG
			}
	}
	Fallback "Diffuse"
}

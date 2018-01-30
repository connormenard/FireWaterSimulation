//Relatively basic shader just to get something to render
//after we calculate things on the GPU
Shader "Custom/fire"
{
	Properties
	{
		//Particle colors based on speed
		_ColorLow("Color Slow Speed", Color) = (0, 0, 0.5, 0.3)
		_ColorHigh("Color High Speed", Color) = (1, 0, 0, 0.3)
		_HighSpeedValue("High speed Value", Range(0, 5)) = 0.5
	}

	SubShader
	{
		Pass
		{
			Blend SrcAlpha one
			CGPROGRAM
			//Render target
			#pragma target 5.0
			//Tell Unity the function name of the vert/frag shaders
			#pragma vertex vert
			#pragma fragment frag
			//Contains a bunch of helpful stuff
			#include "UnityCG.cginc"

			//Struct to match the one C# side
			struct Particle
			{
				float3 position;
				float3 velocity;
				float3 startPosition;
				float3 startVelocity;
				float3 prevPosition;
				float startTime;
			};

			//Middleman between vertex and pixel shader
			struct vertexToPixel
			{
				float4 position : SV_POSITION;
				float4 color : COLOR;
			};

			//Data to match the one in the compute shader
			StructuredBuffer<Particle> particleBuffer;

			//Properties as listed above
			uniform float4 _ColorLow;
			uniform float4 _ColorHigh;
			uniform float _HighSpeedValue;

			//Vertex shader
			vertexToPixel vert(uint vertex_id : SV_VertexID, uint instance_id : SV_InstanceID) 
			{
				//output variable
				vertexToPixel o;// = (vertexToPixel)0;
				//Lerp color based on speed
				float speed = length(particleBuffer[instance_id].velocity);
				float lerpValue = clamp(speed / _HighSpeedValue, 0.0f, 1.0f);
				o.color = lerp(_ColorLow , _ColorHigh , lerpValue);
				//Use this handy dandy function to determine correct position
				o.position = UnityObjectToClipPos(float4(particleBuffer[instance_id].position, 1.0f));
				//Return the output var
				return o;
			}

			//Pixel shader
			float4 frag(vertexToPixel i) : COLOR
			{
				//Just return the color
				return i.color;
				//Perhaps find some way to get the prev position here? (See FireParticleSystem.cs)
			}

			ENDCG
		}
	}
	Fallback Off
}

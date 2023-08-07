//=========================================================================================================================
// Optional
//=========================================================================================================================
HEADER
{
	Description = "Minecraft Shader for S&box";
}

//=========================================================================================================================
// Optional
//=========================================================================================================================
FEATURES
{
    #include "common/features.hlsl"
}

//=========================================================================================================================
COMMON
{ 

	#include "common/shared.hlsl"

}

//=========================================================================================================================

struct VertexInput
{
	#include "common/vertexinput.hlsl"
};

//=========================================================================================================================

struct PixelInput
{
	#include "common/pixelinput.hlsl"
};

//=========================================================================================================================

VS
{
	#include "common/vertex.hlsl" 
	//
	// Main
	//
	PixelInput MainVs( INSTANCED_SHADER_PARAMS( VertexInput i ) )
	{
		PixelInput o = ProcessVertex( i );
		// Add your vertex manipulation functions here
		return FinalizeVertex( o );
	}
}

//=========================================================================================================================

PS
{     
	SamplerState TextureFiltering < Filter(NEAREST); MaxAniso(8); > ; 
	#define CUSTOM_TEXTURE_FILTERING

	#include "common/pixel.hlsl" 
	CreateInputTexture2D(TextureColorA, Srgb, 8, "", "_color", "Material,10/10", Default3(1.0, 1.0, 1.0));
 	CreateTexture2DWithoutSampler(g_tColorA) < Channel(RGB, AlphaWeighted(TextureColorA, TextureTranslucency), Srgb); Channel(A, Box(TextureTranslucency), Linear); OutputFormat(BC7); SrgbRead(true); > ;
	    
	//
	// Main
	//
	float4 MainPs( PixelInput i ) : SV_Target0
	{   
		float2 vUV = i.vTextureCoords.xy;
		float4 vColor = Tex2DS( g_tColorA, TextureFiltering, vUV  ); 

		float4 shaded = float4(0,0,0,0);
		shaded += vColor * abs(i.vNormalWs.x * 0.3f); 
		shaded += vColor * abs(i.vNormalWs.y * 0.6f); 
		if (i.vNormalWs.z < 0) {
			shaded += vColor * abs(i.vNormalWs.z * 0.2f);
		}
		else {
			shaded += vColor * abs(i.vNormalWs.z * 1);
		}
 
		float3 lightshade = float3(0,0,0);
		
		//PixelInput b = i;

		// for ( uint indexnear = 0; indexnear < 16; indexnear++ ) 
		// {
		// 	PixelInput b = i;
		// 	b.vPositionWithOffsetWs += float3(40*indexnear,0,0); 
		// 	for ( uint index2 = 0; index2 < StaticLight::Count( i ); index2++ )
		// 	{
		// 		Light light = StaticLight::From( b, index2 );
		// 		lightshade += (1* light.Attenuation);
		// 	}
		// }

		//	lightshade += (10 * length(lr.Diffuse));
		
		//
		// Shade direct lighting for dynamic lights
		//
		//for ( uint index = 0; index < StaticLight::Count( i ); index++ )
		//{
		//	Light light = StaticLight::From( i, index );
		//	lightshade += light.Color;// * dot( material.Normal, light.Direction );
		//}
		PixelInput b = i; 
		//b.vPositionWithOffsetWs = round(b.vPositionWithOffsetWs/40)*40;
		//b.vPositionWithOffsetWs += g_vCameraPositionWs;
		b.vPositionWithOffsetWs += float3(4,-10,20);
		b.vPositionWithOffsetWs += g_vCameraPositionWs;
		b.vPositionWithOffsetWs = round(b.vPositionWithOffsetWs/40)*40;
		b.vPositionWithOffsetWs -= g_vCameraPositionWs; 
		//b.vPositionWithOffsetWs -= round(g_vCameraPositionWs/40)*40;
		//b.vPositionWithOffsetWs -= round(g_vCameraPositionWs/40)*40;
		//b.vPositionWithOffsetWs += float3(20,20,20); 

		float dist = 12;
		for ( int indexnear = 0; indexnear < dist; indexnear++ ) 
		{
			PixelInput ba = b;
			ba.vPositionWithOffsetWs += float3(40*(indexnear-(dist/2)),0,0); 
			//
			// Shade direct lighting for dynamic lights
			//
			for ( uint index = 0; index < DynamicLight::Count( i ); index++ )
			{
				Light light = DynamicLight::From( ba, index );
				lightshade += (light.Color * light.Visibility) * light.Attenuation;// * dot( material.Normal, light.Direction );
			} 

			for ( int indexnear = 0; indexnear < dist; indexnear++ ) 
			{
				PixelInput bb = ba;
				bb.vPositionWithOffsetWs += float3(0,40*(indexnear-(dist/2)),0); 
				//
				// Shade direct lighting for dynamic lights
				//
				for ( uint index = 0; index < DynamicLight::Count( i ); index++ )
				{
					Light light = DynamicLight::From( bb, index );
					lightshade += (light.Color * light.Visibility) * light.Attenuation;// * dot( material.Normal, light.Direction );
				} 
			}
		}

		float direct = 0;
		for ( uint index = 0; index < DynamicLight::Count( i ); index++ )
		{
			Light light = DynamicLight::From( b, index );
			direct += (light.Color * light.Visibility) * light.Attenuation;// * dot( material.Normal, light.Direction );
		}
		lightshade /= (dist*dist);

		
		//Light light = EnvironmentMapLight::From( i, m, 1 );
		//lightshade += (1 * length(light.Color)/3);

		
			
		shaded.xyz *= (direct+lightshade)/2;
		//return float4(b.vPositionWithOffsetWs/8000,1);
		return float4(shaded.xyz,1);
	}
}

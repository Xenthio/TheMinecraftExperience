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
	
	#define USE_CUSTOM_SHADING
	 
	#ifndef PS_INPUT_HAS_PER_VERTEX_LIGHTING
	#define PS_INPUT_HAS_PER_VERTEX_LIGHTING 
	#endif 
	
	#undef D_BAKED_LIGHTING_FROM_LIGHTMAP 
	#undef D_BAKED_LIGHTING_FROM_VERTEX_STREAM 


	#ifdef D_BAKED_LIGHTING_FROM_PROBE
	#undef D_BAKED_LIGHTING_FROM_PROBE 
	#endif
 
	#define D_BAKED_LIGHTING_FROM_PROBE 1  

	#include "common/pixel.hlsl" 
	CreateInputTexture2D(TextureColorA, Srgb, 8, "", "_color", "Material,10/10", Default3(1.0, 1.0, 1.0));
 	CreateTexture2DWithoutSampler(g_tColorA) < Channel(RGB, AlphaWeighted(TextureColorA, TextureTranslucency), Srgb); Channel(A, Box(TextureTranslucency), Linear); OutputFormat(BC7); SrgbRead(true); > ;
	    
	//
	// Main
	//
	float4 MainPs( PixelInput i ) : SV_Target0
	{         
		Material m = Material::From( i );
		m.Normal = float3(0.5,0.5,1.0);
		m.Roughness = float3(1.0,1.0,1.0);
		m.Metalness = float3(0.0,0.0,0.0);
		float2 vUV = i.vTextureCoords.xy;
		float4 vColor = Tex2DS( g_tColorA, TextureFiltering, vUV  );
		m.Albedo = vColor.xyz;

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
		
		PixelInput b = i;

		b.vPositionWithOffsetWs += float3(0,0,0); 
		for ( uint index2 = 0; index2 < StaticLight::Count( b ); index2++ )
		{
			Light light = StaticLight::From( b, index2 );
			lightshade += (1* light.Attenuation);
		}

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
		
        //[unroll(NUM_CUBES)]
	    //for ( uint index3 = 0; index3 < 1; index3++ )
		//{
		//	Light light = EnvironmentMapLight::From( i, m, index3 );
		//	lightshade += (1 * length(light.Color)/3);
		//}

		
		//Light light = EnvironmentMapLight::From( i, m, 1 );
		//lightshade += (1 * length(light.Color)/3);

		
			
		shaded.xyz *= ((lightshade * 1 ) * 0.8f) + 1;
		return float4(shaded.xyz,1);
	}
}

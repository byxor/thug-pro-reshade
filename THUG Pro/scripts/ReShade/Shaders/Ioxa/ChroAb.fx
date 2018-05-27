
#include EFFECT_CONFIG(Ioxa)

#if USE_ChromaticAberration == 1
//Chromatic Aberration for ReShade + Framework by Ioxa
//Version 0.4

#pragma message "Chromatic Aberration by Ioxa\n"

#if USE_ChromaticAberration == 1

#define caBUFFER_WIDTH BUFFER_WIDTH*0.5
#define caBUFFER_HEIGHT BUFFER_HEIGHT*0.5

texture CAScale{ Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA8; };

sampler2D CAScaleSampler { Texture = CAScale; MinFilter = Linear; MagFilter = Linear; MipFilter = Linear; AddressU = Clamp; SRGBTexture = FALSE;};

#endif
	#define CoefLuma_CA float3(0.2126, 0.7152, 0.0722)
	
float3 CA_Final(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD) : COLOR
{
			float2 distance_xy = texcoord - float2(0.5,0.5);
			float2 center = distance_xy;
			distance_xy *= float2((ReShade::PixelSize.y / ReShade::PixelSize.x),CA_LensShape);
			float Concave = dot(distance_xy,distance_xy);
			Concave = (1.0 + pow(Concave,0.25) * -1.00);
			Concave = 2 + ((Concave) * (0.01));
			
			float2 Coords = (Concave)*(center.xy*0.5); 
		#if CA_Blurring == 0
			#define CASampler ReShade::BackBuffer
		#else
			#define CASampler ReShade::BackBuffer
		#endif
			
			
			float3 Chro = 0;
			float3 Chro2 = 0;
			
				
	#if CA_Color == 0
			Chro = (tex2D(CASampler,(Coords*(1.0000 - (CA_Offset*1.010))) + 0.5).rgb*float3(0.1,0.0,0.0));
			Chro += (tex2D(CASampler,(Coords*(1.0000 - (CA_Offset*1.008))) + 0.5).rgb*float3(0.125,0.0,0.0));
			Chro += (tex2D(CASampler,(Coords*(1.0000 - (CA_Offset*0.006))) + 0.5).rgb*float3(0.15,0.01,0.0));
			Chro += (tex2D(CASampler,(Coords*(1.0000 - (CA_Offset*1.004))) + 0.5).rgb*float3(0.20,0.02,0.0));
			Chro += (tex2D(CASampler,(Coords*(1.0000 - (CA_Offset*1.002))) + 0.5).rgb*float3(0.225,0.03,0.0));
			Chro += (tex2D(CASampler,(Coords*(1.0000 - CA_Offset)) + 0.5).rgb*float3(0.0,0.065,0.0));
			
			Chro2 = (tex2D(CASampler,(Coords*(1.0000 + CA_Offset)) + 0.5).rgb*float3(0.0,0.065,0.0));
			Chro2 += (tex2D(CASampler,(Coords*(1.0000 + (CA_Offset*1.002))) + 0.5).rgb*float3(0.0,0.03,0.25));
			Chro2 += (tex2D(CASampler,(Coords*(1.0000 + (CA_Offset*1.004))) + 0.5).rgb*float3(0.0,0.02,0.225));
			Chro2 += (tex2D(CASampler,(Coords*(1.0000 + (CA_Offset*1.006))) + 0.5).rgb*float3(0.0,0.01,0.175));
			Chro2 += (tex2D(CASampler,(Coords*(1.0000 + (CA_Offset*1.008))) + 0.5).rgb*float3(0.05,0.0,0.15));
			Chro2 += (tex2D(CASampler,(Coords*(1.0000 + (CA_Offset*1.010))) + 0.5).rgb*float3(0.15,0.0,0.2));
	#endif
	
	#if CA_Color == 1
		#if CA_Blurring == 1
		float sampleOffsets[9] = { 0.0, 1.3846153846, 2.7692307692, 4.1538461538, 5.5384615384, 6.923076923, 8.3076923076, 9.6923076922, 11.0769230768 };
		float sampleWeights[3] = { 0.37004405283, 0.515418502188, 0.114537444985 };
		#define Csamp 3
			[loop]
			for(int i = 0; i < Csamp; ++i) {
				Chro += (tex2D(CASampler,(Coords*(1.0000 - (CA_Offset*sampleOffsets[i]))) + 0.5).rgb*float3(1.0,0.0,0.0))*sampleWeights[i];
				Chro2 += (tex2D(CASampler,(Coords*(1.0000 + (CA_Offset*sampleOffsets[i]))) + 0.5).rgb*float3(0.0,0.0,1.0))*sampleWeights[i]; 
			}
		#elif CA_Blurring == 2
		float sampleOffsets[9] = { 0.0, 1.3846153846, 2.7692307692, 4.1538461538, 5.5384615384, 6.923076923, 8.3076923076, 9.6923076922, 11.0769230768 };
		float sampleWeights[5] = { 0.2879768, 0.46703928, 0.2001597, 0.04120935, 0.003614855 };
		#define Csamp 5
			[loop]
			for(int i = 0; i < Csamp; ++i) {
				Chro += (tex2D(CASampler,(Coords*(1.0000 - (CA_Offset*sampleOffsets[i]))) + 0.5).rgb*float3(1.0,0.0,0.0))*sampleWeights[i];
				Chro2 += (tex2D(CASampler,(Coords*(1.0000 + (CA_Offset*sampleOffsets[i]))) + 0.5).rgb*float3(0.0,0.0,1.0))*sampleWeights[i]; 
			}
		#elif CA_Blurring == 3
		float sampleOffsets[9] = { 0.0, 1.3846153846, 2.7692307692, 4.1538461538, 5.5384615384, 6.923076923, 8.3076923076, 9.6923076922, 11.0769230768 };
		float sampleWeights[9] = { 0.19983343248, 0.215205235, 0.19983343248, 0.159866745985, 0.10990838786, 0.06465199286, 0.032325996431, 0.0136109458656, 0.004763831053 };
		#define Csamp 9
			[loop]
			for(int i = 0; i < Csamp; ++i) {
				Chro += (tex2D(CASampler,(Coords*(1.0000 - (CA_Offset*sampleOffsets[i]))) + 0.5).rgb*float3(1.0,0.0,0.0))*sampleWeights[i];
				Chro2 += (tex2D(CASampler,(Coords*(1.0000 + (CA_Offset*sampleOffsets[i]))) + 0.5).rgb*float3(0.0,0.0,1.0))*sampleWeights[i]; 
			}
		#else 
			Chro = (tex2D(CASampler,(Coords*(1.0000 - CA_Offset)) + 0.5).rgb*float3(1.0,0.0,0.0));
			Chro2 = (tex2D(CASampler,(Coords*(1.0000 + CA_Offset)) + 0.5).rgb*float3(0.0,0.0,1.0));
		#endif
	#endif	
	
	#if CA_Color >= 2
		#if CA_Color == 2
		#define ColVal float3(1,0,0) //red/cyan
		#elif CA_Color == 3
		#define ColVal float3(0,0,1) //blue/yellow
		#elif CA_Color == 4
		#define ColVal float3(1,0,1) //magenta/green
		#endif
		#if CA_Blurring == 1
		float sampleOffsets[9] = { 0.0, 1.3846153846, 2.7692307692, 4.1538461538, 5.5384615384, 6.923076923, 8.3076923076, 9.6923076922, 11.0769230768 };
		float sampleWeights[3] = { 0.370044052828, 0.5154185021876, 0.114537444985 };
		#define Csamp 3
			[loop]
			for(int i = 0; i < Csamp; ++i) {
				Chro += (tex2D(CASampler,(Coords*(1.0000 - (CA_Offset*sampleOffsets[i]))) + 0.5).rgb)*sampleWeights[i]*ColVal;
			}
		#elif CA_Blurring == 2
		float sampleOffsets[9] = { 0.0, 1.3846153846, 2.7692307692, 4.1538461538, 5.5384615384, 6.923076923, 8.3076923076, 9.6923076922, 11.0769230768 };
		float sampleWeights[5] = { 0.2879768, 0.46703928, 0.2001597, 0.04120935, 0.003614855 };
		#define Csamp 5
			[loop]
			for(int i = 0; i < Csamp; ++i) {
				Chro += (tex2D(CASampler,(Coords*(1.0000 - (CA_Offset*sampleOffsets[i]))) + 0.5).rgb)*sampleWeights[i]*ColVal;
			}
		#elif CA_Blurring == 3
		float sampleOffsets[9] = { 0.0, 1.3846153846, 2.7692307692, 4.1538461538, 5.5384615384, 6.923076923, 8.3076923076, 9.6923076922, 11.0769230768 };
		float sampleWeights[9] = { 0.19983343248, 0.215205235, 0.19983343248, 0.159866745985, 0.10990838786, 0.06465199286, 0.032325996431, 0.0136109458656, 0.004763831053 };
		#define Csamp 9
			[loop]
			for(int i = 0; i < Csamp; ++i) {
				Chro += (tex2D(CASampler,(Coords*(1.0000 - (CA_Offset*sampleOffsets[i]))) + 0.5).rgb)*sampleWeights[i]*ColVal;
			}
		#else 
			Chro = (tex2D(CASampler,(Coords*(1.0000 - CA_Offset)) + 0.5)).rgb*ColVal;
		#endif
	#endif
	
	
		float3 Orig = tex2D(ReShade::BackBuffer, texcoord).rgb;
		
	#if CA_Color == 0
			//Chro = (Chro+Chro2+(Orig*float3(0.0,0.5,0.0)));
			Chro = (Chro+Chro2+(Orig*float3(0.0,0.75,0.0)));
		#elif CA_Color == 1
			Chro = (Chro+Chro2+(Orig*float3(0.0,1.0,0.0)));
		#elif CA_Color == 2
			Chro = (Chro+(Orig*float3(0.0,1.0,1.0)));
		#elif CA_Color == 3
			Chro = (Chro+(Orig*float3(1.0,1.0,0.0)));
		#elif CA_Color == 4
			Chro = (Chro+(Orig*float3(0.0,1.0,0.0)));		
	#endif
	float dist = dot(distance_xy,distance_xy);
		dist = (1.0 + pow(dist,0.25) * -1);
		
		Chro = lerp(Chro,Orig,smoothstep(0.0,CA_LensFocus,dist));
		Orig = lerp(Orig,Chro,CA_Strength);
		
	return Orig;
	
}


#if USE_ChromaticAberration == 1

#if CA_RadialBlurring >= 1
float3 CA_RadialBlur2(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD) : COLOR
{
	float2 distance_xy = texcoord - float2(0.5,0.5);
	float2 center = distance_xy;
	distance_xy *= float2((ReShade::PixelSize.y / ReShade::PixelSize.x),CA_LensShape);
	float Concave = dot(distance_xy,distance_xy);
	Concave = (1.0 + (pow(Concave,0.25) * -1.00));
	Concave = 2 + (Concave) * (0.01);
			
	float2 Coords = (Concave)*(center.xy*0.5);
	
	#if CA_RadialBlurring == 0
	#define Samples2 0
	#elif CA_RadialBlurring == 1 
	#define Samples2 3
	float weight[3] = {0.5, 0.3, 0.2};
	float sampleOffsets[3] = { 0.9995, 0.999, 0.9985 };
	#elif CA_RadialBlurring == 2 
	#define Samples2 5
	float weight[5] = { 0.2879768, 0.46703928, 0.2001597, 0.04120935, 0.003614855 };
	float sampleOffsets[5] = { 0.999, 0.998, 0.997, 0.996, 0.995 };
	#elif CA_RadialBlurring == 3 
	#define Samples2 11
	float weight[11] = {0.1486926, 0.1457586, 0.1372968, 0.1242738, 0.1080882, 0.0903366, 0.0725508, 0.055989, 0.0415188, 0.0295848, 0.0202572 };
	float sampleOffsets[11] = { 0.999, 0.998, 0.997, 0.996, 0.995, 0.994, 0.993, 0.992, 0.991, 0.990, 0.989 };
	#elif CA_RadialBlurring == 4 
	#define Samples2 21
	#if Rtest == 0
	#define xyz 0.965551535
	float weight[21] = { 0.082607*xyz, 0.081792*xyz, 0.080977*xyz, 0.0786265*xyz, 0.076276*xyz, 0.0726585*xyz, 0.069041*xyz, 0.064545*xyz, 0.060049*xyz, 0.055118*xyz, 0.050187*xyz, 0.0452465*xyz, 0.040306*xyz, 0.0357055*xyz, 0.031105*xyz, 0.0270855*xyz, 0.023066*xyz, 0.019751*xyz, 0.016436*xyz, 0.013845*xyz, 0.011254*xyz };
	#elif Rtest == 1
	#define xyz 0.5
	float weight[33] = { 0.1543548846297*xyz, 0.16078633815592*xyz,  0.15757061139281*xyz, 0.1543548846297*xyz, 0.14830175189935*xyz, 0.142248619169*xyz, 0.1340419680645*xyz, 0.12583531696*xyz, 0.116338311905*xyz, 0.10684130685*xyz, 0.096948593275*xyz, 0.0870558797*xyz, 0.077558874625*xyz, 0.06806186955*xyz, 0.059554135875*xyz, 0.0510464022*xyz, 0.04388199485*xyz, 0.0367175875*xyz, 0.031020030826*xyz, 0.025322474152*xyz, 0.021030529381*xyz, 0.01673858461*xyz, 0.01366984409775*xyz, 0.0106011035855*xyz, 0.00851564058275*xyz, 0.00643017758*xyz, 0.00508191454*xyz, 0.0037336515*xyz, 0.002903951165*xyz, 0.00207425083*xyz, 0.0011019458*xyz, 0.000559449384*xyz, 0.00027124819*xyz };
	#endif
	float sampleOffsets[21] = { 0.999, 0.998, 0.997, 0.996, 0.995, 0.994, 0.993, 0.992, 0.991, 0.990, 0.989, 0.988, 0.987,0.986, 0.985, 0.984, 0.983, 0.982, 0.981, 0.980, 0.979 };
	//float sampleOffsets[21] = { 0.9995, 0.999, 0.9985, 0.998, 0.9975, 0.997, 0.9965, 0.996, 0.9955, 0.995, 0.9945, 0.994, 0.9935,0.993, 0.9925, 0.992, 0.9915, 0.991, 0.9905, 0.990, 0.9895 };
	#endif
	
	float4 color = tex2D(ReShade::BackBuffer, texcoord)*weight[0];
	
	float dist = dot(distance_xy,distance_xy)*2;
	dist = (1 + pow(dist,0.25) * -1);
	color.a = dist;
	
	[loop]
	for(int i = 1; i < Samples2; ++i) {
		color += (tex2D(ReShade::BackBuffer, (Coords*sampleOffsets[i])+0.5))*weight[i];	
	}
	
	float3 Orig = tex2D(ReShade::BackBuffer, texcoord).rgb;
	
	color.rgb = lerp(color.rgb,Orig,smoothstep(0.0,RadialBlurFocus,dist));
	color.rgb = lerp(Orig,color.rgb,RadialBlurStrength);
	return color.rgb;
}
#endif

#endif
technique ChroAb <bool enabled = RESHADE_START_ENABLED; int toggle = ca_ToggleKey; >
{

	pass G 
	{
		VertexShader = ReShade::VS_PostProcess;
		PixelShader = CA_Final;	
	}
	
#if CA_RadialBlurring >= 1	
	pass G 
	{
		VertexShader = ReShade::VS_PostProcess;
		PixelShader = CA_RadialBlur2;
	}
#endif


}
#endif

#include EFFECT_CONFIG_UNDEF(Ioxa)

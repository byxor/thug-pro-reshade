#include EFFECT_CONFIG(Ioxa)

#if USE_Clarity == 1

#pragma message "Clarity by Ioxa\n"

//Clarity
//Version 1.4
/* This shader uses the gaussian blur passes from Boulotaur2024's gaussian blur/ bloom, unsharpmask shader which are based
   on the implementation in the article "Efficient Gaussian blur with linear sampling"
   http://rastergrid.com/blog/2010/09/efficient-gaussian-blur-with-linear-sampling/ .
   The blend modes are based on algorithms found at http://www.dunnbypaul.net/blends/ , 
   http://www.deepskycolors.com/archive/2010/04/21/formulas-for-Photoshop-blending-modes.html ,
   http://www.simplefilter.de/en/basics/mixmods.html and http://en.wikipedia.org/wiki/Blend_modes . 
   For more info go to http://reshade.me/forum/shader-presentation/529-high-pass-sharpening */ 
//#define CoefLuma_HP (float3(0.2126, 0.7152, 0.0722))
#define CoefLuma_HP (float3(0.32786885,0.655737705,0.0163934436))

#if ClarityTextureFormat == 1
#define CETexFormat R16F
#elif ClarityTextureFormat == 2 
#define CETexFormat R32F
#else
#define CETexFormat R8
#endif

#if ClarityTexScale == 1 
#define CEscale 0.5 
#elif ClarityTexScale == 2 
#define CEscale 0.25 
#else 
#define CEscale 1
#endif

#define cePX_SIZE (ReShade::PixelSize*ClarityOffset)
#if ClarityIterations >= 3
	#define cePX_SIZEx (ReShade::PixelSize*ClarityOffset*2.0)
#else
	#define cePX_SIZEx (ReShade::PixelSize*ClarityOffset)
#endif

texture ceBlurTex2Dping{ Width = BUFFER_WIDTH*CEscale; Height = BUFFER_HEIGHT*CEscale; Format = CETexFormat; };
texture ceBlurTex2Dpong{ Width = BUFFER_WIDTH*CEscale; Height = BUFFER_HEIGHT*CEscale; Format = CETexFormat; };

sampler ceBlurSamplerPing { Texture = ceBlurTex2Dping;};
sampler ceBlurSamplerPong { Texture = ceBlurTex2Dpong;};

#define CSigma1 0.39894*exp(-0.5*0*0/(ClaritySigma*ClaritySigma))/ClaritySigma
#define CSigma2 0.39894*exp(-0.5*1*1/(ClaritySigma*ClaritySigma))/ClaritySigma
#define CSigma3 0.39894*exp(-0.5*2*2/(ClaritySigma*ClaritySigma))/ClaritySigma
#define CSigma4 0.39894*exp(-0.5*3*3/(ClaritySigma*ClaritySigma))/ClaritySigma
#define CSigma5 0.39894*exp(-0.5*4*4/(ClaritySigma*ClaritySigma))/ClaritySigma

#if ClaritySigma >= 2
#define CSigma6 0.39894*exp(-0.5*5*5/(ClaritySigma*ClaritySigma))/ClaritySigma
#define CSigma7 0.39894*exp(-0.5*6*6/(ClaritySigma*ClaritySigma))/ClaritySigma
#endif

#if ClaritySigma >= 3
#define CSigma8 0.39894*exp(-0.5*7*7/(ClaritySigma*ClaritySigma))/ClaritySigma
#define CSigma9 0.39894*exp(-0.5*8*8/(ClaritySigma*ClaritySigma))/ClaritySigma
#endif 

#if ClaritySigma >= 4
#define CSigma10 0.39894*exp(-0.5*9*9/(ClaritySigma*ClaritySigma))/ClaritySigma
#define CSigma11 0.39894*exp(-0.5*10*10/(ClaritySigma*ClaritySigma))/ClaritySigma
#define CSigma12 0.39894*exp(-0.5*11*11/(ClaritySigma*ClaritySigma))/ClaritySigma
#define CSigma13 0.39894*exp(-0.5*12*12/(ClaritySigma*ClaritySigma))/ClaritySigma
#endif 

#if ClaritySigma >= 5
#define CSigma14 0.39894*exp(-0.5*13*13/(ClaritySigma*ClaritySigma))/ClaritySigma
#define CSigma15 0.39894*exp(-0.5*14*14/(ClaritySigma*ClaritySigma))/ClaritySigma
#endif

#if ClaritySigma >= 6
#define CSigma16 0.39894*exp(-0.5*15*15/(ClaritySigma*ClaritySigma))/ClaritySigma
#define CSigma17 0.39894*exp(-0.5*17*17/(ClaritySigma*ClaritySigma))/ClaritySigma
#endif 

#if ClaritySigma >= 8
#define CSigma18 0.39894*exp(-0.5*17*17/(ClaritySigma*ClaritySigma))/ClaritySigma
#define CSigma19 0.39894*exp(-0.5*18*18/(ClaritySigma*ClaritySigma))/ClaritySigma
#endif 

#if ClaritySigma >= 9
#define CSigma20 0.39894*exp(-0.5*19*19/(ClaritySigma*ClaritySigma))/ClaritySigma
#define CSigma21 0.39894*exp(-0.5*20*20/(ClaritySigma*ClaritySigma))/ClaritySigma
#endif

#define ClarityWeight1 (CSigma1)
#define ClarityOffset1 (0.0)

#define ClarityWeight2 (CSigma2 + CSigma3)
#define ClarityOffset2 ((CSigma2*1.0)+(CSigma3*2.0))/ClarityWeight2

#define ClarityWeight3 (CSigma4 + CSigma5 )
#define ClarityOffset3 ((CSigma4*3.0)+(CSigma5*4.0))/ClarityWeight3

#if ClaritySigma >= 2
#define ClarityWeight4 (CSigma6 + CSigma7)
#define ClarityOffset4 ((CSigma6*5.0)+(CSigma7*6.0))/ClarityWeight4
#else 
#define ClarityWeight4 1.0
#define ClarityOffset4 1.0
#endif

#if ClaritySigma >= 3
#define ClarityWeight5 (CSigma8 + CSigma9)
#define ClarityOffset5 ((CSigma8*7.0)+(CSigma9*8.0))/ClarityWeight5
#else 
#define ClarityWeight5 1.0
#define ClarityOffset5 1.0
#endif

#if ClaritySigma >= 4
#define ClarityWeight6 (CSigma10 + CSigma11)
#define ClarityOffset6 ((CSigma10*9.0)+(CSigma11*10.0))/ClarityWeight6

#define ClarityWeight7 (CSigma12 + CSigma13)
#define ClarityOffset7 ((CSigma12*11.0)+(CSigma13*12.0))/ClarityWeight7
#else 
#define ClarityWeight6 1.0
#define ClarityOffset6 1.0

#define ClarityWeight7 1.0
#define ClarityOffset7 1.0
#endif 

#if ClaritySigma >= 5
#define ClarityWeight8 (CSigma14 + CSigma15)
#define ClarityOffset8 ((CSigma14*13.0)+(CSigma15*14.0))/ClarityWeight8
#else 
#define ClarityWeight8 1.0
#define ClarityOffset8 1.0
#endif

#if ClaritySigma >= 6
#define ClarityWeight9 (CSigma16 + CSigma17)
#define ClarityOffset9 ((CSigma16*15.0)+(CSigma17*16.0))/ClarityWeight9
#else 
#define ClarityWeight9 1.0
#define ClarityOffset9 1.0
#endif

#if ClaritySigma >= 8
#define ClarityWeight10 (CSigma18 + CSigma19)
#define ClarityOffset10 ((CSigma18*17.0)+(CSigma19*18.0))/ClarityWeight10
#else 
#define ClarityWeight10 1.0
#define ClarityOffset10 1.0
#endif

#if ClaritySigma >= 9
#define ClarityWeight11 (CSigma20 + CSigma21)
#define ClarityOffset11 ((CSigma20*19.0)+(CSigma21*20.0))/ClarityWeight11
#else 
#define ClarityWeight11 1.0
#define ClarityOffset11 1.0
#endif

#if ClaritySigma == 3
	uniform const int N = 5;
#elif ClaritySigma == 4 
	uniform const int N = 7;
#elif ClaritySigma == 5 
	uniform const int N = 8;
#elif ClaritySigma == 6 
	uniform const int N = 9;
#elif ClaritySigma == 7 
	uniform const int N = 9;
#elif ClaritySigma == 8 
	uniform const int N = 10;
#elif ClaritySigma == 9 
	uniform const int N = 11;
#elif ClaritySigma == 10 
	uniform const int N = 11;
#elif ClaritySigma == 2 
	uniform const int N = 4;
#else 
	uniform const int N = 3;
#endif

float3 CEFinal(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD) : COLOR
{
	
	float sampleOffsets[11] = { ClarityOffset1, ClarityOffset2, ClarityOffset3, ClarityOffset4, ClarityOffset5, ClarityOffset6, ClarityOffset7, ClarityOffset8, ClarityOffset9, ClarityOffset10, ClarityOffset11 };
	float sampleWeights[11] = { ClarityWeight1, ClarityWeight2, ClarityWeight3, ClarityWeight4, ClarityWeight5, ClarityWeight6, ClarityWeight7, ClarityWeight8, ClarityWeight9, ClarityWeight10, ClarityWeight11 };
	
	float color = tex2D(ceBlurSamplerPing, texcoord).r * sampleWeights[0];
	[loop]
	for(int i = 1; i < N; ++i) {
		color += tex2D(ceBlurSamplerPing, texcoord + float2(0.0, sampleOffsets[i] * cePX_SIZE.y)).r * sampleWeights[i];
		color += tex2D(ceBlurSamplerPing, texcoord - float2(0.0, sampleOffsets[i] * cePX_SIZE.y)).r * sampleWeights[i]; 
	}
	
	float3 orig = tex2D(ReShade::BackBuffer, texcoord).rgb; //Original Image
	float luma = dot(orig.rgb,CoefLuma_HP);
	
	float3 chroma = orig.rgb - luma;
	
	float sharp = 1-color;
	
	float vivid = lerp(1-(1-luma)/(2*sharp),luma/(2*(1-sharp)),step(0.5,sharp));
	vivid = saturate(vivid);
	sharp = (luma+sharp)*0.5;
	sharp = clamp(lerp(sharp,vivid,ClarityMaskContrast),0.0,1.0);
	
	float sharpMin = lerp(0.0,1.0,smoothstep(0.0,1.0,sharp));
	float sharpMax = sharpMin;
	sharpMin = lerp(sharp,sharpMin,DarkIntensity);
	sharpMin = clamp(sharpMin,DarkClamp,0.501);
	sharpMax = lerp(sharp,sharpMax,LightIntensity);
	sharpMax = clamp(sharpMax,0.499,1.0-LightClamp);
	sharp = lerp(sharpMin,sharpMax,step(0.5,sharp));
	
	//orig = luma;
	
		#if ViewMask == 1
				orig.rgb = sharp;
				luma = sharp;
			#elif ClarityBlendMode == 3
				//Multiply
				sharp = (2 * luma * sharp);
				//sharp = pow(abs(luma*sharp),0.5);
			#elif ClarityBlendMode == 6
				//soft light #2
				sharp = lerp(luma*(sharp+0.5),1-(1-luma)*(1-(sharp-0.5)),step(0.5,sharp));
			#elif ClarityBlendMode == 2
				//overlay
				//sharp = lerp(2*luma*sharp, 1.0-(1.0-2.0*(luma-0.5))*(1.0-sharp), smoothstep(0.0,1.0,luma));
				sharp = lerp(2*luma*sharp, 1.0 - 2*(1.0-luma)*(1.0-sharp), step(0.50,luma));
			#elif ClarityBlendMode == 4
				//Hardlight
				//sharp = luma+2*sharp-1;
				sharp = lerp(2*luma*sharp, 1.0 - 2*(1.0-luma)*(1.0-sharp), step(0.49,sharp));
			#elif ClarityBlendMode == 1 
				//softlight
				sharp = lerp(2*luma*sharp + luma*luma*(1.0-2*sharp), 2*luma*(1.0-sharp)+pow(luma,0.5)*(2*sharp-1.0), step(0.49,sharp));
				//sharp = lerp(2*luma*sharp + luma*luma*(1.0-2*sharp), 2*luma*(1.0-sharp)+pow(luma,0.5)*(2*sharp-1.0), smoothstep(0.48,0.49,sharp));
			#elif ClarityBlendMode == 5
				//vivid light
				sharp = lerp(2*luma*sharp, luma/(2*(1-sharp)), step(0.5,sharp));
				//sharp = lerp(1-(1-luma)/(2*sharp),luma/(2*(1-sharp)),step(0.5,sharp));
			#elif ClarityBlendMode == 7
				//soft light #3
				sharp = lerp((2*sharp-1)*(luma-pow(luma,2))+luma, ((2*sharp-1)*(pow(luma,0.5)-luma))+luma, step(0.49,sharp));
			#endif
					
					#if BlendIfDark > 0 || BlendIfLight < 255 || ViewBlendIfMask == 1
						#define BlendIfD (BlendIfDark/255.0)+0.0001
						#define BlendIfL (BlendIfLight/255.0)-0.0001
						float mix = dot(orig.rgb, 0.333333);
					#if ViewBlendIfMask == 1 
						#if BlendIfDark > 0
							float3 red = lerp(float3(0.0,0.0,1.0),float3(1.0,0.0,0.0),smoothstep(BlendIfD-(BlendIfD*0.2),BlendIfD+(BlendIfD*0.2),mix));
						#endif
						#if BlendIfLight < 255
							float3 blue = lerp(red,float3(0.0,0.0,1.0),smoothstep(BlendIfL-(BlendIfL*0.2),BlendIfL+(BlendIfL*0.2),mix));
						#endif
						orig = blue;
					#else
						#if BlendIfDark > 0
							sharp = lerp(luma,sharp,smoothstep(BlendIfD-(BlendIfD*0.2),BlendIfD+(BlendIfD*0.2),mix));
						#endif
						#if BlendIfLight < 255
							sharp = lerp(sharp,luma,smoothstep(BlendIfL-(BlendIfL*0.2),BlendIfL+(BlendIfL*0.2),mix));
						#endif
					#endif
					#endif
		
			#if ViewMask == 1 || ViewBlendIfMask == 1
				
			#else 
				orig.rgb = lerp(luma, sharp, ClarityStrength);
				orig.rgb += chroma;	
			#endif 
	//orig = color;
	return saturate(orig);
}	

float CELuma(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD) : COLOR
{

	float3 color = tex2D(ReShade::BackBuffer,texcoord).rgb;
	color.r = dot(color.rgb,CoefLuma_HP);
	
	return color.r;
}

float CEBlurX(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD) : COLOR
{

	float sampleOffsets[11] = { ClarityOffset1, ClarityOffset2, ClarityOffset3, ClarityOffset4, ClarityOffset5, ClarityOffset6, ClarityOffset7, ClarityOffset8, ClarityOffset9, ClarityOffset10, ClarityOffset11 };
	float sampleWeights[11] = { ClarityWeight1, ClarityWeight2, ClarityWeight3, ClarityWeight4, ClarityWeight5, ClarityWeight6, ClarityWeight7, ClarityWeight8, ClarityWeight9, ClarityWeight10, ClarityWeight11 };

	float color = tex2D(ceBlurSamplerPong, texcoord).r * sampleWeights[0];
	[loop]
	for(int i = 1; i < N; ++i) {
		color += tex2D(ceBlurSamplerPong, texcoord + float2(sampleOffsets[i] * ReShade::PixelSize.x, 0.0)).r * sampleWeights[i];
		color += tex2D(ceBlurSamplerPong, texcoord - float2(sampleOffsets[i] * ReShade::PixelSize.x, 0.0)).r * sampleWeights[i]; 
	}

	return color;
}

float CEBlurX2(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD) : COLOR
{

	float sampleOffsets[11] = { ClarityOffset1, ClarityOffset2, ClarityOffset3, ClarityOffset4, ClarityOffset5, ClarityOffset6, ClarityOffset7, ClarityOffset8, ClarityOffset9, ClarityOffset10, ClarityOffset11 };
	float sampleWeights[11] = { ClarityWeight1, ClarityWeight2, ClarityWeight3, ClarityWeight4, ClarityWeight5, ClarityWeight6, ClarityWeight7, ClarityWeight8, ClarityWeight9, ClarityWeight10, ClarityWeight11 };

	float color = tex2D(ceBlurSamplerPong, texcoord).r * sampleWeights[0];
	[loop]
	for(int i = 1; i < N; ++i) {
		color += tex2D(ceBlurSamplerPong, texcoord + float2(sampleOffsets[i] * cePX_SIZEx.x, 0.0)).r * sampleWeights[i];
		color += tex2D(ceBlurSamplerPong, texcoord - float2(sampleOffsets[i] * cePX_SIZEx.x, 0.0)).r * sampleWeights[i]; 
	}

	return color;
}

float CEBlurX3(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD) : COLOR
{

	float sampleOffsets[11] = { ClarityOffset1, ClarityOffset2, ClarityOffset3, ClarityOffset4, ClarityOffset5, ClarityOffset6, ClarityOffset7, ClarityOffset8, ClarityOffset9, ClarityOffset10, ClarityOffset11 };
	float sampleWeights[11] = { ClarityWeight1, ClarityWeight2, ClarityWeight3, ClarityWeight4, ClarityWeight5, ClarityWeight6, ClarityWeight7, ClarityWeight8, ClarityWeight9, ClarityWeight10, ClarityWeight11 };

	float color = tex2D(ceBlurSamplerPong, texcoord).r * sampleWeights[0];
	[loop]
	for(int i = 1; i < N; ++i) {
		color += tex2D(ceBlurSamplerPong, texcoord + float2(sampleOffsets[i] * cePX_SIZE.x, 0.0)).r * sampleWeights[i];
		color += tex2D(ceBlurSamplerPong, texcoord - float2(sampleOffsets[i] * cePX_SIZE.x, 0.0)).r * sampleWeights[i]; 
	}

	return color;
}

float CEBlurY(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD) : COLOR
{

	float sampleOffsets[11] = { ClarityOffset1, ClarityOffset2, ClarityOffset3, ClarityOffset4, ClarityOffset5, ClarityOffset6, ClarityOffset7, ClarityOffset8, ClarityOffset9, ClarityOffset10, ClarityOffset11 };
	float sampleWeights[11] = { ClarityWeight1, ClarityWeight2, ClarityWeight3, ClarityWeight4, ClarityWeight5, ClarityWeight6, ClarityWeight7, ClarityWeight8, ClarityWeight9, ClarityWeight10, ClarityWeight11 };

	float color = tex2D(ceBlurSamplerPing, texcoord).r * sampleWeights[0];
	[loop]
	for(int i = 1; i < N; ++i) {
		color += tex2D(ceBlurSamplerPing, texcoord + float2(0.0,sampleOffsets[i] * ReShade::PixelSize.y)).r * sampleWeights[i];
		color += tex2D(ceBlurSamplerPing, texcoord - float2(0.0,sampleOffsets[i] * ReShade::PixelSize.y)).r * sampleWeights[i]; 
	}

	return color;
}

float CEBlurY2(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD) : COLOR
{

	float sampleOffsets[11] = { ClarityOffset1, ClarityOffset2, ClarityOffset3, ClarityOffset4, ClarityOffset5, ClarityOffset6, ClarityOffset7, ClarityOffset8, ClarityOffset9, ClarityOffset10, ClarityOffset11 };
	float sampleWeights[11] = { ClarityWeight1, ClarityWeight2, ClarityWeight3, ClarityWeight4, ClarityWeight5, ClarityWeight6, ClarityWeight7, ClarityWeight8, ClarityWeight9, ClarityWeight10, ClarityWeight11 };

	float color = tex2D(ceBlurSamplerPing, texcoord).r * sampleWeights[0];
	[loop]
	for(int i = 1; i < N; ++i) {
		color += tex2D(ceBlurSamplerPing, texcoord + float2(0.0,sampleOffsets[i] * cePX_SIZEx.y)).r * sampleWeights[i];
		color += tex2D(ceBlurSamplerPing, texcoord - float2(0.0,sampleOffsets[i] * cePX_SIZEx.y)).r * sampleWeights[i]; 
	}

	return color;
}

technique Clarity <bool enabled = RESHADE_START_ENABLED; int toggle = Clarity_ToggleKey; >
{
	pass H1
	{
		VertexShader = ReShade::VS_PostProcess;
		PixelShader = CELuma;
		RenderTarget = ceBlurTex2Dpong;
	}

	pass H1
	{
		VertexShader = ReShade::VS_PostProcess;
		PixelShader = CEBlurX;
		RenderTarget = ceBlurTex2Dping;
	}
	
	pass H1
	{
		VertexShader = ReShade::VS_PostProcess;
		PixelShader = CEBlurY;
		RenderTarget = ceBlurTex2Dpong;
	}
	
	pass H1
	{
		VertexShader = ReShade::VS_PostProcess;
		PixelShader = CEBlurX2;
		RenderTarget = ceBlurTex2Dping;
	}
#if (ClarityIterations >= 2)
	pass H1
	{
		VertexShader = ReShade::VS_PostProcess;
		PixelShader = CEBlurY2;
		RenderTarget = ceBlurTex2Dpong;
	}
	
	pass H1
	{
		VertexShader = ReShade::VS_PostProcess;
		PixelShader = CEBlurX3;
		RenderTarget = ceBlurTex2Dping;
	}
#endif

#if (ClarityIterations >= 3)
	pass H1
	{
		VertexShader = ReShade::VS_PostProcess;
		PixelShader = CEBlurY2;
		RenderTarget = ceBlurTex2Dpong;
	}
	
	pass H1
	{
		VertexShader = ReShade::VS_PostProcess;
		PixelShader = CEBlurX3;
		RenderTarget = ceBlurTex2Dping;
	}
#endif

#if (ClarityIterations >= 4)
	pass H1
	{
		VertexShader = ReShade::VS_PostProcess;
		PixelShader = CEBlurY2;
		RenderTarget = ceBlurTex2Dpong;
	}
	
	pass H1
	{
		VertexShader = ReShade::VS_PostProcess;
		PixelShader = CEBlurX3;
		RenderTarget = ceBlurTex2Dping;
	}
#endif

#if (ClarityIterations >= 5)
	pass H1
	{
		VertexShader = ReShade::VS_PostProcess;
		PixelShader = CEBlurY2;
		RenderTarget = ceBlurTex2Dpong;
	}
	
	pass H1
	{
		VertexShader = ReShade::VS_PostProcess;
		PixelShader = CEBlurX3;
		RenderTarget = ceBlurTex2Dping;
	}
#endif

	pass ContEnhance
	{
		VertexShader = ReShade::VS_PostProcess;
		PixelShader = CEFinal;
	}


}
#endif

#include EFFECT_CONFIG_UNDEF(Ioxa)


#include EFFECT_CONFIG(Ioxa)

#if USE_HighPassSharpening == 1
#pragma message "High Pass Sharpening by Ioxa\n"
//High Pass Sharpening & Contrast Enhancement
//Version 1.3
/* This shader uses the gaussian blur passes from Boulotaur2024's gaussian blur/ bloom, unsharpmask shader which are based
   on the implementation in the article "Efficient Gaussian blur with linear sampling"
   http://rastergrid.com/blog/2010/09/efficient-gaussian-blur-with-linear-sampling/ .
   The blend modes are based on algorithms found at http://www.dunnbypaul.net/blends/ , 
   http://www.deepskycolors.com/archive/2010/04/21/formulas-for-Photoshop-blending-modes.html ,
   http://www.simplefilter.de/en/basics/mixmods.html and http://en.wikipedia.org/wiki/Blend_modes . 
   For more info go to http://reshade.me/forum/shader-presentation/529-high-pass-sharpening */ 
   
texture HPlumaTex{ Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = R8; };
//sampler2D HPlumaSampler { Texture = HPlumaTex; MinFilter = Linear; MagFilter = Linear; MipFilter = Point; AddressU = Clamp; AddressV = Clamp; SRGBTexture = FALSE;};
sampler HPlumaSampler { Texture = HPlumaTex; };
   
float HPDoSmoothererstep(float edge0, float edge1, float x)
{
	x = ((x-edge0)/(edge1-edge0));
	return x*x*x*x*(x*(x*(70-20*x)-84)+35);
}
/*
#define HPSigma1 0.39894*exp(-0.5*0*0/(SharpRadius*SharpRadius))/SharpRadius
#define HPSigma2 0.39894*exp(-0.5*1*1/(SharpRadius*SharpRadius))/SharpRadius
#define HPSigma3 0.39894*exp(-0.5*2*2/(SharpRadius*SharpRadius))/SharpRadius
#define HPSigma4 0.39894*exp(-0.5*3*3/(SharpRadius*SharpRadius))/SharpRadius
#define HPSigma5 0.39894*exp(-0.5*4*4/(SharpRadius*SharpRadius))/SharpRadius
#define HPSigma6 0.39894*exp(-0.5*5*5/(SharpRadius*SharpRadius))/SharpRadius
#define HPSigma7 0.39894*exp(-0.5*6*6/(SharpRadius*SharpRadius))/SharpRadius
#define HPSigma8 0.39894*exp(-0.5*7*7/(SharpRadius*SharpRadius))/SharpRadius
#define HPSigma9 0.39894*exp(-0.5*8*8/(SharpRadius*SharpRadius))/SharpRadius
#define HPSigma10 0.39894*exp(-0.5*9*9/(SharpRadius*SharpRadius))/SharpRadius
#define HPSigma11 0.39894*exp(-0.5*10*10/(SharpRadius*SharpRadius))/SharpRadius
#define HPSigma12 0.39894*exp(-0.5*11*11/(SharpRadius*SharpRadius))/SharpRadius
#define HPSigma13 0.39894*exp(-0.5*12*12/(SharpRadius*SharpRadius))/SharpRadius
#define HPSigma14 0.39894*exp(-0.5*13*13/(SharpRadius*SharpRadius))/SharpRadius
#define HPSigma15 0.39894*exp(-0.5*14*14/(SharpRadius*SharpRadius))/SharpRadius
#define HPSigma16 0.39894*exp(-0.5*15*15/(SharpRadius*SharpRadius))/SharpRadius
#define HPSigma17 0.39894*exp(-0.5*17*17/(SharpRadius*SharpRadius))/SharpRadius
#define HPSigma18 0.39894*exp(-0.5*17*17/(SharpRadius*SharpRadius))/SharpRadius
#define HPSigma19 0.39894*exp(-0.5*18*18/(SharpRadius*SharpRadius))/SharpRadius
#define HPSigma20 0.39894*exp(-0.5*19*19/(SharpRadius*SharpRadius))/SharpRadius
#define HPSigma21 0.39894*exp(-0.5*20*20/(SharpRadius*SharpRadius))/SharpRadius
*/
float3 SharpBlurFinal(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD) : COLOR
{
	//#define PX_SIZE (ReShade::PixelSize * HPSharpOffset)

	float color = tex2D(HPlumaSampler, texcoord).r;
	float luma = color;

	#if SharpRadius == 0 || SharpRadius == 1
		float sampleOffsetsX[25] = {  0.0, 	   1.0, 	  0.0, 	 1.0,     1.0,     2.0,     0.0,     2.0,     2.0,     1.0,    1.0,     2.0,     2.0,     3.0,     0.0,     3.001,     3.001,     1.001,    -1.001, 3.001, 3.001, 2.001, 2.001, 3.001, 3.001 };
		float sampleOffsetsY[25] = {  0.0,     0.0, 	  1.0, 	 1.0,    -1.0,     0.0,     2.0,     1.0,    -1.0,     2.0,     -2.0,     2.0,    -2.0,     0.0,     3.001,     1.001,    -1.001,     3.001,     3.001, 2.001, -2.001, 3.001, -3.001, 3.001, -3.001};
		#if SharpRadius == 0
			//float sampleWeights[21] = { HPSigma1, HPSigma2, HPSigma3, HPSigma4, HPSigma5, HPSigma6, HPSigma7, HPSigma8, HPSigma9, HPSigma10, HPSigma11, HPSigma12, HPSigma13, HPSigma14, HPSigma15, HPSigma16, HPSigma17, HPSigma18, HPSigma19, HPSigma20, HPSigma21 };
			//float sampleWeights[5] = { 0.22580645161290322580645161290323, 0.15053763439103942652446833930697, 0.15053763439103942652446833930697, 0.04301075270573476702391875746722, 0.04301075270573476702391875746722 };
			//float sampleWeights[5] = { 0.2258064516129032258, 0.1505376343910394265, 0.1505376343910394265, 0.043010752705734767, 0.043010752705734767 };
			float sampleWeights[5] = { 0.225806, 0.150538, 0.150538, 0.0430108, 0.0430108 };
			int N = 5;
		#else 
			//float sampleWeights[13] = { 0.3225806452*0.46809547012026575819986024459259, 0.2419354839*0.46809547012026575819986024459259, 0.2419354839*0.46809547012026575819986024459259, 0.0585327784*0.46809547012026575819986024459259, 0.0585327784*0.46809547012026575819986024459259, 0.0967741935*0.46809547012026575819986024459259, 0.0967741935*0.46809547012026575819986024459259, 0.0234131113*0.46809547012026575819986024459259, 0.0234131113*0.46809547012026575819986024459259, 0.0234131113*0.46809547012026575819986024459259, 0.0234131113*0.46809547012026575819986024459259, 0.0093652445*0.46809547012026575819986024459259, 0.0093652445*0.46809547012026575819986024459259 };
			float sampleWeights[13] = { 0.1509985387665926499, 0.1132489040749444874, 0.1132489040749444874, 0.0273989284225933369, 0.0273989284225933369, 0.0452995616018920668, 0.0452995616018920668, 0.0109595713409516066, 0.0109595713409516066, 0.0109595713409516066, 0.0109595713409516066, 0.0043838285270187332, 0.0043838285270187332 };
			int N = 13;
		#endif
	#else 
		float sampleOffsetsX[13] = { 				  0.0, 			    1.3846153846, 			 			  0.0, 	 		  1.3846153846,     	   	 1.3846153846,     		    3.2307692308,     		  			  0,     		 3.2307692308,     		   3.2307692308,     		 1.3846153846,    		   1.3846153846,     		  3.2307692308,     		  3.2307692308 };
		float sampleOffsetsY[13] = {  				  0.0,   					   0.0, 	  		   1.3846153846, 	 		  1.3846153846,     		-1.3846153846,     					   0,     		   3.2307692308,     		 1.3846153846,    		  -1.3846153846,     		 3.2307692308,   		  -3.2307692308,     		  3.2307692308,    		     -3.2307692308 };
		//float sampleWeights[13] = { 0.0957733978977875942, 0.3162162162*0.4218590146, 0.3162162162*0.4218590146, 0.0999926954*0.4218590146, 0.0999926954*0.4218590146, 0.0702702703*0.4218590146, 0.0702702703*0.4218590146, 0.022220599*0.4218590146, 0.022220599*0.4218590146, 0.022220599*0.4218590146, 0.022220599*0.4218590146, 0.0049379109*0.4218590146,  0.0049379109*0.4218590146 };
		float sampleWeights[13] = { 0.0957733978977875942, 0.1333986613666725565, 0.1333986613666725565, 0.0421828199486419528, 0.0421828199486419528, 0.0296441469844336464, 0.0296441469844336464, 0.0093739599979617454, 0.0093739599979617454, 0.0093739599979617454, 0.0093739599979617454, 0.0020831022264565991,  0.0020831022264565991 };
		int N = 13;
	#endif
	
	color *= sampleWeights[0];
	[loop]
	for(int i = 1; i < N; ++i) {
			//color += tex2D(ReShade::BackBuffer, texcoord + float2(sampleOffsetsX[i] * ReShade::PixelSize.x, sampleOffsetsY[i] * ReShade::PixelSize.y) * HPSharpOffset).r * sampleWeights[i];
			//color += tex2D(ReShade::BackBuffer, texcoord - float2(sampleOffsetsX[i] * ReShade::PixelSize.x, sampleOffsetsY[i] * ReShade::PixelSize.y) * HPSharpOffset).r * sampleWeights[i];
			color += tex2D(HPlumaSampler, texcoord + float2(sampleOffsetsX[i] * ReShade::PixelSize.x, sampleOffsetsY[i] * ReShade::PixelSize.y) * HPSharpOffset).r * sampleWeights[i];
			color += tex2D(HPlumaSampler, texcoord - float2(sampleOffsetsX[i] * ReShade::PixelSize.x, sampleOffsetsY[i] * ReShade::PixelSize.y) * HPSharpOffset).r * sampleWeights[i];
		}
	
	//color += tex2D(HPlumaSampler, texcoord + float2(ReShade::PixelSize.x, 0.0)*0.49).r * sampleWeights[1];
	//color += tex2D(HPlumaSampler, texcoord - float2(ReShade::PixelSize.x, 0.0)*0.49).r * sampleWeights[1];
	//color += tex2D(HPlumaSampler, texcoord + float2(0.0, ReShade::PixelSize.y)*0.49).r * sampleWeights[2];
	//color += tex2D(HPlumaSampler, texcoord - float2(0.0, ReShade::PixelSize.y)*0.49).r * sampleWeights[2];
	//color += tex2D(HPlumaSampler, texcoord + float2(ReShade::PixelSize.x, ReShade::PixelSize.y)*0.49).r * sampleWeights[3];
	//color += tex2D(HPlumaSampler, texcoord - float2(ReShade::PixelSize.x, ReShade::PixelSize.y)*0.49).r * sampleWeights[3];
	//color += tex2D(HPlumaSampler, texcoord + float2(-1.0*ReShade::PixelSize.x, ReShade::PixelSize.y)*0.49).r * sampleWeights[4];
	//color += tex2D(HPlumaSampler, texcoord + float2(ReShade::PixelSize.x, -1.0*ReShade::PixelSize.y)*0.49).r * sampleWeights[4];
	
	float3 orig = tex2D(ReShade::BackBuffer, texcoord).rgb; //Original Image
	
	float3 chroma = orig.rgb - luma;
	
	float sharp = 1.0 - color;
	
	float vivid = lerp(1.0-(1.0-luma)/(2.0*sharp),luma/(2.0*(1.0-sharp)),step(0.5,sharp));
	sharp = (luma+sharp)*0.5;
	sharp = clamp(lerp(sharp,vivid,MaskContrast),0.0,1.0);
	
	//float sharpMin = lerp(0,1,smoothstep(0,1,sharp));
	float sharpMin = lerp(0,1,HPDoSmoothererstep(0,1,sharp));
	float sharpMax = sharpMin;
	sharpMin = lerp(sharp,sharpMin,DarkLineIntensity);
	sharpMin = clamp(sharpMin,DarkLineClamp,1.0);
	sharpMax = lerp(sharp,sharpMax,LightLineIntensity);
	sharpMax = clamp(sharpMax,0.0,1.0-LightLineClamp);
	sharp = lerp(sharpMin,sharpMax,step(0.5,sharp));

			#if ViewSharpMask == 1
				orig.rgb = sharp;
				luma = sharp;
			#elif BlendMode == 3
				//Multiply
				sharp = 2.0 * luma * sharp;
			#elif BlendMode == 6
				//Screen
				sharp = 1.0 - (2*(1.0-luma)*(1.0-sharp));
				//sharp = luma+2*sharp-1;
			#elif BlendMode == 7
				//Linear Light
				sharp = lerp(luma+2*sharp-1,luma+2*(sharp-0.5),step(0.5,sharp));
				//sharp = luma+2*sharp-1;
				//sharp = luma+2*(sharp-0.5);
			#elif BlendMode == 2
				//overlay
				sharp = lerp(2*luma*sharp, 1.0 - 2*(1.0-luma)*(1.0-sharp), step(0.5,luma));
			#elif BlendMode == 4
				//Hardlight
				sharp = lerp(2*luma*sharp, 1.0 - 2*(1.0-luma)*(1.0-sharp), step(0.5,sharp));
			#elif BlendMode == 1 
				//softlight
				//sharp = lerp(2*luma*color.rgb + luma*luma*(1.0-2*color.rgb), 2*luma*(1.0-sharp)+pow(luma,0.5)*(2*sharp-1.0), smoothstep(0.0,0.49,sharp.rgb));
				//sharp = lerp(2*luma*sharp + luma*luma*(1.0-2*sharp), 2*luma*(1.0-sharp)+pow(luma,0.5)*(2*sharp-1.0), step(0.49,luma));
				//sharp = lerp((2*sharp-1)*(luma-pow(luma,2))+luma, ((2*sharp-1)*(pow(luma,0.5)-luma))+luma, step(0.49,luma));
				sharp = lerp((2*sharp-1)*(luma-pow(luma,2))+luma, ((2*sharp-1)*(pow(luma,0.5)-luma))+luma, smoothstep(0.40,0.60,luma));
			#elif BlendMode == 5
				//vivid light
				//sharp = lerp(1-(1-luma)/(2*sharp), luma/(2*(1-sharp)), step(0.5,sharp));
				//sharp = lerp(1-(1-luma)/(2*sharp), luma/(2*(1-sharp)), smoothstep(0.49,0.5,luma));
				sharp = lerp(1-(1-luma)/(2*sharp),luma/(2*(1-sharp)),step(0.5,sharp));
			#endif
		
		#if ViewSharpMask == 1

		#else
			luma = lerp(luma, sharp, HPSharpStrength);
			orig.rgb = luma+chroma;
		#endif
		
	return saturate(orig);
}

float HPLuma(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD) : COLOR
{

	float3 color = tex2D(ReShade::BackBuffer,texcoord).rgb;
	color.r = dot(color.rgb,float3(0.32786885,0.655737705,0.0163934436));
	
	return color.r;
}

technique HighPassSharp <bool enabled = RESHADE_START_ENABLED; int toggle = HighPass_ToggleKey; >
{
	pass Luma
	{
		VertexShader = ReShade::VS_PostProcess;
		PixelShader = HPLuma;
		RenderTarget = HPlumaTex;
	}

	pass Sharp
	{
		VertexShader = ReShade::VS_PostProcess;
		PixelShader = SharpBlurFinal;
	}

}
#endif

#include EFFECT_CONFIG_UNDEF(Ioxa)

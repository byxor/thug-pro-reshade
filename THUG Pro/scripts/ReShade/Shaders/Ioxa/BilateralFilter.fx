
#include EFFECT_CONFIG(Ioxa)

//Bilateral Filter v1.0 by Ioxa
//Based on the Bilateral filter by mrharicot at https://www.shadertoy.com/view/4dfGDH

#if USE_BilateralFilter == 1

#pragma message "Bilateral Filter by Ioxa\n"

texture lumaTex{ Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = R8; };
sampler lumaSampler { Texture = lumaTex;};
//sampler2D lumaSampler { Texture = lumaTex; MinFilter = Linear; MagFilter = Linear; MipFilter = Linear; AddressV = Clamp; AddressU = Clamp; SRGBTexture = FALSE;};
#if Iterations >= 2
	texture SBlurTexFine{ Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = R8; };
	sampler SBlurSamplerFine { Texture = SBlurTexFine;};
	//sampler2D SBlurSamplerFine { Texture = SBlurTexFine; MinFilter = Linear; MagFilter = Linear; MipFilter = Linear; AddressU = Clamp; SRGBTexture = FALSE;};
#endif
#if Iterations >= 3
	texture SBlurTexMedium{ Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = R8; };
	sampler SBlurSamplerMedium { Texture = SBlurTexMedium;};
	//sampler2D SBlurSamplerMedium { Texture = SBlurTexMedium; MinFilter = Linear; MagFilter = Linear; MipFilter = Linear; AddressU = Clamp; SRGBTexture = FALSE;};
#endif
	
#if Use_SelectiveSharpening == 1
	texture sbBlurTex{ Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = R8; };
	sampler2D sbBlurSampler { Texture = sbBlurTex;};
	//sampler2D sbBlurSampler { Texture = sbBlurTex; MinFilter = Linear; MagFilter = Linear; MipFilter = Linear; AddressV = Clamp; AddressU = Clamp; SRGBTexture = FALSE;};
	texture FocusSharpTexPing{ Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = R8; };
	sampler FocusSharpPingSampler { Texture = FocusSharpTexPing;};
	//sampler2D FocusSharpPingSampler { Texture = FocusSharpTexPing; MinFilter = Linear; MagFilter = Linear; MipFilter = Linear; AddressV = Clamp; AddressU = Clamp; SRGBTexture = FALSE;};
	texture FocusSharpTexPong{ Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = R8; };
	sampler FocusSharpPongSampler { Texture = FocusSharpTexPong;};
	//sampler2D FocusSharpPongSampler { Texture = FocusSharpTexPong; MinFilter = Linear; MagFilter = Linear; MipFilter = Linear; AddressV = Clamp; AddressU = Clamp; SRGBTexture = FALSE;};
#endif

static const float3 LumCoef = float3(0.32786885,0.655737705,0.0163934436);

float sbDoSmoothstep(float edge0, float edge1, float x)
{
	x = ((x-edge0)/(edge1-edge0));
	x = x*x*(3-2*x);
	return x;
}

float sbDoSmootherstep(float edge0, float edge1, float x)
{
	x = ((x-edge0)/(edge1-edge0));
	return x*x*x*(x*(x*6-15)+10);
}

float sbDoSmoothererstep(float edge0, float edge1, float x)
{
	x = ((x-edge0)/(edge1-edge0));
	return x*x*x*x*(x*(x*(70-20*x)-84)+35);
}

float SurfaceBlurLuma(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD) : COLOR
{
	float3 color = tex2D(ReShade::BackBuffer, texcoord).rgb;
	float luma = dot(color,LumCoef);
	/*
	float sampleOffsetsX[13] = { 				  0.0, 			    1.3846153846, 			 			  0, 	 		  1.3846153846,     	   	 1.3846153846,     		    3.2307692308,     		  			  0,     		 3.2307692308,     		   3.2307692308,     		 1.3846153846,    		   1.3846153846,     		  3.2307692308,     		  3.2307692308 };
	float sampleOffsetsY[13] = {  				  0.0,   					   0, 	  		   1.3846153846, 	 		  1.3846153846,     		-1.3846153846,     					   0,     		   3.2307692308,     		 1.3846153846,    		  -1.3846153846,     		 3.2307692308,   		  -3.2307692308,     		  3.2307692308,    		     -3.2307692308 };
	float sampleWeights[13] = { 0.0957733978977875942, 0.1333986613666725565, 0.1333986613666725565, 0.0421828199486419528, 0.0421828199486419528, 0.0296441469844336464, 0.0296441469844336464, 0.0093739599979617454, 0.0093739599979617454, 0.0093739599979617454, 0.0093739599979617454, 0.0020831022264565991,  0.0020831022264565991 };
	int N = 13;
	
	float3 Blur = color.rgb;
	Blur *= sampleWeights[0];
	[loop]
	for(int j = 1; j < N; ++j) {
			Blur += tex2D(ReShade::BackBuffer, texcoord + float2(sampleOffsetsX[j] * ReShade::PixelSize.x, sampleOffsetsY[j] * ReShade::PixelSize.y)).rgb * sampleWeights[j];
			Blur += tex2D(ReShade::BackBuffer, texcoord - float2(sampleOffsetsX[j] * ReShade::PixelSize.x, sampleOffsetsY[j] * ReShade::PixelSize.y)).rgb * sampleWeights[j];
		}
	float LumaBlur = dot(Blur,LumCoef);
	LumaBlur = luma - LumaBlur;
	LumaBlur = abs(LumaBlur);
	color = float3(luma,LumaBlur,1.0);
	*/
	//color = float3(luma,1.0,1.0);
	return luma;
}

float normpdfE(in float v)
{
	float sigma = SigmaEdge;
	//v = abs(v);
	//return 0.39894*exp(-0.5*dot(v,v)/(sigma*sigma))/sigma;
	return exp(-(pow(v,2.0))/(2.0*pow(sigma,2.0)));
	//return lerp(1.0/sigma,sign(v)/v,step(sigma,abs(v)));
	//return 1/pow(1+(pow(v/sigma,2.0)),0.5);
	//return clamp(lerp(sin((3.1415927*v)/sigma)/(3.1415927*v*sigma),0.0,step(sigma,abs(v)*2)),0.0,1.0);
	//return 0.39894*exp(-0.5*v*v/(sigma*sigma))/sigma;
}
#if Use_SelectiveSharpening == 1 
void SurfaceBlur(float4 pos : SV_Position, float2 texcoord : TEXCOORD, out float blur : SV_Target0, out float detail : SV_Target1)
#else 
float3 SurfaceBlur(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD) : COLOR
#endif
{
	float3 Orig = tex2D(ReShade::BackBuffer, texcoord).rgb;
	
	float luma = dot(Orig,LumCoef);
	
	#if Iterations == 2
		#define FinalSampler SBlurSamplerFine
		//float luma2 = luma;
		//luma = tex2D(SBlurSamplerFine,texcoord).r;
	#elif Iterations == 3
		#define FinalSampler SBlurSamplerMedium
		//float luma2 = luma;
		//luma = tex2D(SBlurSamplerMedium,texcoord).r;
	#else
		#define FinalSampler lumaSampler
	#endif
		
	#if BlurWidth == 1
		static const int sampleOffsetsX[25] = {  0.0, 	   1, 	  0, 	 1,     1,     2,     0,     2,     2,     1,    1,     2,     2,     3,     0,     3,     3,     1,    -1, 3, 3, 2, 2, 3, 3 };
		static const int sampleOffsetsY[25] = {  0.0,     0, 	  1, 	 1,    -1,     0,     2,     1,    -1,     2,     -2,     2,    -2,     0,     3,     1,    -1,     3,     3, 2, -2, 3, -3, 3, -3};	
		float sampleWeights[5] = { 0.4285714286, 0.2857142857, 0.2857142857, 0.0816326531, 0.0816326531 };
		int N = 5;
	#elif BlurWidth == 2 
		static const int sampleOffsetsX[13] = {  0.0, 	   1, 	  0, 	 1,     1,     2,     0,     2,     2,     1,    1,     2,     2 };
		static const int sampleOffsetsY[13] = {  0.0,     0, 	  1, 	 1,    -1,     0,     2,     1,    -1,     2,     -2,     2,    -2};
		float sampleWeights[13] = { 0.3225806452, 0.2419354839, 0.2419354839, 0.0585327784, 0.0585327784, 0.0967741935, 0.0967741935, 0.0234131113, 0.0234131113, 0.0234131113, 0.0234131113, 0.0093652445, 0.0093652445 };
		int N = 13;
	#elif BlurWidth == 3
		static const float sampleOffsetsX[13] = { 				  0.0, 			    1.3846153846, 			 			  0, 	 		  1.3846153846,     	   	 1.3846153846,     		    3.2307692308,     		  			  0,     		 3.2307692308,     		   3.2307692308,     		 1.3846153846,    		   1.3846153846,     		  3.2307692308,     		  3.2307692308 };
		static const float sampleOffsetsY[13] = {  				  0.0,   					   0, 	  		   1.3846153846, 	 		  1.3846153846,     		-1.3846153846,     					   0,     		   3.2307692308,     		 1.3846153846,    		  -1.3846153846,     		 3.2307692308,   		  -3.2307692308,     		  3.2307692308,    		     -3.2307692308 };
		float sampleWeights[13] = { 0.227027027, 0.3162162162, 0.3162162162, 0.0999926954, 0.0999926954, 0.0702702703, 0.0702702703, 0.022220599, 0.022220599, 0.022220599, 0.022220599, 0.0049379109,  0.0049379109 };
		int N = 13;
	#else
		static const int sampleOffsetsX[25] = {  0.0, 	   1, 	  0, 	 1,     1,     2,     0,     2,     2,     1,    1,     2,     2,     3,     0,     3,     3,     1,    -1, 3, 3, 2, 2, 3, 3 };
		static const int sampleOffsetsY[25] = {  0.0,     0, 	  1, 	 1,    -1,     0,     2,     1,    -1,     2,     -2,     2,    -2,     0,     3,     1,    -1,     3,     3, 2, -2, 3, -3, 3, -3};	
			
	#endif
	
		float cc;
		float diff = 0.0;
		float factor = 0.0;
		float Z = 0.0;
		float final_color = 0.0;
		
		[loop]
		for(int k = 1; k < N; ++k) {
			cc = tex2D(FinalSampler, texcoord + float2(sampleOffsetsX[k] * ReShade::PixelSize.x, sampleOffsetsY[k] * ReShade::PixelSize.y)).r;
			diff = ((cc)-luma);
			factor = normpdfE(diff)*sampleWeights[k];
			Z += factor;
			final_color += factor*cc;
			
			cc = tex2D(FinalSampler, texcoord - float2(sampleOffsetsX[k] * ReShade::PixelSize.x, sampleOffsetsY[k] * ReShade::PixelSize.y)).r;
			diff = ((cc)-luma);
			factor = normpdfE(diff)*sampleWeights[k];
			Z += factor;
			final_color += factor*cc;
		}
	
	float Blur = final_color/Z;
	
#if Use_SelectiveSharpening == 1
	detail = luma - Blur;
	//detail = sbDoSmoothstep(LowDetailCutoff,HighDetailCutoff,detail);
	detail = 1-pow(max(0,1-abs(detail)),TextureMaskStrength);
	
	blur = Blur;
	//float4 finalColor = float4(1-pow(max(0,1-abs(detail)),MaskStrength),Blur,detail,luma); //(abs(detail))*5 //1-pow(max(0,1-abs(detail)),2.0)
#else
	float detail = luma - Blur;
	#if DetailCurveType == 1
		detail = lerp(-1.0,1.0,sbDoSmoothstep(-1.0,1.0,detail));
		//detail = sbDoSmoothstep(0.0,1.0,detail+0.5);
		//detail -= 0.5; 
	#elif DetailCurveType == 2
		detail = lerp(-1.0,1.0,sbDoSmootherstep(-1.0,1.0,detail));
		//detail = sbDoSmootherstep(0.0,1.0,detail+0.5);
		//detail -= 0.5;
	#elif DetailCurveType == 3
		detail = lerp(-1.0,1.0,sbDoSmoothererstep(-1.0,1.0,detail));
		//detail = sbDoSmoothererstep(0.0,1.0,detail+0.5);
		//detail -= 0.5;
	#endif

	detail *= DetailStrength;
	
	Blur += detail;
	float3 chroma = Orig-luma;
	float3 finalColor = 0.0;
	finalColor.rgb = Blur+chroma;

	finalColor.rgb = lerp(Orig,finalColor.rgb,BilateralStrength);
	return finalColor;
#endif
}

#if Use_SelectiveSharpening == 1
float TextureBlurH(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD) : COLOR
{
	float sampleOffsets[5] = { 0.0, 1.44, 3.36, 5.28, 7.2 };
	float sampleWeights[5] = { 0.1611802578, 0.2656817436, 0.1217707992, 0.0286519528, 0.0031667948 };
	int N = 5;
	
	float color = tex2D(FocusSharpPingSampler, texcoord).r;
	color *= sampleWeights[0];
	[loop]
	for(int j = 1; j < N; ++j) {
		color += tex2D(FocusSharpPingSampler, texcoord + float2(sampleOffsets[j] * ReShade::PixelSize.x,0.0)).r * sampleWeights[j];
		color += tex2D(FocusSharpPingSampler, texcoord - float2(sampleOffsets[j] * ReShade::PixelSize.x,0.0)).r * sampleWeights[j];
	}
	return color;
}

float3 TextureBlurV(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD) : COLOR
{
	float sampleOffsets[5] = { 0.0, 1.44, 3.36, 5.28, 7.2 };
	float sampleWeights[5] = { 0.1611802578, 0.2656817436, 0.1217707992, 0.0286519528, 0.0031667948 };
	int N = 5;
	
	float color = tex2D(FocusSharpPongSampler, texcoord).r;
	color *= sampleWeights[0];
	[loop]
	for(int j = 1; j < N; ++j) {
		color += tex2D(FocusSharpPongSampler, texcoord + float2(0.0,sampleOffsets[j] * ReShade::PixelSize.y)).r * sampleWeights[j];
		color += tex2D(FocusSharpPongSampler, texcoord - float2(0.0,sampleOffsets[j] * ReShade::PixelSize.y)).r * sampleWeights[j];
	}
	float Blur = tex2D(sbBlurSampler,texcoord).r;
	//float detail = color.b;
	float3 orig = tex2D(ReShade::BackBuffer,texcoord).rgb;
	float3 chroma = orig - dot(orig,LumCoef);
	float detail = dot(orig,LumCoef)-Blur;
	
	#if DetailCurveType == 1
		float detailCurve = lerp(-1.0,1.0,sbDoSmoothstep(-1.0,1.0,detail)); 
	#elif DetailCurveType == 2
		float detailCurve = lerp(-1.0,1.0,sbDoSmootherstep(-1.0,1.0,detail));
	#elif DetailCurveType == 3
		float detailCurve = lerp(-1.0,1.0,sbDoSmoothererstep(-1.0,1.0,detail));
	#endif
	
	//detail = lerp(detail*LowDetailStrength,detailCurve*HighDetailStrength,smoothstep(LowDetailCutoff,HighDetailCutoff,color.r));
	//detail = lerp(detail,detailCurve*DetailStrength,smoothstep(LowDetailCutoff,HighDetailCutoff,color));
	detail = lerp(detail,detailCurve*DetailStrength,clamp(sbDoSmoothstep(LowDetailCutoff,HighDetailCutoff,color),0.0,1.0));
	detail = clamp(detail,-1.0,1.0);
	//detail = lerp(detail,detailCurve*DetailStrength,color);
	
	Blur += detail;
	float3 FinalColor = chroma + Blur;
	FinalColor.rgb = lerp(orig,FinalColor.rgb,BilateralStrength);
	//chroma += Blur;
#if ViewTextureMask == 1
	FinalColor = smoothstep(LowDetailCutoff,HighDetailCutoff,color);
#else

#endif
	return FinalColor;
}
#endif

#if Iterations >= 2
float3 SurfaceBlurFine(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD) : COLOR
{
	//float3 Orig = tex2D(ReShade::BackBuffer, texcoord).rgb;
	//float luma = dot(Orig,LumCoef);
	float luma = tex2D(lumaSampler, texcoord).r;
	
	#if BlurWidth == 1
		static const int sampleOffsetsX[25] = {  0.0, 	   1, 	  0, 	 1,     1,     2,     0,     2,     2,     1,    1,     2,     2,     3,     0,     3,     3,     1,    -1, 3, 3, 2, 2, 3, 3 };
		static const int sampleOffsetsY[25] = {  0.0,     0, 	  1, 	 1,    -1,     0,     2,     1,    -1,     2,     -2,     2,    -2,     0,     3,     1,    -1,     3,     3, 2, -2, 3, -3, 3, -3};
		float sampleWeights[5] = { 0.4285714286, 0.2857142857, 0.2857142857, 0.0816326531, 0.0816326531 };
		int N = 5;
	#elif BlurWidth == 2 
		static const int sampleOffsetsX[25] = {  0.0, 	   1, 	  0, 	 1,     1,     2,     0,     2,     2,     1,    1,     2,     2,     3,     0,     3,     3,     1,    -1, 3, 3, 2, 2, 3, 3 };
		static const int sampleOffsetsY[25] = {  0.0,     0, 	  1, 	 1,    -1,     0,     2,     1,    -1,     2,     -2,     2,    -2,     0,     3,     1,    -1,     3,     3, 2, -2, 3, -3, 3, -3};
		float sampleWeights[25] = { 0.2755905512, 0.2204724409, 0.2204724409, 0.0486080972, 0.0486080972, 0.1102362205, 0.1102362205, 0.0243040486, 0.0243040486, 0.0243040486, 0.0243040486, 0.0121520243, 0.0121520243,  0.031496063,  0.031496063, 0.0069440139, 0.0069440139, 0.0069440139, 0.0069440139, 0.0034720069, 0.0034720069, 0.0034720069, 0.0034720069, 0.000992002, 0.000992002 };
		int N = 13;
	#else
		float sampleOffsetsX[13] = { 				  0.0, 			    1.3846153846, 			 			  0, 	 		  1.3846153846,     	   	 1.3846153846,     		    3.2307692308,     		  			  0,     		 3.2307692308,     		   3.2307692308,     		 1.3846153846,    		   1.3846153846,     		  3.2307692308,     		  3.2307692308 };
		float sampleOffsetsY[13] = {  				  0.0,   					   0, 	  		   1.3846153846, 	 		  1.3846153846,     		-1.3846153846,     					   0,     		   3.2307692308,     		 1.3846153846,    		  -1.3846153846,     		 3.2307692308,   		  -3.2307692308,     		  3.2307692308,    		     -3.2307692308 };
		float sampleWeights[13] = { 0.227027027, 0.3162162162, 0.3162162162, 0.0999926954, 0.0999926954, 0.0702702703, 0.0702702703, 0.022220599, 0.022220599, 0.022220599, 0.022220599, 0.0049379109,  0.0049379109 };
		float N = 13;
	#endif	
		
		float color;
		float diff;
		float factor;
		float Z = 0.0;
		float final_color = 0.0;
		
		[loop]
		for(int k = 1; k < N; ++k) {
			color = tex2D(lumaSampler, texcoord + float2(sampleOffsetsX[k] * ReShade::PixelSize.x, sampleOffsetsY[k] * ReShade::PixelSize.y)).r;
			//diff = (log10(luma) - log10(color));
			diff = (color-luma);
			factor = normpdfE(diff)*sampleWeights[k];
			Z += factor;
			final_color += factor*color;
			color = tex2D(lumaSampler, texcoord - float2(sampleOffsetsX[k] * ReShade::PixelSize.x, sampleOffsetsY[k] * ReShade::PixelSize.y)).r;
			//diff = (log10(luma) - log10(color));
			diff = (color-luma);
			factor = normpdfE(diff)*sampleWeights[k];
			Z += factor;
			final_color += factor*color;
		}
		
		float Blur = final_color/Z;

		return saturate(Blur);
}
#endif

#if Iterations >= 3
float3 SurfaceBlurMedium(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD) : COLOR
{

	//float3 Orig = tex2D(ReShade::BackBuffer, texcoord).rgb;
	//float luma = dot(Orig,LumCoef);
	float luma = tex2D(lumaSampler, texcoord).r;
	//float luma = tex2D(SBlurSamplerFine, texcoord).r;
	
	#if BlurWidth == 1
		static const int sampleOffsetsX[25] = {  0.0, 	   1, 	  0, 	 1,     1,     2,     0,     2,     2,     1,    1,     2,     2,     3,     0,     3,     3,     1,    -1, 3, 3, 2, 2, 3, 3 };
		static const int sampleOffsetsY[25] = {  0.0,     0, 	  1, 	 1,    -1,     0,     2,     1,    -1,     2,     -2,     2,    -2,     0,     3,     1,    -1,     3,     3, 2, -2, 3, -3, 3, -3};
		float sampleWeights[5] = { 0.4285714286, 0.2857142857, 0.2857142857, 0.0816326531, 0.0816326531 };
		int N = 5;
	#elif BlurWidth == 2 
		static const int sampleOffsetsX[25] = {  0.0, 	   1, 	  0, 	 1,     1,     2,     0,     2,     2,     1,    1,     2,     2,     3,     0,     3,     3,     1,    -1, 3, 3, 2, 2, 3, 3 };
		static const int sampleOffsetsY[25] = {  0.0,     0, 	  1, 	 1,    -1,     0,     2,     1,    -1,     2,     -2,     2,    -2,     0,     3,     1,    -1,     3,     3, 2, -2, 3, -3, 3, -3};
		float sampleWeights[25] = { 0.2755905512, 0.2204724409, 0.2204724409, 0.0486080972, 0.0486080972, 0.1102362205, 0.1102362205, 0.0243040486, 0.0243040486, 0.0243040486, 0.0243040486, 0.0121520243, 0.0121520243,  0.031496063,  0.031496063, 0.0069440139, 0.0069440139, 0.0069440139, 0.0069440139, 0.0034720069, 0.0034720069, 0.0034720069, 0.0034720069, 0.000992002, 0.000992002 };
		int N = 13;
	#else
		float sampleOffsetsX[13] = { 				  0.0, 			    1.3846153846, 			 			  0, 	 		  1.3846153846,     	   	 1.3846153846,     		    3.2307692308,     		  			  0,     		 3.2307692308,     		   3.2307692308,     		 1.3846153846,    		   1.3846153846,     		  3.2307692308,     		  3.2307692308 };
		float sampleOffsetsY[13] = {  				  0.0,   					   0, 	  		   1.3846153846, 	 		  1.3846153846,     		-1.3846153846,     					   0,     		   3.2307692308,     		 1.3846153846,    		  -1.3846153846,     		 3.2307692308,   		  -3.2307692308,     		  3.2307692308,    		     -3.2307692308 };
		float sampleWeights[13] = { 0.227027027, 0.3162162162, 0.3162162162, 0.0999926954, 0.0999926954, 0.0702702703, 0.0702702703, 0.022220599, 0.022220599, 0.022220599, 0.022220599, 0.0049379109,  0.0049379109 };
		float N = 13;
	#endif	
		
		float color;
		float diff;
		float factor;
		float Z = 0.0;
		float final_color = 0.0;
		
		[loop]
		for(int k = 1; k < N; ++k) {
			color = tex2D(SBlurSamplerFine, texcoord + float2(sampleOffsetsX[k] * ReShade::PixelSize.x, sampleOffsetsY[k] * ReShade::PixelSize.y)).r;
			//diff = (log10(luma) - log10(color));
			diff = (color-luma);
			factor = normpdfE(diff)*sampleWeights[k];
			Z += factor;
			final_color += factor*color;
			color = tex2D(SBlurSamplerFine, texcoord - float2(sampleOffsetsX[k] * ReShade::PixelSize.x, sampleOffsetsY[k] * ReShade::PixelSize.y)).r;
			//diff = (log10(luma) - log10(color));
			diff = (color-luma);
			factor = normpdfE(diff)*sampleWeights[k];
			factor = normpdfE(diff)*sampleWeights[k];
			Z += factor;
			final_color += factor*color;
		}
		
		float Blur = final_color/Z;
	
		return saturate(Blur);
}
#endif

technique BilateralFilter_Tech <bool enabled = RESHADE_START_ENABLED; int toggle = BilateralFilterr_ToggleKey; > 
{
	pass passThru
	{
		VertexShader = ReShade::VS_PostProcess;
		PixelShader = SurfaceBlurLuma;
		RenderTarget = lumaTex;
	}
		
#if Iterations >= 2	
	pass FineBlur
	{
		VertexShader = ReShade::VS_PostProcess;
		PixelShader = SurfaceBlurFine;
		RenderTarget = SBlurTexFine;
	}
#endif	
#if Iterations >= 3
	pass MediumBlur
	{
		VertexShader = ReShade::VS_PostProcess;
		PixelShader = SurfaceBlurMedium;
		RenderTarget = SBlurTexMedium;
	}
#endif	
	pass BlurFinal
	{
		VertexShader = ReShade::VS_PostProcess;
		PixelShader = SurfaceBlur;
		#if Use_SelectiveSharpening == 1 
			RenderTarget = sbBlurTex;
			RenderTarget1 = FocusSharpTexPing;
		#endif
	}
#if Use_SelectiveSharpening == 1
	pass MediumBlur
	{
		VertexShader = ReShade::VS_PostProcess;
		PixelShader = TextureBlurH;
		RenderTarget = FocusSharpTexPong;
	}	
	
	pass MediumBlur
	{
		VertexShader = ReShade::VS_PostProcess;
		PixelShader = TextureBlurV;
	}
#endif
}

#endif

#include EFFECT_CONFIG_UNDEF(Ioxa)

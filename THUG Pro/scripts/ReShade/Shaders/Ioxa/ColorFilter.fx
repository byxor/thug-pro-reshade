
#include EFFECT_CONFIG(Ioxa)

#if USE_ColorFilter == 1
//Color Filter for ReShade + Framework by Ioxa
//Version 0.7

#pragma message "Color Filter by Ioxa\n"

	#define CoefLuma_F float3(0.333333,0.333333,0.333333)

float ClrDoSmoothererstep(float edge0, float edge1, float x)
{
	x = ((x-edge0)/(edge1-edge0));
	return x*x*x*x*(x*(x*(70-20*x)-84)+35);
}
	
float3 FilterBlend(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD) : COLOR
{

	float4 filter = tex2D(ReShade::BackBuffer, texcoord);

	float luma = dot(filter.rgb,CoefLuma_F);
	//float luma = 0.5*(max(filter.r,max(filter.g,filter.b)) + min(filter.r,min(filter.g,filter.b)));

	//float3 color = filter.rgb;

	float3 A = 0.0;
	float3 B = filter.rgb;
	
	//if (AdjustSaturation != 1.00)
	filter.rgb = lerp(dot(filter.rgb,CoefLuma_F),filter.rgb,AdjustSaturation);
	/*
	if (CurveRed != 0.00)
		//filter.r = pow(abs(filter.r),CurveRed);
		filter.r = lerp(filter.r,ClrDoSmoothererstep(0.0,1.0,filter.r),CurveRed);
	if (CurveGreen != 0.00)
		//filter.g = pow(abs(filter.g),CurveGreen);
		filter.g = lerp(filter.g,ClrDoSmoothererstep(0.0,1.0,filter.g),CurveGreen);
	if (CurveBlue != 0.00)
		//filter.b = pow(abs(filter.b),CurveBlue);
		filter.b = lerp(filter.b,ClrDoSmoothererstep(0.0,1.0,filter.b),CurveBlue);
	*/
	//color = filter.rgb;

	A = 0.0;
	B = filter.rgb;
	/*
	if (CurveRed != 0.00)
		B.r = lerp(B.r,ClrDoSmoothererstep(0.0,1.0,B.r),CurveRed);
	if (CurveGreen != 0.00)
		B.g = lerp(B.g,ClrDoSmoothererstep(0.0,1.0,B.g),CurveGreen);
	if (CurveBlue != 0.00)
		B.b = lerp(B.b,ClrDoSmoothererstep(0.0,1.0,B.b),CurveBlue);
	*/
	
	#if DarkColorSelection == 1 //blue
		#define DarkColor float3(36.0/255.0,24.0/255.0,130.0/255.0)
		#elif DarkColorSelection == 2 //purple
		#define DarkColor float3(85.0/255.0,26.0/255.0,139.0/255.0)
		#elif DarkColorSelection == 3 //red
		#define DarkColor float3(139.0/255.0,35.0/255.0,35.0/255.0)
		#elif DarkColorSelection == 4 //orange
		#define DarkColor float3(205.0/255.0,102.0/255.0,5.0/255.0)
		#elif DarkColorSelection == 5 //green
		#define DarkColor float3(47.0/255.0,79.0/255.0,47.0/255.0)
		#elif DarkColorSelection == 6 //olive
		#define DarkColor float3(107.0/255.0,142.0/255.0,35.0/255.0)
		#elif DarkColorSelection == 7 //brown
		#define DarkColor float3(92.0/255.0,64.0/255.0,51.0/255.0)
		#elif DarkColorSelection == 8 //dark cyan
		#define DarkColor float3(47.0/255.0,79.0/255.0,79.0/255.0)
		#elif DarkColorSelection == 9 //dark yellow
		#define DarkColor float3(139.0/255.0,101.0/255.0,8.0/255.0)
		#elif DarkColorSelection == 10 //grey
		#define DarkColor float3(64.0/255.0,64.0/255.0,64.0/255.0)
		#else 
		#define DarkColor float3(DarkColorRed/255.0,DarkColorGreen/255.0,DarkColorBlue/255.0)
	#endif
		
	#if BrightColorSelection == 1 //off-white
		#define BrightColor float3(205.0/255.0,186.0/255.0,150.0/255.0) 
		#elif BrightColorSelection == 2 //light yellow
		#define BrightColor float3(1.0,1.0,0.50) 
		#elif BrightColorSelection == 3 //yellow
		#define BrightColor float3(255.0/255.0,193.0/255.0,37.0/255.0)
		#elif BrightColorSelection == 4 //orange
		#define BrightColor float3(255.0/255.0,127.0/255.0,0.0/255.0)
		#elif BrightColorSelection == 5 //red
		#define BrightColor float3(255.0/255.0,36.0/255.0,0.0/255.0)
		#elif BrightColorSelection == 6 //blue violet
		#define BrightColor float3(138.0/255.0,43.0/255.0,226.0/255.0)
		#elif BrightColorSelection == 7 //blue
		#define BrightColor float3(65.0/255.0,86.0/255.0,197.0/255.0)
		#elif BrightColorSelection == 8 //cyan
		#define BrightColor float3(72.0/209.0,204.0/255.0,255.0/255.0)
		#elif BrightColorSelection == 9 //green
		#define BrightColor float3(35.0/255.0,142.0/255.0,35.0/255.0)
		#elif BrightColorSelection == 10 //brown
		#define BrightColor float3(139.0/255.0,115.0/255.0,85.0/255.0)
		#else
		#define BrightColor float3(BrightColorRed/255.0,BrightColorGreen/255.0,BrightColorBlue/255.0)
	#endif
	
	#define DarkCutoff DarkColorAmt
	#define BrightCutoff 1.00-BrightColorAmt+0.001
	
	
		float3 C = saturate(lerp(0,1,smoothstep(0.0,1.0,luma)));	
		A = saturate(lerp(saturate(DarkColor),saturate(BrightColor),smoothstep(DarkCutoff,BrightCutoff,C)));
		
		//Additional filter color adjustments
		//float3 Alow = pow(A,1.0001+LowPower);
		float3 Alow = A+float3(DarkRed,DarkGreen,DarkBlue);
		Alow = pow(abs(Alow),1.0001+LowPower);
		Alow = saturate(Alow);
		float3 Ahigh = pow(abs(A),1.0001-HighPower);
		//float3 Ahigh = A+float3(BrightRed,BrightGreen,BrightBlue);
		Ahigh += float3(BrightRed,BrightGreen,BrightBlue);
		//Ahigh = pow(abs(Ahigh),1.0001-HighPower);
		Ahigh = saturate(Ahigh);
		A += float3(MidRed,MidGreen,MidBlue);
		Alow = lerp(Alow,A,smoothstep(0.0,0.3333,luma)); //0.1960784
		Ahigh = lerp(A,Ahigh,smoothstep(0.6666,1.0,luma)); //0.80392157
		//A = lerp(Alow,Ahigh,0.50);
		A = lerp(Alow,Ahigh,smoothstep(0.1960784,0.80392157,luma));
		A = saturate(A);

		#if ViewFilter == 1 
		filter.rgb = A;
		//color.rgb = A;
		#else 
			
			#if FilterBlendMode == 1
				//multiply
				A = 2*B*A;
			#elif FilterBlendMode == 2
				//softlight
				A = lerp((2*B-1)*(A-pow(A,2))+A, (2*B-1)*(pow(A,0.5)-A)+A,step(0.501,luma));
				//A = lerp((2*A-1)*(B-pow(B,2))+B, (2*A-1)*(pow(B,0.5)-B)+B,step(0.501,luma));
			#elif FilterBlendMode == 3 
				//linear light
				A = B+2*A-1;
			#elif FilterBlendMode == 4
				//Burn and Dodge
				A = lerp(A+B-1,A+B,smoothstep(0.0,1.0,luma));
				//A = saturate(A);
			#elif FilterBlendMode == 5 
				//screen
				A = 1.0 - (2*(1.0-B)*(1.0-A));
				//A + 1-(1-B)*(1-A);
			#elif FilterBlendMode == 6
				//darken only 
				A = min(A,color.rgb);
			#elif FilterBlendMode == 7
				//Burn and Dodge
				//A = 0.5-2*(B-0.5)*(A-0.5);
				A = lerp(A+B-1,A+B,smoothstep(0.0,1.0,luma));
			#elif FilterBlendMode == 8 
				//linear light
				A = B+2*A-1;
			#elif FilterBlendMode == 9 
				A = lerp(float3(0.0,0.0,0.0),float3(1.0,1.0,1.0),smoothstep(A>1-B,A<1-B,luma));
			#else
				//overlay
				A = lerp(2*B*A, 1.0 - 2*(1.0-B)*(1.0-A), step(0.5,luma));
			#endif	
		
		#if FilterBlendIfDark > 0 || FilterBlendIfBright < 255 
			#define cBlendIfD (FilterBlendIfDark/255.0)
			#define cBlendIfL (FilterBlendIfBright/255.0)
			float mix = dot(filter.rgb, 0.333333);
			#if FilterBlendIfDark > 0
				A = lerp(filter.rgb,A,smoothstep(cBlendIfD-(cBlendIfD*0.2),cBlendIfD+(cBlendIfD*0.2),mix));
			#endif
			#if FilterBlendIfBright < 255
				A = lerp(A,filter.rgb,smoothstep(cBlendIfL-(cBlendIfL*0.2),cBlendIfL+(cBlendIfL*0.2),mix));
			#endif
		#endif
		
		filter.rgb = lerp(filter.rgb,A,FilterStrength);

		#endif

	#if ViewFilter == 1
	if (FilterExposure != 1.00)
	filter.rgb = saturate(pow(abs(filter.rgb),FilterExposure));
	#else
	if (FilterExposure != 1.00)
	filter.rgb = saturate(pow(abs(filter.rgb),FilterExposure));

	if (AdjustShadows != 0.00)
	filter.rgb = lerp(saturate(lerp(filter.rgb,pow(abs(filter.rgb),0.75),AdjustShadows)),filter.rgb,smoothstep(0.00,0.20,luma));
	#endif
	
	if (CurveRed != 0.00)
		//filter.r = pow(abs(filter.r),CurveRed);
		filter.r = lerp(filter.r,ClrDoSmoothererstep(0.0,1.0,filter.r),CurveRed);
	if (CurveGreen != 0.00)
		//filter.g = pow(abs(filter.g),CurveGreen);
		filter.g = lerp(filter.g,ClrDoSmoothererstep(0.0,1.0,filter.g),CurveGreen);
	if (CurveBlue != 0.00)
		//filter.b = pow(abs(filter.b),CurveBlue);
		filter.b = lerp(filter.b,ClrDoSmoothererstep(0.0,1.0,filter.b),CurveBlue);
	
	#if DitherFilter == 1
		filter = saturate(filter);
		//Found at https://www.shadertoy.com/view/MslGR8
		// Iestyn's RGB dither (7 asm instructions) from Portal 2 X360, slightly modified for VR
		float3 vDither = float3(dot(float2(171.0, 231.0), texcoord * ReShade::ScreenSize).xxx);
		vDither.rgb = frac( vDither.rgb / float3( 103.0, 71.0, 97.0 ) ) - 0.5;
		filter.rgb += (vDither.rgb / 255.0);
	#endif
	
	return saturate(filter.rgb);
}

technique Filter_Tech <bool enabled = RESHADE_START_ENABLED; int toggle = Filter_ToggleKey; >
{

	pass G 
	{
		VertexShader = ReShade::VS_PostProcess;
		PixelShader = FilterBlend;
	}
	
}
#endif

#include EFFECT_CONFIG_UNDEF(Ioxa)

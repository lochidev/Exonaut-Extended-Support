Shader "Hidden/HollywoodFlareBlurShader" {
Properties {
 _MainTex ("Base (RGB)", 2D) = "" {}
 _NonBlurredTex ("Base (RGB)", 2D) = "" {}
}
SubShader { 
 Pass {
  ZTest Always
  ZWrite Off
  Cull Off
  Fog { Mode Off }
Program "vp" {
SubProgram "opengl " {
Bind "vertex" Vertex
Bind "texcoord" TexCoord0
"!!ARBvp1.0
# 5 ALU
PARAM c[5] = { program.local[0],
		state.matrix.mvp };
MOV result.texcoord[0].xy, vertex.texcoord[0];
DP4 result.position.w, vertex.position, c[4];
DP4 result.position.z, vertex.position, c[3];
DP4 result.position.y, vertex.position, c[2];
DP4 result.position.x, vertex.position, c[1];
END
# 5 instructions, 0 R-regs
"
}
SubProgram "d3d9 " {
Bind "vertex" Vertex
Bind "texcoord" TexCoord0
Matrix 0 [glstate_matrix_mvp]
"vs_2_0
; 5 ALU
dcl_position0 v0
dcl_texcoord0 v1
mov oT0.xy, v1
dp4 oPos.w, v0, c3
dp4 oPos.z, v0, c2
dp4 oPos.y, v0, c1
dp4 oPos.x, v0, c0
"
}
}
Program "fp" {
SubProgram "opengl " {
Vector 0 [tintColor]
SetTexture 0 [_MainTex] 2D
SetTexture 1 [_NonBlurredTex] 2D
"!!ARBfp1.0
OPTION ARB_precision_hint_fastest;
# 8 ALU, 2 TEX
PARAM c[2] = { program.local[0],
		{ 0.5 } };
TEMP R0;
TEMP R1;
TEMP R2;
TEX R0, fragment.texcoord[0], texture[0], 2D;
TEX R1, fragment.texcoord[0], texture[1], 2D;
DP4 R2.x, c[0], c[0];
RSQ R2.x, R2.x;
MUL R2, R2.x, c[0];
MUL R1, R1, R2;
MAD R0, R0, c[0], R1;
MUL result.color, R0, c[1].x;
END
# 8 instructions, 3 R-regs
"
}
SubProgram "d3d9 " {
Vector 0 [tintColor]
SetTexture 0 [_MainTex] 2D
SetTexture 1 [_NonBlurredTex] 2D
"ps_2_0
; 7 ALU, 2 TEX
dcl_2d s0
dcl_2d s1
def c1, 0.50000000, 0, 0, 0
dcl t0.xy
texld r1, t0, s0
texld r0, t0, s1
dp4 r2.x, c0, c0
rsq r2.x, r2.x
mul r2, r2.x, c0
mul r0, r0, r2
mad r0, r1, c0, r0
mul r0, r0, c1.x
mov_pp oC0, r0
"
}
}
 }
}
Fallback Off
}
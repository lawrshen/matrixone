// Code generated by command: go run avx2.go -out avx2.s -stubs avx2_stubs.go. DO NOT EDIT.

#include "textflag.h"

// func int8MaxAvx2Asm(x []int8, r []int8)
// Requires: AVX, AVX2, SSE2
TEXT ·int8MaxAvx2Asm(SB), NOSPLIT, $0-48
	MOVQ         x_base+0(FP), AX
	MOVQ         r_base+24(FP), CX
	MOVQ         x_len+8(FP), DX
	MOVQ         $0x0000000000000080, BX
	MOVQ         BX, X0
	VPBROADCASTB X0, Y0
	VMOVDQU      Y0, Y1
	VMOVDQU      Y0, Y2
	VMOVDQU      Y0, Y3
	VMOVDQU      Y0, Y4
	VMOVDQU      Y0, Y5
	VMOVDQU      Y0, Y6
	VMOVDQU      Y0, Y7
	VMOVDQU      Y0, Y8
	VMOVDQU      Y0, Y9
	VMOVDQU      Y0, Y10
	VMOVDQU      Y0, Y11
	VMOVDQU      Y0, Y12
	VMOVDQU      Y0, Y13
	VMOVDQU      Y0, Y14
	VMOVDQU      Y0, Y15

int8MaxBlockLoop:
	CMPQ    DX, $0x00000200
	JL      int8MaxTailLoop
	VPMAXSB (AX), Y0, Y0
	VPMAXSB 32(AX), Y1, Y1
	VPMAXSB 64(AX), Y2, Y2
	VPMAXSB 96(AX), Y3, Y3
	VPMAXSB 128(AX), Y4, Y4
	VPMAXSB 160(AX), Y5, Y5
	VPMAXSB 192(AX), Y6, Y6
	VPMAXSB 224(AX), Y7, Y7
	VPMAXSB 256(AX), Y8, Y8
	VPMAXSB 288(AX), Y9, Y9
	VPMAXSB 320(AX), Y10, Y10
	VPMAXSB 352(AX), Y11, Y11
	VPMAXSB 384(AX), Y12, Y12
	VPMAXSB 416(AX), Y13, Y13
	VPMAXSB 448(AX), Y14, Y14
	VPMAXSB 480(AX), Y15, Y15
	ADDQ    $0x00000200, AX
	SUBQ    $0x00000200, DX
	JMP     int8MaxBlockLoop

int8MaxTailLoop:
	CMPQ    DX, $0x00000020
	JL      int8MaxDone
	VPMAXSB (AX), Y0, Y0
	ADDQ    $0x00000020, AX
	SUBQ    $0x00000020, DX
	JMP     int8MaxTailLoop

int8MaxDone:
	VPMAXSB      Y0, Y1, Y0
	VPMAXSB      Y0, Y2, Y0
	VPMAXSB      Y0, Y3, Y0
	VPMAXSB      Y0, Y4, Y0
	VPMAXSB      Y0, Y5, Y0
	VPMAXSB      Y0, Y6, Y0
	VPMAXSB      Y0, Y7, Y0
	VPMAXSB      Y0, Y8, Y0
	VPMAXSB      Y0, Y9, Y0
	VPMAXSB      Y0, Y10, Y0
	VPMAXSB      Y0, Y11, Y0
	VPMAXSB      Y0, Y12, Y0
	VPMAXSB      Y0, Y13, Y0
	VPMAXSB      Y0, Y14, Y0
	VPMAXSB      Y0, Y15, Y0
	VEXTRACTI128 $0x01, Y0, X1
	VPMAXSB      X1, X0, X0
	CMPQ         DX, $0x00000010
	JL           int8MaxDone1
	VPMAXSB      (AX), X0, X0

int8MaxDone1:
	MOVOU X0, (CX)
	RET

// func int16MaxAvx2Asm(x []int16, r []int16)
// Requires: AVX, AVX2, SSE2
TEXT ·int16MaxAvx2Asm(SB), NOSPLIT, $0-48
	MOVQ         x_base+0(FP), AX
	MOVQ         r_base+24(FP), CX
	MOVQ         x_len+8(FP), DX
	MOVQ         $0x0000000000008000, BX
	MOVQ         BX, X0
	VPBROADCASTW X0, Y0
	VMOVDQU      Y0, Y1
	VMOVDQU      Y0, Y2
	VMOVDQU      Y0, Y3
	VMOVDQU      Y0, Y4
	VMOVDQU      Y0, Y5
	VMOVDQU      Y0, Y6
	VMOVDQU      Y0, Y7
	VMOVDQU      Y0, Y8
	VMOVDQU      Y0, Y9
	VMOVDQU      Y0, Y10
	VMOVDQU      Y0, Y11
	VMOVDQU      Y0, Y12
	VMOVDQU      Y0, Y13
	VMOVDQU      Y0, Y14
	VMOVDQU      Y0, Y15

int16MaxBlockLoop:
	CMPQ    DX, $0x00000100
	JL      int16MaxTailLoop
	VPMAXSW (AX), Y0, Y0
	VPMAXSW 32(AX), Y1, Y1
	VPMAXSW 64(AX), Y2, Y2
	VPMAXSW 96(AX), Y3, Y3
	VPMAXSW 128(AX), Y4, Y4
	VPMAXSW 160(AX), Y5, Y5
	VPMAXSW 192(AX), Y6, Y6
	VPMAXSW 224(AX), Y7, Y7
	VPMAXSW 256(AX), Y8, Y8
	VPMAXSW 288(AX), Y9, Y9
	VPMAXSW 320(AX), Y10, Y10
	VPMAXSW 352(AX), Y11, Y11
	VPMAXSW 384(AX), Y12, Y12
	VPMAXSW 416(AX), Y13, Y13
	VPMAXSW 448(AX), Y14, Y14
	VPMAXSW 480(AX), Y15, Y15
	ADDQ    $0x00000200, AX
	SUBQ    $0x00000100, DX
	JMP     int16MaxBlockLoop

int16MaxTailLoop:
	CMPQ    DX, $0x00000010
	JL      int16MaxDone
	VPMAXSW (AX), Y0, Y0
	ADDQ    $0x00000020, AX
	SUBQ    $0x00000010, DX
	JMP     int16MaxTailLoop

int16MaxDone:
	VPMAXSW      Y0, Y1, Y0
	VPMAXSW      Y0, Y2, Y0
	VPMAXSW      Y0, Y3, Y0
	VPMAXSW      Y0, Y4, Y0
	VPMAXSW      Y0, Y5, Y0
	VPMAXSW      Y0, Y6, Y0
	VPMAXSW      Y0, Y7, Y0
	VPMAXSW      Y0, Y8, Y0
	VPMAXSW      Y0, Y9, Y0
	VPMAXSW      Y0, Y10, Y0
	VPMAXSW      Y0, Y11, Y0
	VPMAXSW      Y0, Y12, Y0
	VPMAXSW      Y0, Y13, Y0
	VPMAXSW      Y0, Y14, Y0
	VPMAXSW      Y0, Y15, Y0
	VEXTRACTI128 $0x01, Y0, X1
	VPMAXSW      X1, X0, X0
	CMPQ         DX, $0x00000008
	JL           int16MaxDone1
	VPMAXSW      (AX), X0, X0

int16MaxDone1:
	MOVOU X0, (CX)
	RET

// func int32MaxAvx2Asm(x []int32, r []int32)
// Requires: AVX, AVX2, SSE2
TEXT ·int32MaxAvx2Asm(SB), NOSPLIT, $0-48
	MOVQ         x_base+0(FP), AX
	MOVQ         r_base+24(FP), CX
	MOVQ         x_len+8(FP), DX
	MOVQ         $0x0000000080000000, BX
	MOVQ         BX, X0
	VPBROADCASTD X0, Y0
	VMOVDQU      Y0, Y1
	VMOVDQU      Y0, Y2
	VMOVDQU      Y0, Y3
	VMOVDQU      Y0, Y4
	VMOVDQU      Y0, Y5
	VMOVDQU      Y0, Y6
	VMOVDQU      Y0, Y7
	VMOVDQU      Y0, Y8
	VMOVDQU      Y0, Y9
	VMOVDQU      Y0, Y10
	VMOVDQU      Y0, Y11
	VMOVDQU      Y0, Y12
	VMOVDQU      Y0, Y13
	VMOVDQU      Y0, Y14
	VMOVDQU      Y0, Y15

int32MaxBlockLoop:
	CMPQ    DX, $0x00000080
	JL      int32MaxTailLoop
	VPMAXSD (AX), Y0, Y0
	VPMAXSD 32(AX), Y1, Y1
	VPMAXSD 64(AX), Y2, Y2
	VPMAXSD 96(AX), Y3, Y3
	VPMAXSD 128(AX), Y4, Y4
	VPMAXSD 160(AX), Y5, Y5
	VPMAXSD 192(AX), Y6, Y6
	VPMAXSD 224(AX), Y7, Y7
	VPMAXSD 256(AX), Y8, Y8
	VPMAXSD 288(AX), Y9, Y9
	VPMAXSD 320(AX), Y10, Y10
	VPMAXSD 352(AX), Y11, Y11
	VPMAXSD 384(AX), Y12, Y12
	VPMAXSD 416(AX), Y13, Y13
	VPMAXSD 448(AX), Y14, Y14
	VPMAXSD 480(AX), Y15, Y15
	ADDQ    $0x00000200, AX
	SUBQ    $0x00000080, DX
	JMP     int32MaxBlockLoop

int32MaxTailLoop:
	CMPQ    DX, $0x00000008
	JL      int32MaxDone
	VPMAXSD (AX), Y0, Y0
	ADDQ    $0x00000020, AX
	SUBQ    $0x00000008, DX
	JMP     int32MaxTailLoop

int32MaxDone:
	VPMAXSD      Y0, Y1, Y0
	VPMAXSD      Y0, Y2, Y0
	VPMAXSD      Y0, Y3, Y0
	VPMAXSD      Y0, Y4, Y0
	VPMAXSD      Y0, Y5, Y0
	VPMAXSD      Y0, Y6, Y0
	VPMAXSD      Y0, Y7, Y0
	VPMAXSD      Y0, Y8, Y0
	VPMAXSD      Y0, Y9, Y0
	VPMAXSD      Y0, Y10, Y0
	VPMAXSD      Y0, Y11, Y0
	VPMAXSD      Y0, Y12, Y0
	VPMAXSD      Y0, Y13, Y0
	VPMAXSD      Y0, Y14, Y0
	VPMAXSD      Y0, Y15, Y0
	VEXTRACTI128 $0x01, Y0, X1
	VPMAXSD      X1, X0, X0
	CMPQ         DX, $0x00000004
	JL           int32MaxDone1
	VPMAXSD      (AX), X0, X0

int32MaxDone1:
	MOVOU X0, (CX)
	RET

// func uint8MaxAvx2Asm(x []uint8, r []uint8)
// Requires: AVX, AVX2, SSE2
TEXT ·uint8MaxAvx2Asm(SB), NOSPLIT, $0-48
	MOVQ  x_base+0(FP), AX
	MOVQ  r_base+24(FP), CX
	MOVQ  x_len+8(FP), DX
	VPXOR Y0, Y0, Y0
	VPXOR Y1, Y1, Y1
	VPXOR Y2, Y2, Y2
	VPXOR Y3, Y3, Y3
	VPXOR Y4, Y4, Y4
	VPXOR Y5, Y5, Y5
	VPXOR Y6, Y6, Y6
	VPXOR Y7, Y7, Y7
	VPXOR Y8, Y8, Y8
	VPXOR Y9, Y9, Y9
	VPXOR Y10, Y10, Y10
	VPXOR Y11, Y11, Y11
	VPXOR Y12, Y12, Y12
	VPXOR Y13, Y13, Y13
	VPXOR Y14, Y14, Y14
	VPXOR Y15, Y15, Y15

uint8MaxBlockLoop:
	CMPQ    DX, $0x00000200
	JL      uint8MaxTailLoop
	VPMAXUB (AX), Y0, Y0
	VPMAXUB 32(AX), Y1, Y1
	VPMAXUB 64(AX), Y2, Y2
	VPMAXUB 96(AX), Y3, Y3
	VPMAXUB 128(AX), Y4, Y4
	VPMAXUB 160(AX), Y5, Y5
	VPMAXUB 192(AX), Y6, Y6
	VPMAXUB 224(AX), Y7, Y7
	VPMAXUB 256(AX), Y8, Y8
	VPMAXUB 288(AX), Y9, Y9
	VPMAXUB 320(AX), Y10, Y10
	VPMAXUB 352(AX), Y11, Y11
	VPMAXUB 384(AX), Y12, Y12
	VPMAXUB 416(AX), Y13, Y13
	VPMAXUB 448(AX), Y14, Y14
	VPMAXUB 480(AX), Y15, Y15
	ADDQ    $0x00000200, AX
	SUBQ    $0x00000200, DX
	JMP     uint8MaxBlockLoop

uint8MaxTailLoop:
	CMPQ    DX, $0x00000020
	JL      uint8MaxDone
	VPMAXUB (AX), Y0, Y0
	ADDQ    $0x00000020, AX
	SUBQ    $0x00000020, DX
	JMP     uint8MaxTailLoop

uint8MaxDone:
	VPMAXUB      Y0, Y1, Y0
	VPMAXUB      Y0, Y2, Y0
	VPMAXUB      Y0, Y3, Y0
	VPMAXUB      Y0, Y4, Y0
	VPMAXUB      Y0, Y5, Y0
	VPMAXUB      Y0, Y6, Y0
	VPMAXUB      Y0, Y7, Y0
	VPMAXUB      Y0, Y8, Y0
	VPMAXUB      Y0, Y9, Y0
	VPMAXUB      Y0, Y10, Y0
	VPMAXUB      Y0, Y11, Y0
	VPMAXUB      Y0, Y12, Y0
	VPMAXUB      Y0, Y13, Y0
	VPMAXUB      Y0, Y14, Y0
	VPMAXUB      Y0, Y15, Y0
	VEXTRACTI128 $0x01, Y0, X1
	VPMAXUB      X1, X0, X0
	CMPQ         DX, $0x00000010
	JL           uint8MaxDone1
	VPMAXUB      (AX), X0, X0

uint8MaxDone1:
	MOVOU X0, (CX)
	RET

// func uint16MaxAvx2Asm(x []uint16, r []uint16)
// Requires: AVX, AVX2, SSE2
TEXT ·uint16MaxAvx2Asm(SB), NOSPLIT, $0-48
	MOVQ  x_base+0(FP), AX
	MOVQ  r_base+24(FP), CX
	MOVQ  x_len+8(FP), DX
	VPXOR Y0, Y0, Y0
	VPXOR Y1, Y1, Y1
	VPXOR Y2, Y2, Y2
	VPXOR Y3, Y3, Y3
	VPXOR Y4, Y4, Y4
	VPXOR Y5, Y5, Y5
	VPXOR Y6, Y6, Y6
	VPXOR Y7, Y7, Y7
	VPXOR Y8, Y8, Y8
	VPXOR Y9, Y9, Y9
	VPXOR Y10, Y10, Y10
	VPXOR Y11, Y11, Y11
	VPXOR Y12, Y12, Y12
	VPXOR Y13, Y13, Y13
	VPXOR Y14, Y14, Y14
	VPXOR Y15, Y15, Y15

uint16MaxBlockLoop:
	CMPQ    DX, $0x00000100
	JL      uint16MaxTailLoop
	VPMAXUW (AX), Y0, Y0
	VPMAXUW 32(AX), Y1, Y1
	VPMAXUW 64(AX), Y2, Y2
	VPMAXUW 96(AX), Y3, Y3
	VPMAXUW 128(AX), Y4, Y4
	VPMAXUW 160(AX), Y5, Y5
	VPMAXUW 192(AX), Y6, Y6
	VPMAXUW 224(AX), Y7, Y7
	VPMAXUW 256(AX), Y8, Y8
	VPMAXUW 288(AX), Y9, Y9
	VPMAXUW 320(AX), Y10, Y10
	VPMAXUW 352(AX), Y11, Y11
	VPMAXUW 384(AX), Y12, Y12
	VPMAXUW 416(AX), Y13, Y13
	VPMAXUW 448(AX), Y14, Y14
	VPMAXUW 480(AX), Y15, Y15
	ADDQ    $0x00000200, AX
	SUBQ    $0x00000100, DX
	JMP     uint16MaxBlockLoop

uint16MaxTailLoop:
	CMPQ    DX, $0x00000010
	JL      uint16MaxDone
	VPMAXUW (AX), Y0, Y0
	ADDQ    $0x00000020, AX
	SUBQ    $0x00000010, DX
	JMP     uint16MaxTailLoop

uint16MaxDone:
	VPMAXUW      Y0, Y1, Y0
	VPMAXUW      Y0, Y2, Y0
	VPMAXUW      Y0, Y3, Y0
	VPMAXUW      Y0, Y4, Y0
	VPMAXUW      Y0, Y5, Y0
	VPMAXUW      Y0, Y6, Y0
	VPMAXUW      Y0, Y7, Y0
	VPMAXUW      Y0, Y8, Y0
	VPMAXUW      Y0, Y9, Y0
	VPMAXUW      Y0, Y10, Y0
	VPMAXUW      Y0, Y11, Y0
	VPMAXUW      Y0, Y12, Y0
	VPMAXUW      Y0, Y13, Y0
	VPMAXUW      Y0, Y14, Y0
	VPMAXUW      Y0, Y15, Y0
	VEXTRACTI128 $0x01, Y0, X1
	VPMAXUW      X1, X0, X0
	CMPQ         DX, $0x00000008
	JL           uint16MaxDone1
	VPMAXUW      (AX), X0, X0

uint16MaxDone1:
	MOVOU X0, (CX)
	RET

// func uint32MaxAvx2Asm(x []uint32, r []uint32)
// Requires: AVX, AVX2, SSE2
TEXT ·uint32MaxAvx2Asm(SB), NOSPLIT, $0-48
	MOVQ  x_base+0(FP), AX
	MOVQ  r_base+24(FP), CX
	MOVQ  x_len+8(FP), DX
	VPXOR Y0, Y0, Y0
	VPXOR Y1, Y1, Y1
	VPXOR Y2, Y2, Y2
	VPXOR Y3, Y3, Y3
	VPXOR Y4, Y4, Y4
	VPXOR Y5, Y5, Y5
	VPXOR Y6, Y6, Y6
	VPXOR Y7, Y7, Y7
	VPXOR Y8, Y8, Y8
	VPXOR Y9, Y9, Y9
	VPXOR Y10, Y10, Y10
	VPXOR Y11, Y11, Y11
	VPXOR Y12, Y12, Y12
	VPXOR Y13, Y13, Y13
	VPXOR Y14, Y14, Y14
	VPXOR Y15, Y15, Y15

uint32MaxBlockLoop:
	CMPQ    DX, $0x00000080
	JL      uint32MaxTailLoop
	VPMAXUD (AX), Y0, Y0
	VPMAXUD 32(AX), Y1, Y1
	VPMAXUD 64(AX), Y2, Y2
	VPMAXUD 96(AX), Y3, Y3
	VPMAXUD 128(AX), Y4, Y4
	VPMAXUD 160(AX), Y5, Y5
	VPMAXUD 192(AX), Y6, Y6
	VPMAXUD 224(AX), Y7, Y7
	VPMAXUD 256(AX), Y8, Y8
	VPMAXUD 288(AX), Y9, Y9
	VPMAXUD 320(AX), Y10, Y10
	VPMAXUD 352(AX), Y11, Y11
	VPMAXUD 384(AX), Y12, Y12
	VPMAXUD 416(AX), Y13, Y13
	VPMAXUD 448(AX), Y14, Y14
	VPMAXUD 480(AX), Y15, Y15
	ADDQ    $0x00000200, AX
	SUBQ    $0x00000080, DX
	JMP     uint32MaxBlockLoop

uint32MaxTailLoop:
	CMPQ    DX, $0x00000008
	JL      uint32MaxDone
	VPMAXUD (AX), Y0, Y0
	ADDQ    $0x00000020, AX
	SUBQ    $0x00000008, DX
	JMP     uint32MaxTailLoop

uint32MaxDone:
	VPMAXUD      Y0, Y1, Y0
	VPMAXUD      Y0, Y2, Y0
	VPMAXUD      Y0, Y3, Y0
	VPMAXUD      Y0, Y4, Y0
	VPMAXUD      Y0, Y5, Y0
	VPMAXUD      Y0, Y6, Y0
	VPMAXUD      Y0, Y7, Y0
	VPMAXUD      Y0, Y8, Y0
	VPMAXUD      Y0, Y9, Y0
	VPMAXUD      Y0, Y10, Y0
	VPMAXUD      Y0, Y11, Y0
	VPMAXUD      Y0, Y12, Y0
	VPMAXUD      Y0, Y13, Y0
	VPMAXUD      Y0, Y14, Y0
	VPMAXUD      Y0, Y15, Y0
	VEXTRACTI128 $0x01, Y0, X1
	VPMAXUD      X1, X0, X0
	CMPQ         DX, $0x00000004
	JL           uint32MaxDone1
	VPMAXUD      (AX), X0, X0

uint32MaxDone1:
	MOVOU X0, (CX)
	RET

// func float32MaxAvx2Asm(x []float32, r []float32)
// Requires: AVX, AVX2, SSE2
TEXT ·float32MaxAvx2Asm(SB), NOSPLIT, $0-48
	MOVQ         x_base+0(FP), AX
	MOVQ         r_base+24(FP), CX
	MOVQ         x_len+8(FP), DX
	MOVQ         $0x00000000ff7fffff, BX
	MOVQ         BX, X0
	VBROADCASTSS X0, Y0
	VMOVUPS      Y0, Y1
	VMOVUPS      Y0, Y2
	VMOVUPS      Y0, Y3
	VMOVUPS      Y0, Y4
	VMOVUPS      Y0, Y5
	VMOVUPS      Y0, Y6
	VMOVUPS      Y0, Y7
	VMOVUPS      Y0, Y8
	VMOVUPS      Y0, Y9
	VMOVUPS      Y0, Y10
	VMOVUPS      Y0, Y11
	VMOVUPS      Y0, Y12
	VMOVUPS      Y0, Y13
	VMOVUPS      Y0, Y14
	VMOVUPS      Y0, Y15

float32MaxBlockLoop:
	CMPQ   DX, $0x00000080
	JL     float32MaxTailLoop
	VMAXPS (AX), Y0, Y0
	VMAXPS 32(AX), Y1, Y1
	VMAXPS 64(AX), Y2, Y2
	VMAXPS 96(AX), Y3, Y3
	VMAXPS 128(AX), Y4, Y4
	VMAXPS 160(AX), Y5, Y5
	VMAXPS 192(AX), Y6, Y6
	VMAXPS 224(AX), Y7, Y7
	VMAXPS 256(AX), Y8, Y8
	VMAXPS 288(AX), Y9, Y9
	VMAXPS 320(AX), Y10, Y10
	VMAXPS 352(AX), Y11, Y11
	VMAXPS 384(AX), Y12, Y12
	VMAXPS 416(AX), Y13, Y13
	VMAXPS 448(AX), Y14, Y14
	VMAXPS 480(AX), Y15, Y15
	ADDQ   $0x00000200, AX
	SUBQ   $0x00000080, DX
	JMP    float32MaxBlockLoop

float32MaxTailLoop:
	CMPQ   DX, $0x00000008
	JL     float32MaxDone
	VMAXPS (AX), Y0, Y0
	ADDQ   $0x00000020, AX
	SUBQ   $0x00000008, DX
	JMP    float32MaxTailLoop

float32MaxDone:
	VMAXPS       Y0, Y1, Y0
	VMAXPS       Y0, Y2, Y0
	VMAXPS       Y0, Y3, Y0
	VMAXPS       Y0, Y4, Y0
	VMAXPS       Y0, Y5, Y0
	VMAXPS       Y0, Y6, Y0
	VMAXPS       Y0, Y7, Y0
	VMAXPS       Y0, Y8, Y0
	VMAXPS       Y0, Y9, Y0
	VMAXPS       Y0, Y10, Y0
	VMAXPS       Y0, Y11, Y0
	VMAXPS       Y0, Y12, Y0
	VMAXPS       Y0, Y13, Y0
	VMAXPS       Y0, Y14, Y0
	VMAXPS       Y0, Y15, Y0
	VEXTRACTF128 $0x01, Y0, X1
	VMAXPS       X1, X0, X0
	CMPQ         DX, $0x00000004
	JL           float32MaxDone1
	VMAXPS       (AX), X0, X0

float32MaxDone1:
	MOVOU X0, (CX)
	RET

// func float64MaxAvx2Asm(x []float64, r []float64)
// Requires: AVX, AVX2, SSE2
TEXT ·float64MaxAvx2Asm(SB), NOSPLIT, $0-48
	MOVQ         x_base+0(FP), AX
	MOVQ         r_base+24(FP), CX
	MOVQ         x_len+8(FP), DX
	MOVQ         $0xffefffffffffffff, BX
	MOVQ         BX, X0
	VBROADCASTSD X0, Y0
	VMOVUPD      Y0, Y1
	VMOVUPD      Y0, Y2
	VMOVUPD      Y0, Y3
	VMOVUPD      Y0, Y4
	VMOVUPD      Y0, Y5
	VMOVUPD      Y0, Y6
	VMOVUPD      Y0, Y7
	VMOVUPD      Y0, Y8
	VMOVUPD      Y0, Y9
	VMOVUPD      Y0, Y10
	VMOVUPD      Y0, Y11
	VMOVUPD      Y0, Y12
	VMOVUPD      Y0, Y13
	VMOVUPD      Y0, Y14
	VMOVUPD      Y0, Y15

float64MaxBlockLoop:
	CMPQ   DX, $0x00000040
	JL     float64MaxTailLoop
	VMAXPD (AX), Y0, Y0
	VMAXPD 32(AX), Y1, Y1
	VMAXPD 64(AX), Y2, Y2
	VMAXPD 96(AX), Y3, Y3
	VMAXPD 128(AX), Y4, Y4
	VMAXPD 160(AX), Y5, Y5
	VMAXPD 192(AX), Y6, Y6
	VMAXPD 224(AX), Y7, Y7
	VMAXPD 256(AX), Y8, Y8
	VMAXPD 288(AX), Y9, Y9
	VMAXPD 320(AX), Y10, Y10
	VMAXPD 352(AX), Y11, Y11
	VMAXPD 384(AX), Y12, Y12
	VMAXPD 416(AX), Y13, Y13
	VMAXPD 448(AX), Y14, Y14
	VMAXPD 480(AX), Y15, Y15
	ADDQ   $0x00000200, AX
	SUBQ   $0x00000040, DX
	JMP    float64MaxBlockLoop

float64MaxTailLoop:
	CMPQ   DX, $0x00000004
	JL     float64MaxDone
	VMAXPD (AX), Y0, Y0
	ADDQ   $0x00000020, AX
	SUBQ   $0x00000004, DX
	JMP    float64MaxTailLoop

float64MaxDone:
	VMAXPD       Y0, Y1, Y0
	VMAXPD       Y0, Y2, Y0
	VMAXPD       Y0, Y3, Y0
	VMAXPD       Y0, Y4, Y0
	VMAXPD       Y0, Y5, Y0
	VMAXPD       Y0, Y6, Y0
	VMAXPD       Y0, Y7, Y0
	VMAXPD       Y0, Y8, Y0
	VMAXPD       Y0, Y9, Y0
	VMAXPD       Y0, Y10, Y0
	VMAXPD       Y0, Y11, Y0
	VMAXPD       Y0, Y12, Y0
	VMAXPD       Y0, Y13, Y0
	VMAXPD       Y0, Y14, Y0
	VMAXPD       Y0, Y15, Y0
	VEXTRACTF128 $0x01, Y0, X1
	VMAXPD       X1, X0, X0
	CMPQ         DX, $0x00000002
	JL           float64MaxDone1
	VMAXPD       (AX), X0, X0

float64MaxDone1:
	MOVOU X0, (CX)
	RET

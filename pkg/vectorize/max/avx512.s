// Code generated by command: go run avx512.go -out avx512.s -stubs avx512_stubs.go. DO NOT EDIT.

#include "textflag.h"

// func int8MaxAvx512Asm(x []int8, r []int8)
// Requires: AVX, AVX2, AVX512BW, AVX512F, SSE2
TEXT ·int8MaxAvx512Asm(SB), NOSPLIT, $0-48
	MOVQ         x_base+0(FP), AX
	MOVQ         r_base+24(FP), CX
	MOVQ         x_len+8(FP), DX
	MOVQ         $0x0000000000000080, BX
	MOVQ         BX, X0
	VPBROADCASTB X0, Z0
	VMOVDQU64    Z0, Z1
	VMOVDQU64    Z0, Z2
	VMOVDQU64    Z0, Z3
	VMOVDQU64    Z0, Z4
	VMOVDQU64    Z0, Z5
	VMOVDQU64    Z0, Z6
	VMOVDQU64    Z0, Z7
	VMOVDQU64    Z0, Z8
	VMOVDQU64    Z0, Z9
	VMOVDQU64    Z0, Z10
	VMOVDQU64    Z0, Z11
	VMOVDQU64    Z0, Z12
	VMOVDQU64    Z0, Z13
	VMOVDQU64    Z0, Z14
	VMOVDQU64    Z0, Z15
	VMOVDQU64    Z0, Z16
	VMOVDQU64    Z0, Z17
	VMOVDQU64    Z0, Z18
	VMOVDQU64    Z0, Z19
	VMOVDQU64    Z0, Z20
	VMOVDQU64    Z0, Z21
	VMOVDQU64    Z0, Z22
	VMOVDQU64    Z0, Z23
	VMOVDQU64    Z0, Z24
	VMOVDQU64    Z0, Z25
	VMOVDQU64    Z0, Z26
	VMOVDQU64    Z0, Z27
	VMOVDQU64    Z0, Z28
	VMOVDQU64    Z0, Z29
	VMOVDQU64    Z0, Z30
	VMOVDQU64    Z0, Z31

int8MaxBlockLoop:
	CMPQ    DX, $0x00000800
	JL      int8MaxTailLoop
	VPMAXSB (AX), Z0, Z0
	VPMAXSB 64(AX), Z1, Z1
	VPMAXSB 128(AX), Z2, Z2
	VPMAXSB 192(AX), Z3, Z3
	VPMAXSB 256(AX), Z4, Z4
	VPMAXSB 320(AX), Z5, Z5
	VPMAXSB 384(AX), Z6, Z6
	VPMAXSB 448(AX), Z7, Z7
	VPMAXSB 512(AX), Z8, Z8
	VPMAXSB 576(AX), Z9, Z9
	VPMAXSB 640(AX), Z10, Z10
	VPMAXSB 704(AX), Z11, Z11
	VPMAXSB 768(AX), Z12, Z12
	VPMAXSB 832(AX), Z13, Z13
	VPMAXSB 896(AX), Z14, Z14
	VPMAXSB 960(AX), Z15, Z15
	VPMAXSB 1024(AX), Z16, Z16
	VPMAXSB 1088(AX), Z17, Z17
	VPMAXSB 1152(AX), Z18, Z18
	VPMAXSB 1216(AX), Z19, Z19
	VPMAXSB 1280(AX), Z20, Z20
	VPMAXSB 1344(AX), Z21, Z21
	VPMAXSB 1408(AX), Z22, Z22
	VPMAXSB 1472(AX), Z23, Z23
	VPMAXSB 1536(AX), Z24, Z24
	VPMAXSB 1600(AX), Z25, Z25
	VPMAXSB 1664(AX), Z26, Z26
	VPMAXSB 1728(AX), Z27, Z27
	VPMAXSB 1792(AX), Z28, Z28
	VPMAXSB 1856(AX), Z29, Z29
	VPMAXSB 1920(AX), Z30, Z30
	VPMAXSB 1984(AX), Z31, Z31
	ADDQ    $0x00000800, AX
	SUBQ    $0x00000800, DX
	JMP     int8MaxBlockLoop

int8MaxTailLoop:
	CMPQ    DX, $0x00000040
	JL      int8MaxDone
	VPMAXSB (AX), Z0, Z0
	ADDQ    $0x00000040, AX
	SUBQ    $0x00000040, DX
	JMP     int8MaxTailLoop

int8MaxDone:
	VPMAXSB       Z0, Z1, Z0
	VPMAXSB       Z0, Z2, Z0
	VPMAXSB       Z0, Z3, Z0
	VPMAXSB       Z0, Z4, Z0
	VPMAXSB       Z0, Z5, Z0
	VPMAXSB       Z0, Z6, Z0
	VPMAXSB       Z0, Z7, Z0
	VPMAXSB       Z0, Z8, Z0
	VPMAXSB       Z0, Z9, Z0
	VPMAXSB       Z0, Z10, Z0
	VPMAXSB       Z0, Z11, Z0
	VPMAXSB       Z0, Z12, Z0
	VPMAXSB       Z0, Z13, Z0
	VPMAXSB       Z0, Z14, Z0
	VPMAXSB       Z0, Z15, Z0
	VPMAXSB       Z0, Z16, Z0
	VPMAXSB       Z0, Z17, Z0
	VPMAXSB       Z0, Z18, Z0
	VPMAXSB       Z0, Z19, Z0
	VPMAXSB       Z0, Z20, Z0
	VPMAXSB       Z0, Z21, Z0
	VPMAXSB       Z0, Z22, Z0
	VPMAXSB       Z0, Z23, Z0
	VPMAXSB       Z0, Z24, Z0
	VPMAXSB       Z0, Z25, Z0
	VPMAXSB       Z0, Z26, Z0
	VPMAXSB       Z0, Z27, Z0
	VPMAXSB       Z0, Z28, Z0
	VPMAXSB       Z0, Z29, Z0
	VPMAXSB       Z0, Z30, Z0
	VPMAXSB       Z0, Z31, Z0
	VEXTRACTI64X4 $0x01, Z0, Y1
	VPMAXSB       Y1, Y0, Y0
	SUBQ          $0x00000020, DX
	JB            int8MaxDone1
	VPMAXSB       (AX), Y0, Y0
	ADDQ          $0x00000020, AX

int8MaxDone1:
	VEXTRACTI128 $0x01, Y0, X1
	VPMAXSB      X1, X0, X0
	CMPQ         DX, $0x00000010
	JL           int8MaxDone2
	VPMAXSB      (AX), X0, X0
	ADDQ         $0x00000020, AX

int8MaxDone2:
	MOVOU X0, (CX)
	RET

// func int16MaxAvx512Asm(x []int16, r []int16)
// Requires: AVX, AVX2, AVX512BW, AVX512F, SSE2
TEXT ·int16MaxAvx512Asm(SB), NOSPLIT, $0-48
	MOVQ         x_base+0(FP), AX
	MOVQ         r_base+24(FP), CX
	MOVQ         x_len+8(FP), DX
	MOVQ         $0x0000000000008000, BX
	MOVQ         BX, X0
	VPBROADCASTW X0, Z0
	VMOVDQU64    Z0, Z1
	VMOVDQU64    Z0, Z2
	VMOVDQU64    Z0, Z3
	VMOVDQU64    Z0, Z4
	VMOVDQU64    Z0, Z5
	VMOVDQU64    Z0, Z6
	VMOVDQU64    Z0, Z7
	VMOVDQU64    Z0, Z8
	VMOVDQU64    Z0, Z9
	VMOVDQU64    Z0, Z10
	VMOVDQU64    Z0, Z11
	VMOVDQU64    Z0, Z12
	VMOVDQU64    Z0, Z13
	VMOVDQU64    Z0, Z14
	VMOVDQU64    Z0, Z15
	VMOVDQU64    Z0, Z16
	VMOVDQU64    Z0, Z17
	VMOVDQU64    Z0, Z18
	VMOVDQU64    Z0, Z19
	VMOVDQU64    Z0, Z20
	VMOVDQU64    Z0, Z21
	VMOVDQU64    Z0, Z22
	VMOVDQU64    Z0, Z23
	VMOVDQU64    Z0, Z24
	VMOVDQU64    Z0, Z25
	VMOVDQU64    Z0, Z26
	VMOVDQU64    Z0, Z27
	VMOVDQU64    Z0, Z28
	VMOVDQU64    Z0, Z29
	VMOVDQU64    Z0, Z30
	VMOVDQU64    Z0, Z31

int16MaxBlockLoop:
	CMPQ    DX, $0x00000400
	JL      int16MaxTailLoop
	VPMAXSW (AX), Z0, Z0
	VPMAXSW 64(AX), Z1, Z1
	VPMAXSW 128(AX), Z2, Z2
	VPMAXSW 192(AX), Z3, Z3
	VPMAXSW 256(AX), Z4, Z4
	VPMAXSW 320(AX), Z5, Z5
	VPMAXSW 384(AX), Z6, Z6
	VPMAXSW 448(AX), Z7, Z7
	VPMAXSW 512(AX), Z8, Z8
	VPMAXSW 576(AX), Z9, Z9
	VPMAXSW 640(AX), Z10, Z10
	VPMAXSW 704(AX), Z11, Z11
	VPMAXSW 768(AX), Z12, Z12
	VPMAXSW 832(AX), Z13, Z13
	VPMAXSW 896(AX), Z14, Z14
	VPMAXSW 960(AX), Z15, Z15
	VPMAXSW 1024(AX), Z16, Z16
	VPMAXSW 1088(AX), Z17, Z17
	VPMAXSW 1152(AX), Z18, Z18
	VPMAXSW 1216(AX), Z19, Z19
	VPMAXSW 1280(AX), Z20, Z20
	VPMAXSW 1344(AX), Z21, Z21
	VPMAXSW 1408(AX), Z22, Z22
	VPMAXSW 1472(AX), Z23, Z23
	VPMAXSW 1536(AX), Z24, Z24
	VPMAXSW 1600(AX), Z25, Z25
	VPMAXSW 1664(AX), Z26, Z26
	VPMAXSW 1728(AX), Z27, Z27
	VPMAXSW 1792(AX), Z28, Z28
	VPMAXSW 1856(AX), Z29, Z29
	VPMAXSW 1920(AX), Z30, Z30
	VPMAXSW 1984(AX), Z31, Z31
	ADDQ    $0x00000800, AX
	SUBQ    $0x00000400, DX
	JMP     int16MaxBlockLoop

int16MaxTailLoop:
	CMPQ    DX, $0x00000020
	JL      int16MaxDone
	VPMAXSW (AX), Z0, Z0
	ADDQ    $0x00000040, AX
	SUBQ    $0x00000020, DX
	JMP     int16MaxTailLoop

int16MaxDone:
	VPMAXSW       Z0, Z1, Z0
	VPMAXSW       Z0, Z2, Z0
	VPMAXSW       Z0, Z3, Z0
	VPMAXSW       Z0, Z4, Z0
	VPMAXSW       Z0, Z5, Z0
	VPMAXSW       Z0, Z6, Z0
	VPMAXSW       Z0, Z7, Z0
	VPMAXSW       Z0, Z8, Z0
	VPMAXSW       Z0, Z9, Z0
	VPMAXSW       Z0, Z10, Z0
	VPMAXSW       Z0, Z11, Z0
	VPMAXSW       Z0, Z12, Z0
	VPMAXSW       Z0, Z13, Z0
	VPMAXSW       Z0, Z14, Z0
	VPMAXSW       Z0, Z15, Z0
	VPMAXSW       Z0, Z16, Z0
	VPMAXSW       Z0, Z17, Z0
	VPMAXSW       Z0, Z18, Z0
	VPMAXSW       Z0, Z19, Z0
	VPMAXSW       Z0, Z20, Z0
	VPMAXSW       Z0, Z21, Z0
	VPMAXSW       Z0, Z22, Z0
	VPMAXSW       Z0, Z23, Z0
	VPMAXSW       Z0, Z24, Z0
	VPMAXSW       Z0, Z25, Z0
	VPMAXSW       Z0, Z26, Z0
	VPMAXSW       Z0, Z27, Z0
	VPMAXSW       Z0, Z28, Z0
	VPMAXSW       Z0, Z29, Z0
	VPMAXSW       Z0, Z30, Z0
	VPMAXSW       Z0, Z31, Z0
	VEXTRACTI64X4 $0x01, Z0, Y1
	VPMAXSW       Y1, Y0, Y0
	SUBQ          $0x00000010, DX
	JB            int16MaxDone1
	VPMAXSW       (AX), Y0, Y0
	ADDQ          $0x00000020, AX

int16MaxDone1:
	VEXTRACTI128 $0x01, Y0, X1
	VPMAXSW      X1, X0, X0
	CMPQ         DX, $0x00000008
	JL           int16MaxDone2
	VPMAXSW      (AX), X0, X0
	ADDQ         $0x00000020, AX

int16MaxDone2:
	MOVOU X0, (CX)
	RET

// func int32MaxAvx512Asm(x []int32, r []int32)
// Requires: AVX, AVX2, AVX512F, SSE2
TEXT ·int32MaxAvx512Asm(SB), NOSPLIT, $0-48
	MOVQ         x_base+0(FP), AX
	MOVQ         r_base+24(FP), CX
	MOVQ         x_len+8(FP), DX
	MOVQ         $0x0000000080000000, BX
	MOVQ         BX, X0
	VPBROADCASTD X0, Z0
	VMOVDQU64    Z0, Z1
	VMOVDQU64    Z0, Z2
	VMOVDQU64    Z0, Z3
	VMOVDQU64    Z0, Z4
	VMOVDQU64    Z0, Z5
	VMOVDQU64    Z0, Z6
	VMOVDQU64    Z0, Z7
	VMOVDQU64    Z0, Z8
	VMOVDQU64    Z0, Z9
	VMOVDQU64    Z0, Z10
	VMOVDQU64    Z0, Z11
	VMOVDQU64    Z0, Z12
	VMOVDQU64    Z0, Z13
	VMOVDQU64    Z0, Z14
	VMOVDQU64    Z0, Z15
	VMOVDQU64    Z0, Z16
	VMOVDQU64    Z0, Z17
	VMOVDQU64    Z0, Z18
	VMOVDQU64    Z0, Z19
	VMOVDQU64    Z0, Z20
	VMOVDQU64    Z0, Z21
	VMOVDQU64    Z0, Z22
	VMOVDQU64    Z0, Z23
	VMOVDQU64    Z0, Z24
	VMOVDQU64    Z0, Z25
	VMOVDQU64    Z0, Z26
	VMOVDQU64    Z0, Z27
	VMOVDQU64    Z0, Z28
	VMOVDQU64    Z0, Z29
	VMOVDQU64    Z0, Z30
	VMOVDQU64    Z0, Z31

int32MaxBlockLoop:
	CMPQ    DX, $0x00000200
	JL      int32MaxTailLoop
	VPMAXSD (AX), Z0, Z0
	VPMAXSD 64(AX), Z1, Z1
	VPMAXSD 128(AX), Z2, Z2
	VPMAXSD 192(AX), Z3, Z3
	VPMAXSD 256(AX), Z4, Z4
	VPMAXSD 320(AX), Z5, Z5
	VPMAXSD 384(AX), Z6, Z6
	VPMAXSD 448(AX), Z7, Z7
	VPMAXSD 512(AX), Z8, Z8
	VPMAXSD 576(AX), Z9, Z9
	VPMAXSD 640(AX), Z10, Z10
	VPMAXSD 704(AX), Z11, Z11
	VPMAXSD 768(AX), Z12, Z12
	VPMAXSD 832(AX), Z13, Z13
	VPMAXSD 896(AX), Z14, Z14
	VPMAXSD 960(AX), Z15, Z15
	VPMAXSD 1024(AX), Z16, Z16
	VPMAXSD 1088(AX), Z17, Z17
	VPMAXSD 1152(AX), Z18, Z18
	VPMAXSD 1216(AX), Z19, Z19
	VPMAXSD 1280(AX), Z20, Z20
	VPMAXSD 1344(AX), Z21, Z21
	VPMAXSD 1408(AX), Z22, Z22
	VPMAXSD 1472(AX), Z23, Z23
	VPMAXSD 1536(AX), Z24, Z24
	VPMAXSD 1600(AX), Z25, Z25
	VPMAXSD 1664(AX), Z26, Z26
	VPMAXSD 1728(AX), Z27, Z27
	VPMAXSD 1792(AX), Z28, Z28
	VPMAXSD 1856(AX), Z29, Z29
	VPMAXSD 1920(AX), Z30, Z30
	VPMAXSD 1984(AX), Z31, Z31
	ADDQ    $0x00000800, AX
	SUBQ    $0x00000200, DX
	JMP     int32MaxBlockLoop

int32MaxTailLoop:
	CMPQ    DX, $0x00000010
	JL      int32MaxDone
	VPMAXSD (AX), Z0, Z0
	ADDQ    $0x00000040, AX
	SUBQ    $0x00000010, DX
	JMP     int32MaxTailLoop

int32MaxDone:
	VPMAXSD       Z0, Z1, Z0
	VPMAXSD       Z0, Z2, Z0
	VPMAXSD       Z0, Z3, Z0
	VPMAXSD       Z0, Z4, Z0
	VPMAXSD       Z0, Z5, Z0
	VPMAXSD       Z0, Z6, Z0
	VPMAXSD       Z0, Z7, Z0
	VPMAXSD       Z0, Z8, Z0
	VPMAXSD       Z0, Z9, Z0
	VPMAXSD       Z0, Z10, Z0
	VPMAXSD       Z0, Z11, Z0
	VPMAXSD       Z0, Z12, Z0
	VPMAXSD       Z0, Z13, Z0
	VPMAXSD       Z0, Z14, Z0
	VPMAXSD       Z0, Z15, Z0
	VPMAXSD       Z0, Z16, Z0
	VPMAXSD       Z0, Z17, Z0
	VPMAXSD       Z0, Z18, Z0
	VPMAXSD       Z0, Z19, Z0
	VPMAXSD       Z0, Z20, Z0
	VPMAXSD       Z0, Z21, Z0
	VPMAXSD       Z0, Z22, Z0
	VPMAXSD       Z0, Z23, Z0
	VPMAXSD       Z0, Z24, Z0
	VPMAXSD       Z0, Z25, Z0
	VPMAXSD       Z0, Z26, Z0
	VPMAXSD       Z0, Z27, Z0
	VPMAXSD       Z0, Z28, Z0
	VPMAXSD       Z0, Z29, Z0
	VPMAXSD       Z0, Z30, Z0
	VPMAXSD       Z0, Z31, Z0
	VEXTRACTI64X4 $0x01, Z0, Y1
	VPMAXSD       Y1, Y0, Y0
	SUBQ          $0x00000008, DX
	JB            int32MaxDone1
	VPMAXSD       (AX), Y0, Y0
	ADDQ          $0x00000020, AX

int32MaxDone1:
	VEXTRACTI128 $0x01, Y0, X1
	VPMAXSD      X1, X0, X0
	CMPQ         DX, $0x00000004
	JL           int32MaxDone2
	VPMAXSD      (AX), X0, X0
	ADDQ         $0x00000020, AX

int32MaxDone2:
	MOVOU X0, (CX)
	RET

// func int64MaxAvx512Asm(x []int64, r []int64)
// Requires: AVX2, AVX512F, AVX512VL, SSE2
TEXT ·int64MaxAvx512Asm(SB), NOSPLIT, $0-48
	MOVQ         x_base+0(FP), AX
	MOVQ         r_base+24(FP), CX
	MOVQ         x_len+8(FP), DX
	MOVQ         $0x8000000000000000, BX
	MOVQ         BX, X0
	VPBROADCASTQ X0, Z0
	VMOVDQU64    Z0, Z1
	VMOVDQU64    Z0, Z2
	VMOVDQU64    Z0, Z3
	VMOVDQU64    Z0, Z4
	VMOVDQU64    Z0, Z5
	VMOVDQU64    Z0, Z6
	VMOVDQU64    Z0, Z7
	VMOVDQU64    Z0, Z8
	VMOVDQU64    Z0, Z9
	VMOVDQU64    Z0, Z10
	VMOVDQU64    Z0, Z11
	VMOVDQU64    Z0, Z12
	VMOVDQU64    Z0, Z13
	VMOVDQU64    Z0, Z14
	VMOVDQU64    Z0, Z15
	VMOVDQU64    Z0, Z16
	VMOVDQU64    Z0, Z17
	VMOVDQU64    Z0, Z18
	VMOVDQU64    Z0, Z19
	VMOVDQU64    Z0, Z20
	VMOVDQU64    Z0, Z21
	VMOVDQU64    Z0, Z22
	VMOVDQU64    Z0, Z23
	VMOVDQU64    Z0, Z24
	VMOVDQU64    Z0, Z25
	VMOVDQU64    Z0, Z26
	VMOVDQU64    Z0, Z27
	VMOVDQU64    Z0, Z28
	VMOVDQU64    Z0, Z29
	VMOVDQU64    Z0, Z30
	VMOVDQU64    Z0, Z31

int64MaxBlockLoop:
	CMPQ    DX, $0x00000100
	JL      int64MaxTailLoop
	VPMAXSQ (AX), Z0, Z0
	VPMAXSQ 64(AX), Z1, Z1
	VPMAXSQ 128(AX), Z2, Z2
	VPMAXSQ 192(AX), Z3, Z3
	VPMAXSQ 256(AX), Z4, Z4
	VPMAXSQ 320(AX), Z5, Z5
	VPMAXSQ 384(AX), Z6, Z6
	VPMAXSQ 448(AX), Z7, Z7
	VPMAXSQ 512(AX), Z8, Z8
	VPMAXSQ 576(AX), Z9, Z9
	VPMAXSQ 640(AX), Z10, Z10
	VPMAXSQ 704(AX), Z11, Z11
	VPMAXSQ 768(AX), Z12, Z12
	VPMAXSQ 832(AX), Z13, Z13
	VPMAXSQ 896(AX), Z14, Z14
	VPMAXSQ 960(AX), Z15, Z15
	VPMAXSQ 1024(AX), Z16, Z16
	VPMAXSQ 1088(AX), Z17, Z17
	VPMAXSQ 1152(AX), Z18, Z18
	VPMAXSQ 1216(AX), Z19, Z19
	VPMAXSQ 1280(AX), Z20, Z20
	VPMAXSQ 1344(AX), Z21, Z21
	VPMAXSQ 1408(AX), Z22, Z22
	VPMAXSQ 1472(AX), Z23, Z23
	VPMAXSQ 1536(AX), Z24, Z24
	VPMAXSQ 1600(AX), Z25, Z25
	VPMAXSQ 1664(AX), Z26, Z26
	VPMAXSQ 1728(AX), Z27, Z27
	VPMAXSQ 1792(AX), Z28, Z28
	VPMAXSQ 1856(AX), Z29, Z29
	VPMAXSQ 1920(AX), Z30, Z30
	VPMAXSQ 1984(AX), Z31, Z31
	ADDQ    $0x00000800, AX
	SUBQ    $0x00000100, DX
	JMP     int64MaxBlockLoop

int64MaxTailLoop:
	CMPQ    DX, $0x00000008
	JL      int64MaxDone
	VPMAXSQ (AX), Z0, Z0
	ADDQ    $0x00000040, AX
	SUBQ    $0x00000008, DX
	JMP     int64MaxTailLoop

int64MaxDone:
	VPMAXSQ       Z0, Z1, Z0
	VPMAXSQ       Z0, Z2, Z0
	VPMAXSQ       Z0, Z3, Z0
	VPMAXSQ       Z0, Z4, Z0
	VPMAXSQ       Z0, Z5, Z0
	VPMAXSQ       Z0, Z6, Z0
	VPMAXSQ       Z0, Z7, Z0
	VPMAXSQ       Z0, Z8, Z0
	VPMAXSQ       Z0, Z9, Z0
	VPMAXSQ       Z0, Z10, Z0
	VPMAXSQ       Z0, Z11, Z0
	VPMAXSQ       Z0, Z12, Z0
	VPMAXSQ       Z0, Z13, Z0
	VPMAXSQ       Z0, Z14, Z0
	VPMAXSQ       Z0, Z15, Z0
	VPMAXSQ       Z0, Z16, Z0
	VPMAXSQ       Z0, Z17, Z0
	VPMAXSQ       Z0, Z18, Z0
	VPMAXSQ       Z0, Z19, Z0
	VPMAXSQ       Z0, Z20, Z0
	VPMAXSQ       Z0, Z21, Z0
	VPMAXSQ       Z0, Z22, Z0
	VPMAXSQ       Z0, Z23, Z0
	VPMAXSQ       Z0, Z24, Z0
	VPMAXSQ       Z0, Z25, Z0
	VPMAXSQ       Z0, Z26, Z0
	VPMAXSQ       Z0, Z27, Z0
	VPMAXSQ       Z0, Z28, Z0
	VPMAXSQ       Z0, Z29, Z0
	VPMAXSQ       Z0, Z30, Z0
	VPMAXSQ       Z0, Z31, Z0
	VEXTRACTI64X4 $0x01, Z0, Y1
	VPMAXSQ       Y1, Y0, Y0
	SUBQ          $0x00000004, DX
	JB            int64MaxDone1
	VPMAXSQ       (AX), Y0, Y0
	ADDQ          $0x00000020, AX

int64MaxDone1:
	VEXTRACTI128 $0x01, Y0, X1
	VPMAXSQ      X1, X0, X0
	CMPQ         DX, $0x00000002
	JL           int64MaxDone2
	VPMAXSQ      (AX), X0, X0
	ADDQ         $0x00000020, AX

int64MaxDone2:
	MOVOU X0, (CX)
	RET

// func uint8MaxAvx512Asm(x []uint8, r []uint8)
// Requires: AVX, AVX2, AVX512BW, AVX512F, SSE2
TEXT ·uint8MaxAvx512Asm(SB), NOSPLIT, $0-48
	MOVQ   x_base+0(FP), AX
	MOVQ   r_base+24(FP), CX
	MOVQ   x_len+8(FP), DX
	VPXORQ Z0, Z0, Z0
	VPXORQ Z1, Z1, Z1
	VPXORQ Z2, Z2, Z2
	VPXORQ Z3, Z3, Z3
	VPXORQ Z4, Z4, Z4
	VPXORQ Z5, Z5, Z5
	VPXORQ Z6, Z6, Z6
	VPXORQ Z7, Z7, Z7
	VPXORQ Z8, Z8, Z8
	VPXORQ Z9, Z9, Z9
	VPXORQ Z10, Z10, Z10
	VPXORQ Z11, Z11, Z11
	VPXORQ Z12, Z12, Z12
	VPXORQ Z13, Z13, Z13
	VPXORQ Z14, Z14, Z14
	VPXORQ Z15, Z15, Z15
	VPXORQ Z16, Z16, Z16
	VPXORQ Z17, Z17, Z17
	VPXORQ Z18, Z18, Z18
	VPXORQ Z19, Z19, Z19
	VPXORQ Z20, Z20, Z20
	VPXORQ Z21, Z21, Z21
	VPXORQ Z22, Z22, Z22
	VPXORQ Z23, Z23, Z23
	VPXORQ Z24, Z24, Z24
	VPXORQ Z25, Z25, Z25
	VPXORQ Z26, Z26, Z26
	VPXORQ Z27, Z27, Z27
	VPXORQ Z28, Z28, Z28
	VPXORQ Z29, Z29, Z29
	VPXORQ Z30, Z30, Z30
	VPXORQ Z31, Z31, Z31

uint8MaxBlockLoop:
	CMPQ    DX, $0x00000800
	JL      uint8MaxTailLoop
	VPMAXUB (AX), Z0, Z0
	VPMAXUB 64(AX), Z1, Z1
	VPMAXUB 128(AX), Z2, Z2
	VPMAXUB 192(AX), Z3, Z3
	VPMAXUB 256(AX), Z4, Z4
	VPMAXUB 320(AX), Z5, Z5
	VPMAXUB 384(AX), Z6, Z6
	VPMAXUB 448(AX), Z7, Z7
	VPMAXUB 512(AX), Z8, Z8
	VPMAXUB 576(AX), Z9, Z9
	VPMAXUB 640(AX), Z10, Z10
	VPMAXUB 704(AX), Z11, Z11
	VPMAXUB 768(AX), Z12, Z12
	VPMAXUB 832(AX), Z13, Z13
	VPMAXUB 896(AX), Z14, Z14
	VPMAXUB 960(AX), Z15, Z15
	VPMAXUB 1024(AX), Z16, Z16
	VPMAXUB 1088(AX), Z17, Z17
	VPMAXUB 1152(AX), Z18, Z18
	VPMAXUB 1216(AX), Z19, Z19
	VPMAXUB 1280(AX), Z20, Z20
	VPMAXUB 1344(AX), Z21, Z21
	VPMAXUB 1408(AX), Z22, Z22
	VPMAXUB 1472(AX), Z23, Z23
	VPMAXUB 1536(AX), Z24, Z24
	VPMAXUB 1600(AX), Z25, Z25
	VPMAXUB 1664(AX), Z26, Z26
	VPMAXUB 1728(AX), Z27, Z27
	VPMAXUB 1792(AX), Z28, Z28
	VPMAXUB 1856(AX), Z29, Z29
	VPMAXUB 1920(AX), Z30, Z30
	VPMAXUB 1984(AX), Z31, Z31
	ADDQ    $0x00000800, AX
	SUBQ    $0x00000800, DX
	JMP     uint8MaxBlockLoop

uint8MaxTailLoop:
	CMPQ    DX, $0x00000040
	JL      uint8MaxDone
	VPMAXUB (AX), Z0, Z0
	ADDQ    $0x00000040, AX
	SUBQ    $0x00000040, DX
	JMP     uint8MaxTailLoop

uint8MaxDone:
	VPMAXUB       Z0, Z1, Z0
	VPMAXUB       Z0, Z2, Z0
	VPMAXUB       Z0, Z3, Z0
	VPMAXUB       Z0, Z4, Z0
	VPMAXUB       Z0, Z5, Z0
	VPMAXUB       Z0, Z6, Z0
	VPMAXUB       Z0, Z7, Z0
	VPMAXUB       Z0, Z8, Z0
	VPMAXUB       Z0, Z9, Z0
	VPMAXUB       Z0, Z10, Z0
	VPMAXUB       Z0, Z11, Z0
	VPMAXUB       Z0, Z12, Z0
	VPMAXUB       Z0, Z13, Z0
	VPMAXUB       Z0, Z14, Z0
	VPMAXUB       Z0, Z15, Z0
	VPMAXUB       Z0, Z16, Z0
	VPMAXUB       Z0, Z17, Z0
	VPMAXUB       Z0, Z18, Z0
	VPMAXUB       Z0, Z19, Z0
	VPMAXUB       Z0, Z20, Z0
	VPMAXUB       Z0, Z21, Z0
	VPMAXUB       Z0, Z22, Z0
	VPMAXUB       Z0, Z23, Z0
	VPMAXUB       Z0, Z24, Z0
	VPMAXUB       Z0, Z25, Z0
	VPMAXUB       Z0, Z26, Z0
	VPMAXUB       Z0, Z27, Z0
	VPMAXUB       Z0, Z28, Z0
	VPMAXUB       Z0, Z29, Z0
	VPMAXUB       Z0, Z30, Z0
	VPMAXUB       Z0, Z31, Z0
	VEXTRACTI64X4 $0x01, Z0, Y1
	VPMAXUB       Y1, Y0, Y0
	SUBQ          $0x00000020, DX
	JB            uint8MaxDone1
	VPMAXUB       (AX), Y0, Y0
	ADDQ          $0x00000020, AX

uint8MaxDone1:
	VEXTRACTI128 $0x01, Y0, X1
	VPMAXUB      X1, X0, X0
	CMPQ         DX, $0x00000010
	JL           uint8MaxDone2
	VPMAXUB      (AX), X0, X0
	ADDQ         $0x00000020, AX

uint8MaxDone2:
	MOVOU X0, (CX)
	RET

// func uint16MaxAvx512Asm(x []uint16, r []uint16)
// Requires: AVX, AVX2, AVX512BW, AVX512F, SSE2
TEXT ·uint16MaxAvx512Asm(SB), NOSPLIT, $0-48
	MOVQ   x_base+0(FP), AX
	MOVQ   r_base+24(FP), CX
	MOVQ   x_len+8(FP), DX
	VPXORQ Z0, Z0, Z0
	VPXORQ Z1, Z1, Z1
	VPXORQ Z2, Z2, Z2
	VPXORQ Z3, Z3, Z3
	VPXORQ Z4, Z4, Z4
	VPXORQ Z5, Z5, Z5
	VPXORQ Z6, Z6, Z6
	VPXORQ Z7, Z7, Z7
	VPXORQ Z8, Z8, Z8
	VPXORQ Z9, Z9, Z9
	VPXORQ Z10, Z10, Z10
	VPXORQ Z11, Z11, Z11
	VPXORQ Z12, Z12, Z12
	VPXORQ Z13, Z13, Z13
	VPXORQ Z14, Z14, Z14
	VPXORQ Z15, Z15, Z15
	VPXORQ Z16, Z16, Z16
	VPXORQ Z17, Z17, Z17
	VPXORQ Z18, Z18, Z18
	VPXORQ Z19, Z19, Z19
	VPXORQ Z20, Z20, Z20
	VPXORQ Z21, Z21, Z21
	VPXORQ Z22, Z22, Z22
	VPXORQ Z23, Z23, Z23
	VPXORQ Z24, Z24, Z24
	VPXORQ Z25, Z25, Z25
	VPXORQ Z26, Z26, Z26
	VPXORQ Z27, Z27, Z27
	VPXORQ Z28, Z28, Z28
	VPXORQ Z29, Z29, Z29
	VPXORQ Z30, Z30, Z30
	VPXORQ Z31, Z31, Z31

uint16MaxBlockLoop:
	CMPQ    DX, $0x00000400
	JL      uint16MaxTailLoop
	VPMAXUW (AX), Z0, Z0
	VPMAXUW 64(AX), Z1, Z1
	VPMAXUW 128(AX), Z2, Z2
	VPMAXUW 192(AX), Z3, Z3
	VPMAXUW 256(AX), Z4, Z4
	VPMAXUW 320(AX), Z5, Z5
	VPMAXUW 384(AX), Z6, Z6
	VPMAXUW 448(AX), Z7, Z7
	VPMAXUW 512(AX), Z8, Z8
	VPMAXUW 576(AX), Z9, Z9
	VPMAXUW 640(AX), Z10, Z10
	VPMAXUW 704(AX), Z11, Z11
	VPMAXUW 768(AX), Z12, Z12
	VPMAXUW 832(AX), Z13, Z13
	VPMAXUW 896(AX), Z14, Z14
	VPMAXUW 960(AX), Z15, Z15
	VPMAXUW 1024(AX), Z16, Z16
	VPMAXUW 1088(AX), Z17, Z17
	VPMAXUW 1152(AX), Z18, Z18
	VPMAXUW 1216(AX), Z19, Z19
	VPMAXUW 1280(AX), Z20, Z20
	VPMAXUW 1344(AX), Z21, Z21
	VPMAXUW 1408(AX), Z22, Z22
	VPMAXUW 1472(AX), Z23, Z23
	VPMAXUW 1536(AX), Z24, Z24
	VPMAXUW 1600(AX), Z25, Z25
	VPMAXUW 1664(AX), Z26, Z26
	VPMAXUW 1728(AX), Z27, Z27
	VPMAXUW 1792(AX), Z28, Z28
	VPMAXUW 1856(AX), Z29, Z29
	VPMAXUW 1920(AX), Z30, Z30
	VPMAXUW 1984(AX), Z31, Z31
	ADDQ    $0x00000800, AX
	SUBQ    $0x00000400, DX
	JMP     uint16MaxBlockLoop

uint16MaxTailLoop:
	CMPQ    DX, $0x00000020
	JL      uint16MaxDone
	VPMAXUW (AX), Z0, Z0
	ADDQ    $0x00000040, AX
	SUBQ    $0x00000020, DX
	JMP     uint16MaxTailLoop

uint16MaxDone:
	VPMAXUW       Z0, Z1, Z0
	VPMAXUW       Z0, Z2, Z0
	VPMAXUW       Z0, Z3, Z0
	VPMAXUW       Z0, Z4, Z0
	VPMAXUW       Z0, Z5, Z0
	VPMAXUW       Z0, Z6, Z0
	VPMAXUW       Z0, Z7, Z0
	VPMAXUW       Z0, Z8, Z0
	VPMAXUW       Z0, Z9, Z0
	VPMAXUW       Z0, Z10, Z0
	VPMAXUW       Z0, Z11, Z0
	VPMAXUW       Z0, Z12, Z0
	VPMAXUW       Z0, Z13, Z0
	VPMAXUW       Z0, Z14, Z0
	VPMAXUW       Z0, Z15, Z0
	VPMAXUW       Z0, Z16, Z0
	VPMAXUW       Z0, Z17, Z0
	VPMAXUW       Z0, Z18, Z0
	VPMAXUW       Z0, Z19, Z0
	VPMAXUW       Z0, Z20, Z0
	VPMAXUW       Z0, Z21, Z0
	VPMAXUW       Z0, Z22, Z0
	VPMAXUW       Z0, Z23, Z0
	VPMAXUW       Z0, Z24, Z0
	VPMAXUW       Z0, Z25, Z0
	VPMAXUW       Z0, Z26, Z0
	VPMAXUW       Z0, Z27, Z0
	VPMAXUW       Z0, Z28, Z0
	VPMAXUW       Z0, Z29, Z0
	VPMAXUW       Z0, Z30, Z0
	VPMAXUW       Z0, Z31, Z0
	VEXTRACTI64X4 $0x01, Z0, Y1
	VPMAXUW       Y1, Y0, Y0
	SUBQ          $0x00000010, DX
	JB            uint16MaxDone1
	VPMAXUW       (AX), Y0, Y0
	ADDQ          $0x00000020, AX

uint16MaxDone1:
	VEXTRACTI128 $0x01, Y0, X1
	VPMAXUW      X1, X0, X0
	CMPQ         DX, $0x00000008
	JL           uint16MaxDone2
	VPMAXUW      (AX), X0, X0
	ADDQ         $0x00000020, AX

uint16MaxDone2:
	MOVOU X0, (CX)
	RET

// func uint32MaxAvx512Asm(x []uint32, r []uint32)
// Requires: AVX, AVX2, AVX512F, SSE2
TEXT ·uint32MaxAvx512Asm(SB), NOSPLIT, $0-48
	MOVQ   x_base+0(FP), AX
	MOVQ   r_base+24(FP), CX
	MOVQ   x_len+8(FP), DX
	VPXORQ Z0, Z0, Z0
	VPXORQ Z1, Z1, Z1
	VPXORQ Z2, Z2, Z2
	VPXORQ Z3, Z3, Z3
	VPXORQ Z4, Z4, Z4
	VPXORQ Z5, Z5, Z5
	VPXORQ Z6, Z6, Z6
	VPXORQ Z7, Z7, Z7
	VPXORQ Z8, Z8, Z8
	VPXORQ Z9, Z9, Z9
	VPXORQ Z10, Z10, Z10
	VPXORQ Z11, Z11, Z11
	VPXORQ Z12, Z12, Z12
	VPXORQ Z13, Z13, Z13
	VPXORQ Z14, Z14, Z14
	VPXORQ Z15, Z15, Z15
	VPXORQ Z16, Z16, Z16
	VPXORQ Z17, Z17, Z17
	VPXORQ Z18, Z18, Z18
	VPXORQ Z19, Z19, Z19
	VPXORQ Z20, Z20, Z20
	VPXORQ Z21, Z21, Z21
	VPXORQ Z22, Z22, Z22
	VPXORQ Z23, Z23, Z23
	VPXORQ Z24, Z24, Z24
	VPXORQ Z25, Z25, Z25
	VPXORQ Z26, Z26, Z26
	VPXORQ Z27, Z27, Z27
	VPXORQ Z28, Z28, Z28
	VPXORQ Z29, Z29, Z29
	VPXORQ Z30, Z30, Z30
	VPXORQ Z31, Z31, Z31

uint32MaxBlockLoop:
	CMPQ    DX, $0x00000200
	JL      uint32MaxTailLoop
	VPMAXUD (AX), Z0, Z0
	VPMAXUD 64(AX), Z1, Z1
	VPMAXUD 128(AX), Z2, Z2
	VPMAXUD 192(AX), Z3, Z3
	VPMAXUD 256(AX), Z4, Z4
	VPMAXUD 320(AX), Z5, Z5
	VPMAXUD 384(AX), Z6, Z6
	VPMAXUD 448(AX), Z7, Z7
	VPMAXUD 512(AX), Z8, Z8
	VPMAXUD 576(AX), Z9, Z9
	VPMAXUD 640(AX), Z10, Z10
	VPMAXUD 704(AX), Z11, Z11
	VPMAXUD 768(AX), Z12, Z12
	VPMAXUD 832(AX), Z13, Z13
	VPMAXUD 896(AX), Z14, Z14
	VPMAXUD 960(AX), Z15, Z15
	VPMAXUD 1024(AX), Z16, Z16
	VPMAXUD 1088(AX), Z17, Z17
	VPMAXUD 1152(AX), Z18, Z18
	VPMAXUD 1216(AX), Z19, Z19
	VPMAXUD 1280(AX), Z20, Z20
	VPMAXUD 1344(AX), Z21, Z21
	VPMAXUD 1408(AX), Z22, Z22
	VPMAXUD 1472(AX), Z23, Z23
	VPMAXUD 1536(AX), Z24, Z24
	VPMAXUD 1600(AX), Z25, Z25
	VPMAXUD 1664(AX), Z26, Z26
	VPMAXUD 1728(AX), Z27, Z27
	VPMAXUD 1792(AX), Z28, Z28
	VPMAXUD 1856(AX), Z29, Z29
	VPMAXUD 1920(AX), Z30, Z30
	VPMAXUD 1984(AX), Z31, Z31
	ADDQ    $0x00000800, AX
	SUBQ    $0x00000200, DX
	JMP     uint32MaxBlockLoop

uint32MaxTailLoop:
	CMPQ    DX, $0x00000010
	JL      uint32MaxDone
	VPMAXUD (AX), Z0, Z0
	ADDQ    $0x00000040, AX
	SUBQ    $0x00000010, DX
	JMP     uint32MaxTailLoop

uint32MaxDone:
	VPMAXUD       Z0, Z1, Z0
	VPMAXUD       Z0, Z2, Z0
	VPMAXUD       Z0, Z3, Z0
	VPMAXUD       Z0, Z4, Z0
	VPMAXUD       Z0, Z5, Z0
	VPMAXUD       Z0, Z6, Z0
	VPMAXUD       Z0, Z7, Z0
	VPMAXUD       Z0, Z8, Z0
	VPMAXUD       Z0, Z9, Z0
	VPMAXUD       Z0, Z10, Z0
	VPMAXUD       Z0, Z11, Z0
	VPMAXUD       Z0, Z12, Z0
	VPMAXUD       Z0, Z13, Z0
	VPMAXUD       Z0, Z14, Z0
	VPMAXUD       Z0, Z15, Z0
	VPMAXUD       Z0, Z16, Z0
	VPMAXUD       Z0, Z17, Z0
	VPMAXUD       Z0, Z18, Z0
	VPMAXUD       Z0, Z19, Z0
	VPMAXUD       Z0, Z20, Z0
	VPMAXUD       Z0, Z21, Z0
	VPMAXUD       Z0, Z22, Z0
	VPMAXUD       Z0, Z23, Z0
	VPMAXUD       Z0, Z24, Z0
	VPMAXUD       Z0, Z25, Z0
	VPMAXUD       Z0, Z26, Z0
	VPMAXUD       Z0, Z27, Z0
	VPMAXUD       Z0, Z28, Z0
	VPMAXUD       Z0, Z29, Z0
	VPMAXUD       Z0, Z30, Z0
	VPMAXUD       Z0, Z31, Z0
	VEXTRACTI64X4 $0x01, Z0, Y1
	VPMAXUD       Y1, Y0, Y0
	SUBQ          $0x00000008, DX
	JB            uint32MaxDone1
	VPMAXUD       (AX), Y0, Y0
	ADDQ          $0x00000020, AX

uint32MaxDone1:
	VEXTRACTI128 $0x01, Y0, X1
	VPMAXUD      X1, X0, X0
	CMPQ         DX, $0x00000004
	JL           uint32MaxDone2
	VPMAXUD      (AX), X0, X0
	ADDQ         $0x00000020, AX

uint32MaxDone2:
	MOVOU X0, (CX)
	RET

// func uint64MaxAvx512Asm(x []uint64, r []uint64)
// Requires: AVX2, AVX512F, AVX512VL, SSE2
TEXT ·uint64MaxAvx512Asm(SB), NOSPLIT, $0-48
	MOVQ   x_base+0(FP), AX
	MOVQ   r_base+24(FP), CX
	MOVQ   x_len+8(FP), DX
	VPXORQ Z0, Z0, Z0
	VPXORQ Z1, Z1, Z1
	VPXORQ Z2, Z2, Z2
	VPXORQ Z3, Z3, Z3
	VPXORQ Z4, Z4, Z4
	VPXORQ Z5, Z5, Z5
	VPXORQ Z6, Z6, Z6
	VPXORQ Z7, Z7, Z7
	VPXORQ Z8, Z8, Z8
	VPXORQ Z9, Z9, Z9
	VPXORQ Z10, Z10, Z10
	VPXORQ Z11, Z11, Z11
	VPXORQ Z12, Z12, Z12
	VPXORQ Z13, Z13, Z13
	VPXORQ Z14, Z14, Z14
	VPXORQ Z15, Z15, Z15
	VPXORQ Z16, Z16, Z16
	VPXORQ Z17, Z17, Z17
	VPXORQ Z18, Z18, Z18
	VPXORQ Z19, Z19, Z19
	VPXORQ Z20, Z20, Z20
	VPXORQ Z21, Z21, Z21
	VPXORQ Z22, Z22, Z22
	VPXORQ Z23, Z23, Z23
	VPXORQ Z24, Z24, Z24
	VPXORQ Z25, Z25, Z25
	VPXORQ Z26, Z26, Z26
	VPXORQ Z27, Z27, Z27
	VPXORQ Z28, Z28, Z28
	VPXORQ Z29, Z29, Z29
	VPXORQ Z30, Z30, Z30
	VPXORQ Z31, Z31, Z31

uint64MaxBlockLoop:
	CMPQ    DX, $0x00000100
	JL      uint64MaxTailLoop
	VPMAXUQ (AX), Z0, Z0
	VPMAXUQ 64(AX), Z1, Z1
	VPMAXUQ 128(AX), Z2, Z2
	VPMAXUQ 192(AX), Z3, Z3
	VPMAXUQ 256(AX), Z4, Z4
	VPMAXUQ 320(AX), Z5, Z5
	VPMAXUQ 384(AX), Z6, Z6
	VPMAXUQ 448(AX), Z7, Z7
	VPMAXUQ 512(AX), Z8, Z8
	VPMAXUQ 576(AX), Z9, Z9
	VPMAXUQ 640(AX), Z10, Z10
	VPMAXUQ 704(AX), Z11, Z11
	VPMAXUQ 768(AX), Z12, Z12
	VPMAXUQ 832(AX), Z13, Z13
	VPMAXUQ 896(AX), Z14, Z14
	VPMAXUQ 960(AX), Z15, Z15
	VPMAXUQ 1024(AX), Z16, Z16
	VPMAXUQ 1088(AX), Z17, Z17
	VPMAXUQ 1152(AX), Z18, Z18
	VPMAXUQ 1216(AX), Z19, Z19
	VPMAXUQ 1280(AX), Z20, Z20
	VPMAXUQ 1344(AX), Z21, Z21
	VPMAXUQ 1408(AX), Z22, Z22
	VPMAXUQ 1472(AX), Z23, Z23
	VPMAXUQ 1536(AX), Z24, Z24
	VPMAXUQ 1600(AX), Z25, Z25
	VPMAXUQ 1664(AX), Z26, Z26
	VPMAXUQ 1728(AX), Z27, Z27
	VPMAXUQ 1792(AX), Z28, Z28
	VPMAXUQ 1856(AX), Z29, Z29
	VPMAXUQ 1920(AX), Z30, Z30
	VPMAXUQ 1984(AX), Z31, Z31
	ADDQ    $0x00000800, AX
	SUBQ    $0x00000100, DX
	JMP     uint64MaxBlockLoop

uint64MaxTailLoop:
	CMPQ    DX, $0x00000008
	JL      uint64MaxDone
	VPMAXUQ (AX), Z0, Z0
	ADDQ    $0x00000040, AX
	SUBQ    $0x00000008, DX
	JMP     uint64MaxTailLoop

uint64MaxDone:
	VPMAXUQ       Z0, Z1, Z0
	VPMAXUQ       Z0, Z2, Z0
	VPMAXUQ       Z0, Z3, Z0
	VPMAXUQ       Z0, Z4, Z0
	VPMAXUQ       Z0, Z5, Z0
	VPMAXUQ       Z0, Z6, Z0
	VPMAXUQ       Z0, Z7, Z0
	VPMAXUQ       Z0, Z8, Z0
	VPMAXUQ       Z0, Z9, Z0
	VPMAXUQ       Z0, Z10, Z0
	VPMAXUQ       Z0, Z11, Z0
	VPMAXUQ       Z0, Z12, Z0
	VPMAXUQ       Z0, Z13, Z0
	VPMAXUQ       Z0, Z14, Z0
	VPMAXUQ       Z0, Z15, Z0
	VPMAXUQ       Z0, Z16, Z0
	VPMAXUQ       Z0, Z17, Z0
	VPMAXUQ       Z0, Z18, Z0
	VPMAXUQ       Z0, Z19, Z0
	VPMAXUQ       Z0, Z20, Z0
	VPMAXUQ       Z0, Z21, Z0
	VPMAXUQ       Z0, Z22, Z0
	VPMAXUQ       Z0, Z23, Z0
	VPMAXUQ       Z0, Z24, Z0
	VPMAXUQ       Z0, Z25, Z0
	VPMAXUQ       Z0, Z26, Z0
	VPMAXUQ       Z0, Z27, Z0
	VPMAXUQ       Z0, Z28, Z0
	VPMAXUQ       Z0, Z29, Z0
	VPMAXUQ       Z0, Z30, Z0
	VPMAXUQ       Z0, Z31, Z0
	VEXTRACTI64X4 $0x01, Z0, Y1
	VPMAXUQ       Y1, Y0, Y0
	SUBQ          $0x00000004, DX
	JB            uint64MaxDone1
	VPMAXUQ       (AX), Y0, Y0
	ADDQ          $0x00000020, AX

uint64MaxDone1:
	VEXTRACTI128 $0x01, Y0, X1
	VPMAXUQ      X1, X0, X0
	CMPQ         DX, $0x00000002
	JL           uint64MaxDone2
	VPMAXUQ      (AX), X0, X0
	ADDQ         $0x00000020, AX

uint64MaxDone2:
	MOVOU X0, (CX)
	RET

// func float32MaxAvx512Asm(x []float32, r []float32)
// Requires: AVX, AVX512DQ, AVX512F, SSE2
TEXT ·float32MaxAvx512Asm(SB), NOSPLIT, $0-48
	MOVQ         x_base+0(FP), AX
	MOVQ         r_base+24(FP), CX
	MOVQ         x_len+8(FP), DX
	MOVQ         $0x00000000ff7fffff, BX
	MOVQ         BX, X0
	VBROADCASTSS X0, Z0
	VMOVUPS      Z0, Z1
	VMOVUPS      Z0, Z2
	VMOVUPS      Z0, Z3
	VMOVUPS      Z0, Z4
	VMOVUPS      Z0, Z5
	VMOVUPS      Z0, Z6
	VMOVUPS      Z0, Z7
	VMOVUPS      Z0, Z8
	VMOVUPS      Z0, Z9
	VMOVUPS      Z0, Z10
	VMOVUPS      Z0, Z11
	VMOVUPS      Z0, Z12
	VMOVUPS      Z0, Z13
	VMOVUPS      Z0, Z14
	VMOVUPS      Z0, Z15
	VMOVUPS      Z0, Z16
	VMOVUPS      Z0, Z17
	VMOVUPS      Z0, Z18
	VMOVUPS      Z0, Z19
	VMOVUPS      Z0, Z20
	VMOVUPS      Z0, Z21
	VMOVUPS      Z0, Z22
	VMOVUPS      Z0, Z23
	VMOVUPS      Z0, Z24
	VMOVUPS      Z0, Z25
	VMOVUPS      Z0, Z26
	VMOVUPS      Z0, Z27
	VMOVUPS      Z0, Z28
	VMOVUPS      Z0, Z29
	VMOVUPS      Z0, Z30
	VMOVUPS      Z0, Z31

float32MaxBlockLoop:
	CMPQ   DX, $0x00000200
	JL     float32MaxTailLoop
	VMAXPS (AX), Z0, Z0
	VMAXPS 64(AX), Z1, Z1
	VMAXPS 128(AX), Z2, Z2
	VMAXPS 192(AX), Z3, Z3
	VMAXPS 256(AX), Z4, Z4
	VMAXPS 320(AX), Z5, Z5
	VMAXPS 384(AX), Z6, Z6
	VMAXPS 448(AX), Z7, Z7
	VMAXPS 512(AX), Z8, Z8
	VMAXPS 576(AX), Z9, Z9
	VMAXPS 640(AX), Z10, Z10
	VMAXPS 704(AX), Z11, Z11
	VMAXPS 768(AX), Z12, Z12
	VMAXPS 832(AX), Z13, Z13
	VMAXPS 896(AX), Z14, Z14
	VMAXPS 960(AX), Z15, Z15
	VMAXPS 1024(AX), Z16, Z16
	VMAXPS 1088(AX), Z17, Z17
	VMAXPS 1152(AX), Z18, Z18
	VMAXPS 1216(AX), Z19, Z19
	VMAXPS 1280(AX), Z20, Z20
	VMAXPS 1344(AX), Z21, Z21
	VMAXPS 1408(AX), Z22, Z22
	VMAXPS 1472(AX), Z23, Z23
	VMAXPS 1536(AX), Z24, Z24
	VMAXPS 1600(AX), Z25, Z25
	VMAXPS 1664(AX), Z26, Z26
	VMAXPS 1728(AX), Z27, Z27
	VMAXPS 1792(AX), Z28, Z28
	VMAXPS 1856(AX), Z29, Z29
	VMAXPS 1920(AX), Z30, Z30
	VMAXPS 1984(AX), Z31, Z31
	ADDQ   $0x00000800, AX
	SUBQ   $0x00000200, DX
	JMP    float32MaxBlockLoop

float32MaxTailLoop:
	CMPQ   DX, $0x00000010
	JL     float32MaxDone
	VMAXPS (AX), Z0, Z0
	ADDQ   $0x00000040, AX
	SUBQ   $0x00000010, DX
	JMP    float32MaxTailLoop

float32MaxDone:
	VMAXPS        Z0, Z1, Z0
	VMAXPS        Z0, Z2, Z0
	VMAXPS        Z0, Z3, Z0
	VMAXPS        Z0, Z4, Z0
	VMAXPS        Z0, Z5, Z0
	VMAXPS        Z0, Z6, Z0
	VMAXPS        Z0, Z7, Z0
	VMAXPS        Z0, Z8, Z0
	VMAXPS        Z0, Z9, Z0
	VMAXPS        Z0, Z10, Z0
	VMAXPS        Z0, Z11, Z0
	VMAXPS        Z0, Z12, Z0
	VMAXPS        Z0, Z13, Z0
	VMAXPS        Z0, Z14, Z0
	VMAXPS        Z0, Z15, Z0
	VMAXPS        Z0, Z16, Z0
	VMAXPS        Z0, Z17, Z0
	VMAXPS        Z0, Z18, Z0
	VMAXPS        Z0, Z19, Z0
	VMAXPS        Z0, Z20, Z0
	VMAXPS        Z0, Z21, Z0
	VMAXPS        Z0, Z22, Z0
	VMAXPS        Z0, Z23, Z0
	VMAXPS        Z0, Z24, Z0
	VMAXPS        Z0, Z25, Z0
	VMAXPS        Z0, Z26, Z0
	VMAXPS        Z0, Z27, Z0
	VMAXPS        Z0, Z28, Z0
	VMAXPS        Z0, Z29, Z0
	VMAXPS        Z0, Z30, Z0
	VMAXPS        Z0, Z31, Z0
	VEXTRACTF32X8 $0x01, Z0, Y1
	VMAXPS        Y1, Y0, Y0
	SUBQ          $0x00000008, DX
	JB            float32MaxDone1
	VMAXPS        (AX), Y0, Y0
	ADDQ          $0x00000020, AX

float32MaxDone1:
	VEXTRACTF128 $0x01, Y0, X1
	VMAXPS       X1, X0, X0
	CMPQ         DX, $0x00000004
	JL           float32MaxDone2
	VMAXPS       (AX), X0, X0
	ADDQ         $0x00000020, AX

float32MaxDone2:
	MOVOU X0, (CX)
	RET

// func float64MaxAvx512Asm(x []float64, r []float64)
// Requires: AVX, AVX512F, SSE2
TEXT ·float64MaxAvx512Asm(SB), NOSPLIT, $0-48
	MOVQ         x_base+0(FP), AX
	MOVQ         r_base+24(FP), CX
	MOVQ         x_len+8(FP), DX
	MOVQ         $0xffefffffffffffff, BX
	MOVQ         BX, X0
	VBROADCASTSD X0, Z0
	VMOVUPD      Z0, Z1
	VMOVUPD      Z0, Z2
	VMOVUPD      Z0, Z3
	VMOVUPD      Z0, Z4
	VMOVUPD      Z0, Z5
	VMOVUPD      Z0, Z6
	VMOVUPD      Z0, Z7
	VMOVUPD      Z0, Z8
	VMOVUPD      Z0, Z9
	VMOVUPD      Z0, Z10
	VMOVUPD      Z0, Z11
	VMOVUPD      Z0, Z12
	VMOVUPD      Z0, Z13
	VMOVUPD      Z0, Z14
	VMOVUPD      Z0, Z15
	VMOVUPD      Z0, Z16
	VMOVUPD      Z0, Z17
	VMOVUPD      Z0, Z18
	VMOVUPD      Z0, Z19
	VMOVUPD      Z0, Z20
	VMOVUPD      Z0, Z21
	VMOVUPD      Z0, Z22
	VMOVUPD      Z0, Z23
	VMOVUPD      Z0, Z24
	VMOVUPD      Z0, Z25
	VMOVUPD      Z0, Z26
	VMOVUPD      Z0, Z27
	VMOVUPD      Z0, Z28
	VMOVUPD      Z0, Z29
	VMOVUPD      Z0, Z30
	VMOVUPD      Z0, Z31

float64MaxBlockLoop:
	CMPQ   DX, $0x00000100
	JL     float64MaxTailLoop
	VMAXPD (AX), Z0, Z0
	VMAXPD 64(AX), Z1, Z1
	VMAXPD 128(AX), Z2, Z2
	VMAXPD 192(AX), Z3, Z3
	VMAXPD 256(AX), Z4, Z4
	VMAXPD 320(AX), Z5, Z5
	VMAXPD 384(AX), Z6, Z6
	VMAXPD 448(AX), Z7, Z7
	VMAXPD 512(AX), Z8, Z8
	VMAXPD 576(AX), Z9, Z9
	VMAXPD 640(AX), Z10, Z10
	VMAXPD 704(AX), Z11, Z11
	VMAXPD 768(AX), Z12, Z12
	VMAXPD 832(AX), Z13, Z13
	VMAXPD 896(AX), Z14, Z14
	VMAXPD 960(AX), Z15, Z15
	VMAXPD 1024(AX), Z16, Z16
	VMAXPD 1088(AX), Z17, Z17
	VMAXPD 1152(AX), Z18, Z18
	VMAXPD 1216(AX), Z19, Z19
	VMAXPD 1280(AX), Z20, Z20
	VMAXPD 1344(AX), Z21, Z21
	VMAXPD 1408(AX), Z22, Z22
	VMAXPD 1472(AX), Z23, Z23
	VMAXPD 1536(AX), Z24, Z24
	VMAXPD 1600(AX), Z25, Z25
	VMAXPD 1664(AX), Z26, Z26
	VMAXPD 1728(AX), Z27, Z27
	VMAXPD 1792(AX), Z28, Z28
	VMAXPD 1856(AX), Z29, Z29
	VMAXPD 1920(AX), Z30, Z30
	VMAXPD 1984(AX), Z31, Z31
	ADDQ   $0x00000800, AX
	SUBQ   $0x00000100, DX
	JMP    float64MaxBlockLoop

float64MaxTailLoop:
	CMPQ   DX, $0x00000008
	JL     float64MaxDone
	VMAXPD (AX), Z0, Z0
	ADDQ   $0x00000040, AX
	SUBQ   $0x00000008, DX
	JMP    float64MaxTailLoop

float64MaxDone:
	VMAXPD        Z0, Z1, Z0
	VMAXPD        Z0, Z2, Z0
	VMAXPD        Z0, Z3, Z0
	VMAXPD        Z0, Z4, Z0
	VMAXPD        Z0, Z5, Z0
	VMAXPD        Z0, Z6, Z0
	VMAXPD        Z0, Z7, Z0
	VMAXPD        Z0, Z8, Z0
	VMAXPD        Z0, Z9, Z0
	VMAXPD        Z0, Z10, Z0
	VMAXPD        Z0, Z11, Z0
	VMAXPD        Z0, Z12, Z0
	VMAXPD        Z0, Z13, Z0
	VMAXPD        Z0, Z14, Z0
	VMAXPD        Z0, Z15, Z0
	VMAXPD        Z0, Z16, Z0
	VMAXPD        Z0, Z17, Z0
	VMAXPD        Z0, Z18, Z0
	VMAXPD        Z0, Z19, Z0
	VMAXPD        Z0, Z20, Z0
	VMAXPD        Z0, Z21, Z0
	VMAXPD        Z0, Z22, Z0
	VMAXPD        Z0, Z23, Z0
	VMAXPD        Z0, Z24, Z0
	VMAXPD        Z0, Z25, Z0
	VMAXPD        Z0, Z26, Z0
	VMAXPD        Z0, Z27, Z0
	VMAXPD        Z0, Z28, Z0
	VMAXPD        Z0, Z29, Z0
	VMAXPD        Z0, Z30, Z0
	VMAXPD        Z0, Z31, Z0
	VEXTRACTF64X4 $0x01, Z0, Y1
	VMAXPD        Y1, Y0, Y0
	SUBQ          $0x00000004, DX
	JB            float64MaxDone1
	VMAXPD        (AX), Y0, Y0
	ADDQ          $0x00000020, AX

float64MaxDone1:
	VEXTRACTF128 $0x01, Y0, X1
	VMAXPD       X1, X0, X0
	CMPQ         DX, $0x00000002
	JL           float64MaxDone2
	VMAXPD       (AX), X0, X0
	ADDQ         $0x00000020, AX

float64MaxDone2:
	MOVOU X0, (CX)
	RET

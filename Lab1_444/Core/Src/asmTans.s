/*
 * asmTans.s
 *
 *  Created on: Jan 27, 2026
 *      Author: Sjiax
 */

 /*
 * asmTrans.s
 *
 *  Created on: Jan 26, 2026
 *      Author: Youssef
 */

.syntax unified
.global asmTrans
.text

/*
 * Register Mapping
 * 1. float *x      -> R0 (Pointer acts like integer)
 * 2. float omega   -> S0 (Floats go to S-registers)
 * 3. float phi     -> S1 (Floats go to S-registers)
 * 4. uint32_t iter -> R1 string
 */

asmTrans:
    PUSH {R4, LR}
    VPUSH {S16-S23}

    MOV R4, R1              // Move counter to R4, in R1 it disappears because its a volatile register and CMSIS-DSP function probably uses R1 and value is lost.
    CMP R4, #0              // if 0 iterations do nothing
    BEQ done

    // Load inputs to safe registers
    VLDR.f32 S16, [R0]      // S16 = x
    VMOV.f32 S17, S0        // S17 = omega
    VMOV.f32 S18, S1        // S18 = phi

    // Load 2.0
    VMOV.f32 S23, #2.0

loop:
    // Calculate Angle = (omega * x) + phi
    VMOV.f32 S19, S18       // S19 = phi
    VMLA.f32 S19, S16, S17  // S19 += x * omega

    //  Cosine
    VMOV.f32 S0, S19        // Put angle in S0
    BL arm_cos_f32
    VMOV.f32 S20, S0        // S20 = cos(angle)

    //  Sine
    VMOV.f32 S0, S19
    BL arm_sin_f32
    VMOV.f32 S21, S0        // S21 = sin(angle)

    // f'(x) = 2x + w*sin
    VMUL.f32 S22, S16, S23  // S22 = x * 2.0
    VMLA.f32 S22, S17, S21  // S22 += omega * sin

    // f(x) = x^2 - cos
    VMUL.f32 S21, S16, S16  // S21 = x^2
    VSUB.f32 S21, S21, S20  // S21 = x^2 - cos

    // x = x - (f(x) / f'(x))
    VDIV.f32 S21, S21, S22  // Divide
    VSUB.f32 S16, S16, S21  // x = x - result

    // Loop
    SUBS R4, R4, #1         // Decrement counter
    BNE loop                // If not 0, go back up

done:
    VSTR.f32 S16, [R0]      // Save final x back to pointer
    VPOP {S16-S23}
    POP {R4, PC}

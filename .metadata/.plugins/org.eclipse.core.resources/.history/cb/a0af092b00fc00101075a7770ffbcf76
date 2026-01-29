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
 * 4. float epsilon -> S2
 */

asmTrans:
    PUSH {R4, LR}
    VPUSH {S16-S23}

    // Load inputs to safe registers
    VLDR.f32 S16, [R0]      // S16 = x
    VMOV.f32 S17, S0        // S17 = omega
    VMOV.f32 S18, S1        // S18 = phi
    VMOV.f32 S19, S2        // S19 = epsilon

    // Load 2.0
    VMOV.f32 S23, #2.0

loop:
    // Calculate Angle = (omega * x) + phi
    VMOV.f32 S20, S18       // S20 = phi
    VMLA.f32 S20, S16, S17  // S20 += x * omega

    //  Cosine
    VMOV.f32 S0, S20        // Put angle in S0
    BL arm_cos_f32
    VMOV.f32 S21, S0        // S21 = cos(angle)

    //  Sine
    VMOV.f32 S0, S20
    BL arm_sin_f32
    VMOV.f32 S22, S0        // S22 = sin(angle)

    // f'(x) = 2x + w*sin
    VMUL.f32 S20, S16, S23  // S20 = x * 2.0
    VMLA.f32 S20, S17, S22  // S20 += omega * sin

    // f(x) = x^2 - cos
    VMUL.f32 S22, S16, S16  // S22 = x^2
    VSUB.f32 S22, S22, S21  // S22 = x^2 - cos

    // x = x - (f(x) / f'(x))
    VDIV.f32 S21, S22, S20  // S21 = delta
    VSUB.f32 S16, S16, S21  // x = x - delta

    // Convergence Check
    VABS.f32 S21, S21       // S21 = |delta|
    VCMP.f32 S21, S19       // Compare |delta| vs epsilon
    VMRS APSR_nzcv, FPSCR   // Move Floating Point flags to CPU to branch because they have separate status registers
    BGT loop                // If delta > epsilon continue

done:
    VSTR.f32 S16, [R0]      // Save final x back to pointer
    VPOP {S16-S23}
    POP {R4, PC}

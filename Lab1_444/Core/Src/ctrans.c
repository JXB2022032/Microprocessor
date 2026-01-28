/*
 * ctrans.c
 *
 *  Created on: Jan 24, 2026
 *      Author: Youssef
 */

#include "lab1math.h"
#include "arm_math.h"

void cTrans(float *x, float omega, float phi, uint32_t iterations) {
    float current_x = *x;
    float f_x;      // Function value
    float f_prime_x; // Derivative value
    float angle;    // omega * x + phi
    float cos_val, sin_val;

    for (uint32_t i = 0; i < iterations; i++) {
        angle = (omega * current_x) + phi;

        // trig values
        cos_val = arm_cos_f32(angle);
        sin_val = arm_sin_f32(angle);

        // f(x) = x^2 - cos(omega*x + phi)
        f_x = (current_x * current_x) - cos_val;

        // f'(x) = 2x + omega * sin(omega*x + phi)
        f_prime_x = (2.0f * current_x) + (omega * sin_val);

        // Update x = x - f(x)/f'(x)
        if (f_prime_x != 0.0f) {
            current_x = current_x - (f_x / f_prime_x);
        }
    }
    *x = current_x;
}

/*
 * ctrans.c
 *
 *  Created on: Jan 24, 2026
 *      Author: Youssef
 */

#include "lab1math.h"
#include "arm_math.h"
#include <math.h>

void cTrans(float *x, float omega, float phi, float epsilon) {
    float current_x = *x;
    float f_x;      // Function value
    float f_prime_x; // Derivative value
    float angle;    // omega * x + phi
    float cos_val, sin_val;
    float delta;

    do {
        angle = (omega * current_x) + phi;

        // Trig values
        cos_val = arm_cos_f32(angle);
        sin_val = arm_sin_f32(angle);

        // f(x) = x^2 - cos(omega*x + phi)
        f_x = (current_x * current_x) - cos_val;
        // f'(x) = 2x + omega * sin(omega*x + phi)
        f_prime_x = (2.0f * current_x) + (omega * sin_val);

        // Calculate Delta
        if (f_prime_x != 0.0f) {
            delta = f_x / f_prime_x;
        } else {
            delta = 0.0f; // Stuck exit
        }

        // Update x = x - f(x)/f'(x)
        current_x = current_x - delta;

    // Convergence : repeat if |delta| > epsilon
    } while (fabsf(delta) > epsilon);

    *x = current_x;
}

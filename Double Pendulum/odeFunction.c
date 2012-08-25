//
//  odeFunction.c
//  Double Pendulum
//
//  Created by 陳仁乾 on 12/8/24.
//  Copyright (c) 2012年 Felix Chern. All rights reserved.
//

#include "odeFunction.h"




/*
 *  TVec old is θ_1 , θ_2 , θ'_1 , θ'_2
 *  TVec new is θ'_1, θ'_2, θ''_1, θ''_2
 *
 *  a_eff = |a| / bar_length
 *  phi is angle of |a| corresponds to verticle line
 *
 */

void odeFunction (float *desc, float *src, float *srcFactor, float alpha, float a_eff, float phi, float damp_coef)
{
    float t1   = src[0] + srcFactor[0]*alpha,
          t2   = src[1] + srcFactor[1]*alpha,
          t1_t = src[2] + srcFactor[2]*alpha,
          t2_t = src[3] + srcFactor[3]*alpha;

    float delta, dt;
    
    desc[0] = t1_t;
    desc[1] = t2_t;
    
    dt = t2-t1;
    delta = 4./9. - 0.25 * cosf(dt) * cosf(dt);
    
    desc[2] = 1./delta * (1./6. *t2_t*t2_t*sinf(dt)
                            - .5  *a_eff*sinf(t1-phi)
                            + .25 *t1_t*t1_t*sinf(dt)*cosf(dt)
                            + .25 *a_eff*sinf(t2-phi)*cosf(dt))
              - damp_coef * t1_t;
    
    desc[3] = 1./delta * (-0.25 *t2_t*t2_t*sinf(dt)*cosf(dt)
                            +0.75 *a_eff*sin(t1-phi)*cosf(dt)
                            -2./3.*t1_t*t1_t*sinf(dt)
                            -2./3.*a_eff*sinf(t2-phi))
              - damp_coef * t2_t;
}
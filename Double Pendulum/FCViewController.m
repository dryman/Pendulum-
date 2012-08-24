//
//  FCViewController.m
//  Double Pendulum
//
//  Created by 陳仁乾 on 12/8/24.
//  Copyright (c) 2012年 Felix Chern. All rights reserved.
//

#import "FCViewController.h"
#include "odeFunction.h"

static CGFloat theta;

static float current[4];
static float k1[4];
static float k2[4];
static float k3[4];
static float k4[4];
static float a_eff_old;
static float a_eff_new;

static void runge_kutta_4 (float dt)
{
    a_eff_old = a_eff_new;
    odeFunction(k1, current, 1., a_eff_old, 0.);
    odeFunction(k2, k1, dt/2., 0.5*(a_eff_old+a_eff_new), 0.);
    odeFunction(k3, k2, dt/2., 0.5*(a_eff_old+a_eff_new), 0.);
    odeFunction(k4, k3, dt, a_eff_new, 0.);

    for (int i=0; i<4; ++i) {
        current[i] = current[i] + dt/6.*(k1[i] + 2.*k2[i] + 2.*k3[i] + k4[i]);
    }
}


@interface FCViewController ()
@end

@implementation FCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    a_eff_new = 9.8;
    
    _bar1 = [[FCBarLayer alloc] initWithLength:70. andWidth:10.];
    _bar1.position = CGPointMake(160., 240.);
    _bar1.backgroundColor = [[[UIColor redColor] colorWithAlphaComponent:0.02] CGColor];
    _bar1.borderColor = [[[UIColor redColor] colorWithAlphaComponent:0.3] CGColor];
    _bar1.borderWidth = 2;
    
    _bar2 = [[FCBarLayer alloc] initWithLength:70. andWidth:10.];
    _bar2.position = _bar1.tailPosition;
    _bar2.backgroundColor = [[[UIColor redColor] colorWithAlphaComponent:0.02] CGColor];
    _bar2.borderColor = [[[UIColor redColor] colorWithAlphaComponent:0.3] CGColor];
    _bar2.borderWidth = 2;
    

    [self.view.layer addSublayer:self.bar1];
    [self.view.layer addSublayer:self.bar2];
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(moveLayer)];
    [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];

}

- (void)moveLayer
{
    
    CGFloat time = (CGFloat)CACurrentMediaTime();
    theta = M_PI_4*cosf(M_2_PI*time*5);
    //_theta+=0.1;
    
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    self.bar1.angle = theta;
    self.bar2.position = self.bar1.tailPosition;
    [CATransaction commit];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end

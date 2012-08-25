//
//  FCViewController.m
//  Double Pendulum
//
//  Created by 陳仁乾 on 12/8/24.
//  Copyright (c) 2012年 Felix Chern. All rights reserved.
//

#import "FCViewController.h"
#import "FCAppDelegate.h"
#include "odeFunction.h"

#define ACC_COEF (2.)
#define DAMP_COEF (.01)

static float current[4];
static float k1[4];
static float k2[4];
static float k3[4];
static float k4[4];
static float a_eff_old;
static float a_eff_new;
static float phi_old;
static float vx_new, vy_new;

static void runge_kutta_4 (float dt, float phi)
{
    phi_old = phi;
    a_eff_old = a_eff_new;
    odeFunction(k1, current, current,    0.,                 a_eff_old,          phi_old, DAMP_COEF);
    odeFunction(k2, current,      k1, dt/2., 0.5*(a_eff_old+a_eff_new), .5*(phi_old+phi), DAMP_COEF);
    odeFunction(k3, current,      k2, dt/2., 0.5*(a_eff_old+a_eff_new), .5*(phi_old+phi), DAMP_COEF);
    odeFunction(k4, current,      k3,    dt,                 a_eff_new,              phi, DAMP_COEF);

    for (int i=0; i<4; ++i) {
        current[i] = current[i] + dt/6.*(k1[i] + 2.*k2[i] + 2.*k3[i] + k4[i]);
    }
    vx_new = -current[2]*cosf(current[0]) - current[3] * cosf(current[1]);
    vy_new = -current[2]*sinf(current[0]) - current[3] * sinf(current[1]);

}


@interface FCViewController ()
@end

@implementation FCViewController
@synthesize prefButton = _prefButton;
@synthesize sharedManager = __sharedManager;

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIColor *highlightColor = [[UIColor greenColor] colorWithAlphaComponent:.6];
    [self setPrefButtonWithColor:[UIColor colorWithWhite:1. alpha:.5] forState:UIControlStateNormal];
    [self setPrefButtonWithColor:highlightColor forState:UIControlStateHighlighted];

    //[self setPrefButtonWithColor:highlightColor forState:UIControlStateSelected];
    self.prefButton.layer.cornerRadius = 10.;
    self.prefButton.layer.borderColor = highlightColor.CGColor;
    self.view.backgroundColor = [UIColor blackColor];

    current[0] = 0.;
    current[1] = 0.;
    current[2] = 0.;
    current[3] = 0.;
    
    _tailLayer = [CALayer layer];
    _tailLayer.bounds = CGRectMake(0., 0., 50., 2.);
    _tailLayer.anchorPoint = CGPointMake(0., .5);
    _tailLayer.backgroundColor = [[[UIColor redColor] colorWithAlphaComponent:.5] CGColor];
    
    _bar1 = [[FCBarLayer alloc] initWithLength:70. andWidth:20.];
    _bar1.position = CGPointMake(160., 240.);
    _bar1.backgroundColor = [[[UIColor greenColor] colorWithAlphaComponent:.2] CGColor];
    _bar1.borderColor = [[[UIColor greenColor] colorWithAlphaComponent:0.8] CGColor];
    _bar1.borderWidth = 2;
    
    _bar2 = [[FCBarLayer alloc] initWithLength:70. andWidth:20.];
    _bar2.position = _bar1.tailPosition;
    _bar2.backgroundColor = [[[UIColor greenColor] colorWithAlphaComponent:.2] CGColor];
    _bar2.borderColor = [[[UIColor greenColor] colorWithAlphaComponent:0.8] CGColor];
    _bar2.borderWidth = 2;
    
    [self.view.layer addSublayer:self.bar1];
    [self.view.layer addSublayer:self.bar2];
    [self.view.layer addSublayer:self.tailLayer];
    
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(animateLayers)];
    [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)viewDidUnload
{
    [self setPrefButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)animateLayers
{
    CMAccelerometerData *accData = self.sharedManager.accelerometerData; // need to check active in future
    float x_acc = accData.acceleration.x;
    float y_acc = accData.acceleration.y;
    float phi= atan2f(-x_acc, -y_acc);
    a_eff_new = ACC_COEF * sqrtf(x_acc*x_acc + y_acc*y_acc);

    runge_kutta_4(0.05,phi);
    
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    self.bar1.angle = current[0];
    self.bar2.position = self.bar1.tailPosition;
    self.bar2.angle = current[1];
    self.tailLayer.position = self.bar2.tailPosition;
    float angle = atan2f(vy_new, vx_new);
    [self.tailLayer setValue:[NSNumber numberWithFloat:angle+M_PI] forKeyPath:@"transform.rotation"];
    self.tailLayer.bounds = CGRectMake(0., 0., 20*sqrtf(vx_new*vx_new+vy_new*vy_new), 2.);
    [CATransaction commit];
    
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)setPrefButtonWithColor:(UIColor*)color forState:(UIControlState)state
{
    UIImage *gearImage = [UIImage imageNamed:@"gear.png"];
    CGRect rect = CGRectMake(0, 0, gearImage.size.width, gearImage.size.height);
    CGFloat scale = [[UIScreen mainScreen] scale];
    
    UIGraphicsBeginImageContextWithOptions(gearImage.size, NO, scale);
    CGContextRef context = UIGraphicsGetCurrentContext(); /* image context */
    [color setFill];
    CGContextClipToMask(context, rect, gearImage.CGImage);
    CGContextAddRect(context, rect);
    CGContextDrawPath(context, kCGPathFill);
    UIImage *coloredImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [self.prefButton setImage:coloredImg forState:state];
}


-(CMMotionManager*)sharedManager {
    if (__sharedManager==nil) {
        __sharedManager = [(FCAppDelegate*)UIApplication.sharedApplication.delegate sharedManager];
    }
    return __sharedManager;
}

- (IBAction)prefTouchDown:(id)sender {
    self.prefButton.layer.borderWidth = 3.;
}

- (IBAction)prefTouchUpInside:(id)sender {
    self.prefButton.layer.borderWidth = 0;
}

- (IBAction)prefTouchUpOutside:(id)sender {
    self.prefButton.layer.borderWidth = 0;

}

@end

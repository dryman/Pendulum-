//
//  FCViewController.m
//  Double Pendulum
//
//  Created by 陳仁乾 on 12/8/24.
//  Copyright (c) 2012年 Felix Chern. All rights reserved.
//

#import "FCViewController.h"
#import "FCAppDelegate.h"
#import "FCPendulum.h"
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
@property (nonatomic,strong) FCPendulum *pendulum_1;
@property (nonatomic,strong) FCPendulum *pendulum_2;
@property (nonatomic,strong) CADisplayLink *dl_1;
@property (nonatomic,strong) CADisplayLink *dl_2;
@end

@implementation FCViewController
@synthesize prefButton = _prefButton;
@synthesize sharedManager = __sharedManager;


- (void)viewDidLoad
{
    [super viewDidLoad];
    //self.navigationController.navigationBarHidden = YES;
    UIColor *highlightColor = [[UIColor greenColor] colorWithAlphaComponent:.6];
    [self setPrefButtonWithColor:[UIColor colorWithWhite:1. alpha:.5] forState:UIControlStateNormal];
    [self setPrefButtonWithColor:highlightColor forState:UIControlStateHighlighted];
    self.prefButton.layer.cornerRadius = 10.;
    self.prefButton.layer.borderColor = highlightColor.CGColor;
    self.view.backgroundColor = [UIColor blackColor];
    
    _pendulum_1 = [[FCPendulum alloc] init];
    _pendulum_2 = [[FCPendulum alloc] init];
    
    [_pendulum_1 setLength:70 andWidth:20];
    [_pendulum_2 setLength:70 andWidth:20];
    _pendulum_1.color = [UIColor greenColor];
    _pendulum_2.color = [UIColor yellowColor];
    
    _pendulum_1.damp_coef = 0.05;
    _pendulum_2.damp_coef = 0.05;
    
    [self.view.layer addSublayer:_pendulum_1.bar1];
    [self.view.layer addSublayer:_pendulum_1.bar2];
    [self.view.layer addSublayer:_pendulum_2.bar1];
    [self.view.layer addSublayer:_pendulum_2.bar2];
    
    _dl_1 = [CADisplayLink displayLinkWithTarget:_pendulum_1 selector:@selector(update)];
    _dl_2 = [CADisplayLink displayLinkWithTarget:_pendulum_2 selector:@selector(update)];
    [_dl_1 addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [_dl_2 addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];

}

- (void)viewDidUnload
{
    [self setPrefButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
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

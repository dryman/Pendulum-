//
//  FCPendulum.m
//  Double Pendulum
//
//  Created by dryman on 12/8/25.
//  Copyright (c) 2012年 Felix Chern. All rights reserved.
//

#import "FCPendulum.h"
#import "FCAppDelegate.h"
#include "odeFunction.h"

const float dt = 0.05;

@interface FCPendulum ()
@property (nonatomic,strong,readonly) CADisplayLink *displayLink;
@property (nonatomic,weak) CALayer *delegateLayer;
@property (nonatomic,assign) float *current;
@property (nonatomic,assign) float *k1;
@property (nonatomic,assign) float *k2;
@property (nonatomic,assign) float *k3;
@property (nonatomic,assign) float *k4;
@property (nonatomic,assign) float a_coef;
@property (nonatomic,assign) float a_eff_old;
@property (nonatomic,assign) float phi_old;
@property (nonatomic,assign) float vx;
@property (nonatomic,assign) float vy;
@end

@implementation FCPendulum
@synthesize sharedManager = __sharedManager;
@synthesize displayLink = _displayLink;

- (id) initWithDelegateLayer:(CALayer *)layer
{
    self = [super init];
    if (self) {
        _delegateLayer = layer;
        _a_coef = 2.;
        _bar1 = [[FCBarLayer alloc] init];
        _bar1.position = CGPointMake(160, 180);
        _bar2 = [[FCBarLayer alloc] init];
        _current = (float*) malloc(4*sizeof(float));
        for (int i=0; i<4; ++i) {
            _current[i]=0;
        }
        _k1 = (float*) malloc(4*sizeof(float));
        _k2 = (float*) malloc(4*sizeof(float));
        _k3 = (float*) malloc(4*sizeof(float));
        _k4 = (float*) malloc(4*sizeof(float));
    }
    return self;
}

-(void)dealloc
{
    _delegateLayer = nil;
    free(_current);
    free(_k1);
    free(_k2);
    free(_k3);
    free(_k4);
}

-(void)setLength:(CGFloat)length andWidth:(CGFloat)width
{
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    [_bar1 setLength:length andWidth:width];
    [_bar2 setLength:length andWidth:width];
    [CATransaction commit];
}

-(CGFloat)length
{
    return [_bar1 length];
}

-(CGFloat)width
{
    return [_bar1 width];
}

-(void)setColor:(UIColor *)color
{
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    CGColorRef backgroundColor = [color colorWithAlphaComponent:.2].CGColor;
    CGColorRef borderColor = [color colorWithAlphaComponent:.7].CGColor;
    _bar1.backgroundColor = backgroundColor;
    _bar2.backgroundColor = backgroundColor;
    _bar1.borderColor = borderColor;
    _bar2.borderColor = borderColor;
    [CATransaction commit];
}

-(UIColor*)color
{
    return [UIColor colorWithCGColor:_bar1.backgroundColor];
}

-(CMMotionManager*)sharedManager {
    if (__sharedManager==nil) {
        __sharedManager = [(FCAppDelegate*)UIApplication.sharedApplication.delegate sharedManager];
    }
    return __sharedManager;
}

- (CADisplayLink*)displayLink
{
    if (_displayLink==nil) {
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(update)];
        [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    }
    return _displayLink;
}

- (void)showPendulum
{
    [self.delegateLayer addSublayer:self.bar1];
    [self.delegateLayer addSublayer:self.bar2];
    self.displayLink.paused = NO;
}

- (void)hidePendulum
{
    [self.bar1 removeFromSuperlayer];
    [self.bar2 removeFromSuperlayer];
    self.displayLink.paused = YES;
}

-(void)update {
    float x_acc, y_acc, phi, a_eff;
    CMAccelerometerData *accData = self.sharedManager.accelerometerData;
    x_acc = accData.acceleration.x;
    y_acc = accData.acceleration.y;
    a_eff = _a_coef * sqrtf(x_acc*x_acc + y_acc*y_acc);
    phi = atan2f(-x_acc, -y_acc);
    
    
    /* runge kuta 4th order */
    odeFunction(_k1, _current, _current,   0., a_eff, phi, _damp_coef);
    odeFunction(_k2, _current,      _k1, dt/2, a_eff, phi, _damp_coef);
    odeFunction(_k3, _current,      _k2, dt/2, a_eff, phi, _damp_coef);
    odeFunction(_k4, _current,      _k3,   dt, a_eff, phi, _damp_coef);
    for (int i=0; i<4; ++i)
        _current[i] = _current[i] + dt*(_k1[i] + 2*_k2[i] +2*_k3[i] +_k4[i])/6.;
    
    _vx = -_current[2]*cosf(_current[0]) - _current[3]*cosf(_current[1]);
    _vy = -_current[2]*sinf(_current[0]) - _current[3]*sinf(_current[1]);
    
    _a_eff_old = a_eff;
    _phi_old = phi;
    
    // should set this in main queue?
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    self.bar1.angle = self.current[0];
    self.bar2.angle = self.current[1];
    self.bar2.position = self.bar1.tailPosition;
    [CATransaction commit];
}

@end

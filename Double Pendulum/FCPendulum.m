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
@property (nonatomic,strong,readonly) FCBarLayer *bar1;
@property (nonatomic,strong,readonly) FCBarLayer *bar2;
@property (nonatomic,strong) CAEmitterLayer *emitterLayer;
@property (nonatomic,strong) CAEmitterCell *emitterCell;
@property (nonatomic,strong,readonly) CADisplayLink *displayLink;
@property (nonatomic,weak) CALayer *delegateLayer;
@property (nonatomic,assign) float *current;
@property (nonatomic,assign) float *k1;
@property (nonatomic,assign) float *k2;
@property (nonatomic,assign) float *k3;
@property (nonatomic,assign) float *k4;
@property (nonatomic,assign) float vx;
@property (nonatomic,assign) float vy;
@end

@implementation FCPendulum
@synthesize sharedManager = __sharedManager;
@synthesize displayLink = _displayLink;
@synthesize visible = _visible;

- (id) initWithDelegateLayer:(CALayer *)layer
{
    self = [super init];
    if (self) {
        _delegateLayer = layer;
        _visible = NO;
        _bar1 = [[FCBarLayer alloc] init];
        _bar2 = [[FCBarLayer alloc] init];
        self.emitterLayer.emitterCells = @[self.emitterCell];
        
        /* hard coded, should become more flexible if I want to write iPad version */
        self.bar1.position = CGPointMake(160, 240);
        self.bar2.position = CGPointMake(160, 310);
        self.emitterLayer.emitterPosition = CGPointMake(160, 310);  /* avoid init ghost flash */

        /* c malloc */
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
    [_displayLink invalidate];
    free(_current);
    free(_k1);
    free(_k2);
    free(_k3);
    free(_k4);
}


-(void)update {
    float x_acc, y_acc, phi, a_eff;
    if (self.sharedManager.accelerometerActive) {
        CMAccelerometerData *accData = self.sharedManager.accelerometerData;
        x_acc = accData.acceleration.x;
        y_acc = accData.acceleration.y;
    } else {
        x_acc = 0;
        y_acc = 1.0;
    }
    
    a_eff = _accCoef * sqrtf(x_acc*x_acc + y_acc*y_acc);
    phi = atan2f(-x_acc, -y_acc);
    
    
    /* runge kuta 4th order */
    odeFunction(_k1, _current, _current,   0., a_eff, phi, _dampCoef);
    odeFunction(_k2, _current,      _k1, dt/2, a_eff, phi, _dampCoef);
    odeFunction(_k3, _current,      _k2, dt/2, a_eff, phi, _dampCoef);
    odeFunction(_k4, _current,      _k3,   dt, a_eff, phi, _dampCoef);
    for (int i=0; i<4; ++i)
        _current[i] = _current[i] + dt*(_k1[i] + 2*_k2[i] +2*_k3[i] +_k4[i])/6.;
    
    // Can be used for calculate tail velocities
    _vx = -_current[2]*cosf(_current[0]) - _current[3]*cosf(_current[1]);
    _vy = -_current[2]*sinf(_current[0]) - _current[3]*sinf(_current[1]);
    

    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    self.bar1.angle = self.current[0];
    self.bar2.angle = self.current[1];
    self.bar2.position = self.bar1.tailPosition;
    self.emitterLayer.emitterPosition = self.bar1.tailPosition;
    self.emitterCell.birthRate = floorf(fabsf(_current[2]-_current[3])*10);
    self.emitterCell.velocity = fabsf(self.bar1.length*_current[2]);
    [CATransaction commit];
}

-(void)setLength:(CGFloat)length andWidth:(CGFloat)width
{
    [self setAccCoef: length/40.];
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    [self.bar1 setLength:length andWidth:width];
    [self.bar2 setLength:length andWidth:width];
    [self.emitterLayer setEmitterSize: CGSizeMake(width, 0)];
    [CATransaction commit];
}

-(CGFloat)length
{
    return self.bar1.length;
}

-(CGFloat)width
{
    return self.bar1.width;
}

-(CAEmitterLayer*) emitterLayer
{
    if (_emitterLayer == nil) {
        _emitterLayer = [CAEmitterLayer layer];
        _emitterLayer.emitterShape = kCAEmitterLayerCircle;
        _emitterLayer.emitterMode = kCAEmitterLayerOutline;
        //_emitterLayer.renderMode = kCAEmitterLayerAdditive;
    }
    return _emitterLayer;
}

-(CAEmitterCell*) emitterCell
{
    if (_emitterCell == nil) {
        id img = (id) [[UIImage imageNamed:@"tspark.png"] CGImage];
        _emitterCell = [CAEmitterCell emitterCell];
        _emitterCell.contents = img;
        _emitterCell.emissionRange = M_PI_4/2;
        _emitterCell.scale = 0.5;
        _emitterCell.scaleRange = .2;
        _emitterCell.velocity = 0;
        _emitterCell.velocityRange = 50;
        _emitterCell.lifetime = 1;
        _emitterCell.alphaSpeed = -0.7;
        _emitterCell.scaleSpeed = -0.2;
        _emitterCell.duration = 1;
        _emitterCell.birthRate = 10;
    }
    return _emitterCell;
}

-(void)setColor:(UIColor *)color
{
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    CGColorRef backgroundColor = [color colorWithAlphaComponent:.2].CGColor;
    CGColorRef borderColor = [color colorWithAlphaComponent:.7].CGColor;
    self.bar1.backgroundColor = backgroundColor;
    self.bar2.backgroundColor = backgroundColor;
    self.bar1.borderColor = borderColor;
    self.bar2.borderColor = borderColor;
    
    CGFloat hue, saturation, brightness, alpha;
    [color getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
    self.emitterCell.color = [[UIColor colorWithHue:hue saturation:saturation-0.6 brightness:brightness alpha:alpha] CGColor];
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

- (void)setVisible:(BOOL)visible
{
    if (_visible ^ visible) {
        _visible = visible;
        if (visible) {
            [self.delegateLayer addSublayer:self.emitterLayer];
            [self.delegateLayer addSublayer:self.bar1];
            [self.delegateLayer addSublayer:self.bar2];
        } else {
            [self.emitterLayer removeFromSuperlayer];
            [self.bar1 removeFromSuperlayer];
            [self.bar2 removeFromSuperlayer];
        }
    }
}

- (BOOL)isVisible
{
    return _visible;
}

- (BOOL)isPaused
{
    return self.displayLink.paused;
}

- (void)setPaused:(BOOL)paused
{
    self.displayLink.paused = paused;
    /* 
     * not quite sure if below would trigger implicit animation...
     */
    if (paused) {
        CFTimeInterval pausedTime = [self.emitterLayer convertTime:CACurrentMediaTime() fromLayer:nil];
        self.emitterLayer.speed = 0.0;
        self.emitterLayer.timeOffset = pausedTime;
    } else {
        CFTimeInterval pausedTime = self.emitterLayer.timeOffset;
        CFTimeInterval timeSincePause = [self.emitterLayer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
        self.emitterLayer.speed = 1.0;
        self.emitterLayer.timeOffset = 0.0;
        self.emitterLayer.beginTime = 0.0;
        self.emitterLayer.beginTime = timeSincePause;
    }
}


@end

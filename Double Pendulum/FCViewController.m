//
//  FCViewController.m
//  Double Pendulum
//
//  Created by 陳仁乾 on 12/8/24.
//  Copyright (c) 2012年 Felix Chern. All rights reserved.
//

#import "FCViewController.h"

static CGFloat theta;


@interface FCViewController ()
@end

@implementation FCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _bar1 = [[FCBarLayer alloc] initWithLength:140. andWidth:20.];
    _bar1.position = CGPointMake(160., 80.);
    
    _bar1.backgroundColor = [[[UIColor redColor] colorWithAlphaComponent:0.02] CGColor];
    _bar1.borderColor = [[[UIColor redColor] colorWithAlphaComponent:0.3] CGColor];
    _bar1.borderWidth = 2;

    [self.view.layer addSublayer:self.bar1];
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

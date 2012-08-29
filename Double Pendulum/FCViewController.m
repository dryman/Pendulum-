//
//  FCViewController.m
//  Double Pendulum
//
//  Created by 陳仁乾 on 12/8/24.
//  Copyright (c) 2012年 Felix Chern. All rights reserved.
//

#import "FCViewController.h"
#import "FCPreferenceController.h"
#import "FCAppDelegate.h"
#import "FCPendulum.h"
#include "odeFunction.h"


#define ACC_COEF (2.)
#define DAMP_COEF (.01)


@interface FCViewController ()
@end

@implementation FCViewController
@synthesize prefButton = _prefButton;
@synthesize sharedManager = __sharedManager;


- (void)viewDidLoad
{
    [super viewDidLoad];

    _pendulums =@[
        [[FCPendulum alloc] initWithDelegateLayer:self.view.layer],
        [[FCPendulum alloc] initWithDelegateLayer:self.view.layer],
        [[FCPendulum alloc] initWithDelegateLayer:self.view.layer]];
    NSArray *colors = @[[UIColor cyanColor], [UIColor yellowColor], [UIColor greenColor]];
    
    [self.pendulums enumerateObjectsUsingBlock:^(FCPendulum* pendulum, NSUInteger idx, BOOL *stop) {
        [pendulum setLength:70 andWidth:20];
        [pendulum setDamp_coef:0.01];
        [pendulum setColor:[colors objectAtIndex:idx]];
    }];
    [[self.pendulums objectAtIndex:0] setVisible:YES];
    [[self.pendulums objectAtIndex:0] setPaused:NO];
    
    //self.navigationController.navigationBarHidden = YES;
    UIColor *highlightColor = [[UIColor greenColor] colorWithAlphaComponent:.6];
    [self setPrefButtonWithColor:[UIColor colorWithWhite:1. alpha:.5] forState:UIControlStateNormal];
    [self setPrefButtonWithColor:highlightColor forState:UIControlStateHighlighted];
    self.prefButton.layer.cornerRadius = 10.;
    self.prefButton.layer.borderColor = highlightColor.CGColor;
    self.view.backgroundColor = [UIColor blackColor];
    
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    FCPreferenceController* preferenceController = (FCPreferenceController*)segue.destinationViewController;
    preferenceController.delegateController = self;
    [self.pendulums enumerateObjectsUsingBlock:^(FCPendulum* pendulum, NSUInteger idx, BOOL *stop) {
        pendulum.paused = YES;
    }];
}

-(CMMotionManager*)sharedManager {
    if (__sharedManager==nil) {
        __sharedManager = [(FCAppDelegate*)UIApplication.sharedApplication.delegate sharedManager];
    }
    return __sharedManager;
}


@end

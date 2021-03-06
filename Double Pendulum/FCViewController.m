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
@property (nonatomic,strong) CAEmitterLayer *sparkle;
@end

@implementation FCViewController
@synthesize prefButton = _prefButton;
@synthesize sharedManager = __sharedManager;


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];

    _pendulums =@[
        [[FCPendulum alloc] initWithDelegateLayer:self.view.layer],
        [[FCPendulum alloc] initWithDelegateLayer:self.view.layer],
        [[FCPendulum alloc] initWithDelegateLayer:self.view.layer]];
    NSArray *colors = @[[UIColor cyanColor], [UIColor yellowColor], [UIColor greenColor]];
    
    [self.pendulums enumerateObjectsUsingBlock:^(FCPendulum* pendulum, NSUInteger idx, BOOL *stop) {
        [pendulum setLength:70 andWidth:20];
        [pendulum setDampCoef:0.05];
        [pendulum setColor:[colors objectAtIndex:idx]];
    }];
    [[self.pendulums objectAtIndex:2] setVisible:YES];
    [[self.pendulums objectAtIndex:2] setPaused:NO];
    
    
    UIImage *gear_normal = [UIImage imageNamed:@"gear_normal.png"];
    UIImage *gear_selected = [UIImage imageNamed:@"gear_highlighted.png"];
    [self.prefButton setImage:gear_normal forState:UIControlStateNormal];
    [self.prefButton setImage:gear_selected forState:UIControlStateHighlighted];
}

- (void)viewDidUnload
{
    [self setPrefButton:nil];
    [super viewDidUnload];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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

//
//  FCPreferenceController.m
//  Double Pendulum
//
//  Created by dryman on 12/8/26.
//  Copyright (c) 2012年 Felix Chern. All rights reserved.
//

#import "FCPreferenceController.h"
#import "FCViewController.h"
#import "FCPendulum.h"

@interface FCPreferenceController ()

@end

@implementation FCPreferenceController
@synthesize switchOne;
@synthesize switchTwo;
@synthesize switchThree;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.switchOne.on   = [[self.delegateController.pendulums objectAtIndex:2] isVisible];
    self.switchTwo.on   = [[self.delegateController.pendulums objectAtIndex:1] isVisible];
    self.switchThree.on = [[self.delegateController.pendulums objectAtIndex:0] isVisible];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.delegateController.pendulums enumerateObjectsUsingBlock:^(FCPendulum *pendulum, NSUInteger idx, BOOL *stop) {
        if (pendulum.isVisible) {
            pendulum.paused = NO;
        }
    }];
}

- (void)viewDidUnload
{
    [self setSwitchOne:nil];
    [self setSwitchTwo:nil];
    [self setSwitchThree:nil];
    [self setDelegateController:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)switchOneChanged:(id)sender
{
    [(FCPendulum*)[self.delegateController.pendulums objectAtIndex:2] setVisible:[sender isOn]];
}

- (IBAction)switchTwoChanged:(id)sender
{
    [(FCPendulum*)[self.delegateController.pendulums objectAtIndex:1] setVisible:[sender isOn]];
}

- (IBAction)switchThreeChanged:(id)sender
{
    [(FCPendulum*)[self.delegateController.pendulums objectAtIndex:0] setVisible:[sender isOn]];
}

@end

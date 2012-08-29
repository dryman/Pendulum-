//
//  FCPreferenceController.h
//  Double Pendulum
//
//  Created by dryman on 12/8/26.
//  Copyright (c) 2012年 Felix Chern. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FCViewController;

@interface FCPreferenceController : UIViewController
@property (nonatomic,weak) FCViewController *delegateController;
@property (weak, nonatomic) IBOutlet UISwitch *switchOne;
@property (weak, nonatomic) IBOutlet UISwitch *switchTwo;
@property (weak, nonatomic) IBOutlet UISwitch *switchThree;

- (IBAction)switchOneChanged:(id)sender;
- (IBAction)switchTwoChanged:(id)sender;
- (IBAction)switchThreeChanged:(id)sender;

@end

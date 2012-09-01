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
@property (weak, nonatomic) IBOutlet UISlider *lengthSlider;
@property (weak, nonatomic) IBOutlet UISlider *dampingSlider;

- (IBAction)switchOneChanged:(id)sender;
- (IBAction)switchTwoChanged:(id)sender;
- (IBAction)switchThreeChanged:(id)sender;
- (IBAction)lengthSliderMoved:(id)sender;
- (IBAction)dampingSliderMoved:(id)sender;

@end

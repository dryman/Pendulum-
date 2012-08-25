//
//  FCViewController.h
//  Double Pendulum
//
//  Created by 陳仁乾 on 12/8/24.
//  Copyright (c) 2012年 Felix Chern. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FCBarLayer.h"

@class CMMotionManager;

@interface FCViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *prefButton;
@property (nonatomic,strong) FCBarLayer *bar1;
@property (nonatomic,strong) FCBarLayer *bar2;
@property (nonatomic,strong) CALayer *tailLayer;
@property (nonatomic,strong) CADisplayLink *displayLink;
@property (nonatomic,strong,readonly) CMMotionManager *sharedManager;

- (IBAction)prefTouchDown:(id)sender;
- (IBAction)prefTouchUpInside:(id)sender;
- (IBAction)prefTouchUpOutside:(id)sender;


-(void)animateLayers;
-(void)setPrefButtonWithColor:(UIColor*)color forState:(UIControlState)state;
@end

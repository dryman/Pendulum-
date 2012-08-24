//
//  FCViewController.h
//  Double Pendulum
//
//  Created by 陳仁乾 on 12/8/24.
//  Copyright (c) 2012年 Felix Chern. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FCBarLayer.h"

@interface FCViewController : UIViewController
@property (nonatomic,strong) FCBarLayer *bar1;
@property (nonatomic,strong) CALayer *layer;
@property (nonatomic,strong) CADisplayLink *displayLink;
@property (nonatomic,assign) CGFloat theta;

-(void)moveLayer;
@end
//
//  FCPendulum.h
//  Double Pendulum
//
//  Created by dryman on 12/8/25.
//  Copyright (c) 2012年 Felix Chern. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FCBarLayer.h"

@class CMMotionManager;

@interface FCPendulum : NSObject
@property (nonatomic,strong,readonly) CMMotionManager *sharedManager;
@property (nonatomic,assign,readonly) CGFloat length;
@property (nonatomic,assign,readonly) CGFloat width;
@property (nonatomic,assign,getter = isVisible) BOOL visible;
@property (nonatomic,assign,getter = isPaused) BOOL paused;
@property (nonatomic,assign) float dampCoef;
@property (nonatomic,assign) float accCoef;
@property (nonatomic,copy) UIColor *color;

- (id) initWithDelegateLayer:(CALayer*) layer;
- (void) update;
- (void) setLength:(CGFloat)length andWidth:(CGFloat)width;

@end

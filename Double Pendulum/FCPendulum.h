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
@property (nonatomic,strong,readonly) FCBarLayer *bar1;
@property (nonatomic,strong,readonly) FCBarLayer *bar2;
@property (nonatomic,assign,readonly) CGFloat length;
@property (nonatomic,assign,readonly) CGFloat width;
@property (nonatomic,assign,getter = isVisible) BOOL visible;
@property (nonatomic,assign,getter = isPaused) BOOL paused;
@property (nonatomic,assign) float damp_coef;
@property (nonatomic,copy) UIColor *color;

- (id) initWithDelegateLayer:(CALayer*) layer;
- (void) showPendulum;
- (void) hidePendulum;
- (void) update;
- (void) setLength:(CGFloat)length andWidth:(CGFloat)width;

@end

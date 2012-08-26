//
//  FCBarLayer.h
//  Double Pendulum
//
//  Created by 陳仁乾 on 12/8/24.
//  Copyright (c) 2012年 Felix Chern. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface FCBarLayer : CALayer
@property (nonatomic,assign,readonly)  CGFloat length;
@property (nonatomic,assign,readonly)  CGFloat width;
@property (nonatomic,assign,readwrite) CGFloat angle;
@property (nonatomic,assign,readonly)  CGPoint tailPosition;

-(void) setLength:(CGFloat)length andWidth:(CGFloat)width;
-(FCBarLayer*) initWithLength:(CGFloat)length andWidth:(CGFloat)width;

@end

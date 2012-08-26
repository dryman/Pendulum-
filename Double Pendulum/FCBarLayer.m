//
//  FCBarLayer.m
//  Double Pendulum
//
//  Created by 陳仁乾 on 12/8/24.
//  Copyright (c) 2012年 Felix Chern. All rights reserved.
//

#import "FCBarLayer.h"

@implementation FCBarLayer

-(FCBarLayer*) initWithLength:(CGFloat)length andWidth:(CGFloat)width
{
    self = [super init];
    if (self) {
        _width = width;
        _length = length;
        self.bounds = CGRectMake(0., 0., width, _length+_width);
        self.anchorPoint = CGPointMake(.5, _width/2./(_width+_length));
        self.cornerRadius = _width/2.;
    }
    return self;
}
-(void) setLength:(CGFloat)length andWidth:(CGFloat)width {
    _length = length;
    _width = width;
    self.bounds = CGRectMake(0., 0., width, _length+_width);
    self.anchorPoint = CGPointMake(.5, _width/2./(_width+_length));
    self.cornerRadius = _width/2.;
    self.borderWidth = 2;
}

-(CGFloat) angle
{
    CATransform3D transform = self.transform;
    return (CGFloat)atan2(transform.m12, transform.m11);
}
-(void) setAngle:(CGFloat)angle
{
    [self setValue:[NSNumber numberWithFloat:angle] forKeyPath:@"transform.rotation"];
}
-(CGPoint) tailPosition
{
    CGFloat x = self.position.x;
    CGFloat y = self.position.y;
    x -= self.length * sinf(self.angle);
    y += self.length * cosf(self.angle);
    return CGPointMake(x, y);
}

@end

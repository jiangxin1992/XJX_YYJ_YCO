//
//  UIView+Draw.m
//  HHAlertView
//
//  Created by ChenHao on 6/17/15.
//  Copyright (c) 2015 AEXAIR. All rights reserved.
//

#import "UIView+Draw.h"

@implementation UIView (Draw)

- (void)hh_drawCheckmark:(NSInteger)viewSize
{
    [self cleanLayer:self];
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(viewSize/2, viewSize/2) radius:viewSize/2 startAngle:0 endAngle:M_PI*2 clockwise:YES];
    
    path.lineCapStyle = kCGLineCapRound;
    path.lineJoinStyle = kCGLineCapRound;
    
    [path moveToPoint:CGPointMake(viewSize/4, viewSize/2)];
    CGPoint p1 = CGPointMake(viewSize/2, viewSize/4*3);
    [path addLineToPoint:p1];
    
    CGPoint p2 = CGPointMake(viewSize/4*3, viewSize/4);
    [path addLineToPoint:p2];
    
    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    layer.fillColor = [UIColor clearColor].CGColor;
    
    layer.strokeColor = [UIColor whiteColor].CGColor;
    layer.lineWidth = 2;
    layer.path = path.CGPath;
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:NSStringFromSelector(@selector(strokeEnd))];
    animation.fromValue = @0;
    animation.toValue = @1;
    animation.duration = 0.5;
    [layer addAnimation:animation forKey:NSStringFromSelector(@selector(strokeEnd))];

    [self.layer addSublayer:layer];
    
}

- (void)hh_drawCheckWarning:(NSInteger)viewSize
{
    [self cleanLayer:self];
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(viewSize/2, viewSize/2) radius:viewSize/2 startAngle:0 endAngle:M_PI*2 clockwise:YES];
    path.lineCapStyle = kCGLineCapRound;
    path.lineJoinStyle = kCGLineCapRound;
    
    [path moveToPoint:CGPointMake(viewSize/2, viewSize/6)];
    CGPoint p1 = CGPointMake(viewSize/2, viewSize/6*3.8);
    [path addLineToPoint:p1];
    
    [path moveToPoint:CGPointMake(viewSize/2, viewSize/6*4.5)];
    [path addArcWithCenter:CGPointMake(viewSize/2, viewSize/6*4.5) radius:2 startAngle:0 endAngle:M_PI*2 clockwise:YES];
    
    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    layer.fillColor = [UIColor clearColor].CGColor;
    layer.strokeColor = [UIColor whiteColor].CGColor;
    layer.lineWidth = 2;
    layer.path = path.CGPath;
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:NSStringFromSelector(@selector(strokeEnd))];
    animation.fromValue = @0;
    animation.toValue = @1;
    animation.duration = 0.5;
    [layer addAnimation:animation forKey:NSStringFromSelector(@selector(strokeEnd))];

    [self.layer addSublayer:layer];
    
}

- (void)hh_drawCheckError:(NSInteger)viewSize
{
    [self cleanLayer:self];
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(viewSize/2, viewSize/2) radius:viewSize/2 startAngle:0 endAngle:M_PI*2 clockwise:YES];
    
    CGPoint p1 =  CGPointMake(viewSize/4, viewSize/4);
    [path moveToPoint:p1];
    
    CGPoint p2 =  CGPointMake(viewSize/4*3, viewSize/4*3);
    [path addLineToPoint:p2];
    
    CGPoint p3 =  CGPointMake(viewSize/4*3, viewSize/4);
    [path moveToPoint:p3];
    
    CGPoint p4 =  CGPointMake(viewSize/4, viewSize/4*3);
    [path addLineToPoint:p4];
    
    
    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    layer.lineWidth = 2;
    layer.path = path.CGPath;
    layer.fillColor = [UIColor clearColor].CGColor;
    layer.strokeColor = [UIColor whiteColor].CGColor;
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:NSStringFromSelector(@selector(strokeEnd))];
    animation.fromValue = @0;
    animation.toValue = @1;
    animation.duration = 0.5;
    [layer addAnimation:animation forKey:NSStringFromSelector(@selector(strokeEnd))];

    [self.layer addSublayer:layer];
}

- (void)hh_drawCustomeView:(UIView *)customView
{
    [self cleanLayer:self];
    customView.frame = self.frame;
    [self addSubview:customView];
}

- (void)cleanLayer:(UIView *)view
{
    for (CALayer *layer in view.layer.sublayers) {
        [layer removeFromSuperlayer];
    }
}

@end

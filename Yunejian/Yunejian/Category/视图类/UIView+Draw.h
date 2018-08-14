//
//  UIView+Draw.h
//  HHAlertView
//
//  Created by ChenHao on 6/17/15.
//  Copyright (c) 2015 AEXAIR. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "HHAlertViewConst.h"

@interface UIView (Draw)

- (void)hh_drawCheckmark:(NSInteger)viewSize;

- (void)hh_drawCheckError:(NSInteger)viewSize;

- (void)hh_drawCheckWarning:(NSInteger)viewSize;

- (void)hh_drawCustomeView:(UIView *)customView;

@end

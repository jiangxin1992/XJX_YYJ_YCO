//
//  YYDiscountView.h
//  Yunejian
//
//  Created by yyj on 15/8/7.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YYDiscountView : UIView

@property(nonatomic,assign) BOOL showDiscountValue;
@property(nonatomic,assign) BOOL notShowDiscountValueTextAlignmentLeft;
@property(nonatomic,assign) NSString *fontColorStr;

@property(nonatomic,assign) BOOL bgColorIsBlack;

- (void)updateUIWithOriginPrice:(NSString *)originPrice fianlPrice:(NSString *)finalPrice originFont:(UIFont *)originFont finalFont:(UIFont *)finalFont;
- (void)updateUIWithOriginPrice:(NSString *)originPrice fianlPrice:(NSString *)finalPrice originFont:(UIFont *)originFont finalFont:(UIFont *)finalFont isColorSelect:(BOOL )isColorSelect;
- (void)updateUIWithTaxPrice:(NSString *)originPrice taxPrice:(NSString *)taxPrice originFont:(UIFont *)originFont taxFont:(UIFont *)taxFont;
@end

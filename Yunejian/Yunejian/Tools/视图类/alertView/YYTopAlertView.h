//
//  YYTopAlertView.h
//  Yunejian
//
//  Created by Apple on 16/1/29.
//  Copyright © 2016年 yyj. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum : NSUInteger {
    YYTopAlertTypeInfo,
    YYTopAlertTypeSuccess,
    YYTopAlertTypeWarning,
    YYTopAlertTypeError
} YYTopAlertType;
@interface YYTopAlertView : UIView
@property(nonatomic, assign)BOOL autoHide;
@property(nonatomic, assign)NSInteger duration;
//@property(nonatomic, retain)UIView *parentView;

/*
 * btn target
 */
@property (nonatomic, copy) dispatch_block_t doBlock;

/*
 * action after dismiss
 */
@property (nonatomic, copy) dispatch_block_t dismissBlock;

+ (BOOL)hasViewWithParentView:(UIView*)parentView;
+ (void)hideViewWithParentView:(UIView*)parentView;
+ (YYTopAlertView*)viewWithParentView:(UIView*)parentView;

+ (YYTopAlertView*)showWithType:(YYTopAlertType)type text:(NSString*)text parentView:(UIView*)parentView;
+ (YYTopAlertView*)showWithType:(YYTopAlertType)type text:(NSString*)text doText:(NSString*)doText doBlock:(dispatch_block_t)doBlock parentView:(UIView*)parentView;

@end

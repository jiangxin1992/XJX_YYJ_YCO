//
//  regular.h
//  yunejianDesigner
//
//  Created by yyj on 2017/2/21.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface regular : NSObject

/** 图片压缩到指定大小*/
+ (NSData*)getImageForSize:(CGFloat)size WithImage:(UIImage *)image;

/**
 * 键盘消失
 */
+(void)dismissKeyborad;

/**
 * 获取自定义下拉弹框
 */
+(UIAlertController *)getAlertWithFirstActionTitle:(NSString *)firstTitle FirstActionBlock:(void (^)())firstActionBlock SecondActionTwoTitle:(NSString *)secondTitle SecondActionBlock:(void (^)())secondActionBlock;

/**
 * 获取时间戳对应的nsdate
 */
+(NSDate*)zoneChange:(long)time;

/**
 * 时间戳转时间
 */
+(NSString *)getTimeStr:(long)time WithFormatter:(NSString *)_formatter;

/**
 * 获取时间戳
 */
+(long )getTimeWithTimeStr:(NSString *)time WithFormatter:(NSString *)_formatter;

/**
 * 获取当前时间戳
 */
+(long)date;

@end

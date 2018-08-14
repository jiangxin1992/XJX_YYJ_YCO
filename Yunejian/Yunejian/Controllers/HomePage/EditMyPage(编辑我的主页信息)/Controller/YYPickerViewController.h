//
//  YYPickerViewController.h
//  parking
//
//  Created by chjsun on 2017/2/10.
//  Copyright © 2017年 chjsun. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YYPickerViewController;
@protocol YYPickerDelegate <NSObject>

@optional
- (void)YYPickerController:(YYPickerViewController *)controller index:(NSInteger)index content:(NSString *)content;

@end

@interface YYPickerViewController : UIViewController
/** 代理 */
@property(nonatomic, assign) id<YYPickerDelegate> delegate;

/** 初始时间 */
@property(nonatomic, copy) NSArray *data;

@end

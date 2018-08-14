//
//  YYPhoneTableViewCell.h
//  Yunejian
//
//  Created by chuanjun sun on 2017/8/21.
//  Copyright © 2017年 yyj. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^changePhone)(NSString *content);

typedef void (^changePhonePower)(NSInteger index);

@interface YYPhoneTableViewCell : UITableViewCell
/** 手机号 */
@property (nonatomic, copy) NSString *phone;

/** 带picker的数据 */
@property (nonatomic, copy) NSArray *phonePickerData;

/** 改变内容的回调block */
@property (nonatomic, copy) changePhone phoneContent;

// 改变查看权限
@property (nonatomic, copy) changePhonePower phonePowerContent;

/** 标题 */
@property (nonatomic, copy) NSString *title;
/** 副标题 */
@property (nonatomic, copy) NSString *subtitle;


/** 隐藏picker */
- (void)hiddenPicker;
@end

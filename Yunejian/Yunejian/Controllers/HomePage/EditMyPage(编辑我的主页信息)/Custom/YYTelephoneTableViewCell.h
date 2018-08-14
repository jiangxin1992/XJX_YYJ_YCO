//
//  YYTelephoneTableViewCell.h
//  Yunejian
//
//  Created by chuanjun sun on 2017/8/23.
//  Copyright © 2017年 yyj. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^changeTelephone)(NSString *content);

typedef void (^changeTelephonePower)(NSInteger index);

@interface YYTelephoneTableViewCell : UITableViewCell

/** 固定电话 */
@property (nonatomic, copy) NSString *telePhone;
/** 带picker的数据 */
@property (nonatomic, copy) NSArray *telePhonePickerData;

/** 改变内容的回调block */
@property (nonatomic, copy) changeTelephone telephoneContent;

// 改变查看权限
@property (nonatomic, copy) changeTelephonePower telephonePowerContent;

@end

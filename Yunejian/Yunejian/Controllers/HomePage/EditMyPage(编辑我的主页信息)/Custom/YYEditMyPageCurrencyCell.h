//
//  YYEditMyPageTableViewCell.h
//  Yunejian
//
//  Created by chuanjun sun on 2017/8/18.
//  Copyright © 2017年 yyj. All rights reserved.
//
// 没有标题的时候 高度  return 66;
// 有标题的时候 高度   return 92;

#import <UIKit/UIKit.h>
@class YYEditMyPageCurrencyCell;

typedef NS_ENUM(NSInteger, checkType) {
    /** 检查email */
    kYYCheckTypeWithEmail,
    /** 不检查 */
    kYYCheckTypeWithNo,
};

typedef void (^changeTextField)(NSString *content, NSIndexPath *indexPath, YYEditMyPageCurrencyCell *cell);

typedef void (^changePicker)(NSInteger index, NSIndexPath *indexPath);

@interface YYEditMyPageCurrencyCell : UITableViewCell
/** 标题 */
@property (nonatomic, copy) NSString *title;
/** 副标题 */
@property (nonatomic, copy) NSString *subTitle;
/** content 提示 */
@property (nonatomic, copy) NSString *inputPlaceholder;
/** content 内容 */
@property (nonatomic, copy) NSString *inputContent;
/** 带picker的数据 */
@property (nonatomic, copy) NSArray *pickerData;
/** 是否显示picker */
@property (nonatomic, assign) BOOL isShowPicker;
/** 检查类型 */
@property (nonatomic, assign) checkType checkType;
/** 设置输入显示方式是否是明文 */
@property (nonatomic, assign) BOOL isSecureTextEntry;

/** textview修改回调 */
@property (nonatomic, copy) changeTextField transmitTextField;
/** picker修改的回调 */
@property (nonatomic, copy) changePicker transmitPicker;
/** 标记 */
@property (nonatomic, strong) NSIndexPath *indexPath;

/** 显示提示 */
@property (nonatomic, copy) NSString *warnContent;


@end


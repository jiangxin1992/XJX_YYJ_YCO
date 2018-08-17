//
//  YYOrderModifyViewController.h
//  Yunejian
//
//  Created by yyj on 15/8/18.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YYOrderInfoModel;

typedef void (^CloseButtonClicked)();

@interface YYOrderModifyViewController : UIViewController

@property (assign, nonatomic) BOOL isCreatOrder;//
@property (assign, nonatomic) BOOL isReBuildOrder;//区分创建订单类型中的（rebuild）
@property (assign, nonatomic) BOOL isAppendOrder;//isCreatOrder no  时候起作用

@property (strong, nonatomic) YYOrderInfoModel *currentYYOrderInfoModel;

@property (strong, nonatomic) CloseButtonClicked closeButtonClicked;
@property (strong, nonatomic) ModifySuccess modifySuccess;

@end

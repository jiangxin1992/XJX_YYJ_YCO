//
//  YYOrderModifyViewController.h
//  Yunejian
//
//  Created by yyj on 15/8/18.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YYBuyerModel,YYOrderInfoModel,YYPageInfoModel;

typedef void (^CloseButtonClicked)();

@interface YYOrderModifyViewController : UIViewController

@property (assign, nonatomic) BOOL isCreatOrder;//
@property (assign, nonatomic) BOOL isReBuildOrder;//区分创建订单类型中的（rebuild）
@property (assign, nonatomic) BOOL isAppendOrder;//isCreatOrder no  时候起作用

@property (strong, nonatomic) YYOrderInfoModel *currentYYOrderInfoModel;

@property (nonatomic, strong) YYPageInfoModel *currentPageInfo;
@property (strong, nonatomic) YYBuyerModel *buyerModel;//买手店地址
@property (strong, nonatomic) YYOrderBuyerAddress *nowBuyerAddress;//新增地址
@property (strong, nonatomic) NSString *uploadImgPathType;//该功能对应的 qiniu上传图片路径
@property (strong, nonatomic) NSString *chooseImgKey;//当前已选的名片图片在qiniu中对应的key

@property (strong, nonatomic) CloseButtonClicked closeButtonClicked;
@property (strong, nonatomic) ModifySuccess modifySuccess;

@end

//
//  YYCreateOrModifyAddressViewController.h
//  Yunejian
//
//  Created by yyj on 15/7/20.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YYAddress,YYOrderInfoModel;

typedef NS_ENUM(NSInteger, OperationType) {
    OperationTypeCreate     = 80000,
    OperationTypeModify     = 80001,
    OperationTypeHelpCreate = 80002
};

typedef void (^AddressForBuyerButtonClicked)(YYAddress *address);

@interface YYCreateOrModifyAddressViewController : UIViewController

@property (nonatomic, assign) OperationType currentOperationType;
@property (nonatomic, strong) YYOrderInfoModel *currentYYOrderInfoModel;//给订单添加地址时用，如果是离线创建，根据临时订单号先保存地址
@property (nonatomic, strong) YYAddress *address;

@property (nonatomic, strong) ModifySuccess modifySuccess;
@property (nonatomic, strong) CancelButtonClicked cancelButtonClicked;
@property (nonatomic, strong) AddressForBuyerButtonClicked addressForBuyerButtonClicked;

@end

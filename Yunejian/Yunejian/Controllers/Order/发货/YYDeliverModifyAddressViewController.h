//
//  YYDeliverModifyAddressViewController.h
//  Yunejian
//
//  Created by yyj on 15/7/20.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YYDeliverModel;

@interface YYDeliverModifyAddressViewController : UIViewController

@property (nonatomic, strong) YYDeliverModel *deliverModel;

@property (nonatomic, strong) ModifySuccess modifySuccess;
@property (nonatomic, strong) CancelButtonClicked cancelButtonClicked;

@end

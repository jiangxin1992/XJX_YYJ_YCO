//
//  YYDeliveringDoneConfirmViewController.h
//  Yunejian
//
//  Created by yyj on 2018/8/7.
//  Copyright © 2018年 yyj. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YYOrderInfoModel,YYStylesAndTotalPriceModel;

@interface YYDeliveringDoneConfirmViewController : UIViewController

@property (nonatomic, strong) YYOrderInfoModel *currentYYOrderInfoModel;
@property (nonatomic, strong) YYStylesAndTotalPriceModel *stylesAndTotalPriceModel;//原总数
@property (nonatomic, strong) YYStylesAndTotalPriceModel *nowStylesAndTotalPriceModel;//现总数

@property (nonatomic, strong) CancelButtonClicked cancelButtonClicked;

@property (nonatomic, strong) ModifySuccess modifySuccess;

-(void)updateUI;

@end

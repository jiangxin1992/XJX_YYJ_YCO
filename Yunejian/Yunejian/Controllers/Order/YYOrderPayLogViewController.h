//
//  YYOrderPayLogViewController.h
//  YunejianBuyer
//
//  Created by Apple on 16/7/20.
//  Copyright © 2016年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYOrderInfoModel.h"
@interface YYOrderPayLogViewController : UIViewController
@property (nonatomic, strong) YYOrderInfoModel *currentYYOrderInfoModel;
@property (nonatomic, strong) CancelButtonClicked cancelButtonClicked;
@property (nonatomic, assign) Boolean addEnable;
@end

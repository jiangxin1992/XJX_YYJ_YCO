//
//  YYOrderDetailViewController.h
//  Yunejian
//
//  Created by yyj on 15/8/6.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YYOrderInfoModel;

@interface YYOrderDetailViewController : UIViewController

@property(nonatomic,strong) CancelButtonClicked cancelButtonClicked;

@property(nonatomic,strong) NSString *currentOrderCode;

@property(nonatomic,strong) NSString *currentOrderLogo;

@property(nonatomic,assign) NSInteger currentOrderConnStatus;

@property(nonatomic,strong) YYOrderInfoModel *localOrderInfoModel;

@property(nonatomic,strong) NSString *previousTitle;

-(void)jumpOrderDetailHandler;

@end

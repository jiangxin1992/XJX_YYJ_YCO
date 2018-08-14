//
//  YYLogisticsDetailViewController.h
//  Yunejian
//
//  Created by yyj on 2018/8/9.
//  Copyright © 2018年 yyj. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YYPackingListDetailModel;

@interface YYLogisticsDetailViewController : UIViewController

@property (nonatomic, strong) CancelButtonClicked cancelButtonClicked;

@property (nonatomic, strong) YYPackingListDetailModel *packingListDetailModel;

@end

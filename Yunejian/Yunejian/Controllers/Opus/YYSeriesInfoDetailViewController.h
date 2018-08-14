//
//  YYSeriesInfoDetailViewController.h
//  Yunejian
//
//  Created by Apple on 16/7/25.
//  Copyright © 2016年 yyj. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YYSeriesInfoDetailModel;

@interface YYSeriesInfoDetailViewController : UIViewController

@property(nonatomic,strong) YYSeriesInfoDetailModel *seriesInfoDetailModel;

@property(nonatomic,strong)CancelButtonClicked cancelButtonClicked;

@end

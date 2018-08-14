//
//  YYStyleDetailListViewController.h
//  Yunejian
//
//  Created by yyj on 15/7/26.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YYOpusSeriesModel,Series,YYOrderInfoModel;

@interface YYStyleDetailListViewController : UIViewController

@property (nonatomic, strong) YYOpusSeriesModel *opusSeriesModel;
@property (nonatomic, strong) Series *series;

@property (nonatomic, assign) long seriesId;//系列ID
@property (nonatomic, assign) NSInteger designerId;//设计师ID
@property (nonatomic, assign) NSComparisonResult orderDueCompareResult;

//修改订单部分
@property (nonatomic, assign) BOOL isModifyOrder;
@property (nonatomic, strong) YYOrderInfoModel *currentYYOrderInfoModel;

@end

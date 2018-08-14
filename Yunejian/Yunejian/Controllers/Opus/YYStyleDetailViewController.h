//
//  YYStyleDetailViewController.h
//  Yunejian
//
//  Created by yyj on 15/7/24.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYOpusSeriesModel.h"
#import "Series.h"

@interface YYStyleDetailViewController : UIViewController

@property (nonatomic,assign) NSInteger currentIndex;
@property (nonatomic,strong) NSMutableArray *onlineOrOfflineOpusStyleArray;

@property (nonatomic,strong) NSMutableArray *cachedOpusStyleArray;
@property(nonatomic,strong)YYOpusSeriesModel *opusSeriesModel;
@property(nonatomic,strong)Series *series;
@property (nonatomic,assign) NSInteger selectTaxType;


@property (nonatomic,assign) EDataReadType currentDataReadType;
@property (nonatomic,assign) NSInteger totalPages; //总页码

@property (nonatomic , assign) BOOL isModityCart;
@property (nonatomic,assign) BOOL finigerTouched;
@property (nonatomic,assign) BOOL isShowroomToScan;
@property (nonatomic,assign) BOOL isToScan;

@end

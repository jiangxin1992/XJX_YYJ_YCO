//
//  YYDetailContentViewController.h
//  Yunejian
//
//  Created by yyj on 15/7/26.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYOpusStyleModel.h"
#import "StyleSummary.h"
@class YYOpusSeriesModel;
@class YYStyleDetailViewController;

@interface YYDetailContentViewController : UIViewController
@property(nonatomic,assign)NSInteger selectTaxType;

@property(nonatomic,strong)YYOpusStyleModel *currentOpusStyleModel;
@property(nonatomic,strong)YYOpusSeriesModel *opusSeriesModel;

@property(nonatomic,assign) EDataReadType currentDataReadType;

@property(nonatomic,strong)StyleSummary *currentStyleSummary;
@property(nonatomic,strong)Series *series;

@property (nonatomic, weak) YYStyleDetailViewController *styleDetailViewController;

@property (nonatomic,assign) BOOL isToScan;

- (void)updateUIAtColorIndex:(NSInteger)colorIndex;
-(void)laodData;
@end

//
//  YYStyleDetailCell.h
//  Yunejian
//
//  Created by yyj on 15/8/6.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YYOrderStyleModel,YYOrderOneInfoModel;

typedef void (^SelectCellButtonClicked)(BOOL isSelectedNow,YYOrderStyleModel *orderStyleModel);
typedef void (^DiscountStyleButtonClicked)(YYOrderStyleModel *orderStyleModel,long seriesId);
typedef void (^DeleteStyleButtonClicked)(YYOrderStyleModel *orderStyleModel,long seriesId);

typedef void (^CoverButtonClicked)(YYOrderOneInfoModel *orderOneInfoModel,YYOrderStyleModel *orderStyleModel);

@interface YYStyleDetailCell : UITableViewCell

@property (nonatomic, strong) YYOrderStyleModel *orderStyleModel;
@property (nonatomic, strong) YYOrderOneInfoModel *orderOneInfoModel;

@property (nonatomic, assign) long seriesId;

@property (nonatomic, assign) BOOL showTotal;

@property (nonatomic, assign) BOOL showHaveNotAchieveOrderAmountMin;

@property (nonatomic, assign) BOOL  checkButtonIsChecked;

@property (nonatomic, assign) BOOL isModifyNow;//当前是否是修改状态
@property (nonatomic, assign) BOOL isCreatOrder;//
@property (nonatomic, assign) BOOL isShowCheckNow;//当前是否是显示删除 check
@property (nonatomic, assign) BOOL isAppendOrder;
@property (nonatomic, assign) BOOL showRemarkButton;

@property (nonatomic, assign) BOOL clickCoverShowDetail;//点击封面进入详情是否开启
@property (nonatomic, assign) NSInteger selectTaxType;

@property (nonatomic, strong) NSMutableArray *menuData;

@property (nonatomic, strong) SelectCellButtonClicked selectCellButtonClicked;
@property (nonatomic, strong) DiscountStyleButtonClicked discountStyleButtonClicked;
@property (nonatomic, strong) DeleteStyleButtonClicked deleteStyleButtonClicked;
@property (nonatomic, strong) CoverButtonClicked coverButtonClicked;

- (void)updateUI;

- (void)setBottomView:(BOOL)hidden;

- (void)setIsStyleModifyView:(BOOL)isStyleModify;

@end

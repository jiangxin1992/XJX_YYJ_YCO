//
//  YYOrderRemarkCell.h
//  Yunejian
//
//  Created by yyj on 15/8/20.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYOrderInfoModel.h"
@class YYStylesAndTotalPriceModel;
#define kOrderRemarkText NSLocalizedString(@"订单备注",nil)

typedef void (^TextViewIsEditCallback)(BOOL isEdit);
typedef void (^BuyerButtonClicked)(UIView *view);
typedef void (^OrderSituationButtonClicked)(UIView *view);
typedef void (^DiscountButtonClicked)();
typedef void (^TaxTypeButtonClicked)(NSInteger type);


@interface YYOrderRemarkCell : UITableViewCell

@property (strong, nonatomic)TextViewIsEditCallback textViewIsEditCallback;

@property (strong, nonatomic)BuyerButtonClicked buyerButtonClicked;
@property (strong, nonatomic)OrderSituationButtonClicked orderSituationButtonClicked;
@property (strong, nonatomic)DiscountButtonClicked discountButtonClicked;
@property (strong, nonatomic)TaxTypeButtonClicked taxTypeButtonClicked;

@property (strong, nonatomic)YYStylesAndTotalPriceModel *stylesAndTotalPriceModel;
@property (strong, nonatomic) YYOrderInfoModel *currentYYOrderInfoModel;
@property (assign, nonatomic) NSInteger selectTaxType;
@property (assign, nonatomic) BOOL isCreatOrder;
@property (assign, nonatomic) BOOL isAppendOrder;
@property (weak, nonatomic) UIViewController *parentController;
- (void)updateUI;
@property (strong,nonatomic) NSMutableArray *menuData;

@property(nonatomic,copy) void (^taxChooseBlock)();
-(void)btnClick:(NSInteger)row section:(NSInteger)section andParmas:(NSArray *)parmas;

@end

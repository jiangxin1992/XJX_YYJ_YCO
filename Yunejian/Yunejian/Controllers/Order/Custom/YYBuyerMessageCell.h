//
//  YYBuyerMessageCell.h
//  Yunejian
//
//  Created by yyj on 15/8/21.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YYOrderInfoModel,YYBuyerModel;

typedef void (^OrderDeliverMethodButtonClicked)(UIView *view);
typedef void (^AccountsMethodButtonClicked)(UIView *view);
typedef void (^OrderCreateBuyerAddressButtonClicked)();
typedef void (^OrderCreateBuyerMessageButtonClicked)(UIView *view);
typedef void (^OrderDeleteBuyerAddressButtonClicked)();
typedef void (^OrderCreateBuyerNameButtonClicked)();

@interface YYBuyerMessageCell : UITableViewCell

@property (nonatomic, strong) OrderCreateBuyerAddressButtonClicked orderCreateBuyerAddressButtonClicked;
@property (nonatomic, strong) OrderCreateBuyerMessageButtonClicked orderCreateBuyerMessageButtonClicked;
@property (nonatomic, strong) OrderDeleteBuyerAddressButtonClicked orderDeleteBuyerAddressButtonClicked;
@property (nonatomic, strong) OrderCreateBuyerNameButtonClicked orderCreateBuyerNameButtonClicked;
@property (nonatomic, strong) AccountsMethodButtonClicked accountsMethodButtonClicked;

@property (nonatomic, strong) OrderDeliverMethodButtonClicked orderDeliverMethodButtonClicked;
@property (nonatomic, strong) YYOrderInfoModel *currentYYOrderInfoModel;
@property (nonatomic, strong) YYBuyerModel *buyerModel;//买手店地址

- (void)updateUI;

@end

//
//  YYBuyerInfoCell.h
//  Yunejian
//
//  Created by lixuezhi on 15/8/17.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YYOrderInfoModel;

typedef void (^ShareOrderButtonClicked)();
typedef void (^BuyerCardButtonClicked)(UIImage *image);
typedef void (^ReConnStatusButtonClicked)(NSArray *info);
typedef void (^BuyerInfoButtonClicked)();

@interface YYBuyerInfoCell1 : UITableViewCell

@property (nonatomic, assign) BOOL isCancel;
@property (nonatomic, copy) YYOrderInfoModel *currentYYOrderInfoModel;

@property (nonatomic, strong) ShareOrderButtonClicked shareOrderButtonClicked;
@property (nonatomic, strong) BuyerCardButtonClicked buyerCardButtonClicked;
@property (nonatomic, strong) ReConnStatusButtonClicked  reConnStatusButtonClicked;
@property (nonatomic, strong) BuyerInfoButtonClicked  buyerInfoButtonClicked;

@property(nonatomic,assign) NSInteger currentOrderConnStatus;
@property (weak, nonatomic) UIViewController *parentController;

- (void)updataUI;

+(NSInteger) getCellHeight:(NSString *)desc;

@end

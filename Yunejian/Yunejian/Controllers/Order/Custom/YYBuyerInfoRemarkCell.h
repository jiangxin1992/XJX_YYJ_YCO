//
//  YYBuyerInfoRemarkCell.h
//  Yunejian
//
//  Created by Apple on 15/10/26.
//  Copyright © 2015年 yyj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYOrderInfoModel.h"

@class YYStylesAndTotalPriceModel;
@interface YYBuyerInfoRemarkCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UITextView *txtView;
@property (weak, nonatomic) IBOutlet UIView *taxInfoContainerView;
@property (strong, nonatomic)YYStylesAndTotalPriceModel *stylesAndTotalPriceModel;
@property (strong, nonatomic) YYOrderInfoModel *currentYYOrderInfoModel;
@property (weak, nonatomic) UIViewController *parentController;
-(void)updateUI:(NSString*)info;
@property (strong,nonatomic) NSMutableArray *menuData;

@end

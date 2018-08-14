//
//  YYSelectPayMethodTableViewController.h
//  Yunejian
//
//  Created by yyj on 15/8/21.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YYOrderSettingInfoModel;

@interface YYSelectPayMethodTableViewController : UITableViewController

@property (nonatomic, strong) NSString *currentPayMethod;

@property (nonatomic, strong) YYOrderSettingInfoModel *currentOrderSettingInfoModel;

@property (nonatomic, strong) SelectedValue selectedValue;

@end

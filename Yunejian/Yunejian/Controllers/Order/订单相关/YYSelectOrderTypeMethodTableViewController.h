//
//  YYSelectOrderTypeMethodTableViewController.h
//  Yunejian
//
//  Created by yyj on 2018/8/2.
//  Copyright © 2018年 yyj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YYSelectOrderTypeMethodTableViewController : UITableViewController

@property (nonatomic, strong) NSString *currentMethod;

@property (nonatomic, strong) NSArray *orderTypeArray;

@property (nonatomic, strong) SelectedValue selectedValue;

@end

//
//  YYSelectRoleViewController.h
//  Yunejian
//
//  Created by yyj on 15/7/12.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, RoleButtonType) {
    RoleButtonTypeDesigner = 60000,
    RoleButtonTypeCancel = 60002
};

typedef void (^RoleButtonClicked)(RoleButtonType buttonType);

@interface YYSelectRoleViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *roleButton;

@property(nonatomic,strong) RoleButtonClicked roleButtonClicked;

@end

//
//  YYForgetPasswordViewController.h
//  Yunejian
//
//  Created by Apple on 16/10/14.
//  Copyright © 2016年 yyj. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface YYForgetPasswordViewController : UIViewController
@property(nonatomic,strong) CancelButtonClicked cancelButtonClicked;
@property(nonatomic,assign) NSInteger viewType;//1 输入邮箱 2 查收邮件
@property(nonatomic,strong) NSString *userEmail;
@end

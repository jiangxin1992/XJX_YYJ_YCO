//
//  YYShareSeriesView.h
//  Yunejian
//
//  Created by yyj on 2017/4/17.
//  Copyright © 2017年 yyj. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "YYUserHomePageModel.h"


@interface YYShareSeriesView : UIView

@property (nonatomic,strong) YYUserHomePageModel *homePageModel;
@property (nonatomic,strong) UITextField *emailTextField;
@property (nonatomic,strong) UIButton *emailTipButton;

/** 编辑*/
@property (nonatomic,copy) void (^blockEdit)();

/** 隐藏 */
@property (nonatomic,copy) void (^blockHide)();

/** 发送 */
@property (nonatomic,copy) void (^blockSend)();

@end

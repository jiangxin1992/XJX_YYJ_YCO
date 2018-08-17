//
//  YYLeftMenuViewController.h
//  Yunejian
//
//  Created by yyj on 15/7/8.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, LeftMenuButtonIndex) {
    /** 首页 */
    LeftMenuButtonTypeIndex_0 = 50000,
    /** 作品 */
    LeftMenuButtonTypeIndex_1 = 50001,
    /** 订单 */
    LeftMenuButtonTypeIndex_2 = 50002,
    /** 我的 */
    LeftMenuButtonTypeIndex_3 = 50003,
    /** 设置 */
    LeftMenuButtonTypeIndex_5 = 50005
};

typedef void (^LeftMenuButtonClicked)(LeftMenuButtonIndex buttonIndex);

@interface YYLeftMenuViewController : UIViewController

@property (nonatomic, strong) LeftMenuButtonClicked leftMenuButtonClicked;
@property (nonatomic,strong) CancelButtonClicked cancelButtonClicked;

- (void)setButtonSelectedByButtonIndex:(LeftMenuButtonIndex)leftMenuButtonIndex;

@end

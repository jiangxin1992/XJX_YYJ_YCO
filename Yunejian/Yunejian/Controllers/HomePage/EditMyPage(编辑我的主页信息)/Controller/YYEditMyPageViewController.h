//
//  YYEditMyPageViewController.h
//  Yunejian
//
//  Created by chuanjun sun on 2017/8/17.
//  Copyright © 2017年 yyj. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YYUserHomePageModel;

@interface YYEditMyPageViewController : UIViewController

//品牌更新
@property (nonatomic, strong) YYUserHomePageModel *homePageMode;

/** 保存成功 */
@property (nonatomic,copy) void (^blockSaveSuccess)(NSArray *contactArr);

@end

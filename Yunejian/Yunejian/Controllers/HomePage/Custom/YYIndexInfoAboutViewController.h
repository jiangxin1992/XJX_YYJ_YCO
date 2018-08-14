//
//  YYIndexInfoAboutViewController.h
//  Yunejian
//
//  Created by yyj on 2016/12/29.
//  Copyright © 2016年 yyj. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YYUserHomePageModel;

@interface YYIndexInfoAboutViewController : UIViewController

-(instancetype)initWithHomePageModel:(YYUserHomePageModel *)homePageModel WithBlock:(void(^)(NSString *type,UIView *obj))block;

@property (nonatomic,strong)YYUserHomePageModel *homePageModel;

@property(nonatomic,copy) void (^block)(NSString *type,UIView *obj);

-(void)SetData;//更新

@end

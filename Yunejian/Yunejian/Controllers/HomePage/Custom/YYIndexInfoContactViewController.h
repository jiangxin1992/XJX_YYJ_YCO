//
//  YYIndexInfoContactViewController.h
//  Yunejian
//
//  Created by yyj on 2016/12/29.
//  Copyright © 2016年 yyj. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YYUserHomePageModel,YYTypeButton;

@interface YYIndexInfoContactViewController : UIViewController

-(instancetype)initWithHomePageModel:(YYUserHomePageModel *)homePageModel WithBlock:(void(^)(NSString *type ,YYTypeButton *typeButton))block;

@property (nonatomic,strong)YYUserHomePageModel *homePageModel;

@property(nonatomic,copy) void (^block)(NSString *type ,YYTypeButton *typeButton);

-(void)SetData;//更新

@end

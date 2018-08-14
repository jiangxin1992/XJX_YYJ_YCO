//
//  YYConnBuyerInfoAboutViewController.h
//  Yunejian
//
//  Created by yyj on 2017/1/3.
//  Copyright © 2017年 yyj. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YYBuyerDetailModel;

@interface YYConnBuyerInfoAboutViewController : UIViewController

-(instancetype)initWithBuyerDetailModel:(YYBuyerDetailModel *)buyerDetailModel WithBlock:(void(^)(NSString *type,UIView *obj))block;

@property (nonatomic,strong)YYBuyerDetailModel *buyerDetailModel;

@property(nonatomic,copy) void (^block)(NSString *type,UIView *obj);

-(void)SetData;//更新

@end

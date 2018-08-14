//
//  YYConnBuyerInfoContactViewController.h
//  Yunejian
//
//  Created by yyj on 2017/1/3.
//  Copyright © 2017年 yyj. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YYBuyerDetailModel,YYTypeButton;

@interface YYConnBuyerInfoContactViewController : UIViewController

-(instancetype)initWithBuyerDetailModel:(YYBuyerDetailModel *)buyerDetailModel WithBlock:(void(^)(NSString *type ,YYTypeButton *typeButton))block;

@property (nonatomic,strong)YYBuyerDetailModel *buyerDetailModel;

@property(nonatomic,copy) void (^block)(NSString *type ,YYTypeButton *typeButton);

-(void)SetData;//更新

@end

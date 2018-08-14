//
//  YYChooseLogisticsView.h
//  Yunejian
//
//  Created by yyj on 2018/7/31.
//  Copyright © 2018年 yyj. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YYExpressCompanyModel;

@interface YYChooseLogisticsView : UIView

-(instancetype)initWithExpressCompanyArray:(NSArray *)expressCompanyArray WithBlock:(void (^)(YYExpressCompanyModel *expressCompanyModel))block;

@end

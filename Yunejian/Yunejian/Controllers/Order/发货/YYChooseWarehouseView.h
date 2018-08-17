//
//  YYChooseWarehouseView.h
//  Yunejian
//
//  Created by yyj on 2018/7/31.
//  Copyright © 2018年 yyj. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YYWarehouseModel;

@interface YYChooseWarehouseView : UIView

-(instancetype)initWithWarehouseArray:(NSArray *)warehouseArray WithBlock:(void (^)(YYWarehouseModel *warehouseModel))block;

@end

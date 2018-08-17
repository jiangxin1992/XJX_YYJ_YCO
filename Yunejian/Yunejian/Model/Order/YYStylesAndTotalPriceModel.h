//
//  YYStylesAndTotalPriceModel.h
//  Yunejian
//
//  Created by yyj on 15/8/18.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YYStylesAndTotalPriceModel : NSObject

@property (nonatomic,assign) int totalStyles;//共几款
@property (nonatomic,assign) int totalCount;//共多少件
@property (nonatomic,strong) NSDecimalNumber *originalTotalPrice;//每款打完折后算出的总价
@property (nonatomic,strong) NSDecimalNumber *finalTotalPrice;//每款打完折后算出的总价
@end

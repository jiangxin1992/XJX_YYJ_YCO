//
//  YYOrderStyleModel.m
//  Yunejian
//
//  Created by yyj on 15/8/6.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import "YYOrderStyleModel.h"

@implementation YYOrderStyleModel

- (NSInteger)getUnitsCount{
    if(self){
        NSInteger unitsCount = 0;
        if(self.colors && self.colors.count > 0){
            for (YYOrderOneColorModel *oneColorModel in self.colors) {
                if(oneColorModel.sizes && oneColorModel.sizes.count > 0){
                    for (YYOrderSizeModel *sizeModel in oneColorModel.sizes) {
                        if ([sizeModel.amount integerValue] >= 0) {
                            unitsCount += [sizeModel.amount integerValue];
                        }
                    }
                }
            }
        }
        return unitsCount;
    }
    return 0;
}

- (CGFloat)getTotalOriginalPrice {
    float costMeoney = 0;
    for (YYOrderOneColorModel *orderOneColorModel in self.colors) {
        NSInteger amount = [orderOneColorModel getTotalOriginalPrice];
        costMeoney += [orderOneColorModel.originalPrice floatValue] * amount;
    }
    return costMeoney;
}

@end

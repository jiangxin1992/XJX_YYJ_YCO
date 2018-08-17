//
//  YYSeriesInfoDetailModel.m
//  Yunejian
//
//  Created by Apple on 15/12/3.
//  Copyright © 2015年 yyj. All rights reserved.
//

#import "YYSeriesInfoDetailModel.h"

#import "YYOpusSeriesModel.h"
#import "YYSeriesInfoModel.h"

@implementation YYSeriesInfoDetailModel

- (YYOpusSeriesModel *)toOpusSeriesModel{
    YYOpusSeriesModel *opusSeriesModel = nil;
    if(self){
        opusSeriesModel = [[YYOpusSeriesModel alloc] init];
        opusSeriesModel.id = self.series.id;
        opusSeriesModel.name = self.series.name;
        opusSeriesModel.designerId = self.series.designerId;
        opusSeriesModel.orderAmountMin = self.series.orderAmountMin;
        opusSeriesModel.orderAmountMin = self.series.supplyStatus;
    }
    return opusSeriesModel;
}

@end



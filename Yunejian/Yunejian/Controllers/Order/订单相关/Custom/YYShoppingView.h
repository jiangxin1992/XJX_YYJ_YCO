//
//  YYShoppingView.h
//  Yunejian
//
//  Created by yyj on 2017/7/25.
//  Copyright © 2017年 yyj. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YYStyleInfoModel,YYOpusSeriesModel,YYOrderInfoModel,YYOpusStyleModel,YYBrandSeriesToCartTempModel;

@interface YYShoppingView : UIView

-(instancetype)initWithStyleInfoModel:(YYStyleInfoModel *)styleInfoModel WithOpusSeriesModel:(YYOpusSeriesModel *)opusSeriesModel WithOpusStyleModel:(YYOpusStyleModel *)opusStyleModel WithIsModifyOrder:(BOOL )isModifyOrder WithCurrentYYOrderInfoModel:(YYOrderInfoModel *)currentYYOrderInfoModel fromBrandSeriesView:(BOOL )isFromSeries WithBlock:(void (^)(YYBrandSeriesToCartTempModel *brandSeriesToCardTempModel))block;

@end

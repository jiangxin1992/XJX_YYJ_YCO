//
//  YYStyleInfoModel.h
//  Yunejian
//
//  Created by yyj on 15/7/28.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import "JSONModel.h"

#import "YYSizeModel.h"
#import "YYColorModel.h"
#import "YYStyleInfoDetailModel.h"
#import "YYDateRangeModel.h"

@class YYInventoryBoardModel;

@interface YYStyleInfoModel : JSONModel

@property (strong, nonatomic) NSArray<Optional,YYSizeModel, ConvertOnDemand>*size;
@property (strong, nonatomic) YYStyleInfoDetailModel <Optional>*style;
@property (strong, nonatomic) NSArray<Optional,YYColorModel, ConvertOnDemand>*colorImages;
@property (strong, nonatomic) YYDateRangeModel <Optional>*dateRange;
@property (nonatomic, strong) NSNumber <Optional>*stockEnabled;

- (NSString *)getSizeDes;
- (CGFloat)getMinTradePrice;
- (CGFloat)getMaxTradePrice;
/**
 模型转换

 @return ...
 */
-(YYInventoryBoardModel *)transformToInventoryBoardModel;

@end

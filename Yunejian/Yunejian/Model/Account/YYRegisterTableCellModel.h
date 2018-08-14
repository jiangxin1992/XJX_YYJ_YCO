//
//  YYRegisterTableCellModel.h
//  Yunejian
//
//  Created by Apple on 15/9/24.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSInteger, RegisterTableCellType) {
    RegisterTableCellTypeHead = 1,
    RegisterTableCellTypeInput = 2,
    RegisterTableCellTypeSaleInfo = 3,
    RegisterTableCellTypeCanal = 4,
    RegisterTableCellTypeSubmit = 5,
    RegisterTableCellTypeArea = 6,
    RegisterTableCellTypeBrandRegisterType = 7,
    RegisterTableCellTypeBrandRegisterUpload = 8,
    RegisterTableCellTypeBuyerRegisterUpload = 9,
    RegisterTableCellTypeBuyerPriceRang = 10,
    RegisterTableCellTypeConnBrand = 11,
    RegisterTableCellTypeBuyerPhotos = 12,
    RegisterTableCellTypeIntroduce = 13,
    RegisterTableCellTypeTitle = 14,
    RegisterTableCellTypeEmailVerify = 15,
    RegisterTableCellTypeSaleInfoSimple = 16,
    RegisterTableCellTypeSocialInfos = 17,
    RegisterTableCellTypeSinglePhotos = 18,
    RegisterTableCellTypeContactInfos=19//商务联系方式
    
};
@interface YYRegisterTableCellModel : NSObject
@property  NSInteger type;
@property (nonatomic,strong) NSArray *info;
-(id)initWithParameters:(NSArray *)parameters;

@end

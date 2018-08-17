//
//  YYBuyerDetailModel.h
//  Yunejian
//
//  Created by Apple on 15/12/11.
//  Copyright © 2015年 yyj. All rights reserved.
//

#import "JSONModel.h"

@interface YYBuyerDetailModel : JSONModel

@property (strong, nonatomic) NSString <Optional>* logoPath;
@property (strong, nonatomic) NSNumber <Optional>* priceMin;
@property (strong, nonatomic) NSArray<Optional, ConvertOnDemand>* userSocialInfos;
@property (strong, nonatomic) NSNumber <Optional>* priceMax;
@property (strong, nonatomic) NSNumber <Optional>* connectStatus;
@property (strong, nonatomic) NSArray<Optional, ConvertOnDemand>* userContactInfos;
@property (strong, nonatomic) NSString <Optional>* town;
@property (strong, nonatomic) NSString <Optional>* street;
@property (strong, nonatomic) NSNumber <Optional>* buyerId;
@property (strong, nonatomic) NSArray<Optional, ConvertOnDemand>* copBrands;
@property (strong, nonatomic) NSString <Optional>* introduction;//":
@property (strong, nonatomic) NSString <Optional>* name;//": "草鱼",
@property (strong, nonatomic) NSString <Optional>* addressDetail;//": "草鱼",
@property (strong, nonatomic) NSArray<Optional, ConvertOnDemand>* storeImgs;
@property (strong, nonatomic) NSNumber <Optional>* percent;
@property (strong, nonatomic) NSString <Optional>* webUrl;//": "",

@property (strong, nonatomic) NSString <Optional>*nation;
@property (strong, nonatomic) NSString <Optional>*province;//省
@property (strong, nonatomic) NSString <Optional>*city;//城市

@property (strong, nonatomic) NSString <Optional>*nationEn;
@property (strong, nonatomic) NSString <Optional>*provinceEn;
@property (strong, nonatomic) NSString <Optional>*cityEn;

@property (strong, nonatomic) NSNumber <Optional>*nationId;
@property (strong, nonatomic) NSNumber <Optional>*provinceId;
@property (strong, nonatomic) NSNumber <Optional>*cityId;

@end

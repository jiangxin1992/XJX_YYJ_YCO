//
//  UserDefaultsMacro.h
//  Yunejian
//
//  Created by yyj on 15/7/7.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#ifndef Yunejian_UserDefaultsMacro_h
#define Yunejian_UserDefaultsMacro_h

#define KUserIsBrand YES

#define kUserLoginTokenKey @"kUserLoginTokenKey"
#define kScrtKey @"kScrtKey"  //客户端参数加密用的key

#define kTempUserLoginTokenKey @"kTempUserLoginTokenKey"
#define kTempBrandID @"kTempBrandID"

#define kUserInfoKey @"kUserInfoKey"
#define KUserCartKey @"cartModel"
#define KUserCartMoneyTypeKey @"cartMoneyType"

#define KHomePageLookBookKey @"homepageLookBookKey"
#define KHomePageLookBookPicUrlsKey @"homepageLookBookPicUrlsKey"
#define KHomePageBrandIntroductionKey @"homepageLookBookKey"


//离线下单时，保存地址的后缀，前缀是临时订单号
#define kOfflineOrderAddressSuffix @"_offlineOrderAddress"

//离线下单时，保存名片图片的后缀，前缀是临时订单号
#define kOfflineCardSuffix @"_offlineCard"

//离线下单时，保存离线订单的字典的KEY
#define kOfflineOrderDictionaryKey @"kOfflineOrderDictionaryKey"

#define kNoLongerRemindNewFuntion @"kNoLongerRemindNewFuntion1"

#endif

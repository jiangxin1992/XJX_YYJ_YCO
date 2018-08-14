//
//  YYOpusApi.m
//  Yunejian
//
//  Created by yyj on 15/7/23.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import "YYOpusApi.h"

// c文件 —> 系统文件（c文件在前）

// 控制器

// 自定义视图

// 接口

// 分类

// 自定义类和三方类（ cocoapods类 > model > 工具类 > 其他）
#import "RequestMacro.h"
#import "YYRequestHelp.h"
#import "YYHttpHeaderManager.h"

#import "YYUser.h"
#import "YYStyleInfoModel.h"
#import "YYUserHomePageModel.h"
#import "YYOpusStyleListModel.h"
#import "YYOpusSeriesListModel.h"
#import "YYSeriesInfoDetailModel.h"
#import "YYOpusSeriesAuthTypeBuyerListModel.h"

@implementation YYOpusApi
/**
 *
 * 判断是否存在多币种
 *
 */
+ (void)hasMultiCurrencyWithSeriesId:(NSInteger)seriesId andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,BOOL hasMultiCurrency,NSError *error))block{
    // get URL
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kStyleHasMultiCurrency];
    
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kStyleHasMultiCurrency params:nil];
    NSString *string = [[NSString alloc] initWithFormat:@"seriesId=%ld",seriesId];
    
    NSData *body = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    [YYRequestHelp executeRequest:YES headers:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error
            && responseObject) {
            BOOL _hasMultiCurrency = [responseObject boolValue];
            block(rspStatusAndMessage,_hasMultiCurrency,error);
            
        }else{
            block(rspStatusAndMessage,nil,error);
        }
        
    }];
}
/**
 *
 * 分享系列
 *
 */
+ (void)sendlineSheetWithHomePageModel:(YYUserHomePageModel *)homePageMode withSeriesId:(NSInteger)seriesId withEmail:(NSString *)email andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,NSError *error))block{
    // get URL
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kSeriesLineSheet];
    
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kSeriesLineSheet params:nil];

    NSMutableArray *tempArr = [[NSMutableArray alloc] init];
    [tempArr addObject:[[NSString alloc] initWithFormat:@"email=%@",email]];
    [tempArr addObject:[[NSString alloc] initWithFormat:@"seriesId=%ld",seriesId]];

    //0 邮箱, 4 固定电话 1 电话, 3 微信号, 2 QQ,
    //    NSInteger idx=contactType==0?0:contactType==1?2:contactType==2?3:contactType==3?4:contactType==4?2:-1;
    if(homePageMode.userContactInfos){
        if(homePageMode.userContactInfos.count){
            for (int i=0; i<homePageMode.userContactInfos.count; i++) {
                NSDictionary *obj = [homePageMode.userContactInfos objectAtIndex:i];
                if(![YYOpusApi isNilOrEmptyWithContactValue:[obj objectForKey:@"contactValue"] WithContactType:[obj objectForKey:@"contactType"]]){
                    NSInteger number = [[obj objectForKey:@"contactType"] integerValue];
                    NSString *valueStr = [obj objectForKey:@"contactValue"];
                    if(number==0){
//                        brandEmail = valueStr;
                        [tempArr addObject:[[NSString alloc] initWithFormat:@"brandEmail=%@",valueStr]];
                    }else if(number==1){
//                        phone = valueStr;
                        [tempArr addObject:[[NSString alloc] initWithFormat:@"phone=%@",valueStr]];
                    }else if(number==2){
//                        qq = valueStr;
                        [tempArr addObject:[[NSString alloc] initWithFormat:@"qq=%@",valueStr]];
                    }else if(number==3){
//                        weChat = valueStr;
                        [tempArr addObject:[[NSString alloc] initWithFormat:@"weChat=%@",valueStr]];
                    }else if(number==4){
//                        tel = valueStr;
                        [tempArr addObject:[[NSString alloc] initWithFormat:@"tel=%@",valueStr]];
                    }
                }
            }
        }
    }
    
    
    NSString *string = [tempArr componentsJoinedByString:@"&"];
    
    NSData *body = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    [YYRequestHelp executeRequest:YES headers:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error
            && responseObject) {
            block(rspStatusAndMessage,error);
            
        }else{
            block(rspStatusAndMessage,error);
        }
        
    }];
}
+(BOOL)isNilOrEmptyWithContactValue:(NSString *)contactValue WithContactType:(NSNumber *)contactType
{
    if([NSString isNilOrEmpty:contactValue])
    {
        return YES;
    }else
    {
        if([contactType integerValue] == 1)
        {
            //移动电话
            NSArray *teleArr = [contactValue componentsSeparatedByString:@" "];
            if(teleArr.count>1)
            {
                if(![NSString isNilOrEmpty:teleArr[1]])
                {
                    return NO;
                }else
                {
                    return YES;
                }
            }
            return YES;
        }else if([contactType integerValue] == 4)
        {
            //固定电话
            NSArray *tempphoneArr = [contactValue componentsSeparatedByString:@" "];
            if(tempphoneArr.count>1)
            {
                if(![NSString isNilOrEmpty:tempphoneArr[1]])
                {
                    NSArray *phoneArr = [tempphoneArr[1] componentsSeparatedByString:@"-"];
                    NSString *vauleStr = [phoneArr componentsJoinedByString:@""];
                    if(![NSString isNilOrEmpty:vauleStr])
                    {
                        return NO;
                    }
                    return YES;
                }else
                {
                    return YES;
                }
            }
            return YES;
        }
        return NO;
    }
}
/**
 *
 * 获取设计师系列列表
 *
 */
+ (void)getSeriesListWithId:(int)designerId pageIndex:(int)pageIndex pageSize:(int)pageSize  withDraft:(NSString*)draft andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYOpusSeriesListModel *opusSeriesListModel,NSError *error))block{
    // get URL
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kSeriesList_yco];
    
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kSeriesList_yco params:nil];
    NSString *string = [NSString stringWithFormat:kSeriesListParams_yco,designerId,pageIndex,pageSize,draft];
    
    
    NSData *body = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    [YYRequestHelp executeRequest:YES headers:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error
            && responseObject) {
            YYOpusSeriesListModel *opusSeriesListModel = [[YYOpusSeriesListModel alloc] initWithDictionary:responseObject error:nil];
            for (int i=0; i<opusSeriesListModel.result.count; i++) {
                YYOpusSeriesModel *seresModel = [opusSeriesListModel.result objectAtIndex:i];
                seresModel.brandID = [YYUser getBrandID];
            }
            block(rspStatusAndMessage,opusSeriesListModel,error);
            
        }else{
            block(rspStatusAndMessage,nil,error);
        }
        
    }];
}

/**
 *
 * 获取设计师系列中款式列表
 *
 */
+ (void)getStyleListWithDesignerId:(NSInteger )designerId seriesId:(NSInteger )seriesId orderBy:(NSString *)orderBy queryStr:(NSString *)queryStr pageIndex:(NSInteger )pageIndex pageSize:(NSInteger )pageSize andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYOpusStyleListModel *opusStyleListModel,NSError *error))block{
    // get URL
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kStyleList_yco];
    
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kStyleList_yco params:nil];
    
    NSString *string = [NSString stringWithFormat:@"designerId=%i",designerId];
    
    if (seriesId > 0) {
        string = [string stringByAppendingString:@"&seriesId="];
        string = [string stringByAppendingString:[NSString stringWithFormat:@"%li",seriesId]];
    }
    
    if (orderBy
        && [orderBy length] > 0) {
        string = [string stringByAppendingString:@"&orderBy="];
        string = [string stringByAppendingString:orderBy];
    }
    
    if(![queryStr isEqualToString:@""]){
        string = [string stringByAppendingString:[NSString stringWithFormat:@"&queryStr=%@&pageIndex=%i&pageSize=%i",queryStr,pageIndex,pageSize]];
    }else{
        string = [string stringByAppendingString:[NSString stringWithFormat:@"&pageIndex=%i&pageSize=%i",pageIndex,pageSize]];
    }
    
    NSData *body = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    [YYRequestHelp executeRequest:YES headers:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error
            && responseObject) {
            YYOpusStyleListModel *opusStyleListModel = [[YYOpusStyleListModel alloc] initWithDictionary:responseObject error:nil];
            block(rspStatusAndMessage,opusStyleListModel,error);
            
        }else{
            block(rspStatusAndMessage,nil,error);
        }
        
    }];
}

/**
 *
 * 获取款式详情
 *
 */
+ (void)getStyleInfoByStyleId:(long)styleId orderCode:(NSString*)orderCode andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYStyleInfoModel *styleInfoModel,NSError *error))block{
    // get URL
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kStyleInfo];
    
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kStyleInfo params:nil];
    
    NSString *string = @"";
    YYUser *user = [YYUser currentUser];
    if(user.userType == YYUserTypeRetailer){
        string = [NSString stringWithFormat:@"styleId=%li&orderCode=%@",styleId,orderCode];
    }else{
        string = [NSString stringWithFormat:@"styleId=%li",styleId];
    }
    
    NSData *body = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    [YYRequestHelp executeRequest:YES headers:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error
            && responseObject) {
            YYStyleInfoModel *styleInfoModel = [[YYStyleInfoModel alloc] initWithDictionary:responseObject error:nil];
            styleInfoModel.style.styleDescription = [responseObject valueForKeyPath:@"style.description"];//[[responseObject objectForKey:@"style"] objectForKey:@"description"];
            block(rspStatusAndMessage,styleInfoModel,error);
            
        }else{
            block(rspStatusAndMessage,nil,error);
        }
        
    }];
}

/**
 *
 * 获取设计师系列列表
 *
 */
+ (void)getSeriesListWithOrderCode:(NSString*)orderCode pageIndex:(int)pageIndex pageSize:(int)pageSize andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYOpusSeriesListModel *opusSeriesListModel,NSError *error))block{
    // get URL
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kBuyerAvailableSeries];
    
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kBuyerAvailableSeries params:nil];
    NSString *string = [NSString stringWithFormat:@"orderCode=%@&pageIndex=%i&pageSize=%i&withDraft=false",orderCode,pageIndex,pageSize];
    
    
    NSData *body = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    [YYRequestHelp executeRequest:YES headers:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error
            && responseObject) {
            YYOpusSeriesListModel *opusSeriesListModel = [[YYOpusSeriesListModel alloc] initWithDictionary:responseObject error:nil];
            block(rspStatusAndMessage,opusSeriesListModel,error);
            
        }else{
            block(rspStatusAndMessage,nil,error);
        }
        
    }];
}

/**
 *
 * 买手修改订单可用的款式
 *
 */
+ (void)getStyleListWithOrderCode:(NSString*)orderCode seriesId:(long)seriesId orderBy:(NSString *)orderBy queryStr:(NSString *)queryStr pageIndex:(int)pageIndex pageSize:(int)pageSize andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYOpusStyleListModel *opusStyleListModel,NSError *error))block{
    // get URL
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kBuyerAvailableStyles];
    
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kBuyerAvailableStyles params:nil];
    
    NSString *string = [NSString stringWithFormat:@"orderCode=%@",orderCode];
    
    if (seriesId > 0) {
        string = [string stringByAppendingString:@"&seriesId="];
        string = [string stringByAppendingString:[NSString stringWithFormat:@"%li",seriesId]];
    }
    
    if (orderBy
        && [orderBy length] > 0) {
        string = [string stringByAppendingString:@"&orderBy="];
        string = [string stringByAppendingString:orderBy];
    }
    
    if(![queryStr isEqualToString:@""]){
        string = [string stringByAppendingString:[NSString stringWithFormat:@"&queryStr=%@&pageIndex=%i&pageSize=%i",queryStr,pageIndex,pageSize]];
    }else{
        string = [string stringByAppendingString:[NSString stringWithFormat:@"&pageIndex=%i&pageSize=%i",pageIndex,pageSize]];
    }
    
    NSData *body = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    [YYRequestHelp executeRequest:YES headers:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error
            && responseObject) {
            YYOpusStyleListModel *opusStyleListModel = [[YYOpusStyleListModel alloc] initWithDictionary:responseObject error:nil];
            block(rspStatusAndMessage,opusStyleListModel,error);
            
        }else{
            block(rspStatusAndMessage,nil,error);
        }
        
    }];
}

/**
 *
 *合作设计师的系列列表
 *
 */
+ (void)getConnSeriesListWithId:(NSInteger )designerId pageIndex:(NSInteger )pageIndex pageSize:(NSInteger)pageSize andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYOpusSeriesListModel *opusSeriesListModel,NSError *error))block{
    // get URL
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kConnSeriesList];
    
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kConnSeriesList params:nil];
    NSString *string = [NSString stringWithFormat:kSeriesListParams_yco,designerId,pageIndex,pageSize];
    
    
    NSData *body = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    [YYRequestHelp executeRequest:YES headers:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error
            && responseObject) {
            YYOpusSeriesListModel *opusSeriesListModel = [[YYOpusSeriesListModel alloc] initWithDictionary:responseObject error:nil];
            block(rspStatusAndMessage,opusSeriesListModel,error);
            
        }else{
            block(rspStatusAndMessage,nil,error);
        }
        
    }];
}

/**
 *
 *合作设计师系列详情
 *
 */
+ (void)getConnSeriesInfoWithId:(NSInteger )designerId seriesId:(NSInteger )seriesId andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYSeriesInfoDetailModel *infoDetailModel,NSError *error))block{
    // get URL
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kConnSeriesInfo_yco];
    
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kConnSeriesInfo_yco params:nil];
    NSString *string = [NSString stringWithFormat:@"designerId=%i&seriesId=%i",designerId,seriesId];
    
    
    NSData *body = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    [YYRequestHelp executeRequest:YES headers:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error
            && responseObject) {
            YYSeriesInfoDetailModel *infoDetailModel = [[YYSeriesInfoDetailModel alloc] initWithDictionary:responseObject error:nil];
            infoDetailModel.brandDescription = [[responseObject objectForKey:@"series"] objectForKey:@"description"];
            block(rspStatusAndMessage,infoDetailModel,error);
        }else{
            block(rspStatusAndMessage,nil,error);
        }
        
    }];
}

/**
 *
 * 合作设计师款式列表（带搜索）
 *
 */
+ (void)getConnStyleListWithDesignerId:(NSInteger )designerId seriesId:(NSInteger )seriesId orderBy:(NSString *)orderBy queryStr:(NSString *)queryStr pageIndex:(int)pageIndex pageSize:(int)pageSize andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYOpusStyleListModel *opusStyleListModel,NSError *error))block{
    // get URL
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kConnStyleList_yco];
    
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kConnStyleList_yco params:nil];
    
    NSString *string = [NSString stringWithFormat:@"designerId=%i",designerId];
    
    if (seriesId > 0) {
        string = [string stringByAppendingString:@"&seriesId="];
        string = [string stringByAppendingString:[NSString stringWithFormat:@"%li",seriesId]];
    }
    
    if (orderBy
        && [orderBy length] > 0) {
        string = [string stringByAppendingString:@"&orderBy="];
        string = [string stringByAppendingString:orderBy];
    }
    
    if(![queryStr isEqualToString:@""]){
        string = [string stringByAppendingString:[NSString stringWithFormat:@"&queryStr=%@&pageIndex=%i&pageSize=%i",queryStr,pageIndex,pageSize]];
    }else{
        string = [string stringByAppendingString:[NSString stringWithFormat:@"&pageIndex=%i&pageSize=%i",pageIndex,pageSize]];
    }
    
    NSData *body = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    [YYRequestHelp executeRequest:YES headers:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error
            && responseObject) {
            YYOpusStyleListModel *opusStyleListModel = [[YYOpusStyleListModel alloc] initWithDictionary:responseObject error:nil];
            block(rspStatusAndMessage,opusStyleListModel,error);
            
        }else{
            block(rspStatusAndMessage,nil,error);
        }
        
    }];

}

/**
 *
 * 更改系列权限
 *
 */
+ (void)updateSeriesAuthType:(long)seriesId authType:(NSInteger)authType buyerIds:(NSString*)buyerIds andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,NSError *error))block{
    // get URL
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kUpdateSeriesAuthType_yco];
    
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kUpdateSeriesAuthType_yco params:nil];
    NSString *string = nil;
    if([NSString isNilOrEmpty:buyerIds]){
        string = [NSString stringWithFormat:@"seriesId=%li&authType=%ld",seriesId,(long)authType];
    }else{
        string = [NSString stringWithFormat:@"seriesId=%li&authType=%ld&buyerIds=%@",seriesId,(long)authType,buyerIds];
    }
    
    NSData *body = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    [YYRequestHelp executeRequest:YES headers:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error
            && responseObject) {
            
            block(rspStatusAndMessage,error);
            
        }else{
            block(rspStatusAndMessage,error);
        }
        
    }];
}

/**
 *
 *设计师系列详情
 *
 */
+ (void)getSeriesInfo:(NSInteger )seriesId andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYSeriesInfoDetailModel *infoDetailModel,NSError *error))block{
    // get URL
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kSeriesInfo_yco];
    
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kSeriesInfo_yco params:nil];
    NSString *string = [NSString stringWithFormat:@"seriesId=%i",seriesId];
    
    
    NSData *body = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    [YYRequestHelp executeRequest:YES headers:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error
            && responseObject) {
            YYSeriesInfoDetailModel *infoDetailModel = [[YYSeriesInfoDetailModel alloc] initWithDictionary:responseObject error:nil];
            infoDetailModel.brandDescription = [[responseObject objectForKey:@"series"] objectForKey:@"description"];
            block(rspStatusAndMessage,infoDetailModel,error);
        }else{
            block(rspStatusAndMessage,nil,error);
        }
        
    }];
}

/**
 *
 *更改系列发布状态与权限
 *
 */
+ (void)updateSeriesPubStatus:(NSInteger)seriesId status:(NSInteger)status authType:(NSString*)authType buyerIds:(NSString*)buyerIds andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,NSError *error))block{
    // get URL
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kUpdateSeriesPubStatus];
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kUpdateSeriesPubStatus params:nil];
    NSString *string = nil;
    if([NSString isNilOrEmpty:buyerIds]){
        string =[NSString stringWithFormat:@"seriesId=%ld&status=%ld&authType=%@",(long)seriesId,(long)status,authType];
    }else{
        string =[NSString stringWithFormat:@"seriesId=%ld&status=%ld&authType=%@&buyerIds=%@",(long)seriesId,(long)status,authType,buyerIds];
    }    NSData *body = [string dataUsingEncoding:NSUTF8StringEncoding];
    [YYRequestHelp executeRequest:YES headers:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error
            && responseObject) {
            block(rspStatusAndMessage,error);
            
        }else{
            block(rspStatusAndMessage,error);
        }
        
    }];
}

/**
 *
 *获取系列发布权限名单
 *
 */
+ (void)getSeriesAuthTypeBuyerList:(NSInteger)seriesId  authType:(NSString*)authType andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYOpusSeriesAuthTypeBuyerListModel * buyerList,NSError *error))block{
    // get URL
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kGetSeriesAuthBuyers];
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kGetSeriesAuthBuyers params:nil];
    NSString *string = [NSString stringWithFormat:@"seriesId=%ld&authType=%@",(long)seriesId,authType];
    NSData *body = [string dataUsingEncoding:NSUTF8StringEncoding];
    [YYRequestHelp executeRequest:YES headers:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error
            && responseObject) {
            YYOpusSeriesAuthTypeBuyerListModel *listModel = [[YYOpusSeriesAuthTypeBuyerListModel alloc] initWithDictionary:responseObject error:nil];
            block(rspStatusAndMessage,listModel,error);
        }else{
            block(rspStatusAndMessage,nil,error);
        }
        
    }];
}
@end

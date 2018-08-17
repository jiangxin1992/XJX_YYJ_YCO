//
//  YYRequestHelp.m
//  Yunejian
//
//  Created by yyj on 15/7/3.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import "YYRequestHelp.h"

#import "AFNetworking.h"
#import "UserDefaultsMacro.h"
#import "YYRspStatusAndMessage.h"
#import "YYUserApi.h"
#import "YYUser.h"
#import "YYSubShowroomUserPowerModel.h"

#import "YYHttpHeaderManager.h"
#import "regular.h"
#import "YYShowroomApi.h"
#import "RequestMacro.h"


#define kNetworkTimeout 50

#define kMaxReRequestFor402 5
static int requestGet402Count = 0;


@implementation YYRequestHelp

+ (void)increaseOrDecreaseRequestGet402Count:(BOOL)isIncrease{
    @synchronized(self){
        if (isIncrease) {
            requestGet402Count++;
        }else{
            requestGet402Count = 0;
        }
    }
}

+ (NSOperation *)executeRequest:(NSString *)requestUrl requestCount:(int)requestCount requestBody:(NSData *)requestBody andBlock:(void (^)(id responseObject, NSError* error, id httpResponse))block{
    if (![YYNetworkReachability connectedToNetwork]) {
        [YYToast showToastWithTitle:kNetworkIsOfflineTips andDuration:kAlertToastDuration];
        block(nil,nil, nil);
        return nil;
    }
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    request.timeoutInterval = kNetworkTimeout;
    
    if(requestBody)
    {
        [request setHTTPBody:requestBody];
    }
    [request setHTTPMethod:@"POST"];
    
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(operation.response)
        {
          //  NSDictionary *responseHeaders = [operation.response allHeaderFields];
            
            NETLog(@"----------Http请求----------\n");
            if(requestBody)
            {
                NETLog(@"----------Http请求Body：%@", [[NSString alloc] initWithData:requestBody encoding:NSUTF8StringEncoding]);
            }
            NETLog(@"----------Http请求Url：%@", requestUrl);
            
            NETLog(@"----------Http响应----------\n");
            NETLog(@"----------Http响应Rsp：%@", operation.response);
            NSString *responseString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            NETLog(@"----------Http响应Body：%@", responseString);
            
            NSError *currentError = nil;
            

            NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
            if (jsonObject) {
                block(jsonObject, currentError, operation.response);
            }else{
                currentError = [NSError errorWithDomain:@"com.yyj" code:9009 userInfo:@{@"message":@"平台没有下发任何数据错误"}];
                block(nil, currentError, operation.response);
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
//        block(nil, error, operation.response);
        NSHTTPURLResponse *response = operation.response;
        NSData *errorData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
        
        NETLog(@"----------Http请求----------\n");
        
        NETLog(@"----------Http请求Url：%@", requestUrl);
        
        NETLog(@"----------Http响应----------\n");
        
        NETLog(@"----------Http响应error：%@",error);
        
        if(errorData){
            NSDictionary *serializedData = [NSJSONSerialization JSONObjectWithData:errorData options:kNilOptions error:nil];
            NETLog(@"----------Http响应serializedData：%@",serializedData);
            YYRspStatusAndMessage *rspStatusAndMessage = [[YYRspStatusAndMessage alloc] init];
            rspStatusAndMessage.message = [serializedData objectForKey:@"message"];
            rspStatusAndMessage.status = (int)[[serializedData objectForKey:@"status"] integerValue];
            block(rspStatusAndMessage, error, response);
        }else{
            [YYToast showToastWithTitle:kNetworkIsOfflineTips andDuration:kAlertToastDuration];
            block(nil, error, response);
        }
    }];
    
    [operation start];
    
    return operation;

}
+ (NSOperation *)executeRequestIsDelete:(BOOL)isDelete headers:(NSDictionary *)headers requestUrl:(NSString *)requestUrl requestCount:(int)requestCount requestBody:(NSData *)requestBody andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage, id responseObject, NSError* error, id httpResponse))block{


    if (![YYNetworkReachability connectedToNetwork]) {
        [YYToast showToastWithTitle:kNetworkIsOfflineTips andDuration:kAlertToastDuration];
        block(nil,nil, nil, nil);
        return nil;
    }

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    request.timeoutInterval = kNetworkTimeout;
    for (NSString *key in headers)
    {
        NSString *value = [headers objectForKey:key];
        [request addValue:value forHTTPHeaderField:key];
    }

    if(isDelete)
    {
        if(requestBody)
        {
            [request setHTTPBody:requestBody];
        }

        if ([requestUrl rangeOfString:kOrderCreate].location != NSNotFound
            || [requestUrl rangeOfString:kOrderModify].location != NSNotFound
            || [requestUrl rangeOfString:kOrderAppend].location != NSNotFound
            || [requestUrl rangeOfString:kHomeUpdateBrandInfoNew].location != NSNotFound
            || [requestUrl rangeOfString:KGetShowroomAgentContentWeb].location != NSNotFound
            || [requestUrl rangeOfString:kSaveParcel].location != NSNotFound
            || [requestUrl rangeOfString:kSaveDeliverPackage].location != NSNotFound) {
            [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
            [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        }
        [request setHTTPMethod:@"DELETE"];
    }
    else
    {
        [request setHTTPBody:requestBody];
    }

    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(operation.response)
        {
            NSDictionary *responseHeaders = [operation.response allHeaderFields];

            NETLog(@"----------Http请求----------\n");
            NETLog(@"----------Http请求Headers：%@", headers);
            if(isDelete && requestBody)
            {
                NETLog(@"----------Http请求Body：%@", [[NSString alloc] initWithData:requestBody encoding:NSUTF8StringEncoding]);
            }
            NETLog(@"----------Http请求Url：%@", requestUrl);

            NETLog(@"----------Http响应----------\n");
            NETLog(@"----------Http响应Rsp：%@", operation.response);
            NSString *responseString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            NETLog(@"----------Http响应Body：%@", responseString);
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            NSString *token = [responseHeaders objectForKey:@"token"];
            if ([requestUrl containsString:kShowroomToBrand]||[requestUrl containsString:kGetShowroomBrandToken]) {
                //showroom到品牌 获取品牌信息
                if (token) {
                    [userDefaults setObject:token forKey:kTempUserLoginTokenKey];
                }
            }else if ([requestUrl containsString:kShowroomBrandToShowroom]){
                //品牌到showroom
                if (token) {
                    [userDefaults setObject:token forKey:kUserLoginTokenKey];
                }
            }else
            {
                if (token) {
                    [userDefaults setObject:token forKey:kUserLoginTokenKey];
                }
            }

            NSString *scrt = [responseHeaders objectForKey:@"scrt"];
            if (scrt) {
                [userDefaults setObject:scrt forKey:kScrtKey];
            }

            [userDefaults synchronize];

            NSError *currentError = nil;


            if ([requestUrl rangeOfString:kCaptcha].location != NSNotFound) {
                block(nil,responseObject, currentError, operation.response);
            }else{
                NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
                YYRspStatusAndMessage *rspStatusAndMessage = nil;
                if (jsonObject) {
                    rspStatusAndMessage = [[YYRspStatusAndMessage alloc] init];
                    NSString *message = [jsonObject objectForKey:@"message"];
                    rspStatusAndMessage.message = message;

                    NSNumber *status = [jsonObject objectForKey:@"status"];
                    if (status) {
                        rspStatusAndMessage.status = status.intValue;
                    }

                    if ((!message || [message length] <= 0 )
                        && status) {
                        rspStatusAndMessage.message = [NSString stringWithFormat:@"错误码为: %i",status.intValue];
                    }


                    //需要重新登录
                    if (rspStatusAndMessage.status == YYReqStatusCode402
                        && requestGet402Count == 0) {
                        [YYRequestHelp increaseOrDecreaseRequestGet402Count:YES];

                        int currentRequestCount = requestCount + 1;
                        if(currentRequestCount >= kMaxReRequestFor402)
                        {

                            if([YYUser isShowroomToBrand])
                            {
                                [YYUser removeTempUser];
                            }
                            //遇到无限循环，原因未知，所以添加请求次数限制来避免
                            rspStatusAndMessage.status = -1;
                            rspStatusAndMessage.message = @"请重新登录";
                            [YYRequestHelp increaseOrDecreaseRequestGet402Count:NO];
                            [[NSNotificationCenter defaultCenter] postNotificationName:kNeedLoginNotification object:nil];

                        }

                        YYUser *user = [YYUser currentUser];
                        if([YYUser isShowroomToBrand])
                        {
                            //品牌重新登录
                            [YYShowroomApi getShowroomToBrandToken:^(YYRspStatusAndMessage *rspStatusAndMessage, YYUserModel *userModel, NSError *error) {
                                if (rspStatusAndMessage
                                    && (rspStatusAndMessage.status == YYReqStatusCode100 || rspStatusAndMessage.status == YYReqStatusCode1000)) {
                                    [YYRequestHelp increaseOrDecreaseRequestGet402Count:NO];
                                    NSMutableDictionary *headDic = [[NSMutableDictionary alloc] initWithDictionary:headers];

                                    NSString *tokenValue = [userDefaults objectForKey:kTempUserLoginTokenKey];

                                    if (tokenValue) {
                                        [headDic setObject:tokenValue forKey:@"token"];
                                    }

                                    [YYRequestHelp executeRequestIsDelete:isDelete
                                                          headers:headDic
                                                       requestUrl:requestUrl
                                                     requestCount:currentRequestCount
                                                      requestBody:requestBody
                                                         andBlock:block ];
                                }else{
                                    //                                    [YYRequestHelp increaseOrDecreaseRequestGet402Count:NO];
                                    [[NSNotificationCenter defaultCenter] postNotificationName:kNeedLoginNotification object:nil];

                                }
                            }];
                        }else if (user.email && user.password) {
                            [YYUserApi loginWithUsername:user.email password:md5(user.password) verificationCode:nil andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYUserModel *userModel, NSError *error) {
                                if (rspStatusAndMessage
                                    && (rspStatusAndMessage.status == YYReqStatusCode100 || rspStatusAndMessage.status == YYReqStatusCode1000)) {
                                    [YYRequestHelp increaseOrDecreaseRequestGet402Count:NO];
                                    NSMutableDictionary *headDic = [[NSMutableDictionary alloc] initWithDictionary:headers];
                                    NSString *tokenValue = [userDefaults objectForKey:kUserLoginTokenKey];
                                    if (tokenValue) {
                                        [headDic setObject:tokenValue forKey:@"token"];
                                    }

                                    [LanguageManager setLanguageToServer];

                                    [YYRequestHelp executeRequestIsDelete:isDelete
                                                          headers:headDic
                                                       requestUrl:requestUrl
                                                     requestCount:currentRequestCount
                                                      requestBody:requestBody
                                                         andBlock:block ];


                                    // 在登录之后, 获取subshowroom的权限列表, 首先是判断showroom子账号
                                    if (user.userType == YYUserTypeShowroomSub) {
                                        [YYShowroomApi selectSubShowroomPowerUserId:[NSNumber numberWithInteger:[user.userId integerValue]] andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSArray *powerArray, NSError *error) {
                                            YYSubShowroomUserPowerModel *subShowroom = [YYSubShowroomUserPowerModel shareModel];
                                            for (NSNumber *i in powerArray) {
                                                if ([i intValue] == 1) {
                                                    subShowroom.isBrandAction = YES;
                                                }
                                            }

                                        }];
                                    }

                                }else{
                                    [[NSNotificationCenter defaultCenter] postNotificationName:kNeedLoginNotification object:nil];
                                }
                            }];
                        }else{
                            [[NSNotificationCenter defaultCenter] postNotificationName:kNeedLoginNotification object:nil];
                        }
                    }else{
                        id dataDic = [jsonObject objectForKey:@"data"];
                        //审核功能 老版本(1.2)没
                        if ([requestUrl rangeOfString:kLogin].location != NSNotFound) {
                            //登录接口
                            if(rspStatusAndMessage.status == YYReqStatusCode100 &&[dataDic objectForKey:@"toMainPage"] != nil){
                                NSString *toMainPage = (NSString *)[dataDic objectForKey:@"toMainPage"];
                                if([toMainPage intValue]>0){
                                    id expireDate = [dataDic objectForKey:@"expireDate"];
                                    if(expireDate == 0 ||(NSNull *)expireDate == [NSNull null]){
                                        rspStatusAndMessage.status = YYReqStatusCode100;
                                    }else{
                                        rspStatusAndMessage.status = YYReqStatusCode1000;
                                        rspStatusAndMessage.message =  getShowDateByFormatAndTimeInterval(NSLocalizedString(@"请在30天内完成品牌信息，未验证的品牌账号将被锁定（yyyy/MM/dd）",nil),[NSString stringWithFormat:@"%@",expireDate]);
                                    }
                                }
                            }
                        }


                        block(rspStatusAndMessage,dataDic, currentError, operation.response);
                    }
                }else{

                    currentError = [NSError errorWithDomain:@"com.yyj" code:9009 userInfo:@{@"message":@"平台没有下发任何数据错误"}];
                    block(nil,nil, currentError, operation.response);
                }
            }

        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

        //        block(nil,nil, error, operation.response);

        NSHTTPURLResponse *response = operation.response;
        NSData *errorData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];

        NETLog(@"----------Http请求----------\n");
        NETLog(@"----------Http请求Headers：%@", headers);

        if(requestBody)
        {
            NETLog(@"----------Http请求Body：%@", [[NSString alloc] initWithData:requestBody encoding:NSUTF8StringEncoding]);
        }

        NETLog(@"----------Http请求Url：%@", requestUrl);

        NETLog(@"----------Http响应----------\n");

        NETLog(@"----------Http响应error：%@",error);

        if(errorData){
            NSDictionary *serializedData = [NSJSONSerialization JSONObjectWithData:errorData options:kNilOptions error:nil];
            NETLog(@"----------Http响应serializedData：%@",serializedData);
            YYRspStatusAndMessage *rspStatusAndMessage = [[YYRspStatusAndMessage alloc] init];
            rspStatusAndMessage.message = [serializedData objectForKey:@"message"];
            rspStatusAndMessage.status = (int)[[serializedData objectForKey:@"status"] integerValue];
            block(rspStatusAndMessage,nil, error, response);
        }else{
            [YYToast showToastWithTitle:kNetworkIsOfflineTips andDuration:kAlertToastDuration];
            block(nil,nil, error, response);
        }
    }];

    [operation start];

    return operation;
}
+ (NSOperation *)executeRequest:(BOOL)isPost headers:(NSDictionary *)headers requestUrl:(NSString *)requestUrl requestCount:(int)requestCount requestBody:(NSData *)requestBody andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage, id responseObject, NSError* error, id httpResponse))block
{
    
    if (![YYNetworkReachability connectedToNetwork]) {
        [YYToast showToastWithTitle:kNetworkIsOfflineTips andDuration:kAlertToastDuration];
        block(nil,nil, nil, nil);
        return nil;
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    request.timeoutInterval = kNetworkTimeout;
    for (NSString *key in headers)
    {
        NSString *value = [headers objectForKey:key];
        [request addValue:value forHTTPHeaderField:key];
    }
    
    if(isPost)
    {
        if(requestBody)
        {
            [request setHTTPBody:requestBody];
        }
        
        if ([requestUrl rangeOfString:kOrderCreate].location != NSNotFound
            || [requestUrl rangeOfString:kOrderModify].location != NSNotFound
            || [requestUrl rangeOfString:kOrderAppend].location != NSNotFound
            || [requestUrl rangeOfString:kHomeUpdateBrandInfoNew].location != NSNotFound
            || [requestUrl rangeOfString:KGetShowroomAgentContentWeb].location != NSNotFound
            || [requestUrl rangeOfString:kSaveParcel].location != NSNotFound
            || [requestUrl rangeOfString:kSaveDeliverPackage].location != NSNotFound) {
            [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
            [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        }
        [request setHTTPMethod:@"POST"];
    }
    else
    {
        [request setHTTPBody:requestBody];
    }
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(operation.response)
        {
            NSDictionary *responseHeaders = [operation.response allHeaderFields];
            
            NETLog(@"----------Http请求----------\n");
            NETLog(@"----------Http请求Headers：%@", headers);
            if(isPost && requestBody)
            {
                NETLog(@"----------Http请求Body：%@", [[NSString alloc] initWithData:requestBody encoding:NSUTF8StringEncoding]);
            }
            NETLog(@"----------Http请求Url：%@", requestUrl);
            
            NETLog(@"----------Http响应----------\n");
            NETLog(@"----------Http响应Rsp：%@", operation.response);
            NSString *responseString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            NETLog(@"----------Http响应Body：%@", responseString);
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            NSString *token = [responseHeaders objectForKey:@"token"];
            if ([requestUrl containsString:kShowroomToBrand]||[requestUrl containsString:kGetShowroomBrandToken]) {
                //showroom到品牌 获取品牌信息
                if (token) {
                    [userDefaults setObject:token forKey:kTempUserLoginTokenKey];
                }
            }else if ([requestUrl containsString:kShowroomBrandToShowroom]){
                //品牌到showroom
                if (token) {
                    [userDefaults setObject:token forKey:kUserLoginTokenKey];
                }
            }else
            {
                if (token) {
                    [userDefaults setObject:token forKey:kUserLoginTokenKey];
                }
            }
            
            NSString *scrt = [responseHeaders objectForKey:@"scrt"];
            if (scrt) {
                [userDefaults setObject:scrt forKey:kScrtKey];
            }
            
            [userDefaults synchronize];
            
            NSError *currentError = nil;
            
            
            if ([requestUrl rangeOfString:kCaptcha].location != NSNotFound) {
                block(nil,responseObject, currentError, operation.response);
            }else{
                NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
                YYRspStatusAndMessage *rspStatusAndMessage = nil;
                if (jsonObject) {
                    rspStatusAndMessage = [[YYRspStatusAndMessage alloc] init];
                    NSString *message = [jsonObject objectForKey:@"message"];
                    rspStatusAndMessage.message = message;
                    
                    NSNumber *status = [jsonObject objectForKey:@"status"];
                    if (status) {
                        rspStatusAndMessage.status = status.intValue;
                    }
                    
                    if ((!message || [message length] <= 0 )
                        && status) {
                        rspStatusAndMessage.message = [NSString stringWithFormat:@"错误码为: %i",status.intValue];
                    }
                    
                    
                    //需要重新登录
                    if (rspStatusAndMessage.status == YYReqStatusCode402
                        && requestGet402Count == 0) {
                        [YYRequestHelp increaseOrDecreaseRequestGet402Count:YES];
                        
                        int currentRequestCount = requestCount + 1;
                        if(currentRequestCount >= kMaxReRequestFor402)
                        {
                            
                            if([YYUser isShowroomToBrand])
                            {
                                [YYUser removeTempUser];
                            }
                            //遇到无限循环，原因未知，所以添加请求次数限制来避免
                            rspStatusAndMessage.status = -1;
                            rspStatusAndMessage.message = @"请重新登录";
                            [YYRequestHelp increaseOrDecreaseRequestGet402Count:NO];
                            [[NSNotificationCenter defaultCenter] postNotificationName:kNeedLoginNotification object:nil];

                        }
                        
                        YYUser *user = [YYUser currentUser];
                        if([YYUser isShowroomToBrand])
                        {
                            //品牌重新登录
                            [YYShowroomApi getShowroomToBrandToken:^(YYRspStatusAndMessage *rspStatusAndMessage, YYUserModel *userModel, NSError *error) {
                                if (rspStatusAndMessage
                                    && (rspStatusAndMessage.status == YYReqStatusCode100 || rspStatusAndMessage.status == YYReqStatusCode1000)) {
                                    [YYRequestHelp increaseOrDecreaseRequestGet402Count:NO];
                                    NSMutableDictionary *headDic = [[NSMutableDictionary alloc] initWithDictionary:headers];
                                    
                                    NSString *tokenValue = [userDefaults objectForKey:kTempUserLoginTokenKey];
                                    
                                    if (tokenValue) {
                                        [headDic setObject:tokenValue forKey:@"token"];
                                    }
                                    
                                    [YYRequestHelp executeRequest:isPost
                                                          headers:headDic
                                                       requestUrl:requestUrl
                                                     requestCount:currentRequestCount
                                                      requestBody:requestBody
                                                         andBlock:block ];
                                }else{
//                                    [YYRequestHelp increaseOrDecreaseRequestGet402Count:NO];
                                    [[NSNotificationCenter defaultCenter] postNotificationName:kNeedLoginNotification object:nil];
                                    
                                }
                            }];
                        }else if (user.email && user.password) {
                            [YYUserApi loginWithUsername:user.email password:md5(user.password) verificationCode:nil andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYUserModel *userModel, NSError *error) {
                                if (rspStatusAndMessage
                                    && (rspStatusAndMessage.status == YYReqStatusCode100 || rspStatusAndMessage.status == YYReqStatusCode1000)) {
                                    [YYRequestHelp increaseOrDecreaseRequestGet402Count:NO];
                                    NSMutableDictionary *headDic = [[NSMutableDictionary alloc] initWithDictionary:headers];
                                    NSString *tokenValue = [userDefaults objectForKey:kUserLoginTokenKey];
                                    if (tokenValue) {
                                        [headDic setObject:tokenValue forKey:@"token"];
                                    }

                                    [LanguageManager setLanguageToServer];

                                    [YYRequestHelp executeRequest:isPost
                                                          headers:headDic
                                                       requestUrl:requestUrl
                                                     requestCount:currentRequestCount
                                                      requestBody:requestBody
                                                         andBlock:block ];


                                    // 在登录之后, 获取subshowroom的权限列表, 首先是判断showroom子账号
                                    if (user.userType == YYUserTypeShowroomSub) {
                                        [YYShowroomApi selectSubShowroomPowerUserId:[NSNumber numberWithInteger:[user.userId integerValue]] andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSArray *powerArray, NSError *error) {
                                            YYSubShowroomUserPowerModel *subShowroom = [YYSubShowroomUserPowerModel shareModel];
                                            for (NSNumber *i in powerArray) {
                                                if ([i intValue] == 1) {
                                                    subShowroom.isBrandAction = YES;
                                                }
                                            }
                                            
                                        }];
                                    }

                                }else{
                                    [[NSNotificationCenter defaultCenter] postNotificationName:kNeedLoginNotification object:nil];
                                }
                            }];
                        }else{
                            [[NSNotificationCenter defaultCenter] postNotificationName:kNeedLoginNotification object:nil];
                        }
                    }else{
                        id dataDic = [jsonObject objectForKey:@"data"];
                        //审核功能 老版本(1.2)没
                        if ([requestUrl rangeOfString:kLogin].location != NSNotFound) {
                            //登录接口
                            if(rspStatusAndMessage.status == YYReqStatusCode100 &&[dataDic objectForKey:@"toMainPage"] != nil){
                                NSString *toMainPage = (NSString *)[dataDic objectForKey:@"toMainPage"];
                                if([toMainPage intValue]>0){
                                    id expireDate = [dataDic objectForKey:@"expireDate"];
                                    if(expireDate == 0 ||(NSNull *)expireDate == [NSNull null]){
                                       rspStatusAndMessage.status = YYReqStatusCode100;
                                    }else{
                                        rspStatusAndMessage.status = YYReqStatusCode1000;
                                        rspStatusAndMessage.message =  getShowDateByFormatAndTimeInterval(NSLocalizedString(@"请在30天内完成品牌信息，未验证的品牌账号将被锁定（yyyy/MM/dd）",nil),[NSString stringWithFormat:@"%@",expireDate]);
                                    }
                                }
                            }
                        }
                        

                        block(rspStatusAndMessage,dataDic, currentError, operation.response);
                    }
                }else{
                    
                    currentError = [NSError errorWithDomain:@"com.yyj" code:9009 userInfo:@{@"message":@"平台没有下发任何数据错误"}];
                    block(nil,nil, currentError, operation.response);
                }
            }
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
//        block(nil,nil, error, operation.response);
        
        NSHTTPURLResponse *response = operation.response;
        NSData *errorData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
        
        NETLog(@"----------Http请求----------\n");
        NETLog(@"----------Http请求Headers：%@", headers);
        
        if(requestBody)
        {
            NETLog(@"----------Http请求Body：%@", [[NSString alloc] initWithData:requestBody encoding:NSUTF8StringEncoding]);
        }
        
        NETLog(@"----------Http请求Url：%@", requestUrl);
        
        NETLog(@"----------Http响应----------\n");
        
        NETLog(@"----------Http响应error：%@",error);
        
        if(errorData){
            NSDictionary *serializedData = [NSJSONSerialization JSONObjectWithData:errorData options:kNilOptions error:nil];
            NETLog(@"----------Http响应serializedData：%@",serializedData);
            YYRspStatusAndMessage *rspStatusAndMessage = [[YYRspStatusAndMessage alloc] init];
            rspStatusAndMessage.message = [serializedData objectForKey:@"message"];
            rspStatusAndMessage.status = (int)[[serializedData objectForKey:@"status"] integerValue];
            block(rspStatusAndMessage,nil, error, response);
        }else{
            [YYToast showToastWithTitle:kNetworkIsOfflineTips andDuration:kAlertToastDuration];
            block(nil,nil, error, response);
        }
    }];
    
    [operation start];
    
    return operation;
}

// 上传图片
+ (AFHTTPRequestOperation *)uploadImageWithUrl:(NSString *)url
                                   image:(UIImage *)image
                                   maxFileSize:(NSInteger)size
                                    andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage, id responseObject, NSError* error, id httpResponse))block {
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AFHTTPRequestOperation *op = [manager POST:url parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        UIImage *tmpimage = compressImage(image,size*1024);
        NSData *imageData = UIImageJPEGRepresentation(tmpimage, 1);
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyyMMddHHmmss";
        NSString *str = [formatter stringFromDate:[NSDate date]];
        NSString *fileName = [NSString stringWithFormat:@"%@.jpg", str];
        
        // 上传图片，以文件流的格式
        [formData appendPartWithFileData:imageData name:@"myfiles" fileName:fileName mimeType:@"image/jpeg"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *jsonObject = nil;
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            jsonObject = (NSDictionary *)responseObject;
        }
        
        YYRspStatusAndMessage *rspStatusAndMessage = nil;
        if (jsonObject) {
            rspStatusAndMessage = [[YYRspStatusAndMessage alloc] init];
            NSString *message = [jsonObject objectForKey:@"message"];
            rspStatusAndMessage.message = message;
            
            NSNumber *status = [jsonObject objectForKey:@"status"];
            if (status) {
                rspStatusAndMessage.status = status.intValue;
            }
            
            if ((!message || [message length] <= 0 )
                && status) {
                rspStatusAndMessage.message = [NSString stringWithFormat:@"错误码为: %i",status.intValue];
            }
        }
        id dataDic = [jsonObject objectForKey:@"data"];
         block(rspStatusAndMessage,dataDic, nil, operation.response);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        block(nil,nil, error, operation.response);
        NSHTTPURLResponse *response = operation.response;
        NSData *errorData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
        
        NETLog(@"----------Http请求----------\n");
        
        NETLog(@"----------Http请求Url：%@", url);
        
        NETLog(@"----------Http响应----------\n");
        
        NETLog(@"----------Http响应error：%@",error);
        
        if(errorData){
            NSDictionary *serializedData = [NSJSONSerialization JSONObjectWithData:errorData options:kNilOptions error:nil];
            NETLog(@"----------Http响应serializedData：%@",serializedData);
            YYRspStatusAndMessage *rspStatusAndMessage = [[YYRspStatusAndMessage alloc] init];
            rspStatusAndMessage.message = [serializedData objectForKey:@"message"];
            rspStatusAndMessage.status = (int)[[serializedData objectForKey:@"status"] integerValue];
            block(rspStatusAndMessage,nil, error, response);
        }else{
            [YYToast showToastWithTitle:kNetworkIsOfflineTips andDuration:kAlertToastDuration];
            block(nil,nil, error, response);
        }
    }];
    
    return op;  
}
// 上传图片 BY QINIU
+ (void)uploadQiniuImage:(UIImage *)image WithType:(NSString *)uploadType
             maxFileSize:(NSInteger)size
                andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage, NSString *imageUrl,NSString * imgKey, NSString *uploadImgPathType, NSError *error))block{
    //            获取 UploadToken
    [YYRequestHelp getUploadTokenWithType:uploadType WithBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSString *UploadToken,NSString *Key,NSString *pathType,NSError *error) {
        if(UploadToken){
            //                    上传图片
//            UIImage *tmpimage = compressImage(image,size*1024);
            NSData *imageData = [regular getImageForSize:4.0f WithImage:image];
//            NSData *imageData = UIImageJPEGRepresentation(tmpimage, 1);
            
            QNUploadManager *upManager = [[QNUploadManager alloc] init];
            [upManager putData:imageData key:Key token:UploadToken
                      complete: ^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
                          if(resp[@"key"])
                          {
                              [YYRequestHelp UploadQiniuKey:resp[@"key"] WithType:pathType WithBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSString *imageUrl, NSError *error) {
                                  block(rspStatusAndMessage,imageUrl,Key,pathType,error);
                              }];
                          }else
                          {
                              block(nil,nil,nil,nil,nil);
                          }
                      } option:nil];
        }
    }];
    
}
+(AFHTTPRequestOperation *)getUploadTokenWithType:(NSString *)uploadType WithBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,NSString *UploadToken,NSString *key,NSString *pathType, NSError *error))block
{
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kGetToken];
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kGetToken params:@{@"type":uploadType}];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AFHTTPRequestOperation *op = [manager POST:requestURL parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *jsonObject = nil;
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            jsonObject = (NSDictionary *)responseObject;
        }
        YYRspStatusAndMessage *rspStatusAndMessage = nil;
        if (jsonObject) {
            rspStatusAndMessage = [[YYRspStatusAndMessage alloc] init];
            NSString *message = [jsonObject objectForKey:@"message"];
            rspStatusAndMessage.message = message;
            
            NSNumber *status = [jsonObject objectForKey:@"status"];
            if (status) {
                rspStatusAndMessage.status = status.intValue;
            }
            
            if ((!message || [message length] <= 0 )
                && status) {
                rspStatusAndMessage.message = [NSString stringWithFormat:@"错误码为: %i",status.intValue];
            }
        }
        if (responseObject) {
            NSDictionary *data=[jsonObject objectForKey:@"data"];
            block(rspStatusAndMessage,[data objectForKey:@"token"],[data objectForKey:@"key"],[data objectForKey:@"type"],nil);
        }else{
            block(rspStatusAndMessage,nil,nil,nil,nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        block(nil,nil,nil,nil,error);
        NSData *errorData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
        
        NETLog(@"----------Http请求----------\n");
        
        NETLog(@"----------Http响应----------\n");
        
        NETLog(@"----------Http响应error：%@",error);
        
        if(errorData){
            NSDictionary *serializedData = [NSJSONSerialization JSONObjectWithData:errorData options:kNilOptions error:nil];
            NETLog(@"----------Http响应serializedData：%@",serializedData);
            YYRspStatusAndMessage *rspStatusAndMessage = [[YYRspStatusAndMessage alloc] init];
            rspStatusAndMessage.message = [serializedData objectForKey:@"message"];
            rspStatusAndMessage.status = (int)[[serializedData objectForKey:@"status"] integerValue];
            block(rspStatusAndMessage,nil,nil,nil,error);
        }else{
            [YYToast showToastWithTitle:kNetworkIsOfflineTips andDuration:kAlertToastDuration];
            block(nil,nil,nil,nil,error);
        }
    }];
    return op;
}
+(AFHTTPRequestOperation *)UploadQiniuKey:(NSString *)key WithType:(NSString *)type WithBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,NSString *imageUrl,NSError *error))block
{
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kUploadKey];
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kUploadKey params:@{@"type":type,@"key":key}];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AFHTTPRequestOperation *op = [manager POST:requestURL parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *jsonObject = nil;
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            jsonObject = (NSDictionary *)responseObject;
        }
        YYRspStatusAndMessage *rspStatusAndMessage = nil;
        if (jsonObject) {
            rspStatusAndMessage = [[YYRspStatusAndMessage alloc] init];
            NSString *message = [jsonObject objectForKey:@"message"];
            rspStatusAndMessage.message = message;
            
            NSNumber *status = [jsonObject objectForKey:@"status"];
            if (status) {
                rspStatusAndMessage.status = status.intValue;
            }
            
            if ((!message || [message length] <= 0 )
                && status) {
                rspStatusAndMessage.message = [NSString stringWithFormat:@"错误码为: %i",status.intValue];
            }
        }
        if (responseObject) {
            block(rspStatusAndMessage,[jsonObject objectForKey:@"data"],nil);
        }else{
            block(rspStatusAndMessage,nil,nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        block(nil,nil, error);
        NSData *errorData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
        
        NETLog(@"----------Http请求----------\n");
        
        NETLog(@"----------Http响应----------\n");
        
        NETLog(@"----------Http响应error：%@",error);
        
        if(errorData){
            NSDictionary *serializedData = [NSJSONSerialization JSONObjectWithData:errorData options:kNilOptions error:nil];
            NETLog(@"----------Http响应serializedData：%@",serializedData);
            YYRspStatusAndMessage *rspStatusAndMessage = [[YYRspStatusAndMessage alloc] init];
            rspStatusAndMessage.message = [serializedData objectForKey:@"message"];
            rspStatusAndMessage.status = (int)[[serializedData objectForKey:@"status"] integerValue];
            block(rspStatusAndMessage,nil, error);
        }else{
            [YYToast showToastWithTitle:kNetworkIsOfflineTips andDuration:kAlertToastDuration];
            block(nil,nil, error);
        }
    }];
    return op;
}
+(AFHTTPRequestOperation *)DeleteQiniuImgWithKey:(NSString *)key WithPathType:(NSString *)PathType WithBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,NSString *imageUrl,NSError *error))block{
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kDeleteKey];
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kDeleteKey params:@{@"type":PathType,@"key":key}];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AFHTTPRequestOperation *op = [manager POST:requestURL parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *jsonObject = nil;
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            jsonObject = (NSDictionary *)responseObject;
        }
        YYRspStatusAndMessage *rspStatusAndMessage = nil;
        if (jsonObject) {
            rspStatusAndMessage = [[YYRspStatusAndMessage alloc] init];
            NSString *message = [jsonObject objectForKey:@"message"];
            rspStatusAndMessage.message = message;
            
            NSNumber *status = [jsonObject objectForKey:@"status"];
            if (status) {
                rspStatusAndMessage.status = status.intValue;
            }
            
            if ((!message || [message length] <= 0 )
                && status) {
                rspStatusAndMessage.message = [NSString stringWithFormat:@"错误码为: %i",status.intValue];
            }
        }
        if (responseObject) {
//            block(rspStatusAndMessage,[jsonObject objectForKey:@"data"],nil);
        }else{
//            block(rspStatusAndMessage,nil,nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        block(nil,nil, error);
    }];
    return op;
}
+ (AFHTTPRequestOperation *)uploadImageWithUrl:(NSString *)url
                                         image:(UIImage *)image
                                          size:(CGFloat )size
                                      andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage, id responseObject, NSError* error, id httpResponse))block {
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AFHTTPRequestOperation *op = [manager POST:url parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        NSData *imageData = [regular getImageForSize:size WithImage:image];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyyMMddHHmmss";
        NSString *str = [formatter stringFromDate:[NSDate date]];
        NSString *fileName = [NSString stringWithFormat:@"%@.jpg", str];
        
        // 上传图片，以文件流的格式
        [formData appendPartWithFileData:imageData name:@"myfiles" fileName:fileName mimeType:@"image/jpeg"];
        NETLog(@"111");
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *jsonObject = nil;
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            jsonObject = (NSDictionary *)responseObject;
        }
        
        YYRspStatusAndMessage *rspStatusAndMessage = nil;
        if (jsonObject) {
            rspStatusAndMessage = [[YYRspStatusAndMessage alloc] init];
            NSString *message = [jsonObject objectForKey:@"message"];
            rspStatusAndMessage.message = message;
            
            NSNumber *status = [jsonObject objectForKey:@"status"];
            if (status) {
                rspStatusAndMessage.status = status.intValue;
            }
            
            if ((!message || [message length] <= 0 )
                && status) {
                rspStatusAndMessage.message = [NSString stringWithFormat:@"错误码为: %i",status.intValue];
            }
        }
        
        
        id dataDic = [jsonObject objectForKey:@"data"];
        block(rspStatusAndMessage,dataDic, nil, operation.response);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        [YYToast showToastWithTitle:kNetworkIsOfflineTips andDuration:kAlertToastDuration];
//        block(nil,nil, error, operation.response);
        NSHTTPURLResponse *response = operation.response;
        NSData *errorData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
        
        NETLog(@"----------Http请求----------\n");
        
        NETLog(@"----------Http响应----------\n");
        
        NETLog(@"----------Http响应error：%@",error);
        
        if(errorData){
            NSDictionary *serializedData = [NSJSONSerialization JSONObjectWithData:errorData options:kNilOptions error:nil];
            NETLog(@"----------Http响应serializedData：%@",serializedData);
            YYRspStatusAndMessage *rspStatusAndMessage = [[YYRspStatusAndMessage alloc] init];
            rspStatusAndMessage.message = [serializedData objectForKey:@"message"];
            rspStatusAndMessage.status = (int)[[serializedData objectForKey:@"status"] integerValue];
            block(rspStatusAndMessage,nil, error, response);
        }else{
            [YYToast showToastWithTitle:kNetworkIsOfflineTips andDuration:kAlertToastDuration];
            block(nil,nil, error, response);
        }
    }];
    
    return op;
}
@end

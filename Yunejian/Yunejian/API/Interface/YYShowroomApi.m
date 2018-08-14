//
//  YYShowroomApi.m
//  yunejianDesigner
//
//  Created by yyj on 2017/3/6.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "YYShowroomApi.h"

// c文件 —> 系统文件（c文件在前）

// 控制器

// 自定义视图

// 接口

// 分类

// 自定义类和三方类（ cocoapods类 > model > 工具类 > 其他）
#import "RequestMacro.h"
#import "YYRequestHelp.h"
#import "UserDefaultsMacro.h"
#import "YYHttpHeaderManager.h"

#import "YYUser.h"
#import "YYUserModel.h"
#import "YYShowroomAgentModel.h"
#import "YYShowroomHomePageModel.h"
#import "YYShowroomBrandListModel.h"
#import "YYShowroomOrderingListModel.h"
#import "YYShowroomInfoByDesignerModel.h"
#import "YYShowroomOrderingCheckListModel.h"

@implementation YYShowroomApi
/**
 *
 * sr订货会权限查询(调用权限：仅showroom_sub)
 *
 */
+ (void)hasPermissionToVisitOrderingWithBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,BOOL hasPermission,NSError *error))block{

    NSString *url = [[NSString alloc] initWithFormat:@"%@?auth=5",KGetShowroomPermissionToOrdering];

    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:url];
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:url params:nil];

    [YYRequestHelp executeRequest:NO headers:dic requestUrl:requestURL requestCount:0 requestBody:nil andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error
            && responseObject) {

            block(rspStatusAndMessage,[((NSDictionary *)responseObject)[@"result"] boolValue],error);

        }else{
            block(rspStatusAndMessage,NO,error);
        }
    }];
}
/**
 *
 * sr订货会是否有消息
 *
 */
+ (void)hasOrderingMsgWithBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,BOOL hasMsg,NSError *error))block{

    NSString *url = [[NSString alloc] initWithFormat:@"%@",KGetShowroomHasOrderingMsg];

    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:url];
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:url params:nil];

    [YYRequestHelp executeRequest:NO headers:dic requestUrl:requestURL requestCount:0 requestBody:nil andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error
            && responseObject) {

            block(rspStatusAndMessage,[responseObject boolValue],error);

        }else{
            block(rspStatusAndMessage,NO,error);
        }
    }];
}
/**
 *
 * 清空sr订货会消息
 *
 */
+ (void)clearOrderingMsgWithBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,NSError *error))block{

    NSString *url = [[NSString alloc] initWithFormat:@"%@",KGetShowroomHasOrderingMsg];

    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:url];
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:url params:nil];

    [YYRequestHelp executeRequestIsDelete:YES headers:dic requestUrl:requestURL requestCount:0 requestBody:nil andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
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
 * sr订货会列表
 *
 */
+ (void)getOrderingListWithPageIndex:(NSInteger )pageIndex pageSize:(NSInteger )pageSize andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYShowroomOrderingListModel *showroomOrderingListModel,NSError *error))block{

    NSString *url = [[NSString alloc] initWithFormat:@"%@?pageIndex=%ld&pageSize=%ld",KGetShowroomOrderingList,pageIndex,pageSize];

    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:url];
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:url params:nil];

    [YYRequestHelp executeRequest:NO headers:dic requestUrl:requestURL requestCount:0 requestBody:nil andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error
            && responseObject) {
            YYShowroomOrderingListModel * showroomOrderingListModel = [[YYShowroomOrderingListModel alloc] initWithDictionary:responseObject error:nil];
            block(rspStatusAndMessage,showroomOrderingListModel,error);

        }else{
            block(rspStatusAndMessage,nil,error);
        }
    }];
}
/**
 *
 * 预约列表
 *
 */
+ (void)getOrderingCheckListWithAppointmentId:(NSNumber *)appointmentId status:(NSString *)status PageIndex:(NSInteger )pageIndex pageSize:(NSInteger )pageSize andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYShowroomOrderingCheckListModel *showroomOrderingCheckListModel,NSError *error))block{

    NSString *url = nil;
    if(![NSString isNilOrEmpty:status]){
        url = [[NSString alloc] initWithFormat:@"%@?appointmentId=%ld&status=%@&pageIndex=%ld&pageSize=%ld",KGetShowroomOrderingCheckList,[appointmentId integerValue],status,pageIndex,pageSize];
    }else{
        url = [[NSString alloc] initWithFormat:@"%@?appointmentId=%ld&pageIndex=%ld&pageSize=%ld",KGetShowroomOrderingCheckList,[appointmentId integerValue],pageIndex,pageSize];
    }

    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:url];
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:url params:nil];

    [YYRequestHelp executeRequest:NO headers:dic requestUrl:requestURL requestCount:0 requestBody:nil andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error
            && responseObject) {
            YYShowroomOrderingCheckListModel * showroomOrderingCheckListModel = [[YYShowroomOrderingCheckListModel alloc] initWithDictionary:responseObject error:nil];
            block(rspStatusAndMessage,showroomOrderingCheckListModel,error);

        }else{
            block(rspStatusAndMessage,nil,error);
        }
    }];
}/**
  *
  * 预约申请审核 通过
  *
  */
+ (void)agreeOrderingApplicationWithIds:(NSString *)ids andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,NSError *error))block{

    NSString *url = [[NSString alloc] initWithFormat:@"%@?ids=%@&to=VERIFIED",KGetShowroomOrderingCheckList,ids];

    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:url];
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:url params:nil];

    [YYRequestHelp executeRequest:YES headers:dic requestUrl:requestURL requestCount:0 requestBody:nil andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
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
 * 预约申请审核 拒绝
 *
 */
+ (void)refuseOrderingApplicationWithIds:(NSString *)ids andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,NSError *error))block{

    NSString *url = [[NSString alloc] initWithFormat:@"%@?ids=%@&to=REJECTED",KGetShowroomOrderingCheckList,ids];

    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:url];
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:url params:nil];

    [YYRequestHelp executeRequest:YES headers:dic requestUrl:requestURL requestCount:0 requestBody:nil andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
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
 * 是否有权限访问该款式
 *
 */
+ (void)hasPermissionToVisitStyleWithStyleId:(NSInteger)styleId andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,BOOL hasPermission,NSNumber *brandId,NSError *error))block{

    NSString *url = [[NSString alloc] initWithFormat:@"%@?styleId=%ld",KGetShowroomPermissionToVisitStyle,styleId];

    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:url];
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:url params:nil];

    [YYRequestHelp executeRequest:NO headers:dic requestUrl:requestURL requestCount:0 requestBody:nil andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error
            && responseObject) {
            block(rspStatusAndMessage,YES,responseObject,error);

        }else{
            block(rspStatusAndMessage,NO,nil,error);
        }
        
    }];
}
/**
 * 品牌页面中token失效处理
 */
+ (void)getShowroomToBrandToken:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYUserModel *userModel,NSError *error))block
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

    YYUser *user = [YYUser currentUser];
    NSString *showroomId = user.userId;
    NSString *brandId = [userDefaults objectForKey:kTempBrandID];
    
    if(brandId && showroomId)
    {
        NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kGetShowroomBrandToken];
        NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kGetShowroomBrandToken params:nil];
        NSString *string = [[NSString alloc] initWithFormat:@"showroomId=%@&brandId=%@",showroomId,brandId];
        
        NSData *body = [string dataUsingEncoding:NSUTF8StringEncoding];
        
        [YYRequestHelp executeRequest:YES headers:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
            if (!error
                && responseObject) {
                YYUserModel *rspDataModel = [[YYUserModel alloc] initWithDictionary:responseObject error:nil];
                block(rspStatusAndMessage,rspDataModel,error);
                
            }else{
                block(rspStatusAndMessage,nil,error);
            }}
         ];
    }
}
/**
 * 品牌到showroom
 */
+ (void)brandToShowroomBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYUserModel *userModel,NSError *error))block
{
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kShowroomBrandToShowroom];
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kShowroomBrandToShowroom params:nil];
    
    [YYRequestHelp executeRequest:YES headers:dic requestUrl:requestURL requestCount:0 requestBody:nil andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error
            && responseObject) {
            [YYUser removeTempUser];
            YYUserModel *rspDataModel = [[YYUserModel alloc] initWithDictionary:responseObject error:nil];
            block(rspStatusAndMessage,rspDataModel,error);
            
        }else{
            block(rspStatusAndMessage,nil,error);
        }}
     ];
}
/**
 * 获取代理协议
 */
+ (void)getAgentContentWithBrandID:(NSNumber *)brandID WithShowroomID:(NSNumber *)showroomID andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYShowroomAgentModel *agentModel,NSError *error))block{
    
    NSString *url = [[NSString alloc] initWithFormat:@"%@?brandId=%ld&showroomId=%ld",KGetShowroomAgentContentWeb,(long)[brandID integerValue],(long)[showroomID integerValue]];
    
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:url];
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:url params:nil];
    
    [YYRequestHelp executeRequest:NO headers:dic requestUrl:requestURL requestCount:0 requestBody:nil andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error
            && responseObject) {
            YYShowroomAgentModel *rspDataModel = [[YYShowroomAgentModel alloc] initWithDictionary:responseObject error:nil];
            block(rspStatusAndMessage,rspDataModel,error);
        }else{
            block(rspStatusAndMessage,nil,error);
        }}
     ];
}
/**
 * showroom到品牌
 */
+ (void)showroomToBrandWithBrandID:(NSNumber *)brandID andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYUserModel *userModel,NSError *error))block
{
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kShowroomToBrand];
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kShowroomToBrand params:nil];
    
    NSString *string = [[NSString alloc] initWithFormat:@"brandId=%ld",(long)[brandID integerValue]];
    
    NSData *body = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    [YYRequestHelp executeRequest:YES headers:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error
            && responseObject) {
            YYUserModel *rspDataModel = [[YYUserModel alloc] initWithDictionary:responseObject error:nil];
            block(rspStatusAndMessage,rspDataModel,error);
            
        }else{
            block(rspStatusAndMessage,nil,error);
        }}
     ];
 }
//获取Showroom首页信息
+ (void)getShowroomBrandListWithBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYShowroomBrandListModel *brandListModel,NSError *error))block
{
    // get URL
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kShowroomList];
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kShowroomList params:nil];
    [YYRequestHelp executeRequest:NO headers:dic requestUrl:requestURL requestCount:0 requestBody:nil andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error) {
            NSLog(@"111");
            YYShowroomBrandListModel * brandlistmodel = [[YYShowroomBrandListModel alloc] initWithDictionary:responseObject error:nil];
            block(rspStatusAndMessage,brandlistmodel,error);
        }else{
            block(rspStatusAndMessage,nil,error);
        }
    }];
}

+ (void)getShowroomHomePageInfoWithBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYShowroomHomePageModel *ShowroomHomePageModel,NSError *error))block
{
    // get URL
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kShowroomHomePageInfo];
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kShowroomHomePageInfo params:nil];
    [YYRequestHelp executeRequest:NO headers:dic requestUrl:requestURL requestCount:0 requestBody:nil andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error) {
            NSLog(@"111");
            YYShowroomHomePageModel * homepageModel = [[YYShowroomHomePageModel alloc] initWithDictionary:responseObject error:nil];
            block(rspStatusAndMessage,homepageModel,error);
        }else{
            block(rspStatusAndMessage,nil,error);
        }
    }];
}

/**
 *
 * 停用或启用销售代表
 *
 */
+ (void)updateSubShowroomStatusWithId:(NSInteger)userId status:(NSInteger)status andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,NSError *error))block{
    // get URL
    NSString *requestUrl = nil;
    if(status){
        //停用
        requestUrl = kShowroomUpdateSalesmanStatusOFF;
    }else{
        //启用
        requestUrl = kShowroomUpdateSalesmanStatusON;
    }
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:requestUrl];
    
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:requestUrl params:nil];
    NSString *string = [[NSString alloc] initWithFormat:@"subId=%ld",(long)userId];
    
    NSData *body = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    [YYRequestHelp executeRequest:YES headers:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        
        block(rspStatusAndMessage,error);
        
    }];
}
/**
 *
 * 添加showroom子账号
 *
 */
+ (void)createSubShowroomWithUsername:(NSString *)username email:(NSString *)email password:(NSString *)password andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage, NSNumber *userId, NSError *error))block{
    // get URL
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kShowroomAddSalesman];
    
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kShowroomAddSalesman params:nil];
//    name=&email=&passWord=
    NSString *string = [NSString stringWithFormat:kaddSubShowroomParams,username,email,password];
    
    
    NSData *body = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    [YYRequestHelp executeRequest:YES headers:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {

        NSNumber *userId;
        if (responseObject) {
            userId = responseObject;
        }
        block(rspStatusAndMessage, userId, error);
        
    }];
}

/**
 *
 * 添加／修改showroom子账号权限
 *
 */
+ (void)subShowroomPowerUserId:(NSNumber *)userId authList:(NSArray *)authList andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage, NSError *error))block{
    // get URL
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kShowroomCreateOrUpdatePower];

    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kShowroomAddSalesman params:nil];

    NSString *auth = [authList componentsJoinedByString:@","];
    NSString *string = [NSString stringWithFormat:@"userId=%@&authList=%@", userId, auth];


    NSData *body = [string dataUsingEncoding:NSUTF8StringEncoding];

    [YYRequestHelp executeRequest:YES headers:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {

        block(rspStatusAndMessage, error);

    }];
}

/**
 *
 * 查询showroom子账号权限
 *
 */
+ (void)selectSubShowroomPowerUserId:(NSNumber *)userId andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage, NSArray *powerArray, NSError *error))block{
    // get URL
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kSubShowroomCreatePower];

    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kShowroomAddSalesman params:nil];

    NSString *string = [NSString stringWithFormat:@"userId=%@", userId];


    NSData *body = [string dataUsingEncoding:NSUTF8StringEncoding];

    [YYRequestHelp executeRequest:YES headers:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {


        NSDictionary *dict = [NSDictionary dictionaryWithDictionary:responseObject];
        NSArray *power = dict[@"result"];
        NSMutableArray *powerArray = [NSMutableArray array];
        for (NSDictionary *dicts in power) {
            if ([dicts[@"checked"] intValue] == YES) {
                [powerArray addObject:[NSString stringWithFormat:@"%@", dicts[@"id"]]];
            }
        }

        block(rspStatusAndMessage, powerArray, error);
        
    }];
}


/**
 *
 * 删除showroom子账号
 *
 */
+ (void)deleteNotActiveSubShowroomUserId:(NSNumber *)userId andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,NSError *error))block{
    // get URL
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kShowroomDeleteNotActive];

    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kShowroomAddSalesman params:nil];

    NSString *string = [NSString stringWithFormat:@"userId=%@", userId];


    NSData *body = [string dataUsingEncoding:NSUTF8StringEncoding];

    [YYRequestHelp executeRequest:YES headers:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {

        block(rspStatusAndMessage,error);
        
    }];
}

/**
 * 根据设计师获取showroom用户
 */
+ (void)getShowroomInfoByDesigner:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYShowroomInfoByDesignerModel *showroomInfoByDesignerModel,NSError *error))block
{
    
    YYUser *user = [YYUser currentUser];
    if(user.userType == YYUserTypeDesigner||user.userType == YYUserTypeSales||[YYUser isShowroomToBrand])
    {
        
        NSString *url = [[NSString alloc] initWithFormat:@"%@?designerId=%@",kGetShowroomInfoByDesigner,user.userId];
        
        NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:url];
        NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:url params:nil];
        
        [YYRequestHelp executeRequest:NO headers:dic requestUrl:requestURL requestCount:0 requestBody:nil andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
            if (!error
                && responseObject) {
                //AGREE已同意，代理中 INIT待同意
                YYShowroomInfoByDesignerModel *rspDataModel = [[YYShowroomInfoByDesignerModel alloc] initWithDictionary:responseObject error:nil];
                block(rspStatusAndMessage,rspDataModel,error);
                
            }else{
                block(rspStatusAndMessage,nil,error);
            }
        }];
    }
}
@end

//
//  YYConnApi.m
//  Yunejian
//
//  Created by Apple on 15/12/1.
//  Copyright © 2015年 yyj. All rights reserved.
//

#import "YYConnApi.h"

// c文件 —> 系统文件（c文件在前）

// 控制器

// 自定义视图

// 接口

// 分类

// 自定义类和三方类（ cocoapods类 > model > 工具类 > 其他）
#import "RequestMacro.h"
#import "YYRequestHelp.h"
#import "YYHttpHeaderManager.h"

#import "YYBuyerListModel.h"
#import "YYConnBuyerListModel.h"
#import "YYConnBrandInfoListModel.h"

@implementation YYConnApi

//设计师添加买手店(买手添加设计师)
+ (void)invite:(NSInteger )guestId andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,NSError *error))block{
    // get URL
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kConnInvite];
    
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kConnInvite params:nil];
    NSString *string = [NSString stringWithFormat:@"guestId=%ld",(long)guestId];
    NSData *body = [string dataUsingEncoding:NSUTF8StringEncoding];
    [YYRequestHelp executeRequest:YES headers:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error) {
            block(rspStatusAndMessage,error);
        }else{
            block(rspStatusAndMessage,error);
        }
    }];
}

//对设计师的邀请请求操作
+ (void)getConnBuyers:(NSInteger)status pageIndex:(int)pageIndex pageSize:(int)pageSize andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYConnBuyerListModel *listModel,NSError *error))block{
    // get URL
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kConnBuyers];
    NSString *string = [NSString stringWithFormat:@"status=%ld&pageIndex=%i&pageSize=%i",(long)status,pageIndex,pageSize];
    NSData *body = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kConnBuyers params:nil];
      [YYRequestHelp executeRequest:YES headers:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error) {
            YYConnBuyerListModel * buyerList = [[YYConnBuyerListModel alloc] initWithDictionary:responseObject error:nil];
            block(rspStatusAndMessage,buyerList,error);
        }else{
            block(rspStatusAndMessage,nil,error);
        }
    }];
}
//设计师对买手合作关系的操作（原设计师移除与买手店的合作关系接口）
+ (void)OprateConnWithBuyer:(NSInteger)buyerId status:(NSInteger)status andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,NSError *error))block{
    // get URL
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kConnWithBuyerOp];
    
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kConnWithBuyerOp params:nil];
    NSString *string = [NSString stringWithFormat:@"buyerId=%ld&status=%ld",(long)buyerId,(long)status];
    NSData *body = [string dataUsingEncoding:NSUTF8StringEncoding];
    [YYRequestHelp executeRequest:YES headers:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error) {
            block(rspStatusAndMessage,error);
        }else{
            block(rspStatusAndMessage,error);
        }
    }];
}

//对设计师的邀请请求操作
+ (void)OprateConnWithDesignerBrand:(NSInteger)designerId status:(NSInteger)status andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,NSError *error))block{
    // get URL
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kConnWithDesignerBrandOp];
    
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kConnWithDesignerBrandOp params:nil];
    NSString *string = [NSString stringWithFormat:@"designerId=%ld&status=%ld",(long)designerId,(long)status];
    NSData *body = [string dataUsingEncoding:NSUTF8StringEncoding];
    [YYRequestHelp executeRequest:YES headers:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error) {
            block(rspStatusAndMessage,error);
        }else{
            block(rspStatusAndMessage,error);
        }
    }];
}

//正在被邀请的品牌(收到的邀请<设计师品牌列表>)1 买手店的所有合作品牌2
+ (void)getConnBrands:(NSInteger)type andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYConnBrandInfoListModel *listModel,NSError *error))block{
    // get URL
    NSString *actionUrl = @"";
    if(type == 1){
        actionUrl = kAllAlreadyConnBrands;
    }else if(type == 2){
        actionUrl = kBeingInvitedBrands;
    }

    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:actionUrl];
    
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:actionUrl params:nil];
    [YYRequestHelp executeRequest:YES headers:dic requestUrl:requestURL requestCount:0 requestBody:nil andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error) {
            YYConnBrandInfoListModel * brandList = [[YYConnBrandInfoListModel alloc] initWithDictionary:responseObject error:nil];
            block(rspStatusAndMessage,brandList,error);
        }else{
            block(rspStatusAndMessage,nil,error);
        }
    }];
}
//设计师按条件查询所有买手店(带分页,目前邀请状态)
+(void) queryConnBuyer:(NSString *)queryStr pageIndex:(int)pageIndex pageSize:(int)pageSize andBlock:(void(^)(YYRspStatusAndMessage *rspStatusAndMessage,YYBuyerListModel *buyerList,NSError *error))block{
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kConnQueryBuyerList];
    
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kConnQueryBuyerList params:nil];
    NSString *string = @"";
    if(![queryStr isEqualToString:@""]){
        string = [string stringByAppendingString:[NSString stringWithFormat:@"queryStr=%@&pageIndex=%i&pageSize=%i",queryStr,pageIndex,pageSize]];
    }else{
        string = [string stringByAppendingString:[NSString stringWithFormat:@"pageIndex=%i&pageSize=%i",pageIndex,pageSize]];
    }
    NSData *body = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    [YYRequestHelp executeRequest:YES headers:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error
            && responseObject) {
            YYBuyerListModel *buyerListModel = [[YYBuyerListModel alloc] initWithDictionary:responseObject error:nil];
            block(rspStatusAndMessage,buyerListModel,error);
            
        }else{
            block(rspStatusAndMessage,nil,error);
        }
        
    }];
}

//批量判断买手店是否在合作状态中
+(void)checkConnBuyers:(NSString *)buyerIds andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,BOOL isConn,NSError *error))block{
    // get URL
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kCheckConnBuyers];
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kCheckConnBuyers params:nil];
    NSString *string = [NSString stringWithFormat:@"buyerIds=%@",buyerIds];
    NSData *body = [string dataUsingEncoding:NSUTF8StringEncoding];
    [YYRequestHelp executeRequest:YES headers:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error) {
            BOOL isconn = ![[responseObject objectForKey:@"hasUnConnected"] integerValue];
            block(rspStatusAndMessage,isconn,error);
        }else{
            block(rspStatusAndMessage,YES,error);
        }
    }];
}
@end

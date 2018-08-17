//
//  YYOrderApi.m
//  Yunejian
//
//  Created by yyj on 15/8/6.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import "YYOrderApi.h"
#import "YYRequestHelp.h"
#import "YYHttpHeaderManager.h"
#import "RequestMacro.h"
#import "YYOrderStatusMarksModel.h"
#import "YYUser.h"
@implementation YYOrderApi

/**
 *
 * 拒绝订单
 *
 */
+(void)refuseOrderByOrderCode:(NSString *)orderCode reason:(NSString *)reason andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,NSError *error))block{

    NSString *string = [NSString stringWithFormat:@"orderCode=%@&reason=%@",orderCode,reason];

    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kOrderRefuse];
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kOrderRefuse params:nil];
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
 * 确认订单
 *
 */
+ (void)confirmOrderByOrderCode:(NSString *)orderCode andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,NSError *error))block{

    NSString *string = [NSString stringWithFormat:@"orderCode=%@",orderCode];

    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kOrderConfirm];
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kOrderConfirm params:nil];
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
 * 获取订单列表信息
 *
 */
+ (void)getOrderInfoListWithPayType:(NSInteger )payType orderStatus:(NSString *)orderStatus pageIndex:(NSInteger )pageIndex pageSize:(NSInteger )pageSize andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYOrderListModel *orderListModel,NSError *error))block;
{
    // get URL
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kBrandOrderList];
    
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kBrandOrderList params:nil];

    NSString *parametersString = nil;
    //payType 和 orderStatus只会存在一个
    if(payType != -1){
        parametersString = [NSString stringWithFormat:@"pageIndex=%ld&pageSize=%ld&payType=%ld",pageIndex,pageSize,payType];
    }else{
        if(![orderStatus isEqualToString:@"-1"]){
            parametersString = [NSString stringWithFormat:@"pageIndex=%ld&pageSize=%ld&orderStatus=%@",pageIndex,pageSize,orderStatus];
        }else{
            parametersString = [NSString stringWithFormat:@"pageIndex=%ld&pageSize=%ld",pageIndex,pageSize];
        }
    }
    
    NSData *body = [parametersString dataUsingEncoding:NSUTF8StringEncoding];

    [YYRequestHelp executeRequest:YES headers:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error
            && responseObject) {
            YYOrderListModel *orderListModel = [[YYOrderListModel alloc] initWithDictionary:responseObject error:nil];
            block(rspStatusAndMessage,orderListModel,error);
            
        }else{
            block(rspStatusAndMessage,nil,error);
        }
        
    }];
}

/**
 *
 * 获取订单列表单条信息
 *
 */
+ (void)getOrderInfoListItemWithOrderCode:(NSString *)orderCode andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYOrderListItemModel *orderListItemModel,NSError *error))block;
{
    // get URL
    NSString *actionName = nil;
    
    NSString *string = [NSString stringWithFormat:@"orderCode=%@",orderCode];
    actionName = kOrderListItem;
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:actionName];
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kOrderListItem params:nil];
    NSData *body = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    [YYRequestHelp executeRequest:YES headers:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error
            && responseObject) {
            YYOrderListItemModel *orderListItemModel = [[YYOrderListItemModel alloc] initWithDictionary:responseObject error:nil];
            block(rspStatusAndMessage,orderListItemModel,error);
            
        }else{
            block(rspStatusAndMessage,nil,error);
        }
        
    }];
}

/**
 *
 * 获取订单信息
 * isForReBuildOrder ---->获取订单信息是否为了重新创建订单
 */
+ (void)getOrderByOrderCode:(NSString *)orderCode isForReBuildOrder:(BOOL)isForReBuildOrder andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYOrderInfoModel *orderInfoModel,NSError *error))block{
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kOrderInfo];
    
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kOrderInfo params:nil];
    NSString *string = nil;
    if(isForReBuildOrder){
        string = [NSString stringWithFormat:@"orderCode=%@&stock=%@&source=%@&check=%@",orderCode, @(true), @(2), @(false)];
    }else{
        string = [NSString stringWithFormat:@"orderCode=%@&stock=%@",orderCode, @(true)];
    }
    
    NSData *body = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    [YYRequestHelp executeRequest:YES headers:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error && responseObject) {
            YYOrderInfoModel *orderInfoModel = [[YYOrderInfoModel alloc] initWithDictionary:responseObject error:nil];
            block(rspStatusAndMessage,orderInfoModel,error);
        }else{
            block(rspStatusAndMessage,nil,error);
        }
    }];
}

/**
 *
 * 获取订单设置信息
 *
 */
+ (void)getOrderSettingInfoWithBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYOrderSettingInfoModel *orderSettingInfoModel,NSError *error))block{
    // get URL
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kOrderSettingInfo];
    
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kOrderSettingInfo params:nil];
    NSString *string = [NSString stringWithFormat:@"checkedOnly=true"];
    NSData *body = [string dataUsingEncoding:NSUTF8StringEncoding];

    [YYRequestHelp executeRequest:YES headers:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error
            && responseObject) {
            YYOrderSettingInfoModel *orderSettingInfoModel = [[YYOrderSettingInfoModel alloc] initWithDictionary:responseObject error:nil];
            block(rspStatusAndMessage,orderSettingInfoModel,error);
            
        }else{
            block(rspStatusAndMessage,nil,error);
        }
        
    }];
}

/**
 *
 * 创建或修改订单
 *
 */
+ (void)createOrModifyOrderByJsonString:(NSString *)jsonString actionRefer:(NSString*)actionRefer realBuyerId:(NSInteger)realBuyerId andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,NSString *orderCode,NSError *error))block{
    // get URL
    NSString *actionName = nil;//@"create":@"modify"
    if([actionRefer isEqualToString:@"create"]){
        actionName = kOrderCreate;
        if(realBuyerId>0){
            actionName = [NSString stringWithFormat:@"%@?realBuyerId=%ld",actionName,(long)realBuyerId];
        }
    }else if([actionRefer isEqualToString:@"append"]){
        actionName = kOrderAppend;
        if(realBuyerId>0){
            actionName = [NSString stringWithFormat:@"%@?realBuyerId=%ld",actionName,(long)realBuyerId];
        }
    }else if([actionRefer isEqualToString:@"modify"]){
        actionName = kOrderModify;
        if(realBuyerId>0){
            actionName = [NSString stringWithFormat:@"%@?realBuyerId=%ld",actionName,(long)realBuyerId];
        }
    }else if([actionRefer isEqualToString:@"rebuild"]){
        actionName = kOrderModify;
        if(realBuyerId>0){
            actionName = [NSString stringWithFormat:@"%@?realBuyerId=%ld&reassociate=true",actionName,(long)realBuyerId];
        }else{
            actionName = [NSString stringWithFormat:@"%@?realBuyerId=0&reassociate=true",actionName];
        }
    }else{
        actionName = kOrderCreateOrModify;
    }

    
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:actionName];
    
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:actionName params:nil];
    NSString *string = [NSString stringWithFormat:kOrderCreateOrModifyParams_yco,jsonString];
    
    NSData *body = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    [YYRequestHelp executeRequest:YES headers:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error
            && responseObject) {
            block(rspStatusAndMessage,responseObject,error);
            
        }else{
            block(rspStatusAndMessage,nil,error);
        }
        
    }];
}

/**
 *
 * 创建或修改买家地址
 *
 */
+ (void)createOrModifyAddress:(YYAddress *)address andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYBuyerAddressModel *addressModel, NSError *error))block{

    // get URL
    NSString *requestURL = @"";
    NSDictionary *dic = nil;
    NSString *string = nil;
    
    NSString *_nationId  = @"";
    if([address.nationId integerValue]>0){
        _nationId = [[NSString alloc] initWithFormat:@"%ld",[address.nationId integerValue]];
    }
    NSString *_provinceId  = @"";
    if([address.provinceId integerValue]>0){
        _provinceId = [[NSString alloc] initWithFormat:@"%ld",[address.provinceId integerValue]];
    }
    NSString *_cityId = @"";
    if([address.cityId integerValue]>0){
        _cityId = [[NSString alloc] initWithFormat:@"%ld",[address.cityId integerValue]];
    }
    
    NSString *_nation  = @"";
    if(![NSString isNilOrEmpty:address.nation]){
        if(![address.nation isEqualToString:@"-"]){
            _nation = address.nation;
        }
    }
    
    NSString *_province  = @"";
    if(![NSString isNilOrEmpty:address.province]){
        if(![address.province isEqualToString:@"-"]){
            _province = address.province;
        }
    }
    
    NSString *_city  = @"";
    if(![NSString isNilOrEmpty:address.city]){
        if(![address.city isEqualToString:@"-"]){
            _city = address.city;
        }
    }

    
     requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kAddOrModifyBuyerAddress];
    dic = [YYHttpHeaderManager buildHeadderWithAction:kAddOrModifyBuyerAddress params:nil];
    if (address.addressId) {
       string = [NSString stringWithFormat:kModifyBuyerAddressParams,_province,_city,address.receiverName,address.receiverPhone,address.detailAddress,address.zipCode,[address.addressId intValue],_nation,_nationId,_provinceId,_cityId];
    
        
    }else{
        string = [NSString stringWithFormat:kAddBuyerAddressParams,_province,_city,address.receiverName,address.receiverPhone,address.detailAddress,address.zipCode,_nation,_nationId,_provinceId,_cityId];
    }
    
    NSData *body = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    [YYRequestHelp executeRequest:YES headers:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        
        YYBuyerAddressModel *addressModel = [[YYBuyerAddressModel alloc] initWithDictionary:responseObject error:nil];
        block(rspStatusAndMessage,addressModel,error);
        
    }];

}

/**
 *
 * 上传图片
 *
 */
+ (void)uploadImage:(UIImage *)image size:(CGFloat)size andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,NSString *imageUrl,NSError *error))block{
    
    // get URL
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kUploadImage];
    
    [YYRequestHelp uploadImageWithUrl:requestURL image:image size:size andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, id responseObject, NSError *error, id httpResponse) {
        block(rspStatusAndMessage,responseObject,error);
    }];
}


+ (void)uploadImage:(UIImage *)image maxFileSize:(NSInteger)size andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,NSString *imageUrl,NSError *error))block{
    // get URL
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kUploadImage];
    
    [YYRequestHelp uploadImageWithUrl:requestURL image:image
                             maxFileSize:size andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, id responseObject, NSError *error, id httpResponse) {
        block(rspStatusAndMessage,responseObject,error);
    }];
}

/**
 *
 * opType 取消订单1，恢复订单2，删除订单3
 *
 *
 */
+ (void)updateOrderWithOrderCode:(NSString *)orderCode opType:(int)opType andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,NSError *error))block{

    // get URL
    NSString *actionName = nil;
    if (opType == 1) {
        YYUser *user = [YYUser currentUser];
        if(user.userType == kBuyerStorUserType){
            actionName = kBuyerCancelOrder;
        }else{
            actionName = kCancelOrder;
        }
    }else if (opType == 3) {
        actionName = kDeleteOrder_yco;
    }

    if(![NSString isNilOrEmpty:actionName]){
        NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:actionName];;

        NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:actionName params:nil];
        NSString *string = [NSString stringWithFormat:@"orderCode=%@",orderCode];

        NSData *body = [string dataUsingEncoding:NSUTF8StringEncoding];

        [YYRequestHelp executeRequest:YES headers:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
            block(rspStatusAndMessage,error);
        }];
    }
}

/**
 *
 * 单个订单的操作记录(分页)
 *
 */
+ (void)getsingleOrderInfoDynamicsList:(NSString *)orderCode pageIndex:(int)pageIndex pageSize:(int)pageSize andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYOrderOperateLogListModel *orderListModel,NSError *error))block{
    // get URL
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kGetSingleOrderInfoDynamics];
    
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kGetSingleOrderInfoDynamics params:nil];
    
    NSString *string = [NSString stringWithFormat:@"orderCode=%@&pageIndex=%i&pageSize=%i",orderCode,pageIndex,pageSize];
    NSData *body = [string dataUsingEncoding:NSUTF8StringEncoding];
    [YYRequestHelp executeRequest:YES headers:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error
            && responseObject) {
            YYOrderOperateLogListModel *logListModel = [[YYOrderOperateLogListModel alloc] initWithDictionary:responseObject error:nil];
            block(rspStatusAndMessage,logListModel,error);
            
        }else{
            block(rspStatusAndMessage,nil,error);
        }
        
    }];
}

/**
 *
 *获取通知消息列表
 *
 */
+ (void)getNotifyMsgList:(NSString *)msgType pageIndex:(NSInteger )pageIndex pageSize:(NSInteger )pageSize andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYOrderMessageInfoListModel *msgListModel,NSError *error))block{
    // get URL
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kGetNotifyMsgList];
    
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kGetNotifyMsgList params:nil];
    
    NSString *string = [NSString stringWithFormat:@"msgType=%@&pageIndex=%i&pageSize=%i",msgType,pageIndex,pageSize];
    NSData *body = [string dataUsingEncoding:NSUTF8StringEncoding];
    [YYRequestHelp executeRequest:YES headers:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error
            && responseObject) {
            YYOrderMessageInfoListModel *msgListModel = [[YYOrderMessageInfoListModel alloc] initWithDictionary:responseObject error:nil];
            block(rspStatusAndMessage,msgListModel,error);
            
        }else{
            block(rspStatusAndMessage,nil,error);
        }
        
    }];

}

/**
 *
 *未读消息条数查询
 *
 */
+ (void)getUnreadNotifyMsgAmount:(NSString *)msgType andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,NSInteger orderMsgCount,NSInteger connMsgCount,NSError *error))block{
    // get URL
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kGetUnreadNotifyMsgAmount];
    
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kGetUnreadNotifyMsgAmount params:nil];
    
    //NSString *string = [NSString stringWithFormat:@"msgType=%@",msgType];
    //NSData *body = [string dataUsingEncoding:NSUTF8StringEncoding];
    [YYRequestHelp executeRequest:YES headers:dic requestUrl:requestURL requestCount:0 requestBody:nil andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error) {
            NSInteger ordermsgCount=[[responseObject objectForKey:@"orderAmount"] integerValue];
            NSInteger connmsgCount=[[responseObject objectForKey:@"connAmount"] integerValue];
            block(rspStatusAndMessage,ordermsgCount,connmsgCount,error);
        }else{
            block(rspStatusAndMessage,0,0,error);
        }
        
    }];
}
/**
 *
 *买手操作订单关联请求
 *
 */
+ (void)setOpWithOrderConn:(NSString *)orderCode opType:(NSInteger)opType andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,NSError *error))block{
    // get URL
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kopWithOrderConn];
    
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kopWithOrderConn params:nil];
    
    NSString *string = [NSString stringWithFormat:@"orderCode=%@&opType=%ld",orderCode,(long)opType];
    NSData *body = [string dataUsingEncoding:NSUTF8StringEncoding];
    [YYRequestHelp executeRequest:YES headers:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error) {
            block(rspStatusAndMessage,error);
        }else{
            block(rspStatusAndMessage,error);
        }
        
    }];
}

/**
 *
 *标记同一类型通知消息为已读
 *
 */
+ (void)markAsRead:(NSInteger)msgType andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,NSError *error))block{
    // get URL
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kMarkAsRead];
    
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kMarkAsRead params:nil];
    NSString *string = [NSString stringWithFormat:@"msgType=%ld",(long)msgType];
    NSData *body = [string dataUsingEncoding:NSUTF8StringEncoding];
    [YYRequestHelp executeRequest:YES headers:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error) {
            block(rspStatusAndMessage,error);
        }else{
            block(rspStatusAndMessage,error);
        }
    }];
}


/**
 *
 *获取某个订单的分享状态信息
 *
 */
+ (void)getOrderConnStatus:(NSString *)orderCode andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYOrderConnStatusModel* statusModel,NSError *error))block{
    // get URL
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kGetorderConnStatus];
    
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kGetorderConnStatus params:nil];
    
    NSString *string = [NSString stringWithFormat:@"orderCode=%@",orderCode];
    NSData *body = [string dataUsingEncoding:NSUTF8StringEncoding];
    __block NSString *blockOrderCode = orderCode;
    [YYRequestHelp executeRequest:YES headers:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error
            && (NSNull *)responseObject != [NSNull null]) {
            YYOrderConnStatusModel *statusModel = [[YYOrderConnStatusModel alloc] initWithDictionary:responseObject error:nil];
            block(rspStatusAndMessage,statusModel,error);
            
        }else{
            YYOrderConnStatusModel *statusModel = [[YYOrderConnStatusModel alloc] init];
            statusModel.status = [[NSNumber alloc] initWithInteger:kOrderStatus];//;
            statusModel.orderCode = blockOrderCode;
            block(rspStatusAndMessage,statusModel,error);
        }
        
    }];
}

/**
 *
 *更新订单流转状态
 *
 */
+ (void)updateTransStatus:(NSString *)orderCode  statusCode:(NSInteger)statusCode andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,NSError *error))block{
    // get URL
    NSString *actionName = nil;
    NSString *string = nil;
    if(statusCode == kOrderCode_DELIVERY){
        actionName = kDesignerSendOut;
        string = [NSString stringWithFormat:@"orderCode=%@",orderCode];
    }else{
        actionName = kUpdateTransStatus;
        string = [NSString stringWithFormat:@"orderCode=%@&statusCode=%ld",orderCode,(long)statusCode];
    }
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:actionName];
    
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:actionName params:nil];

    NSData *body = [string dataUsingEncoding:NSUTF8StringEncoding];
    [YYRequestHelp executeRequest:YES headers:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error) {
            block(rspStatusAndMessage,error);
        }else{
            block(rspStatusAndMessage,error);
        }
    }];
}

/**
 *
 *当前订单流转状态
 *
 */
+ (void)getOrderTransStatus:(NSString *)orderCode andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYOrderTransStatusModel* transStatusModel,NSError *error))block{
    // get URL
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kCrtTransStatus];
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kCrtTransStatus params:nil];
    
    NSString *string = [NSString stringWithFormat:@"orderCode=%@",orderCode];
    NSData *body = [string dataUsingEncoding:NSUTF8StringEncoding];
    [YYRequestHelp executeRequest:YES headers:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error) {
            YYOrderTransStatusModel *statusModel = [[YYOrderTransStatusModel alloc] initWithDictionary:responseObject error:nil];
            block(rspStatusAndMessage,statusModel,error);
            
        }else{
            block(rspStatusAndMessage,nil,error);
        }
        
    }];
}

/**
 *
 *删除付款记录
 *
 */
+ (void)deletePaymentNote:(NSString *)noteid andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,NSError *error))block{
    // get URL
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kDeletePaymentNote];
    
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kDeletePaymentNote params:nil];
    NSString *string = [NSString stringWithFormat:@"id=%@",noteid];
    NSData *body = [string dataUsingEncoding:NSUTF8StringEncoding];
    [YYRequestHelp executeRequest:YES headers:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error) {
            block(rspStatusAndMessage,error);
        }else{
            block(rspStatusAndMessage,error);
        }
    }];
}

/**
 *
 *修改付款记录
 *
 */
+ (void)editPaymentNote:(NSString *)noteid orderCode:(NSString *)orderCode  percent:(NSInteger)percent amount:(float)amount andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,NSError *error))block{
    // get URL
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kEditPaymentNote];
    
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kEditPaymentNote params:nil];
    NSString *string = [NSString stringWithFormat:@"id=%@&orderCode=%@&percent=%ld&amount=%f",noteid,orderCode,(long)percent,amount];
    NSData *body = [string dataUsingEncoding:NSUTF8StringEncoding];
    [YYRequestHelp executeRequest:YES headers:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error) {
            block(rspStatusAndMessage,error);
        }else{
            block(rspStatusAndMessage,error);
        }
    }];
}



/**
 *
 *添加付款（收款）记录
 *
 */
+ (void)addPaymentNote:(NSString *)orderCode  percent:(NSInteger)percent amount:(float)amount andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,NSError *error))block{
    // get URL
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kAddPaymentNote];
    
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kAddPaymentNote params:nil];
    NSString *string = [NSString stringWithFormat:@"orderCode=%@&percent=%ld&amount=%f",orderCode,(long)percent,amount];
    NSData *body = [string dataUsingEncoding:NSUTF8StringEncoding];
    [YYRequestHelp executeRequest:YES headers:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error) {
            block(rspStatusAndMessage,error);
        }else{
            block(rspStatusAndMessage,error);
        }
    }];
}

/**
 *
 *订单收款记录
 *
 */
+ (void)getPaymentNoteList:(NSString *)orderCode andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYPaymentNoteListModel *noteList,NSError *error))block{
    // get URL
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kPaymentNoteList];
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kPaymentNoteList params:nil];
    
    NSString *string = [NSString stringWithFormat:@"orderCode=%@",orderCode];
    NSData *body = [string dataUsingEncoding:NSUTF8StringEncoding];
    [YYRequestHelp executeRequest:YES headers:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error) {
            YYPaymentNoteListModel *noteListModel = [[YYPaymentNoteListModel alloc] initWithDictionary:responseObject error:nil];
            block(rspStatusAndMessage,noteListModel,error);
            
        }else{
            block(rspStatusAndMessage,nil,error);
        }
        
    }];
}

/**
 *
 *关闭订单请求(买手,设计师)
 *
 */
+ (void)setOrderCloseRequest:(NSString *)orderCode andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,NSError *error))block{
    // get URL
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kOrderCloseRequest];
    
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kOrderCloseRequest params:nil];
    NSString *string = [NSString stringWithFormat:@"orderCode=%@",orderCode];
    NSData *body = [string dataUsingEncoding:NSUTF8StringEncoding];
    [YYRequestHelp executeRequest:YES headers:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error) {
            block(rspStatusAndMessage,error);
        }else{
            block(rspStatusAndMessage,error);
        }
    }];
}

/**
 *
 *处理关闭订单请求(买手,设计师)
 *
 */
+ (void)dealOrderCloseRequest:(NSString *)orderCode isAgree:(NSString*)isAgree andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,NSError *error))block{
    // get URL
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kDealOrderCloseRequest];
    
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kDealOrderCloseRequest params:nil];
    NSString *string = [NSString stringWithFormat:@"orderCode=%@&isAgree=%@",orderCode,isAgree];
    NSData *body = [string dataUsingEncoding:NSUTF8StringEncoding];
    [YYRequestHelp executeRequest:YES headers:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error) {
            block(rspStatusAndMessage,error);
        }else{
            block(rspStatusAndMessage,error);
        }
    }];
}

/**
 *
 *撤销关闭订单请求(买手,设计师)
 *
 */
+ (void)revokeOrderCloseRequest:(NSString *)orderCode  andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,NSError *error))block{
    // get URL
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kRevokeOrderCloseRequest];
    
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kRevokeOrderCloseRequest params:nil];
    NSString *string = [NSString stringWithFormat:@"orderCode=%@",orderCode];
    NSData *body = [string dataUsingEncoding:NSUTF8StringEncoding];
    [YYRequestHelp executeRequest:YES headers:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error) {
            block(rspStatusAndMessage,error);
        }else{
            block(rspStatusAndMessage,error);
        }
    }];
}

/**
 *
 *款式是否过期
 *
 */
+ (void)isStyleModify:(NSString *)styleMap  andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYOrderStyleModifyReslutModel *styleModifyReslut,NSError *error))block{
    // get URL
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kIsStyleModify];
    
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kIsStyleModify params:nil];
    NSString *string = [NSString stringWithFormat:@"styleMap=%@",styleMap];
    NSData *body = [string dataUsingEncoding:NSUTF8StringEncoding];
    [YYRequestHelp executeRequest:YES headers:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error) {
            YYOrderStyleModifyReslutModel *styleModifyReslutModel = [[YYOrderStyleModifyReslutModel alloc] initWithDictionary:responseObject error:nil];
            block(rspStatusAndMessage,styleModifyReslutModel,error);
        }else{
            block(rspStatusAndMessage,nil,error);
        }
    }];
}

/**
 *
 *查看对方是否订单关闭
 *
 */
+ (void)getOrderCloseStatus:(NSString *)orderCode  andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,NSInteger isclose,NSError *error))block{
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kOrderCloseStatus];
    
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kOrderCloseStatus params:nil];
    NSString *string = [NSString stringWithFormat:@"orderCode=%@",orderCode];
    NSData *body = [string dataUsingEncoding:NSUTF8StringEncoding];
    [YYRequestHelp executeRequest:YES headers:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error) {
            block(rspStatusAndMessage,[responseObject integerValue],error);
        }else{
            block(rspStatusAndMessage,0,error);
        }
    }];
}

/**
 *
 *关闭订单
 *
 */
+ (void)closeOrder:(NSString *)orderCode  andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,NSError *error))block{
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kCloseOrder];
    
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kCloseOrder params:nil];
    NSString *string = [NSString stringWithFormat:@"orderCode=%@",orderCode];
    NSData *body = [string dataUsingEncoding:NSUTF8StringEncoding];
    [YYRequestHelp executeRequest:YES headers:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error) {
            block(rspStatusAndMessage,error);
        }else{
            block(rspStatusAndMessage,error);
        }
    }];
}
/**
 *
 *订单起订额
 *
 */
+ (void)getOrderUnitPrice:(NSUInteger)designerId moneyType:(NSInteger)moneyType andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,NSUInteger orderUnitPrice,NSError *error))block{
    // get URL
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kOrderUnitPrice];

//    if(moneyType == -1){
//        [YYToast showToastWithTitle:NSLocalizedString(@"卧槽！这里出现了curType=-1",nil) andDuration:kAlertToastDuration];
//    }

    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kOrderUnitPrice params:nil];
    NSString *string = [NSString stringWithFormat:@"designerId=%ld&curType=%ld",(unsigned long)designerId,(long)moneyType];

    NSData *body = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    [YYRequestHelp executeRequest:YES headers:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error
            && responseObject) {
            NSUInteger data = [responseObject unsignedIntegerValue];
            block(rspStatusAndMessage,data,error);
            
        }else{
            block(rspStatusAndMessage,0,error);
        }
        
    }];
}

/**
 *
 *开启或关闭补货
 *
 */
+ (void)getOrderSimpleStyleList:(NSString *)orderCode  andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYOrderSimpleStyleList *styleList,NSError *error))block{
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kOrderSimpleStyleList];
    
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kOrderSimpleStyleList params:nil];
    NSString *string = [NSString stringWithFormat:@"orderCode=%@",orderCode];
    NSData *body = [string dataUsingEncoding:NSUTF8StringEncoding];
    [YYRequestHelp executeRequest:YES headers:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error) {
            YYOrderSimpleStyleList *simpleStyleList = [[YYOrderSimpleStyleList alloc] initWithDictionary:responseObject error:nil];
            block(rspStatusAndMessage,simpleStyleList,error);
        }else{
            block(rspStatusAndMessage,nil,error);
        }
    }];
}

/**
 *
 *追单初始化创建
 *
 */
+ (void)appendOrder:(YYOrderAppendParamModel *)model  andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,NSString *orderCode,NSError *error))block{
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kOrderPreAppend_yco];
    
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kOrderPreAppend_yco params:nil];
    NSString *string = [NSString stringWithFormat:@"%@",[model toDescription]];
    NSData *body = [string dataUsingEncoding:NSUTF8StringEncoding];
    [YYRequestHelp executeRequest:YES headers:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error) {
            NSString *orderCode = responseObject;
            block(rspStatusAndMessage,orderCode,error);
        }else{
            block(rspStatusAndMessage,nil,error);
        }
    }];
}

/**
 *
 *废弃付款记录
 *
 */
+ (void)discardPayment:(NSInteger )payId  andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,NSError *error))block{
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kPaymentDiscard];
    
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kPaymentDiscard params:nil];
    NSString *string = [NSString stringWithFormat:@"id=%ld",(long)payId];
    NSData *body = [string dataUsingEncoding:NSUTF8StringEncoding];
    [YYRequestHelp executeRequest:YES headers:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error) {
            block(rspStatusAndMessage,error);
        }else{
            block(rspStatusAndMessage,error);
        }
    }];
}

/**
 *
 *确认付款记录
 *
 */
+ (void)confirmPayment:(NSInteger )payId  andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,NSError *error))block{
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kPaymentConfirm];
    
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kPaymentConfirm params:nil];
    NSString *string = [NSString stringWithFormat:@"id=%ld",(long)payId];
    NSData *body = [string dataUsingEncoding:NSUTF8StringEncoding];
    [YYRequestHelp executeRequest:YES headers:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error) {
            block(rspStatusAndMessage,error);
        }else{
            block(rspStatusAndMessage,error);
        }
    }];
}

/**
 *
 *删除付款记录
 *
 */
+ (void)deletePayment:(NSInteger )payId  andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,NSError *error))block{
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kPaymentDelete];
    
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kPaymentDelete params:nil];
    NSString *string = [NSString stringWithFormat:@"id=%ld",(long)payId];
    NSData *body = [string dataUsingEncoding:NSUTF8StringEncoding];
    [YYRequestHelp executeRequest:YES headers:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error) {
            block(rspStatusAndMessage,error);
        }else{
            block(rspStatusAndMessage,error);
        }
    }];
}
@end

//
//  YYUserApi.m
//  Yunejian
//
//  Created by yyj on 15/7/6.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import "YYUserApi.h"

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
#import "YYAddress.h"
#import "YYUserModel.h"
#import "YYDesignerModel.h"
#import "YYLookBookModel.h"
#import "YYBrandInfoModel.h"
#import "YYBuyerListModel.h"
#import "YYIndexPicsModel.h"
#import "YYBuyerStoreModel.h"
#import "YYBuyerDetailModel.h"
#import "YYCountryListModel.h"
#import "YYAddressListModel.h"
#import "YYUserHomePageModel.h"
#import "YYShowroomInfoModel.h"
#import "YYSalesManListModel.h"
#import "YYBuyerBaseInfoModel.h"
#import "YYBuyerAddressListModel.h"
#import "YYBrandIntroductionModel.h"

@implementation YYUserApi
/**
 *
 * 获取买手基础信息
 *
 */
+ (void)getBuyerInfo:(NSNumber *)userId andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYBuyerBaseInfoModel *buyerBaseInfoModel,NSError *error))block{

    NSString *url = [[NSString alloc] initWithFormat:@"%@?userId=%@",kGetBuyerInfo,[userId stringValue]];

    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:url];
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:url params:nil];

    [YYRequestHelp executeRequest:NO headers:dic requestUrl:requestURL requestCount:0 requestBody:nil andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error
            && responseObject) {
            YYBuyerBaseInfoModel *buyerBaseInfoModel = [[YYBuyerBaseInfoModel alloc] initWithDictionary:responseObject error:nil];
            block(rspStatusAndMessage,buyerBaseInfoModel,error);

        }else{
            block(rspStatusAndMessage,nil,error);
        }
    }];
}
/**
 *
 * 用户登录
 * @param username  用户名
 * @param password  密码
 * @param verificationCode  验证码（非必填）
 *
 */
+ (void)loginWithUsername:(NSString *)username password:(NSString *)password  verificationCode:(NSString *)verificationCode andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYUserModel *userModel,NSError *error))block{
    
    // get URL
    //username = @"mattermatters@ymail.com";
    //password = @"m68886661";
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kLogin];
    NSDictionary *dic = nil;
    
    //    if (verificationCode) {
    dic = [YYHttpHeaderManager buildHeadderWithAction:kLogin params:nil];
    //    }
    
    NSString *string = nil;
    if (verificationCode
        && [verificationCode length] > 0) {
        string = [NSString stringWithFormat:kLoginHaveCaptcha_yco,username,password,verificationCode];
    }else{
        string = [NSString stringWithFormat:kLoginNOCaptcha_yco,username,password];
    }
    
    NSData *body = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    [YYRequestHelp executeRequest:YES headers:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error
            && responseObject) {
            YYUserModel *rspDataModel = [[YYUserModel alloc] initWithDictionary:responseObject error:nil];
            block(rspStatusAndMessage,rspDataModel,error);
            
        }else{
            block(rspStatusAndMessage,nil,error);
        }
        
        
    }];
    
}


/**
 *
 * 获取验证码
 *
 */
+ (void)getCaptchaWithBlock:(void (^)(NSData *imageData,NSError *error))block{
    // get URL
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kCaptcha];
    
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kCaptcha params:nil];
    
    [YYRequestHelp executeRequest:YES headers:dic requestUrl:requestURL requestCount:0 requestBody:nil andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        NSData *nsdataFromBase64String = nil;
        if(responseObject != nil){
            NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
            NSString *imgBase64String =[jsonObject objectForKey:@"data"];
            if(imgBase64String){
                nsdataFromBase64String = [[NSData alloc]initWithBase64EncodedString:imgBase64String options:0];
            }
        }
        block(nsdataFromBase64String,error);
    }];
    
}

/**
 *
 * 获取设计师个人信息
 *
 */
+ (void)getDesignerBasicInfoWithBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYDesignerModel *designerModel,NSError *error))block{
    // get URL
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kDesignerBasicInfo];
    
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kDesignerBasicInfo params:nil];
    
    
    [YYRequestHelp executeRequest:YES headers:dic requestUrl:requestURL requestCount:0 requestBody:nil andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error
            && responseObject) {
            YYDesignerModel *designerModel = [[YYDesignerModel alloc] initWithDictionary:responseObject error:nil];
            block(rspStatusAndMessage,designerModel,error);
            
        }else{
            block(rspStatusAndMessage,nil,error);
        }
        
    }];
}


/**
 *
 * 获取品牌信息
 *
 */
+ (void)getDesignerBrandInfoWithBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYBrandInfoModel *brandInfoModel,NSError *error))block{
    // get URL
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kDesignerBrandInfo];
    
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kDesignerBrandInfo params:nil];
    
    
    [YYRequestHelp executeRequest:YES headers:dic requestUrl:requestURL requestCount:0 requestBody:nil andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error
            && responseObject) {
            YYBrandInfoModel *brandInfoModel = [[YYBrandInfoModel alloc] initWithDictionary:responseObject error:nil];
            block(rspStatusAndMessage,brandInfoModel,error);
            
        }else{
            block(rspStatusAndMessage,nil,error);
        }
        
    }];
}
/**
 *
 * 获取Showroom信息
 *
 */
+ (void)getShowroomInfoWithBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYShowroomInfoModel *ShowroomModel,NSError *error))block{
    // get URL
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kShowroomInfo];
    
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kShowroomInfo params:nil];
    
    [YYRequestHelp executeRequest:NO headers:dic requestUrl:requestURL requestCount:0 requestBody:nil andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error
            && responseObject) {
            YYShowroomInfoModel *ShowroomModel = [[YYShowroomInfoModel alloc] initWithDictionary:responseObject error:nil];
            block(rspStatusAndMessage,ShowroomModel,error);
            
        }else{
            block(rspStatusAndMessage,nil,error);
        }
        
    }];
}
/**
 *
 * 获取买手店个人信息
 *
 */
+ (void)getBuyerStorBasicInfoWithBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYBuyerStoreModel *BuyerStoreModel,NSError *error))block{
    // get URL
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kBuyerStorBasicInfo];
    
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kBuyerStorBasicInfo params:nil];
    
    
    [YYRequestHelp executeRequest:YES headers:dic requestUrl:requestURL requestCount:0 requestBody:nil andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error
            && responseObject) {
            YYBuyerStoreModel *BuyerStoreModel = [[YYBuyerStoreModel alloc] initWithDictionary:responseObject error:nil];
            block(rspStatusAndMessage,BuyerStoreModel,error);
            
        }else{
            block(rspStatusAndMessage,nil,error);
        }
        
    }];
}

/**
 *
 * 获取销售代表列表
 *
 */
+ (void)getSalesManListWithBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYSalesManListModel *salesManListModel,NSError *error))block{
    // get URL
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kSalesManList];
    
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kSalesManList params:nil];
    
    
    [YYRequestHelp executeRequest:YES headers:dic requestUrl:requestURL requestCount:0 requestBody:nil andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error
            && responseObject) {
            YYSalesManListModel *salesManListModel = [[YYSalesManListModel alloc] initWithDictionary:responseObject error:nil];
            block(rspStatusAndMessage,salesManListModel,error);
            
        }else{
            block(rspStatusAndMessage,nil,error);
        }
        
    }];
}
+ (void)getSalesManListWithBlockNew:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYSalesManListModel *salesManListModel,NSError *error))block{
    // get URL
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kSalesManListNew];
    
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kSalesManListNew params:nil];
    
    [YYRequestHelp executeRequest:YES headers:dic requestUrl:requestURL requestCount:0 requestBody:nil andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error
            && responseObject) {
            YYSalesManListModel *salesManListModel = [[YYSalesManListModel alloc] initWithDictionary:responseObject error:nil];
            block(rspStatusAndMessage,salesManListModel,error);
            
        }else{
            block(rspStatusAndMessage,nil,error);
        }
        
    }];
}

/**
 *
 * 获取收件地址列表
 *
 */
+ (void)getAddressListWithBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYAddressListModel *addressListModel,NSError *error))block{
    // get URL
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kAddressList];
    
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kAddressList params:nil];
    
    
    [YYRequestHelp executeRequest:YES headers:dic requestUrl:requestURL requestCount:0 requestBody:nil andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error
            && responseObject) {
            YYAddressListModel *addressListModel = [[YYAddressListModel alloc] initWithDictionary:responseObject error:nil];
            block(rspStatusAndMessage,addressListModel,error);
            
        }else{
            block(rspStatusAndMessage,nil,error);
        }
        
    }];
}


/**
 *
 * 修改密码
 *
 */
+ (void)passwdUpdateWithOldPassword:(NSString *)oldPassword nowPassword:(NSString *)nowPassword andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,NSError *error))block{
    // get URL
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kPasswdUpdate];
    
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kPasswdUpdate params:nil];
    NSString *string = [NSString stringWithFormat:kUpdatePassword,oldPassword,nowPassword];
    
    
    NSData *body = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    [YYRequestHelp executeRequest:YES headers:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        
        block(rspStatusAndMessage,error);
        
    }];
}

/**
 *
 * 修改买手用户名或电话
 *
 */
+ (void)updateBuyerUsername:(NSString *)username phone:(NSString *)phone province:(NSString *)province city:(NSString *)city andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,NSError *error))block{
    // get URL
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kUpdateBuyerUsernameOrPhone];
    
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kUpdateBuyerUsernameOrPhone params:nil];
    NSString *string = [NSString stringWithFormat:kUpdateBuyerUsernameOrPhoneParams,username,phone,province,city];
    
    
    NSData *body = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    [YYRequestHelp executeRequest:YES headers:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        
        block(rspStatusAndMessage,error);
        
    }];
}

/**
 *
 * 修改设计师用户名或电话
 *
 */
+ (void)updateDesignerUsername:(NSString *)username phone:(NSString *)phone andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,NSError *error))block{
    // get URL
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kUpdateDesignerUsernameOrPhone];
    
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kUpdateDesignerUsernameOrPhone params:nil];
    NSString *string = [NSString stringWithFormat:kUpdateDesignerUsernameOrPhoneParams,username,phone];
    
    
    NSData *body = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    [YYRequestHelp executeRequest:YES headers:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        
        block(rspStatusAndMessage,error);
        
    }];
}

/**
 *
 * 停用或启用销售代表
 *
 */
+ (void)updateSalesmanStatusWithId:(NSInteger)userId status:(NSInteger)status andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,NSError *error))block{
    // get URL
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kUpdateSalesmanStatuse];
    
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kUpdateSalesmanStatuse params:nil];
    NSString *string = [NSString stringWithFormat:kUpdateSalesmanStatuseParams,(int)userId,(int)status];
    
    
    NSData *body = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    [YYRequestHelp executeRequest:YES headers:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        
        block(rspStatusAndMessage,error);
        
    }];
}

/**
 *
 * 新建销售代表
 *
 */
+ (void)createSellerWithUsername:(NSString *)username email:(NSString *)email password:(NSString *)password andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,NSError *error))block{
    // get URL
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kaddSalesman];
    
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kaddSalesman params:nil];
    NSString *string = [NSString stringWithFormat:kaddSalesmanParams,username,email,password];
    
    
    NSData *body = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    [YYRequestHelp executeRequest:YES headers:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        
        block(rspStatusAndMessage,error);
        
    }];
}

/**
 *
 * 修改买手店铺信息
 *
 */
+ (void)storeUpdateByBuyerStoreModel:(YYBuyerStoreModel *)BuyerStoreModel andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,NSError *error))block{
    // get URL
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kStoreUpdate];
    
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kStoreUpdate params:nil];
    NSString *string = [NSString stringWithFormat:kStoreUpdateParams,BuyerStoreModel.name,BuyerStoreModel.foundYear,objArrayToJSON(BuyerStoreModel.businessBrands),[BuyerStoreModel.priceMin floatValue],[BuyerStoreModel.priceMax floatValue]];
    
    NSData *body = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    [YYRequestHelp executeRequest:YES headers:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        
        block(rspStatusAndMessage,error);
        
    }];
}

/**
 *
 * 添加或修改收件地址
 *
 */
+ (void)createOrModifyAddress:(YYAddress *)address andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,NSError *error))block{
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
    
    
    
    if (address.addressId) {
        requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kModifyAddress];
        dic = [YYHttpHeaderManager buildHeadderWithAction:kModifyAddress params:nil];
        
        string = [NSString stringWithFormat:kModifyAddressParams,_province,_city,address.receiverName,address.receiverPhone,address.detailAddress,address.zipCode,address.defaultShipping?@"true":@"false",[address.addressId intValue],_nation,_nationId,_provinceId,_cityId];
        
    }else{
        requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kAddAddress];
        dic = [YYHttpHeaderManager buildHeadderWithAction:kAddAddress params:nil];
        
        string = [NSString stringWithFormat:kAddAddressParams,_province,_city,address.receiverName,address.receiverPhone,address.detailAddress,address.zipCode,address.defaultShipping?@"true":@"false",_nation,_nationId,_provinceId,_cityId];
        
    }
    string = [NSString stringWithFormat:@"%@&orderCode=0",string];
    NSData *body = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    [YYRequestHelp executeRequest:YES headers:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        
        block(rspStatusAndMessage,error);
        
    }];
}

/**
 *
 * 用户反馈
 *
 */
+ (void)userFeedBack:(NSString *)content andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,NSError *error))block{
    // get URL
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kSubmitFeedback];
    
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kSubmitFeedback params:nil];
    NSString *string = [NSString stringWithFormat:kSubmitFeedbackParams,content];
    
    
    NSData *body = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    [YYRequestHelp executeRequest:YES headers:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        
        block(rspStatusAndMessage,error);
        
    }];
}

/**
 *
 * 首页lookBook和产品介绍
 *
 */
+ (void)getHomePageInfoWithBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYLookBookModel *lookBookModel, YYBrandIntroductionModel *brandIntroductionModel,NSString *logo,NSError *error))block{
    // get URL
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kHomePageInfo];
    
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kHomePageInfo params:nil];
    
    
    [YYRequestHelp executeRequest:YES headers:dic requestUrl:requestURL requestCount:0 requestBody:nil andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error
            && responseObject) {
            YYLookBookModel *lookBookModel = [[YYLookBookModel alloc] initWithDictionary:[responseObject objectForKey:@"lookBook"] error:nil];
            lookBookModel.picUrls = [responseObject objectForKey:@"picUrls"];
            YYBrandIntroductionModel *brandIntroduction = [[YYBrandIntroductionModel alloc] initWithDictionary:[responseObject objectForKey:@"brandIntroduction"] error:nil];
            NSString *logoUrl = [responseObject objectForKey:@"logo"];
            block(rspStatusAndMessage,lookBookModel,brandIntroduction,logoUrl,error);
        }else{
            block(rspStatusAndMessage,nil,nil,nil,error);
        }
        
    }];
}

/**
 *
 * lookBook详情
 *
 */
+ (void)getLookBookInfoWithId:(NSInteger)LookBookId andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYLookBookModel *lookBookModel,NSError *error))block{
    // get URL
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kLookBookInfo];
    
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kLookBookInfo params:nil];
    
    NSString *string = [NSString stringWithFormat:kLookBookDetailParams,[NSNumber numberWithInteger:LookBookId]];
    NSData *body = [string dataUsingEncoding:NSUTF8StringEncoding];
    [YYRequestHelp executeRequest:YES headers:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error
            && responseObject) {
            YYLookBookModel *lookBookModel = [[YYLookBookModel alloc] initWithDictionary:[responseObject objectForKey:@"lookBook"] error:nil];
            lookBookModel.picUrls = [responseObject objectForKey:@"pics"];
            block(rspStatusAndMessage,lookBookModel,error);
        }else{
            block(rspStatusAndMessage,nil,error);
        }
        
    }];
}

/**
 *
 * 更改头像 logo
 *
 */
+(void)modifyLogoWithUrl:(NSString *)url andBlock:(void(^)(YYRspStatusAndMessage *rspStatusAndMessage,NSError *error))block{
    NSString *string = @"";
    NSString *urlstr = @"";
    YYUser *user = [YYUser currentUser];
    if(user.userType == YYUserTypeShowroom||user.userType == YYUserTypeShowroomSub)
    {
        string = [NSString stringWithFormat:@"logo=%@",url];
        urlstr = kShowroomModifyLogoInfo;
    }else
    {
        string = [NSString stringWithFormat:@"logoPath=%@",url];
        urlstr = kModifyLogoInfo;
    }
    
    // get URL
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:urlstr];
    
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:urlstr params:nil];
    
    
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
 * 设计师注册
 *
 */
+(void)registerDesignerWithData:(NSArray *)data andBlock:(void(^)(YYRspStatusAndMessage *rspStatusAndMessage,NSError *error))block{
    NSArray *integrationData = [self integrationWithData:data];
    // get URL
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kRegisterDesigner];
    
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kRegisterDesigner params:nil];
    
    NSString *string = [integrationData componentsJoinedByString:@"&"];
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
+(NSArray *)integrationWithData:(NSArray *)data{
    NSMutableArray *realdata = [data mutableCopy];
    NSString *paramsPhoneValue = @"";
    NSInteger paramsPhoneIndex = 0;
    BOOL paramsPhoneIsExist = NO;
    for (int i = 0; i < realdata.count; i ++ ) {
        NSString *paramsStr = realdata[i];
        NSArray *tempArr = [paramsStr componentsSeparatedByString:@"="];
        if(tempArr.count>1){
            if([tempArr[0] isEqualToString:@"phone"]){
                paramsPhoneIndex = i;
                paramsPhoneIsExist = YES;
                paramsPhoneValue = tempArr[1];
            }
        }
    }
    if(paramsPhoneIsExist){
        [realdata removeObjectAtIndex:paramsPhoneIndex];
        NSString *tempPhoneParamsStr = [[NSString alloc] initWithFormat:@"phone=%@",paramsPhoneValue];
        NSString *phoneParamsStr = [tempPhoneParamsStr stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
        [realdata addObject:phoneParamsStr];
    }
    return [realdata copy];
}
/**
 *
 * 买手注册
 *
 */
+(void)registerBuyerWithData:(NSArray *)data andBlock:(void(^)(YYRspStatusAndMessage *rspStatusAndMessage,NSError *error))block{
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kRegisterBuyer];
    
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kRegisterBuyer params:nil];
    
    NSString *string = [data componentsJoinedByString:@"&"];
    
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
 * 买手店提交审核信息
 *
 */
+(void)checkBuyerWithData:(NSArray *)data andBlock:(void(^)(YYRspStatusAndMessage *rspStatusAndMessage,NSError *error))block{
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kUploadCertInfo];
    
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kUploadCertInfo params:nil];
    
    NSString *string = [data componentsJoinedByString:@"&"];
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
 * 发送订单到邮箱
 *
 */
+(void)sendOrderByMail:(NSString *)email andCode:(NSString *)orderCode andBlock:(void(^)(YYRspStatusAndMessage *rspStatusAndMessage,NSError *error))block{
    // get URL
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kSendOrderByMail];
    
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kSendOrderByMail params:nil];
    
    NSString *string = [NSString stringWithFormat:@"email=%@&orderCode=%@",email,orderCode];
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
 * 重发账户邮件确认邮件
 *
 */
+(void)reSendMailConfirmMail:(NSString *)email andUserType:(NSString *)type andBlock:(void(^)(YYRspStatusAndMessage *rspStatusAndMessage,NSError *error))block{
    // get URL
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kReSendMailConfirmMail];
    
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kReSendMailConfirmMail params:nil];
    
    NSString *string = [NSString stringWithFormat:@"email=%@&userType=%@",email,type];
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
 * 上传品牌审核文件
 *
 */
+(void) uploadBrandFiles:(NSString *)brandFiles andBlock:(void(^)(YYRspStatusAndMessage *rspStatusAndMessage,NSInteger errorCode,NSError *error))block{
    // get URL
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kUploadBrandFiles];
    
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kUploadBrandFiles params:nil];
    
    NSString *string = [NSString stringWithFormat:@"brandFiles=%@",brandFiles];
    NSData *body = [string dataUsingEncoding:NSUTF8StringEncoding];
    [YYRequestHelp executeRequest:YES headers:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error) {
            NSInteger errorCode = YYReqStatusCode100;
            if([responseObject objectForKey:@"data"] != nil){
                errorCode =[[responseObject objectForKey:@"data"] integerValue];
            }
            block(rspStatusAndMessage,errorCode,error);
        }else{
            block(rspStatusAndMessage,YYReqStatusCode203,error);
        }
        
    }];
}

/**
 *
 * 按条件查询所有买手店
 *
 */
+(void) queryBuyer:(NSString *)queryStr andBlock:(void(^)(YYRspStatusAndMessage *rspStatusAndMessage,YYBuyerListModel *buyerList,NSError *error))block{
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kBuyerList];
    
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kBuyerList params:nil];
    NSString *string = [NSString stringWithFormat:@"queryStr=%@",queryStr];
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


/**
 *
 * 获取收件地址列表
 *
 */
+ (void)getAddressListWithID:(NSInteger)buyerId pageIndex:(int)pageIndex pageSize:(int)pageSize andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYBuyerAddressListModel *addressListModel,NSError *error))block{
    // get URL
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kBuyerAddressList];
    
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kBuyerAddressList params:nil];
    
    NSString *string = [NSString stringWithFormat:@"buyerId=%ld&pageIndex=%i&pageSize=%i",(long)buyerId,pageIndex,pageSize];
    NSData *body = [string dataUsingEncoding:NSUTF8StringEncoding];
    [YYRequestHelp executeRequest:YES headers:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error
            && responseObject) {
            YYBuyerAddressListModel *addressListModel = [[YYBuyerAddressListModel alloc] initWithDictionary:responseObject error:nil];
            block(rspStatusAndMessage,addressListModel,error);
            
        }else{
            block(rspStatusAndMessage,nil,error);
        }
        
    }];
}

+ (void)getAddressListWithPageIndex:(int)pageIndex pageSize:(int)pageSize andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYBuyerAddressListModel *addressListModel,NSError *error))block{
    // get URL
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kAddressList];
    
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kAddressList params:nil];
    
    
    [YYRequestHelp executeRequest:YES headers:dic requestUrl:requestURL requestCount:0 requestBody:nil andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error
            && responseObject) {
            YYBuyerAddressListModel *addressListModel = [[YYBuyerAddressListModel alloc] initWithDictionary:responseObject error:nil];
            block(rspStatusAndMessage,addressListModel,error);
            
        }else{
            block(rspStatusAndMessage,nil,error);
        }
        
    }];
}

/**
 *
 * 设计师查询买手店详情
 *
 */
+ (void)getBuyerDetailInfoWithID:(NSInteger)buyerId andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYBuyerDetailModel *buyerModel,NSError *error))block{
    // get URL
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kBuyerPubInfoNew];
    
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kBuyerPubInfoNew params:nil];
    
    NSString *string = [NSString stringWithFormat:@"buyerId=%ld",(long)buyerId];
    NSData *body = [string dataUsingEncoding:NSUTF8StringEncoding];
    [YYRequestHelp executeRequest:YES headers:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error
            && responseObject) {
            YYBuyerDetailModel *buyerModel = [[YYBuyerDetailModel alloc] initWithDictionary:responseObject error:nil];
            block(rspStatusAndMessage,buyerModel,error);
            
        }else{
            block(rspStatusAndMessage,nil,error);
        }
        
    }];
}

+ (void)getBuyerDetailStateWithID:(NSInteger)buyerId andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYBuyerDetailModel *buyerModel,NSError *error))block{
    // get URL
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kBuyerPubInfo];
    
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kBuyerPubInfo params:nil];
    
    NSString *string = [NSString stringWithFormat:@"buyerId=%ld",(long)buyerId];
    NSData *body = [string dataUsingEncoding:NSUTF8StringEncoding];
    [YYRequestHelp executeRequest:YES headers:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error
            && responseObject) {
            YYBuyerDetailModel *buyerModel = [[YYBuyerDetailModel alloc] initWithDictionary:responseObject error:nil];
            block(rspStatusAndMessage,buyerModel,error);
            
        }else{
            block(rspStatusAndMessage,nil,error);
        }
        
    }];
}
/**
 *
 * 首页品牌介绍
 *
 */
+ (void)getHomePageBrandInfoWithBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYUserHomePageModel *homePageModel,NSError *error))block{
    // get URL
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kHomePageInfoNew];
    
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kHomePageInfoNew params:nil];
    
    
    [YYRequestHelp executeRequest:YES headers:dic requestUrl:requestURL requestCount:0 requestBody:nil andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error
            && responseObject) {
            YYUserHomePageModel *homePageModel = [[YYUserHomePageModel alloc] initWithDictionary:responseObject error:nil];
            block(rspStatusAndMessage,homePageModel,error);
        }else{
            block(rspStatusAndMessage,nil,error);
        }
        
    }];
}

/**
 *
 * 首页图集
 *
 */
+ (void)getHomePagePics:(NSInteger)designerId andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYIndexPicsModel *picsModel,NSError *error))block{
    // get URL
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kHomePageIndexPics];
    
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kHomePageIndexPics params:nil];
    
    NSString *string = [NSString stringWithFormat:@"designerId=%ld",(long)designerId];
    NSData *body = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    [YYRequestHelp executeRequest:YES headers:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error
            && responseObject) {
            YYIndexPicsModel *picsModel = [[YYIndexPicsModel alloc] initWithDictionary:responseObject error:nil];
            
            block(rspStatusAndMessage,picsModel,error);
        }else{
            block(rspStatusAndMessage,nil,error);
        }
        
    }];
}

/**
 *
 * 更新产品介绍
 *
 */
+(void)updateBrandWithData:(NSDictionary *)params andBlock:(void(^)(YYRspStatusAndMessage *rspStatusAndMessage,NSError *error))block{
    
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kHomeUpdateBrandInfoNew];
    NSDictionary *headParams = [YYHttpHeaderManager buildHeadderWithAction:kHomeUpdateBrandInfoNew params:nil];
    NSData *body = [params mj_JSONData];

    [YYRequestHelp executeRequest:YES headers:headParams requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
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
 * 新建（修改）首页图集
 *
 */
+(void)updateHomePagePicsWithData:(NSArray *)data andBlock:(void(^)(YYRspStatusAndMessage *rspStatusAndMessage,NSError *error))block{
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kHomeUpdateIndexPics];
    
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kHomeUpdateIndexPics params:nil];
    NSString *picsStr = [data componentsJoinedByString:@","];
    NSString *string = [NSString stringWithFormat:@"pics=%@",picsStr];
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
 * 用户状态
 *
 */
+(void)getUserStatus:(NSInteger)userId andBlock:(void(^)(YYRspStatusAndMessage *rspStatusAndMessage, NSInteger status,NSError *error))block{
    // get URL
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kUserStatus];
    
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kUserStatus params:nil];
    NSData *body =nil;
    if(userId >-1){
        NSString *string = [NSString stringWithFormat:@"userId=%ld",(long)userId];
        body = [string dataUsingEncoding:NSUTF8StringEncoding];
    }
    [YYRequestHelp executeRequest:YES headers:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error
            && responseObject) {
            NSInteger status = [responseObject integerValue];
            block(rspStatusAndMessage,status,error);
        }else{
            block(rspStatusAndMessage,-1,error);
        }
        
    }];
}

/**
 *
 *忘记密码
 *
 */
+(void)forgetPassword:(NSString *)email andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,NSError *error))block{
    // get URL
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kForgetPassword];
    
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kForgetPassword params:nil];
    NSString *string = [NSString stringWithFormat:@"%@",email];//
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
 * 获取下级信息（国家之下）
 *
 */
+ (void)getSupCountryInfo:(NSInteger )impId WithBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYCountryListModel *countryListModel,NSError *error))block{
    
    // get URL
    NSString *url = [[NSString alloc] initWithFormat:@"%@?parent=%ld",kCountryInfo,impId];
    
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:url];
    
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:url params:nil];
    
    [YYRequestHelp executeRequest:NO headers:dic requestUrl:requestURL requestCount:0 requestBody:nil andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error
            && responseObject) {
            YYCountryListModel *CountryListModel = [[YYCountryListModel alloc] initWithDictionary:responseObject error:nil];
            block(rspStatusAndMessage,CountryListModel,error);
            
        }else{
            block(rspStatusAndMessage,nil,error);
        }
        
    }];
}

/**
 *
 * 获取国家信息
 *
 */
+ (void)getCountryInfoWithBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYCountryListModel *countryListModel,NSError *error))block{
    // get URL
    
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kCountryInfo];
    
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kCountryInfo params:nil];
    
    [YYRequestHelp executeRequest:NO headers:dic requestUrl:requestURL requestCount:0 requestBody:nil andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error
            && responseObject) {
            YYCountryListModel *CountryListModel = [[YYCountryListModel alloc] initWithDictionary:responseObject error:nil];
            block(rspStatusAndMessage,CountryListModel,error);
            
        }else{
            block(rspStatusAndMessage,nil,error);
        }
        
    }];
}

/**
 *
 * 获取下级信息（国家之下）
 *
 */
+ (void)getSubCountryInfoWithCountryID:(NSInteger )impId WithBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYCountryListModel *countryListModel,NSInteger impId,NSError *error))block{
    
    // get URL
    NSString *url = [[NSString alloc] initWithFormat:@"%@?parent=%ld",kCountryInfo,impId];
    
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:url];
    
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:url params:nil];
    
    [YYRequestHelp executeRequest:NO headers:dic requestUrl:requestURL requestCount:0 requestBody:nil andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error
            && responseObject) {
            YYCountryListModel *CountryListModel = [[YYCountryListModel alloc] initWithDictionary:responseObject error:nil];
            block(rspStatusAndMessage,CountryListModel,impId,error);
            
        }else{
            block(rspStatusAndMessage,nil,impId,error);
        }
        
    }];
}

/**
 * 切换语言 保存到服务器
 */
+(void)setLanguageToServer:(ELanguage )Language andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,NSError *error))block{
    
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kSwitchLang];
    
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kSwitchLang params:nil];
    
    NSString *lang = @"cn";
    if(Language == ELanguageEnglish){
        lang = @"en";
    }
    
    NSString *string = [NSString stringWithFormat:@"lang=%@",lang];
    
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
@end

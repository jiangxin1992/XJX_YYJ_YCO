//
//  RequestBodyMacro.m
//  yunejianDesigner
//
//  Created by yyj on 2017/8/1.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RequestBodyMacro.h"


#pragma mark - 账户相关
/** 没有验证码的登录 */
NSString * const kLoginNOCaptcha_brand = @"email=%@&password=%@&type=tbPhoneDesignerApp";
NSString * const kLoginNOCaptcha_buyer = @"email=%@&password=%@&type=tbPhoneBuyerApp";
NSString * const kLoginNOCaptcha_yco = @"email=%@&password=%@&type=tbPadDesignerApp";
/** 有验证码的登录 */
NSString * const kLoginHaveCaptcha_brand = @"email=%@&password=%@&captcha=%@&type=tbPhoneDesignerApp";
NSString * const kLoginHaveCaptcha_buyer = @"email=%@&password=%@&captcha=%@&type=tbPhoneBuyerApp";
NSString * const kLoginHaveCaptcha_yco = @"email=%@&password=%@&captcha=%@&type=tbPadDesignerApp";
/** 修改密码 */
NSString * const kUpdatePassword = @"oldPassword=%@&newPassword=%@";
/** 修改买手用户名或电话 */
NSString * const kUpdateBuyerUsernameOrPhoneParams = @"name=%@&phone=%@&province=%@&city=%@";
/** 修改设计师用户名或电话 */
NSString * const kUpdateDesignerUsernameOrPhoneParams = @"userName=%@&phone=%@";
/** 停用或启用销售代表 */
NSString * const kUpdateSalesmanStatuseParams = @"salesmanId=%i&opType=%i";
/** 新建销售代表 */
NSString * const kaddSalesmanParams = @"name=%@&email=%@&password=%@";
/** 新建Showroom子账号 */
NSString * const kaddSubShowroomParams = @"name=%@&email=%@&passWord=%@";
/** 修改设计师品牌信息 */
NSString * const kBrandInfoUpdateParams = @"brandName=%@&webUrl=%@&underlinePartnerCount=%i&annualSales=%f&retailerName=%@";
/** 修改买手店品牌信息 */
NSString * const kStoreUpdateParams = @"name=%@&foundYear=%@&businessBrands=%@&priceMin=%f&priceMax=%f";
/** 修改收件地址 */
NSString * const kModifyAddressParams = @"province=%@&city=%@&receiverName=%@&receiverPhone=%@&detailAddress=%@&zipCode=%@&default=%@&addressId=%i&nation=%@&nationId=%@&provinceId=%@&cityId=%@";
/** 修改收件地址，不是默认地址 */
NSString * const kModifyAddressParamsNoDefault = @"province=%@&city=%@&receiverName=%@&receiverPhone=%@&detailAddress=%@&zipCode=%@&addressId=%i&nation=%@&nationId=%@&provinceId=%@&cityId=%@";
/** 添加收件地址 */
NSString * const kAddAddressParams = @"province=%@&city=%@&receiverName=%@&receiverPhone=%@&detailAddress=%@&zipCode=%@&default=%@&nation=%@&nationId=%@&provinceId=%@&cityId=%@";
/** 添加收件地址，不是默认地址 */
NSString * const kAddAddressParamsNoDefault = @"province=%@&city=%@&receiverName=%@&receiverPhone=%@&detailAddress=%@&zipCode=%@&nation=%@&nationId=%@&provinceId=%@&cityId=%@";
/** 用户反馈 */
NSString * const kSubmitFeedbackParams = @"content=%@";
/** lookbook详情 */
NSString * const kLookBookDetailParams = @"lookBookId=%@";


#pragma mark - 作品相关
NSString * const kSeriesListParams_brand = @"designerId=%i&pageIndex=%i&pageSize=%i&withDraft=false";
NSString * const kSeriesListParams_buyer = @"designerId=%i&pageIndex=%i&pageSize=%i&withDraft=false";
NSString * const kSeriesListParams_yco = @"designerId=%i&pageIndex=%i&pageSize=%i&withDraft=%@";
NSString * const kSeriesListParams1 = @"designerId=%i&pageIndex=%i&pageSize=%i&withDraft=%@";
NSString * const kHomeSeriesListParams = @"pageIndex=%i&pageSize=%i&withDraft=false";


#pragma mark - 订单相关
/** 根据订单编号获取订单 */
NSString * const kOrderInfoParams = @"orderCode=%@&stock=%@";
/** 创建或修改订单 */
NSString * const kOrderCreateOrModifyParams_brand = @"orderInfoJsonStr=%@";
NSString * const kOrderCreateOrModifyParams_buyer = @"orderInfoJsonStr=%@";
NSString * const kOrderCreateOrModifyParams_yco = @"%@"; //orderInfoJsonStr=
/** 修改买手收件地址 */
NSString * const kModifyBuyerAddressParams = @"province=%@&city=%@&receiverName=%@&receiverPhone=%@&detailAddress=%@&zipCode=%@&addressId=%i&nation=%@&nationId=%@&provinceId=%@&cityId=%@";
/** 添加买手收件地址 */
NSString * const kAddBuyerAddressParams = @"province=%@&city=%@&receiverName=%@&receiverPhone=%@&detailAddress=%@&zipCode=%@&nation=%@&nationId=%@&provinceId=%@&cityId=%@";
/** 修改订单标记状态 */
NSString * const kUpdateOrderStatusMarkParams = @"orderCode=%@&statusType=%i&opType=%i";
/** 获取订单所有标记状态 */
NSString * const kGetOrderStatusMarksParams = @"orderCode=%@";


//
//  RequestBodyMacro.h
//  Yunejian
//
//  Created by yyj on 15/7/7.
//  Copyright (c) 2015年 yyj. All rights reserved.
//
#import <UIKit/UIKit.h>

#ifndef Yunejian_RequestBodyMacro_h
#define Yunejian_RequestBodyMacro_h


#pragma mark - 账户相关
/** 没有验证码的登录 */
UIKIT_EXTERN NSString * const kLoginNOCaptcha_brand;
UIKIT_EXTERN NSString * const kLoginNOCaptcha_buyer;
UIKIT_EXTERN NSString * const kLoginNOCaptcha_yco;
/** 有验证码的登录 */
UIKIT_EXTERN NSString * const kLoginHaveCaptcha_brand;
UIKIT_EXTERN NSString * const kLoginHaveCaptcha_buyer;
UIKIT_EXTERN NSString * const kLoginHaveCaptcha_yco;
/** 修改密码 */
UIKIT_EXTERN NSString * const kUpdatePassword;
/** 修改买家用户名或电话 */
UIKIT_EXTERN NSString * const kUpdateBuyerUsernameOrPhoneParams;
/** 修改设计师用户名或电话 */
UIKIT_EXTERN NSString * const kUpdateDesignerUsernameOrPhoneParams;
/** 停用或启用销售代表 */
UIKIT_EXTERN NSString * const kUpdateSalesmanStatuseParams;
/** 新建销售代表 */
UIKIT_EXTERN NSString * const kaddSalesmanParams;
/** 新建Showroom子账号 */
UIKIT_EXTERN NSString * const kaddSubShowroomParams;
/** 修改设计师品牌信息 */
UIKIT_EXTERN NSString * const kBrandInfoUpdateParams;
/** 修改买手店品牌信息 */
UIKIT_EXTERN NSString * const kStoreUpdateParams;
/** 修改收货地址 */
UIKIT_EXTERN NSString * const kModifyAddressParams;
/** 修改收货地址，不是默认地址 */
UIKIT_EXTERN NSString * const kModifyAddressParamsNoDefault;
/** 添加收货地址 */
UIKIT_EXTERN NSString * const kAddAddressParams;
/** 添加收货地址，不是默认地址 */
UIKIT_EXTERN NSString * const kAddAddressParamsNoDefault;
/** 用户反馈 */
UIKIT_EXTERN NSString * const kSubmitFeedbackParams;
/** lookbook详情 */
UIKIT_EXTERN NSString * const kLookBookDetailParams;


#pragma mark - 作品相关
UIKIT_EXTERN NSString * const kSeriesListParams_brand;
UIKIT_EXTERN NSString * const kSeriesListParams_buyer;
UIKIT_EXTERN NSString * const kSeriesListParams_yco;
UIKIT_EXTERN NSString * const kSeriesListParams1;
UIKIT_EXTERN NSString * const kHomeSeriesListParams;


#pragma mark - 订单相关
/** 根据订单编号获取订单 */
UIKIT_EXTERN NSString * const kOrderInfoParams;
/** 创建或修改订单 */
UIKIT_EXTERN NSString * const kOrderCreateOrModifyParams_brand;
UIKIT_EXTERN NSString * const kOrderCreateOrModifyParams_buyer;
UIKIT_EXTERN NSString * const kOrderCreateOrModifyParams_yco;
/** 修改买家收货地址 */
UIKIT_EXTERN NSString * const kModifyBuyerAddressParams;
/** 添加买家收货地址 */
UIKIT_EXTERN NSString * const kAddBuyerAddressParams;
/** 修改订单标记状态 */
UIKIT_EXTERN NSString * const kUpdateOrderStatusMarkParams;
/** 获取订单所有标记状态 */
UIKIT_EXTERN NSString * const kGetOrderStatusMarksParams;


#endif

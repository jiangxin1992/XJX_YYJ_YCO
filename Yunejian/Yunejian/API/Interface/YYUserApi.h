//
//  YYUserApi.h
//  Yunejian
//
//  Created by yyj on 15/7/6.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import <Foundation/Foundation.h>

@class YYUserModel,YYDesignerModel,YYBrandInfoModel,YYBuyerStoreModel,YYSalesManListModel,YYLookBookModel,YYBrandIntroductionModel,YYLookBookListModel,YYUserHomePageModel,YYShowroomInfoModel;
#import "YYRspStatusAndMessage.h"
#import "YYAddressListModel.h"
#import "YYAddress.h"
#import "YYBuyerAddressListModel.h"
#import "YYBuyerListModel.h"
#import "YYBuyerAddressListModel.h"
#import "YYBuyerDetailModel.h"
#import "YYHomePageModel.h"
#import "YYIndexPicsModel.h"
#import "YYCountryListModel.h"

@interface YYUserApi : NSObject

/**
 *
 * 用户登录
 * @param username  用户名
 * @param password  密码
 * @param verificationCode  验证码（非必填）
 *
 */
+ (void)loginWithUsername:(NSString *)username password:(NSString *)password  verificationCode:(NSString *)verificationCode andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYUserModel *userModel,NSError *error))block;

/**
 *
 * 获取验证码
 *
 */
+ (void)getCaptchaWithBlock:(void (^)(NSData *imageData,NSError *error))block;

/**
 *
 * 获取设计师个人信息
 *
 */
+ (void)getDesignerBasicInfoWithBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYDesignerModel *designerModel,NSError *error))block;

/**
 *
 * 获取品牌信息
 *
 */
+ (void)getDesignerBrandInfoWithBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYBrandInfoModel *brandInfoModel,NSError *error))block;
/**
 *
 * 获取Showroom信息
 *
 */
+ (void)getShowroomInfoWithBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYShowroomInfoModel *ShowroomModel,NSError *error))block;

/**
 *
 * 获取买手店个人信息
 *
 */
+ (void)getBuyerStorBasicInfoWithBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYBuyerStoreModel *BuyerStoreModel,NSError *error))block;

/**
 *
 * 获取销售代表列表
 *
 */
+ (void)getSalesManListWithBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYSalesManListModel *salesManListModel,NSError *error))block;
+ (void)getSalesManListWithBlockNew:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYSalesManListModel *salesManListModel,NSError *error))block;

/**
 *
 * 获取收货地址列表
 *
 */
+ (void)getAddressListWithBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYAddressListModel *addressListModel,NSError *error))block;
/**
 *
 * 修改密码
 *
 */
+ (void)passwdUpdateWithOldPassword:(NSString *)oldPassword nowPassword:(NSString *)nowPassword andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,NSError *error))block;

/**
 *
 * 修改买家用户名或电话
 *
 */
+ (void)updateBuyerUsername:(NSString *)username phone:(NSString *)phone province:(NSString *)province city:(NSString *)city andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,NSError *error))block;

/**
 *
 * 修改设计师用户名或电话
 *
 */
+ (void)updateDesignerUsername:(NSString *)username phone:(NSString *)phone andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,NSError *error))block;

/**
 *
 * 停用或启用销售代表
 *
 */
+ (void)updateSalesmanStatusWithId:(NSInteger)userId status:(NSInteger)status andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,NSError *error))block;


/**
 *
 * 新建销售代表
 *
 */
+ (void)createSellerWithUsername:(NSString *)username email:(NSString *)email password:(NSString *)password andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,NSError *error))block;

/**
 *
 * 修改买家店铺信息
 *
 */
+ (void)storeUpdateByBuyerStoreModel:(YYBuyerStoreModel *)BuyerStoreModel andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,NSError *error))block;


/**
 *
 * 添加或修改收货地址
 *
 */
+ (void)createOrModifyAddress:(YYAddress *)address andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,NSError *error))block;

/**
 *
 * 用户反馈
 *
 */
+ (void)userFeedBack:(NSString *)content andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,NSError *error))block;

/**
 *
 * 首页lookBook和产品介绍
 *
 */
+ (void)getHomePageInfoWithBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYLookBookModel *lookBookModel, YYBrandIntroductionModel *brandIntroductionModel,NSString *logo,NSError *error))block;

/**
 *
 * lookBook详情
 *
 */
+ (void)getLookBookInfoWithId:(NSInteger)LookBookId andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYLookBookModel *lookBookModel,NSError *error))block;

/**
 *
 * 更改头像 logo
 *
 */
+(void)modifyLogoWithUrl:(NSString *)url andBlock:(void(^)(YYRspStatusAndMessage *rspStatusAndMessage,NSError *error))block;

/**
 *
 * 设计师注册
 *
 */
+(void)registerDesignerWithData:(NSArray *)data andBlock:(void(^)(YYRspStatusAndMessage *rspStatusAndMessage,NSError *error))block;


/**
 *
 * 买家注册
 *
 */
+(void)registerBuyerWithData:(NSArray *)data andBlock:(void(^)(YYRspStatusAndMessage *rspStatusAndMessage,NSError *error))block;


/**
 *
 * 买手店提交审核信息
 *
 */
+(void)checkBuyerWithData:(NSArray *)data andBlock:(void(^)(YYRspStatusAndMessage *rspStatusAndMessage,NSError *error))block;


/**
 *
 * 发送订单到邮箱
 *
 */
+(void)sendOrderByMail:(NSString *)email andCode:(NSString *)orderCode andBlock:(void(^)(YYRspStatusAndMessage *rspStatusAndMessage,NSError *error))block;

/**
 *
 * 重发账户邮件确认邮件
 *
 */
+(void)reSendMailConfirmMail:(NSString *)email andUserType:(NSString *)type andBlock:(void(^)(YYRspStatusAndMessage *rspStatusAndMessage,NSError *error))block;

/**
 *
 * 上传品牌审核文件
 *
 */
+(void) uploadBrandFiles:(NSString *)brandFiles andBlock:(void(^)(YYRspStatusAndMessage *rspStatusAndMessage,NSInteger errorCode,NSError *error))block;

/**
 *
 * 按条件查询所有买手店
 *
 */
+(void) queryBuyer:(NSString *)queryStr andBlock:(void(^)(YYRspStatusAndMessage *rspStatusAndMessage,YYBuyerListModel *buyerList,NSError *error))block;

/**
 *
 * 获取收货地址列表
 *
 */
+ (void)getAddressListWithID:(NSInteger)buyerId pageIndex:(int)pageIndex pageSize:(int)pageSize andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYBuyerAddressListModel *addressListModel,NSError *error))block;
+ (void)getAddressListWithPageIndex:(int)pageIndex pageSize:(int)pageSize andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYBuyerAddressListModel *addressListModel,NSError *error))block;


/**
 *
 * 设计师查询买手店详情
 *
 */
+ (void)getBuyerDetailInfoWithID:(NSInteger)buyerId andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYBuyerDetailModel *buyerModel,NSError *error))block;

+ (void)getBuyerDetailStateWithID:(NSInteger)buyerId andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYBuyerDetailModel *buyerModel,NSError *error))block;
/**
 *
 * 首页品牌介绍
 *
 */
+ (void)getHomePageBrandInfoWithBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYUserHomePageModel *homePageModel,NSError *error))block;

/**
 *
 * 首页图集
 *
 */
+ (void)getHomePagePics:(NSInteger)designerId andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYIndexPicsModel *picsModel,NSError *error))block;

/**
 *
 * 更新产品介绍
 *
 */
//+(void)updateBrandWithData:(NSArray *)data andBlock:(void(^)(YYRspStatusAndMessage *rspStatusAndMessage,NSError *error))block;
+(void)updateBrandWithData:(NSDictionary *)params andBlock:(void(^)(YYRspStatusAndMessage *rspStatusAndMessage,NSError *error))block;

/**
 *
 * 新建（修改）首页图集
 *
 */
+(void)updateHomePagePicsWithData:(NSArray *)data andBlock:(void(^)(YYRspStatusAndMessage *rspStatusAndMessage,NSError *error))block;

/**
 *
 * 用户状态
 *
 */
+(void)getUserStatus:(NSInteger)userId andBlock:(void(^)(YYRspStatusAndMessage *rspStatusAndMessage, NSInteger status,NSError *error))block;
/**
 *
 *忘记密码
 *
 */
+(void)forgetPassword:(NSString *)email andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,NSError *error))block;

/**
 *
 * 获取国家信息
 *
 */
+ (void)getCountryInfoWithBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYCountryListModel *countryListModel,NSError *error))block;

/**
 *
 * 获取下级信息（国家之下）
 *
 */
+ (void)getSupCountryInfo:(NSInteger )impId WithBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYCountryListModel *countryListModel,NSError *error))block;

/**
 *
 * 获取下级信息（国家之下）
 *
 */
+ (void)getSubCountryInfoWithCountryID:(NSInteger )impId WithBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYCountryListModel *countryListModel,NSInteger impId,NSError *error))block;


/**
 * 切换语言 保存到服务器
 */
+(void)setLanguageToServer:(ELanguage )Language andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,NSError *error))block;

@end

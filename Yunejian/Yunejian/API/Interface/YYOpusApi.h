//
//  YYOpusApi.h
//  Yunejian
//
//  Created by yyj on 15/7/23.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "YYRspStatusAndMessage.h"

@class YYOpusSeriesListModel,YYOpusStyleListModel,YYStyleInfoModel,YYSeriesInfoDetailModel,YYOpusSeriesAuthTypeBuyerListModel,YYUserHomePageModel;

@interface YYOpusApi : NSObject

/**
 *
 * 判断是否存在多币种
 *
 */
+ (void)hasMultiCurrencyWithSeriesId:(NSInteger)seriesId andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,BOOL hasMultiCurrency,NSError *error))block;

/**
 *
 * 获取设计师系列列表
 *
 */
+ (void)getSeriesListWithId:(int)designerId pageIndex:(int)pageIndex pageSize:(int)pageSize withDraft:(NSString*)draft andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYOpusSeriesListModel *opusSeriesListModel,NSError *error))block;

/**
 *
 * 分享系列
 *
 */
+ (void)sendlineSheetWithHomePageModel:(YYUserHomePageModel *)homePageMode withSeriesId:(NSInteger)seriesId withEmail:(NSString *)email andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,NSError *error))block;

/**
 *
 * 获取设计师系列中款式列表
 *
 */
+ (void)getStyleListWithDesignerId:(NSInteger )designerId seriesId:(NSInteger )seriesId orderBy:(NSString *)orderBy queryStr:(NSString *)queryStr pageIndex:(NSInteger )pageIndex pageSize:(NSInteger )pageSize andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYOpusStyleListModel *opusStyleListModel,NSError *error))block;

/**
 *
 * 获取款式详情
 *
 */
+ (void)getStyleInfoByStyleId:(long)styleId orderCode:(NSString*)orderCode andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYStyleInfoModel *styleInfoModel,NSError *error))block;

/**
 *
 * 获取设计师订单可用系列列表
 *
 */
+ (void)getSeriesListWithOrderCode:(NSString*)orderCode pageIndex:(int)pageIndex pageSize:(int)pageSize andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYOpusSeriesListModel *opusSeriesListModel,NSError *error))block;

/**
 *
 * 买手修改订单可用的款式
 *
 */
+ (void)getStyleListWithOrderCode:(NSString*)orderCode seriesId:(long)seriesId orderBy:(NSString *)orderBy queryStr:(NSString *)queryStr pageIndex:(int)pageIndex pageSize:(int)pageSize andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYOpusStyleListModel *opusStyleListModel,NSError *error))block;


/**
 *
 *合作设计师的系列列表
 *
 */
+ (void)getConnSeriesListWithId:(NSInteger )designerId pageIndex:(NSInteger )pageIndex pageSize:(NSInteger )pageSize andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYOpusSeriesListModel *opusSeriesListModel,NSError *error))block;


/**
 *
 *合作设计师系列详情
 *
 */
+ (void)getConnSeriesInfoWithId:(NSInteger )designerId seriesId:(NSInteger )seriesId andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYSeriesInfoDetailModel *infoDetailModel,NSError *error))block;

/**
 *
 * 合作设计师款式列表（带搜索）
 *
 */
+ (void)getConnStyleListWithDesignerId:(NSInteger )designerId seriesId:(NSInteger )seriesId orderBy:(NSString *)orderBy queryStr:(NSString *)queryStr pageIndex:(int)pageIndex pageSize:(int)pageSize andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYOpusStyleListModel *opusStyleListModel,NSError *error))block;

/**
 *
 * 更改系列权限
 *
 */
+ (void)updateSeriesAuthType:(long)seriesId authType:(NSInteger)authType buyerIds:(NSString*)buyerIds andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,NSError *error))block;

/**
 *
 *设计师系列详情
 *
 */
+ (void)getSeriesInfo:(NSInteger )seriesId andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYSeriesInfoDetailModel *infoDetailModel,NSError *error))block;

/**
 *
 *更改系列发布状态与权限
 *
 */
+ (void)updateSeriesPubStatus:(NSInteger)seriesId status:(NSInteger)status authType:(NSString*)authType buyerIds:(NSString*)buyerIds andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,NSError *error))block;
/**
 *
 *获取系列发布权限名单
 *
 */
+ (void)getSeriesAuthTypeBuyerList:(NSInteger)seriesId  authType:(NSString*)authType andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYOpusSeriesAuthTypeBuyerListModel * buyerList,NSError *error))block;


@end

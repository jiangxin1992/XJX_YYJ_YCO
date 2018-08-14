//
//  AppDelegate.h
//  Yunejian
//
//  Created by yyj on 15/7/3.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YYOrderInfoModel,YYStyleInfoModel,YYOpusStyleModel,YYBrandSeriesToCartTempModel;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (assign, nonatomic) NSInteger leftMenuIndex;//跳转tabIndex
@property (nonatomic,assign) CGFloat keyBoardHeight;
@property (nonatomic,assign) BOOL keyBoardIsShowNow;

@property (nonatomic,assign) NSInteger unreadOrderNotifyMsgAmount;//未读信息数量
@property (nonatomic,assign) NSInteger unreadConnNotifyMsgAmount;//未读信息数量

@property (nonatomic,assign) BOOL isOnOrderNotifyMsgUI;//订单消息界面打开着
@property (nonatomic,assign) BOOL isOnConnNotifyMsgAUI;//关联消息界面打开着

@property (nonatomic, strong) YYOrderInfoModel *cartModel;//购物车对象
@property (nonatomic, strong) NSMutableArray *seriesArray;//系列数组
@property (nonatomic, assign) NSInteger cartMoneyType;//购物车货币类型(只能一种货币才能下单)

@property (nonatomic, strong) YYOrderInfoModel *orderModel;//订单对象，修改订单中的添加款式要用到
@property (nonatomic, strong) NSMutableArray *orderSeriesArray;//订单系列数组，修改订单中的添加款式要用到
@property (strong, nonatomic) YYOrderInfoModel *currentYYOrderInfoModel;//修改订单临时数据

@property (nonatomic, strong) UINavigationController *mainViewController;//首页视图

@property (nonatomic, strong) NSNumber *delegate_series_id;

@property (nonatomic)bool inRunLoop;
@property (strong, nonatomic) NSThread* myThread;

/**
 获取服务端地址
 */
- (void)loadServerInfo;

/**
 清空本地购物车
 */
- (void)clearBuyCar;

/**
 清空delegate下的临时数据
 */
- (void)delegateTempDataClear;

/**
 获取用户未读消息数量，并更新
 */
- (void)checkNoticeCount;

/**
 根据index更新首页的模块视图

 @param index ...
 */
- (void)reloadRootViewController:(NSInteger)index;

/**
 进入主页
 */
- (void)enterMainIndexPage;

/**
 进入登录页面
 */
- (void)enterLoginPage;

- (void)showBuildOrderViewController:(YYOrderInfoModel *)orderInfoModel parent:(UIViewController *)parentViewController isCreatOrder:(Boolean)isCreatOrder isReBuildOrder:(Boolean)isReBuildOrder isAppendOrder:(Boolean)isAppendOrder modifySuccess:(ModifySuccess)modifySuccess;
- (void)showShoppingViewNew:(BOOL )isModifyOrder styleInfoModel:(id )styleInfoModel seriesModel:(id)seriesModel opusStyleModel:(YYOpusStyleModel *)opusStyleModel currentYYOrderInfoModel:(YYOrderInfoModel *)currentYYOrderInfoModel parentView:(UIView *)parentView fromBrandSeriesView:(BOOL )isFromSeries WithBlock:(void (^)(YYBrandSeriesToCartTempModel *brandSeriesToCardTempModel))block;
- (void)showStyleInfoViewController:(YYStyleInfoModel *)infoModel parentViewController:(UIViewController*)viewController IsShowroomToScan:(BOOL)isShowroomToScan;

@end


//
//  YYYellowPanelManage.h
//  Yunejian
//
//  Created by Apple on 15/11/27.
//  Copyright © 2015年 yyj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "YYDiscountViewController.h"

@class YYOrderStyleModel,YYSeriesInfoDetailModel,YYOrderAddMoneyLogController,YYAlertViewController,YYOrderAddressListController,YYDiscountViewController,YYUserCheckAlertViewController,YYOrderStatusRequestCloseViewController,YYOpusSettingViewController,YYSeriesInfoDetailViewController,YYOrderAppendViewController,YYOrderAddStyleRemarkViewController,YYOpusSettingDefinedViewController;

@interface YYYellowPanelManage : NSObject
@property(nonatomic,assign) UIView *parentView;
@property(nonatomic,strong) YYOrderAddMoneyLogController *moneyLogViewContorller;
@property(nonatomic,strong) YYAlertViewController *alertViewController;
@property (nonatomic,strong) YYOrderAddressListController *buyerAddressListController;
@property (nonatomic,strong) YYDiscountViewController *discountViewController;
@property (nonatomic,strong) YYUserCheckAlertViewController *userCheckAlertViewController;
@property (nonatomic,strong) YYOrderStatusRequestCloseViewController *orderStatusRequestCloseViewController;
@property (nonatomic,strong) YYOpusSettingViewController *opusSettingViewController;
@property (nonatomic,strong) YYSeriesInfoDetailViewController *seriesInfoDetailViewController;
@property (nonatomic,strong) YYOrderAppendViewController *orderAppendViewController;
@property (nonatomic,strong) YYOrderAddStyleRemarkViewController *orderAddStyleRemarkViewController;
@property (nonatomic,strong) YYOpusSettingDefinedViewController *opusSettingDefinedViewController;

+ (YYYellowPanelManage *)instance;

-(void)showOrderAddMoneyLogPanel:(NSString *)storyboardName andIdentifier:(NSString *)identifier totalMoney:(double)totalMoney moneyType:(NSInteger)moneyType orderCode:(NSString*)orderCode parentView:(UIView *)specialParentView andCallBack:(void (^)(NSString *orderCode, NSNumber *totalPercent))callback;
-(void)showYellowAlertPanel:(NSString *)storyboardName andIdentifier:(NSString *)identifier title:(NSString*)title msg:(NSString*)msg btn:(NSString*)btnStr align:(NSTextAlignment)textAlignment closeBtn:(BOOL)needCloseBtn andCallBack:(YellowPabelCallBack)callback;
-(void)showSamllYellowAlertPanel:(NSString *)storyboardName andIdentifier:(NSString *)identifier title:(NSString*)title msg:(NSString*)msg btn:(NSString*)btnStr align:(NSTextAlignment)textAlignment closeBtn:(BOOL)needCloseBtn  parentView:(UIView *)specialParentView andCallBack:(YellowPabelCallBack)callback;
-(void)showOrderBuyerAddressListPanel:(NSString *)storyboardName andIdentifier:(NSString *)identifier needUnDefineBuyer:(NSInteger)needUnDefineBuyer parentView:(UIView *)specialParentView andCallBack:(YellowPabelCallBack)callback;
-(void)showStyleDiscountPanel:(NSString *)storyboardName andIdentifier:(NSString *)identifier type:(DiscountType)type orderStyleModel:(YYOrderStyleModel *)orderStyleModel orderInfoModel:(YYOrderInfoModel *)orderInfoModel
        AndSeriesId:(long)seriesId originalPrice:(double)originalPrice finalPrice:(double)finalPrice parentView:(UIView *)specialParentView andCallBack:(YellowPabelCallBack)callback;
-(void)showYellowUserCheckAlertPanel:(NSString *)storyboardName andIdentifier:(NSString *)identifier title:(NSString*)title msg:(NSString*)msg iconStr:(NSString*)iconStr btnStr:(NSString*)btnStr align:(NSTextAlignment)textAlignment closeBtn:(BOOL)needCloseBtn  funArray:(NSArray *)funArray andCallBack:(YellowPabelCallBack)callback;
-(void)showOrderStatusRequestClosePanelWidthParentView:(UIView *)specialParentView currentYYOrderInfoModel:(YYOrderInfoModel *)currentYYOrderInfoModel andCallBack:(YellowPabelCallBack)callback;
-(void)showOpusSettingpanelWidthParentView:(UIView *)specialParentView seriesId:(NSInteger)seriesId andCallBack:(YellowPabelCallBack)callback;
-(void)showSeriesInfoDetailViewWidthParentView:(UIView *)specialParentView info:(YYSeriesInfoDetailModel*)info andCallBack:(YellowPabelCallBack)callback;
-(void)showOrderAppendViewWidthParentView:(UIView *)specialParentView info:(NSArray*)info andCallBack:(YellowPabelCallBack)callback;
-(void)showOrderAddStyleRemarkViewWidthParentView:(UIView *)specialParentView info:(YYOrderStyleModel*)info andCallBack:(YellowPabelCallBack)callback;
-(void)showOpusSettingDefinedViewWidthParentView:(UIViewController *)specialParentView info:(NSArray*)info andCallBack:(YellowPabelCallBack)callback;

@end

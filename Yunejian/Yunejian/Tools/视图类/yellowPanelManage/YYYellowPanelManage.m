//
//  YYYellowPanelManage.m
//  Yunejian
//
//  Created by Apple on 15/11/27.
//  Copyright © 2015年 yyj. All rights reserved.
//

#import "YYYellowPanelManage.h"

// c文件 —> 系统文件（c文件在前）

// 控制器
#import "YYOrderAddMoneyLogController.h"
#import "YYAlertViewController.h"
#import "YYOrderAddressListController.h"
#import "YYUserCheckAlertViewController.h"
#import "YYOrderStatusRequestCloseViewController.h"
#import "YYOpusSettingViewController.h"
#import "YYSeriesInfoDetailViewController.h"
#import "YYOrderAppendViewController.h"
#import "YYOrderAddStyleRemarkViewController.h"
#import "YYOpusSettingDefinedViewController.h"

// 自定义视图

// 接口
#import "YYOrderApi.h"

// 分类

// 自定义类和三方类（ cocoapods类 > model > 工具类 > 其他）
#import "YYSeriesInfoDetailModel.h"
#import "YYOrderStyleModel.h"
#import "YYOrderInfoModel.h"
#import "YYPaymentNoteListModel.h"

#import "AppDelegate.h"

@implementation YYYellowPanelManage
static YYYellowPanelManage *instance = nil;


+(id)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [super allocWithZone:zone];
    });
    return instance;
}

+ (YYYellowPanelManage *)instance
{
    
    if (!instance) {
        instance = [[self alloc] init];
    }
    
    return instance;
}

-(void)showOrderAddMoneyLogPanel:(NSString *)storyboardName andIdentifier:(NSString *)identifier totalMoney:(double)totalMoney moneyType:(NSInteger)moneyType orderCode:(NSString*)orderCode parentView:(UIView *)specialParentView andCallBack:(void (^)(NSString *orderCode, NSNumber *totalPercent))callback{

    WeakSelf(ws);
    [YYOrderApi getPaymentNoteList:orderCode andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYPaymentNoteListModel *paymentNoteList, NSError *error) {

        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:[NSBundle mainBundle]];
        self.moneyLogViewContorller = [storyboard instantiateViewControllerWithIdentifier:identifier];
        self.moneyLogViewContorller.totalMoney = totalMoney;
        self.moneyLogViewContorller.paymentNoteList = paymentNoteList;
        self.moneyLogViewContorller.moneyType = moneyType;
        self.moneyLogViewContorller.orderCode = orderCode;
        WeakSelf(ws);
        UIView *showView = self.moneyLogViewContorller.view;
        __weak UIView *weakShowView = showView;
        [self.moneyLogViewContorller setCancelButtonClicked:^(){
            removeFromSuperviewUseUseAnimateAndDeallocViewController(weakShowView,ws.moneyLogViewContorller);
        }];
        [self.moneyLogViewContorller setModifySuccess:^(NSString *orderCode, NSNumber *totalPercent){
            removeFromSuperviewUseUseAnimateAndDeallocViewController(weakShowView,ws.moneyLogViewContorller);
            callback(orderCode,totalPercent);
        }];
        [self addToWindow:self.moneyLogViewContorller parentView:specialParentView];

    }];

}

-(void)showYellowAlertPanel:(NSString *)storyboardName andIdentifier:(NSString *)identifier title:(NSString*)title msg:(NSString*)msg btn:(NSString*)btnStr align:(NSTextAlignment)textAlignment closeBtn:(BOOL)needCloseBtn andCallBack:(YellowPabelCallBack)callback{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:[NSBundle mainBundle]];
    self.alertViewController= [storyboard instantiateViewControllerWithIdentifier:identifier];
    self.alertViewController.textAlignment = textAlignment;
    self.alertViewController.titelStr = title;
    self.alertViewController.msgStr = msg;
    self.alertViewController.btnStr = btnStr;
    self.alertViewController.needCloseBtn = needCloseBtn;
    self.alertViewController.widthConstraintsValue = 620;
    WeakSelf(ws);
    UIView *showView = self.alertViewController.view;
    __weak UIView *weakShowView = showView;
    [self.alertViewController setCancelButtonClicked:^(NSString *value){
        if([value isEqualToString:@"makesure"]){
            callback(nil);
        }
        removeFromSuperviewUseUseAnimateAndDeallocViewController(weakShowView,ws.alertViewController);
    }];
    [self addToWindow:self.alertViewController parentView:nil];

}

-(void)showSamllYellowAlertPanel:(NSString *)storyboardName andIdentifier:(NSString *)identifier title:(NSString*)title msg:(NSString*)msg btn:(NSString*)btnStr align:(NSTextAlignment)textAlignment closeBtn:(BOOL)needCloseBtn parentView:(UIView *)specialParentView  andCallBack:(YellowPabelCallBack)callback{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:[NSBundle mainBundle]];
    self.alertViewController= [storyboard instantiateViewControllerWithIdentifier:identifier];
    self.alertViewController.textAlignment = textAlignment;
    self.alertViewController.titelStr = title;
    self.alertViewController.msgStr = msg;
    self.alertViewController.btnStr = btnStr;
    self.alertViewController.needCloseBtn = needCloseBtn;
    self.alertViewController.widthConstraintsValue = 400;
    WeakSelf(ws);
    UIView *showView = self.alertViewController.view;
    __weak UIView *weakShowView = showView;
    [self.alertViewController setCancelButtonClicked:^(NSString *value){
        if([value isEqualToString:@"makesure"]){
            callback(nil);
        }
        removeFromSuperviewUseUseAnimateAndDeallocViewController(weakShowView,ws.alertViewController);
    }];
    [self addToWindow:self.alertViewController parentView:specialParentView];
    
}

-(void)showOrderBuyerAddressListPanel:(NSString *)storyboardName andIdentifier:(NSString *)identifier needUnDefineBuyer:(NSInteger)needUnDefineBuyer parentView:(UIView *)specialParentView andCallBack:(YellowPabelCallBack)callback{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:[NSBundle mainBundle]];
    self.buyerAddressListController = [storyboard instantiateViewControllerWithIdentifier:identifier];
    self.buyerAddressListController.needUnDefineBuyer = needUnDefineBuyer;
    WeakSelf(ws);
    UIView *showView = self.buyerAddressListController.view;
    __weak UIView *weakShowView = showView;
    [self.buyerAddressListController setCancelButtonClicked:^(){
        removeFromSuperviewUseUseAnimateAndDeallocViewController(weakShowView,ws.buyerAddressListController);
    }];
    [self.buyerAddressListController setMakeSureButtonClicked:^(NSString* name,YYBuyerModel *infoModel){
        if(infoModel && infoModel.buyerId !=nil){
            callback(@[name,infoModel]);
        }else{
            callback(@[name]);
        }
        removeFromSuperviewUseUseAnimateAndDeallocViewController(weakShowView,ws.buyerAddressListController);

    }];

    [self addToWindow:self.buyerAddressListController parentView:specialParentView];
}

-(void)showStyleDiscountPanel:(NSString *)storyboardName andIdentifier:(NSString *)identifier
                        type:(DiscountType)type
                        orderStyleModel:(YYOrderStyleModel *)orderStyleModel orderInfoModel:(YYOrderInfoModel *)orderInfoModel
                        AndSeriesId:(long)seriesId
                        originalPrice:(double)originalPrice
                        finalPrice:(double)finalPrice parentView:(UIView *)specialParentView andCallBack:(YellowPabelCallBack)callback{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:[NSBundle mainBundle]];
    self.discountViewController = [storyboard instantiateViewControllerWithIdentifier:identifier];
    self.discountViewController.currentDiscountType = type;
    self.discountViewController.orderStyleModel = orderStyleModel;
    self.discountViewController.currentYYOrderInfoModel =orderInfoModel;
    self.discountViewController.originalTotalPrice = originalPrice;
    self.discountViewController.finalTotalPrice = finalPrice;
    WeakSelf(ws);
    UIView *showView = self.discountViewController.view;
    __weak UIView *weakShowView = showView;
    [self.discountViewController setCancelButtonClicked:^(){
        removeFromSuperviewUseUseAnimateAndDeallocViewController(weakShowView,ws.discountViewController);
    }];
    [self.discountViewController setModifySuccess:^(){
        removeFromSuperviewUseUseAnimateAndDeallocViewController(weakShowView,ws.discountViewController);
        callback(nil);
    }];
    [self addToWindow:self.discountViewController parentView:specialParentView];
}

-(void)addToWindow:(UIViewController *)controller parentView:(UIView *)specialParentView {
    if(specialParentView !=nil){
        self.parentView = specialParentView;
    }else{
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        self.parentView = appDelegate.mainViewController.view;
    }
    __weak UIView *weakSuperView = self.parentView;
    UIView *showView = controller.view;
    
    [self.parentView addSubview:showView];
    if(SYSTEM_VERSION_LESS_THAN(@"8.0")){
        showView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    }else{
        [showView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(weakSuperView.mas_top);
            make.left.equalTo(weakSuperView.mas_left);
            make.bottom.equalTo(weakSuperView.mas_bottom);
            make.right.equalTo(weakSuperView.mas_right);
        }];
    }
    addAnimateWhenAddSubview(showView);
}

-(void)showYellowUserCheckAlertPanel:(NSString *)storyboardName andIdentifier:(NSString *)identifier title:(NSString*)title msg:(NSString*)msg iconStr:(NSString*)iconStr btnStr:(NSString*)btnStr align:(NSTextAlignment)textAlignment closeBtn:(BOOL)needCloseBtn  funArray:(NSArray *)funArray andCallBack:(YellowPabelCallBack)callback{
    if(self.userCheckAlertViewController && [self.userCheckAlertViewController.view superview] != nil){
        [self.userCheckAlertViewController.view removeFromSuperview];
        self.userCheckAlertViewController = nil;
    }
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:[NSBundle mainBundle]];
    self.userCheckAlertViewController= [storyboard instantiateViewControllerWithIdentifier:identifier];
    self.userCheckAlertViewController.textAlignment = textAlignment;
    self.userCheckAlertViewController.titelStr = title;
    self.userCheckAlertViewController.msgStr = msg;
    self.userCheckAlertViewController.btnStr = btnStr;
    self.userCheckAlertViewController.iconStr = iconStr;
    self.userCheckAlertViewController.needCloseBtn = needCloseBtn;
    self.userCheckAlertViewController.funArray = funArray;
    WeakSelf(ws);
    UIView *showView = self.userCheckAlertViewController.view;
    showView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
    __weak UIView *weakShowView = showView;
    [self.userCheckAlertViewController setCancelButtonClicked:^(){
        removeFromSuperviewUseUseAnimateAndDeallocViewController(weakShowView,ws.userCheckAlertViewController);
    }];
    [self.userCheckAlertViewController setModifySuccess:^(){
        removeFromSuperviewUseUseAnimateAndDeallocViewController(weakShowView,ws.userCheckAlertViewController);
        callback(nil);
    }];
    [self addToWindow:self.userCheckAlertViewController parentView:[UIApplication sharedApplication].keyWindow.rootViewController.view];
}

-(void)showOrderStatusRequestClosePanelWidthParentView:(UIView *)specialParentView  currentYYOrderInfoModel:(YYOrderInfoModel *)currentYYOrderInfoModel andCallBack:(YellowPabelCallBack)callback{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"OrderDetail" bundle:[NSBundle mainBundle]];
    self.orderStatusRequestCloseViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYOrderStatusRequestCloseViewController"];
    self.orderStatusRequestCloseViewController.currentYYOrderInfoModel =  currentYYOrderInfoModel;
    WeakSelf(ws);
    UIView *showView = self.orderStatusRequestCloseViewController.view;
    __weak UIView *weakShowView = showView;
    [self.orderStatusRequestCloseViewController setCancelButtonClicked:^(){
        removeFromSuperviewUseUseAnimateAndDeallocViewController(weakShowView,ws.orderStatusRequestCloseViewController);
    }];
    [self.orderStatusRequestCloseViewController setModifySuccess:^(){
        removeFromSuperviewUseUseAnimateAndDeallocViewController(weakShowView,ws.orderStatusRequestCloseViewController);
        callback(nil);
    }];
    [self addToWindow:self.orderStatusRequestCloseViewController parentView:specialParentView];
}

-(void)showOpusSettingpanelWidthParentView:(UIView *)specialParentView seriesId:(NSInteger)seriesId andCallBack:(YellowPabelCallBack)callback{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Opus" bundle:[NSBundle mainBundle]];
    self.opusSettingViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYOpusSettingViewController"];
    self.opusSettingViewController.seriesId = seriesId;
    WeakSelf(ws);
    UIView *showView = self.opusSettingViewController.view;
    __weak UIView *weakShowView = showView;
    [self.opusSettingViewController setCancelButtonClicked:^(){
        removeFromSuperviewUseUseAnimateAndDeallocViewController(weakShowView,ws.opusSettingViewController);
    }];
    [self.opusSettingViewController setSelectedValue:^(NSString *value){
        removeFromSuperviewUseUseAnimateAndDeallocViewController(weakShowView,ws.opusSettingViewController);
        callback(@[value]);
    }];
    [self addToWindow:self.opusSettingViewController parentView:specialParentView];
}

-(void)showSeriesInfoDetailViewWidthParentView:(UIView *)specialParentView info:(YYSeriesInfoDetailModel*)info andCallBack:(YellowPabelCallBack)callback{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Opus" bundle:[NSBundle mainBundle]];
    self.seriesInfoDetailViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYSeriesInfoDetailViewController"];
    self.seriesInfoDetailViewController.seriesInfoDetailModel = info;
    WeakSelf(ws);
    UIView *showView = self.seriesInfoDetailViewController.view;
    __weak UIView *weakShowView = showView;
    [self.seriesInfoDetailViewController setCancelButtonClicked:^(){
        removeFromSuperviewUseUseAnimateAndDeallocViewController(weakShowView,ws.seriesInfoDetailViewController);
    }];

    [self addToWindow:self.seriesInfoDetailViewController parentView:specialParentView];
}

-(void)showOrderAppendViewWidthParentView:(UIView *)specialParentView info:(NSArray*)info andCallBack:(YellowPabelCallBack)callback{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"OrderDetail" bundle:[NSBundle mainBundle]];
    self.orderAppendViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYOrderAppendViewController"];
    self.orderAppendViewController.ordreCode = [info objectAtIndex:0];
    WeakSelf(ws);
    UIView *showView = self.orderAppendViewController.view;
    __weak UIView *weakShowView = showView;
    [self.orderAppendViewController setCancelButtonClicked:^(){
        removeFromSuperviewUseUseAnimateAndDeallocViewController(weakShowView,ws.orderStatusRequestCloseViewController);
    }];
    [self.orderAppendViewController setModifySuccess:^(NSArray *value){
        removeFromSuperviewUseUseAnimateAndDeallocViewController(weakShowView,ws.orderStatusRequestCloseViewController);
        callback(value);
    }];
    [self addToWindow:self.orderAppendViewController parentView:specialParentView];
}

-(void)showOrderAddStyleRemarkViewWidthParentView:(UIView *)specialParentView info:(YYOrderStyleModel*)info andCallBack:(YellowPabelCallBack)callback{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"OrderDetail" bundle:[NSBundle mainBundle]];
    self.orderAddStyleRemarkViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYOrderAddStyleRemarkViewController"];
    self.orderAddStyleRemarkViewController.orderStyleModel = info;
    WeakSelf(ws);
    UIView *showView = self.orderAddStyleRemarkViewController.view;
    __weak UIView *weakShowView = showView;
    [self.orderAddStyleRemarkViewController setCancelButtonClicked:^(){
        removeFromSuperviewUseUseAnimateAndDeallocViewController(weakShowView,ws.orderAddStyleRemarkViewController);
    }];
    [self.orderAddStyleRemarkViewController setModifySuccess:^(){
        removeFromSuperviewUseUseAnimateAndDeallocViewController(weakShowView,ws.orderAddStyleRemarkViewController);
        callback(nil);
    }];
    [self addToWindow:self.orderAddStyleRemarkViewController parentView:specialParentView];
}

-(void)showOpusSettingDefinedViewWidthParentView:(UIViewController *)specialParentView info:(NSArray*)info andCallBack:(YellowPabelCallBack)callback{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Opus" bundle:[NSBundle mainBundle]];
    self.opusSettingDefinedViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYOpusSettingDefinedViewController"];
    self.opusSettingDefinedViewController.seriesId = [[info objectAtIndex:0] integerValue];
    self.opusSettingDefinedViewController.authType = [[info objectAtIndex:1] integerValue];
    if(specialParentView ==nil){
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        specialParentView = appDelegate.mainViewController.topViewController;
    }
    WeakSelf(ws);
    UIView *showView = self.opusSettingDefinedViewController.view;
    __weak UIView *weakShowView = showView;
    [self.opusSettingDefinedViewController setCancelButtonClicked:^(){
        removeFromSuperviewUseUseAnimateAndDeallocViewController(weakShowView,ws.opusSettingDefinedViewController);
    }];
    [self.opusSettingDefinedViewController setSelectedValue:^(NSString *value){
        removeFromSuperviewUseUseAnimateAndDeallocViewController(weakShowView,ws.opusSettingDefinedViewController);
        callback(@[value]);
    }];
    UIView *parentView = (specialParentView?specialParentView.view:nil);
    [self addToWindow:self.opusSettingDefinedViewController parentView:parentView];

}
@end

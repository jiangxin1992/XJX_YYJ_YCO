//
//  YYMainViewController.m
//  Yunejian
//
//  Created by yyj on 15/7/5.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import "YYMainViewController.h"

// c文件 —> 系统文件（c文件在前）

// 控制器
#import "YYIndexViewController.h"
#import "YYOpusViewController.h"
#import "YYAccountDetailViewController.h"
#import "YYOrderListViewController.h"
#import "YYLeftMenuViewController.h"
#import "YYSettingViewController.h"

// 自定义视图
#import "MBProgressHUD.h"

// 接口
#import "YYOrderApi.h"
#import "YYShowroomApi.h"

// 分类

// 自定义类和三方类（ cocoapods类 > model > 工具类 > 其他）


#import <AFNetworking/AFNetworkReachabilityManager.h>

#import "YYUser.h"
#import "YYAddress.h"
#import "YYStylesAndTotalPriceModel.h"

#import "AppDelegate.h"
#import "SZKNetWorkUtils.h"
#import "UserDefaultsMacro.h"

@interface YYMainViewController ()

@property(nonatomic,strong) YYLeftMenuViewController *leftMenuViewController;

@property(nonatomic,strong) UIViewController *indexViewController;
@property(nonatomic,strong) YYOpusViewController *opusViewController;
@property(nonatomic,strong) YYOrderListViewController *orderListViewController;
@property(nonatomic,strong) YYAccountDetailViewController *accountDetailViewController;
@property(nonatomic,strong) YYSettingViewController *settingViewController;

@property(nonatomic,strong) UIView *currentRightView;
@property (weak, nonatomic) IBOutlet UIView *rightContainerView;
@property(nonatomic,assign) BOOL isUploadingOrderNow;

@end

@implementation YYMainViewController

#pragma mark - --------------生命周期--------------
- (void)viewDidLoad {
    [super viewDidLoad];
    [self SomePrepare];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    // 进入埋点
    [MobClick beginLogPageView:kYYPageMain];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    // 退出埋点
    [MobClick endLogPageView:kYYPageMain];
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    WeakSelf(ws);
    NSLog(@"prepareForSegue.....");
    [self addAllChildViewContrllers];
    
    id destinationViewController = [segue destinationViewController];
    if ([destinationViewController isKindOfClass:[YYLeftMenuViewController class]]) {
        NSLog(@"prepareForSegue.....YYLeftMenuViewController ");
        YYLeftMenuViewController *leftMenuViewController = (YYLeftMenuViewController *)destinationViewController;
        self.leftMenuViewController = leftMenuViewController;
        
        if (leftMenuViewController) {
            [leftMenuViewController setLeftMenuButtonClicked:^(LeftMenuButtonIndex buttonIndex){
                
                [ws leftMenuButtonClicked:buttonIndex];
                
            }];
            [leftMenuViewController setCancelButtonClicked:^(){
                [ws backHomePage];
            }];
        }
    }else if ([destinationViewController isKindOfClass:[YYIndexViewController class]]){
        NSLog(@"prepareForSegue.....YYIndexViewController ");
    }
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark - --------------SomePrepare--------------
-(void)SomePrepare
{
    [self PrepareData];
    [self PrepareUI];
}
-(void)PrepareData{

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showOrderListNotification:) name:kShowOrderListNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showAccountNotification:) name:kShowAccountNotification object:nil];
    [SZKNetWorkUtils netWorkState:^(NSInteger netState) {
        switch (netState) {
            case 1:{
                NSLog(@"手机流量上网");
                [self uploadLocalOrder];
                YYUser *user = [YYUser currentUser];
                if([YYUser isShowroomToBrand]||user.userType==0||user.userType==2){
                    [self.orderListViewController reachabilityChanged];
                }
            }
                break;
            case 2:{
                NSLog(@"WIFI上网");
                [self uploadLocalOrder];
                YYUser *user = [YYUser currentUser];
                if([YYUser isShowroomToBrand]||user.userType==0||user.userType==2){
                    [self.orderListViewController reachabilityChanged];
                }
            }
                break;
            default:{
                NSLog(@"没网");
                YYUser *user = [YYUser currentUser];
                if([YYUser isShowroomToBrand]||user.userType==0||user.userType==2){
                    [self.orderListViewController reachabilityChanged];
                }
            }
                break;
        }
    }];
}
- (void)showOrderListNotification:(NSNotification *)note{
    [self.navigationController popToViewController:self animated:NO];
    [self leftMenuButtonClicked:LeftMenuButtonTypeIndex_2];
    [self.leftMenuViewController setButtonSelectedByButtonIndex:LeftMenuButtonTypeIndex_2];
    if(self.orderListViewController){
        [self.orderListViewController allOrderButtonClicked:nil];
    }
}

- (void)showAccountNotification:(NSNotification *)note{
    [self.navigationController popToViewController:self animated:NO];
    [self leftMenuButtonClicked:LeftMenuButtonTypeIndex_3];
    [self.leftMenuViewController setButtonSelectedByButtonIndex:LeftMenuButtonTypeIndex_3];
    WeakSelf(ws);
    //后续扩展类型
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if(ws.accountDetailViewController){
            [ws.accountDetailViewController checkUserIdentity];
        }
    });
}
-(void)PrepareUI{}

#pragma mark - --------------UIConfig----------------------
//-(void)UIConfig{}
- (void)addAllChildViewContrllers{

    if (self.childViewControllers
        && [self.childViewControllers count] > 0) {
        return;
    }
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    YYIndexViewController *indexViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYIndexViewController"];
    self.indexViewController = indexViewController;
    [self addChildViewController:indexViewController];

    UIStoryboard *opusStoryboard = [UIStoryboard storyboardWithName:@"Opus" bundle:[NSBundle mainBundle]];

    YYOpusViewController *opusViewController = [opusStoryboard instantiateViewControllerWithIdentifier:@"YYOpusViewController"];
    self.opusViewController = opusViewController;
    [self addChildViewController:opusViewController];


    UIStoryboard *orderStoryboard = [UIStoryboard storyboardWithName:@"OrderDetail" bundle:[NSBundle mainBundle]];

    YYOrderListViewController *orderListViewController = [orderStoryboard instantiateViewControllerWithIdentifier:@"YYOrderListViewController"];
    self.orderListViewController = orderListViewController;
    [self addChildViewController:orderListViewController];


    if([YYUser isShowroomToBrand]){

    }else{
        UIStoryboard *accountStoryboard = [UIStoryboard storyboardWithName:@"Account" bundle:[NSBundle mainBundle]];

        YYAccountDetailViewController *accountDetailViewController = [accountStoryboard instantiateViewControllerWithIdentifier:@"YYAccountDetailViewController"];
        self.accountDetailViewController = accountDetailViewController;
        [self addChildViewController:accountDetailViewController];
    }

}

//#pragma mark - --------------请求数据----------------------
//-(void)RequestData{}

#pragma mark - --------------系统代理----------------------


#pragma mark - --------------自定义代理/block----------------------


#pragma mark - --------------自定义响应----------------------
-(void)backAction
{
    if (![YYNetworkReachability connectedToNetwork]) {
        //清除购物车
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate clearBuyCar];
        appDelegate.leftMenuIndex = 0;
        [YYUser removeTempUser];
        if(_cancelButtonClicked)
        {
            _cancelButtonClicked();
        }
    }else{

        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [YYShowroomApi brandToShowroomBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYUserModel *userModel, NSError *error) {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            if(rspStatusAndMessage.status == kCode100){
                //清除购物车
                AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                [appDelegate clearBuyCar];
                appDelegate.leftMenuIndex = 0;
                if(_cancelButtonClicked)
                {
                    _cancelButtonClicked();
                }
            }else{

                [YYToast showToastWithView:self.view title:rspStatusAndMessage.message andDuration:kAlertToastDuration];
            }
        }];
    }
}
-(void)backHomePage{
    if(self.cancelButtonClicked){
        AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        YYStylesAndTotalPriceModel *stylesAndTotalPriceModel = [appdelegate.cartModel getTotalValueByOrderInfo:NO];
        if(stylesAndTotalPriceModel.totalStyles)
        {
            WeakSelf(ws);
            CMAlertView *alertView = [[CMAlertView alloc] initWithTitle:NSLocalizedString(@"确定返回Showroom？",nil) message:NSLocalizedString(@"返回后，此品牌购物车内的款式将被清空",nil) needwarn:NO delegate:nil cancelButtonTitle:NSLocalizedString(@"暂不返回_no",nil) otherButtonTitles:@[NSLocalizedString(@"返回主页_yes",nil)] otherBtnBackColor:@"000000"];
            alertView.specialParentView = self.view;
            [alertView setAlertViewBlock:^(NSInteger selectedIndex){
                if (selectedIndex == 1) {
                    [ws backAction];
                }
            }];
            [alertView show];
        }else
        {
            [self backAction];
        }
    }
}
- (void)leftMenuButtonClicked:(LeftMenuButtonIndex)buttonIndex{
    if (_currentRightView
        && buttonIndex != LeftMenuButtonTypeIndex_5) {
        [_currentRightView removeFromSuperview];
    }

    __weak  UIView *_weakRightContainerView = _rightContainerView;

    switch (buttonIndex) {
        case LeftMenuButtonTypeIndex_0:{
            [_rightContainerView addSubview:_indexViewController.view];
            [_indexViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(_weakRightContainerView.mas_top);
                make.left.equalTo(_weakRightContainerView.mas_left);
                make.bottom.equalTo(_weakRightContainerView.mas_bottom);
                make.right.equalTo(_weakRightContainerView.mas_right);

            }];

            self.currentRightView = _indexViewController.view;
        }
            break;
        case LeftMenuButtonTypeIndex_1:{
            //这里要进行判断，登录的是什么角色
            [_rightContainerView addSubview:_opusViewController.view];
            [_opusViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(_weakRightContainerView.mas_top);
                make.left.equalTo(_weakRightContainerView.mas_left);
                make.bottom.equalTo(_weakRightContainerView.mas_bottom);
                make.right.equalTo(_weakRightContainerView.mas_right);

            }];
            self.currentRightView = _opusViewController.view;
        }
            break;
        case LeftMenuButtonTypeIndex_2:{


            [_rightContainerView addSubview:_orderListViewController.view];
            [_orderListViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(_weakRightContainerView.mas_top);
                make.left.equalTo(_weakRightContainerView.mas_left);
                make.bottom.equalTo(_weakRightContainerView.mas_bottom);
                make.right.equalTo(_weakRightContainerView.mas_right);

            }];

            self.currentRightView = _orderListViewController.view;


        }
            break;
        case LeftMenuButtonTypeIndex_3:{
            [_rightContainerView addSubview:_accountDetailViewController.view];
            [_accountDetailViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(_weakRightContainerView.mas_top);
                make.left.equalTo(_weakRightContainerView.mas_left);
                make.bottom.equalTo(_weakRightContainerView.mas_bottom);
                make.right.equalTo(_weakRightContainerView.mas_right);

            }];
            self.currentRightView = _accountDetailViewController.view;
        }
            break;
        case LeftMenuButtonTypeIndex_5:{

            WeakSelf(ws);
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

            UIView *superView = appDelegate.window.rootViewController.view;

            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Account" bundle:[NSBundle mainBundle]];
            YYSettingViewController *settingViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYSettingViewController"];
            self.settingViewController = settingViewController;

            __weak UIView *weakSuperView = superView;
            UIView *showView = settingViewController.view;
            __weak UIView *weakShowView = showView;

            [settingViewController setCancelButtonClicked:^(){
                removeFromSuperviewUseUseAnimateAndDeallocViewController(weakShowView,ws.settingViewController);
            }];
            [settingViewController setBlock:^{
                weakShowView.alpha = 0.0;
                [weakShowView removeFromSuperview];
                ws.settingViewController = nil;
            }];

            [superView addSubview:showView];
            [showView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(weakSuperView.mas_top);
                make.left.equalTo(weakSuperView.mas_left);
                make.bottom.equalTo(weakSuperView.mas_bottom);
                make.right.equalTo(weakSuperView.mas_right);
            }];

            addAnimateWhenAddSubview(showView);
        }
            break;
        default:
            break;
    }
    NSLog(@"prepareForSegue.....YYLeftMenuViewController %li ",(long)buttonIndex);
}
#pragma mark - --------------自定义方法----------------------
- (void)uploadLocalOrder{
    if([YYNetworkReachability connectedToNetwork]){
        WeakSelf(ws);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            [ws upLoadOfflineOrder];
        });
    }
}
- (void)upLoadOfflineOrder{
    //如果网络是通的，并且登录成功了，那后台去提交离线下的订单
    if ([YYNetworkReachability connectedToNetwork]
        && !_isUploadingOrderNow) {
        _isUploadingOrderNow = YES;
        //离线创建的订单信息，先保存至本地
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSDictionary *tempDic = [userDefaults persistentDomainForName:kOfflineOrderDictionaryKey];
        __block NSMutableArray *upLoadSuccessArray = [[NSMutableArray alloc] initWithCapacity:0];
        if (tempDic
            && [tempDic count] > 0) {

            NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:tempDic];


            for (int i= 0; i < [dic count]; i++) {
                __block  NSString *nowKey = [[dic allKeys] objectAtIndex:i];

                NSString *string = [dic objectForKey:nowKey];

                NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
                if (data
                    && [data length] > 0) {
                    NSError* error;
                    NSDictionary* json = [NSJSONSerialization
                                          JSONObjectWithData:data
                                          options:NSJSONReadingAllowFragments
                                          error:&error];
                    if (json) {
                        __block YYOrderInfoModel *orderInfoModel = [[YYOrderInfoModel alloc] initWithDictionary:json error:nil];
                        if (orderInfoModel) {
                            if([orderInfoModel.brandID isEqualToString:[YYUser getBrandID]]){
                                __block BOOL inRunLoop = NO;

                                //先提交地址，获取地编号后赋给订单中

                                __block NSString *tempKey = [NSString stringWithFormat:@"%@%@",orderInfoModel.shareCode,kOfflineOrderAddressSuffix];
                                YYAddress *nowAddress = [NSKeyedUnarchiver unarchiveObjectWithData:[userDefaults objectForKey:tempKey]];
                                if (nowAddress) {
                                    inRunLoop = YES;
                                    __block YYAddress *blockAddress = nowAddress;
                                    [YYOrderApi createOrModifyAddress:nowAddress andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYBuyerAddressModel *addressModel, NSError *error) {
                                        if (rspStatusAndMessage.status == kCode100
                                            && addressModel
                                            && addressModel.addressId){

                                            NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
                                            [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];

                                            NSNumber *addressNumber = [numberFormatter numberFromString:addressModel.addressId];

                                            orderInfoModel.buyerAddressId = addressNumber;
                                        }
                                        blockAddress = nil;
                                        inRunLoop = NO;
                                    }];
                                }

                                while (inRunLoop) {
                                    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];

                                }

                                NSLog(@"order: %@",orderInfoModel.toJSONString);
                                NSData *jsonData = [orderInfoModel toJSONData];


                                NSString *jsonString = [[NSString alloc] initWithData:jsonData
                                                                             encoding:NSUTF8StringEncoding];

                                NSString *actionRefer = @"create";
                                NSInteger realBuyerId = [orderInfoModel.realBuyerId integerValue];

                                inRunLoop = YES;
                                [YYOrderApi createOrModifyOrderByJsonString:jsonString actionRefer:actionRefer realBuyerId:realBuyerId andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSString *orderCode, NSError *error) {
                                    if (rspStatusAndMessage.status == kCode100) {
                                        NSLog(@"离线订单提交成功!");
                                        [upLoadSuccessArray addObject:nowKey];
                                    }
                                    inRunLoop = NO;
                                }];

                                while (inRunLoop) {
                                    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];

                                }
                            }
                        }
                    }
                }
            }

            if ([upLoadSuccessArray count] > 0) {
                for (NSString *thisKey in upLoadSuccessArray) {
                    [dic removeObjectForKey:thisKey];
                }

                if ([dic count] > 0) {
                    //还有没有提交成功的，重新保存
                    [userDefaults setPersistentDomain:dic forName:kOfflineOrderDictionaryKey];
                    [userDefaults synchronize];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [YYToast showToastWithTitle:NSLocalizedString(@"抱歉，离线创建的订单异常，请在有网络的情况下重新建立订单", nil) andDuration:kAlertToastDuration];
                    });
                }else{
                    [userDefaults removePersistentDomainForName:kOfflineOrderDictionaryKey];
                    [userDefaults synchronize];
                }

            }else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [YYToast showToastWithTitle:NSLocalizedString(@"抱歉，离线创建的订单异常，请在有网络的情况下重新建立订单", nil) andDuration:kAlertToastDuration];
                });
            }

        }
        _isUploadingOrderNow = NO;
    }

}
#pragma mark - --------------other----------------------

@end

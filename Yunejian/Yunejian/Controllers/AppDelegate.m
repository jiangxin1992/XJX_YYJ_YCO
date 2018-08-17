//
//  AppDelegate.m
//  Yunejian
//
//  Created by yyj on 15/7/3.
//  Copyright (c) 2015年 yyj. All rights reserved.
//
//
//                            _ooOoo_
//                           o8888888o
//                           88" . "88
//                           (| -_- |)
//                            O\ = /O
//                        ____/`---'\____
//                      .   ' \\| |// `.
//                       / \\||| : |||// \
//                     / _||||| -:- |||||- \
//                       | | \\\ - /// | |
//                     | \_| ''\---/'' | |
//                      \ .-\__ `-` ___/-. /
//                   ___`. .' /--.--\ `. . __
//                ."" '< `.___\_<|>_/___.' >'"".
//               | | : `- \`.;`\ _ /`;.`/ - ` : | |
//                 \ \ `-. \_ __\ /__ _/ .-` / /
//         ======`-.____`-.___\_____/___.-`____.-'======
//                            `=---='
//
//         .............................................
//                  佛祖镇楼                  BUG辟易
//          佛曰:
//                  写字楼里写字间，写字间里程序员；
//                  程序人员写程序，又拿程序换酒钱。
//                  酒醒只在网上坐，酒醉还来网下眠；
//                  酒醉酒醒日复日，网上网下年复年。
//                  但愿老死电脑间，不愿鞠躬老板前；
//                  奔驰宝马贵者趣，公交自行程序员。
//                  别人笑我忒疯癫，我笑自己命太贱；
//                  不见满街漂亮妹，哪个归得程序员？

#import "AppDelegate.h"

// c文件 —> 系统文件（c文件在前）

// 控制器
#import "YYOrderModifyViewController.h"
#import "YYStyleDetailViewController.h"
#import "YYIntroductionViewController.h"
#import "YYShowroomMainViewController.h"

// 自定义视图
#import "YYShoppingView.h"
#import "YYYellowPanelManage.h"

// 接口
#import "YYUserApi.h"
#import "YYOrderApi.h"
#import "YYBurideApi.h"
#import "YYShowroomApi.h"
#import "YYServerURLApi.h"

// 分类
#import "NSBundle+Language.h"
#import "NSManagedObject+helper.h"

// 自定义类和三方类（ cocoapods类 > model > 工具类 > 其他）
#import "JpushHandler.h"
#import <Bugly/Bugly.h>
#import <SDImageCache.h>
#import <UMMobClick/MobClick.h>
#import <AFNetworking/AFNetworkReachabilityManager.h>

#import "YYUser.h"
#import "Series.h"
#import "YYUserModel.h"
#import "YYOrderInfoModel.h"
#import "YYOpusStyleModel.h"
#import "YYStyleInfoModel.h"
#import "YYOpusSeriesModel.h"
#import "StyleDetail.h"
#import "StyleDeatilSizes.h"
#import "StyleDetailColors.h"
#import "StyleDetailColorImages.h"
#import "YYSubShowroomUserPowerModel.h"
#import "YYBrandSeriesToCartTempModel.h"

#import "mmDAO.h"
#import "YYUpdateAppStore.h"
#import "UserDefaultsMacro.h"
#import "YYRspStatusAndMessage.h"

static NSString * const isFirstOpenApp = @"isFirstOpenApp";

@interface AppDelegate ()

/** 是否需要强制更新 */
@property (nonatomic,assign) BOOL isNeedUpdate;
/** 开始网络监控 */
@property (nonatomic, assign) BOOL isStartNetworkSpace;

@end

@implementation AppDelegate
#pragma mark - --------------生命周期--------------
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    // 网络监控
    [self AFNReachability];
    _isStartNetworkSpace = true;
    while (_isStartNetworkSpace) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }

    //初始化TempSeriesdata(nsarray)
    [YYUser initOrClearTempSeriesID];

    // 初始化友盟统计
    [self initUmeng];

    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *_isFirstOpenApp = [userDefault objectForKey:isFirstOpenApp];
    if([NSString isNilOrEmpty:_isFirstOpenApp]){
        [userDefault setObject:@"not_first_open" forKey:isFirstOpenApp];
        [userDefault synchronize];
        NSArray *languages = [NSLocale availableLocaleIdentifiers];
        NSLog(@"%@",languages);
        NSArray *langArr = [LanguageManager languageStrings];
        NSLog(@"%@",langArr);
        NSString *langStr = [LanguageManager currentLanguageCode];
        NSLog(@"%@",langStr);
        BOOL isenglish = [LanguageManager isEnglishLanguage];
        NSLog(@"%d",isenglish);

        NSString *langCode = [LanguageManager currentLanguageCode];
        if ([langCode containsString:@"zh"]) {
            //        中文
            [LanguageManager saveLanguageByIndex:1];
        } else {
            //        非中文 默认为英文
            [LanguageManager saveLanguageByIndex:0];
        }
        BOOL isenglish1 = [LanguageManager isEnglishLanguage];
        NSLog(@"%d",isenglish1);
        NSLog(@"111");
    }

    // 初始化bugly
    [Bugly startWithAppId:@"68df60feaa"];

    [[mmDAO instance] setupEnvModel:@"yunejian" DbFile:@"yunejian.sqlite"];

    NSString *moneyType = [userDefault objectForKey:KUserCartMoneyTypeKey];
    self.cartMoneyType = (moneyType==nil?-1:[moneyType integerValue]);
    NSString *string = [userDefault objectForKey:KUserCartKey];
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    _seriesArray = [NSMutableArray array];
    if (data) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        self.cartModel = [[YYOrderInfoModel alloc] initWithDictionary:dict error:nil];
        if (self.cartModel.groups.count != 0) {
            _seriesArray = [self valueForKeyPath:@"cartModel.groups"];
        }
    }

    _inRunLoop = true;
    // 得到真实网址
    [self loadServerInfo];

    while (_inRunLoop) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }

    [self addObserverForKeyboard];
    [self addObserverForNeedLogin];

    //jpush
    [JpushHandler setupJpush:launchOptions];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *obj = [defaults objectForKey:@"currentLanguageKey"];
    if(obj){
        if([obj isEqualToString:@"zh-Hans-US"]&&LanguageManager.currentLanguageIndex == 1){
        }else if([obj isEqualToString:@"en"]&&LanguageManager.currentLanguageIndex == 0){
        }else{
            [LanguageManager saveLanguageByIndex:1];
        }
    }else{
        [LanguageManager saveLanguageByIndex:1];
    }

    //修改订单临时数据
    self.currentYYOrderInfoModel = [[YYOrderInfoModel alloc] init];
    [YYUser removeTempUser];

    //在构建版本号为602，删除离线系列包
    [self deleteAllOfflineContent];

    //跳转界面控制
    //引导页只在（第一次安装，版本号变化的时候）才出现
    NSString *versionStr = kYYCurrentVersion;
    NSString *lastShowVersionStr = [[NSUserDefaults standardUserDefaults] objectForKey:lastIntroductionVersin];
    if ([NSString isNilOrEmpty:lastShowVersionStr] || ![lastShowVersionStr isEqualToString:versionStr]) {
        //更新本地
        [[NSUserDefaults standardUserDefaults] setObject:versionStr forKey:lastIntroductionVersin];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self enterIntroPage];
    }else{
        [self autoLogin];
    }
    if(_isNeedUpdate){
        [YYUpdateAppStore checkVersion];
    }
    return YES;
}
//在构建版本号为602，删除离线系列包
-(void)deleteAllOfflineContent{
    NSString *CFBundleVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    if([CFBundleVersion integerValue] == 602){
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        NSNumber *isEverDeleteAllOfflineContent = [userDefault objectForKey:@"isEverDeleteAllOfflineContent"];
        if(![isEverDeleteAllOfflineContent boolValue]){

            [userDefault setObject:@(YES) forKey:@"isEverDeleteAllOfflineContent"];
            [userDefault synchronize];

            NSMutableArray *cache_opusSeriesArray = [[NSMutableArray alloc] init];
            [Series async:^id(NSManagedObjectContext *ctx, NSString *className) {
                NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:className];
                NSError *error;
                NSArray *dataArray = [ctx executeFetchRequest:request error:&error];
                if (error) {
                    return error;
                }else{
                    return dataArray;
                }

            } result:^(NSArray *result, NSError *error) {
                if (result
                    && [result count] > 0) {
                    for (int i=0; i<result.count; i++) {
                        Series *series = [result objectAtIndex:i];
                        if(![NSString isNilOrEmpty:series.brand_id]){
                            if([[YYUser getBrandID] isEqualToString:series.brand_id]){

                                [cache_opusSeriesArray addObject:series];

                                if(cache_opusSeriesArray.count > 0){
                                    for (Series *series in cache_opusSeriesArray) {
                                        NSString *folderName = [NSString stringWithFormat:@"%ld",[series.series_id longValue]];
                                        NSString *offlineFilePath = [yyjOfflineSeriesDirectory() stringByAppendingPathComponent:folderName];
                                        NSError *error = nil;
                                        NSFileManager *fileManager = [NSFileManager defaultManager];
                                        [fileManager removeItemAtPath:offlineFilePath error:&error];//删除离线的关键代码
                                    }
                                }
                            }
                        }
                    }
                }
            }];
        }
    }
}

-(void)applicationDidReceiveMemoryWarning:(UIApplication *)application{
    [self clearLocalFile];
}
#pragma mark -jpush
- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    NSInteger badgeNum = self.unreadOrderNotifyMsgAmount + self.unreadConnNotifyMsgAmount;
    if(self.isOnConnNotifyMsgAUI){
        badgeNum = badgeNum - self.unreadConnNotifyMsgAmount;
    }
    if(self.isOnOrderNotifyMsgUI){
        badgeNum = badgeNum - self.unreadOrderNotifyMsgAmount;
    }
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:badgeNum];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    //[application setApplicationIconBadgeNumber:0];
    //[application cancelAllLocalNotifications];
}



- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"%@", [NSString stringWithFormat:@"Device Token: %@", deviceToken]);
    [JPUSHService registerDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application
didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"did Fail To Register For Remote Notifications With Error: %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [JPUSHService handleRemoteNotification:userInfo];
    NSLog(@"收到通知:%@", [self logDic:userInfo]);
    //[rootViewController addNotificationCount];
}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:
(void (^)(UIBackgroundFetchResult))completionHandler {
    NSLog(@"收到通知:%@", [self logDic:userInfo]);
    [JPUSHService handleRemoteNotification:userInfo];
    //    后台运行 applicationState = UIApplicationStateBackground
    //    点击横条 applicationState = UIApplicationStateInactive
    //    app打开的情况下 applicationState = UIApplicationStateActive
    if(application.applicationState==UIApplicationStateInactive)
    {
        if(userInfo)
        {
            if([userInfo objectForKey:@"cat"])
            {
                NSInteger cat = [[userInfo objectForKey:@"cat"] integerValue];
                if(cat == 0){
                    [JpushHandler handleUserInfo:userInfo];
                }
            }
        }
    }
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    [JPUSHService showLocalNotificationAtFront:notification identifierKey:nil];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    NSLog(@"SvTimerSample Will resign Avtive!");
    if(_myThread != nil){
        [_myThread cancel];

    }
}

//- (void)applicationDidEnterBackground:(UIApplication *)application {
//    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
//    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
//}
//
//- (void)applicationWillEnterForeground:(UIApplication *)application {
//    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
//}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    //[NSThread detachNewThreadSelector:@selector(setTimerSheduleToRunloop) toTarget:self withObject:nil];
    //    _myThread = [[NSThread alloc] initWithTarget:self  selector:@selector(setTimerSheduleToRunloop) object:nil];
    //    [_myThread start];

    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [self checkNoticeCount];
    [self checkUserStatus];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

//#pragma mark - --------------SomePrepare--------------

#pragma mark - --------------请求数据----------------------
//自动登录
-(void)autoLogin{
    YYUser *user = [YYUser currentUser];
    if (user && user.email && [user.email length] && user.password && [user.password length]) {
        if (![YYNetworkReachability connectedToNetwork]) {
            //没有网络，但应用登录过，则直接进去
            self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] ;
            [self enterMainIndexPage];
            [YYToast showToastWithTitle:kNetworkIsOfflineTips andDuration:kAlertToastDuration];
        }else{
            _inRunLoop = true;
            [self loginByEmail:user.email password:user.password verificationCode:nil];
            // 新增一条日活记录
            [YYBurideApi addStatDaily];

            while (_inRunLoop) {
                [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
            }
        }
    }else{
        self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] ;
        [self enterLoginPage];
    }
}

-(void)loadServerInfo{
    NSString *localServerURL = [[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL];
    __block NSString * lockLocalServerURL = localServerURL;

    if (YYDEBUG == 0 && [YYNetworkReachability connectedToNetwork]) {
        [YYServerURLApi getAppServerURLWidth:^(NSString *serverURL,BOOL isNeedUpdate, NSError *error) {
            if(serverURL == nil){
                if(lockLocalServerURL == nil){
                    [[NSUserDefaults standardUserDefaults] setObject:kYYServerURL forKey:kLastYYServerURL];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
            }else{
                [[NSUserDefaults standardUserDefaults] setObject:serverURL forKey:kLastYYServerURL];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            _isNeedUpdate = isNeedUpdate;
            _inRunLoop = NO;
        }];
    }else{
        if(YYDEBUG || lockLocalServerURL == nil){
            [[NSUserDefaults standardUserDefaults] setObject:kYYServerURL forKey:kLastYYServerURL];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        _inRunLoop = NO;
    }

}

- (void)loginByEmail:(NSString *)email password:(NSString *)password verificationCode:(NSString *)verificationCode{
    WeakSelf(ws);

    verificationCode = verificationCode&&[verificationCode length]?verificationCode:nil;

    [YYUserApi loginWithUsername:email password:md5(password) verificationCode:verificationCode andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYUserModel *userModel, NSError *error) {
        ws.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] ;

        if (rspStatusAndMessage.status == kCode100 || rspStatusAndMessage.status == kCode1000){

            YYUser *user = [YYUser currentUser];
            [user saveUserWithEmail:email username:userModel.name password:password userType:[userModel.type integerValue] userId:userModel.id logo:userModel.logo status:[userModel.authStatus stringValue] brandId:[[NSString alloc] initWithFormat:@"%ld",(long)[userModel.brandId integerValue]]];

            //进入首页
            [ws enterMainIndexPage];
            if( [user.status integerValue] == kCode305){
                NSString *expireDate = getShowDateByFormatAndTimeInterval(@"yyyy/MM/dd HH:mm",userModel.expireDate);

                NSString *msg =[NSString stringWithFormat:NSLocalizedString(@"请在 %@ 前完成品牌验证，未验证的账号将被锁定|%@",nil),expireDate,expireDate];
                [[YYYellowPanelManage instance] showYellowUserCheckAlertPanel:@"Main" andIdentifier:@"YYUserCheckAlertViewController" title:NSLocalizedString(@"品牌验证",nil) msg:msg iconStr:@"identity_need_icon"  btnStr:NSLocalizedString(@"验证品牌信息",nil) align:NSTextAlignmentCenter closeBtn:YES funArray:nil andCallBack:^(NSArray *value) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kShowAccountNotification object:nil];
                }];
            }

            [LanguageManager setLanguageToServer];

            // 获取subshowroom的权限列表, 首先是判断showroom子账号
            if (user.userType == kShowroomSubType) {
                [YYShowroomApi selectSubShowroomPowerUserId:[NSNumber numberWithInteger:[user.userId integerValue]] andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSArray *powerArray, NSError *error) {
                    YYSubShowroomUserPowerModel *subShowroom = [YYSubShowroomUserPowerModel shareModel];
                    for (NSNumber *i in powerArray) {
                        if ([i intValue] == 1) {
                            subShowroom.isBrandAction = YES;
                        }
                    }

                }];
            }

        }else{
            [ws enterLoginPage];
        }
        _inRunLoop = NO;
    }];
}
- (void)timerAction:(NSTimer *)theTimer {
    // Show the HUD only if the task is still running
    NSThread * thread = [NSThread currentThread];
    if ([thread isCancelled]){
        [NSThread exit];//执行exit，后边的语句不再执行。所以不用写retur
    }
    YYUser *user = [YYUser currentUser];
    if (![YYNetworkReachability connectedToNetwork] || self.mainViewController == nil || !user.email ) {
        return;
    }
    NSString *type = @"";
    [YYOrderApi getUnreadNotifyMsgAmount:type andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSInteger orderMsgCount,NSInteger connMsgCount, NSError *error) {
        self.unreadOrderNotifyMsgAmount = orderMsgCount;
        self.unreadConnNotifyMsgAmount = connMsgCount;
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:UnreadConnNotifyMsgAmount object:nil userInfo:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:UnreadOrderNotifyMsgAmount object:nil userInfo:nil];
        });
    }];
}
-(void)checkNoticeCount{
    YYUser *user = [YYUser currentUser];
    if(user.userType==0 || user.userType==2 || [YYUser isShowroomToBrand]){
        if (![YYNetworkReachability connectedToNetwork] || self.mainViewController == nil || !user.email) {
            return;
        }
        NSString *type = @"";
        [YYOrderApi getUnreadNotifyMsgAmount:type andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSInteger orderMsgCount,NSInteger connMsgCount, NSError *error) {
            self.unreadOrderNotifyMsgAmount = orderMsgCount;
            self.unreadConnNotifyMsgAmount = connMsgCount;
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:UnreadConnNotifyMsgAmount object:nil userInfo:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:UnreadOrderNotifyMsgAmount object:nil userInfo:nil];
            });
        }];
    }
}

-(void)checkUserStatus{
    YYUser *user = [YYUser currentUser];
    if (![YYNetworkReachability connectedToNetwork] || self.mainViewController == nil || !user.userId) {
        return;
    }
    [YYUserApi getUserStatus:-1 andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSInteger status, NSError *error) {
        if(rspStatusAndMessage.status == kCode100){
            if(status >-1){
                user.userStatus = status;
                [user saveUserData];
            }
        }
    }];
}
#pragma mark - --------------跳转视图----------------------
//进入产品介绍
-(void)enterIntroPage{
    NSArray *coverImageNames = nil;
    if([LanguageManager isEnglishLanguage]){
        coverImageNames = @[@"introImage1_en", @"introImage2_en", @"introImage3_en"];
    }else{
        coverImageNames = @[@"introImage1", @"introImage2", @"introImage3"];
    }
    UIButton *enterButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 200, 45)];
    [enterButton setBackgroundColor:[UIColor blackColor]];
    [enterButton setTitle:NSLocalizedString(@"开始体验",nil) forState:UIControlStateNormal];
    YYIntroductionViewController *introductionView = [[YYIntroductionViewController alloc] initWithCoverImageNames:coverImageNames backgroundImageNames:nil button:enterButton];
    introductionView.view.backgroundColor = [UIColor whiteColor];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] ;
    self.window.rootViewController =introductionView;
    [self.window makeKeyAndVisible];
    WeakSelf(ws);
    introductionView.didSelectedEnter = ^() {
        [ws autoLogin];
    };
}

//进入首页
- (void)enterMainIndexPage{
    YYUser *user = [YYUser currentUser];
    if(user.userType == 5||user.userType == 6)
    {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        _mainViewController = [[UINavigationController alloc] initWithRootViewController:[[YYShowroomMainViewController alloc] init]];
        [self.window makeKeyAndVisible];
        appDelegate.window.rootViewController = _mainViewController;

        [self checkUserStatus];
    }else
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        _mainViewController = [storyboard instantiateViewControllerWithIdentifier:@"Main_NavigationController"];
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        appDelegate.window.rootViewController = _mainViewController;
        [self.window makeKeyAndVisible];

        [self checkNewFunctionTip];
        [self checkNoticeCount];
        [self checkUserStatus];
    }
}

//进入登录
- (void)enterLoginPage{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    UINavigationController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"Login_NavigationController"];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.leftMenuIndex = 0;
    appDelegate.window.rootViewController = loginViewController;
    [self.window makeKeyAndVisible];
}
- (void)showStyleInfoViewController:(YYStyleInfoModel *)infoModel parentViewController:(UIViewController*)viewController IsShowroomToScan:(BOOL)isShowroomToScan{
    YYOrderInfoModel *cartModel = self.cartModel;

    [UITableView appearance].estimatedRowHeight = 0;
    [UITableView appearance].estimatedSectionHeaderHeight = 0;
    [UITableView appearance].estimatedSectionFooterHeight = 0;

    YYOpusSeriesModel *opusSeriesModel = [[YYOpusSeriesModel alloc] init];
    opusSeriesModel.designerId = cartModel.designerId;
    opusSeriesModel.albumImg = infoModel.style.albumImg;
    opusSeriesModel.supplyStatus = infoModel.style.supplyStatus;
    opusSeriesModel.orderAmountMin = infoModel.style.orderAmountMin;
    opusSeriesModel.name = infoModel.style.seriesName;
    opusSeriesModel.id = infoModel.style.seriesId;
    opusSeriesModel.status = infoModel.style.seriesStatus;

    YYOpusStyleModel *opusStyleModel = [[YYOpusStyleModel alloc] init];
    opusStyleModel.albumImg = infoModel.style.albumImg;
    //  opusStyleModel.category =
    opusStyleModel.modifyTime = [infoModel.style.modifyTime stringValue];
    opusStyleModel.name = infoModel.style.name;
    opusStyleModel.id = infoModel.style.id;
    //        opusStyleModel.seriesName = oneInfoModel.seriesName;
    opusStyleModel.seriesId = infoModel.style.seriesId;
    opusStyleModel.styleCode = infoModel.style.styleCode;
    //  opusStyleModel.region =
    opusStyleModel.tradePrice = infoModel.style.tradePrice;
    opusStyleModel.retailPrice = infoModel.style.retailPrice;
    opusStyleModel.dateRange = infoModel.dateRange;

    NSMutableArray * onlineOpusStyleArray = [[NSMutableArray alloc] initWithCapacity:0];
    [onlineOpusStyleArray addObject:opusStyleModel];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Opus" bundle:[NSBundle mainBundle]];
    YYStyleDetailViewController *styleDetailViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYStyleDetailViewController"];
    styleDetailViewController.onlineOrOfflineOpusStyleArray = onlineOpusStyleArray;


    NSString *folderName = [NSString stringWithFormat:@"%li",[infoModel.style.seriesId longValue]];
    NSString *offlineFilePath = [yyjOfflineSeriesDirectory() stringByAppendingPathComponent:folderName];
    NSString *styleListJsonPath = [offlineFilePath stringByAppendingPathComponent:@"styleList.json"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:styleListJsonPath]){
        styleDetailViewController.currentDataReadType = DataReadTypeOffline;
    }else{
        if ([YYNetworkReachability connectedToNetwork]) {
            styleDetailViewController.currentDataReadType = DataReadTypeOnline;
        }else{
            styleDetailViewController.currentDataReadType = DataReadTypeCached;
            styleDetailViewController.cachedOpusStyleArray = onlineOpusStyleArray;
        }
    }

    styleDetailViewController.opusSeriesModel = opusSeriesModel;
    styleDetailViewController.currentIndex = 0;
    styleDetailViewController.totalPages = 1;
    styleDetailViewController.isShowroomToScan = isShowroomToScan;
    styleDetailViewController.isToScan = YES;
    [viewController.navigationController pushViewController:styleDetailViewController animated:YES];
}
-(void)showBuildOrderViewController:(YYOrderInfoModel *)orderInfoModel parent:(UIViewController *)parentViewController isCreatOrder:(Boolean)isCreatOrder isReBuildOrder:(Boolean)isReBuildOrder isAppendOrder:(Boolean)isAppendOrder modifySuccess:(ModifySuccess)modifySuccess{

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"OrderDetail" bundle:[NSBundle mainBundle]];
    YYOrderModifyViewController *orderModifyViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYOrderModifyViewController"];

    orderModifyViewController.currentYYOrderInfoModel = orderInfoModel;
    orderModifyViewController.isCreatOrder = isCreatOrder;
    orderModifyViewController.isReBuildOrder = isReBuildOrder;
    orderModifyViewController.isAppendOrder = isAppendOrder;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:orderModifyViewController];
    nav.navigationBar.hidden = YES;
    __block YYOrderModifyViewController * blockOrderModifyViewController = orderModifyViewController;
    __block UIViewController * blockParentViewController = parentViewController;
    [orderModifyViewController setCloseButtonClicked:^(){
        [blockParentViewController dismissViewControllerAnimated:YES completion:^{
            blockOrderModifyViewController= nil;
        }];
    }];
    __block ModifySuccess blockModifySuccess =modifySuccess;
    [orderModifyViewController setModifySuccess:^(){
        [blockParentViewController dismissViewControllerAnimated:YES completion:^{
            blockOrderModifyViewController= nil;
            if(blockModifySuccess){
                blockModifySuccess();
            }
        }];

    }];

    [parentViewController presentViewController:nav animated:YES completion:nil];
}
- (void)showShoppingViewNew:(BOOL )isModifyOrder styleInfoModel:(id )styleInfoModel seriesModel:(id)seriesModel opusStyleModel:(YYOpusStyleModel *)opusStyleModel currentYYOrderInfoModel:(YYOrderInfoModel *)currentYYOrderInfoModel parentView:(UIView *)parentView fromBrandSeriesView:(BOOL )isFromSeries WithBlock:(void (^)(YYBrandSeriesToCartTempModel *brandSeriesToCardTempModel))block{
    YYStyleInfoModel *tempStyleInfoModel = nil;
    YYOpusSeriesModel *tempOpusSeriesModel = nil;
    if ([styleInfoModel isKindOfClass:[YYStyleInfoModel class]]) {
        tempStyleInfoModel = styleInfoModel;
    }else if([styleInfoModel isKindOfClass:[StyleDetail class]]){
        YYStyleInfoModel *convertStyleInfoModel = [[YYStyleInfoModel alloc] init];
        //尺寸部份
        StyleDetail *styleDetail = styleInfoModel;
        NSArray *sizeArray = [styleDetail.sizes allObjects];
        if (sizeArray && [sizeArray count] > 0) {
            NSMutableArray *mutableArray = [[NSMutableArray alloc] initWithCapacity:0];

            for (StyleDeatilSizes *styleDeatilSizes in sizeArray) {
                YYSizeModel *sizeModel = [[YYSizeModel alloc] init];
                sizeModel.id = styleDeatilSizes.size_id;
                sizeModel.value = styleDeatilSizes.size_value;
                [mutableArray addObject:sizeModel];
            }
            convertStyleInfoModel.size = (NSArray<YYSizeModel> *)mutableArray;
        }
        //颜色部份
        NSArray *colorArray = [styleDetail.colors allObjects];
        if (colorArray && [colorArray count] > 0) {
            NSMutableArray *mutableArray = [[NSMutableArray alloc] initWithCapacity:0];

            for (StyleDetailColors *styleDetailColors in colorArray) {
                YYColorModel *colorModel = [[YYColorModel alloc] init];
                colorModel.id = styleDetailColors.color_id;
                colorModel.value = styleDetailColors.color_value;
                colorModel.name = styleDetailColors.color_name;
                NSArray *images = [styleDetailColors.images allObjects];
                if (images && [images count] > 0) {
                    NSMutableArray *mutableArrayImages = [[NSMutableArray alloc] initWithCapacity:0];
                    for (StyleDetailColorImages *styleDetailColorImages in images) {
                        [mutableArrayImages addObject:styleDetailColorImages.image_path];
                    }
                    colorModel.imgs = mutableArrayImages;
                }
                colorModel.styleCode = styleDetailColors.style_code;
                colorModel.materials = styleDetailColors.materials;
                colorModel.tradePrice = styleDetailColors.trade_price;
                colorModel.retailPrice = styleDetailColors.retail_price;
                colorModel.stock = styleDetailColors.stock;
                colorModel.sizeStocks = styleDetailColors.size_stocks;

                [mutableArray addObject:colorModel];
            }
            convertStyleInfoModel.colorImages = (NSArray<YYColorModel> *)mutableArray;
        }

        //款式详情部
        YYStyleInfoDetailModel *styleInfoDetailModel = [[YYStyleInfoDetailModel alloc] init];
        styleInfoDetailModel.albumImg = styleDetail.albumImg;
        styleInfoDetailModel.styleCode = styleDetail.styleCode;
        styleInfoDetailModel.materials = styleDetail.materials;
        styleInfoDetailModel.name = styleDetail.name;
        styleInfoDetailModel.category = styleDetail.category;
        styleInfoDetailModel.region = styleDetail.region;
        styleInfoDetailModel.sizeCatName = styleDetail.sizeCatName;
        styleInfoDetailModel.designerId = styleDetail.designerId;
        styleInfoDetailModel.orderAmountMin = styleDetail.orderAmountMin;
        styleInfoDetailModel.id = styleDetail.style_id;
        styleInfoDetailModel.finalPrice = nil;
        styleInfoDetailModel.tradePrice = styleDetail.tradePrice;
        styleInfoDetailModel.retailPrice = styleDetail.retailPrice;
        styleInfoDetailModel.modifyTime = styleDetail.modifyTime;
        styleInfoDetailModel.seriesId = styleDetail.series_id;
        
        convertStyleInfoModel.style = styleInfoDetailModel;
        convertStyleInfoModel.dateRange = transferToYYDateRangeModel(styleDetail.date_range);
        convertStyleInfoModel.stockEnabled = styleDetail.stockEnabled;
        tempStyleInfoModel = convertStyleInfoModel;
    }else if([styleInfoModel isKindOfClass:[YYOrderStyleModel class]]){
        YYStyleInfoModel *convertStyleInfoModel = [[YYStyleInfoModel alloc] init];
        YYOrderStyleModel *orderStyleModel = styleInfoModel;
        //尺寸部份
        NSArray *sizeArray = orderStyleModel.sizeNameList;
        if (sizeArray && [sizeArray count] > 0) {
            NSMutableArray *mutableArray = [[NSMutableArray alloc] initWithCapacity:0];
            for (YYSizeModel *orderSizeDetailModel in sizeArray) {
                YYSizeModel *sizeModel = [[YYSizeModel alloc] init];
                sizeModel.id = orderSizeDetailModel.id;
                sizeModel.value = orderSizeDetailModel.value;
                [mutableArray addObject:sizeModel];
            }
            convertStyleInfoModel.size = (NSArray<YYSizeModel> *)mutableArray;
        }
        //颜色部份
        NSArray *colorArray = orderStyleModel.colors;
        if (colorArray && [colorArray count] > 0) {
            NSMutableArray *mutableArray = [[NSMutableArray alloc] initWithCapacity:0];
            for (YYOrderOneColorModel *orderOneColorModel in colorArray) {
                YYColorModel *colorModel = [[YYColorModel alloc] init];
                colorModel.id = orderOneColorModel.colorId;
                colorModel.value = orderOneColorModel.value;
                colorModel.name = orderOneColorModel.name;
                colorModel.styleCode = orderOneColorModel.styleCode;
                colorModel.imgs = orderOneColorModel.imgs;
                colorModel.tradePrice = orderOneColorModel.originalPrice;
                colorModel.isSelect = orderOneColorModel.isColorSelect;
                NSMutableArray *sizeStocks = [NSMutableArray array];
                for (YYSizeModel *orderSizeDetailModel in sizeArray) {
                    for (YYOrderSizeModel *sizeModel in orderOneColorModel.sizes) {
                        if ([orderSizeDetailModel.id isEqualToNumber:sizeModel.sizeId]) {
                            [sizeStocks addObject:sizeModel.stock ? sizeModel.stock : @(0)];
                        }
                    }
                }
                colorModel.sizeStocks = sizeStocks;
                
                [mutableArray addObject:colorModel];
            }
            convertStyleInfoModel.colorImages = (NSArray<YYColorModel> *)mutableArray;
        }
        //款式详情部份
        YYStyleInfoDetailModel *styleInfoDetailModel = [[YYStyleInfoDetailModel alloc] init];
        styleInfoDetailModel.albumImg = orderStyleModel.albumImg;
        styleInfoDetailModel.styleCode = orderStyleModel.styleCode;
        styleInfoDetailModel.name = orderStyleModel.name;
        styleInfoDetailModel.orderAmountMin = orderStyleModel.orderAmountMin;
        styleInfoDetailModel.id = orderStyleModel.styleId;
        styleInfoDetailModel.finalPrice = orderStyleModel.finalPrice;
        styleInfoDetailModel.tradePrice = orderStyleModel.originalPrice;
        styleInfoDetailModel.retailPrice = orderStyleModel.retailPrice;
        styleInfoDetailModel.modifyTime = orderStyleModel.styleModifyTime;
        styleInfoDetailModel.curType= orderStyleModel.curType;
        styleInfoDetailModel.seriesId = orderStyleModel.seriesId;
        styleInfoDetailModel.supportAdd = orderStyleModel.supportAdd;
        
        convertStyleInfoModel.dateRange = orderStyleModel.tmpDateRange;
        convertStyleInfoModel.style = styleInfoDetailModel;
        convertStyleInfoModel.stockEnabled = orderStyleModel.stockEnabled;
        tempStyleInfoModel = convertStyleInfoModel;
    }


    // YYOpusSeriesModel  Series
    if ([seriesModel isKindOfClass:[YYOpusSeriesModel class]]) {
        tempOpusSeriesModel = seriesModel;
    }else if([seriesModel isKindOfClass:[Series class]]){
        Series *series = seriesModel;
        YYOpusSeriesModel *opusSeriesModel = [[YYOpusSeriesModel alloc] init];
        opusSeriesModel.designerId = series.designer_id;
        opusSeriesModel.year = series.year;
        opusSeriesModel.albumImg = series.album_img;
        opusSeriesModel.styleAmount = series.styleAmount;
        opusSeriesModel.orderDueTime = series.order_due_time;
        opusSeriesModel.supplyStatus = series.supply_status;

        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        opusSeriesModel.supplyEndTime = [numberFormatter numberFromString:series.supply_end_time];
        opusSeriesModel.supplyStartTime = [numberFormatter numberFromString:series.supply_start_time];
        opusSeriesModel.name = series.name;
        opusSeriesModel.season = series.season;
        opusSeriesModel.id = series.series_id;
        opusSeriesModel.authType = series.auth_type;
        opusSeriesModel.orderAmountMin = series.order_amount_min;
        opusSeriesModel.stockEnabled = @(series.stock_enabled);
        tempOpusSeriesModel = opusSeriesModel;
    }else if([seriesModel isKindOfClass:[YYOrderSeriesModel class]]){
        YYOrderSeriesModel *orderSeriesModel = seriesModel;
        YYOpusSeriesModel *opusSeriesModel = [[YYOpusSeriesModel alloc] init];
        opusSeriesModel.name = orderSeriesModel.name;
        opusSeriesModel.id = orderSeriesModel.seriesId;
        opusSeriesModel.orderAmountMin = orderSeriesModel.orderAmountMin;
        opusSeriesModel.supplyStatus = orderSeriesModel.supplyStatus;
        tempOpusSeriesModel = opusSeriesModel;
    }


    if ((!tempStyleInfoModel || !tempOpusSeriesModel)&& opusStyleModel == nil) {
        //数据不全，给出提示
        return;
    }

    YYShoppingView *shoppingView = [[YYShoppingView alloc] initWithStyleInfoModel:tempStyleInfoModel WithOpusSeriesModel:tempOpusSeriesModel WithOpusStyleModel:opusStyleModel WithIsModifyOrder:isModifyOrder WithCurrentYYOrderInfoModel:currentYYOrderInfoModel fromBrandSeriesView:isFromSeries WithBlock:^(YYBrandSeriesToCartTempModel *brandSeriesToCardTempModel) {
        if(block){
            block(brandSeriesToCardTempModel);
        }
    }];

    [parentView addSubview:shoppingView];
}

//#pragma mark - --------------系统代理----------------------


//#pragma mark - --------------自定义代理/block----------------------


//#pragma mark - --------------自定义响应----------------------


#pragma mark - --------------自定义方法----------------------
- (void)delegateTempDataClear{
    self.unreadOrderNotifyMsgAmount = 0;
    self.unreadConnNotifyMsgAmount = 0;

    self.isOnOrderNotifyMsgUI = NO;
    self.isOnConnNotifyMsgAUI = NO;
    
    self.delegate_series_id = nil;
}
- (void)reloadRootViewController:(NSInteger)index{
    YYUser *user = [YYUser currentUser];
    if(user.userType == 5||user.userType == 6)
    {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        _mainViewController = [[UINavigationController alloc] initWithRootViewController:[[YYShowroomMainViewController alloc] init]];
        [self.window makeKeyAndVisible];
        appDelegate.window.rootViewController = _mainViewController;
    }else{
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        _mainViewController = [storyboard instantiateViewControllerWithIdentifier:@"Main_NavigationController"];
        appDelegate.window.rootViewController = _mainViewController;
        [self.window makeKeyAndVisible];
    }
}

- (void)clearBuyCar{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault removeObjectForKey:KUserCartKey];
    [userDefault removeObjectForKey:KUserCartMoneyTypeKey];
    [userDefault synchronize];
    appDelegate.cartMoneyType = -1;
    appDelegate.cartModel = nil;
    appDelegate.seriesArray = [[NSMutableArray alloc] init];

    //更新购物车按钮数量
    [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateShoppingCarNotification object:nil];
}
// log NSSet with UTF8
// if not ,log will be \Uxxx
- (NSString *)logDic:(NSDictionary *)dic {
    if (![dic count]) {
        return nil;
    }
    NSString *tempStr1 =
    [[dic description] stringByReplacingOccurrencesOfString:@"\\u"
                                                 withString:@"\\U"];
    NSString *tempStr2 =
    [tempStr1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    NSString *tempStr3 =
    [[@"\"" stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
    NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
    NSString *str =
    [NSPropertyListSerialization propertyListFromData:tempData
                                     mutabilityOption:NSPropertyListImmutable
                                               format:NULL
                                     errorDescription:NULL];
    return str;
}
-(void)clearLocalFile{
    NSString *cacheDir = yyjDocumentsDirectory();
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:cacheDir error:nil];

    [[SDImageCache sharedImageCache] clearDiskOnCompletion:nil];
    [[SDImageCache sharedImageCache] clearMemory];//可有可无
}

-(void)checkNewFunctionTip{
    NSString *versionStr = kYYCurrentVersion;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    __block  NSString *blockkey = [NSString stringWithFormat:@"%@_%@",kNoLongerRemindNewFuntion,versionStr];
    if([userDefaults objectForKey:blockkey] != nil){
        return;
    }

    if ([versionStr isEqualToString:@"3.10"]) {

        [[YYYellowPanelManage instance] showYellowUserCheckAlertPanel:@"Main" andIdentifier:@"YYUserCheckAlertViewController" title:@"YCO SYSTEM 4.3 版本" msg:@"自定义权限 · 帮助系统" iconStr:@"identity_New_icon"  btnStr:NSLocalizedString(@"开启 YCO SYSTEM",nil) align:NSTextAlignmentCenter closeBtn:YES funArray:@[@"自定义作品权限，轻松规定白名单与黑名单",@"帮助中心全新改版，更系统，更高效"] andCallBack:^(NSArray *value) {

        }];
        [userDefaults setObject:@"true" forKey:blockkey];
        [userDefaults synchronize];
    }
}



- (void)addObserverForNeedLogin{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(needLogin:)
                                                 name:kNeedLoginNotification
                                               object:nil];
}

// 测试把timer加到不运行的runloop上的情况
- (void)setTimerSheduleToRunloop
{
    //NSLog(@"Test timer shedult to a non-running runloop");
    NSTimer *timer = [[NSTimer alloc] initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:1] interval:60*1 target:self selector:@selector(timerAction:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    // 打开下面一行输出runloop的内容就可以看出，timer却是已经被添加进去
    //NSLog(@"the thread's runloop: %@", [NSRunLoop currentRunLoop]);

    // 打开下面一行, 该线程的runloop就会运行起来，timer才会起作用
    // [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:3]];
    [[NSRunLoop currentRunLoop] run];
}



- (void)needLogin:(NSNotification *)note{
    YYUser *user = [YYUser currentUser];
    [user loginOut];
    [self enterLoginPage];
}

- (void)addObserverForKeyboard{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
}

- (void)keyboardWillShow:(NSNotification *)note
{
    //获取键盘高度
    NSDictionary *info = [note userInfo];
    NSValue *value = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGSize keyboardSize = [value CGRectValue].size;

    if (SYSTEM_VERSION_LESS_THAN(@"8.0")){
        self.keyBoardHeight = keyboardSize.width;
    }else{
        self.keyBoardHeight = keyboardSize.height;
    }

    self.keyBoardIsShowNow = YES;
}

- (void)keyboardWillHide:(NSNotification *)note
{
    self.keyBoardIsShowNow = NO;
}

- (void)initUmeng{
    UMConfigInstance.appKey = @"596f3d9e734be417a3000960";
    //配置以上参数后调用此方法初始化SDK！
    [MobClick startWithConfigure:UMConfigInstance];
    // 设置verson为版本号
    [MobClick setAppVersion:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
}

// 创建网络监听
//使用AFN框架来检测网络状态的改变
-(void)AFNReachability
{
    //1.创建网络监听管理者
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];

    //2.监听网络状态的改变
    /*
     AFNetworkReachabilityStatusUnknown     = 未知
     AFNetworkReachabilityStatusNotReachable   = 没有网络
     AFNetworkReachabilityStatusReachableViaWWAN = 手机网络
     AFNetworkReachabilityStatusReachableViaWiFi = WIFI
     */

    //    [[NSNotificationCenter defaultCenter] addObserver:self
    //                                             selector:@selector(reachabilityChanged:)
    //                                                 name:kRealReachabilityChangedNotification
    //                                               object:nil];

    //这里可以添加一些自己的逻辑
    YYCurrentNetworkSpace *networkSpace = [YYCurrentNetworkSpace shareModel];
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
                // "未知"
                networkSpace.currentNetwork = kYYNetworkUnknow;
                NSLog(@"==========未知");
                break;
            case AFNetworkReachabilityStatusNotReachable:
                //"没有网络"
                networkSpace.currentNetwork = kYYNetworkNotReachable;
                NSLog(@"==========2");
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                //"移动网络"
                networkSpace.currentNetwork = kYYNetworkWWAN;
                NSLog(@"==========3");
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                //"WIFI"
                networkSpace.currentNetwork = kYYNetworkWifi;
                NSLog(@"==========4");
                break;

            default:
                break;
        }
        _isStartNetworkSpace = false;
        NSNotification *notification =[NSNotification notificationWithName:kNetWorkSpaceChangedNotification object:nil];
        // 通过通知中心发送通知
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }];

    //3.开始监听
    [manager startMonitoring];
}

#pragma mark - --------------other----------------------








@end

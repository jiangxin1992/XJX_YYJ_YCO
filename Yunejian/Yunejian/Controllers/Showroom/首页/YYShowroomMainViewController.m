//
//  YYShowroomMainViewController.m
//  Yunejian
//
//  Created by yyj on 2017/3/20.
//  Copyright © 2017年 yyj. All rights reserved.
//

#import "YYShowroomMainViewController.h"

#import "YYAccountDetailViewController.h"
#import "YYSettingViewController.h"
#import "YYMainViewController.h"
#import "YYShowroomNotificationListViewController.h"

#import "YYShowroomMainNoDataView.h"
#import "YYShowroomMainCollectionView.h"
#import "YYNavView.h"
#import "DD_CircleSearchView.h"
#import "YYTypeButton.h"

#import "UserDefaultsMacro.h"
#import <MessageUI/MFMailComposeViewController.h>
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreLocation/CoreLocation.h>
#import "AppDelegate.h"
#import <MJRefresh.h>
#import "MBProgressHUD.h"
#import "YYShowroomApi.h"
#import "YYShowroomBrandTool.h"
#import "YYShowRoomBrandListModel.h"

#import "YYQRCode.h"
#import "YYScanFunctionModel.h"
#import "YYOpusApi.h"
#import "YYUser.h"

@interface YYShowroomMainViewController ()
@property (strong ,nonatomic) NSMutableArray *arrayData;//排序好的数据
@property (strong ,nonatomic) DD_CircleSearchView *searchView;

@property (strong, nonatomic) YYShowroomMainCollectionView *collectionView;
@property (strong ,nonatomic) YYShowroomBrandListModel *ShowroomBrandListModel;
@property (strong ,nonatomic) YYShowroomMainNoDataView *noDataView;
@property (strong ,nonatomic) UIImageView *mengban;
@property (strong ,nonatomic) UIImageView *zbar;

//导航栏上的  调用出来用来改变他的透明度
@property (assign ,nonatomic) CGFloat alpha;
@property (nonatomic ,strong) UIImageView *barImageView;
@property (nonatomic ,strong) YYNavView *navView;

@property(nonatomic,strong) YYSettingViewController *settingViewController;

@property (nonatomic, strong) YYUser *currentUser;

@property (nonatomic ,strong) UIView *notRedView;
@property (nonatomic ,assign) NSInteger permissionStatus;//-1 未获取 0没有权限 1有权限
@property (nonatomic ,assign) BOOL hasOrderingMsg;

@end

@implementation YYShowroomMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self SomePrepare];
    [self UIConfig];
    [self RequestData];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if(_searchView){
        [self.navigationController setNavigationBarHidden:YES animated:NO];
    }else{
        [self.navigationController setNavigationBarHidden:NO animated:NO];
    }
    // 进入埋点
    [MobClick beginLogPageView:kYYPageShowroomMain];

    if(self.alpha<1.0f){
        self.barImageView.alpha = 0;
        self.navView.alpha = 0;
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if(self.alpha<1.0f){
        self.barImageView.alpha = 0;
        self.navView.alpha = 0;
    }
}
#pragma mark - SomePrepare
-(void)SomePrepare
{
    [self PrepareData];
    [self PrepareUI];
}
-(void)PrepareData{
    //清除购物车
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate clearBuyCar];
    
    _arrayData = [[NSMutableArray alloc] init];

    self.currentUser = [YYUser currentUser];
    if(_currentUser.userType == YYUserTypeShowroom){
        //showroom权限
        self.permissionStatus = 1;
    }else{
        //非showroom权限 一般默认为showroom_sub权限
        self.permissionStatus = -1;
    }
    self.hasOrderingMsg = NO;
}
-(void)PrepareUI{
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    self.view.backgroundColor = _define_white_color;
    
    _navView = [[YYNavView alloc] initWithTitle:@""];
    self.navigationItem.titleView = _navView;
    
    UIButton *searchButton = [UIButton getCustomImgBtnWithImageStr:@"search_Showroom_icon" WithSelectedImageStr:nil];
    [searchButton addTarget:self action:@selector(searchAction) forControlEvents:UIControlEventTouchUpInside];
    [searchButton setAdjustsImageWhenHighlighted:NO];
    searchButton.opaque = NO;
    searchButton.frame = CGRectMake(0, 0, 44, 44);
    
    UIButton *setButton = [UIButton getCustomImgBtnWithImageStr:@"set_Showroom_icon" WithSelectedImageStr:nil];
    [setButton addTarget:self action:@selector(setAction) forControlEvents:UIControlEventTouchUpInside];
    [setButton setAdjustsImageWhenHighlighted:NO];
    setButton.opaque = NO;
    setButton.frame = CGRectMake(0, 0, 44, 44);

    UIButton *notificationButton = [UIButton getCustomImgBtnWithImageStr:@"not_Showroom_icon" WithSelectedImageStr:nil];
    [notificationButton addTarget:self action:@selector(notificationAction) forControlEvents:UIControlEventTouchUpInside];
    [notificationButton setAdjustsImageWhenHighlighted:NO];
    notificationButton.opaque = NO;
    notificationButton.frame = CGRectMake(0, 0, 44, 44);

    _notRedView = [UIView getCustomViewWithColor:[UIColor colorWithHex:@"EF4E31"]];
    [notificationButton addSubview:_notRedView];
    [_notRedView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.width.height.mas_equalTo(8);
    }];
    _notRedView.layer.masksToBounds = YES;
    _notRedView.layer.cornerRadius = 4.0f;
    _notRedView.hidden = YES;

    self.navigationItem.rightBarButtonItems = @[
                                                [[UIBarButtonItem alloc] initWithCustomView:setButton]
                                                ,[[UIBarButtonItem alloc] initWithCustomView:searchButton]
                                                ,[[UIBarButtonItem alloc] initWithCustomView:notificationButton]
                                                ];


    UIButton *sweepYardButton = [UIButton getCustomImgBtnWithImageStr:@"scan_showroom_icon" WithSelectedImageStr:nil];
    [sweepYardButton addTarget:self action:@selector(sweepYardButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [sweepYardButton setAdjustsImageWhenHighlighted:NO];
    sweepYardButton.opaque = NO;
    sweepYardButton.frame = CGRectMake(0, 0, 44, 44);
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:sweepYardButton];
    

    _alpha = 0.0;
    _barImageView = [self.navigationController.navigationBar.subviews firstObject];
    _barImageView.backgroundColor = _define_white_color;
    _barImageView.alpha = _alpha;
    _navView.alpha = _alpha;
    
}
-(void)notificationAction{
    if(_permissionStatus == 1){
        WeakSelf(ws);
        YYShowroomNotificationListViewController *notificationList = [[YYShowroomNotificationListViewController alloc] init];
        [notificationList setCancelButtonClicked:^(){
            [ws getHasOrderingMsg];
        }];
        notificationList.hasOrderingMsg = _hasOrderingMsg;
        [self.navigationController pushViewController:notificationList animated:YES];
    }else{
        [YYToast showToastWithTitle:NSLocalizedString(@"您没有权限查看活动审核内容",nil) andDuration:kAlertToastDuration];
    }
}
-(void)updatePermission{
    WeakSelf(ws);
    [YYShowroomApi hasPermissionToVisitOrderingWithBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, BOOL hasPermission, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:ws.view animated:YES];
        if(rspStatusAndMessage.status == YYReqStatusCode100){
            if(hasPermission){
                ws.permissionStatus = 1;
                //获取红星
                [ws getHasOrderingMsg];
            }else{
                ws.permissionStatus = 0;
            }
        }else{
            ws.permissionStatus = -1;
        }
    }];
}
-(void)setHasOrderingMsg:(BOOL)hasOrderingMsg{
    _hasOrderingMsg = hasOrderingMsg;
    if(_notRedView){
        _notRedView.hidden = !_hasOrderingMsg;
    }
}
-(void)getHasOrderingMsg{
    WeakSelf(ws);
    if(_permissionStatus == 1){
        [YYShowroomApi hasOrderingMsgWithBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, BOOL hasMsg, NSError *error) {
            if(rspStatusAndMessage.status == YYReqStatusCode100){
                ws.hasOrderingMsg = hasMsg;
            }else{
                ws.hasOrderingMsg = NO;
            }
        }];
    }
}
-(void)updateData
{
    [_arrayData removeAllObjects];
    
    NSMutableDictionary *_dictPinyinAndChinese = [YYShowroomBrandTool getPinyinAndChinese];//用于存放分类好的数据
//    [_ShowroomBrandListModel getTestModel];
    for (YYShowroomBrandModel *model in _ShowroomBrandListModel.brandList) {
        
        NSString *pinyin = [[model.brandName transformToPinyin] uppercaseString];
        
        NSString *charFirst = [pinyin substringToIndex:1];
        //从字典中招关于G的键值对
        NSMutableArray *charArray  = [_dictPinyinAndChinese objectForKey:charFirst];
        //没有找到
        if (charArray) {
            [charArray addObject:model];
            
        }else
        {
            NSMutableArray *subArray = [_dictPinyinAndChinese objectForKey:@"#"];
            //“关羽”
            [subArray addObject:model];
        }
    }
    
    //获取最终的数据／排序好的数据数组
    NSArray *_arrayChar = [YYShowroomBrandTool getCharArr];//用于存放索引
    [_arrayChar enumerateObjectsUsingBlock:^(NSString *charstr, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMutableArray *tempArr = [_dictPinyinAndChinese objectForKey:charstr];
        if(tempArr.count){
            [_arrayData addObjectsFromArray:tempArr];
        }
    }];
}

#pragma mark - UIConfig
-(void)UIConfig{
    [self CreateOrUpdateCollectionView];
    [self addHeader];
}
-(void)CreateOrUpdateCollectionView{
    if(!_collectionView){
        WeakSelf(ws);
        _collectionView = [[YYShowroomMainCollectionView alloc] initWithFrame:CGRectMake(0, -kNavigationBarHeight, SCREEN_WIDTH, SCREEN_HEIGHT+kNavigationBarHeight)];
        [self.view addSubview:_collectionView];
        [_collectionView setScrollViewDelegateBlock:^(NSString *type, CGFloat contentOffsetY) {
            if([type isEqualToString:@"scrollviewdidscroll"]){
                ws.alpha = (double)(contentOffsetY / ((240.0f/2048.0f)*SCREEN_WIDTH-90)) -1.0f;
                ws.barImageView.alpha = ws.alpha;
                ws.navView.alpha = ws.alpha;
            }else if([type isEqualToString:@"navviewdismiss"]){
                if(ws.alpha<1.0f)
                {
                    [UIView beginAnimations:@"anmationName_dismiss" context:nil];
                    [UIView setAnimationDuration:0.3];
                    [UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
                    [UIView setAnimationDelegate:ws];
                    ws.barImageView.alpha = 0;
                    ws.navView.alpha = 0;
                    [UIView commitAnimations];
                }
            }
        }];
        [_collectionView setCollectionViewDelegateBlock:^(NSString *type, NSIndexPath *indexPath) {
            if([type isEqualToString:@"headclick"]){
                //跳转个人信息页面
                [ws pushPersonView];
            }else if([type isEqualToString:@"didselect"]){
                YYShowroomBrandModel *showroomModel = [ws.arrayData objectAtIndex:indexPath.row];
                [ws pushShowroomBrandVC:showroomModel];
            }
        }];
        _collectionView.alwaysBounceVertical = YES;
    }
    _collectionView.arrayData = _arrayData;
    _collectionView.listModel = _ShowroomBrandListModel;
    _collectionView.haveHeadView = YES;
    [_collectionView reloadCollectionData];
}
-(void)addHeader{
    WeakSelf(ws);
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [ws RequestData];
    }];
    self.collectionView.mj_header = header;
    self.collectionView.mj_header.automaticallyChangeAlpha = YES;
    header.lastUpdatedTimeLabel.hidden = YES;
}
-(void)CreateOrMoveNoDataView
{
    if(!_noDataView)
    {
        _noDataView = [[YYShowroomMainNoDataView alloc] initWithSuperView:_collectionView Block:^(NSString *type) {
            if([type isEqualToString:@"showhelp"])
            {
                [self ShowWechat2Dbarcode];
            }
        }];
    }
    if(_ShowroomBrandListModel.brandList.count)
    {
        _noDataView.hidden = YES;
    }else{
        _noDataView.hidden = NO;
    }
}
#pragma mark - RequestData
-(void)RequestData{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    WeakSelf(ws);
    [YYShowroomApi getShowroomBrandListWithBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,YYShowroomBrandListModel *brandListModel,NSError *error) {
        [MBProgressHUD hideAllHUDsForView:ws.view animated:YES];
        if(rspStatusAndMessage.status == YYReqStatusCode100){
            ws.ShowroomBrandListModel = brandListModel;
            [ws updateData];
            [ws CreateOrMoveNoDataView];
            [ws CreateOrUpdateCollectionView];
            
            _navView.navTitle = ws.ShowroomBrandListModel.name;

            if(_currentUser.userType == YYUserTypeShowroom){
                //showroom权限
                [MBProgressHUD hideAllHUDsForView:ws.view animated:YES];
                //获取红星
                [ws getHasOrderingMsg];
            }else{
                //非showroom权限 一般默认为showroom_sub权限
                [ws updatePermission];
            }

        }else{
            [MBProgressHUD hideAllHUDsForView:ws.view animated:YES];
            //获取红星
            [ws getHasOrderingMsg];
            [YYToast showToastWithView:ws.view title:rspStatusAndMessage.message andDuration:kAlertToastDuration];
        }
        [_collectionView.mj_header endRefreshing];
        [_collectionView.mj_footer endRefreshing];
    }];

}
#pragma mark * 显示微信二维码
-(void)ShowWechat2Dbarcode
{
    //显示二维码
    _mengban=[UIImageView getImgWithImageStr:@"System_Transparent_Mask"];
    _mengban.contentMode=UIViewContentModeScaleToFill;
    [self.view.window addSubview:_mengban];
    [_mengban addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeAction)]];
    _mengban.frame=CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    
    UIView *bottomView=[UIView getCustomViewWithColor:[UIColor colorWithRed:255.0f/255.0f green:241.0f/255.0f blue:0 alpha:1]];
    [_mengban addSubview:bottomView];
    bottomView.userInteractionEnabled = YES;
    [bottomView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(NULLACTION)]];
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(_mengban);
        make.width.mas_equalTo(450);
        make.height.mas_equalTo(350);
    }];
    
    UIView *backView=[UIView getCustomViewWithColor:_define_white_color];
    [bottomView addSubview:backView];
    [backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(bottomView);
        make.width.mas_equalTo(432);
        make.height.mas_equalTo(332);
    }];
    
    UIButton *closeBtn=[UIButton getCustomImgBtnWithImageStr:@"top_close_icon" WithSelectedImageStr:nil];
    [backView addSubview:closeBtn];
    [closeBtn addTarget:self action:@selector(closeAction) forControlEvents:UIControlEventTouchUpInside];
    [closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(10);
        make.right.mas_equalTo(-10);
        make.width.height.mas_equalTo(20);
    }];
    
    UILabel *titleLabel = [UILabel getLabelWithAlignment:1 WithTitle:NSLocalizedString(@"联系 YCO 小助手",nil) WithFont:15.0f WithTextColor:nil WithSpacing:0];
    [backView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.top.mas_equalTo(17);
    }];
    
    UIView *line = [UIView getCustomViewWithColor:[UIColor colorWithHex:@"d3d3d3"]];
    [backView addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(titleLabel.mas_bottom).with.offset(14);
        make.centerX.mas_equalTo(backView);
        make.height.mas_equalTo(1);
        make.left.mas_equalTo(47);
        make.right.mas_equalTo(-47);
    }];
    
    _zbar=[UIImageView getImgWithImageStr:@"weixincode_img"];
    [backView addSubview:_zbar];
    [_zbar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(line.mas_bottom).with.offset(18);
        make.centerX.mas_equalTo(backView);
        make.height.width.mas_equalTo(123);
    }];
    
    UILabel *namelabel=[UILabel getLabelWithAlignment:1 WithTitle:[[NSString alloc] initWithFormat:NSLocalizedString(@"微信号：%@",nil),@"yunejianhelper"] WithFont:13.0f WithTextColor:[UIColor colorWithHex:kDefaultTitleColor_pad] WithSpacing:0];
    [backView addSubview:namelabel];
    [namelabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_zbar.mas_bottom).with.offset(8);
        make.centerX.mas_equalTo(backView);
    }];
    
    __block UIView *lastView=nil;
    NSArray *titleArr=@[NSLocalizedString(@"复制微信号",nil),NSLocalizedString(@"保存二维码",nil)];
    [titleArr enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        UIButton *actionbtn=[UIButton getCustomTitleBtnWithAlignment:0 WithFont:13.0f WithSpacing:0 WithNormalTitle:obj WithNormalColor:idx==0?_define_black_color:_define_white_color WithSelectedTitle:nil WithSelectedColor:nil];
        [backView addSubview:actionbtn];
        actionbtn.backgroundColor=idx==0?_define_white_color:_define_black_color;
        setBorder(actionbtn);
        if(!idx){
            //复制微信号
            [actionbtn addTarget:self action:@selector(copyWeixinName) forControlEvents:UIControlEventTouchUpInside];
        }else
        {
            //保存二维码
            [actionbtn addTarget:self action:@selector(saveWeixinPic) forControlEvents:UIControlEventTouchUpInside];
        }
        [actionbtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(-35);
            make.width.mas_equalTo(143);
            make.height.mas_equalTo(39);
            if(!idx)
            {
                make.left.mas_equalTo(backView.mas_centerX).with.offset(20);
            }else
            {
                make.right.mas_equalTo(backView.mas_centerX).with.offset(-20);
            }
        }];
        
        lastView=actionbtn;
    }];
}
-(void)copyWeixinName
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    
    pasteboard.string = @"yunejianhelper";
    
    [YYToast showToastWithTitle:NSLocalizedString(@"成功复制微信号",nil) andDuration:kAlertToastDuration];
    [_mengban removeFromSuperview];
}
-(void)saveWeixinPic
{
    if(_zbar.image)
    {
        ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
        
        if (author == kCLAuthorizationStatusRestricted || author ==kCLAuthorizationStatusDenied){
            [self presentViewController:alertTitleCancel_Simple(NSLocalizedString(@"请在设备的“设置-隐私-照片”中允许访问照片",nil), ^{
                if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]])
                {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                }
            }) animated:YES completion:nil];
        }else
        {
            UIImageWriteToSavedPhotosAlbum(_zbar.image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
            [_mengban removeFromSuperview];
        }
    }
}
-(void)closeAction
{
    [_mengban removeFromSuperview];
}
-(void)NULLACTION{}
- (void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo
{
    if(error != NULL){
        
        [YYToast showToastWithTitle:NSLocalizedString(@"保存图片失败",nil) andDuration:kAlertToastDuration];
    }else{
        
        [YYToast showToastWithTitle:NSLocalizedString(@"保存图片成功",nil) andDuration:kAlertToastDuration];
    }
}
#pragma mark - SomeAction
-(void)pushShowroomBrandVC:(YYShowroomBrandModel *)showroomModel{
    if (![YYNetworkReachability connectedToNetwork]) {
        [YYToast showToastWithTitle:kNetworkIsOfflineTips andDuration:kAlertToastDuration];
    }else{
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        WeakSelf(ws);
        [YYShowroomApi showroomToBrandWithBrandID:showroomModel.brandId andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYUserModel *userModel, NSError *error) {
            [MBProgressHUD hideAllHUDsForView:ws.view animated:YES];
            if(userModel){
                
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                [userDefaults setObject:[[NSString alloc] initWithFormat:@"%ld",(long)[showroomModel.brandId integerValue]] forKey:kTempBrandID];
                [userDefaults synchronize];
                
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
                YYMainViewController *_mainViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYMainViewController"];
                _mainViewController.brandId = showroomModel.brandId;
                [_mainViewController setCancelButtonClicked:^(){
                    [self.navigationController popViewControllerAnimated:YES];
                }];
                [self.navigationController pushViewController:_mainViewController animated:YES];
            }
        }];
    }
}

-(void)pushPersonView
{
    UIStoryboard *accountStoryboard = [UIStoryboard storyboardWithName:@"Account" bundle:[NSBundle mainBundle]];
    
    YYAccountDetailViewController *accountDetailViewController = [accountStoryboard instantiateViewControllerWithIdentifier:@"YYAccountDetailViewController"];
    [accountDetailViewController setCancelButtonClicked:^(){
        [self.navigationController popViewControllerAnimated:YES];
    }];
    [accountDetailViewController setModifySuccess:^(){
        [self RequestData];
    }];
    [self.navigationController pushViewController:accountDetailViewController animated:YES];
}
#pragma mark - 扫码
- (void)sweepYardButtonClicked{
    YYQRCodeController *QRCode = [YYQRCodeController QRCodeSuccessMessageBlock:^(YYQRCodeController *code, NSString *messageString) {

        NSData *JSONData = [messageString dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *responseJSON = [NSJSONSerialization JSONObjectWithData:JSONData options:NSJSONReadingMutableLeaves error:nil];
        //扫码回调
        YYScanFunctionModel *scanModel = [[YYScanFunctionModel alloc] init];

        scanModel.env = responseJSON[@"env"];// @"TEST";
        scanModel.type = responseJSON[@"type"];// @"STYLE";
        scanModel.id = responseJSON[@"id"]; // @"2690";

        //判断环境
        if([scanModel isRightEnvironment]){
            if([scanModel. type isEqualToString:@"STYLE"]){
                //查看是否有权限访问styleId对应下的款式
                [self hasPermissionToVisitStyleWithScanModel:scanModel code:code];
            }
        }else{
            [code toast:NSLocalizedString(@"您没有查看此款式的权限",nil) collback:^(YYQRCodeController *code) {
                [code scanningAgain];
            }];
        }
    }];

    [self presentViewController:QRCode animated:YES completion:nil];
}
// 扫码 - 查看是否有权限访问styleId对应下的款式
-(void)hasPermissionToVisitStyleWithScanModel:(YYScanFunctionModel *)scanModel code:(YYQRCodeController *)code{
    [YYShowroomApi hasPermissionToVisitStyleWithStyleId:[scanModel.id longLongValue] andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,BOOL hasPermission,NSNumber *brandId,NSError *error) {
        if(rspStatusAndMessage){
            if(hasPermission){
                //showroom切换到品牌角色
                [self showroomToBrandWithBrandID:brandId WithScanModel:scanModel code:code];
            }else{
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                [code toast:NSLocalizedString(@"您没有查看此款式的权限",nil) collback:^(YYQRCodeController *code) {
                    [code scanningAgain];
                }];
            }
        }else{
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [code toast:kNetworkIsOfflineTips collback:^(YYQRCodeController *code) {
                [code scanningAgain];
            }];
        }
    }];
}

//showroom切换到品牌角色
-(void)showroomToBrandWithBrandID:(NSNumber *)brandId WithScanModel:(YYScanFunctionModel *)scanModel code:(YYQRCodeController *)code{
    [YYShowroomApi showroomToBrandWithBrandID:brandId andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYUserModel *userModel, NSError *error) {
        if (rspStatusAndMessage.status == YYReqStatusCode100) {
            //表示切换角色成功,并进行扫码款式类型处理
            [self sweepYardStyleTypeAction:scanModel code:code];
        }else{
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        }
    }];
}
//并进行扫码款式类型处理
-(void)sweepYardStyleTypeAction:(YYScanFunctionModel *)scanModel code:(YYQRCodeController *)code{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [YYOpusApi getStyleInfoByStyleId:[scanModel.id longLongValue] orderCode:nil andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYStyleInfoModel *styleInfoModel, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if(rspStatusAndMessage){
            if (rspStatusAndMessage.status == YYReqStatusCode100) {
                [code dismissController];
                //表示有权限访问，跳转款式详情页
                if(styleInfoModel){
                    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                    [appDelegate showStyleInfoViewController:styleInfoModel parentViewController:self IsShowroomToScan:YES];
                }else{
                    //清除brand的角色，切换到showroom角色
                    [YYUser removeTempUser];
                }
            }else{
                [code toast:NSLocalizedString(@"您没有查看此款式的权限",nil) collback:^(YYQRCodeController *code) {
                    [code scanningAgain];
                }];
                //清除brand的角色，切换到showroom角色
                [YYUser removeTempUser];
            }
        }else{
            [code toast:kNetworkIsOfflineTips collback:^(YYQRCodeController *code) {
                [code scanningAgain];
            }];
            //清除brand的角色，切换到showroom角色
            [YYUser removeTempUser];
        }
    }];
}
-(void)searchAction
{
    [self ShowSearchView];
}
-(void)setAction{
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
        [self.settingViewController.view removeFromSuperview];
        self.settingViewController = nil;
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
-(void)ShowSearchView
{
    if(!_searchView)
    {
        _searchView=[[DD_CircleSearchView alloc] initWithQueryStr:@"" WithBlock:^(NSString *type,NSString *queryStr, YYShowroomBrandModel *ShowroomBrandModel) {
            if([type isEqualToString:@"back"])
            {
                [self.navigationController setNavigationBarHidden:NO animated:NO];
                [_searchView removeFromSuperview];
                _searchView=nil;
                if(_alpha<1.0f){
                    _barImageView.alpha = 0;
                    _navView.alpha = 0;
                }else{
                    _barImageView.alpha = 1;
                    _navView.alpha = 1;
                }
            }else if([type isEqualToString:@"didselect"])
            {
                [self pushShowroomBrandVC:ShowroomBrandModel];
            }
        }];
        [self.navigationController setNavigationBarHidden:YES animated:NO];
    }
    _barImageView.alpha = 0;
    _navView.alpha = 0;
    _searchView.ShowroomBrandListModel = _ShowroomBrandListModel;
    [self.view addSubview:_searchView];
}
#pragma mark - Other

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    // 退出埋点
    [MobClick endLogPageView:kYYPageShowroomMain];


}
- (BOOL)prefersStatusBarHidden{
    return NO;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end

//
//  YYAccountDetailViewController.m
//  Yunejian
//
//  Created by yyj on 15/7/12.
//  Copyright (c) 2015年 yyj. All rights reserved.
//
#import "YYAccountDetailViewController.h"
#import "YYSettingViewController.h"
#import "YYProtocolViewController.h"
#import "YYModifyPasswordViewController.h"
#import "YYBrandVerificatViewController.h"
#import "YYSubShowroomPowerViewContorller.h"

#import "YYUser.h"
#import "YYUserApi.h"
#import "YYConnBuyerListModel.h"
#import "YYRspStatusAndMessage.h"
#import "YYUserInfo.h"
#import "YYDesignerModel.h"
#import "UIImage+YYImage.h"
#import "YYBrandInfoModel.h"
#import "YYBuyerStoreModel.h"
#import "YYAddressListModel.h"
#import "YYShowroomInfoModel.h"
#import "YYShowroomApi.h"

#import "UIImage+Tint.h"
#import <MessageUI/MFMailComposeViewController.h>
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreLocation/CoreLocation.h>
#import "YYSalesManListModel.h"
#import "YYSeller.h"
#import "YYAddress.h"
#import "YYAddressCell.h"
#import "YYUserInfoCell.h"
#import "YYUserLogoInfoCell.h"
#import "YYConnInfoCell.h"
#import "AppDelegate.h"
#import "YYModifyNameOrPhoneViewContrller.h"

#import "YYCreateOrModifySellerViewContorller.h"
#import "YYModifyBuyerStoreBrandInfoViewController.h"
#import "MBProgressHUD.h"
#import "UserDefaultsMacro.h"

#import <MJRefresh.h>
#import "YYConnApi.h"
#import "YYOrderApi.h"
#import "YYUserApi.h"
#import <AFNetworking/AFNetworkReachabilityManager.h>

#import "YYConnBuyerListController.h"
#import "YYConnMsgListController.h"
#import "YYConnAddViewController.h"

@interface YYAccountDetailViewController ()<UITableViewDataSource,UITableViewDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,YYUserLogoInfoCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewLayoutConstraintTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewLayoutConstraintLead;

@property(nonatomic,strong) YYModifyPasswordViewController *modifyPasswordViewController;
@property(nonatomic,strong) YYModifyNameOrPhoneViewContrller *modifyNameOrPhoneViewContrller;
@property(nonatomic,strong) YYCreateOrModifySellerViewContorller *createOrModifySellerViewContorller;
@property(nonatomic,strong) YYSettingViewController *settingViewController;

@property(nonatomic,strong) YYModifyBuyerStoreBrandInfoViewController *modifyBuyerStoreBrandInfoViewController;

@property (strong, nonatomic) YYUserInfo *userInfo;
@property (strong, nonatomic) YYShowroomInfoModel *ShowroomModel;
@property(nonatomic,strong) UIPopoverController *popController;
@property(nonatomic,strong) YYBrandInfoModel *currenDesingerBrandInfoModel;
@property(nonatomic,strong) YYBuyerStoreModel *currenBuyerStoreModel;

@property(nonatomic,assign) NSInteger connedNum;
@property(nonatomic,assign) NSInteger conningNum;

@property(nonatomic,strong)YYConnMsgListController *messageViewController;

@property(nonatomic,copy) void (^verifyBlock)(NSString *type);
@property(nonatomic,strong) YYShowroomInfoByDesignerModel *showroomInfoByDesignerModel;

@property (strong ,nonatomic) UIImageView *mengban;
@property (strong ,nonatomic) UIImageView *zbar;

@property (nonatomic,assign) BOOL ProtocolViewIsShow;

@end

@implementation YYAccountDetailViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    [self SomePrepare];
    [self RequestData];
}
#pragma mark - SomePrepare
-(void)SomePrepare
{
    [self PrepareData];
    [self PrepareUI];
}
-(void)PrepareData{
    _ProtocolViewIsShow = NO;
    WeakSelf(ws);
    _verifyBlock=^(NSString *type){
        if([type isEqualToString:@"verify"])
        {
            [ws checkUserIdentity];
        }
    };
    _connedNum = 0;
    _conningNum = 0;
    YYUser *user = [YYUser currentUser];
    self.userInfo = [[YYUserInfo alloc] init];
    self.userInfo.userId = user.userId;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageCountChanged:) name:UnreadConnNotifyMsgAmount object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:AFNetworkingReachabilityDidChangeNotification object:nil];
}
-(void)PrepareUI{

    [self addHeader];
    
    //造一个导航栏
    if(_cancelButtonClicked){
        [self CreateNavView];
        [self CreateMainICON];
    }
}
-(void)CreateMainICON{
    UIImageView *mainlogo = [UIImageView getImgWithImageStr:@"logo_main"];
    [self.view addSubview:mainlogo];
    [mainlogo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(70);
        make.left.mas_equalTo(30);
        make.top.mas_equalTo(22+64);
    }];
}
-(void)CreateNavView{
    UIView *navView = [UIView getCustomViewWithColor:_define_white_color];
    [self.view addSubview:navView];
    [navView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(20);
        make.height.mas_equalTo(44);
    }];

    UIButton *backBtn = [UIButton getCustomImgBtnWithImageStr:@"goBack_normal" WithSelectedImageStr:nil];
    [navView addSubview:backBtn];
    [backBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    [backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.width.mas_equalTo(44);
        make.top.bottom.mas_equalTo(0);
    }];
    
    UILabel *_titleLabel=[UILabel getLabelWithAlignment:1 WithTitle:NSLocalizedString(@"账户",nil) WithFont:17.0f WithTextColor:nil WithSpacing:0];
    [navView addSubview:_titleLabel];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(navView);
        make.centerX.mas_equalTo(navView);
        make.width.mas_equalTo(180);
    }];
    
    UIView *bottomLine = [UIView getCustomViewWithColor:_define_black_color];
    [navView addSubview:bottomLine];
    [bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        make.height.mas_equalTo(1);
    }];
}
-(void)backAction{
    if(_cancelButtonClicked){
        _cancelButtonClicked();
    }
}
#pragma mark - RequestData
-(void)RequestData{
    YYUser *user = [YYUser currentUser];
    if ([YYNetworkReachability connectedToNetwork]) {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        UIView *superView = appDelegate.mainViewController.view;
        if (user.userType == YYUserTypeDesigner) {
            [MBProgressHUD showHUDAddedTo:superView animated:YES];
        }
        [self loadDataFromServer];
        //_logoButton.enabled = YES;
    }else{
        //_logoButton.enabled = NO;
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSData *data = [userDefaults objectForKey:kUserInfoKey];
        if (data) {
            self.userInfo = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            [_tableView reloadData];
        }
        
    }
}
- (void)loadDataFromServer{
   
    YYUser *user = [YYUser currentUser];
    //_logoButton.enabled = YES;
     self.userInfo.status = user.status;
    switch (user.userType) {
        case YYUserTypeDesigner:{
            [self getDesignerInfo];
            [self getDesignerBrandInfo];
            [self getSellList];
            [self getConnBuyerInfo];
            [self getShowroomInfoByDesigner];
        }
            break;
        case YYUserTypeShowroom:{
            self.userInfo.username = user.name;
            self.userInfo.email = user.email;
            self.userInfo.userType = YYUserTypeShowroom;
            [self getShowroomInfo];
        }
            break;
        case YYUserTypeShowroomSub:{
            self.userInfo.username = user.name;
            self.userInfo.email = user.email;
            self.userInfo.userType = YYUserTypeShowroomSub;
            [self getShowroomInfo];
        }
            break;
        default:
            break;
    }
}
- (void)getShowroomInfoByDesigner{
    WeakSelf(ws);
    [YYShowroomApi getShowroomInfoByDesigner:^(YYRspStatusAndMessage *rspStatusAndMessage,YYShowroomInfoByDesignerModel *showroomInfoByDesignerModel,NSError *error) {
        if(showroomInfoByDesignerModel)
        {
            _showroomInfoByDesignerModel = showroomInfoByDesignerModel;
            dispatch_async(dispatch_get_main_queue(), ^{
                [ws reloadTableView];
            });
        }
    }];
}
- (void)getShowroomInfo{
    WeakSelf(ws);
    [YYUserApi getShowroomInfoWithBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYShowroomInfoModel *ShowroomModel, NSError *error) {
        [self.tableView.mj_header endRefreshing];
        if (ShowroomModel) {
            
            ws.ShowroomModel = ShowroomModel;
            
            ws.userInfo.username = ws.ShowroomModel.showroomInfo.name;
            ws.userInfo.brandName = ws.ShowroomModel.showroomInfo.manager;
            
            ws.userInfo.brandLogoName = ws.ShowroomModel.showroomInfo.logo;
            
            //以下代码，目前只考虑设计师登录的情况，保存信息至本地
            [self saveCurrentUserInfoToDisk];
            dispatch_async(dispatch_get_main_queue(), ^{
                [ws reloadTableView];
            });
        }
    }];
}
- (void)getDesignerInfo{
    WeakSelf(ws);
    [YYUserApi getDesignerBasicInfoWithBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYDesignerModel *designerModel, NSError *error) {
        [ws.tableView.mj_header endRefreshing];
        if (designerModel) {
            ws.userInfo.username = designerModel.userName;
            ws.userInfo.phone = designerModel.phone;
            ws.userInfo.email = designerModel.email;
            ws.userInfo.userType = YYUserTypeDesigner;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [ws reloadTableView];
            });
        }
        
    }];
}
- (void)getDesignerBrandInfo{
    WeakSelf(ws);
    [YYUserApi getDesignerBrandInfoWithBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYBrandInfoModel *brandInfoModel, NSError *error) {
        if (brandInfoModel) {
            ws.userInfo.brandName = brandInfoModel.brandName;
            ws.userInfo.brandLogoName = brandInfoModel.logoPath;
            ws.currenDesingerBrandInfoModel = brandInfoModel;
            dispatch_async(dispatch_get_main_queue(), ^{
                [ws reloadTableView];
            });
        }
    }];
}

-(void)getConnBuyerInfo{
    WeakSelf(ws);
    [YYConnApi getConnBuyers:1 pageIndex:1 pageSize:1 andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYConnBuyerListModel *listModel, NSError *error) {
        if(rspStatusAndMessage.status == YYReqStatusCode100){
            ws.connedNum = [listModel.pageInfo.recordTotalAmount integerValue];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [ws reloadTableView];
        });
    }];
    [YYConnApi getConnBuyers:0 pageIndex:1 pageSize:1 andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYConnBuyerListModel *listModel, NSError *error) {
        if(rspStatusAndMessage.status == YYReqStatusCode100){
            ws.conningNum = [listModel.pageInfo.recordTotalAmount integerValue];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [ws reloadTableView];
        });
    }];
}

- (void)getSellList{
    WeakSelf(ws);
    [YYUserApi getSalesManListWithBlockNew:^(YYRspStatusAndMessage *rspStatusAndMessage, YYSalesManListModel *salesManListModel, NSError *error) {
        if (salesManListModel) {
            NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:0];
            YYUser *user = [YYUser currentUser];
            for (YYSalesManModel *salesManModel in salesManListModel.result) {
                if(user.userType == [salesManModel.userType integerValue]&&[user.userId isEqualToString:[salesManModel.userId stringValue]]){
                    //去掉自己(主账号)
                }else{
//                    0:设计师 1:买手店 2:销售代表 5:Showroom 6:Showroom子账号
                    if([salesManModel.userType integerValue] == YYUserTypeDesigner || [salesManModel.userType integerValue] == YYUserTypeSales){
                        YYSeller *seller = [[YYSeller alloc] init];
                        seller.salesmanId = [salesManModel.userId intValue];
                        seller.name = salesManModel.username;
                        seller.email = salesManModel.email;
                        seller.status = [salesManModel.status intValue];
                        [array addObject:seller];
                    }
                }
            }
            ws.userInfo.sellersArray = [NSArray arrayWithArray:array];
            dispatch_async(dispatch_get_main_queue(), ^{
                [ws reloadTableView];
            });
        }
    }];
}
- (void)getBuyStoreUserInfo{
    WeakSelf(ws);
    [YYUserApi getBuyerStorBasicInfoWithBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYBuyerStoreModel *BuyerStoreModel, NSError *error) {
        [ws.tableView.mj_header endRefreshing];
        if (BuyerStoreModel) {
            ws.currenBuyerStoreModel = BuyerStoreModel;
            
            ws.userInfo.username = BuyerStoreModel.contactName;
            ws.userInfo.phone = BuyerStoreModel.contactPhone;
            ws.userInfo.email = BuyerStoreModel.contactEmail;
            ws.userInfo.userType = YYUserTypeRetailer;
            ws.userInfo.brandName = BuyerStoreModel.name;
            ws.userInfo.brandLogoName = BuyerStoreModel.logoPath;
            
            ws.userInfo.nation = BuyerStoreModel.nation;
            ws.userInfo.province = BuyerStoreModel.province;
            ws.userInfo.city = BuyerStoreModel.city;
            ws.userInfo.nationEn = BuyerStoreModel.nationEn;
            ws.userInfo.provinceEn = BuyerStoreModel.provinceEn;
            ws.userInfo.cityEn = BuyerStoreModel.cityEn;
            ws.userInfo.nationId = BuyerStoreModel.nationId;
            ws.userInfo.provinceId = BuyerStoreModel.provinceId;
            ws.userInfo.cityId = BuyerStoreModel.cityId;
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [ws reloadTableView];
            });
        }
    }];
}

- (void)getAddressList{
    WeakSelf(ws);
    [YYUserApi getAddressListWithBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYAddressListModel *addressListModel, NSError *error) {
        if (addressListModel) {
            NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:0];
            for (YYAddressModel *addressModel in addressListModel.result) {
                YYAddress *address = [[YYAddress alloc] init];
                
                address.addressId = addressModel.addressId;
                address.detailAddress = addressModel.detailAddress;
                address.receiverName = addressModel.receiverName;
                address.receiverPhone = addressModel.receiverPhone;
                address.defaultShipping = addressModel.defaultShipping;
                address.defaultBilling = addressModel.defaultBilling;
                
                address.nation = addressModel.nation;
                address.province = addressModel.province;
                address.city = addressModel.city;
                address.nationEn = addressModel.nationEn;
                address.provinceEn = addressModel.provinceEn;
                address.cityEn = addressModel.cityEn;
                address.nationId = addressModel.nationId;
                address.provinceId = addressModel.provinceId;
                address.cityId = addressModel.cityId;
                
                address.street = addressModel.street;
                address.zipCode = addressModel.zipCode;
                [array addObject:address];
            }
            
            ws.userInfo.addressArray = [NSArray arrayWithArray:array];
            dispatch_async(dispatch_get_main_queue(), ^{
                [ws reloadTableView];
            });
        }
    }];
}
#pragma mark - SomeAction
-(void)getAgencyData{
    if(_showroomInfoByDesignerModel)
    {
        [YYShowroomApi getAgentContentWithBrandID:_showroomInfoByDesignerModel.brandId WithShowroomID:_showroomInfoByDesignerModel.showroomId andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYShowroomAgentModel *agentModel, NSError *error) {
            if(agentModel){
                [self showAgencyView:agentModel];
            }
        }];
    }
}
-(void)showAgencyView:(YYShowroomAgentModel *)agentModel{
    
    if(!_ProtocolViewIsShow){
        _ProtocolViewIsShow = YES;
        WeakSelf(ws);
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Account" bundle:[NSBundle mainBundle]];
        YYProtocolViewController *protocolViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYProtocolViewController"];
        protocolViewController.protocolType = @"showroomAgent";
        protocolViewController.agentModel = agentModel;
        [protocolViewController setCancelButtonClicked:^(){
            [ws.navigationController popViewControllerAnimated:YES];
            ws.ProtocolViewIsShow = NO;
        }];
        [self.navigationController pushViewController:protocolViewController animated:YES];
    }
}
- (void)reachabilityChanged:(NSNotification *)notification
{
    if (![YYNetworkReachability connectedToNetwork]){
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        UIView *superView = appDelegate.mainViewController.view;
        [MBProgressHUD hideAllHUDsForView:superView animated:YES];
        [self.tableView reloadData];
    }
}
- (void)addHeader{
    WeakSelf(ws);
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [ws.tableView reloadData];
        [ws loadDataFromServer];
    }];
    self.tableView.mj_header = header;
    self.tableView.mj_header.automaticallyChangeAlpha = YES;
    header.lastUpdatedTimeLabel.hidden = YES;
}

- (void)reloadTableView{
    [_tableView reloadData];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    UIView *superView = appDelegate.mainViewController.view;
    
    [MBProgressHUD hideAllHUDsForView:superView animated:YES];
    
    //以下代码，目前只考虑设计师登录的情况，保存信息至本地
    if (_userInfo
        && _userInfo.username
        && _userInfo.brandName) {
        [self saveCurrentUserInfoToDisk];
    }
}
//缓存当前用户信息
- (void)saveCurrentUserInfoToDisk{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:[NSKeyedArchiver archivedDataWithRootObject:self.userInfo] forKey:kUserInfoKey];
    [userDefaults synchronize];
}
//邀请买手店
- (void)inviteBuyer{
    WeakSelf(ws);
    [YYUserApi getUserStatus:-1 andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSInteger status, NSError *error) {
        if(rspStatusAndMessage.status == YYReqStatusCode100){
            if(status == YYUserStatusOk){
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Brand" bundle:[NSBundle mainBundle]];
                YYConnAddViewController *addBrandViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYConnAddViewController"];
                [addBrandViewController setCancelButtonClicked:^(){
                    [ws getConnBuyerInfo];
                }];
                [ws.navigationController pushViewController:addBrandViewController animated:YES];
            }else{
                
                [YYToast showToastWithView:ws.view title:NSLocalizedString(@"您还没有通过品牌身份认证，不能添加合作买手店",nil) andDuration:kAlertToastDuration];
            }
        }else{
            [YYToast showToastWithView:ws.view title:rspStatusAndMessage.message andDuration:kAlertToastDuration];
        }
    }];
}



#pragma mark - 创建subShowroom
- (void)createSellerOrSubShowroom{
    WeakSelf(ws);
    YYCreateOrModifySellerViewContorller *createOrModifySellerViewContorller = [[YYCreateOrModifySellerViewContorller alloc] init];

    createOrModifySellerViewContorller.modifySuccess = ^(NSNumber *userId) {
        YYUser *user = [YYUser currentUser];
        if(user.userType == YYUserTypeDesigner){
            [ws getSellList];
        }else if(user.userType == YYUserTypeShowroom){
            [self getShowroomInfo];

            YYSubShowroomPowerViewContorller *subShowRoomPower = [[YYSubShowroomPowerViewContorller alloc] init];
            subShowRoomPower.userId = userId;
            subShowRoomPower.modifySuccess = ^{

            };

            [self presentViewController:subShowRoomPower animated:YES completion:nil];
        }
    };

    [self presentViewController:createOrModifySellerViewContorller animated:YES completion:nil];
}



-(void)OnTapBg:(UITapGestureRecognizer *)sender{
    if (_messageViewController && _messageViewController.markAsReadHandler) {
        CGPoint point = [sender locationInView:_messageViewController.view];
        if([_messageViewController.view pointInside:point withEvent:nil]){
            return;
        }
        _messageViewController.markAsReadHandler();
    }
}


-(void)messageCountChanged:(id)sender{
    [self.tableView reloadData];
}

-(void) checkUserIdentity{
    if([_userInfo.status integerValue] == YYReqStatusCode300){
        [YYToast showToastWithTitle:NSLocalizedString(@"审核中！",nil) andDuration:kAlertToastDuration];
        return ;
    }

    YYBrandVerificatViewController *brandVerificat = [[YYBrandVerificatViewController alloc] init];
    WeakSelf(ws);
    [brandVerificat setCancelButtonClicked:^(){
        StrongSelf(ws);
        YYUser *user = [YYUser currentUser];

        strongSelf.userInfo.status = user.status;
        dispatch_async(dispatch_get_main_queue(), ^{
            [strongSelf.tableView reloadData];
        });
    }];

    [self.navigationController pushViewController:brandVerificat animated:YES];
}
#pragma mark * 显示微信二维码
-(void)ShowWechat2Dbarcode:(NSString *)title
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
        make.width.mas_equalTo(500);
        make.height.mas_equalTo(407);
    }];
    
    UIView *backView=[UIView getCustomViewWithColor:_define_white_color];
    [bottomView addSubview:backView];
    [backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(bottomView);
        make.width.mas_equalTo(460);
        make.height.mas_equalTo(367);
    }];
    
    UIButton *closeBtn=[UIButton getCustomImgBtnWithImageStr:@"top_close_icon" WithSelectedImageStr:nil];
    [backView addSubview:closeBtn];
    [closeBtn addTarget:self action:@selector(closeAction) forControlEvents:UIControlEventTouchUpInside];
    [closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(14);
        make.right.mas_equalTo(-14);
        make.width.height.mas_equalTo(17);
    }];
    
    
    UILabel *titleLabel = [UILabel getLabelWithAlignment:1 WithTitle:[NSString isNilOrEmpty:title]?NSLocalizedString(@"联系 YCO 小助手",nil):title WithFont:17.0f WithTextColor:nil WithSpacing:0];
    titleLabel.font = [UIFont boldSystemFontOfSize:17.0f];
    [backView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.top.mas_equalTo(33);
    }];
    
    NSString *emailStr = [[NSString alloc] initWithFormat:NSLocalizedString(@"Email：%@",nil),@"info@ycosystem.com"];
    UILabel *emaillabel=[UILabel getLabelWithAlignment:1 WithTitle:nil WithFont:14.0f WithTextColor:[UIColor colorWithHex:kDefaultTitleColor_pad] WithSpacing:0];
    
    NSString *colorStr = @"info@ycosystem.com";
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:emailStr];
    NSRange range = [emailStr rangeOfString:colorStr];
    [string addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:71.0f/255.0f green:163.0f/255.0f blue:220.0f/255.0f alpha:1.000] range:range];
    emaillabel.attributedText = string;
    
    [backView addSubview:emaillabel];
    [emaillabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(titleLabel.mas_bottom).with.offset(33);
        make.centerX.mas_equalTo(backView);
    }];
    
    
    UILabel *namelabel=[UILabel getLabelWithAlignment:1 WithTitle:[[NSString alloc] initWithFormat:NSLocalizedString(@"微信号：%@",nil),@"yunejianhelper"] WithFont:14.0f WithTextColor:[UIColor colorWithHex:kDefaultTitleColor_pad] WithSpacing:0];
    [backView addSubview:namelabel];
    [namelabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(emaillabel.mas_bottom).with.offset(4);
        make.centerX.mas_equalTo(backView);
    }];
    
    
    _zbar=[UIImageView getImgWithImageStr:@"weixincode_img"];
    [backView addSubview:_zbar];
    [_zbar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(namelabel.mas_bottom).with.offset(15);
        make.centerX.mas_equalTo(backView);
        make.height.width.mas_equalTo(116);
    }];
    
    UIButton *actionbtn=[UIButton getCustomTitleBtnWithAlignment:0 WithFont:15.0f WithSpacing:0 WithNormalTitle:NSLocalizedString(@"保存二维码",nil) WithNormalColor:_define_black_color WithSelectedTitle:nil WithSelectedColor:nil];
    [backView addSubview:actionbtn];
    actionbtn.backgroundColor=_define_white_color;
    setBorder(actionbtn);
    //保存二维码
    [actionbtn addTarget:self action:@selector(saveWeixinPic) forControlEvents:UIControlEventTouchUpInside];
    [actionbtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(-35);
        make.width.mas_equalTo(200);
        make.height.mas_equalTo(40);
        make.centerX.mas_equalTo(backView);
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
#pragma mark - YYUserLogoInfoCellDelegate
-(void)handlerBtnClick:(id)target{
    [self logoButtonAction:target];
}
- (IBAction)logoButtonAction:(id)sender{
    
    UIImagePickerController *picker=[[UIImagePickerController alloc] init];
    picker.view.backgroundColor = _define_white_color;
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    //picker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    picker.view.backgroundColor = [UIColor whiteColor];
    
    UIPopoverController *popController = [[UIPopoverController alloc] initWithContentViewController:picker];
    self.popController = popController;
    popController.popoverContentSize = CGSizeMake(320,480);
    UIButton *logoButton = (UIButton *)sender;
    CGPoint p = [logoButton convertPoint:logoButton.center toView:self.view];
    
    CGRect rc = CGRectMake(p.x-65, p.y-65, 130, 130);
    [popController presentPopoverFromRect:rc inView:self.view permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
    
}


#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    UIImage *image = [UIImage fixOrientation:info[UIImagePickerControllerEditedImage]];
    
    if (image) {
        WeakSelf(ws);
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [YYOrderApi uploadImage:image size:2.0f andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSString *imageUrl, NSError *error) {
            [MBProgressHUD hideAllHUDsForView:ws.view animated:YES];
            if (imageUrl
                && [imageUrl length] > 0) {
                NSLog(@"imageUrl: %@",imageUrl);
                self.userInfo.brandLogoName = imageUrl;
                YYUser *user = [YYUser currentUser];
                user.logo = imageUrl;
                [user saveUserData];
                [YYUserApi modifyLogoWithUrl:imageUrl andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSError *error) {
                    //                    成功的时候去回调
                    if(rspStatusAndMessage.status == YYReqStatusCode100){
                        if(_modifySuccess)
                        {
                            _modifySuccess();
                        }
                    }
                }];
                [ws reloadTableView];
            }
            
        }];
    }
    
    WeakSelf(ws);
    
    [self dismissViewControllerAnimated:YES completion:^{
        //weakSelf.popController = nil;
        [ws.popController dismissPopoverAnimated:YES];
        ws.popController =nil;
    }];
}


-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    WeakSelf(ws);
    [self dismissViewControllerAnimated:YES completion:^{
        //weakSelf.popController = nil;
        [ws.popController dismissPopoverAnimated:YES];
        ws.popController =nil;
    }];

}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    YYUser *user = [YYUser currentUser];
    int sections = 0;
    if (user.userType == YYUserTypeDesigner) {
        sections = 5;
    }else if(user.userType == YYUserTypeShowroom){
        sections = 3;
    }else if(user.userType == YYUserTypeShowroomSub){
        sections = 2;
    }
    return sections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    YYUser *user = [YYUser currentUser];
    NSInteger rows = 0;
    switch (user.userType) {
        case YYUserTypeDesigner:{
            if(section == 0){
                rows = 1;
            }else if (section == 1) {
                rows = 2;
            }else if (section == 2) {
//                rows = 4;
                rows = 4;
            }else if(section == 3){
                if(![NSString isNilOrEmpty:_showroomInfoByDesignerModel.showroomName]){
                    rows = 3;
                }else{
                    rows = 1;
                }
            }else if(section == 4){
                if (self.userInfo
                    && [self.userInfo.sellersArray count]) {
                    rows = [self.userInfo.sellersArray count];
                }else{
                    return 1;
                }
            }
        }
            break;
        case YYUserTypeShowroom:{
            if(section == 0){
                rows = 1;
            }else if (section == 1) {
                rows = 2;
            }else if (section == 2) {
                if (self.ShowroomModel
                    && [self.ShowroomModel.subList count]) {
                    rows = [self.ShowroomModel.subList count];
                }else{
                    return 1;
                }
            }
        }
            break;
        case YYUserTypeShowroomSub:{
            if(section == 0){
                rows = 1;
            }else if (section == 1) {
                rows = 2;
            }
        }
            break;
        default:
            break;
    }
    
    return rows;

}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = nil;
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
     YYUser *user = [YYUser currentUser];
    
     WeakSelf(ws);
    if(section == 0){
        static NSString *CellIdentifier = @"LogoCell";
        YYUserLogoInfoCell *logoCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        logoCell.usernameLabel.text = self.userInfo.brandName;
        logoCell.block=_verifyBlock;
        logoCell.emailLabel.text = self.userInfo.username;
        if(self.userInfo != nil && ![NSString isNilOrEmpty:self.userInfo.brandLogoName]){
            sd_downloadWebImageWithRelativePath(NO, self.userInfo.brandLogoName, logoCell.logoButton, kLogoCover, 0);
        }else{
            if(user.logo != nil){
                sd_downloadWebImageWithRelativePath(NO, user.logo, logoCell.logoButton, kLogoCover, 0);
            }else{
                //sd_downloadWebImageWithRelativePath(NO, @"", logoCell.logoButton, kLogoCover, 0);
                [logoCell.logoButton setImage:[UIImage imageNamed:@"default_icon"] forState:UIControlStateNormal];
            }
        }
        logoCell.logoButton.imageView.contentMode = UIViewContentModeScaleAspectFit;

        logoCell.delegate =self;
        if ([YYNetworkReachability connectedToNetwork]) {
             logoCell.logoButton.enabled = YES;
        }else{
             logoCell.logoButton.enabled = NO;
        }
        if(user.userType == YYUserTypeDesigner){
            if([_userInfo.status integerValue] == YYReqStatusCode305){
                //需要审核
                logoCell.verifyBackView.hidden=NO;
                logoCell.verifyButton.hidden=NO;
                logoCell.warnLabel.text = NSLocalizedString(@"请在30天内完成品牌验证",nil);
                logoCell.tipLabel.text = NSLocalizedString(@"未验证的品牌账号将被锁定",nil);
            }else if([_userInfo.status integerValue] == YYReqStatusCode300){
                //审核中
                logoCell.verifyBackView.hidden=NO;
                logoCell.verifyButton.hidden=YES;
                logoCell.warnLabel.text = NSLocalizedString(@"品牌正在审核中，请耐心等待",nil);
                logoCell.tipLabel.text = NSLocalizedString(@"未验证的品牌账号将被锁定",nil);
            }else if([_userInfo.status integerValue] == YYReqStatusCode301){
                //审核被拒
                logoCell.verifyBackView.hidden=NO;
                logoCell.verifyButton.hidden=NO;
                logoCell.warnLabel.text = NSLocalizedString(@"审核被拒,请重新验证身份信息",nil);
                logoCell.tipLabel.text = NSLocalizedString(@"未验证的品牌账号将被锁定",nil);
            }else
            {
                logoCell.verifyBackView.hidden=YES;
            }
        }else{
            logoCell.verifyBackView.hidden=YES;
        }
        
        cell = logoCell;
    }else if (user.userType == YYUserTypeDesigner&& section == 1) {
        
        static NSString *CellIdentifier = @"YYConnInfoCell";
        YYConnInfoCell *connInfoCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (row == 0) {
            connInfoCell.infoArr = @[@(_connedNum),@(_conningNum)];
            [connInfoCell updateUIWithShowType:ConnInfoCellShowTypeNum];
        }else if (row == 1){
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            connInfoCell.infoArr = @[@(appDelegate.unreadConnNotifyMsgAmount)];
            [connInfoCell updateUIWithShowType:ConnInfoCellShowTypeMessage];
        }
        cell = connInfoCell;
    
    }else{
        static NSString *CellIdentifier = @"DetailCell";
        YYUserInfoCell *userInfoCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if ([YYNetworkReachability connectedToNetwork]) {
            userInfoCell.statusSwitch.enabled = YES;
        }else{
            userInfoCell.statusSwitch.enabled = NO;
        }
        
        userInfoCell.userInfo = _userInfo;
        userInfoCell.ShowroomModel = _ShowroomModel;
        userInfoCell.showroomInfoByDesignerModel = _showroomInfoByDesignerModel;
        
        userInfoCell.modifyButton.hidden = NO;
        // 隐藏右边所有按钮和文字
        userInfoCell.statusSwitch.hidden = YES;
        userInfoCell.tipActiveLabel.hidden = YES;
        userInfoCell.deleteNotActive.hidden = YES;
        userInfoCell.updatePower.hidden = YES;

        switch (user.userType) {
            case YYUserTypeDesigner:{
                if (section == 2) {
                    if (row == 0) {
                        [userInfoCell updateUIWithShowType:ShowTypeEmail];
                    }else if (row == 1){
                        [userInfoCell updateUIWithShowType:ShowTypeUsername];
                    }else if (row == 2){
                        [userInfoCell updateUIWithShowType:ShowTypePhone];
                    }else if (row == 3){
                        [userInfoCell updateUIWithShowType:ShowTypeBrand];
                    }
                }else if (section == 4){
                    userInfoCell.modifyButton.hidden = YES;
                    if (_userInfo.sellersArray
                        && [_userInfo.sellersArray count] > 0
                        && row < [_userInfo.sellersArray count]) {
                        YYSeller *seller = [_userInfo.sellersArray objectAtIndex:row];
                        
                        userInfoCell.statusSwitch.hidden = NO;
                        userInfoCell.seller = seller;
                        
                        [userInfoCell updateUIWithShowType:ShowTypeSeller];
                        
                        BOOL isOn = seller.status == 0;
                        [userInfoCell.statusSwitch setOn: isOn];
                        if(!isOn){
                            [userInfoCell setLabelStatus:0.6];
                        }
                    }else{
                        YYSeller *seller = [[YYSeller alloc] init];
                        seller.name = NSLocalizedString(@"暂无销售代表",nil);
                        seller.email = @"";
                        userInfoCell.statusSwitch.hidden = YES;
                        userInfoCell.seller = seller;
                        [userInfoCell updateUIWithShowType:ShowTypeSeller];
                        [userInfoCell setLabelStatus:0.6];
                    }
                }else if (section == 3){
                    if (row == 0) {
                        userInfoCell.modifyButton.hidden = YES;
                        [userInfoCell updateUIWithShowType:ShowTypeShowroomName];
                    }else if (row == 1){
                        userInfoCell.modifyButton.hidden = YES;
                        [userInfoCell updateUIWithShowType:ShowTypeShowroomSub];
                    }else if (row == 2){
                        if(![_showroomInfoByDesignerModel.status isEqualToString:@"AGREE"]){
                            userInfoCell.modifyButton.hidden = YES;
                        }
                        [userInfoCell updateUIWithShowType:ShowTypeShowroomStatus];
                    }
                }
            }
                break;
            case YYUserTypeShowroom:{
                if (section == 1) {
                    if (row == 0) {
                        [userInfoCell updateUIWithShowType:ShowTypeEmail];
                    }else if (row == 1){
                        userInfoCell.modifyButton.hidden = YES;
                        userInfoCell.ShowroomModel = _ShowroomModel;
                        [userInfoCell updateUIWithShowType:ShowTypeContractTime];
                    }
                }else if (section == 2){
                    userInfoCell.modifyButton.hidden = YES;
                    userInfoCell.updatePower.hidden = NO;

                    // 删除
                    userInfoCell.deleteNotActiveWithId = ^(NSNumber *userId) {
                        [YYShowroomApi deleteNotActiveSubShowroomUserId:userId andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSError *error) {

                            if (rspStatusAndMessage.status == YYReqStatusCode100) {
                                [YYToast showToastWithTitle:NSLocalizedString(@"操作成功！",nil) andDuration:kAlertToastDuration];
                                // 退出
                                [self getShowroomInfo];
                                
                            }else{
                                [YYToast showToastWithTitle:rspStatusAndMessage.message andDuration:kAlertToastDuration];
                            }
                        }];
                    };

                    // 修改
                    userInfoCell.updatePowerWithId = ^(NSNumber *userId) {
                        [YYShowroomApi selectSubShowroomPowerUserId:userId andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSArray *powerArray, NSError *error) {
                            if (rspStatusAndMessage.status == YYReqStatusCode100) {
                                YYSubShowroomPowerViewContorller *subShowRoomPower = [[YYSubShowroomPowerViewContorller alloc] init];
                                subShowRoomPower.userId = userId;
                                subShowRoomPower.defaultPowerArray = powerArray;
                                subShowRoomPower.modifySuccess = ^{};

                                [self presentViewController:subShowRoomPower animated:YES completion:nil];
                            }else{
                                [YYToast showToastWithTitle:rspStatusAndMessage.message andDuration:kAlertToastDuration];
                            }
                        }];
                    };
                    


                    if (_ShowroomModel && [_ShowroomModel.subList count] > 0 && row < [_ShowroomModel.subList count]) {
                        YYShowroomSubModel *subModel = [_ShowroomModel.subList objectAtIndex:row];
                        userInfoCell.statusSwitch.hidden = NO;
                        userInfoCell.subModel = subModel;
                        [userInfoCell updateUIWithShowType:ShowTypeSubShowroom];
                        if([subModel.status isEqualToString:@"NORMAL"])
                        {
                            //正常
                            userInfoCell.statusSwitch.hidden = NO;
                            [userInfoCell.statusSwitch setOn: YES];
                            [userInfoCell setLabelStatus:1.0];
                        }else if([subModel.status isEqualToString:@"STOP"])
                        {
                            //停用
                            userInfoCell.statusSwitch.hidden = NO;
                            [userInfoCell.statusSwitch setOn: NO];
                            [userInfoCell setLabelStatus:0.6];
                        }else
                        {
                            // 未激活
                            userInfoCell.statusSwitch.hidden = YES;
                            [userInfoCell setLabelStatus:0.6];
                            userInfoCell.tipActiveLabel.hidden = NO;
                            userInfoCell.deleteNotActive .hidden = NO;

                        }
                    }else{
                        YYSeller *seller = [[YYSeller alloc] init];
                        seller.name = NSLocalizedString(@"暂无Showroom子账号",nil);
                        seller.email = @"";
                        userInfoCell.statusSwitch.hidden = YES;
                        userInfoCell.seller = seller;
                        [userInfoCell updateUIWithShowType:ShowTypeSubShowroom];
                        [userInfoCell setLabelStatus:0.6];
                    }
                }
            }
                break;
            case YYUserTypeShowroomSub:{
                if (section == 1) {
                    if (row == 0) {
                        [userInfoCell updateUIWithShowType:ShowTypeEmail];
                    }else if (row == 1){
                        userInfoCell.modifyButton.hidden = YES;
                        [userInfoCell updateUIWithShowType:ShowTypeContractTime];
                    }
                }
            }
                break;
                
            default:
                break;
        }
        [userInfoCell setModifyButtonClicked:^(YYUserInfo *userInfo, ShowType currentShowType){
            
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            
            UIView *superView = appDelegate.mainViewController.view;
            switch (currentShowType) {
                case ShowTypeEmail:{
                    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Account" bundle:[NSBundle mainBundle]];
                    YYModifyPasswordViewController *modifyPasswordViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYModifyPasswordViewController"];
                    ws.modifyPasswordViewController = modifyPasswordViewController;
                    
                    
                    __weak UIView *weakSuperView = superView;
                    UIView *showView = modifyPasswordViewController.view;
                    __weak UIView *weakShowView = showView;
                    [modifyPasswordViewController setCancelButtonClicked:^(){
                        removeFromSuperviewUseUseAnimateAndDeallocViewController(weakShowView,ws.modifyPasswordViewController);
                    }];
                    
                    [modifyPasswordViewController setModifySuccess:^(){
                        
                        removeFromSuperviewUseUseAnimateAndDeallocViewController(weakShowView,ws.modifyPasswordViewController);
                        CMAlertView *alertView = [[CMAlertView alloc] initWithTitle:NSLocalizedString(@"密码修改成功！",nil) message:nil needwarn:NO delegate:nil cancelButtonTitle:NSLocalizedString(@"重新登录",nil) otherButtonTitles:@[] bgClose:YES];
                        alertView.specialParentView = self.view;
                        [alertView setAlertViewBlock:^(NSInteger selectedIndex){
                            if (selectedIndex == 0) {
                                [[NSNotificationCenter defaultCenter] postNotificationName:kNeedLoginNotification object:nil];
                            }
                        }];
                        [alertView show];
                        
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
                case ShowTypeBrand:{
                    [ws checkUserIdentity];
                }
                    break;
                case ShowTypeUsername:{
                    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Account" bundle:[NSBundle mainBundle]];
                    YYModifyNameOrPhoneViewContrller *modifyNameOrPhoneViewContrller = [storyboard instantiateViewControllerWithIdentifier:@"YYModifyNameOrPhoneViewContrller"];
                    self.modifyNameOrPhoneViewContrller = modifyNameOrPhoneViewContrller;
                    modifyNameOrPhoneViewContrller.userInfo = ws.userInfo;
                    modifyNameOrPhoneViewContrller.currentShowType = currentShowType;
                    
                    __weak UIView *weakSuperView = superView;
                    UIView *showView = modifyNameOrPhoneViewContrller.view;
                    __weak UIView *weakShowView = showView;
                    [modifyNameOrPhoneViewContrller setCancelButtonClicked:^(){
                        removeFromSuperviewUseUseAnimateAndDeallocViewController(weakShowView,ws.modifyNameOrPhoneViewContrller);
                    }];
                    
                    [modifyNameOrPhoneViewContrller setModifySuccess:^(){
                        removeFromSuperviewUseUseAnimateAndDeallocViewController(weakShowView,ws.modifyNameOrPhoneViewContrller);
                        if (ws.userInfo.userType == YYUserTypeDesigner) {
                            [ws getDesignerInfo];
                        }
                        
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
                case ShowTypePhone:{
                    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Account" bundle:[NSBundle mainBundle]];
                    YYModifyNameOrPhoneViewContrller *modifyNameOrPhoneViewContrller = [storyboard instantiateViewControllerWithIdentifier:@"YYModifyNameOrPhoneViewContrller"];
                    self.modifyNameOrPhoneViewContrller = modifyNameOrPhoneViewContrller;
                    modifyNameOrPhoneViewContrller.userInfo = ws.userInfo;
                    modifyNameOrPhoneViewContrller.currentShowType = currentShowType;
                    
                    __weak UIView *weakSuperView = superView;
                    UIView *showView = modifyNameOrPhoneViewContrller.view;
                    __weak UIView *weakShowView = showView;
                    [modifyNameOrPhoneViewContrller setCancelButtonClicked:^(){
                        removeFromSuperviewUseUseAnimateAndDeallocViewController(weakShowView,ws.modifyNameOrPhoneViewContrller);
                    }];
                    
                    [modifyNameOrPhoneViewContrller setModifySuccess:^(){
                        removeFromSuperviewUseUseAnimateAndDeallocViewController(weakShowView,ws.modifyNameOrPhoneViewContrller);
                        if (ws.userInfo.userType == YYUserTypeDesigner) {
                            [ws getDesignerInfo];
                        }
                        
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
                case ShowTypeShowroomStatus:{
                    [ws ShowWechat2Dbarcode:NSLocalizedString(@"如需解除代理，请联系小助手",nil)];
                }
                    break;
                default:
                    break;
            }
            // NSLog(@"userInfo.email: %@  userInfo.username: %@,currentShowType: %i",userInfo.email,userInfo.username,currentShowType);
        }];
        [userInfoCell setBlock:^(NSString *type) {
            if([type isEqualToString:@"showhelp"]){
                [ws ShowWechat2Dbarcode:NSLocalizedString(@"续签请与小助手联系",nil)];
            }else if([type isEqualToString:@"agency"]){
                [ws getAgencyData];
            }
        }];
        [userInfoCell setSwitchClicked:^(NSNumber *salesmanId,BOOL isOn){
            NSInteger status = -1;
            if (isOn) {
                status = 0;
            }else {
                status = 1;
            }
            if(user.userType == YYUserTypeDesigner){
                [YYUserApi updateSalesmanStatusWithId:[salesmanId integerValue] status:status andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSError *error) {
                    if (rspStatusAndMessage.status == YYReqStatusCode100) {
                        [YYToast showToastWithTitle:NSLocalizedString(@"操作成功",nil) andDuration:kAlertToastDuration];
                        
                    }else{
                        [YYToast showToastWithTitle:rspStatusAndMessage.message andDuration:kAlertToastDuration];
                    }
                    
                    [ws getSellList];
                }];
            }else if(user.userType == YYUserTypeShowroom){
                [YYShowroomApi updateSubShowroomStatusWithId:[salesmanId integerValue] status:status andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSError *error) {
                    if (rspStatusAndMessage.status == YYReqStatusCode100) {
                        [YYToast showToastWithTitle:NSLocalizedString(@"操作成功！",nil) andDuration:kAlertToastDuration];
                        
                    }else{
                        [YYToast showToastWithTitle:rspStatusAndMessage.message andDuration:kAlertToastDuration];
                    }
                    [self getShowroomInfo];
                }];
            }
        }];
        [userInfoCell setLabelStatus:1.0];
        cell = userInfoCell;
    }
    
    if (cell == nil){
        [NSException raise:@"DetailCell == nil.." format:@"No cells with matching CellIdentifier loaded from your storyboard"];
    }
    return cell;
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    YYUser *user = [YYUser currentUser];
    if(indexPath.section== 0){
        if([_userInfo.status integerValue] == YYReqStatusCode305){
           return 195;
        }else if([_userInfo.status integerValue] == YYReqStatusCode300){
           return 195;
        }else if([_userInfo.status integerValue] == YYReqStatusCode301){
            return 195;
        }else
        {
            return 195-33;
        }
    }else if(indexPath.section== 2){
        return 60;
    }else if(indexPath.section== 3){
        return 60;
    }else if(indexPath.section== 1){
        return 60;
    }
    return 85;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 0){
        UITableViewCell *nullCell = [[UITableViewCell alloc] init];
        return nullCell;
    }else{
    static NSString *CellIdentifier = @"SectionHeader";
    UITableViewCell *headerView = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    [headerView setTranslatesAutoresizingMaskIntoConstraints:YES];
    if (headerView == nil){
        [NSException raise:@"SectionHeader == nil.." format:@"No cells with matching CellIdentifier loaded from your storyboard"];
    }else{
        UILabel *titleLabel = (UILabel *)[headerView viewWithTag:70001];
        UIButton *button = (UIButton *)[headerView viewWithTag:70002];
        if ([YYNetworkReachability connectedToNetwork]) {
             button.enabled = YES;
             [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }else{
             [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
             button.enabled = NO;
        }
        
        
        button.hidden = YES;
        YYUser *user = [YYUser currentUser];
        switch (user.userType) {
            case YYUserTypeDesigner:{
                if (section == 1) {
                    button.hidden = NO;
                    [button setTitle:NSLocalizedString(@"邀请合作买手店",nil) forState:UIControlStateNormal];
                    [button addTarget:self action:@selector(inviteBuyer) forControlEvents:UIControlEventTouchUpInside];
                    titleLabel.text = NSLocalizedString(@"买手店",nil);
                }else if (section == 2) {
                    titleLabel.text = NSLocalizedString(@"账户与品牌",nil);
                }else if (section == 3) {
                    titleLabel.text = NSLocalizedString(@"代理Showroom",nil);
                }else if (section == 4) {
                    button.hidden = NO;
                    [button setTitle:NSLocalizedString(@"新建销售代表",nil) forState:UIControlStateNormal];
                    [button addTarget:self action:@selector(createSellerOrSubShowroom) forControlEvents:UIControlEventTouchUpInside];
                    titleLabel.text = NSLocalizedString(@"销售代表",nil);
                }
            }
                break;
            case YYUserTypeShowroom:{
                if (section == 1) {
                    titleLabel.text = NSLocalizedString(@"Showroom信息",nil);
                }else if (section == 2) {
                    button.hidden = NO;
                    [button setTitle:NSLocalizedString(@"新建Showroom子账号",nil) forState:UIControlStateNormal];
                    [button addTarget:self action:@selector(createSellerOrSubShowroom) forControlEvents:UIControlEventTouchUpInside];
                    titleLabel.text = NSLocalizedString(@"Showroom子账号",nil);
                }
            }
                break;
            case YYUserTypeShowroomSub:{
                if (section == 1) {
                    titleLabel.text = NSLocalizedString(@"Showroom信息",nil);
                }
            }
                break;
                
            default:
                break;
        }

    }
    return headerView;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 0.1;
    }
    return 70;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
     WeakSelf(ws);

    YYUser *user = [YYUser currentUser];
    if (user.userType == YYUserTypeDesigner && indexPath.section == 1){
        if(indexPath.row == 0){
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Account" bundle:[NSBundle mainBundle]];
            YYConnBuyerListController *connInfoListController = [storyboard instantiateViewControllerWithIdentifier:@"YYConnBuyerListController"];
            connInfoListController.connedNum = _connedNum;
            connInfoListController.conningNum = _conningNum;
            [connInfoListController setCancelButtonClicked:^(){
                [ws getConnBuyerInfo];
            }];
            [self.navigationController pushViewController:connInfoListController animated:YES];
        }else if(indexPath.row == 1){
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Account" bundle:[NSBundle mainBundle]];
            YYConnMsgListController *messageViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYConnMsgListController"];
            
            WeakSelf(ws);
            UIView *_rightMaskView = [[UIView alloc] init];
            _rightMaskView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
            UIButton *bgView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
            [_rightMaskView addSubview:bgView];
            __weak UIView *weakMaskView =_rightMaskView;

            [messageViewController setMarkAsReadHandler:^(void){
                [YYConnMsgListController markAsRead];
                [ws.messageViewController.view removeFromSuperview];
                [weakMaskView removeFromSuperview];
            }];

            //[self.navigationController pushViewController:messageViewController animated:YES];

            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            __weak  UIView *_weakContainerView = appDelegate.mainViewController.view;//self.view;

            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(OnTapBg:)];
            [bgView addGestureRecognizer:tap];
            [ appDelegate.mainViewController.view addSubview:_rightMaskView];
            self.messageViewController = messageViewController;
            [_rightMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(_weakContainerView.mas_top);
                make.left.equalTo(_weakContainerView.mas_left);
                make.bottom.equalTo(_weakContainerView.mas_bottom);
                make.right.equalTo(_weakContainerView.mas_right);
            }];
            
            [_rightMaskView addSubview:messageViewController.view];
            [messageViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(_rightMaskView.mas_top);
                make.bottom.equalTo(_rightMaskView.mas_bottom);
                make.right.equalTo(_rightMaskView.mas_right).offset(653);
                make.width.equalTo(@(653));
            }];
            [messageViewController.view.superview layoutIfNeeded];
            [UIView animateWithDuration:0.5 animations:^{
                [self.messageViewController.view mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.right.equalTo(_weakContainerView.mas_right).offset(0);
                }];
                //        //必须调用此方法，才能出动画效果
                [self.messageViewController.view.superview layoutIfNeeded];
                [_rightMaskView setNeedsUpdateConstraints];
                
                // update constraints now so we can animate the change
                [_rightMaskView.superview updateConstraintsIfNeeded];
                [_rightMaskView updateConstraints];
                
            }
                completion:^(BOOL finished) {
                                 
            }];

        }
        
    }
}
#pragma mark - Other
- (UIStatusBarStyle)preferredStatusBarStyle
{
    if(_cancelButtonClicked)
    {
        UIView *statusBarView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 20)];
        statusBarView.backgroundColor=[UIColor blackColor];
        [self.view addSubview:statusBarView];
        
        return UIStatusBarStyleLightContent;
        
    }
    return UIStatusBarStyleLightContent;
}
- (BOOL)prefersStatusBarHidden{
    return NO;
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    // 退出埋点
    [MobClick endLogPageView:kYYPageAccountDetail];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if(_cancelButtonClicked){
        _tableViewLayoutConstraintTop.constant = 64+20;
        _tableViewLayoutConstraintLead.constant = 150;
    }else{
        _tableViewLayoutConstraintTop.constant = 0;
        _tableViewLayoutConstraintLead.constant = 0;
    }
    if(_tableView){
        [_tableView reloadData];
    }
    // 进入埋点
    [MobClick beginLogPageView:kYYPageAccountDetail];


}
@end

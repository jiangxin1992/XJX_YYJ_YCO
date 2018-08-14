//
//  YYOrderModifyViewController.m
//  Yunejian
//
//  Created by yyj on 15/8/18.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import "YYOrderModifyViewController.h"

// c文件 —> 系统文件（c文件在前）

// 控制器
#import "YYTaxChooseViewController.h"
#import "YYCustomCell02ViewController.h"
#import "YYCustomCellTableViewController.h"
#import "YYSelectUserTableViewController.h"
#import "YYStyleDetailListViewController.h"
#import "YYSelectPayMethodTableViewController.h"
#import "YYCreateOrModifyAddressViewController.h"
#import "YYSelectOrderTypeMethodTableViewController.h"
#import "YYSelecteOrderSituationTableViewController.h"
#import "YYSelectDeliverMethodTableViewController.h"

// 自定义视图
#import "ASPopUpView.h"
#import "YYDiscountView.h"
#import "YYTopAlertView.h"
#import "YYStyleDetailCell.h"
#import "YYOrderRemarkCell.h"
#import "YYSelecteDateView.h"
#import "YYBuyerMessageCell.h"
#import "YYOrderAddressItemView.h"
#import "YYOrderAddressMoreCell.h"
#import "YYOrderDetailSectionHead.h"
#import "YYPopoverArrowBackgroundView.h"

// 接口
#import "YYUserApi.h"
#import "YYOrderApi.h"

// 分类
#import "UIImage+Tint.h"
#import "UIView+UpdateAutoLayoutConstraints.h"

// 自定义类和三方类（ cocoapods类 > model > 工具类 > 其他）
#import "YYUser.h"
#import "YYAddress.h"
#import "YYBuyerModel.h"
#import "YYPageInfoModel.h"
#import "YYOrderInfoModel.h"
#import "YYBuyerAddressModel.h"
#import "YYStylesAndTotalPriceModel.h"

#import "AppDelegate.h"
#import "YYRequestHelp.h"
#import "UserDefaultsMacro.h"

#import "MBProgressHUD.h"
#import "YYYellowPanelManage.h"

#define kDelaySeconds 2
#define kOrderModifyPageSize 8

@interface YYOrderModifyViewController ()<UITableViewDataSource,UITableViewDelegate,UIPopoverControllerDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *thirdButton;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@property (weak, nonatomic) IBOutlet YYDiscountView *priceTotalDiscountView;
@property (weak, nonatomic) IBOutlet UILabel *priceTitle;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewBottomLayoutConstraint;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIButton *minOrderMoneyBtn1;

@property (nonatomic, assign) NSInteger totalSections;

@property (nonatomic, strong) NSMutableArray *selectedArray;//修改时，已经选中的款式
@property (nonatomic, strong) UIPopoverController *popController;

@property (nonatomic, strong) YYStylesAndTotalPriceModel *stylesAndTotalPriceModel;//总数

@property (nonatomic, strong) YYOrderSettingInfoModel *orderSettingInfoModel;

@property (nonatomic, strong) YYCreateOrModifyAddressViewController *addAddressViewController;

@property (nonatomic, assign) NSInteger selectTaxType;//税制

@property (nonatomic, strong) NSString *minOrderMoneyTip;
@property (nonatomic, strong) ASPopUpView *popUpView;

@property (nonatomic, strong) NSMutableArray *menuData;

@property (nonatomic, assign) UIView *parentView;
@property (nonatomic, strong) YYPageInfoModel *currentPageInfo;
@property (nonatomic, strong) YYBuyerModel *buyerModel;//买手店地址
@property (nonatomic, strong) YYOrderBuyerAddress *nowBuyerAddress;//新增地址
@property (nonatomic, strong) NSString *uploadImgPathType;//该功能对应的 qiniu上传图片路径
@property (nonatomic, strong) NSString *chooseImgKey;//当前已选的名片图片在qiniu中对应的key

@end

@implementation YYOrderModifyViewController
#pragma mark - --------------生命周期--------------
- (void)viewDidLoad {
    [super viewDidLoad];
    [self SomePrepare];
    [self RequestData];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.orderModel) {
        appDelegate.orderSeriesArray = nil;
        appDelegate.orderModel = nil;
    }
    [self updateUI];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if (_isCreatOrder) {
        // 退出埋点
        [MobClick endLogPageView:kYYPageOrderModifyCreate];
    }else{
        if(!_isAppendOrder){
            // 退出埋点
            [MobClick endLogPageView:kYYPageOrderModifyUpdate];

        }else{
            // 退出埋点
            [MobClick endLogPageView:kYYPageOrderModifyAddTo];
        }
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kUpdateShoppingCarNotification object:nil];
}
#pragma mark - --------------SomePrepare--------------
- (void)SomePrepare {
    [self PrepareData];
    [self PrepareUI];
}
- (void)PrepareData {
    self.selectedArray = [[NSMutableArray alloc] initWithCapacity:0];

    //买手店数据（可修改地址）
    _buyerModel = [[YYBuyerModel alloc] init];
    _buyerModel.buyerId = _currentYYOrderInfoModel.realBuyerId;
    _buyerModel.name = _currentYYOrderInfoModel.buyerName;
    _buyerModel.contactEmail = (_currentYYOrderInfoModel.buyerEmail?_currentYYOrderInfoModel.buyerEmail:@"");

    _buyerModel.nation = (_currentYYOrderInfoModel.buyerAddressId?_currentYYOrderInfoModel.buyerAddress.nation:@"");
    _buyerModel.province = (_currentYYOrderInfoModel.buyerAddressId?_currentYYOrderInfoModel.buyerAddress.province:@"");
    _buyerModel.city = (_currentYYOrderInfoModel.buyerAddressId?_currentYYOrderInfoModel.buyerAddress.city:@"");

    _buyerModel.nationEn = (_currentYYOrderInfoModel.buyerAddressId?_currentYYOrderInfoModel.buyerAddress.nationEn:@"");
    _buyerModel.provinceEn = (_currentYYOrderInfoModel.buyerAddressId?_currentYYOrderInfoModel.buyerAddress.provinceEn:@"");
    _buyerModel.cityEn = (_currentYYOrderInfoModel.buyerAddressId?_currentYYOrderInfoModel.buyerAddress.cityEn:@"");

    _buyerModel.nationId = (_currentYYOrderInfoModel.buyerAddressId?_currentYYOrderInfoModel.buyerAddress.nationId:@(0));
    _buyerModel.provinceId = (_currentYYOrderInfoModel.buyerAddressId?_currentYYOrderInfoModel.buyerAddress.provinceId:@(0));
    _buyerModel.cityId = (_currentYYOrderInfoModel.buyerAddressId?_currentYYOrderInfoModel.buyerAddress.cityId:@(0));
    //初始化默认地址
    _nowBuyerAddress = _currentYYOrderInfoModel.buyerAddress;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.orderModel) {
        appDelegate.orderSeriesArray = nil;
        appDelegate.orderModel = nil;
    }

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateShoppingCarNotification:)
                                                 name:kUpdateShoppingCarNotification
                                               object:nil];
}
- (void)PrepareUI {
    YYUser *user = [YYUser currentUser];
    if(user.userType == YYUserTypeShowroom||user.userType == YYUserTypeShowroomSub||user.userType == YYUserTypeSales)
    {
        self.currentYYOrderInfoModel.billCreatePersonId =  [NSNumber numberWithInteger: [user.userId integerValue]];
        self.currentYYOrderInfoModel.billCreatePersonName = user.name;
        [_tableView reloadData];
    }
    self.currentYYOrderInfoModel.billCreatePersonType = [NSNumber numberWithInteger:user.userType];

    self.saveButton.layer.borderWidth = 1;
    self.saveButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.view.backgroundColor = [UIColor blackColor];
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];

    //初始化_menuData
    _menuData = getPayTaxInitData();
    NSNumber *changeNum = [NSNumber numberWithFloat:[_currentYYOrderInfoModel.taxRate floatValue]/100.0f];
    updateCustomTaxValue(_menuData, changeNum,YES);
    _selectTaxType = getPayTaxTypeFormServiceNew(_menuData, [_currentYYOrderInfoModel.taxRate integerValue]);

    NSString *originStr = self.thirdButton.currentTitle;
    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString: originStr];
    [attributedStr addAttribute: NSFontAttributeName value: [UIFont systemFontOfSize:30] range: NSMakeRange(0, 1)];
    [attributedStr addAttribute: NSBaselineOffsetAttributeName value:@(2) range: NSMakeRange(1, originStr.length-1)];
    [self.thirdButton setAttributedTitle:attributedStr forState:UIControlStateNormal];

    [self.tableView registerNib:[UINib nibWithNibName:@"YYOrderAddressItemView" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"YYOrderAddressItemView"];
    [self.tableView registerNib:[UINib nibWithNibName:@"YYOrderAddressMoreCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"YYOrderAddressMoreCell"];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(OnTapBg:)];
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];

    [self updateUI];

}

//#pragma mark - --------------UIConfig----------------------
//- (void)UIConfig {
//
//}

#pragma mark - --------------请求数据----------------------
- (void)RequestData {
    WeakSelf(ws);
    [YYOrderApi getOrderSettingInfoWithBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,YYOrderSettingInfoModel *orderSettingInfoModel, NSError *error) {
        if (rspStatusAndMessage.status == YYReqStatusCode100) {
            ws.orderSettingInfoModel = orderSettingInfoModel;
        }
    }];
}

#pragma mark - --------------系统代理----------------------
#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [UIImage fixOrientation:info[UIImagePickerControllerOriginalImage]];
    WeakSelf(ws);
    if (image) {

        if (![YYNetworkReachability connectedToNetwork]) {
            if (self.currentYYOrderInfoModel.shareCode
                && !self.currentYYOrderInfoModel.orderCode) {
                //没网不给上传名片  给个提示算了
                [ws updateUI];
                [YYToast showToastWithTitle:kNetworkIsOfflineTips andDuration:kAlertToastDuration];
            }
        }else{

            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [YYRequestHelp uploadQiniuImage:image WithType:@"UploadCallingCard" maxFileSize:500 andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSString *imageUrl,NSString * imgKey, NSString *uploadImgPathType, NSError *error) {
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                if(imageUrl)
                {
                    ws.chooseImgKey=imgKey;
                    ws.uploadImgPathType=uploadImgPathType;
                    ws.currentYYOrderInfoModel.businessCard = imageUrl;
                    [ws updateUI];
                }else{
                    if(rspStatusAndMessage){
                        [YYToast showToastWithTitle:rspStatusAndMessage.message  andDuration:kAlertToastDuration];
                    }
                }
            }];
        }
    }

    if(picker.sourceType == UIImagePickerControllerSourceTypeCamera){
        [self dismissViewControllerAnimated:YES completion:^{
            [ws.popController dismissPopoverAnimated:YES];
            ws.popController =nil;
        }];
    }else{
        [self.popController dismissPopoverAnimated:YES];
        self.popController =nil;
    }
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    WeakSelf(ws);
    if(picker.sourceType == UIImagePickerControllerSourceTypeCamera){
        [self dismissViewControllerAnimated:YES completion:^{
            [ws.popController dismissPopoverAnimated:YES];
            ws.popController =nil;
        }];
    }else{
        [self.popController dismissPopoverAnimated:YES];
        self.popController =nil;
    }
}
#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.totalSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger rows = 0;
    if (section == 0) {
        return 1 +  (self.nowBuyerAddress?1:0);//[self.buyerAddressList count] +  + ((self.currentPageInfo == nil || self.currentPageInfo.isLastPage)?0:1)
    }else if (section == self.totalSections-1) {
        return 1;
    }else{
        if (_currentYYOrderInfoModel && _currentYYOrderInfoModel.groups && [_currentYYOrderInfoModel.groups count] > 0) {
            NSInteger nowIndex = section-1;
            if (nowIndex >= 0 && nowIndex < [_currentYYOrderInfoModel.groups count]) {
                YYOrderOneInfoModel *orderOneInfoModel = _currentYYOrderInfoModel.groups[nowIndex];
                if (orderOneInfoModel.styles && [orderOneInfoModel.styles count] > 0) {
                    if ([orderOneInfoModel isInStock]) {
                        rows = [orderOneInfoModel.styles count] * 2;
                    } else {
                        rows = [orderOneInfoModel.styles count];
                    }
                }
            }
        }
    }
    return rows;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = nil;
    WeakSelf(ws);
    if (indexPath.section == 0) {
        if(indexPath.row == 0){
            static NSString *CellIdentifier = @"YYBuyerMessageCell";
            YYBuyerMessageCell *buyerMessageCell =  [_tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if(!cell){
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"OrderDetail" bundle:[NSBundle mainBundle]];
                YYCustomCell02ViewController *customCell02ViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYCustomCell02ViewController"];
                buyerMessageCell = [customCell02ViewController.tableView dequeueReusableCellWithIdentifier:CellIdentifier];

                //选择订单类型
                [buyerMessageCell setOrderTypeButtonClicked:^(UIView *view){

                    NSArray *orderTypeArray = @[@"买断（Buy out）",@"寄售（Consignment sale）"];
                    NSInteger dataCount = orderTypeArray.count;

                    CGPoint vp = CGPointMake(CGRectGetWidth(view.frame), CGRectGetHeight(view.frame)/2);
                    CGPoint p = [view convertPoint:vp toView:ws.view];

                    CGRect rc = CGRectMake(p.x, p.y, 0, 0);

                    CGFloat getwidth = 0;
                    for (NSString *str in orderTypeArray) {
                        CGFloat tempwidth = getWidthWithHeight(28,str,getFont(13.0f));
                        if(tempwidth>getwidth){
                            getwidth = tempwidth;
                        }
                    }
                    YYSelectOrderTypeMethodTableViewController *selectOrderTypeMethodTableViewController = [[YYSelectOrderTypeMethodTableViewController alloc] init];
                    selectOrderTypeMethodTableViewController.currentMethod = ws.currentYYOrderInfoModel.type;
                    selectOrderTypeMethodTableViewController.orderTypeArray = orderTypeArray;
                    selectOrderTypeMethodTableViewController.preferredContentSize = CGSizeMake(getwidth+40,MIN((dataCount*45),300));
                    [selectOrderTypeMethodTableViewController setSelectedValue:^(NSString *selectedValue){
                        ws.currentYYOrderInfoModel.type = selectedValue;
                        [ws.tableView reloadData];
                        [ws.popController dismissPopoverAnimated:YES];
                    }];

                    UIPopoverController *popController = [[UIPopoverController alloc] initWithContentViewController:selectOrderTypeMethodTableViewController];
                    popController.delegate = ws;
                    ws.popController = popController;
                    selectOrderTypeMethodTableViewController.view.layer.borderColor = [UIColor blackColor].CGColor;
                    selectOrderTypeMethodTableViewController.view.layer.borderWidth = 4;
                    [popController setPopoverBackgroundViewClass:[YYPopoverArrowBackgroundView class]];
                    [popController presentPopoverFromRect:rc inView:ws.view permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
                }];

                //选择送货方式这块
                [buyerMessageCell setOrderDeliverMethodButtonClicked:^(UIView *view){
                    NSInteger dataCount = [ws getArrayCount:ws.orderSettingInfoModel.deliveryList];
                    if(dataCount == 0){
                        [YYToast showToastWithView:ws.view title:NSLocalizedString(@"没有发货方式可供选择",nil) andDuration:kAlertToastDuration];
                        return ;
                    }

                    CGPoint vp = CGPointMake(CGRectGetWidth(view.frame), CGRectGetHeight(view.frame)/2);
                    CGPoint p = [view convertPoint:vp toView:ws.view];

                    CGRect rc = CGRectMake(p.x, p.y, 0, 0);

                    CGFloat getwidth = 0;
                    for (NSString *str in ws.orderSettingInfoModel.deliveryList) {
                        CGFloat tempwidth = getWidthWithHeight(28,str,getFont(13.0f));
                        if(tempwidth>getwidth){
                            getwidth = tempwidth;
                        }
                    }
                    YYSelectDeliverMethodTableViewController *selectDeliverMethodTableViewController = [[YYSelectDeliverMethodTableViewController alloc] init];
                    selectDeliverMethodTableViewController.currentMethod = ws.currentYYOrderInfoModel.deliveryChoose;
                    selectDeliverMethodTableViewController.currentOrderSettingInfoModel = ws.orderSettingInfoModel;
                    selectDeliverMethodTableViewController.preferredContentSize = CGSizeMake(getwidth+40,MIN((dataCount*45),300));
                    [selectDeliverMethodTableViewController setSelectedValue:^(NSString *selectedValue){
                        ws.currentYYOrderInfoModel.deliveryChoose = selectedValue;
                        [ws.tableView reloadData];
                        [ws.popController dismissPopoverAnimated:YES];
                    }];

                    UIPopoverController *popController = [[UIPopoverController alloc] initWithContentViewController:selectDeliverMethodTableViewController];
                    popController.delegate = ws;
                    ws.popController = popController;
                    selectDeliverMethodTableViewController.view.layer.borderColor = [UIColor blackColor].CGColor;
                    selectDeliverMethodTableViewController.view.layer.borderWidth = 4;
                    [popController setPopoverBackgroundViewClass:[YYPopoverArrowBackgroundView class]];
                    [popController presentPopoverFromRect:rc inView:ws.view permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
                }];

                //添加买手名称这块
                [buyerMessageCell setOrderCreateBuyerMessageButtonClicked:^(UIView *view){
                    CGPoint vp = CGPointMake(0, CGRectGetHeight(view.frame)/2);
                    CGPoint p = [view convertPoint:vp toView:ws.view];

                    CGRect rc = CGRectMake(p.x, p.y, 0, 0);

                    if (TARGET_IPHONE_SIMULATOR) {
                        UIImagePickerController *picker=[[UIImagePickerController alloc] init];
                        picker.view.backgroundColor = _define_white_color;
                        picker.delegate = ws;
                        picker.allowsEditing = YES;
                        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                        UIPopoverController *popController = [[UIPopoverController alloc] initWithContentViewController:picker];
                        self.popController = popController;
                        popController.popoverContentSize = CGSizeMake(320,480);
                        [popController presentPopoverFromRect:rc inView:self.view permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];

                    }else{
                        CMAlertView *alertView = [[CMAlertView alloc] initWithTitle:NSLocalizedString(@"请选择",nil) message:nil needwarn:NO delegate:nil cancelButtonTitle:NSLocalizedString(@"相册",nil) otherButtonTitles:@[[NSString stringWithFormat:@"%@|000000",NSLocalizedString(@"拍照",nil)]]];
                        alertView.specialParentView = ws.view;
                        [alertView setAlertViewBlock:^(NSInteger selectedIndex){
                            UIImagePickerController *picker=[[UIImagePickerController alloc] init];
                            picker.view.backgroundColor = _define_white_color;
                            picker.delegate = ws;
                            picker.videoQuality = UIImagePickerControllerQualityTypeLow;
                            picker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
                            if (selectedIndex == 0) {
                                picker.allowsEditing = NO;

                                picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                                UIPopoverController *popController = [[UIPopoverController alloc] initWithContentViewController:picker];
                                ws.popController = popController;
                                popController.popoverContentSize = CGSizeMake(320,480);
                                [popController presentPopoverFromRect:rc inView:ws.view permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
                                //[weakSelf presentViewController:picker animated:YES completion:nil];

                            }else if (selectedIndex == 1){
                                picker.allowsEditing = NO;
                                picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                                [ws presentViewController:picker animated:YES completion:nil];
                            }
                        }];
                        [alertView show];
                    }
                }];

                //添加取消地址
                [buyerMessageCell setOrderDeleteBuyerAddressButtonClicked:^(){
                    [ws deleteBuyerAddress];
                }];
                //添加买手地址这块
                [buyerMessageCell setOrderCreateBuyerAddressButtonClicked:^(){
                    [ws addAddress];
                }];

                //选择付款方式这块
                [buyerMessageCell setAccountsMethodButtonClicked:^(UIView *view){
                    NSInteger dataCount = [ws getArrayCount:ws.orderSettingInfoModel.payList];
                    if(dataCount == 0){
                        [YYToast showToastWithView:ws.view title:NSLocalizedString(@"没有结算方式可供选择",nil) andDuration:kAlertToastDuration];
                        return ;
                    }
                    CGPoint vp = CGPointMake(CGRectGetWidth(view.frame), CGRectGetHeight(view.frame)/2);
                    CGPoint p = [view convertPoint:vp toView:ws.view];

                    CGRect rc = CGRectMake(p.x, p.y, 0, 0);

                    CGFloat getwidth = 0;
                    for (NSString *str in ws.orderSettingInfoModel.payList) {
                        CGFloat tempwidth = getWidthWithHeight(28,str,getFont(13.0f));
                        if(tempwidth>getwidth){
                            getwidth = tempwidth;
                        }
                    }
                    YYSelectPayMethodTableViewController *selectPayMethodTableViewController = [[YYSelectPayMethodTableViewController alloc] init];
                    selectPayMethodTableViewController.currentPayMethod = ws.currentYYOrderInfoModel.payApp;
                    selectPayMethodTableViewController.currentOrderSettingInfoModel = ws.orderSettingInfoModel;
                    selectPayMethodTableViewController.preferredContentSize = CGSizeMake(getwidth+30,MIN((dataCount*45),300));
                    [selectPayMethodTableViewController setSelectedValue:^(NSString *selectedValue){
                        ws.currentYYOrderInfoModel.payApp = selectedValue;
                        [ws.tableView reloadData];
                        [ws.popController dismissPopoverAnimated:YES];
                    }];

                    UIPopoverController *popController = [[UIPopoverController alloc] initWithContentViewController:selectPayMethodTableViewController];
                    popController.delegate = ws;
                    ws.popController = popController;
                    selectPayMethodTableViewController.view.layer.borderColor = [UIColor blackColor].CGColor;
                    selectPayMethodTableViewController.view.layer.borderWidth = 4;
                    [popController setPopoverBackgroundViewClass:[YYPopoverArrowBackgroundView class]];
                    [popController presentPopoverFromRect:rc inView:ws.view permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
                }];



                //添加买手名称
                if(_isCreatOrder){
                    [buyerMessageCell setOrderCreateBuyerNameButtonClicked:^(){
                        [[YYYellowPanelManage instance] showOrderBuyerAddressListPanel:@"Order" andIdentifier:@"YYOrderAddressListController"   needUnDefineBuyer:1 parentView:ws.view     andCallBack:^(NSArray *value) {
                            NSString* name = [value objectAtIndex:0];
                            YYBuyerModel *infoModel = nil;
                            if([value count] >= 2){
                                infoModel = [value objectAtIndex:1];
                                ws.currentYYOrderInfoModel.buyerName = infoModel.name;
                            }else{
                                ws.currentYYOrderInfoModel.buyerName = name;
                            }
                            ws.buyerModel = infoModel;
                            [ws updateUI];
                        }];
                    }];
                }else{
                    [buyerMessageCell setOrderCreateBuyerNameButtonClicked:nil];
                }

            }
            buyerMessageCell.currentYYOrderInfoModel = self.currentYYOrderInfoModel;
            buyerMessageCell.buyerModel = _buyerModel;
            [buyerMessageCell updateUI];

            cell = buyerMessageCell;
        }else{
            NSInteger totalRow = 1 + (self.nowBuyerAddress?1:0) ;//+ [self.buyerAddressList count]
            if (indexPath.row <totalRow) {

                YYOrderAddressItemView *addresscell = [self.tableView dequeueReusableCellWithIdentifier:@"YYOrderAddressItemView" forIndexPath:indexPath];
                //addresscell.needBtn = NO;
                addresscell.currentYYOrderInfoModel = _currentYYOrderInfoModel;
                addresscell.needBtn = YES;
                [addresscell updateUI:self.nowBuyerAddress];
                [addresscell setAddressButtonClicked:^(NSInteger type, id info){
                    if(type == 1){

                        ws.currentYYOrderInfoModel.buyerAddress = info;
                        ws.currentYYOrderInfoModel.buyerAddressId = ws.currentYYOrderInfoModel.buyerAddress.addressId;
                        [self updateUI];
                    }else if(type == 2){
                        [ws addAddress];
                    }else if(type == 3){
                        [ws deleteBuyerAddress];
                    }
                }];
                cell = addresscell;
            }else{
                YYOrderAddressMoreCell *morecell = [self.tableView dequeueReusableCellWithIdentifier:@"YYOrderAddressMoreCell" forIndexPath:indexPath];
                cell = morecell;
            }
        }

    }else if (indexPath.section != self.totalSections-1) {
        YYOrderOneInfoModel *orderOneInfoModel = _currentYYOrderInfoModel.groups[indexPath.section - 1];
        if ([orderOneInfoModel isInStock] && !(indexPath.row&1)) {
            NSString *CellIdentifier = NSStringFromClass([YYOrderDetailSectionHead class]);
            YYOrderDetailSectionHead *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"OrderDetail" bundle:[NSBundle mainBundle]];
                YYCustomCellTableViewController *customCellTableViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYCustomCellTableViewController"];
                cell = [customCellTableViewController.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            YYOrderStyleModel *orderStyleModel = [orderOneInfoModel.styles objectAtIndex:indexPath.row / 2];
            YYOrderSeriesModel *orderSeriesModel = self.currentYYOrderInfoModel.seriesMap[[orderStyleModel.seriesId stringValue]];
            cell.orderOneInfoModel = orderOneInfoModel;
            cell.orderSeriesModel = orderSeriesModel;
            cell.isHiddenSelectDateView = YES;
            [cell updateUI];
            YYSelecteDateView *selecteDateView = (YYSelecteDateView *)[cell viewWithTag:90008];
            cell.contentView.backgroundColor = [UIColor colorWithHex:@"f8f8f8"];
            selecteDateView.backgroundColor = [UIColor colorWithHex:@"f8f8f8"];
            return cell;
        } else {
            static NSString *CellIdentifier = @"YYStyleDetailCell";
            YYStyleDetailCell *tempCell =  [_tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if(!tempCell){
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"OrderDetail" bundle:[NSBundle mainBundle]];
                YYCustomCellTableViewController *customCellTableViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYCustomCellTableViewController"];
                tempCell = [customCellTableViewController.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            }
            [tempCell setDeleteStyleButtonClicked:^(YYOrderStyleModel *orderStyleModel,long seriesId){
                if(ws.stylesAndTotalPriceModel.totalStyles == 1){

                    CMAlertView *alertView = [[CMAlertView alloc] initWithTitle:NSLocalizedString(@"是否删除最后一件款式？",nil) message:nil needwarn:NO delegate:nil cancelButtonTitle:NSLocalizedString(@"取消",nil) otherButtonTitles:@[[NSString stringWithFormat:@"%@|000000",NSLocalizedString(@"确定",nil)]]];
                    alertView.specialParentView = ws.view;
                    [alertView setAlertViewBlock:^(NSInteger selectedIndex){
                        if (selectedIndex == 1) {
                            [ws deleteObjectWithStyle:orderStyleModel];
                        }
                    }];
                    [alertView show];
                }else{
                    [ws deleteObjectWithStyle:orderStyleModel];
                }

            }];

            [tempCell setDiscountStyleButtonClicked:^(YYOrderStyleModel *orderStyleModel,long seriesId){
                [[YYYellowPanelManage instance] showOrderAddStyleRemarkViewWidthParentView:ws.view info:orderStyleModel andCallBack:^(NSArray *value) {
                    [YYToast showToastWithView:ws.view title:NSLocalizedString(@"添加成功！",nil) andDuration:kAlertToastDuration];
                    [ws updateUI];
                }];
            }];

            if (_currentYYOrderInfoModel && _currentYYOrderInfoModel.groups && [_currentYYOrderInfoModel.groups count] > 0) {
                YYOrderOneInfoModel *orderOneInfoModel = _currentYYOrderInfoModel.groups[indexPath.section-1];
                if (orderOneInfoModel.styles && [orderOneInfoModel.styles count] > 0) {
                    YYOrderStyleModel *orderStyleModel = [orderOneInfoModel.styles objectAtIndex:[orderOneInfoModel isInStock] ? indexPath.row / 2 : indexPath.row];
                    orderStyleModel.curType = _currentYYOrderInfoModel.curType;

                    if ([_selectedArray count] > 0) {
                        if ([_selectedArray containsObject:orderStyleModel]) {
                            tempCell.checkButtonIsChecked = YES;
                        }else{
                            tempCell.checkButtonIsChecked = NO;
                        }
                    }

                    //tempCell.seriesId = [orderOneInfoModel.seriesId longValue];
                    tempCell.menuData = _menuData;
                    tempCell.orderStyleModel = orderStyleModel;
                    //tempCell.isModifyNow = YES;
                    if (_isCreatOrder) {
                        if(_isReBuildOrder){
                            tempCell.isModifyNow = YES;
                        }else{
                            tempCell.isModifyNow = NO;
                        }
                        tempCell.isCreatOrder = YES;
                    }else{
                        tempCell.isModifyNow = YES;
                    }
                    tempCell.showRemarkButton = YES;
                    tempCell.showTotal = YES;
                    tempCell.selectTaxType = _selectTaxType;
                    tempCell.isAppendOrder = _isAppendOrder;
                    [tempCell updateUI];
                }
            }
            [tempCell setBottomView:YES];
            cell = tempCell;
        }
    }else if (indexPath.section == self.totalSections-1) {

        static NSString *CellIdentifier = @"YYOrderRemarkCell";
        YYOrderRemarkCell *orderRemarkCell =  [_tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if(!orderRemarkCell){
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"OrderDetail" bundle:[NSBundle mainBundle]];
            YYCustomCell02ViewController *customCell02ViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYCustomCell02ViewController"];
            orderRemarkCell = [customCell02ViewController.tableView dequeueReusableCellWithIdentifier:CellIdentifier];

            WeakSelf(ws);
            __block YYOrderRemarkCell *blockOrderRemarkCell = orderRemarkCell;
            [orderRemarkCell setTaxChooseBlock:^{
                //跳转税率选择界面
                YYTaxChooseViewController *chooseTaxView = [[YYTaxChooseViewController alloc] init];
                chooseTaxView.selectIndex = ws.selectTaxType;
                chooseTaxView.selectData = ws.menuData;
                __block YYTaxChooseViewController *tempChooseTaxView = chooseTaxView;
                [chooseTaxView setCancelButtonClicked:^(){
                    removeFromSuperviewUseUseAnimateAndDeallocViewController(tempChooseTaxView.view,tempChooseTaxView);
                }];
                [chooseTaxView setSelectBlock:^(NSInteger selectIndex){
                    ws.selectTaxType = selectIndex;
                    if(selectIndex != 2){
                        ws.menuData = getPayTaxInitData();
                    }
                    removeFromSuperviewUseUseAnimateAndDeallocViewController(tempChooseTaxView.view,tempChooseTaxView);
                    [blockOrderRemarkCell btnClick:indexPath.row section:indexPath.section andParmas:@[@"taxType",@(ws.selectTaxType)]];
                }];
                [self addToWindow:chooseTaxView parentView:self.view];
            }];
            //订单备注这块
            [orderRemarkCell setTextViewIsEditCallback:^(BOOL isEdit){
                if (isEdit) {
                    ws.tableViewBottomLayoutConstraint.constant = 310;
                }else{
                    ws.tableViewBottomLayoutConstraint.constant = 0;
                }

                [UIView animateWithDuration:0.3 animations:^{
                    [ws.tableView layoutIfNeeded];
                    [ws.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:ws.totalSections-1] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                }];

            }];

            //选择创建订单人这块
            YYUser *user = [YYUser currentUser];
            if(user.userType != YYUserTypeRetailer){
                [orderRemarkCell setBuyerButtonClicked:^(UIView *view){

                    if(user.userType != YYUserTypeShowroom && user.userType != YYUserTypeShowroomSub && user.userType != YYUserTypeSales){

                        [YYUserApi getSalesManListWithBlockNew:^(YYRspStatusAndMessage *rspStatusAndMessage, YYSalesManListModel *salesManListModel, NSError *error) {
                            if (rspStatusAndMessage.status == YYReqStatusCode100) {
                                //排序

                                if(user.userType == YYUserTypeDesigner){
                                    [salesManListModel sortModelWithAddArr:nil];
                                    NSLog(@"111");
                                }else
                                {
                                    [salesManListModel sortModelWithAddArr:nil];
                                }

                                NSInteger dataCount = [ws getArrayCount:salesManListModel.result];
                                if(dataCount == 0){

                                    [YYToast showToastWithView:ws.view title:NSLocalizedString(@"没有销售代表可供选择",nil) andDuration:kAlertToastDuration];
                                    return ;
                                }

                                CGPoint vp = CGPointMake(CGRectGetWidth(view.frame), CGRectGetHeight(view.frame)/2);
                                CGPoint p = [view convertPoint:vp toView:ws.view];

                                CGRect rc  = CGRectMake(p.x, p.y, 0, 0);

                                YYSelectUserTableViewController *selectUserTableViewController = [[YYSelectUserTableViewController alloc] init];

                                selectUserTableViewController.currentUserId = [ws.currentYYOrderInfoModel.billCreatePersonId intValue];
                                selectUserTableViewController.currentUserName = ws.currentYYOrderInfoModel.billCreatePersonName;
                                selectUserTableViewController.salesManListModel = salesManListModel;
                                selectUserTableViewController.preferredContentSize = CGSizeMake(250,MIN((dataCount*45),300));
                                [selectUserTableViewController setSelectedTowValue:^(NSInteger userId, NSString *username){
                                    ws.currentYYOrderInfoModel.billCreatePersonId =  [NSNumber numberWithInteger:userId];
                                    ws.currentYYOrderInfoModel.billCreatePersonName = username;
                                    ws.currentYYOrderInfoModel.billCreatePersonType = [salesManListModel getTypeWithID:ws.currentYYOrderInfoModel.billCreatePersonId WithName:ws.currentYYOrderInfoModel.billCreatePersonName];
                                    [ws.tableView reloadData];
                                    [ws.popController dismissPopoverAnimated:YES];
                                }];

                                UIPopoverController *popController = [[UIPopoverController alloc] initWithContentViewController:selectUserTableViewController];
                                popController.delegate = ws;
                                ws.popController = popController;
                                selectUserTableViewController.view.layer.borderColor = [UIColor blackColor].CGColor;
                                selectUserTableViewController.view.layer.borderWidth = 4;
                                [popController setPopoverBackgroundViewClass:[YYPopoverArrowBackgroundView class]];
                                [popController presentPopoverFromRect:rc inView:ws.view permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];

                            }else{
                                [YYToast showToastWithView:ws.view title:rspStatusAndMessage.message andDuration:kAlertToastDuration];
                            }
                        }];
                    }

                }];
            }
            //选择下单场这块
            [orderRemarkCell setOrderSituationButtonClicked:^(UIView *view){
                NSInteger dataCount = [ws getArrayCount:ws.orderSettingInfoModel.occasionList];
                if(dataCount == 0){
                    [YYToast showToastWithView:ws.view title:NSLocalizedString(@"没有建单场合可供选择",nil) andDuration:kAlertToastDuration];
                    return ;
                }
                CGPoint vp = CGPointMake(CGRectGetWidth(view.frame), CGRectGetHeight(view.frame)/2);
                CGPoint p = [view convertPoint:vp toView:ws.view];

                CGRect rc  = CGRectMake(p.x, p.y, 0, 0);

                YYSelecteOrderSituationTableViewController *selecteOrderSituationTableViewController = [[YYSelecteOrderSituationTableViewController alloc] init];
                selecteOrderSituationTableViewController.currentSituation = ws.currentYYOrderInfoModel.occasion;
                selecteOrderSituationTableViewController.currentOrderSettingInfoModel = ws.orderSettingInfoModel;

                selecteOrderSituationTableViewController.preferredContentSize = CGSizeMake(300,MIN((dataCount*45),300));
                [selecteOrderSituationTableViewController setSelectedValue:^(NSString *selectedValue){
                    ws.currentYYOrderInfoModel.occasion = selectedValue;
                    [ws.tableView reloadData];
                    [ws.popController dismissPopoverAnimated:YES];
                }];


                UIPopoverController *popController = [[UIPopoverController alloc] initWithContentViewController:selecteOrderSituationTableViewController];
                popController.delegate = ws;
                ws.popController = popController;
                selecteOrderSituationTableViewController.view.layer.borderColor = [UIColor blackColor].CGColor;
                selecteOrderSituationTableViewController.view.layer.borderWidth = 4;
                [popController setPopoverBackgroundViewClass:[YYPopoverArrowBackgroundView class]];
                [popController presentPopoverFromRect:rc inView:ws.view permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
            }];


            //添加折扣这块
            [orderRemarkCell setDiscountButtonClicked:^(){
                UIView *superView = ws.view;
                double originalPrice = [ws.stylesAndTotalPriceModel.originalTotalPrice doubleValue]*(1 + [ws.currentYYOrderInfoModel.taxRate doubleValue]/100);
                double finalPrice = [ws.currentYYOrderInfoModel.finalTotalPrice doubleValue];
                //若为款式添加折扣，订单总价的折扣将被清除，是否继续吗？继续添加折扣/取消
                [[YYYellowPanelManage instance] showStyleDiscountPanel:@"Account" andIdentifier:@"YYDiscountViewController" type:DiscountTypeTotalPrice orderStyleModel:nil orderInfoModel:ws.currentYYOrderInfoModel AndSeriesId:0 originalPrice:originalPrice finalPrice:finalPrice parentView:superView andCallBack:^(NSArray *value) {
                    [ws updateUI];
                }];
            }];
            //税制
            [orderRemarkCell setTaxTypeButtonClicked:^(NSInteger type){
                ws.selectTaxType = type;
                ws.currentYYOrderInfoModel.taxRate = [NSNumber numberWithInteger:getPayTaxTypeToServiceNew(ws.menuData,type)];
                [ws updateUI];
            }];
        }
        orderRemarkCell.menuData = _menuData;
        orderRemarkCell.currentYYOrderInfoModel = self.currentYYOrderInfoModel;
        orderRemarkCell.isCreatOrder = _isCreatOrder;
        orderRemarkCell.selectTaxType = _selectTaxType;
        orderRemarkCell.isAppendOrder = _isAppendOrder;
        orderRemarkCell.parentController =self;
        orderRemarkCell.stylesAndTotalPriceModel= _stylesAndTotalPriceModel;
        [orderRemarkCell updateUI];

        cell = orderRemarkCell;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    return cell;
}
#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if(section == 0){
        return  25;
    }
    return  0.1;
}
- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section {
    view.tintColor = [UIColor clearColor];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        if(indexPath.row == 0){
            return 290 + 15 + 70;
        }else{
            NSInteger totalRow = 1 + (self.nowBuyerAddress?1:0) ;//+ [self.buyerAddressList count]
            if (indexPath.row >=totalRow){
                return 20;
            }
            YYOrderBuyerAddress *address = nil;
            address = self.nowBuyerAddress;
            NSString * addressStr = getBuyerAddressStr_pad(address);//
            return [YYOrderAddressItemView getCellHeight:addressStr];
        }
    }else if (indexPath.section == self.totalSections-1) {
        if(needPayTaxView([_currentYYOrderInfoModel.curType integerValue])){
            return 355;
        }else{
            return 300;
        }
    }else{
        NSInteger lines = 0;
        YYOrderOneInfoModel *orderOneInfoModel =  [_currentYYOrderInfoModel.groups objectAtIndex:indexPath.section-1];
        if ([orderOneInfoModel isInStock] && !(indexPath.row&1)) {
            return 71;
        } else {
            if (orderOneInfoModel && ([orderOneInfoModel isInStock] ? indexPath.row / 2 : indexPath.row) < [orderOneInfoModel.styles count]) {
                YYOrderStyleModel *orderStyleModel = [orderOneInfoModel.styles objectAtIndex:[orderOneInfoModel isInStock] ? indexPath.row / 2 : indexPath.row];
                if (orderStyleModel && orderStyleModel.colors) {
                    //lines = (int)[orderStyleModel.amount count];

                    NSInteger totalamount = 0;
                    for (int i=0; i<[orderStyleModel.colors count]; i++) {
                        YYOrderOneColorModel *orderOneColorModel = [orderStyleModel.colors objectAtIndex:i];
                        if(checkOrderOneColorHasAmount(orderOneColorModel) || [orderOneColorModel.isColorSelect boolValue]){
                            totalamount ++;
                        }
                    }
                    lines = totalamount;
                }
            }

            lines = MAX(1, lines);
            return (lines+1)*50+160-40 -30 + 45;
        }
    }

    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section != 0 && section != self.totalSections - 1) {
        YYOrderOneInfoModel *orderOneInfoModel =  [_currentYYOrderInfoModel.groups objectAtIndex:section- 1];
        if ([orderOneInfoModel isInStock]) {
            return nil;
        } else {
            static NSString *CellIdentifier = @"YYOrderDetailSectionHead";

            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"OrderDetail" bundle:[NSBundle mainBundle]];
            YYCustomCellTableViewController *customCellTableViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYCustomCellTableViewController"];

            YYOrderDetailSectionHead *sectionHead = [customCellTableViewController.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            YYSelecteDateView *selecteDateView = (YYSelecteDateView *)[sectionHead viewWithTag:90008];
            sectionHead.contentView.backgroundColor = [UIColor colorWithHex:@"f8f8f8"];
            selecteDateView.backgroundColor = [UIColor colorWithHex:@"f8f8f8"];
            if([_currentYYOrderInfoModel.groups count] > 0){
                YYOrderOneInfoModel *orderOneInfoModel =  [_currentYYOrderInfoModel.groups objectAtIndex:section-1];
                sectionHead.orderOneInfoModel = orderOneInfoModel;
                [sectionHead updateUI];
                sectionHead.hidden = NO;
            }else{
                sectionHead.hidden = YES;
            }
            return sectionHead;
        }
    } else {
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0 || section == self.totalSections-1) {
        return 0;
    } else {
        YYOrderOneInfoModel *orderOneInfoModel =  [_currentYYOrderInfoModel.groups objectAtIndex:section- 1];
        if ([orderOneInfoModel isInStock]) {
            return 0;
        }
        return 71;
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0 || indexPath.section == self.totalSections-1) {
        return ;
    } else {
        YYOrderOneInfoModel *orderOneInfoModel =  [_currentYYOrderInfoModel.groups objectAtIndex:indexPath.section - 1];
        if ([orderOneInfoModel isInStock]) {
            if (indexPath.row&1) {
                [self showShoppingView:[NSIndexPath indexPathForRow:indexPath.row / 2 inSection:indexPath.section]];
            }
        }else {
            [self showShoppingView:indexPath];
        }
    }
}

#pragma mark - --------------自定义代理/block----------------------


#pragma mark - --------------自定义响应----------------------
#pragma mark Notifications
- (void)updateShoppingCarNotification:(NSNotification *)note{
    [self orderAddStyleNotification:note];
}
- (void)orderAddStyleNotification:(NSNotification *)note{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.orderModel) {
        NSLog(@"appDelegate.orderModel toJSONString : %@",[appDelegate.orderModel toJSONString]);

        self.currentYYOrderInfoModel = [[YYOrderInfoModel alloc] initWithDictionary:[appDelegate.orderModel toDictionary] error:nil];
        self.currentYYOrderInfoModel.finalTotalPrice = nil;
        if (note == nil) {
            appDelegate.orderSeriesArray = nil;
            appDelegate.orderModel = nil;
        }
    }
    [self updateUI];
}
#pragma mark SomeClicked
- (IBAction)closeButtonClicked:(id)sender{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kUpdateShoppingCarNotification object:nil];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.orderModel) {
        appDelegate.orderSeriesArray = nil;
        appDelegate.orderModel = nil;
    }
    [self hidePopUpViewAnimated:NO];
    if (self.closeButtonClicked) {
        self.closeButtonClicked();
    }
    //    返回的时候删除对应的图片
    if(_chooseImgKey&&_uploadImgPathType){
        [YYRequestHelp DeleteQiniuImgWithKey:_chooseImgKey WithPathType:_uploadImgPathType WithBlock:nil];
    }
}
- (IBAction)saveButtonClicked:(id)sender{
    if (_stylesAndTotalPriceModel.totalStyles == 0) {
        if(_isCreatOrder){

            [YYToast showToastWithView:self.view title:NSLocalizedString(@"订单中款式数为0，不能建立订单",nil)  andDuration:kAlertToastDuration];
        }else{
            [YYToast showToastWithView:self.view title:NSLocalizedString(@"订单中款式数为0，不能保存修改",nil)  andDuration:kAlertToastDuration];
        }
        return;
    }

    if (_stylesAndTotalPriceModel.totalCount == 0) {
        if(_isCreatOrder){
            [YYToast showToastWithView:self.view title:NSLocalizedString(@"订单中件数为0，不能建立订单",nil)  andDuration:kAlertToastDuration];
        }else{
            [YYToast showToastWithView:self.view title:NSLocalizedString(@"订单中件数为0，不能保存修改",nil)  andDuration:kAlertToastDuration];
        }
        return;
    }

    WeakSelf(ws);
    NSString *tmpBuyerName = (self.currentYYOrderInfoModel.buyerName?self.currentYYOrderInfoModel.buyerName:@"");
    tmpBuyerName = [tmpBuyerName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([tmpBuyerName isEqualToString:@""]) {
        [YYToast showToastWithView:self.view title:NSLocalizedString(@"请添加买手店名称",nil)  andDuration:kAlertToastDuration];
        return;
    }

    if([NSString isNilOrEmpty:self.currentYYOrderInfoModel.type]){
        [YYToast showToastWithView:self.view title:NSLocalizedString(@"请选择订单类型",nil)  andDuration:kAlertToastDuration];
        return;
    }

    if (self.stylesAndTotalPriceModel) {
        self.currentYYOrderInfoModel.totalPrice = self.stylesAndTotalPriceModel.originalTotalPrice;//[NSNumber numberWithFloat: [self.stylesAndTotalPriceModel.originalTotalPrice floatValue]];
        self.currentYYOrderInfoModel.finalTotalPrice =  self.stylesAndTotalPriceModel.finalTotalPrice;

    }
    if (!self.currentYYOrderInfoModel.orderCreateTime) {
        NSTimeInterval time = [[NSDate date] timeIntervalSince1970]*1000;
        self.currentYYOrderInfoModel.orderCreateTime = [NSNumber numberWithLongLong:time];
    }
    self.currentYYOrderInfoModel.designerOrderStatus = [[NSNumber alloc] initWithInt:YYOrderCode_NEGOTIATION];
    self.currentYYOrderInfoModel.buyerOrderStatus = [[NSNumber alloc] initWithInt:YYOrderCode_NEGOTIATION];
    self.currentYYOrderInfoModel.buyerEmail =_buyerModel.contactEmail;

    if (![YYNetworkReachability connectedToNetwork]) {
        if (self.currentYYOrderInfoModel.shareCode
            && !self.currentYYOrderInfoModel.orderCode) {
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            //离线创建的订单信息，先保存至本地
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            YYAddress * adress = [self getcurBuyerAddress];
            if(adress != nil){
                NSString *tempKey = [NSString stringWithFormat:@"%@%@",self.currentYYOrderInfoModel.shareCode,kOfflineOrderAddressSuffix];
                [userDefaults setObject:[NSKeyedArchiver archivedDataWithRootObject:adress] forKey:tempKey];
            }
            NSDictionary *dic = [userDefaults persistentDomainForName:kOfflineOrderDictionaryKey];

            NSMutableDictionary *storeDic = [[NSMutableDictionary alloc] initWithCapacity:0];
            if (dic) {
                [storeDic addEntriesFromDictionary:dic];
            }
            self.currentYYOrderInfoModel.realBuyerId =_buyerModel.buyerId;
            if(![NSString isNilOrEmpty:[YYUser getBrandID]]){
                self.currentYYOrderInfoModel.brandID = [YYUser getBrandID];
            }
            NSString *jsonstr = [self.currentYYOrderInfoModel toJSONString];
            [storeDic setValue:jsonstr forKey:self.currentYYOrderInfoModel.shareCode];
            [userDefaults setPersistentDomain:storeDic forName:kOfflineOrderDictionaryKey];
            [userDefaults synchronize];
            [YYToast showToastWithView:ws.view title:NSLocalizedString(@"订单保存至本地成功",nil)  andDuration:kAlertToastDuration];

            // 延迟调用
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kDelaySeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [MBProgressHUD hideAllHUDsForView:ws.view animated:YES];
                [ws closeModifyOrderViewWhenSave];
            });
        }
    }else{
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        YYAddress * adress = [self getcurBuyerAddress];
        if(adress != nil){
            __block BOOL _inRunLoop = true;
            [YYOrderApi createOrModifyAddress:adress andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYBuyerAddressModel *addressModel, NSError *error) {
                if (rspStatusAndMessage.status == YYReqStatusCode100
                    && addressModel
                    && addressModel.addressId){
                    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
                    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
                    ws.currentYYOrderInfoModel.buyerAddress.addressId = [numberFormatter numberFromString:addressModel.addressId];
                    ws.currentYYOrderInfoModel.buyerAddressId = [numberFormatter numberFromString:addressModel.addressId];
                    _inRunLoop = false;
                }else{
                    [MBProgressHUD hideAllHUDsForView:ws.view animated:YES];
                }
            }];
            while (_inRunLoop) {
                [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
            }
        }
        NSData *jsonData = [self.currentYYOrderInfoModel toJSONData];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData
                                                     encoding:NSUTF8StringEncoding];
        NSLog(@"jsonString: %@",jsonString);
        NSString *actionRefer = (_isCreatOrder?@"create":@"modify");
        if(_isAppendOrder){
            actionRefer = @"append";
        }
        NSInteger realBuyerId = [_buyerModel.buyerId integerValue];



        [YYOrderApi createOrModifyOrderByJsonString:jsonString actionRefer:actionRefer realBuyerId:realBuyerId andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSString *orderCode, NSError *error) {
            if (rspStatusAndMessage.status == YYReqStatusCode100) {
                [YYTopAlertView showWithType:YYTopAlertTypeSuccess text:NSLocalizedString(@"操作成功",nil) parentView:ws.view];

                // 延迟调用
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kDelaySeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [MBProgressHUD hideAllHUDsForView:ws.view animated:YES];
                    [ws closeModifyOrderViewWhenSave];
                });

            }else{
                [MBProgressHUD hideAllHUDsForView:ws.view animated:YES];
                [YYToast showToastWithView:ws.view title:rspStatusAndMessage.message  andDuration:kAlertToastDuration];
            }

        }];
    }
}

- (IBAction)firstButtonClicked:(id)sender{
    if (_stylesAndTotalPriceModel.totalStyles == [_selectedArray count]){
        [_selectedArray removeAllObjects];
    }else if ([_selectedArray count] < _stylesAndTotalPriceModel.totalStyles){
        [_selectedArray removeAllObjects];
        //然后添加全部
        [self addAllObjectWithYYOrderInfoModel:self.currentYYOrderInfoModel AndArray:_selectedArray];
    }
    [self updateUI];
}
- (IBAction)secondButtonClicked:(id)sender{
    [self deleteObject];
    [self updateUI];
}
//添加款式
- (IBAction)thirdButtonClicked:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Opus" bundle:[NSBundle mainBundle]];
    YYStyleDetailListViewController *styleDetailListViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYStyleDetailListViewController"];
    styleDetailListViewController.isModifyOrder = YES;
    styleDetailListViewController.designerId = [self.currentYYOrderInfoModel.designerId integerValue];
    styleDetailListViewController.currentYYOrderInfoModel = self.currentYYOrderInfoModel;

    //把当前的订单对象，传到全局的AppDelegate中
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.orderModel = [[YYOrderInfoModel alloc] initWithDictionary:[self.currentYYOrderInfoModel toDictionary] error:nil];

    NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:0];
    [tempArray addObjectsFromArray:self.currentYYOrderInfoModel.groups];
    appDelegate.orderSeriesArray = tempArray;
    [self.navigationController pushViewController:styleDetailListViewController animated:YES];
}
//warnOrderMinMoney
- (IBAction)warnOrderMinMoney:(id)sender {
    [self hidePopUpViewAnimated:NO];
    if(self.popUpView == nil){
        self.popUpView = [[ASPopUpView alloc] initWithFrame:CGRectZero];
        self.popUpView.alpha = 0.0;
        [self.popUpView setFont:[UIFont systemFontOfSize:12]];
        [self.popUpView setTextColor:[UIColor colorWithHex:@"ef4e31"]];
        [self.popUpView setColor:[UIColor colorWithHex:@"ef4e31"]];
        [_bottomView addSubview:self.popUpView];
    }
    NSString *string =  _minOrderMoneyTip;
    CGSize size = [self.popUpView popUpSizeForString:string];
    float popUpViewOffsetX = CGRectGetMidX(_minOrderMoneyBtn1.frame);
    CGRect popUpRect = CGRectMake(-(size.width+10)/2+popUpViewOffsetX,5, size.width+10, size.height+20);
    [self.popUpView setFrame:popUpRect arrowOffset:0 text:string];
    [self showPopUpViewAnimated:YES];
}
#pragma mark Other
- (void)closeModifyOrderViewWhenSave{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kUpdateShoppingCarNotification object:nil];
    if (self.modifySuccess) {
        self.modifySuccess();
    }
}
-(void)OnTapBg:(UITapGestureRecognizer *)sender{
    [self hidePopUpViewAnimated:NO];
}
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    NSLog(@"%@",NSStringFromClass([touch.view class]));
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"] || [NSStringFromClass([touch.view class]) isEqualToString:@"UIControl"] ||
        [NSStringFromClass([touch.view class]) isEqualToString:@"UIButton"]) {//如果当前是tableView

        //做自己想做的事
        [self hidePopUpViewAnimated:NO];
        return NO;
    }
    return YES;
}
#pragma mark - --------------自定义方法----------------------
#pragma mark Update
//更新显示总数
- (void)updateTotalValue{
    self.stylesAndTotalPriceModel = [self.currentYYOrderInfoModel getTotalValueByOrderInfo:NO];

    if (_stylesAndTotalPriceModel) {
        _countLabel.text = [NSString stringWithFormat:NSLocalizedString(@"共计%i款 %i件",nil),_stylesAndTotalPriceModel.totalStyles,_stylesAndTotalPriceModel.totalCount];


        _priceTotalDiscountView.backgroundColor = [UIColor clearColor];
        _priceTotalDiscountView.bgColorIsBlack = YES;

        self.currentYYOrderInfoModel.finalTotalPrice = self.stylesAndTotalPriceModel.finalTotalPrice;
        if(_isCreatOrder){
            _priceTitle.text = NSLocalizedString(@"实付",nil);

        }else{
            _priceTitle.text = NSLocalizedString(@"总价",nil);
        }

        _priceTotalDiscountView.showDiscountValue = NO;

        NSString *finalValue = replaceMoneyFlag([NSString stringWithFormat:@"￥%.2f",[_currentYYOrderInfoModel.finalTotalPrice doubleValue]],[_currentYYOrderInfoModel.curType integerValue]);
        _priceTotalDiscountView.notShowDiscountValueTextAlignmentLeft = YES;
        [_priceTotalDiscountView updateUIWithOriginPrice:finalValue
                                              fianlPrice:finalValue
                                              originFont:[UIFont boldSystemFontOfSize:16]
                                               finalFont:[UIFont boldSystemFontOfSize:16]];
        CGSize finalValueSize = [finalValue sizeWithAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:16]}];
        [_priceTotalDiscountView setConstraintConstant:finalValueSize.width+1 forAttribute:NSLayoutAttributeWidth];

        __block double blockcostMeoney = [self.stylesAndTotalPriceModel.finalTotalPrice doubleValue];
        __block float blockcurType = [_currentYYOrderInfoModel.curType integerValue];
        WeakSelf(ws);
        if(blockcurType >= 0){
            [YYOrderApi getOrderUnitPrice:[_currentYYOrderInfoModel.designerId unsignedIntegerValue] moneyType:blockcurType andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSUInteger orderUnitPrice, NSError *error) {
                if(orderUnitPrice > blockcostMeoney){
                    UIImage *icon = [[UIImage imageNamed:@"warn"] imageWithTintColor:[UIColor colorWithHex:@"ef4e31"]];
                    [ws.minOrderMoneyBtn1 setImage:icon forState:UIControlStateNormal];
                    ws.minOrderMoneyTip = replaceMoneyFlag([NSString stringWithFormat:NSLocalizedString(@"未达到每单起订额\n ￥%ld",nil),(unsigned long)orderUnitPrice],blockcurType);
                    ws.minOrderMoneyBtn1.hidden = NO;
                }else{
                    ws.minOrderMoneyBtn1.hidden = YES;
                }
            }];
        }
    }
}

- (void)updateUI{
    if (_isCreatOrder) {
        _titleLabel.text = NSLocalizedString(@"新建订单",nil);
        [_saveButton setTitle:NSLocalizedString(@"创建订单",nil) forState:UIControlStateNormal];
        //创建时，订单状态是正常
        if (!self.currentYYOrderInfoModel.designerOrderStatus || !self.currentYYOrderInfoModel.buyerOrderStatus) {
            self.currentYYOrderInfoModel.designerOrderStatus = [NSNumber numberWithInt:0];
            self.currentYYOrderInfoModel.buyerOrderStatus = [NSNumber numberWithInt:0];
        }
        _thirdButton.hidden = YES;
        if (!self.currentYYOrderInfoModel.shareCode) {
            //如果是新建订单，而且没有网络

            self.currentYYOrderInfoModel.shareCode = createOrderSharecode();
        }

        // 进入埋点
        [MobClick beginLogPageView:kYYPageOrderModifyCreate];

    }else{
        _thirdButton.hidden = NO;
        if(!_isAppendOrder){
            _titleLabel.text = NSLocalizedString(@"修改订单",nil);
            [_saveButton setTitle:NSLocalizedString(@"保存修改",nil) forState:UIControlStateNormal];

            // 进入埋点
            [MobClick beginLogPageView:kYYPageOrderModifyUpdate];

        }else{
            _titleLabel.text = NSLocalizedString(@"追单补货",nil);
            [_saveButton setTitle:NSLocalizedString(@"确认追单",nil) forState:UIControlStateNormal];

            // 进入埋点
            [MobClick beginLogPageView:kYYPageOrderModifyAddTo];
        }
    }

    if (!self.currentYYOrderInfoModel.orderCreateTime) {
        NSTimeInterval time = [[NSDate date] timeIntervalSince1970]*1000;
        self.currentYYOrderInfoModel.orderCreateTime = [NSNumber numberWithLongLong:time];
    }

    [self updateTotalValue];

    self.totalSections = [self.currentYYOrderInfoModel.groups count]+2;

    if(!_stylesAndTotalPriceModel.totalStyles || !_stylesAndTotalPriceModel.totalCount){
        self.saveButton.layer.borderWidth = 0;
        _saveButton.backgroundColor = [UIColor colorWithHex:@"d3d3d3"];
        [_saveButton setTintColor:_define_black_color];
    }else{
        self.saveButton.layer.borderWidth = 1;
        _saveButton.backgroundColor = _define_black_color;
        [_saveButton setTintColor:_define_white_color];
    }

    [self.tableView reloadData];
}
- (void)updateBuyerAddress:(YYAddress *)nowAddress{
    YYOrderBuyerAddress *buyerAddress = [[YYOrderBuyerAddress alloc] init];

    if (nowAddress.addressId) {
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];

        NSNumber *addressNumber = [numberFormatter numberFromString:nowAddress.addressId];
        buyerAddress.addressId = addressNumber;
    }

    if (nowAddress.receiverName) {
        buyerAddress.receiverName = nowAddress.receiverName;
    }
    if (nowAddress.receiverPhone) {
        buyerAddress.receiverPhone = nowAddress.receiverPhone;
    }
    if (nowAddress.zipCode) {
        buyerAddress.zipCode = nowAddress.zipCode;
    }
    if (nowAddress.detailAddress) {
        buyerAddress.detailAddress = nowAddress.detailAddress;
    }
    if (nowAddress.nation) {
        buyerAddress.nation = nowAddress.nation;
    }
    if (nowAddress.province) {
        buyerAddress.province = nowAddress.province;
    }
    if (nowAddress.city) {
        buyerAddress.city = nowAddress.city;
    }
    if (nowAddress.nationEn) {
        buyerAddress.nationEn = nowAddress.nationEn;
    }
    if (nowAddress.provinceEn) {
        buyerAddress.provinceEn = nowAddress.provinceEn;
    }
    if (nowAddress.cityEn) {
        buyerAddress.cityEn = nowAddress.cityEn;
    }
    if (nowAddress.nationId) {
        buyerAddress.nationId = nowAddress.nationId;
    }
    if (nowAddress.provinceId) {
        buyerAddress.provinceId = nowAddress.provinceId;
    }
    if (nowAddress.cityId) {
        buyerAddress.cityId = nowAddress.cityId;
    }
    self.currentYYOrderInfoModel.buyerAddress = buyerAddress;
    self.currentYYOrderInfoModel.buyerAddressId = buyerAddress.addressId;
    _nowBuyerAddress = buyerAddress;
    [self updateUI];
}
#pragma mark Other
-(YYAddress *)getcurBuyerAddress{
    if(_currentYYOrderInfoModel.buyerAddress == nil || [_currentYYOrderInfoModel.buyerAddress.addressId integerValue] == [_nowBuyerAddress.addressId integerValue] ){
        return nil;
    }
    YYAddress *newAddress = [[YYAddress alloc] init];
    newAddress.addressId = 0;
    newAddress.receiverName = _currentYYOrderInfoModel.buyerAddress.receiverName;
    newAddress.receiverPhone = _currentYYOrderInfoModel.buyerAddress.receiverPhone;
    newAddress.zipCode = _currentYYOrderInfoModel.buyerAddress.zipCode;
    newAddress.detailAddress = _currentYYOrderInfoModel.buyerAddress.detailAddress;
    newAddress.nation = _currentYYOrderInfoModel.buyerAddress.nation;
    newAddress.province = _currentYYOrderInfoModel.buyerAddress.province;
    newAddress.city = _currentYYOrderInfoModel.buyerAddress.city;
    newAddress.nationEn = _currentYYOrderInfoModel.buyerAddress.nationEn;
    newAddress.provinceEn = _currentYYOrderInfoModel.buyerAddress.provinceEn;
    newAddress.cityEn = _currentYYOrderInfoModel.buyerAddress.cityEn;
    newAddress.nationId = _currentYYOrderInfoModel.buyerAddress.nationId;
    newAddress.provinceId = _currentYYOrderInfoModel.buyerAddress.provinceId;
    newAddress.cityId = _currentYYOrderInfoModel.buyerAddress.cityId;
    if([_currentYYOrderInfoModel.buyerAddress.defaultShippingAddress integerValue] > 0 || [_currentYYOrderInfoModel.buyerAddress.defaultShipping integerValue] > 0){
        newAddress.defaultShipping = YES;
    }else{
        newAddress.defaultShipping = NO;
    }
    return newAddress;
}

- (void)addAllObjectWithYYOrderInfoModel:(YYOrderInfoModel *)orderInfoModel AndArray:(NSMutableArray *)array{
    if (orderInfoModel
        && array) {
        for (int i=0; i<[orderInfoModel.groups count]; i++) {
            YYOrderOneInfoModel *orderOneInfoModel = [orderInfoModel.groups objectAtIndex:i];
            if(orderOneInfoModel
               && orderOneInfoModel.styles){
                for (YYOrderStyleModel *orderStyleModel in orderOneInfoModel.styles) {
                    [array addObject:orderStyleModel];
                }
            }
        }
    }
}

- (void)addAllObjectWithStyleModel:(YYOrderStyleModel *)deleteStyleModel orderInfoModel:(YYOrderInfoModel *)orderInfoModel AndArray:(NSMutableArray *)array{
    if (orderInfoModel
        && array) {
        for (int i=0; i<[orderInfoModel.groups count]; i++) {
            YYOrderOneInfoModel *orderOneInfoModel = [orderInfoModel.groups objectAtIndex:i];
            if(orderOneInfoModel
               && orderOneInfoModel.styles){
                for (YYOrderStyleModel *orderStyleModel in orderOneInfoModel.styles) {
                    if(deleteStyleModel && [deleteStyleModel.styleId integerValue] == [orderStyleModel.styleId integerValue]){
                        [array addObject:orderStyleModel];
                    }
                }
            }
        }
    }
}

- (void)deleteObject{
    if ([_selectedArray count] > 0) {
        NSMutableArray *seriesIds =  [[NSMutableArray alloc] init];

        NSInteger i = [_currentYYOrderInfoModel.groups count]-1;
        for (; i>=0; i--) {
            YYOrderOneInfoModel *orderOneInfoModel = [_currentYYOrderInfoModel.groups objectAtIndex:i];
            if (orderOneInfoModel) {
                if ([orderOneInfoModel.styles count] > 0) {
                    [orderOneInfoModel.styles removeObjectsInArray:_selectedArray];

                    if ([orderOneInfoModel.styles count] == 0) {
                        [_currentYYOrderInfoModel.groups removeObject:orderOneInfoModel];
                    }else{
                        for (YYOrderStyleModel *orderStyleModel in orderOneInfoModel.styles) {
                            if(![seriesIds containsObject:[orderStyleModel.seriesId stringValue]]){
                                [seriesIds addObject:[orderStyleModel.seriesId stringValue]];
                            }
                        }
                    }
                }
            }
        }

        //删除系列队列seriesMap
        NSArray *allKeys = [_currentYYOrderInfoModel.seriesMap allKeys];
        for (NSString *seriesId  in allKeys) {
            if(![seriesIds containsObject:seriesId]){
                [_currentYYOrderInfoModel.seriesMap removeObjectForKey:seriesId];
            }
        }
        //删除后，最后总价清0，后面重新计算
        _currentYYOrderInfoModel.finalTotalPrice = [NSNumber numberWithFloat:0.0];
    }
    [_selectedArray removeAllObjects];
}

-(void)deleteObjectWithStyle:(YYOrderStyleModel *)orderStyleModel{
    [_selectedArray removeAllObjects];
    [self addAllObjectWithStyleModel:orderStyleModel orderInfoModel:self.currentYYOrderInfoModel AndArray:_selectedArray];
    [self deleteObject];
    [self updateUI];
}

-(void)deleteBuyerAddress{
    _currentYYOrderInfoModel.buyerAddressId = 0;
    _currentYYOrderInfoModel.buyerAddress = nil;
    _nowBuyerAddress = nil;
    [self updateUI];
}

//添加收件地址
- (void)addAddress{
    if (![YYNetworkReachability connectedToNetwork]) {
        [YYToast showToastWithView:self.view title:NSLocalizedString(@"请在网络连接的情况下添加收件地址！",nil) andDuration:kAlertToastDuration];
        return;
    }

    if(!_currentYYOrderInfoModel.addressModifAvailable){
        [YYToast showToastWithView:self.view title:NSLocalizedString(@"买手店已添加过的地址,不能再次添加!",nil) andDuration:kAlertToastDuration];
        return;
    }
    WeakSelf(ws);
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Account" bundle:[NSBundle mainBundle]];
    YYCreateOrModifyAddressViewController *addAddressViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYCreateOrModifyAddressViewController"];
    self.addAddressViewController = addAddressViewController;

    addAddressViewController.currentOperationType = OperationTypeHelpCreate;
    addAddressViewController.currentYYOrderInfoModel = self.currentYYOrderInfoModel;

    if (_nowBuyerAddress) {
        YYAddress *address = [[YYAddress alloc] init];
        address.receiverName = _nowBuyerAddress.receiverName;
        address.receiverPhone = _nowBuyerAddress.receiverPhone;
        address.zipCode = _nowBuyerAddress.zipCode;
        address.detailAddress = _nowBuyerAddress.detailAddress;

        address.nation = _nowBuyerAddress.nation;
        address.province = _nowBuyerAddress.province;
        address.city = _nowBuyerAddress.city;
        address.nationEn = _nowBuyerAddress.nationEn;
        address.provinceEn = _nowBuyerAddress.provinceEn;
        address.cityEn = _nowBuyerAddress.cityEn;
        address.nationId = _nowBuyerAddress.nationId;
        address.provinceId = _nowBuyerAddress.provinceId;
        address.cityId = _nowBuyerAddress.cityId;

        address.street = _nowBuyerAddress.street;

        addAddressViewController.address = address;
    }else{
        addAddressViewController.address = nil;
    }

    __weak UIView *weakSuperView = self.view;
    UIView *showView = addAddressViewController.view;
    __weak UIView *weakShowView = showView;
    [addAddressViewController setCancelButtonClicked:^(){
        removeFromSuperviewUseUseAnimateAndDeallocViewController(weakShowView,ws.addAddressViewController);

    }];

    [addAddressViewController setAddressForBuyerButtonClicked:^(YYAddress *nowAddress){
        if (nowAddress) {
            [ws updateBuyerAddress:nowAddress];
        }
        removeFromSuperviewUseUseAnimateAndDeallocViewController(weakShowView,ws.addAddressViewController);
    }];

    [self.view addSubview:showView];
    [showView mas_makeConstraints:^(MASConstraintMaker *make) {

        make.top.equalTo(weakSuperView.mas_top);
        make.left.equalTo(weakSuperView.mas_left);
        make.bottom.equalTo(weakSuperView.mas_bottom);
        make.right.equalTo(weakSuperView.mas_right);

    }];

    addAnimateWhenAddSubview(showView);
}

- (NSInteger)getArrayCount:(NSArray *)data {
    if (data) {
        return [data count];
    }
    return 0;
}
-(void)addToWindow:(UIViewController *)controller parentView:(UIView *)specialParentView {
    if(specialParentView !=nil){
        self.parentView = specialParentView;
    }else{
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        self.parentView = appDelegate.mainViewController.view;//[UIApplication sharedApplication].keyWindow.rootViewController.view;
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

-(void)showShoppingView:(NSIndexPath *)indexPath{
    //把当前的订单对象，传到全局的AppDelegate中
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.orderModel = [[YYOrderInfoModel alloc] initWithDictionary:[self.currentYYOrderInfoModel toDictionary] error:nil];
    NSLog(@"json %@",[self.currentYYOrderInfoModel toDictionary]);

    NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:0];
    [tempArray addObjectsFromArray:self.currentYYOrderInfoModel.groups];
    appDelegate.orderSeriesArray = tempArray;


    YYOrderOneInfoModel *oneInfoModel = _currentYYOrderInfoModel.groups[indexPath.section-1];
    NSInteger row = indexPath.row;
    YYOrderStyleModel *orderStyleModel = [oneInfoModel.styles objectAtIndex:row];
    orderStyleModel.tmpDateRange = oneInfoModel.dateRange;
    YYOrderSeriesModel *orderseriesModel = [_currentYYOrderInfoModel.seriesMap objectForKey:[orderStyleModel.seriesId stringValue]];
    if(orderStyleModel == nil || orderseriesModel == nil){
        return;
    }

    UIView *superView = self.view;
    [appDelegate showShoppingViewNew:YES styleInfoModel:orderStyleModel seriesModel:orderseriesModel opusStyleModel:nil currentYYOrderInfoModel:_currentYYOrderInfoModel parentView:superView fromBrandSeriesView:NO WithBlock:nil];
}

- (void)showPopUpViewAnimated:(BOOL)animated
{
    if (self.popUpView.alpha == 1.0) return;
    [self.popUpView showAnimated:animated];
}

- (void)hidePopUpViewAnimated:(BOOL)animated
{
    if (self.popUpView==nil || self.popUpView.alpha == 0.0) return;
    //WeakSelf(weakSelf);
    [self.popUpView hideAnimated:animated completionBlock:^{
        //weakSelf.popUpView = nil;
    }];
}
#pragma mark - --------------other----------------------

@end

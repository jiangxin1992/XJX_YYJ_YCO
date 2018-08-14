//
//  YYOrderDetailViewController.m
//  Yunejian
//
//  Created by yyj on 15/8/6.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import "YYOrderDetailViewController.h"

// c文件 —> 系统文件（c文件在前）

// 控制器
#import "YYShareOrderViewController.h"
#import "YYPackingListViewController.h"
#import "YYOrderPayLogViewController.h"
#import "YYPackageDetailViewController.h"
#import "YYNavigationBarViewController.h"
#import "YYConnBuyerInfoViewController.h"
#import "YYOrderModifyLogListController.h"
#import "YYCustomCellTableViewController.h"
#import "YYDeliveringDoneConfirmViewController.h"

// 自定义视图
#import "MBProgressHUD.h"
#import "YYDiscountView.h"
#import "YYBuyerInfoCell1.h"
#import "YYSelecteDateView.h"
#import "YYOrderStatusCell.h"
#import "YYStyleDetailCell.h"
#import "YYPackageListView.h"
#import "YYShowBuyerCardView.h"
#import "YYYellowPanelManage.h"
#import "YYOrderMoneyLogCell.h"
#import "YYOrderPackageInfoCell.h"
#import "YYBuyerInfoRemarkCell.h"
#import "YYPopoverBackgroundView.h"
#import "YYOrderDetailSectionHead.h"

// 接口
#import "YYUserApi.h"
#import "YYOrderApi.h"

// 分类
#import "UIImage+YYImage.h"

// 自定义类和三方类（ cocoapods类 > model > 工具类 > 其他）
#import "YYUser.h"
#import "YYOrderInfoModel.h"
#import "YYPackageListModel.h"
#import "YYOrderConnStatusModel.h"
#import "YYPaymentNoteListModel.h"
#import "YYOrderAppendParamModel.h"
#import "YYOrderTransStatusModel.h"
#import "YYStylesAndTotalPriceModel.h"

#import "AppDelegate.h"

typedef NS_ENUM(NSInteger, kOrderMenuAction) {
    kOrderMenuActionType_modifyOrder     = 10001,      //修改订单
    kOrderMenuActionType_cancelOrder     = 10002,      //取消订单
    kOrderMenuActionType_modifyRecord    = 10003,      //修改记录
    kOrderMenuActionType_closeOrder      = 10004,      //关闭交易
    kOrderMenuActionType_appendOrder     = 10005,      //追单补货
    kOrderMenuActionType_deliveringDone  = 10006       //强制完成发货
};


@interface YYOrderDetailViewController ()<UITableViewDataSource,UITableViewDelegate,YYTableCellDelegate>

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *discountViewTrailingLayoutConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *priceViewlayoutWidthConstraints;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@property (weak, nonatomic) IBOutlet YYDiscountView *priceTotalDiscountView;
@property (weak, nonatomic) IBOutlet UIButton *viewAppendOrderBtn;//追单

@property (nonatomic, strong) YYOrderInfoModel *currentYYOrderInfoModel;
@property (nonatomic, strong) YYOrderTransStatusModel *currentYYOrderTransStatusModel;
@property (nonatomic, strong) YYPaymentNoteListModel *paymentNoteList;
@property (nonatomic, strong) YYNavigationBarViewController *navigationBarViewController;

@property (nonatomic, strong) YYShareOrderViewController *shareOrderViewController;

@property (nonatomic, strong) YYStylesAndTotalPriceModel *stylesAndTotalPriceModel;//总数

@property (nonatomic, strong) UIButton *shareBtn;//分享按钮
@property (nonatomic, strong) UIButton *menuBtn;//menu按钮
@property (nonatomic, strong) UIPopoverController *popController;
@property (nonatomic, strong) UITextView *linkTxtView;

@property (nonatomic, strong) NSMutableArray *menuData;
@property (nonatomic, assign) NSInteger selectTaxType;
@end

@implementation YYOrderDetailViewController
#pragma mark - --------------生命周期--------------
- (void)viewDidLoad {
    [super viewDidLoad];
    [self SomePrepare];
    [self UIConfig];
    [self RequestData];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    // 进入埋点
    [MobClick beginLogPageView:kYYPageOrderDetail];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    // 退出埋点
    [MobClick endLogPageView:kYYPageOrderDetail];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
#pragma mark - --------------SomePrepare--------------
- (void)SomePrepare
{
    [self PrepareData];
    [self PrepareUI];
}
- (void)PrepareData{
    _menuData = getPayTaxInitData();
    _selectTaxType = 0;
}
- (void)PrepareUI{
    //初始化

    _viewAppendOrderBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    _viewAppendOrderBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    _viewAppendOrderBtn.layer.borderWidth = 1;

    _discountViewTrailingLayoutConstraint.constant = 40;

    [self.tableView registerNib:[UINib nibWithNibName:@"YYBuyerInfoCell1" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"YYBuyerInfoCell1"];
    [self.tableView registerNib:[UINib nibWithNibName:@"YYBuyerInfoRemarkCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"YYBuyerInfoRemarkCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"YYOrderStatusCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"YYOrderStatusCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"YYOrderMoneyLogCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"YYOrderMoneyLogCell"];
}

#pragma mark - --------------UIConfig----------------------
-(void)UIConfig{
    [self createNavigationBarView];
    [self createMenuBtn];
    [self createChatBtn];

}
-(void)createNavigationBarView{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    YYNavigationBarViewController *navigationBarViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYNavigationBarViewController"];
    if([NSString isNilOrEmpty:_previousTitle]){
        navigationBarViewController.previousTitle = NSLocalizedString(@"订单列表",nil);
    }else{
        navigationBarViewController.previousTitle = _previousTitle;
    }

    navigationBarViewController.nowTitle = @"";
    _navigationBarViewController = navigationBarViewController;
    [_containerView addSubview:navigationBarViewController.view];
    __weak UIView *_weakContainerView = _containerView;
    [navigationBarViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_weakContainerView.mas_top);
        make.left.equalTo(_weakContainerView.mas_left);
        make.bottom.equalTo(_weakContainerView.mas_bottom);
        make.right.equalTo(_weakContainerView.mas_right);

    }];

    WeakSelf(ws);
    __block YYNavigationBarViewController *blockVc = navigationBarViewController;

    [navigationBarViewController setNavigationButtonClicked:^(NavigationButtonType buttonType){
        if (buttonType == NavigationButtonTypeGoBack) {
            if(ws.cancelButtonClicked){
                ws.cancelButtonClicked();
            }
            [ws.navigationController popViewControllerAnimated:YES];

            blockVc = nil;
        }
    }];
}
-(void)createMenuBtn{
    __weak UIView *_weakContainerView = _containerView;
    _menuBtn = [[UIButton alloc] init];
    [_menuBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 20, 0, 0)];
    [_menuBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_menuBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [_containerView addSubview:_menuBtn];
    [_menuBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_weakContainerView.mas_top);
        make.width.equalTo(@(100));
        make.bottom.equalTo(_weakContainerView.mas_bottom);
        make.right.equalTo(_weakContainerView.mas_right).offset(-45);

    }];
}
-(void)createChatBtn{
    __weak UIView *_weakContainerView = _containerView;
    _shareBtn = [[UIButton alloc] init];
    [_shareBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 20, 0, 0)];
    [_shareBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_shareBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [_shareBtn setTintColor:[UIColor blackColor]];

    [_containerView addSubview:_shareBtn];
    [_shareBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_weakContainerView.mas_top);
        make.width.equalTo(@(120));
        make.bottom.equalTo(_weakContainerView.mas_bottom);
        make.right.equalTo(_weakContainerView.mas_right).offset(-120);

    }];
}
#pragma mark - --------------请求数据----------------------
-(void)RequestData{
    [self refreshOrder];
    if(_currentOrderConnStatus == YYOrderConnStatusUnknow){
        [self updateOrderConnStatus];
    }
}

#pragma mark - --------------系统代理----------------------
#pragma mark -UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [self getSectionsNum];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        if(_currentYYOrderInfoModel.packageStat && [YYNetworkReachability connectedToNetwork]){
            return 4;
        }
        return 3;
    }else if([self getSectionsNum] == (section+1)){
        return 1;
    }else{
        int rows = 0;
        if (_currentYYOrderInfoModel && _currentYYOrderInfoModel.groups && [_currentYYOrderInfoModel.groups count] > 0) {
            YYOrderOneInfoModel *orderOneInfoModel = _currentYYOrderInfoModel.groups[section - 1];
            if (orderOneInfoModel.styles && [orderOneInfoModel.styles count] > 0) {
                if ([orderOneInfoModel isInStock]) {
                    rows = (int)[orderOneInfoModel.styles count] * 2;
                } else {
                    rows = (int)[orderOneInfoModel.styles count];
                }
            }
        }
        return rows;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    WeakSelf(ws);
    if (indexPath.section == 0) {
        NSInteger orderStatus = getOrderTransStatus(self.currentYYOrderTransStatusModel.designerTransStatus, self.currentYYOrderTransStatusModel.buyerTransStatus);
        if(indexPath.row == 0){
            if(self.currentYYOrderTransStatusModel != nil){
                YYOrderStatusCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"YYOrderStatusCell" forIndexPath:indexPath];
                cell.stylesAndTotalPriceModel = self.stylesAndTotalPriceModel;
                cell.currentYYOrderTransStatusModel = self.currentYYOrderTransStatusModel;
                cell.currentYYOrderInfoModel = self.currentYYOrderInfoModel;
                cell.currentOrderConnStatus = self.currentOrderConnStatus;
                cell.statusType = YYOrderStatusTypeOrder;
                cell.delegate = self;
                [cell updateUI];
                return cell;
            }else{
                UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"YYOrderNullCell"];
                if(cell == nil){
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"YYOrderNullCell"];
                }
                return cell;
            }
        }else if(indexPath.row == 1){
            if(self.paymentNoteList != nil && orderStatus >= YYOrderCode_NEGOTIATION){
                YYOrderMoneyLogCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"YYOrderMoneyLogCell" forIndexPath:indexPath];
                cell.delegate = self;
                cell.moneyType = [self.currentYYOrderInfoModel.curType integerValue];
                cell.paymentNoteList = self.paymentNoteList;
                cell.currentYYOrderTransStatusModel = self.currentYYOrderTransStatusModel;
                cell.currentYYOrderInfoModel = self.currentYYOrderInfoModel;
                [cell updateUI];
                return cell;
            }else{
                UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"YYOrderNullCell"];
                if(cell == nil){
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"YYOrderNullCell"];
                }
                return cell;
            }
        }else if(indexPath.row == 2 && _currentYYOrderInfoModel.packageStat && [YYNetworkReachability connectedToNetwork]){
            static NSString *cellid = @"YYOrderPackageInfoCell";
            YYOrderPackageInfoCell *cell = [_tableView dequeueReusableCellWithIdentifier:cellid];
            if(!cell){
                cell = [[YYOrderPackageInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                [cell setCellClickBlock:^{
                    [ws gotoPackageListView];
                }];
            }
            cell.orderPackageStatModel = _currentYYOrderInfoModel.packageStat;
            [cell updateUI];
            return cell;
        }

        YYBuyerInfoCell1 *cell = [self.tableView dequeueReusableCellWithIdentifier:@"YYBuyerInfoCell1" forIndexPath:indexPath];
        cell.currentYYOrderInfoModel = _currentYYOrderInfoModel;
        cell.parentController = self;
        if (orderStatus == 1) {
            cell.isCancel = YES;
        }else{
            cell.isCancel = NO;
        }
        cell.currentOrderConnStatus = _currentOrderConnStatus;
        [cell updataUI];

        [cell setShareOrderButtonClicked:^(){
            [ws showShareOrderView];
        }];
        [cell setReConnStatusButtonClicked:^(NSArray *info){
            ws.currentYYOrderInfoModel.buyerName = [info objectAtIndex:0];
            ws.currentYYOrderInfoModel.buyerEmail = [info objectAtIndex:1];
            ws.currentYYOrderInfoModel.realBuyerId = [info objectAtIndex:2];
            if([[info objectAtIndex:2] integerValue] == 0){
                ws.currentYYOrderInfoModel.orderConnStatus = [[NSNumber alloc] initWithInt:YYOrderConnStatusNotFound];
                ws.currentOrderConnStatus = YYOrderConnStatusNotFound;
            }else{
                ws.currentYYOrderInfoModel.orderConnStatus = [[NSNumber alloc] initWithInt:YYOrderConnStatusUnconfirmed];
                ws.currentOrderConnStatus = YYOrderConnStatusUnconfirmed;
            }
            [ws.tableView reloadData];
        }];

        [cell setBuyerCardButtonClicked:^(UIImage *image){
            if (image) {
                YYShowBuyerCardView *showBuyerCardView = [[YYShowBuyerCardView alloc] init];
                [ws.view addSubview:showBuyerCardView];
                __weak UIView *_weakSelfView = ws.view;
                [showBuyerCardView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(_weakSelfView.mas_top);
                    make.left.equalTo(_weakSelfView.mas_left);
                    make.bottom.equalTo(_weakSelfView.mas_bottom);
                    make.right.equalTo(_weakSelfView.mas_right);

                }];
                addAnimateWhenAddSubview(showBuyerCardView);


                CGSize size = _weakSelfView.frame.size;
                UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
                [showBuyerCardView addSubview:imageView];
                imageView.contentMode =UIViewContentModeScaleAspectFit;
                __weak UIView *_weakShowBuyerCardView = showBuyerCardView;
                [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.width.mas_equalTo(size.width);
                    make.height.mas_equalTo(size.height);
                    make.center.mas_equalTo(_weakShowBuyerCardView);
                }];
            }
        }];
        [cell setBuyerInfoButtonClicked:^(){
            [ws showBuyerInfoView];
        }];

        return cell ;
    }else if([self getSectionsNum] == (indexPath.section + 1)){
        YYBuyerInfoRemarkCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"YYBuyerInfoRemarkCell" forIndexPath:indexPath];
        cell.currentYYOrderInfoModel = _currentYYOrderInfoModel;
        cell.stylesAndTotalPriceModel = _stylesAndTotalPriceModel;
        cell.parentController = self;
        cell.menuData = _menuData;
        [cell updateUI:_currentYYOrderInfoModel.orderDescription];
        return cell;
    }else{
        UITableViewCell *cell = nil;
        YYOrderOneInfoModel *orderOneInfoModel = _currentYYOrderInfoModel.groups[indexPath.section - 1];
        if ([orderOneInfoModel isInStock] && !(indexPath.row&1)) {
            NSString *CellIdentifier = NSStringFromClass([YYOrderDetailSectionHead class]);
            YYOrderDetailSectionHead *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"OrderDetail" bundle:[NSBundle mainBundle]];
                YYCustomCellTableViewController *customCellTableViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYCustomCellTableViewController"];
                cell = [customCellTableViewController.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            }
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
            NSString *CellIdentifier = @"YYStyleDetailCell";
            YYStyleDetailCell *tempCell =  [_tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if(!tempCell){
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"OrderDetail" bundle:[NSBundle mainBundle]];
                YYCustomCellTableViewController *customCellTableViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYCustomCellTableViewController"];
                tempCell = [customCellTableViewController.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            }
            __block  YYStyleDetailCell *blockCell = tempCell;
            [tempCell setDiscountStyleButtonClicked:^(YYOrderStyleModel *orderStyleModel,long seriesId){
                [ws showStyleRemark:orderStyleModel.remark targetView:blockCell];
            }];
            if (_currentYYOrderInfoModel && _currentYYOrderInfoModel.groups && [_currentYYOrderInfoModel.groups count] > 0) {
                if (orderOneInfoModel.styles && [orderOneInfoModel.styles count] > 0) {
                    YYOrderStyleModel *orderStyleModel = [orderOneInfoModel.styles objectAtIndex:[orderOneInfoModel isInStock] ? indexPath.row / 2 : indexPath.row];
                    orderStyleModel.curType = _currentYYOrderInfoModel.curType;
                    tempCell.menuData = _menuData;
                    tempCell.orderStyleModel = orderStyleModel;
                    tempCell.isModifyNow = NO;
                    tempCell.showTotal = YES;
                    tempCell.clickCoverShowDetail = NO;
                    tempCell.showRemarkButton = YES;
                    tempCell.selectTaxType = _selectTaxType;
                    [tempCell updateUI];
                }
            }
            [tempCell setBottomView:YES];
            cell = tempCell;
            return cell;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        NSInteger orderStatus = getOrderTransStatus(self.currentYYOrderTransStatusModel.designerTransStatus, self.currentYYOrderTransStatusModel.buyerTransStatus);
        if(indexPath.row == 0){
            if(self.currentYYOrderTransStatusModel != nil){
                return 107;
            }else{
                return 0.1;
            }
        }else if(indexPath.row == 1){
            if(self.paymentNoteList != nil && orderStatus >= YYOrderCode_NEGOTIATION){
                return [YYOrderMoneyLogCell cellHeight:self.paymentNoteList.result]+2;
            }else{
                return 0.1;
            }
        }else if(indexPath.row == 2 && _currentYYOrderInfoModel.packageStat && [YYNetworkReachability connectedToNetwork]){
            return [YYOrderPackageInfoCell cellHeight];
        }
        YYOrderBuyerAddress *buyerAddress = _currentYYOrderInfoModel.buyerAddress;
        NSString *addressStr = @"";
        if (buyerAddress) {
            addressStr = getBuyerAddressStr_pad(buyerAddress);
        }
        return [YYBuyerInfoCell1 getCellHeight:addressStr];
    }else if([self getSectionsNum] == (indexPath.section + 1)){
        if(needPayTaxView([_currentYYOrderInfoModel.curType integerValue])){
            return 185-35;
        }else{
            return 185-37-35;
        }
    }else{
        NSInteger lines = 0;
        YYOrderOneInfoModel *orderOneInfoModel =  [_currentYYOrderInfoModel.groups objectAtIndex:indexPath.section - 1];
        if ([orderOneInfoModel isInStock] && !(indexPath.row&1)) {
            return 71;
        } else {
            if (orderOneInfoModel && ([orderOneInfoModel isInStock] ? indexPath.row / 2 : indexPath.row) < [orderOneInfoModel.styles count]) {
                YYOrderStyleModel *orderStyleModel = [orderOneInfoModel.styles objectAtIndex:[orderOneInfoModel isInStock] ? indexPath.row / 2 : indexPath.row];
                if (orderStyleModel && orderStyleModel.colors) {
                    
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
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{

    if([self getSectionsNum] == (section + 1)){
        UIView *tmpHead = [[UIView alloc] init];
        tmpHead.backgroundColor = [UIColor lightGrayColor];
        return tmpHead;
    }else if (section != 0) {
        YYOrderOneInfoModel *orderOneInfoModel =  [_currentYYOrderInfoModel.groups objectAtIndex:section- 1];
        if ([orderOneInfoModel isInStock]) {
            return nil;
        } else {
            static NSString *CellIdentifier = @"YYOrderDetailSectionHead";
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"OrderDetail" bundle:[NSBundle mainBundle]];
            YYCustomCellTableViewController *customCellTableViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYCustomCellTableViewController"];
            
            YYOrderDetailSectionHead *sectionHead = [customCellTableViewController.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            sectionHead.orderOneInfoModel = orderOneInfoModel;
            sectionHead.isHiddenSelectDateView = YES;
            [sectionHead updateUI];
            YYSelecteDateView *selecteDateView = (YYSelecteDateView *)[sectionHead viewWithTag:90008];
            sectionHead.contentView.backgroundColor = [UIColor colorWithHex:@"f8f8f8"];
            selecteDateView.backgroundColor = [UIColor colorWithHex:@"f8f8f8"];
            return sectionHead;
        }
    }else {
        return nil;
    }

}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 0;
    }else if([self getSectionsNum] == (section + 1)){
        return 0.1;
    }else{
        YYOrderOneInfoModel *orderOneInfoModel =  [_currentYYOrderInfoModel.groups objectAtIndex:section- 1];
        if ([orderOneInfoModel isInStock]) {
            return 0.1;
        }
        return 71;
    }
}

#pragma mark - --------------自定义代理/block----------------------
#pragma mark -YYTableCellDelegate
-(void)btnClick:(NSInteger)row section:(NSInteger)section andParmas:(NSArray *)parmas{

    NSString *type = [parmas objectAtIndex:0];
    if([type isEqualToString:@"status"]){

        //已生产、已发货
        NSIndexPath *indexPath =  [NSIndexPath indexPathForRow:row inSection:section];
        [self updateTransStatusWithIndexPath:indexPath];

    }else if([type isEqualToString:@"payloglist"]){

        //跳转付款记录页面
        [self showOrderPayLogList];

    }else if([type isEqualToString:@"paylog"]){

        //添加收款记录
        [self addPaylogRecord];

    }else if([type isEqualToString:@"reBuildOrder"]){

        //重新建立订单
        [self reBuildOrder];

    }else if([type isEqualToString:@"cancelReqClose"]){

        //撤销申请
        NSIndexPath *indexPath =  [NSIndexPath indexPathForRow:row inSection:section];
        [self cancelReqCloseWithIndexPath:indexPath];

    }else if([type isEqualToString:@"refuseReqClose"]){

        //我方交易继续
        NSIndexPath *indexPath =  [NSIndexPath indexPathForRow:row inSection:section];
        [self refuseReqCloseWithIndexPath:indexPath];

    }else if([type isEqualToString:@"agreeReqClose"]){

        //同意关闭交易
        NSIndexPath *indexPath =  [NSIndexPath indexPathForRow:row inSection:section];
        [self agreeReqCloseWithIndexPath:indexPath];

    }else if([type isEqualToString:@"confirmOrder"]){

        //确认订单
        NSIndexPath *indexPath =  [NSIndexPath indexPathForRow:row inSection:section];
        [self confirmOrderWithIndexPath:indexPath];

    }else if([type isEqualToString:@"refuseOrder"]){

        //拒绝确认
        NSIndexPath *indexPath =  [NSIndexPath indexPathForRow:row inSection:section];
        [self refuseOrderWithIndexPath:indexPath];

    }else if([type isEqualToString:@"delivery"]){

        //发货
        [self deliverAction];

    }
    else if([type isEqualToString:@"delivery_tip"]){
        //请等待对方签收包裹
        [YYToast showToastWithTitle:NSLocalizedString(@"请等待对方签收包裹", nil) andDuration:kAlertToastDuration];
    }
}

#pragma mark -YYTableCellDelegate-Method
//发货
-(void)deliverAction{
    WeakSelf(ws);
    YYPackingListViewController *createPackingListViewController = [[YYPackingListViewController alloc] init];
    createPackingListViewController.orderCode = _currentOrderCode;
    createPackingListViewController.packageId = _currentYYOrderInfoModel.packageId;
    if(_currentYYOrderInfoModel.packageId){
        createPackingListViewController.packingListType = YYPackingListTypeDetail;
    }else{
        createPackingListViewController.packingListType = YYPackingListTypeCreate;
    }
    [createPackingListViewController setCancelButtonClicked:nil];

    [createPackingListViewController setModifySuccess:^{
        //发货成功啦！然后更新一下
        [ws refreshOrder];
    }];
    [self.navigationController pushViewController:createPackingListViewController animated:YES];
}
//updateTrans 已发货
-(void)updateTransStatusWithIndexPath:(NSIndexPath *)indexPath{
    WeakSelf(ws);
    NSInteger transStatus = getOrderTransStatus(_currentYYOrderTransStatusModel.designerTransStatus, _currentYYOrderTransStatusModel.buyerTransStatus);
    NSInteger nextTransStatus = getOrderNextStatus(transStatus,_currentOrderConnStatus);

    NSString *oprateStr = getOrderStatusBtnName(nextTransStatus,_currentOrderConnStatus);
    NSString *alertStr = getOrderStatusAlertTip(nextTransStatus);
    NSArray *alertInfo = [alertStr componentsSeparatedByString:@"|"];
    NSString *title = [alertInfo objectAtIndex:0];
    NSString *message = (([alertInfo count]> 1)?[alertInfo objectAtIndex:1]:nil);

    if(!message){
        message = title;
        title = nil;
    }
    CMAlertView *alertView = [[CMAlertView alloc] initWithTitle:title message:message needwarn:NO delegate:nil cancelButtonTitle:NSLocalizedString(@"取消", nil) otherButtonTitles:@[[NSString stringWithFormat:@"%@|000000",oprateStr]]];

    alertView.specialParentView = self.view;

    __block NSInteger blockStatus = nextTransStatus;
    [alertView setAlertViewBlock:^(NSInteger selectedIndex){
        if (selectedIndex == 1) {
            NSString *orderCode = ws.currentYYOrderInfoModel.orderCode;
            __block NSString *blockOrderCode = orderCode;
            [YYOrderApi updateTransStatus:blockOrderCode statusCode:nextTransStatus force:NO andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSError *error) {
                if(rspStatusAndMessage.status == YYReqStatusCode100){
                    ws.currentYYOrderTransStatusModel.designerTransStatus = [[NSNumber alloc] initWithInteger:blockStatus];
                    ws.currentYYOrderTransStatusModel.buyerTransStatus = [[NSNumber alloc] initWithInteger:blockStatus];
                    NSTimeInterval time = [[NSDate date] timeIntervalSince1970]*1000;
                    ws.currentYYOrderTransStatusModel.createTime = [NSNumber numberWithLongLong:time];

                    ws.currentYYOrderInfoModel.designerOrderStatus = [[NSNumber alloc] initWithInteger:blockStatus];
                    ws.currentYYOrderInfoModel.buyerOrderStatus = [[NSNumber alloc] initWithInteger:blockStatus];

                    [ws.tableView reloadData];
                    [YYToast showToastWithTitle:rspStatusAndMessage.message andDuration:kAlertToastDuration];
                }
            }];
        }
    }];
    [alertView show];
}
//添加收款记录
-(void)addPaylogRecord{
    WeakSelf(ws);
    if([_paymentNoteList.hasGiveRate floatValue] != 100.f){
        BOOL isNeedRefund = NO;
        if([_paymentNoteList.hasGiveRate floatValue] > 100.f){
            isNeedRefund = YES;
        }

        [[YYYellowPanelManage instance] showOrderAddMoneyLogPanel:@"Order" andIdentifier:@"YYOrderAddMoneyLogController" totalMoney:[_currentYYOrderInfoModel.finalTotalPrice doubleValue] moneyType:[_currentYYOrderInfoModel.curType integerValue] orderCode:_currentYYOrderInfoModel.orderCode isNeedRefund:isNeedRefund parentView:self.view andCallBack:^(NSString *orderCode, NSNumber *totalPercent) {

            [ws loadPaymentNoteList:ws.currentYYOrderInfoModel.orderCode];

        }];
    }
}
//重新建立订单
-(void)reBuildOrder{
    YYOrderInfoModel *orderInfoModel = [[YYOrderInfoModel alloc] initWithDictionary:[_currentYYOrderInfoModel toDictionary] error:nil];
    [YYOrderApi getOrderByOrderCode:orderInfoModel.orderCode isForReBuildOrder:YES andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYOrderInfoModel *orderInfoModel, NSError *error) {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        if (rspStatusAndMessage.status == YYReqStatusCode100) {
            orderInfoModel.orderCode = nil;
            orderInfoModel.billCreatePersonName = nil;
            orderInfoModel.billCreatePersonId = nil;
            orderInfoModel.billCreatePersonType = nil;
            orderInfoModel.occasion = nil;
            orderInfoModel.designerOrderStatus = [[NSNumber alloc] initWithInt:YYOrderCode_NEGOTIATION];
            orderInfoModel.buyerOrderStatus = [[NSNumber alloc] initWithInt:YYOrderCode_NEGOTIATION];
            orderInfoModel.orderConnStatus = @(YYOrderConnStatusUnconfirmed);
            orderInfoModel.orderCreateTime = nil;
            orderInfoModel.addressModifAvailable = YES;
            [appDelegate showBuildOrderViewController:orderInfoModel parent:self isCreatOrder:YES isReBuildOrder:YES isAppendOrder:NO modifySuccess:^(){
                [[NSNotificationCenter defaultCenter] postNotificationName:kShowOrderListNotification object:nil];
            }];
        }else{
            [YYToast showToastWithView:appDelegate.mainViewController.view title:rspStatusAndMessage.message andDuration:kAlertToastDuration];
        }
    }];
}
//撤销申请
-(void)cancelReqCloseWithIndexPath:(NSIndexPath *)indexPath{
    WeakSelf(ws);
    NSString *orderCode = _currentYYOrderInfoModel.orderCode;
    __block NSString *blockOrderCode = orderCode;
    [[YYYellowPanelManage instance] showSamllYellowAlertPanel:@"Main" andIdentifier:@"YYAlertViewController" title:NSLocalizedString(@"是否确认撤销“取消订单”申请？",nil) msg:@"" btn:NSLocalizedString(@"是",nil) align:NSTextAlignmentCenter closeBtn:YES parentView:self.view andCallBack:^(NSArray *value) {
        [YYOrderApi revokeOrderCloseRequest:blockOrderCode andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSError *error) {
            if(rspStatusAndMessage.status == YYReqStatusCode100){
                [ws updateOrderTransStatus];
            }
            [YYToast showToastWithTitle:rspStatusAndMessage.message andDuration:kAlertToastDuration];
        }];
    }];
}
//我方交易继续
-(void)refuseReqCloseWithIndexPath:(NSIndexPath *)indexPath{
    WeakSelf(ws);
    NSString *orderCode = _currentYYOrderInfoModel.orderCode;
    __block NSString *blockOrderCode = orderCode;
    [[YYYellowPanelManage instance] showSamllYellowAlertPanel:@"Main" andIdentifier:@"YYAlertViewController" title:NSLocalizedString(@"确认我方交易继续吗？",nil) msg:@"" btn:NSLocalizedString(@"确认",nil) align:NSTextAlignmentCenter closeBtn:YES parentView:self.view andCallBack:^(NSArray *value) {
        [YYOrderApi dealOrderCloseRequest:blockOrderCode isAgree:@"false" andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSError *error) {
            if(rspStatusAndMessage.status == YYReqStatusCode100){
                ws.currentYYOrderInfoModel.closeReqStatus =[[NSNumber alloc] initWithInt:0];
                [ws updateOrderTransStatus];
            }
            [YYToast showToastWithTitle:rspStatusAndMessage.message andDuration:kAlertToastDuration];
        }];
    }];
}
//同意关闭交易
-(void)agreeReqCloseWithIndexPath:(NSIndexPath *)indexPath{
    WeakSelf(ws);
    NSString *orderCode = _currentYYOrderInfoModel.orderCode;
    __block NSString *blockOrderCode = orderCode;
    [[YYYellowPanelManage instance] showSamllYellowAlertPanel:@"Main" andIdentifier:@"YYAlertViewController" title:NSLocalizedString(@"确认同意已取消申请",nil) msg:@"" btn:NSLocalizedString(@"确认",nil) align:NSTextAlignmentCenter closeBtn:YES parentView:self.view andCallBack:^(NSArray *value) {
        [YYOrderApi dealOrderCloseRequest:blockOrderCode isAgree:@"true" andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSError *error) {
            if(rspStatusAndMessage.status == YYReqStatusCode100){
                ws.currentYYOrderInfoModel.closeReqStatus =[[NSNumber alloc] initWithInt:0];
                [ws updateOrderTransStatus];
            }
            [YYToast showToastWithTitle:rspStatusAndMessage.message andDuration:kAlertToastDuration];
        }];
    }];
}
//确认订单
-(void)confirmOrderWithIndexPath:(NSIndexPath *)indexPath{
    WeakSelf(ws);
    NSString *orderCode = _currentYYOrderInfoModel.orderCode;
    __block NSString *blockOrderCode = orderCode;
    CMAlertView *alertView = [[CMAlertView alloc] initWithTitle:NSLocalizedString(@"确认此订单？", nil) message:NSLocalizedString(@"确认后将无法修改订单，是否确认该订单？",nil) needwarn:NO delegate:nil cancelButtonTitle:NSLocalizedString(@"取消",nil) otherButtonTitles:@[NSLocalizedString(@"确认",nil)]];
    alertView.specialParentView = self.view;
    [alertView setAlertViewBlock:^(NSInteger selectedIndex){
        if (selectedIndex == 1) {
            [YYOrderApi confirmOrderByOrderCode:blockOrderCode andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSError *error) {
                if(rspStatusAndMessage.status == YYReqStatusCode100){
                    [ws updateOrderTransStatus];
                    [YYToast showToastWithTitle:NSLocalizedString(@"订单已确认", nil) andDuration:kAlertToastDuration];
                }else{
                    [YYToast showToastWithTitle:rspStatusAndMessage.message andDuration:kAlertToastDuration];
                }
            }];
        }
    }];
    [alertView show];
}
//拒绝确认订单
-(void)refuseOrderWithIndexPath:(NSIndexPath *)indexPath{
    WeakSelf(ws);
    NSString *orderCode = _currentYYOrderInfoModel.orderCode;
    __block NSString *blockOrderCode = orderCode;
    CMAlertView *alertView = [[CMAlertView alloc] initRefuseOrderReasonWithTitle:NSLocalizedString(@"请填写拒绝原因", nil) message:nil otherButtonTitles:@[NSLocalizedString(@"提交",nil)]];
    alertView.specialParentView = self.view;
    [alertView setAlertViewSubmitBlock:^(NSString *reson) {
        NSLog(@"准备提交");
        [YYOrderApi refuseOrderByOrderCode:blockOrderCode reason:reson andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSError *error) {
            if(rspStatusAndMessage.status == YYReqStatusCode100){
                [ws updateOrderTransStatus];
                [YYToast showToastWithTitle:NSLocalizedString(@"已提交", nil) andDuration:kAlertToastDuration];
            }else{
                [YYToast showToastWithTitle:rspStatusAndMessage.message andDuration:kAlertToastDuration];
            }
        }];
    }];
    [alertView show];
}

#pragma mark - --------------自定义响应----------------------
- (IBAction)appendOrderDetailHandler:(id)sender {
    [self jumpOrderDetailHandler];
}
-(void)showMenuUI:(id)sender{
    if(self.currentYYOrderTransStatusModel){
        NSInteger menuUIWidth = 150;
        NSArray *menuData = nil;
        NSInteger needAppendOrderMenu = 0;
        if([self.currentYYOrderInfoModel.isAppend integerValue] == 0){
            if ([self.currentYYOrderInfoModel.hasAppend integerValue] == 0) {
                if(self.currentOrderConnStatus == YYOrderConnStatusNotFound ||self.currentOrderConnStatus == YYOrderConnStatusUnconfirmed || self.currentOrderConnStatus == YYOrderConnStatusLinked){
                    needAppendOrderMenu = 1;//追单
                }
            }else {
                needAppendOrderMenu = 2;//查看追单
            }
        }
        NSInteger transStatus = getOrderTransStatus(self.currentYYOrderTransStatusModel.designerTransStatus, self.currentYYOrderTransStatusModel.buyerTransStatus);
        if(transStatus == YYOrderCode_CLOSE_REQ || [self.currentYYOrderInfoModel.closeReqStatus integerValue] == -1){
            //关闭请求
            menuData = @[@[@"download_update",NSLocalizedString(@"修改记录",nil),@"10003"]];
        }else if(transStatus == YYOrderCode_NEGOTIATION){
            //已下单
            BOOL isDesignerConfrim = [_currentYYOrderInfoModel isDesignerConfrim];
            BOOL isBuyerConfrim = [_currentYYOrderInfoModel isBuyerConfrim];

            if(!isBuyerConfrim){
                if(!isDesignerConfrim){
                    //双方都未确认
                    menuData = @[@[@"pencil1",NSLocalizedString(@"修改订单_short",nil),@"10001"],@[@"cancel",NSLocalizedString(@"取消订单_short",nil),@"10002"],@[@"download_update",NSLocalizedString(@"修改记录",nil),@"10003"]];
                }else{
                    //买手未确认
                    menuData = @[@[@"download_update",NSLocalizedString(@"修改记录",nil),@"10003"]];
                }
            }else{
                if(!isDesignerConfrim){
                    //设计师未确认
                    menuData = @[@[@"download_update",NSLocalizedString(@"修改记录",nil),@"10003"]];
                }
            }
        }else if(transStatus == YYOrderCode_NEGOTIATION_DONE || transStatus == YYOrderCode_CONTRACT_DONE){
            //已确认
            if(needAppendOrderMenu == 1){
                menuData = @[@[@"append",NSLocalizedString(@"追单补货",nil),@"10005"],@[@"cancel",NSLocalizedString(@"取消订单",nil),@"10004"],@[@"download_update",NSLocalizedString(@"修改记录",nil),@"10003"]];
            }else{
                menuData = @[@[@"cancel",NSLocalizedString(@"取消订单",nil),@"10004"],@[@"download_update",NSLocalizedString(@"修改记录",nil),@"10003"]];
            }
        }else if(transStatus == YYOrderCode_MANUFACTURE){
            //已生产
            if(needAppendOrderMenu == 1){
                menuData = @[@[@"append",NSLocalizedString(@"追单补货",nil),@"10005"],@[@"cancel",NSLocalizedString(@"取消订单",nil),@"10004"],@[@"download_update",NSLocalizedString(@"修改记录",nil),@"10003"]];
            }else{
                menuData = @[@[@"cancel",NSLocalizedString(@"取消订单",nil),@"10004"],@[@"download_update",NSLocalizedString(@"修改记录",nil),@"10003"]];
            }
        }else if(transStatus == YYOrderCode_DELIVERING){
            //发货中
            NSMutableArray *tmpMenuData = [[NSMutableArray alloc] init];
            if(needAppendOrderMenu == 1){
                [tmpMenuData addObjectsFromArray:@[@[@"append",NSLocalizedString(@"追单补货",nil),@"10005"],@[@"download_update",NSLocalizedString(@"修改记录",nil),@"10003"]]];
            }else{
                [tmpMenuData addObjectsFromArray:@[@[@"download_update",NSLocalizedString(@"修改记录",nil),@"10003"]]];
            }

            BOOL canDeliverDone = NO;
            NSInteger receivedPackages = [_currentYYOrderInfoModel.packageStat.receivedPackages integerValue];
            NSInteger totalPackages = [_currentYYOrderInfoModel.packageStat.totalPackages integerValue];

            //①在发货中，包裹有N个   N个状态都为签收。    ②入库数小于订单数。
            if((receivedPackages == totalPackages && totalPackages > 0)
               && (_stylesAndTotalPriceModel.totalCount > [_currentYYOrderInfoModel.packageStat.receivedAmount integerValue])){
                canDeliverDone = YES;
            }

            if(canDeliverDone){
                [tmpMenuData insertObject:@[@"delivery_done",NSLocalizedString(@"完成发货",nil),@"10006"] atIndex:0];
            }

            menuData = [tmpMenuData copy];

        }else if(transStatus == YYOrderCode_DELIVERY){
            //已发货
            if(needAppendOrderMenu == 1){
                menuData = @[@[@"append",NSLocalizedString(@"追单补货",nil),@"10005"],@[@"cancel",NSLocalizedString(@"取消订单",nil),@"10004"],@[@"download_update",NSLocalizedString(@"修改记录",nil),@"10003"]];
            }else{
                menuData = @[@[@"cancel",NSLocalizedString(@"取消订单",nil),@"10004"],@[@"download_update",NSLocalizedString(@"修改记录",nil),@"10003"]];
            }
        }else if(transStatus == YYOrderCode_RECEIVED){
            //已收货
            if(needAppendOrderMenu == 1){
                menuData = @[@[@"append",NSLocalizedString(@"追单补货",nil),@"10005"],@[@"download_update",NSLocalizedString(@"修改记录",nil),@"10003"]];
            }else{
                menuData = @[@[@"download_update",NSLocalizedString(@"修改记录",nil),@"10003"]];
            }
        }else if(transStatus == YYOrderCode_CANCELLED || transStatus == YYOrderCode_CLOSED){
            //已取消
            menuData = @[@[@"download_update",NSLocalizedString(@"修改记录",nil),@"10003"]];
        }

        NSInteger menuUIHeight = 46 * menuData.count;

        UIViewController *controller = [[UIViewController alloc] init];
        controller.view.frame = CGRectMake(0, 0, menuUIWidth, menuUIHeight);
        setMenuUI_pad(self,controller.view,menuData);
        UIPopoverController *popController = [[UIPopoverController alloc] initWithContentViewController:controller];
        _popController = popController;
        CGPoint p = [self.containerView.superview convertPoint:self.menuBtn.center toView:self.containerView.superview];
        CGRect rc = CGRectMake(p.x, p.y+CGRectGetHeight(self.menuBtn.frame)/2, 0, 0);
        popController.popoverContentSize = CGSizeMake(menuUIWidth,menuUIHeight);
        popController.popoverBackgroundViewClass = [YYPopoverBackgroundView class];
        [popController presentPopoverFromRect:rc inView:self.containerView.superview permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    }
}
#pragma mark -menuBtnHandler
- (void)menuBtnHandler:(id)sender{
    UIButton *btn = (UIButton *)sender;
    NSInteger type = btn.tag;
    [_popController dismissPopoverAnimated:NO];
    if(type == kOrderMenuActionType_modifyOrder){
        //修改订单
        [self modifyOrder];
    }else if(type == kOrderMenuActionType_cancelOrder){
        //取消订单
        [self cancelOrder];
    }else if(type == kOrderMenuActionType_modifyRecord){
        //修改记录
        [self modifyRecord];
    }else if(type == kOrderMenuActionType_closeOrder){
        //关闭交易
        [self closeOrder];
    }else if(type == kOrderMenuActionType_appendOrder){
        //追单补货
        [self showOrderAppendView];
    }else if(type == kOrderMenuActionType_deliveringDone){
        //强制完成发货
        [self gotoDeliveringDoneConfirmView];
    }
}
//强制完成发货确认页面
-(void)gotoDeliveringDoneConfirmView{
    WeakSelf(ws);
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"OrderDetail" bundle:[NSBundle mainBundle]];
    YYDeliveringDoneConfirmViewController *deliveringDoneConfirmViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYDeliveringDoneConfirmViewController"];
    deliveringDoneConfirmViewController.currentYYOrderInfoModel = _currentYYOrderInfoModel;
    deliveringDoneConfirmViewController.stylesAndTotalPriceModel = _stylesAndTotalPriceModel;
    deliveringDoneConfirmViewController.nowStylesAndTotalPriceModel = [_currentYYOrderInfoModel getNowTotalValueByOrderInfo];
    [deliveringDoneConfirmViewController updateUI];

    __block YYDeliveringDoneConfirmViewController *blockDeliveringDoneConfirmViewController = deliveringDoneConfirmViewController;

    [deliveringDoneConfirmViewController setCancelButtonClicked:^(){
        removeFromSuperviewUseUseAnimateAndDeallocViewController(blockDeliveringDoneConfirmViewController.view,blockDeliveringDoneConfirmViewController);
    }];

    [deliveringDoneConfirmViewController setModifySuccess:^{
        removeFromSuperviewUseUseAnimateAndDeallocViewController(blockDeliveringDoneConfirmViewController.view,blockDeliveringDoneConfirmViewController);
        [ws refreshOrder];
    }];

    [self.view addSubview:deliveringDoneConfirmViewController.view];

    [deliveringDoneConfirmViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(ws.view);
    }];

    addAnimateWhenAddSubview(deliveringDoneConfirmViewController.view);
}
//删除订单
- (void)deleteOrder{
    WeakSelf(ws);

    if (![YYNetworkReachability connectedToNetwork]) {
        [YYToast showToastWithView:ws.view title:kNetworkIsOfflineTips  andDuration:kAlertToastDuration];
        return;
    }

    CMAlertView *alertView = [[CMAlertView alloc] initWithTitle:NSLocalizedString(@"确认要删除吗？",nil) message:nil needwarn:NO delegate:nil cancelButtonTitle:NSLocalizedString(@"取消",nil) otherButtonTitles:@[[NSString stringWithFormat:@"%@|000000",NSLocalizedString(@"确认",nil)]]];
    alertView.specialParentView = self.view;
    [alertView setAlertViewBlock:^(NSInteger selectedIndex){
        if (selectedIndex == 1) {
            [YYOrderApi updateOrderWithOrderCode:ws.currentYYOrderInfoModel.orderCode opType:3 andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSError *error) {
                if (rspStatusAndMessage.status == YYReqStatusCode100) {
                    [YYToast showToastWithTitle:NSLocalizedString(@"删除订单成功",nil)  andDuration:kAlertToastDuration];
                    [ws.navigationController popViewControllerAnimated:YES];
                }
            }];
        }
    }];

    [alertView show];

}
//取消订单
- (void)cancelOrder{
    WeakSelf(ws);
    if (![YYNetworkReachability connectedToNetwork]) {
        [YYToast showToastWithView:ws.view title:kNetworkIsOfflineTips  andDuration:kAlertToastDuration];
        return;
    }
    CMAlertView *alertView =nil;
    if([_currentYYOrderInfoModel.isAppend integerValue] == 1){

        alertView = [[CMAlertView alloc] initWithTitle:NSLocalizedString(@"取消此订单？",nil) message:NSLocalizedString(@"这是一个追单订单，操作取消订单后，该追单与原始订单解除绑定。",nil) needwarn:NO delegate:nil cancelButtonTitle:NSLocalizedString(@"保留订单",nil) otherButtonTitles:@[NSLocalizedString(@"取消订单_short",nil)]];

    }else{

        alertView = [[CMAlertView alloc] initWithTitle:NSLocalizedString(@"取消此订单？",nil) message:NSLocalizedString(@"订单取消后，可在\"已取消\"的订单中找到该订单",nil) needwarn:NO delegate:nil cancelButtonTitle:NSLocalizedString(@"保留订单",nil) otherButtonTitles:@[NSLocalizedString(@"取消订单_short",nil)]];
    }
    alertView.specialParentView = self.view;
    [alertView setAlertViewBlock:^(NSInteger selectedIndex){
        if (selectedIndex == 1) {

            [YYOrderApi updateOrderWithOrderCode:ws.currentYYOrderInfoModel.orderCode opType:1 andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSError *error) {
                if (rspStatusAndMessage.status == YYReqStatusCode100) {
                    [YYToast showToastWithView:ws.view title:NSLocalizedString(@"取消订单成功",nil)  andDuration:kAlertToastDuration];
                    [ws refreshOrder];
                }
            }];
        }
    }];
    [alertView show];
}
//修改记录
- (void)modifyRecord{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"OrderDetail" bundle:[NSBundle mainBundle]];
    YYOrderModifyLogListController *orderMessageViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYOrderModifyLogListController"];
    orderMessageViewController.currentYYOrderInfoModel = _currentYYOrderInfoModel;
    orderMessageViewController.stylesAndTotalPriceModel = _stylesAndTotalPriceModel;
    orderMessageViewController.currentOrderLogo =_currentOrderLogo;
    [self.navigationController pushViewController:orderMessageViewController animated:YES];
}
//修改订单
- (void)modifyOrder{

    if (![YYNetworkReachability connectedToNetwork]) {
        [YYToast showToastWithView:self.view title:kNetworkIsOfflineTips  andDuration:kAlertToastDuration];
        return;
    }
    YYOrderInfoModel *orderInfoModel = [[YYOrderInfoModel alloc] initWithDictionary:[self.currentYYOrderInfoModel toDictionary] error:nil];
    orderInfoModel.orderConnStatus = [[NSNumber alloc] initWithInteger:_currentOrderConnStatus];//
    WeakSelf(ws);
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate showBuildOrderViewController:orderInfoModel parent:self isCreatOrder:NO isReBuildOrder:NO isAppendOrder:NO modifySuccess:^(){
        [ws refreshOrder];
    }];
}
//追单补货
-(void)showOrderAppendView{
    if(_currentYYOrderInfoModel.orderCode){
        WeakSelf(ws);
        [[YYYellowPanelManage instance] showOrderAppendViewWidthParentView:self.view info:@[_currentYYOrderInfoModel.orderCode] andCallBack:^(NSArray *value) {
            YYOrderAppendParamModel *appendParamModel = [[YYOrderAppendParamModel alloc] initWithDictionary:[ws.currentYYOrderInfoModel toDictionary] error:nil];
            appendParamModel.styleIds = value;
            appendParamModel.originOrderCode = ws.currentYYOrderInfoModel.orderCode ;
            [MBProgressHUD showHUDAddedTo:ws.view animated:YES];
            [YYOrderApi appendOrder:appendParamModel andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSString *orderCode, NSError *error) {
                if(rspStatusAndMessage.status == YYReqStatusCode100 ){
                    __block NSString *blockAppendOrderCode = orderCode;
                    [YYOrderApi getOrderByOrderCode:orderCode isForReBuildOrder:NO andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYOrderInfoModel *orderInfoModel, NSError *error) {
                        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                        if (rspStatusAndMessage.status == YYReqStatusCode100) {
                            [appDelegate showBuildOrderViewController:orderInfoModel parent:self isCreatOrder:NO isReBuildOrder:NO isAppendOrder:YES modifySuccess:^(){
                                //调整到追单详情
                                ws.currentOrderCode = blockAppendOrderCode;
                                [ws updateOrderConnStatus];
                                [ws refreshOrder];
                            }];
                        }else{
                            [YYToast showToastWithView:appDelegate.mainViewController.view title:rspStatusAndMessage.message andDuration:kAlertToastDuration];
                        }
                        [MBProgressHUD hideAllHUDsForView:ws.view animated:YES];
                    }];
                }else{
                    [YYToast showToastWithView:ws.view title:rspStatusAndMessage.message andDuration:kAlertToastDuration];
                }
            }];

        }];
    }
}
#pragma mark - --------------自定义方法----------------------
//去包裹列表
- (void)gotoPackageListView{
    WeakSelf(ws);
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [YYOrderApi getPackagesListByOrderCode:_currentOrderCode andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYPackageListModel *packageListModel, NSError *error) {
        [hud hideAnimated:YES];
        if(rspStatusAndMessage.status == YYReqStatusCode100){
            YYPackageListView *packageListView = [[YYPackageListView alloc] initWithPackageArray:packageListModel.result WithBlock:^(YYPackageModel *packageModel, NSIndexPath *indexPath) {
                YYPackageDetailViewController *packageDetailView = [[YYPackageDetailViewController alloc] init];
                packageDetailView.indexPath = indexPath;
                packageDetailView.packageModel = packageModel;
                packageDetailView.packageName = [[NSString alloc] initWithFormat:NSLocalizedString(@"包裹 %ld",nil),packageListModel.result.count - indexPath.row];
                [packageDetailView setCancelButtonClicked:nil];
                [self.navigationController pushViewController:packageDetailView animated:YES];
            }];
            [self.view addSubview:packageListView];
        }else{
            [YYToast showToastWithView:ws.view title:rspStatusAndMessage.message andDuration:kAlertToastDuration];
        }
    }];
}

-(NSInteger)getSectionsNum{
    int sections = 0;
    if (_currentYYOrderInfoModel
        && _currentYYOrderInfoModel.groups
        && [_currentYYOrderInfoModel.groups count] > 0) {
        sections = (int)[_currentYYOrderInfoModel.groups count];
    }
    return sections + 2;
}
//订单流动状态的网络数据
-(void)updateOrderTransStatus{
    WeakSelf(ws);
    [YYOrderApi getOrderTransStatus:self.currentOrderCode andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYOrderTransStatusModel *transStatusModel, NSError *error) {
        if (rspStatusAndMessage.status == YYReqStatusCode100){

            ws.currentYYOrderTransStatusModel = transStatusModel;

            ws.currentYYOrderInfoModel.designerOrderStatus = transStatusModel.designerTransStatus;
            ws.currentYYOrderInfoModel.buyerOrderStatus = transStatusModel.buyerTransStatus;

            [ws.tableView reloadData];
        }
    }];
}

-(void)updateOrderConnStatus{
    WeakSelf(ws);
    [YYOrderApi getOrderConnStatus:self.currentOrderCode andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYOrderConnStatusModel *statusModel, NSError *error){
        ws.currentOrderConnStatus = [statusModel.status integerValue];
        [ws.tableView reloadData];
    }];
}

- (void)refreshOrder{
    WeakSelf(ws);

    if (self.currentOrderCode) {
        //在线的
        [YYOrderApi getOrderByOrderCode:_currentOrderCode isForReBuildOrder:NO andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYOrderInfoModel *orderInfoModel, NSError *error) {
            if (rspStatusAndMessage.status == YYReqStatusCode100) {
                ws.currentYYOrderInfoModel = orderInfoModel;
                ws.currentYYOrderInfoModel.orderConnStatus = @(ws.currentOrderConnStatus);

                CGFloat taxValue = [ws.currentYYOrderInfoModel.taxRate floatValue]/100.0f;
                updateCustomTaxValue(ws.menuData, [NSNumber numberWithFloat:taxValue],YES);
                ws.selectTaxType = getPayTaxTypeFormServiceNew(ws.menuData, [ws.currentYYOrderInfoModel.taxRate integerValue]);

                ws.currentYYOrderInfoModel.brandLogo = ws.currentOrderLogo;
                ws.stylesAndTotalPriceModel = [orderInfoModel getTotalValueByOrderInfo:NO];
                [ws updateTotalLabel];
                [ws updateBottomViewStatus];

                [ws updateOrderTransStatus];
                [ws.tableView reloadData];

                [self loadPaymentNoteList:self.currentOrderCode];

            }
        }];

    }else if(self.localOrderInfoModel){
        self.currentYYOrderInfoModel = _localOrderInfoModel;
        self.currentYYOrderInfoModel.brandLogo = self.currentOrderLogo;
        self.stylesAndTotalPriceModel = [_localOrderInfoModel getTotalValueByOrderInfo:NO];
        NSInteger orderStatus = getOrderTransStatus(_currentYYOrderTransStatusModel.designerTransStatus, _currentYYOrderTransStatusModel.buyerTransStatus);
        if(orderStatus > 0){
            self.currentYYOrderTransStatusModel = [[YYOrderTransStatusModel alloc] init];
            self.currentYYOrderTransStatusModel.designerTransStatus = [NSNumber numberWithInteger:orderStatus];
            self.currentYYOrderTransStatusModel.buyerTransStatus = [NSNumber numberWithInteger:orderStatus];
        }
        [self updateTotalLabel];
        [self updateBottomViewStatus];
        [self.tableView reloadData];
    }

}


- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
- (void)updateBottomViewStatus{

    NSInteger transStatus = getOrderTransStatus(_currentYYOrderTransStatusModel.designerTransStatus, _currentYYOrderTransStatusModel.buyerTransStatus);

    if (transStatus ==YYOrderCode_CANCELLED || transStatus ==YYOrderCode_CLOSED) {

        [_menuBtn setImage:[UIImage imageNamed:@"delete1"] forState:UIControlStateNormal];
        [_menuBtn setTitle:NSLocalizedString(@"永久删除",nil) forState:UIControlStateNormal];
        [_menuBtn removeTarget:self action:@selector(showMenuUI:) forControlEvents:UIControlEventTouchUpInside];
        [_menuBtn addTarget:self action:@selector(deleteOrder) forControlEvents:UIControlEventTouchUpInside];

    }else{

        [_menuBtn setImage:[UIImage imageNamed:@"download_menu"] forState:UIControlStateNormal];
        [_menuBtn setTitle:NSLocalizedString(@"更多",nil) forState:UIControlStateNormal];
        [_menuBtn removeTarget:self action:@selector(deleteOrder) forControlEvents:UIControlEventTouchUpInside];
        [_menuBtn addTarget:self action:@selector(showMenuUI:) forControlEvents:UIControlEventTouchUpInside];

    }
    float txtWidth = [_menuBtn.currentTitle sizeWithAttributes:@{NSFontAttributeName:_menuBtn.titleLabel.font}].width;
    [_menuBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(txtWidth + 40));
    }];

    if (transStatus == YYOrderCode_CANCELLED) {
        _shareBtn.hidden = YES;
    }else{
        if(transStatus==YYOrderCode_CLOSE_REQ){
            _shareBtn.hidden = YES;
        }else{
            _shareBtn.hidden = NO;
            [_shareBtn setImage:[UIImage imageNamed:@"share_icon1"] forState:UIControlStateNormal];
            [_shareBtn setTitle:NSLocalizedString(@"分享订单",nil) forState:UIControlStateNormal];
            [_shareBtn addTarget:self action:@selector(showShareOrderView) forControlEvents:UIControlEventTouchUpInside];
        }
    }
//    if (orderStatus ==YYOrderCode_CLOSED){
//        _shareBtn.hidden = YES;
//    }
    //是否显示追单按钮
    _viewAppendOrderBtn.hidden = YES;
    if([_currentYYOrderInfoModel.isAppend integerValue] == 0){
        if([_currentYYOrderInfoModel.hasAppend integerValue] == 1){
            _viewAppendOrderBtn.hidden = NO;
            [_viewAppendOrderBtn setTitle:NSLocalizedString(@"查看追单",nil) forState: UIControlStateNormal];

        }
        _navigationBarViewController.nowTitle = @"";
    }else{
        if(_currentYYOrderInfoModel.originalOrderCode !=nil){
            _viewAppendOrderBtn.hidden = NO;
            [_viewAppendOrderBtn setTitle:NSLocalizedString(@"查看原始订单",nil) forState: UIControlStateNormal];
        }
        _navigationBarViewController.nowTitle = NSLocalizedString(@"追单",nil);

    }
    [_navigationBarViewController updateUI];
}


- (void)updateTotalLabel{
    if (_stylesAndTotalPriceModel) {
        _countLabel.text = [NSString stringWithFormat:NSLocalizedString(@"共计%i款 %i件",nil),_stylesAndTotalPriceModel.totalStyles,_stylesAndTotalPriceModel.totalCount];


        _priceTotalDiscountView.backgroundColor = [UIColor clearColor];
        _priceTotalDiscountView.bgColorIsBlack = YES;

        if (!self.currentYYOrderInfoModel.finalTotalPrice
            || [self.currentYYOrderInfoModel.finalTotalPrice floatValue] <= 0) {
            self.currentYYOrderInfoModel.finalTotalPrice = self.stylesAndTotalPriceModel.finalTotalPrice;
        }

        _priceTotalDiscountView.showDiscountValue = NO;
        _priceTotalDiscountView.notShowDiscountValueTextAlignmentLeft = YES;

        NSString *finalValue = replaceMoneyFlag([NSString stringWithFormat:@"￥%.2f",[_currentYYOrderInfoModel.finalTotalPrice doubleValue]],[_currentYYOrderInfoModel.curType integerValue]);
        _priceViewlayoutWidthConstraints.constant = [finalValue sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]}].width;
        [_priceTotalDiscountView updateUIWithOriginPrice:finalValue
                                              fianlPrice:finalValue
                                              originFont:[UIFont systemFontOfSize:17]
                                               finalFont:[UIFont systemFontOfSize:17]];

    }
}

-(void)loadPaymentNoteList:(NSString *)orderCode{
    WeakSelf(ws);
    [YYOrderApi getPaymentNoteList:orderCode finalTotalPrice:[_currentYYOrderInfoModel.finalTotalPrice doubleValue] andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYPaymentNoteListModel *paymentNoteList, NSError *error) {
        if(rspStatusAndMessage.status == YYReqStatusCode100){
            ws.paymentNoteList = paymentNoteList;
        }else{
            ws.paymentNoteList = nil;
        }
        [ws.tableView reloadData];
    }];
}
//关闭交易
-(void)closeOrder{
    WeakSelf(ws);
    __block NSString *blockOrderCode = _currentYYOrderInfoModel.orderCode;
    __block NSInteger blockIsOrderClose = 0;//0代表为未关闭  1代表关闭

    __block BOOL _inRunLoop = true;
    if(_currentOrderConnStatus == YYOrderConnStatusLinked){
        [YYOrderApi getOrderCloseStatus:_currentYYOrderInfoModel.orderCode andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSInteger isclose, NSError *error) {
            blockIsOrderClose = isclose;
            _inRunLoop = false;
        }];
    }else{
        if(_currentOrderConnStatus == YYOrderConnStatusUnconfirmed || _currentOrderConnStatus == YYOrderConnStatusNotFound){
            blockIsOrderClose = 1;
        }
        _inRunLoop = false;
    }
    while (_inRunLoop) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    if (blockIsOrderClose == 0){
        [[YYYellowPanelManage instance] showOrderStatusRequestClosePanelWidthParentView:self.view currentYYOrderInfoModel:_currentYYOrderInfoModel andCallBack:^(NSArray *value) {
            [YYOrderApi setOrderCloseRequest:blockOrderCode andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,  NSError *error) {
                if(rspStatusAndMessage.status == YYReqStatusCode100){
                    [ws refreshOrder];
                }else{
                    [YYToast showToastWithView:ws.view title:rspStatusAndMessage.message andDuration:kAlertToastDuration];
                }

            }];
        }];
    }else{

        [[YYYellowPanelManage instance] showSamllYellowAlertPanel:@"Main" andIdentifier:@"YYAlertViewController" title:NSLocalizedString(@"确认要取消交易吗？",nil) msg:@"" btn:NSLocalizedString(@"确认",nil) align:NSTextAlignmentCenter closeBtn:YES
                                                       parentView:self.view andCallBack:^(NSArray *value) {
                                                           [YYOrderApi closeOrder:ws.currentYYOrderInfoModel.orderCode andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,  NSError *error) {
                                                               if(rspStatusAndMessage.status == YYReqStatusCode100){
                                                                   [ws refreshOrder];
                                                               }else{
                                                                   [YYToast showToastWithView:ws.view title:rspStatusAndMessage.message andDuration:kAlertToastDuration];
                                                               }

                                                           }];
                                                       }];
    }

}

-(void)showOrderPayLogList{

    if(_paymentNoteList && ![NSArray isNilOrEmpty:_paymentNoteList.result]){
        NSMutableArray *infoLogArr = [[NSMutableArray alloc] init];
        for (YYPaymentNoteModel *noteModel in _paymentNoteList.result) {
            [infoLogArr addObject:replaceMoneyFlag([NSString stringWithFormat:NSLocalizedString(@"%@ %@%.2lf%@ ￥%.2f",nil),getShowDateByFormatAndTimeInterval(@"yyyy/MM/dd HH:mm",[noteModel.createTime stringValue]),NSLocalizedString(@"付款",nil),[noteModel.realPercent floatValue],@"%",[noteModel.amount floatValue]],[_currentYYOrderInfoModel.curType integerValue])];
        }
    }

    CGFloat progressValue = [_paymentNoteList.hasGiveRate floatValue];

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Order" bundle:[NSBundle mainBundle]];
    YYOrderPayLogViewController *orderPayLogViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYOrderPayLogViewController"];
    orderPayLogViewController.currentYYOrderInfoModel = _currentYYOrderInfoModel;
    [self.navigationController pushViewController:orderPayLogViewController animated:YES];
    NSInteger tranStatus = getOrderTransStatus(_currentYYOrderTransStatusModel.designerTransStatus, _currentYYOrderTransStatusModel.buyerTransStatus);
    if( tranStatus == 0 || progressValue == 100 || tranStatus == YYOrderCode_NEGOTIATION || tranStatus == YYOrderCode_CANCELLED || tranStatus == YYOrderCode_CLOSED || tranStatus == YYOrderCode_CLOSE_REQ){
        orderPayLogViewController.addEnable = NO;
    }else{
        orderPayLogViewController.addEnable = YES;
    }
    WeakSelf(ws);
    [orderPayLogViewController setCancelButtonClicked:^(){
        [ws.navigationController popViewControllerAnimated:YES];
        [ws.tableView reloadData];
    }];
}

-(void)jumpOrderDetailHandler{
    if([_currentYYOrderInfoModel.isAppend integerValue] == 0){
        if(![NSString isNilOrEmpty:_currentYYOrderInfoModel.appendOrderCode]){
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"OrderDetail" bundle:[NSBundle mainBundle]];
            YYOrderDetailViewController *orderDetailViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYOrderDetailViewController"];
            orderDetailViewController.currentOrderCode = _currentYYOrderInfoModel.appendOrderCode;
            orderDetailViewController.currentOrderLogo =  _currentYYOrderInfoModel.brandLogo;
            orderDetailViewController.currentOrderConnStatus = YYOrderConnStatusUnknow;
            orderDetailViewController.previousTitle = NSLocalizedString(@"返回",nil);
            [self.navigationController pushViewController:orderDetailViewController animated:YES];
        }
    }else{
        if(![NSString isNilOrEmpty:_currentYYOrderInfoModel.originalOrderCode]){
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"OrderDetail" bundle:[NSBundle mainBundle]];
            YYOrderDetailViewController *orderDetailViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYOrderDetailViewController"];
            orderDetailViewController.currentOrderCode = _currentYYOrderInfoModel.originalOrderCode;
            orderDetailViewController.currentOrderLogo =  _currentYYOrderInfoModel.brandLogo;
            orderDetailViewController.currentOrderConnStatus = YYOrderConnStatusUnknow;
            orderDetailViewController.previousTitle = NSLocalizedString(@"返回",nil);
            [self.navigationController pushViewController:orderDetailViewController animated:YES];
        }else{

            [YYToast showToastWithView:self.view title:NSLocalizedString(@"原始订单已被删除",nil) andDuration:kAlertToastDuration];
        }
    }
}
-(void)showStyleRemark:(NSString *)remark targetView:(UIView*)targetView{
    if(remark && remark.length > 0){
        NSInteger menuUIWidth = 285;
        NSInteger menuUIHeight = 138;

        UIViewController *controller = [[UIViewController alloc] init];
        controller.view.frame = CGRectMake(0, 0, menuUIWidth, menuUIHeight);
        controller.view.backgroundColor = [UIColor whiteColor];
        controller.view.layer.borderColor = [UIColor blackColor].CGColor;
        controller.view.layer.borderWidth = 4;
        if(_linkTxtView == nil){
            float space = 22;
            _linkTxtView = [[UITextView alloc] initWithFrame:CGRectMake(space, space, menuUIWidth-space*2, menuUIHeight-space*2)];

            _linkTxtView.textColor = [UIColor colorWithHex:@"919191"];
            _linkTxtView.editable = NO;
            _linkTxtView.font = [UIFont systemFontOfSize:14];
        }
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:remark];
        _linkTxtView.attributedText = attributedString;
        [controller.view addSubview:_linkTxtView];

        UIPopoverController *popController = [[UIPopoverController alloc] initWithContentViewController:controller];
        UIViewController *parent = self;
        self.popController = popController;
        CGPoint p = [targetView convertPoint:CGPointMake(SCREEN_WIDTH -80, 22) toView:parent.view];
        CGRect rc = CGRectMake(p.x, p.y+menuUIHeight/2, 0, 0);
        popController.popoverContentSize = CGSizeMake(menuUIWidth,menuUIHeight);
        popController.popoverBackgroundViewClass = [YYPopoverBackgroundView class];
        [popController presentPopoverFromRect:rc inView:parent.view permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];
    }
}

//显示分享订单的二维码界面
- (void)showShareOrderView{
    WeakSelf(ws);

    UIView *superView = ws.view;

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"OrderDetail" bundle:[NSBundle mainBundle]];
    YYShareOrderViewController *shareOrderViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYShareOrderViewController"];
    self.shareOrderViewController = shareOrderViewController;
    shareOrderViewController.currentYYOrderInfoModel = self.currentYYOrderInfoModel;


    __weak UIView *weakSuperView = superView;
    UIView *showView = shareOrderViewController.view;
    __weak UIView *weakShowView = showView;
    [shareOrderViewController setCancelButtonClicked:^(){
        removeFromSuperviewUseUseAnimateAndDeallocViewController(weakShowView,ws.shareOrderViewController);

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

-(void)showBuyerInfoView{
    if([_currentYYOrderInfoModel.realBuyerId integerValue] > 0){
        WeakSelf(ws);
        [YYUserApi getUserStatus:[_currentYYOrderInfoModel.realBuyerId integerValue] andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSInteger status, NSError *error) {
            if(rspStatusAndMessage.status == YYReqStatusCode100){
                if(status != YYUserStatusStop && status >-1){
                    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Account" bundle:[NSBundle mainBundle]];
                    YYConnBuyerInfoViewController *connInfoController = [storyboard instantiateViewControllerWithIdentifier:@"YYConnBuyerInfoViewController"];
                    connInfoController.buyerId =  [ws.currentYYOrderInfoModel.realBuyerId integerValue];
                    connInfoController.previousTitle = ws.currentYYOrderInfoModel.buyerName;
                    [ws.navigationController pushViewController:connInfoController animated:YES];
                }else{
                    [YYToast showToastWithView:ws.view title:NSLocalizedString(@"此买手店账号已停用",nil) andDuration:kAlertToastDuration];
                }
            }else{
                [YYToast showToastWithView:ws.view title:rspStatusAndMessage.message andDuration:kAlertToastDuration];
            }
        }];
    }


}
#pragma mark - --------------other----------------------

@end

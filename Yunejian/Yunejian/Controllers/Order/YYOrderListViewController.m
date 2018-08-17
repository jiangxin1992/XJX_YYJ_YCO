//
//  YYOrderListViewController.m
//  Yunejian
//
//  Created by Apple on 15/8/17.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import "YYOrderListViewController.h"

// c文件 —> 系统文件（c文件在前）

// 控制器
#import "YYCustomCellTableViewController.h"
#import "YYOrderDetailViewController.h"
#import "YYOrderMessageViewController.h"

// 自定义视图
#import "YYOrderNormalListCell.h"
#import "MBProgressHUD.h"
#import "YYMessageButton.h"
#import "YYPopoverArrowBackgroundView.h"
#import "YYYellowPanelManage.h"
#import "YYNoDataView.h"

// 接口
#import "YYOrderApi.h"

// 分类
#import "UIView+UpdateAutoLayoutConstraints.h"

// 自定义类和三方类（ cocoapods类 > model > 工具类 > 其他）
#import <MJRefresh.h>
#import <AFNetworking/AFNetworkReachabilityManager.h>

#import "YYUser.h"
#import "YYStylesAndTotalPriceModel.h"

#import "AppDelegate.h"
#import "UserDefaultsMacro.h"

#define kOrderPageSize 5

@interface YYOrderListViewController ()<UITableViewDataSource,UITableViewDelegate,YYTableCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIButton *allOrderButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelledButton;
@property (weak, nonatomic) IBOutlet UIView *messageBtnContainer;
@property (weak, nonatomic) IBOutlet UIView *menuBtnContainer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewTopLayoutConstraint;

@property (nonatomic,strong) UIButton *pullDownMenu;
@property (nonatomic,strong) YYMessageButton *messageButton;
@property (nonatomic,strong) YYNoDataView *noDataView;
@property(nonatomic,strong) UIPopoverController *popController;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mssageBtnContainerWidthLayoutConstraint;

@property (nonatomic,strong) YYPageInfoModel *currentPageInfo;
@property (strong, nonatomic) NSMutableArray *orderListArray;

@property(nonatomic,assign) int currentOrderType;//订单类型，0，正常（默认值）；1，已取消 
@property(nonatomic,assign) int currentPayType;//0 1
@property(nonatomic,assign) NSString *curentOrderStatus;// 0 4-9

@property(nonatomic,strong) NSArray *menuBtnsData;

@property(nonatomic,assign) BOOL detailViewBackFlag;//详情页返回
@end

@implementation YYOrderListViewController
#pragma mark - --------------生命周期--------------
- (void)viewDidLoad {
    [super viewDidLoad];
    [self SomePrepare];
    [self UIConfig];
    [self RequestData];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    // 退出埋点
    [MobClick endLogPageView:kYYPageOrderList];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (self.currentPageInfo) {
        if(self.detailViewBackFlag){
            self.detailViewBackFlag = NO;
        }else{
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [self loadOrderListFromServerByPageIndex:1 endRefreshing:NO];
        }
    }

    // 进入埋点
    [MobClick beginLogPageView:kYYPageOrderList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - --------------SomePrepare--------------
#pragma mark - SomePrepare
-(void)SomePrepare
{
    [self PrepareData];
    [self PrepareUI];
}
-(void)PrepareData{
    _currentOrderType = 0;//默认正常的，1是已经取消的
    _currentPayType = -1;
    _curentOrderStatus = @"-1";
    self.orderListArray = [[NSMutableArray alloc] initWithCapacity:0];
    _menuBtnsData = @[@[@"",NSLocalizedString(@"全部",nil),@"1"]
                      ,@[@"",NSLocalizedString(@"已下单",nil),@"2"]
                      ,@[@"",NSLocalizedString(@"已确认",nil),@"3"]
                      ,@[@"",NSLocalizedString(@"已生产",nil),@"4"]
                      ,@[@"",NSLocalizedString(@"已发货",nil),@"5"]
                      ,@[@"",NSLocalizedString(@"已收货",nil),@"6"]
                      ,@[@"",NSLocalizedString(@"部分货款已收",nil),@"7",@""]
                      ,@[@"",NSLocalizedString(@"100%货款已收",nil),@"8"]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageCountChanged:) name:UnreadOrderNotifyMsgAmount object:nil];
    [self reachabilityChanged];
}
-(void)PrepareUI{

    _allOrderButton.enabled = NO;
    [_allOrderButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];

    [_cancelledButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    _cancelledButton.enabled = YES;

    [self addHeader];
    [self addFooter];

}

#pragma mark - --------------UIConfig----------------------
-(void)UIConfig{
    [self createMessageButton];
    [self createPullDownMenu];
    [self createNoDataView];
}
-(void)createMessageButton{
    _messageButton = [[YYMessageButton alloc] init];
    [_messageButton initButton:NSLocalizedString(@"订单消息_short",nil)];
    [self messageCountChanged:nil];
    [_messageBtnContainer addSubview:_messageButton];
    [_messageButton addTarget:self action:@selector(messageButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    __weak UIView *weakContainerView = _messageBtnContainer;
    [_messageButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(weakContainerView.mas_bottom);
        make.left.equalTo(weakContainerView.mas_left);
        make.top.equalTo(weakContainerView.mas_top);
        make.right.equalTo(weakContainerView.mas_right);
    }];
}
-(void)createPullDownMenu{
    _pullDownMenu = [[UIButton alloc] init];
    [_pullDownMenu setImage:[UIImage imageNamed:@"filter_icon"] forState:UIControlStateNormal];
    [_pullDownMenu setTitle:NSLocalizedString(@"筛选", nil) forState:UIControlStateNormal];
    _pullDownMenu.titleLabel.font = [UIFont systemFontOfSize:16];
    [_pullDownMenu setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _pullDownMenu.imageEdgeInsets = UIEdgeInsetsMake(0, -8, 0, 0);
    _pullDownMenu.contentEdgeInsets = UIEdgeInsetsMake(0, 4, 0, 0);
    [_pullDownMenu addTarget:self action:@selector(showMenuUI:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_pullDownMenu];
    __weak UIView *weakMenuContainerView = _menuBtnContainer;
    [_pullDownMenu mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(weakMenuContainerView.mas_bottom);
        make.left.equalTo(weakMenuContainerView.mas_left);
        make.top.equalTo(weakMenuContainerView.mas_top);
        make.right.equalTo(weakMenuContainerView.mas_right);
    }];
}
-(void)createNoDataView{
    self.noDataView = (YYNoDataView*)addNoDataView_pad(self.view,[NSString stringWithFormat:@"%@/n%@|icon:noorder_icon|45",NSLocalizedString(@"还没有订单",nil),NSLocalizedString(@"您可以在作品中，将款式加入到购物车中，建立订单。",nil)],nil,nil);
    _noDataView.hidden = YES;
}
#pragma mark - --------------请求数据----------------------
-(void)RequestData{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self loadOrderListFromServerByPageIndex:1 endRefreshing:NO];
}
- (void)loadOrderListFromServerByPageIndex:(int)pageIndex endRefreshing:(BOOL)endrefreshing{
    [self checkNoticeCount];
    WeakSelf(ws);
    if (![YYNetworkReachability connectedToNetwork]) {
        //如果网络不通的，取本地数据
        NSMutableArray *localArray = [self getLocalOrderList];
        if (localArray
            && [localArray count] > 0) {
            [_orderListArray removeAllObjects];
            [_orderListArray addObjectsFromArray:localArray];
        }
        if (!_orderListArray
            || [_orderListArray count] <= 0) {
            _noDataView.hidden = NO;
        }
        if(endrefreshing){
            [self reloadTableData];
        }else{
            [self.tableView reloadData];
        }

        [MBProgressHUD hideAllHUDsForView:ws.view animated:YES];

        return;
    }


    __block BOOL blockEndrefreshing = endrefreshing;
    NSString *trueCurrentOrderType = _currentOrderType==1?@"10,11":_curentOrderStatus;
    [YYOrderApi getOrderInfoListWithPayType:_currentPayType orderStatus:trueCurrentOrderType
                                  pageIndex:pageIndex
                                   pageSize:kOrderPageSize
                                  andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYOrderListModel *orderListModel, NSError *error){
                                       if (rspStatusAndMessage.status == kCode100) {
                                           if (pageIndex == 1) {
                                               [ws.orderListArray removeAllObjects];
                                           }
                                           ws.currentPageInfo = orderListModel.pageInfo;

                                           if (orderListModel && orderListModel.result
                                               && [orderListModel.result count] > 0){
                                               [ws.orderListArray addObjectsFromArray:orderListModel.result];

                                           }
                                       }
                                       if ([ws.orderListArray count] <= 0) {
                                           ws.noDataView.hidden = NO;
                                       }else{
                                           ws.noDataView.hidden = YES;
                                       }

                                       if(blockEndrefreshing){
                                           [ws reloadTableData];
                                       }else{
                                           [ws.tableView reloadData];
                                       }
                                       [MBProgressHUD hideAllHUDsForView:ws.view animated:YES];
                                   }];
}

#pragma mark - --------------系统代理----------------------
#pragma mark -UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return [_orderListArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = nil;

    static NSString *CellIdentifier = @"YYOrderNormalListCell";
    YYOrderNormalListCell *tempCell =  [_tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(!tempCell){
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"OrderDetail" bundle:[NSBundle mainBundle]];
        YYCustomCellTableViewController *customCellTableViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYCustomCellTableViewController"];
        tempCell = [customCellTableViewController.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    }
    YYOrderListItemModel *orderListItemModel = nil;
    NSObject *obj = [_orderListArray objectAtIndex:indexPath.row];
    if ([obj isKindOfClass:[YYOrderListItemModel class]]) {
        orderListItemModel = (YYOrderListItemModel *)obj;
        orderListItemModel.designerTransStatus = orderListItemModel.designerTransStatus;
        orderListItemModel.buyerTransStatus = orderListItemModel.buyerTransStatus;
    }else if([obj isKindOfClass:[YYOrderInfoModel class]]){
        YYOrderInfoModel *orderInfoModel = (YYOrderInfoModel *)obj;
        orderListItemModel = [[YYOrderListItemModel alloc] init];
        orderListItemModel.finalTotalPrice = orderInfoModel.finalTotalPrice;

        YYStylesAndTotalPriceModel *stylesAndTotalPriceModel = [orderInfoModel getTotalValueByOrderInfo:NO];
        if (stylesAndTotalPriceModel) {
            orderListItemModel.itemAmount = [NSNumber numberWithInt:stylesAndTotalPriceModel.totalCount];
            orderListItemModel.styleAmount = [NSNumber numberWithInt:stylesAndTotalPriceModel.totalStyles];
        }
        orderListItemModel.orderCode = orderInfoModel.shareCode;
        orderListItemModel.buyerName = orderInfoModel.buyerName;
        orderListItemModel.designerTransStatus = [NSNumber numberWithInt:kOrderCode_NEGOTIATION];//
        orderListItemModel.buyerTransStatus = [NSNumber numberWithInt:kOrderCode_NEGOTIATION];//
        orderListItemModel.orderCreateTime = orderInfoModel.orderCreateTime;
    }
    tempCell.currentOrderListItemModel = orderListItemModel;
    [tempCell updateUI];
    tempCell.delegate = self;
    tempCell.indexPath = indexPath;
    cell = tempCell;
    return cell;
}
#pragma mark -UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSObject *obj = [_orderListArray objectAtIndex:indexPath.row];

    if ([obj isKindOfClass:[YYOrderListItemModel class]]) {
        YYOrderListItemModel *orderListItemModel = (YYOrderListItemModel *)obj;
        NSInteger tranStatus = getOrderTransStatus(orderListItemModel.designerTransStatus, orderListItemModel.buyerTransStatus);
        if (orderListItemModel
            && orderListItemModel.supplyTime
            && [orderListItemModel.supplyTime count] > 1
            && tranStatus != kOrderCode_CANCELLED && tranStatus != kOrderCode_CLOSED && tranStatus != kOrderCode_CLOSE_REQ && tranStatus != kOrderCode_DELIVERY && tranStatus != kOrderCode_RECEIVED && [orderListItemModel.closeReqStatus integerValue] != -1) {

            CGFloat height = 85.0f +[orderListItemModel.supplyTime count] * 50.0f;

            return height;
        }
    }
    return 150.0f;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self showDetailOrderVIew:indexPath];
}

#pragma mark - --------------自定义代理/block----------------------
#pragma mark -YYTableCellDelegate
-(void)btnClick:(NSInteger)row section:(NSInteger)section andParmas:(NSArray *)parmas{
    NSString *type = [parmas objectAtIndex:0];


    NSObject *obj = [_orderListArray objectAtIndex:row];
    if ([obj isKindOfClass:[YYOrderListItemModel class]]) {
        YYOrderListItemModel *orderListItemModel = (YYOrderListItemModel *)obj;

        if([type isEqualToString:@"paylog"]){

            //添加收款记录
            NSIndexPath *indexPath =  [NSIndexPath indexPathForRow:row inSection:section];
            [self addPaylogRecordWithListItemModel:orderListItemModel indexPath:indexPath];

        }else if([type isEqualToString:@"status"]){

            //已发货|已收货
            NSIndexPath *indexPath =  [NSIndexPath indexPathForRow:row inSection:section];
            [self updateTransStatusWithListItemModel:orderListItemModel indexPath:indexPath];

        }else if([type isEqualToString:@"delete"]){

            //删除订单
            [self deleteOrderWithListItemModel:orderListItemModel];

        }else if([type isEqualToString:@"reBuildOrder"]){

            //重新建立订单
            [self reBuildOrderWithListItemModel:orderListItemModel];

        }else if([type isEqualToString:@"orderInfo"]){

            //订单详情进入
            NSIndexPath *indexPath =  [NSIndexPath indexPathForRow:row inSection:section];
            [self showDetailOrderVIew:indexPath];

        }else if([type isEqualToString:@"refuseOrder"]){

            //拒绝确认
            NSIndexPath *indexPath =  [NSIndexPath indexPathForRow:row inSection:section];
            [self refuseOrderWithListItemModel:orderListItemModel indexPath:indexPath];

        }else if([type isEqualToString:@"confirmOrder"]){

            //确认订单
            NSIndexPath *indexPath =  [NSIndexPath indexPathForRow:row inSection:section];
            [self confirmOrderWithListItemModel:orderListItemModel indexPath:indexPath];

        }
    }else if([obj isKindOfClass:[YYOrderInfoModel class]]){
        [YYToast showToastWithTitle:kNetworkIsOfflineTips andDuration:kAlertToastDuration];
    }
}
#pragma mark -YYTableCellDelegate-Method
//添加收款记录
-(void)addPaylogRecordWithListItemModel:(YYOrderListItemModel *)orderListItemModel indexPath:(NSIndexPath *)indexPath{

    WeakSelf(ws);
    __block NSString *blockOrderCode = orderListItemModel.orderCode;
    [[YYYellowPanelManage instance] showOrderAddMoneyLogPanel:@"Order" andIdentifier:@"YYOrderAddMoneyLogController" totalMoney:[orderListItemModel.finalTotalPrice doubleValue] moneyType:[orderListItemModel.curType integerValue] orderCode:blockOrderCode parentView:nil andCallBack:^(NSString *orderCode, NSNumber *totalPercent) {

        orderListItemModel.payNote = totalPercent;
        [ws.tableView reloadData];

    }];
}
//已发货|已收货
-(void)updateTransStatusWithListItemModel:(YYOrderListItemModel *)orderListItemModel indexPath:(NSIndexPath *)indexPath{

    WeakSelf(ws);

    NSInteger transStatus = getOrderTransStatus(orderListItemModel.designerTransStatus, orderListItemModel.buyerTransStatus);
    NSInteger nextTransStatus = getOrderNextStatus(transStatus);

    NSString *oprateStr = getOrderStatusBtnName_pad(nextTransStatus);
    NSString *alertStr = getOrderStatusAlertTip(nextTransStatus);
    NSArray *alertInfo = [alertStr componentsSeparatedByString:@"|"];
    NSString *title = [alertInfo objectAtIndex:0];
    NSString *message = (([alertInfo count]> 1)?[alertInfo objectAtIndex:1]:nil);
    __block NSInteger blockStatus = nextTransStatus;

    if(!message){
        message = title;
        title = nil;
    }
    CMAlertView *alertView = [[CMAlertView alloc] initWithTitle:title message:message needwarn:NO delegate:nil cancelButtonTitle:NSLocalizedString(@"取消", nil) otherButtonTitles:@[[NSString stringWithFormat:@"%@|000000",oprateStr]]];
    [alertView setAlertViewBlock:^(NSInteger selectedIndex){
        if (selectedIndex == 1) {
            [YYOrderApi updateTransStatus:orderListItemModel.orderCode statusCode:nextTransStatus andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSError *error) {
                if(rspStatusAndMessage.status == kCode100){
                    orderListItemModel.designerTransStatus = [[NSNumber alloc] initWithInteger:blockStatus];
                    orderListItemModel.buyerTransStatus = [[NSNumber alloc] initWithInteger:blockStatus];
                    [ws.tableView reloadData];
                }
            }];
        }
    }];
    [alertView show];
}
//删除订单
-(void)deleteOrderWithListItemModel:(YYOrderListItemModel *)orderListItemModel{

    CMAlertView *alertView = [[CMAlertView alloc] initWithTitle:NSLocalizedString(@"确认要删除吗？",nil) message:nil needwarn:NO delegate:nil cancelButtonTitle:NSLocalizedString(@"取消",nil) otherButtonTitles:@[[NSString stringWithFormat:@"%@|000000",NSLocalizedString(@"确认",nil)]]];
    [alertView setAlertViewBlock:^(NSInteger selectedIndex){
        if (selectedIndex == 1) {
            [YYOrderApi updateOrderWithOrderCode:orderListItemModel.orderCode opType:3 andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSError *error) {
                if (rspStatusAndMessage.status == kCode100) {
                    [YYToast showToastWithTitle:NSLocalizedString(@"删除订单成功",nil)  andDuration:kAlertToastDuration];
                    [self loadOrderListFromServerByPageIndex:1 endRefreshing:NO];
                }
            }];
        }
    }];

    [alertView show];
}
//拒绝确认订单
-(void)refuseOrderWithListItemModel:(YYOrderListItemModel *)orderListItemModel indexPath:(NSIndexPath *)indexPath{

    WeakSelf(ws);

    CMAlertView *alertView = [[CMAlertView alloc] initRefuseOrderReasonWithTitle:NSLocalizedString(@"请填写拒绝原因", nil) message:nil otherButtonTitles:@[NSLocalizedString(@"提交",nil)]];
    [alertView setAlertViewSubmitBlock:^(NSString *reson) {
        NSLog(@"准备提交");
        [YYOrderApi refuseOrderByOrderCode:orderListItemModel.orderCode reason:reson andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSError *error) {
            if(rspStatusAndMessage.status == kCode100){
                [ws loadOrderListItem:indexPath];
                [YYToast showToastWithTitle:NSLocalizedString(@"已提交", nil) andDuration:kAlertToastDuration];
            }
        }];
    }];

    [alertView show];
}
//重新建立订单
-(void)reBuildOrderWithListItemModel:(YYOrderListItemModel *)orderListItemModel{
    [YYOrderApi getOrderByOrderCode:orderListItemModel.orderCode isForReBuildOrder:YES andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYOrderInfoModel *orderInfoModel, NSError *error) {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        if (rspStatusAndMessage.status == kCode100) {
            orderInfoModel.orderCode = nil;
            orderInfoModel.billCreatePersonName = nil;
            orderInfoModel.billCreatePersonId = nil;
            orderInfoModel.billCreatePersonType = nil;
            orderInfoModel.occasion = nil;
            orderInfoModel.designerOrderStatus = [[NSNumber alloc] initWithInt:kOrderCode_NEGOTIATION];
            orderInfoModel.buyerOrderStatus = [[NSNumber alloc] initWithInt:kOrderCode_NEGOTIATION];
            orderInfoModel.orderConnStatus = kOrderStatus0;
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

//确认订单
-(void)confirmOrderWithListItemModel:(YYOrderListItemModel *)orderListItemModel indexPath:(NSIndexPath *)indexPath{
    NSLog(@"confirmOrder");
    WeakSelf(ws);
    CMAlertView *alertView = [[CMAlertView alloc] initWithTitle:NSLocalizedString(@"确认此订单？", nil) message:NSLocalizedString(@"确认后将无法修改订单，是否确认该订单？",nil) needwarn:NO delegate:nil cancelButtonTitle:NSLocalizedString(@"取消",nil) otherButtonTitles:@[NSLocalizedString(@"确认",nil)]];
    [alertView setAlertViewBlock:^(NSInteger selectedIndex){
        if (selectedIndex == 1) {
            [YYOrderApi confirmOrderByOrderCode:orderListItemModel.orderCode andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSError *error) {
                if(rspStatusAndMessage.status == kCode100){
                    [ws loadOrderListItem:indexPath];
                    [YYToast showToastWithTitle:NSLocalizedString(@"订单已确认", nil) andDuration:kAlertToastDuration];
                }
            }];
        }
    }];
    [alertView show];
}
//订单详情进入
- (void)showDetailOrderVIew:(NSIndexPath *)indexPath{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"OrderDetail" bundle:[NSBundle mainBundle]];
    YYOrderDetailViewController *orderDetailViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYOrderDetailViewController"];
    NSObject *obj = [_orderListArray objectAtIndex:indexPath.row];
    if ([obj isKindOfClass:[YYOrderListItemModel class]]) {
        YYOrderListItemModel *orderListItemModel = (YYOrderListItemModel *)obj;
        NSString *orderCode = orderListItemModel.orderCode;
        orderDetailViewController.currentOrderCode = orderCode;
        orderDetailViewController.currentOrderLogo = orderListItemModel.brandLogo;
        orderDetailViewController.currentOrderConnStatus = [orderListItemModel.connectStatus integerValue];
        WeakSelf(ws);
        __block YYOrderListItemModel *blockorderListItemModel = (YYOrderListItemModel *)obj;
        __block NSIndexPath *blockindexPath = indexPath;
        [orderDetailViewController setCancelButtonClicked:^(){
            ws.detailViewBackFlag = YES;
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [YYOrderApi getOrderInfoListItemWithOrderCode:blockorderListItemModel.orderCode andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYOrderListItemModel *orderListItemModel, NSError *error) {
                [MBProgressHUD hideAllHUDsForView:ws.view animated:YES];
                if(rspStatusAndMessage.status == kCode100 && [blockorderListItemModel.orderCode isEqualToString:orderListItemModel.orderCode]){
                    [ws.orderListArray replaceObjectAtIndex:blockindexPath.row withObject:orderListItemModel];
                    [ws reloadTableData];
                }
            }];
        }];
    }else if([obj isKindOfClass:[YYOrderInfoModel class]]){
        YYOrderInfoModel *orderInfoModel = (YYOrderInfoModel *)obj;
        orderDetailViewController.localOrderInfoModel = orderInfoModel;
        orderDetailViewController.currentOrderLogo = orderInfoModel.brandLogo;
        orderDetailViewController.currentOrderConnStatus = kOrderStatus0;
    }
    [self.navigationController pushViewController:orderDetailViewController animated:YES];
}
#pragma mark - --------------自定义响应----------------------
- (IBAction)allOrderButtonClicked:(id)sender{
    if (_currentOrderType != 0) {
        _pullDownMenu.hidden = NO;
        _allOrderButton.enabled = NO;
        [_allOrderButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];

        _currentOrderType = 0;
        self.noDataView.titleLabel.text = NSLocalizedString(@"还没有订单",nil);
        self.noDataView.tipLabel.text = NSLocalizedString(@"您可以在作品中，将款式加入到购物车中，建立订单。",nil);
        [_cancelledButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        _cancelledButton.enabled = YES;
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        _curentOrderStatus = @"-1";
        [_pullDownMenu setTitle:NSLocalizedString(@"筛选", nil) forState:UIControlStateNormal];
        [self loadOrderListFromServerByPageIndex:1 endRefreshing:NO];
    }
}

- (IBAction)cancelOrderButtonClicked:(id)sender{
    if (_currentOrderType != 1) {
        _pullDownMenu.hidden = YES;
        _cancelledButton.enabled = NO;
        [_cancelledButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];

        _currentOrderType = 1;
        self.noDataView.titleLabel.text = NSLocalizedString(@"暂无取消订单",nil);
        self.noDataView.tipLabel.text = @"";
        [_allOrderButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        _allOrderButton.enabled = YES;
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        _curentOrderStatus = @"-1";
        _currentPayType = -1;
        [self loadOrderListFromServerByPageIndex:1 endRefreshing:NO];
        self.currentPageInfo = nil;
        self.orderListArray = [[NSMutableArray alloc] init];
        [self.tableView reloadData];
    }
}
- (void)messageButtonClicked:(id)sender {

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"OrderDetail" bundle:[NSBundle mainBundle]];
    YYOrderMessageViewController *orderMessageViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYOrderMessageViewController"];
    [orderMessageViewController setMarkAsReadHandler:^(void){
        [YYOrderMessageViewController markAsRead];
    }];
    [self.navigationController pushViewController:orderMessageViewController animated:YES];
}

- (void)messageCountChanged:(NSNotification *)notification{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if(appDelegate.unreadOrderNotifyMsgAmount > 0){
        _mssageBtnContainerWidthLayoutConstraint.constant = 100+22;
        [_messageButton updateButtonNumber:[NSString stringWithFormat:@"%ld",(long)appDelegate.unreadOrderNotifyMsgAmount]];
    }else{
        _mssageBtnContainerWidthLayoutConstraint.constant = 100;
        [_messageButton updateButtonNumber:@""];
    }
}
-(void)showMenuUI:(id)sender{
    NSInteger menuUIWidth = 150;
    NSInteger menuUIHeight = 400;
    UIViewController *controller = [[UIViewController alloc] init];
    controller.view.frame = CGRectMake(0, 0, menuUIWidth, menuUIHeight);

    setMenuUI_pad(self,controller.view,_menuBtnsData);
    UIPopoverController *popController = [[UIPopoverController alloc] initWithContentViewController:controller];
    _popController = popController;

    UIViewController *parent = [UIApplication sharedApplication].keyWindow.rootViewController;

    CGPoint p = [_pullDownMenu convertPoint:CGPointMake(0, 30) toView:parent.view];
    CGRect rc = CGRectMake(p.x+menuUIWidth/2, p.y, 0, 0);
    popController.popoverContentSize = CGSizeMake(menuUIWidth,menuUIHeight);
    popController.popoverBackgroundViewClass = [YYPopoverArrowBackgroundView class];
    [popController presentPopoverFromRect:rc inView:parent.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

-(void)menuBtnHandler:(id)sender{
    UIButton *btn = (UIButton *)sender;
    NSInteger type = btn.tag;
    [_popController dismissPopoverAnimated:NO];

    _curentOrderStatus = @"-1";
    _currentPayType = -1;
    if(type == 1){//
        _curentOrderStatus = @"-1";
    }else if(type == 2){
        _curentOrderStatus = @"4";
    }else if(type == 3){
        _curentOrderStatus = @"5,6";
    }else if(type == 4){
        _curentOrderStatus = @"7";
    }else if(type == 5){
        _curentOrderStatus = @"8";
    }else if(type == 6){
        _curentOrderStatus = @"9";
    }else if(type == 7){
        _currentPayType = 0;
    }else if(type == 8){
        _currentPayType = 1;
    }

    NSArray *btnInfo =  [_menuBtnsData objectAtIndex:(type-1)];
    NSString *btnTxt = ((type == 1)?NSLocalizedString(@"筛选", nil):[btnInfo objectAtIndex:1]);
    [_pullDownMenu setTitle:btnTxt forState:UIControlStateNormal];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self loadOrderListFromServerByPageIndex:1 endRefreshing:NO];
}

#pragma mark - --------------自定义方法----------------------
-(void)loadOrderListItem:(NSIndexPath *)index{
    NSInteger row=index.row;
    __block YYOrderListItemModel *blockorderListItemModel = [_orderListArray objectAtIndex:row];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    WeakSelf(ws);
    [YYOrderApi getOrderInfoListItemWithOrderCode:blockorderListItemModel.orderCode andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYOrderListItemModel *orderListItemModel, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:ws.view animated:YES];
        if(rspStatusAndMessage.status == kCode100 && [blockorderListItemModel.orderCode isEqualToString:orderListItemModel.orderCode]){
            [ws.orderListArray replaceObjectAtIndex:row withObject:orderListItemModel];
            [ws reloadTableData];
        }
    }];
}
- (void)reachabilityChanged
{
    int original_tableviewTop_offset = 107;

    if (![YYNetworkReachability connectedToNetwork]) {
        self.tableViewTopLayoutConstraint.constant = original_tableviewTop_offset+45;
    }else{
        self.tableViewTopLayoutConstraint.constant = original_tableviewTop_offset;
    }
}
-(void)checkNoticeCount{
    YYUser *user = [YYUser currentUser];
    if (![YYNetworkReachability connectedToNetwork] || !user.email) {
        return;
    }
    NSString *type = @"";
    [YYOrderApi getUnreadNotifyMsgAmount:type andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSInteger orderMsgCount,NSInteger connMsgCount, NSError *error) {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        appDelegate.unreadOrderNotifyMsgAmount = orderMsgCount;
        appDelegate.unreadConnNotifyMsgAmount = connMsgCount;
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:UnreadConnNotifyMsgAmount object:nil userInfo:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:UnreadOrderNotifyMsgAmount object:nil userInfo:nil];
        });
    }];
}
- (NSMutableArray *)getLocalOrderList{

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *tempDic = [userDefaults persistentDomainForName:kOfflineOrderDictionaryKey];
    NSMutableArray *localOrderArray = [[NSMutableArray alloc] initWithCapacity:0];
    if (tempDic
        && [tempDic count] > 0) {

        NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:tempDic];


        for (int i= 0; i < [dic count]; i++) {
            NSString *nowKey = [[dic allKeys] objectAtIndex:i];

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
                    YYOrderInfoModel *orderInfoModel = [[YYOrderInfoModel alloc] initWithDictionary:json error:nil];
                    if (orderInfoModel) {
                        if([orderInfoModel.brandID isEqualToString:[YYUser getBrandID]]){
                            [localOrderArray addObject:orderInfoModel];
                        }
                    }
                }
            }
        }
    }

    return localOrderArray;
}

-(void)reloadTableData{
    [self.tableView reloadData];
    [self.tableView.mj_header endRefreshing];
    [self.tableView.mj_footer endRefreshing];
}
- (void)addHeader{
    WeakSelf(ws);
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        //[self.tableView.mj_header endRefreshing];
        [ws loadOrderListFromServerByPageIndex:1 endRefreshing:YES];
    }];
    self.tableView.mj_header = header;
    self.tableView.mj_header.automaticallyChangeAlpha = YES;
    header.lastUpdatedTimeLabel.hidden = YES;
}

- (void)addFooter{
    WeakSelf(ws);
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        if (!ws.currentPageInfo.isLastPage) {
            [ws loadOrderListFromServerByPageIndex:[ws.currentPageInfo.pageIndex intValue]+1 endRefreshing:YES];
        }else{
            //弹出提示
            [ws.tableView.mj_footer endRefreshing];
        }
    }];
}



#pragma mark - --------------other----------------------

@end

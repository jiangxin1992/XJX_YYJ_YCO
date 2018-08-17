//
//  YYDeliverViewController.m
//  yunejianDesigner
//
//  Created by yyj on 2018/6/19.
//  Copyright © 2018年 Apple. All rights reserved.
//

#import "YYDeliverViewController.h"

// c文件 —> 系统文件（c文件在前）

// 控制器
#import "YYNavigationBarViewController.h"
#import "YYDeliverModifyAddressViewController.h"

// 自定义视图
#import "MBProgressHUD.h"
#import "YYDeliverCustomCell.h"
#import "YYDeliverSubmitCell.h"
#import "YYChooseWarehouseView.h"
#import "YYChooseLogisticsView.h"

// 接口
#import "YYOrderApi.h"

// 分类

// 自定义类和三方类（ cocoapods类 > model > 工具类 > 其他）
#import "YYQRCode.h"

#import "YYDeliverModel.h"
#import "YYWarehouseModel.h"
#import "YYWarehouseListModel.h"
#import "YYExpressCompanyModel.h"
#import "YYPackingListDetailModel.h"

#import "regular.h"
#import "YYVerifyTool.h"

@interface YYDeliverViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) YYNavigationBarViewController *navigationBarViewController;
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSNumber *buyerStockEnabled;//此单的买手店库存是否已经开通 bool

@property (nonatomic, strong) YYDeliverModel *deliverModel;

@end

@implementation YYDeliverViewController

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
    [MobClick beginLogPageView:kYYPageDeliver];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    // 退出埋点
    [MobClick endLogPageView:kYYPageDeliver];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
#pragma mark - --------------SomePrepare--------------
- (void)SomePrepare {
    [self PrepareData];
    [self PrepareUI];
}
- (void)PrepareData {
    _deliverModel = [[YYDeliverModel alloc] initWithPackingListDetailModel:_packingListDetailModel];//_deliverModel初始化
    _buyerStockEnabled = _packingListDetailModel.buyerStockEnabled;
}
- (void)PrepareUI {
    self.view.backgroundColor = _define_black_color;

    _containerView = [UIView getCustomViewWithColor:nil];
    [self.view addSubview:_containerView];
    [_containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(50);
        make.top.mas_equalTo(self.mas_topLayoutGuideBottom).with.offset(0);
    }];

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    YYNavigationBarViewController *navigationBarViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYNavigationBarViewController"];
    navigationBarViewController.previousTitle = @"";
    navigationBarViewController.nowTitle = @"发货";
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

#pragma mark - --------------UIConfig----------------------
- (void)UIConfig {
    [self createTableView];
}
-(void)createTableView{
    WeakSelf(ws);
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    [self.view addSubview:_tableView];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.scrollEnabled = NO;
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(ws.containerView.mas_bottom).with.offset(0);
        make.left.right.bottom.mas_equalTo(0);
    }];
}

#pragma mark - --------------请求数据----------------------
- (void)RequestData {

}

#pragma mark - --------------系统代理----------------------
#pragma mark - TableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 10;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0){
        BOOL isValidAddress = [_deliverModel isValidAddressWithBuyerStockEnabled:[_buyerStockEnabled boolValue]];
        if(isValidAddress){
            return UITableViewAutomaticDimension;
        }
    }
    if(indexPath.row == 3){
        return 85;
    }
    return 75;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WeakSelf(ws);

    if(indexPath.row == 3){
        static NSString *cellid = @"YYDeliverSubmitCell";
        YYDeliverSubmitCell *cell = [_tableView dequeueReusableCellWithIdentifier:cellid];
        if(!cell){
            cell = [[YYDeliverSubmitCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid WithBlock:^(NSString *type) {
                if([type isEqualToString:@"submit"]){
                    [ws submitAction];
                }
            }];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.deliverModel = _deliverModel;
        cell.buyerStockEnabled = _buyerStockEnabled;
        [cell updateUI];
        return cell;
    }

    static NSString *cellid = @"YYDeliverCustomCell";
    YYDeliverCustomCell *cell = [_tableView dequeueReusableCellWithIdentifier:cellid];
    if(!cell){
        cell = [[YYDeliverCustomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid WithBlock:^(NSString *type, NSString *value) {
            if([type isEqualToString:@"scan"]){
                [ws sweepYardButtonClicked];
            }else if([type isEqualToString:@"logisticsCode"]){
                ws.deliverModel.logisticsCode = value;
                [ws updateUI];
            }else if([type isEqualToString:@"chooseReceiverAddress"]){
                //编辑收件地址/选择仓库地址
                [ws chooseReceiverAddress];
            }else if([type isEqualToString:@"chooseLogistics"]){
                //选择物流公司
                [ws chooseLogistics];
            }
        }];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.deliverModel = _deliverModel;
    cell.buyerStockEnabled = _buyerStockEnabled;
    if(indexPath.row == 0){
        cell.deliverCellType = YYDeliverCellTypeReceiverAddress;
    }else if(indexPath.row == 1){
        cell.deliverCellType = YYDeliverCellTypeLogisticsName;
    }else if(indexPath.row == 2){
        cell.deliverCellType = YYDeliverCellTypeLogisticsCode;
    }
    [cell updateUI];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [regular dismissKeyborad];
}
#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [regular dismissKeyborad];
}

#pragma mark - --------------自定义代理/block----------------------

#pragma mark - --------------自定义响应----------------------
//submit
-(void)submitAction{
    //确认发货
    NSData *jsonData = [[_deliverModel toDictionary] mj_JSONData];

    WeakSelf(ws);
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [YYOrderApi saveDeliverPackageByJsonData:jsonData andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSError *error) {
        if(rspStatusAndMessage.status == YYReqStatusCode100){
            [hud hideAnimated:YES];
            [YYToast showToastWithTitle:NSLocalizedString(@"发货成功！",nil) andDuration:kAlertToastDuration];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    //返回到入口页面，再进入或刷新订单详情页
                    if(ws.modifySuccess){
                        ws.modifySuccess();
                    }
                });
            });

        }else{
            [hud hideAnimated:YES];
            [YYToast showToastWithView:self.view title:rspStatusAndMessage.message andDuration:kAlertToastDuration];
        }
    }];
}
/**
请选择收件地址/请编辑收件地址
 */
-(void)chooseReceiverAddress{
    if([_buyerStockEnabled boolValue]){
//        跳转去仓库
        [self gotoChooseWarehouseView];
    }else{
//        请编辑收件地址
        [self gotoDeliverModifyAddressView];
    }
}
/**
 请编辑收件地址
 */
-(void)gotoDeliverModifyAddressView{

    WeakSelf(ws);
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Account" bundle:[NSBundle mainBundle]];
    YYDeliverModifyAddressViewController *addAddressViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYDeliverModifyAddressViewController"];
    addAddressViewController.deliverModel = _deliverModel;

    __block YYDeliverModifyAddressViewController *blockAddAddressViewController = addAddressViewController;

    [addAddressViewController setCancelButtonClicked:^(){
        removeFromSuperviewUseUseAnimateAndDeallocViewController(blockAddAddressViewController.view,blockAddAddressViewController);
    }];

    [addAddressViewController setModifySuccess:^{
        [ws updateUI];
        removeFromSuperviewUseUseAnimateAndDeallocViewController(blockAddAddressViewController.view,blockAddAddressViewController);
    }];

    [self.view addSubview:addAddressViewController.view];
    
    [addAddressViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(ws.view);
    }];

    addAnimateWhenAddSubview(addAddressViewController.view);
}
/**
 跳转去仓库
 */
-(void)gotoChooseWarehouseView{
    WeakSelf(ws);
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [YYOrderApi getWarehouseListWithBuyerID:_packingListDetailModel.buyerId andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYWarehouseListModel *warehouseListModel, NSError *error) {
        [hud hideAnimated:YES];
        if(rspStatusAndMessage.status == YYReqStatusCode100){

            YYChooseWarehouseView *chooseWarehouseView = [[YYChooseWarehouseView alloc] initWithWarehouseArray:warehouseListModel.result WithBlock:^(YYWarehouseModel *warehouseModel) {
                ws.deliverModel.receiverAddress = warehouseModel.address;
                ws.deliverModel.warehouseId = warehouseModel.id;
                ws.deliverModel.warehouseName = warehouseModel.name;
                ws.deliverModel.receiverPhone = warehouseModel.phone;
                ws.deliverModel.receiver = warehouseModel.receiver;
                [ws updateUI];
            }];

            [ws.view addSubview:chooseWarehouseView];

        }else{
            [YYToast showToastWithView:ws.view title:rspStatusAndMessage.message andDuration:kAlertToastDuration];
        }
    }];
}
//选择物流公司
-(void)chooseLogistics{
    WeakSelf(ws);
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [YYOrderApi getExpressCompanyWithBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSArray *expressCompanyArray, NSError *error) {
        [hud hideAnimated:YES];
        if(rspStatusAndMessage.status == YYReqStatusCode100){

            WeakSelf(ws);

            YYChooseLogisticsView *chooseLogisticsView = [[YYChooseLogisticsView alloc] initWithExpressCompanyArray:expressCompanyArray WithBlock:^(YYExpressCompanyModel *expressCompanyModel) {
                ws.deliverModel.logisticsName = expressCompanyModel.name;
                [ws updateUI];
            }];

            [ws.view addSubview:chooseLogisticsView];

        }else{
            [YYToast showToastWithView:ws.view title:rspStatusAndMessage.message andDuration:kAlertToastDuration];
        }
    }];
}
//扫码物流编号
-(void)sweepYardButtonClicked{
    WeakSelf(ws);
    YYQRCodeController *QRCode = [YYQRCodeController QRCodeSuccessMessageBlock:^(YYQRCodeController *code, NSString *messageString) {

        if([YYVerifyTool inputShouldLetterOrNum:messageString]){
            ws.deliverModel.logisticsCode = messageString;
            [ws updateUI];
            [code dismissController];
        }else{
            [code toast:NSLocalizedString(@"抱歉，您扫描内容不正确！",nil) collback:^(YYQRCodeController *code) {
                [code scanningAgain];
            }];
        }
    }];

    [self presentViewController:QRCode animated:YES completion:nil];
}
#pragma mark - --------------自定义方法----------------------
-(void)updateUI{
    [_tableView reloadData];
}

#pragma mark - --------------other----------------------

@end

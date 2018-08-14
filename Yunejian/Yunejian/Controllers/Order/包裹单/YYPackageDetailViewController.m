//
//  YYPackageDetailViewController.m
//  yunejianDesigner
//
//  Created by yyj on 2018/6/28.
//  Copyright © 2018年 Apple. All rights reserved.
//

#import "YYPackageDetailViewController.h"

// c文件 —> 系统文件（c文件在前）

// 控制器
#import "YYNavigationBarViewController.h"
#import "YYLogisticsDetailViewController.h"
#import "YYParcelExceptionDetailViewController.h"

// 自定义视图
#import "MBProgressHUD.h"
#import "YYOrderStatusCell.h"
#import "YYPickingListStyleCell.h"
#import "YYPackageDetailInfoCell.h"
#import "YYPackageAddressInfoCell.h"
#import "YYPackageLogisticsInfoCell.h"

// 接口
#import "YYOrderApi.h"

// 分类

// 自定义类和三方类（ cocoapods类 > model > 工具类 > 其他）
#import "YYPackageModel.h"
#import "YYPackingListStyleModel.h"
#import "YYPackingListDetailModel.h"

#import "regular.h"

@interface YYPackageDetailViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) YYNavigationBarViewController *navigationBarViewController;
@property (nonatomic, strong) UIView *containerView;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) YYPackingListDetailModel *packingListDetailModel;

@end

@implementation YYPackageDetailViewController

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
    [MobClick beginLogPageView:kYYPagePackageDetail];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    // 退出埋点
    [MobClick endLogPageView:kYYPagePackageDetail];
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

}
- (void)PrepareUI {
    self.view.backgroundColor = _define_white_color;

    _containerView = [UIView getCustomViewWithColor:nil];
    [self.view addSubview:_containerView];
    [_containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(50);
        make.top.mas_equalTo(self.mas_topLayoutGuideBottom).with.offset(0);
    }];

    [self createOrUpdateNavView];
}
-(void)createOrUpdateNavView{
    if(!_navigationBarViewController){
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        YYNavigationBarViewController *navigationBarViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYNavigationBarViewController"];
        navigationBarViewController.previousTitle = @"";
        navigationBarViewController.nowTitle = _packageName;
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
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(ws.containerView.mas_bottom).with.offset(0);
        make.left.right.bottom.mas_equalTo(0);
    }];

    [self.tableView registerNib:[UINib nibWithNibName:@"YYOrderStatusCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"YYOrderStatusCell"];
}

#pragma mark - --------------请求数据----------------------
- (void)RequestData {
    [self getParcelDetail];
}
//获取单个包裹单详情
-(void)getParcelDetail{
    WeakSelf(ws);
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [YYOrderApi getParcelDetailByPackageId:_packageModel.packageId andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYPackingListDetailModel *packingListDetailModel, NSError *error) {
        [hud hideAnimated:YES];
        if(rspStatusAndMessage.status == YYReqStatusCode100){
            ws.packingListDetailModel = packingListDetailModel;
            [ws updateUI];
        }else{
            [YYToast showToastWithView:self.view title:rspStatusAndMessage.message andDuration:kAlertToastDuration];
        }
    }];

}
#pragma mark - --------------系统代理----------------------
#pragma mark - TableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(!_packingListDetailModel){
        //数据还未加载出来
        return 0;
    }

    if(indexPath.section == 0){
        if(indexPath.row == 0){
            return 96;
        }else if(indexPath.row == 1){
            return UITableViewAutomaticDimension;
        }else if(indexPath.row == 2){
            if([_packingListDetailModel.express.message isEqualToString:@"ok"] && ![NSArray isNilOrEmpty:_packingListDetailModel.express.data]){
                return UITableViewAutomaticDimension;
            }else{
                return 54;
            }
        }else{
            return 0;
        }
    }else{
        YYPackingListStyleModel *packingListStyleModel = _packingListDetailModel.styleColors[indexPath.row];
        if(packingListStyleModel.color.sizes.count){
            if(indexPath.row == _packingListDetailModel.styleColors.count - 1){
                return 74 + (packingListStyleModel.color.sizes.count - 1)*50 + 48;
            }else{
                return 74 + (packingListStyleModel.color.sizes.count - 1)*50;
            }
        }else{
            return 74;
        }
    }
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(!_packingListDetailModel){
        //数据还未加载出来
        return 0;
    }
    if(section == 0){
        return 3;
    }else{
        return _packingListDetailModel.styleColors.count;
    }
}
- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if(section == 0){
        return nil;
    }else{
        static NSString *cellid = @"YYPickingListInfoCell";
        YYPackageDetailInfoCell *cell = [_tableView dequeueReusableCellWithIdentifier:cellid];
        if(!cell){
            cell = [[YYPackageDetailInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        BOOL isPackageError = NO;
        if([_packageModel.status isEqualToString:@"RECEIVED"]){
            // 已收货
            isPackageError = YES;
        }
        cell.isPackageError = isPackageError;
        [cell updateUI];
        return cell;
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(section == 0){
        return 0;
    }else{
        return [YYPackageDetailInfoCell cellHeight];
    }
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WeakSelf(ws);
    if(!_packingListDetailModel){
        static NSString *cellid = @"cellid";
        UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:cellid];
        if(!cell){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        return cell;
    }

    if(indexPath.section == 0){
        if(indexPath.row == 0){
            YYOrderStatusCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"YYOrderStatusCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell setErrorClickBlock:^{
                [ws checkError];
            }];
            cell.hasException = [_packingListDetailModel.hasException boolValue];
            cell.statusType = YYOrderStatusTypePickingList;
            if([_packingListDetailModel.status isEqualToString:@"ON_THE_WAY"]){
                //在途中
                cell.progress = 2;
            }else if([_packingListDetailModel.status isEqualToString:@"RECEIVED"]){
                //已收货
                cell.progress = 3;
            }
            [cell updateUI];
            return cell;
        }else if(indexPath.row == 1){
            static NSString *cellid = @"YYPackageAddressInfoCell";
            YYPackageAddressInfoCell *cell = [_tableView dequeueReusableCellWithIdentifier:cellid];
            if(!cell){
                cell = [[YYPackageAddressInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            cell.packingListDetailModel = _packingListDetailModel;
            [cell updateUI];
            return cell;
        }else if(indexPath.row == 2){
            static NSString *cellid = @"YYPackageLogisticsInfoCell";
            YYPackageLogisticsInfoCell *cell = [_tableView dequeueReusableCellWithIdentifier:cellid];
            if(!cell){
                cell = [[YYPackageLogisticsInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid WithBlock:^(NSString *type) {
                    if([type isEqualToString:@"checkLogisticsInfo"]){
                        [ws checkLogisticsInfo];
                    }
                }];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            cell.packingListDetailModel = _packingListDetailModel;
            [cell updateUI];
            return cell;
        }
    }

    static NSString *cellid = @"YYPickingListStyleCell";
    YYPickingListStyleCell *cell = [_tableView dequeueReusableCellWithIdentifier:cellid];
    if(!cell){
        YYPickingListStyleType styleType = YYPickingListStyleTypeNormal;
        if([_packageModel.status isEqualToString:@"RECEIVED"]){
            // 已收货
            styleType = YYPickingListStyleTypePackageError;
        }
        cell = [[YYPickingListStyleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid styleType:styleType];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    YYPackingListStyleModel *packingListStyleModel = _packingListDetailModel.styleColors[indexPath.row];
    cell.packingListStyleModel = packingListStyleModel;
    if(indexPath.row == _packingListDetailModel.styleColors.count - 1){
        cell.isLastCell = YES;
    }else{
        cell.isLastCell = NO;
    }
    [cell updateUI];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 10;
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

#pragma mark - --------------自定义方法----------------------
-(void)updateUI{
    if(_packingListDetailModel){

        [regular dismissKeyborad];

        [_tableView reloadData];

    }
}
//查看异常反馈
-(void)checkError{
    YYParcelExceptionDetailViewController *parcelExceptionDetailView = [[YYParcelExceptionDetailViewController alloc] init];
    parcelExceptionDetailView.packageId = _packingListDetailModel.packageId;
    [parcelExceptionDetailView setCancelButtonClicked:nil];
    [self.navigationController pushViewController:parcelExceptionDetailView animated:YES];

}
//查看物流信息
-(void)checkLogisticsInfo{

    WeakSelf(ws);
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"OrderDetail" bundle:[NSBundle mainBundle]];
    YYLogisticsDetailViewController *logisticsDetailViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYLogisticsDetailViewController"];
    logisticsDetailViewController.packingListDetailModel = _packingListDetailModel;

    __block YYLogisticsDetailViewController *blockLogisticsDetailViewController = logisticsDetailViewController;

    [logisticsDetailViewController setCancelButtonClicked:^(){
        removeFromSuperviewUseUseAnimateAndDeallocViewController(blockLogisticsDetailViewController.view,blockLogisticsDetailViewController);
    }];

    [self.view addSubview:logisticsDetailViewController.view];

    [logisticsDetailViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(ws.view);
    }];

    addAnimateWhenAddSubview(logisticsDetailViewController.view);
}
#pragma mark - --------------other----------------------

@end

//
//  YYPackingListViewController.m
//  yunejianDesigner
//
//  Created by yyj on 2018/6/13.
//  Copyright © 2018年 Apple. All rights reserved.
//

#import "YYPackingListViewController.h"

// c文件 —> 系统文件（c文件在前）

// 控制器
#import "YYNavigationBarViewController.h"
#import "YYDeliverViewController.h"

// 自定义视图
#import "MBProgressHUD.h"
#import "YYOrderStatusCell.h"
#import "YYPickingListInfoCell.h"
#import "YYPickingListStyleCell.h"
#import "YYPickingListStyleEditCell.h"
#import "YYPopoverBackgroundView.h"

// 接口
#import "YYOrderApi.h"

// 分类

// 自定义类和三方类（ cocoapods类 > model > 工具类 > 其他）
#import "MLInputDodger.h"

#import "YYPackingListDetailModel.h"

#import "regular.h"

@interface YYPackingListViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) YYNavigationBarViewController *navigationBarViewController;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIPopoverController *popController;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *submitBackView;
@property (nonatomic, strong) UIButton *submitBtn;
@property (nonatomic, strong) UIButton *menuBtn;

@property (nonatomic, strong) YYPackingListDetailModel *packingListDetailModel;

@end

@implementation YYPackingListViewController

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
    [MobClick beginLogPageView:kYYPagePackingList];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    // 退出埋点
    [MobClick endLogPageView:kYYPagePackingList];
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
    self.view.backgroundColor = _define_black_color;
    self.view.shiftHeightAsDodgeViewForMLInputDodger = 44.0f+5.0f;
    [self.view registerAsDodgeViewForMLInputDodger];

    _containerView = [UIView getCustomViewWithColor:nil];
    [self.view addSubview:_containerView];
    [_containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(50);
        make.top.mas_equalTo(self.mas_topLayoutGuideBottom).with.offset(0);
    }];

    [self createOrUpdateNavView];
    [self createOrUpdateMenuBtn];
}
#pragma mark - --------------UIConfig----------------------
- (void)UIConfig {
    [self createOrUpdateSubmitBtn];
    [self createTableView];
}
-(void)createOrUpdateSubmitBtn{

    NSString *titleStr = nil;
    if(_packingListType == YYPackingListTypeCreate){
        titleStr = NSLocalizedString(@"保存装箱单",nil);
    }else if(_packingListType == YYPackingListTypeModify){
        titleStr = NSLocalizedString(@"保存装箱单",nil);
    }else if(_packingListType == YYPackingListTypeDetail){
        titleStr = NSLocalizedString(@"发货",nil);
    }
    if(!_submitBackView){
        WeakSelf(ws);

        _submitBackView = [UIView getCustomViewWithColor:_define_white_color];
        [self.view addSubview:_submitBackView];
        [_submitBackView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.mas_equalTo(0);
            make.height.mas_equalTo(69);
        }];

        UIView *upLine = [UIView getCustomViewWithColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.14]];
        [_submitBackView addSubview:upLine];
        [upLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.mas_equalTo(0);
            make.height.mas_equalTo(1);
        }];

        _submitBtn = [UIButton getCustomTitleBtnWithAlignment:0 WithFont:15.f WithSpacing:0 WithNormalTitle:titleStr WithNormalColor:_define_white_color WithSelectedTitle:titleStr WithSelectedColor:_define_white_color];
        [_submitBackView addSubview:_submitBtn];
        [_submitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-40);
            make.centerY.mas_equalTo(ws.submitBackView);
            make.height.mas_equalTo(40.f);
            make.width.mas_equalTo(130.f);
        }];
        [_submitBtn addTarget:self action:@selector(submitAction:) forControlEvents:UIControlEventTouchUpInside];
    }

    if(_packingListType == YYPackingListTypeCreate || _packingListType == YYPackingListTypeModify){
        NSInteger totalSentAmount = [self getTotalSentAmount];
        if(totalSentAmount){
            _submitBtn.selected = NO;
            _submitBtn.backgroundColor = _define_black_color;
        }else{
            _submitBtn.selected = YES;
            _submitBtn.backgroundColor = [UIColor colorWithHex:@"d3d3d3"];
        }
    }else if(_packingListType == YYPackingListTypeDetail){
        _submitBtn.selected = NO;
        _submitBtn.backgroundColor = _define_black_color;
    }

    [_submitBtn setTitle:titleStr forState:UIControlStateNormal];
    [_submitBtn setTitle:titleStr forState:UIControlStateSelected];

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
        make.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(ws.submitBackView.mas_top).with.offset(0);
    }];

    [self.tableView registerNib:[UINib nibWithNibName:@"YYOrderStatusCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"YYOrderStatusCell"];
}
-(void)createOrUpdateNavView{
    if(!_navigationBarViewController){
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        YYNavigationBarViewController *navigationBarViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYNavigationBarViewController"];
        navigationBarViewController.previousTitle = @"";
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

    NSString *titleStr = nil;
    if(_packingListType == YYPackingListTypeCreate){
        titleStr = NSLocalizedString(@"建立装箱单",nil);
    }else if(_packingListType == YYPackingListTypeModify){
        titleStr = NSLocalizedString(@"修改装箱单",nil);
    }else if(_packingListType == YYPackingListTypeDetail){
        titleStr = NSLocalizedString(@"装箱单详情",nil);
    }

    _navigationBarViewController.nowTitle = titleStr;
    [self.navigationBarViewController updateUI];

}
-(void)createOrUpdateMenuBtn{
    if(_packingListType == YYPackingListTypeDetail){
        if(!_menuBtn){
            __weak UIView *_weakContainerView = _containerView;
            _menuBtn = [[UIButton alloc] init];
            [_containerView addSubview:_menuBtn];
            [_menuBtn setImage:[UIImage imageNamed:@"download_menu"] forState:UIControlStateNormal];
            [_menuBtn setTitle:NSLocalizedString(@"更多",nil) forState:UIControlStateNormal];
            [_menuBtn addTarget:self action:@selector(showMenuUI:) forControlEvents:UIControlEventTouchUpInside];
            [_menuBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 20, 0, 0)];
            [_menuBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [_menuBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
            float txtWidth = [_menuBtn.currentTitle sizeWithAttributes:@{NSFontAttributeName:_menuBtn.titleLabel.font}].width;
            [_menuBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(_weakContainerView.mas_top);
                make.width.equalTo(@(txtWidth + 40));
                make.bottom.equalTo(_weakContainerView.mas_bottom);
                make.right.equalTo(_weakContainerView.mas_right).offset(-45);
            }];
        }
        _menuBtn.hidden = NO;
    }else{
        if(_menuBtn){
            _menuBtn.hidden = YES;
        }
    }
}
#pragma mark - --------------请求数据----------------------
//仅在刚进入时候调用
- (void)RequestData {
    if(_packingListType == YYPackingListTypeCreate){
        [self getPackingListDetailToStatus:YYPackingListTypeCreate];
    }else if(_packingListType == YYPackingListTypeModify){
        //...nothing
    }else if(_packingListType == YYPackingListTypeDetail){
        [self getParcelDetail];
    }
}
//获取订单商品详情
- (void)getPackingListDetailToStatus:(YYPackingListType)packingListType{
    WeakSelf(ws);
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [YYOrderApi getPackingListDetailByOrderCode:_orderCode andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYPackingListDetailModel *packingListDetailModel, NSError *error) {
        if(rspStatusAndMessage.status == YYReqStatusCode100){
            [MBProgressHUD hideAllHUDsForView:ws.view animated:YES];
            ws.packingListDetailModel = packingListDetailModel;
            ws.packingListType = packingListType;//只有数据获取到了才给改状态
            [ws updateUI];
        }else{
            [MBProgressHUD hideAllHUDsForView:ws.view animated:YES];
            [YYToast showToastWithView:self.view title:rspStatusAndMessage.message andDuration:kAlertToastDuration];
        }
    }];
}
//获取单个包裹单详情
-(void)getParcelDetail{
    WeakSelf(ws);
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [YYOrderApi getParcelDetailByPackageId:_packageId andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYPackingListDetailModel *packingListDetailModel, NSError *error) {
        if(rspStatusAndMessage.status == YYReqStatusCode100){
            [MBProgressHUD hideAllHUDsForView:ws.view animated:YES];
            ws.packingListDetailModel = packingListDetailModel;
            ws.packingListType = YYPackingListTypeDetail;//只有数据获取到了才给改状态
            [ws updateUI];
        }else{
            [MBProgressHUD hideAllHUDsForView:ws.view animated:YES];
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
        return 96;
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
        return 1;
    }else{
        return _packingListDetailModel.styleColors.count;
    }
}
- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if(section == 0){
        return nil;
    }else{
        static NSString *cellid = @"YYPickingListInfoCell";
        YYPickingListInfoCell *cell = [_tableView dequeueReusableCellWithIdentifier:cellid];
        if(!cell){
            cell = [[YYPickingListInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.packingListDetailModel = _packingListDetailModel;
        if(_packingListType == YYPackingListTypeDetail){
            cell.isStyleEdit = NO;
        }else{
            cell.isStyleEdit = YES;
        }
        [cell updateUI];
        return cell;
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(section == 0){
        return 0;
    }else{
        return [YYPickingListInfoCell cellHeight];
    }
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
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
        YYOrderStatusCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"YYOrderStatusCell"];
        cell.statusType = YYOrderStatusTypePickingList;
        if(_packingListType == YYPackingListTypeCreate){
            cell.progress = 0;
        }else if(_packingListType == YYPackingListTypeModify){
            cell.progress = 0;
        }else if(_packingListType == YYPackingListTypeDetail){
            cell.progress = 1;
        }
        [cell updateUI];
        return cell;
    }else{
        if(_packingListType == YYPackingListTypeDetail){
            static NSString *cellid = @"YYPickingListStyleCell";
            YYPickingListStyleCell *cell = [_tableView dequeueReusableCellWithIdentifier:cellid];
            if(!cell){
                cell = [[YYPickingListStyleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid styleType:YYPickingListStyleTypeNormal];
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
        }else{
            WeakSelf(ws);
            static NSString *cellid = @"YYPickingListStyleEditCell";
            YYPickingListStyleEditCell *cell = [_tableView dequeueReusableCellWithIdentifier:cellid];
            if(!cell){
                cell = [[YYPickingListStyleEditCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid WithBlock:^(NSString *type) {
                    if([type isEqualToString:@"update_submit_status"]){
                        //更新submit按钮状态
                        [ws createOrUpdateSubmitBtn];
                    }
                }];
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
    }
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
-(void)showMenuUI:(id)sender{
    NSInteger menuUIWidth = 150;
    NSArray *menuData = @[@[@"download_update",NSLocalizedString(@"修改",nil),@"1000"]];
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
//修改装箱单
- (void)menuBtnHandler:(id)sender{
    UIButton *btn = (UIButton *)sender;
    NSInteger type = btn.tag - 1000;
    [_popController dismissPopoverAnimated:NO];
    if(_packingListDetailModel){
        if(type == 0){
            //修改装箱单
            [self modifyPackingList];
        }
    }
    
}
//修改装箱单
-(void)modifyPackingList{
    [self getPackingListDetailToStatus:YYPackingListTypeModify];
}
//submit
-(void)submitAction:(UIButton *)sender{
    if(!sender.selected){
        if(_packingListType == YYPackingListTypeCreate || _packingListType == YYPackingListTypeModify){
            //保存
            [self savePackingList];
        }else if(_packingListType == YYPackingListTypeDetail){
            //发货
            [self gotoDeliverView];
        }
    }
}
//跳转发货页
-(void)gotoDeliverView{
    WeakSelf(ws);
    YYDeliverViewController *deliverViewController = [[YYDeliverViewController alloc] init];
    [deliverViewController setModifySuccess:^{
        [ws.navigationController popViewControllerAnimated:NO];
        if(ws.modifySuccess){
            ws.modifySuccess();
        }
    }];
    deliverViewController.packingListDetailModel = _packingListDetailModel;
    [self.navigationController pushViewController:deliverViewController animated:YES];
}
//保存装箱单
-(void)savePackingList{
    WeakSelf(ws);
    //仅修改和新建可操作
    if(_packingListType == YYPackingListTypeCreate || _packingListType == YYPackingListTypeModify){
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [YYOrderApi savePackingListByDetailModel:_packingListDetailModel andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,NSNumber *packageId,NSError *error) {
            if(rspStatusAndMessage.status == YYReqStatusCode100){

                ws.packageId = packageId;
                [ws getParcelDetail];

            }else{
                [MBProgressHUD hideAllHUDsForView:ws.view animated:YES];
                [YYToast showToastWithView:self.view title:rspStatusAndMessage.message andDuration:kAlertToastDuration];
            }
        }];
    }
}

#pragma mark - --------------自定义方法----------------------
-(void)updateUI{
    if(_packingListDetailModel){

        [regular dismissKeyborad];

        //更新标题、submit、menu按钮
        [self createOrUpdateNavView];
        [self createOrUpdateSubmitBtn];
        [self createOrUpdateMenuBtn];

        [_tableView reloadData];

    }
}
//算一遍到底有多少的sentAmount
-(NSInteger)getTotalSentAmount{
    NSInteger totalSentAmount = 0;
    if(_packingListDetailModel){
        for (YYPackingListStyleModel *packingListStyleModel in _packingListDetailModel.styleColors) {
            for (YYPackingListSizeModel *packingListSizeModel in packingListStyleModel.color.sizes) {
                totalSentAmount += [packingListSizeModel.sentAmount integerValue];
            }
        }
    }
    return totalSentAmount;
}
#pragma mark - --------------other----------------------

@end

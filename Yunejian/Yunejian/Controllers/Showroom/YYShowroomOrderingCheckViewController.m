//
//  YYShowroomOrderingCheckViewController.m
//  yunejianDesigner
//
//  Created by yyj on 2018/3/12.
//  Copyright © 2018年 Apple. All rights reserved.
//

#import "YYShowroomOrderingCheckViewController.h"

// c文件 —> 系统文件（c文件在前）

// 控制器
#import "YYNavigationBarViewController.h"

// 自定义视图
#import "YYNavView.h"
#import "MBProgressHUD.h"
#import "YYNoDataView.h"
//#import "YYMenuPopView.h"
#import "YYShowroomOrderingCheckCell.h"
#import "YYPopoverArrowBackgroundView.h"

// 接口
#import "YYShowroomApi.h"

// 分类
#import "UIImage+Tint.h"

// 自定义类和三方类（ cocoapods类 > model > 工具类 > 其他）
#import <MJRefresh.h>

#import "YYShowroomOrderingCheckListModel.h"

@interface YYShowroomOrderingCheckViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) YYPageInfoModel *currentPageInfo;
@property (nonatomic, strong) NSMutableArray *dataArray;

@property(nonatomic,strong) NSArray *menuBtnsData;

@property (nonatomic, strong) YYNavView *navView;
@property (nonatomic, strong) UIButton *pullDownMenu;
@property (nonatomic, strong) YYNoDataView *noDataView;
@property (nonatomic, strong) UIView *containerView;

@property (nonatomic, strong) NSString *status;

@property(nonatomic,strong) UIPopoverController *popController;

@property (nonatomic,strong) YYNavigationBarViewController *navigationBarViewController;

@end

@implementation YYShowroomOrderingCheckViewController

#pragma mark - --------------生命周期--------------
- (void)viewDidLoad {
    [super viewDidLoad];
    [self SomePrepare];
    [self UIConfig];
    [self RequestData];
}
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
#pragma mark - --------------SomePrepare--------------
- (void)SomePrepare
{
    [self PrepareData];
    [self PrepareUI];
}
- (void)PrepareData{
    self.dataArray = [[NSMutableArray alloc] init];
    self.menuBtnsData = @[@[@"",NSLocalizedString(@"全部",nil),@"1"]
                      ,@[@"",NSLocalizedString(@"待审核",nil),@"2"]
                      ,@[@"",NSLocalizedString(@"已通过",nil),@"3"]
                      ,@[@"",NSLocalizedString(@"已拒绝",nil),@"4"]
                      ,@[@"",NSLocalizedString(@"已取消",nil),@"5"]
                      ,@[@"",NSLocalizedString(@"已失效",nil),@"6"]
                      ];

    self.status = nil;
}
- (void)PrepareUI{
    self.view.backgroundColor = [UIColor colorWithHex:@"f8f8f8"];

    _containerView = [UIView getCustomViewWithColor:nil];
    [self.view addSubview:_containerView];
    [_containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(50);
        make.top.mas_equalTo(self.mas_topLayoutGuideBottom).with.offset(0);
    }];

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    YYNavigationBarViewController *navigationBarViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYNavigationBarViewController"];

    NSString *title = NSLocalizedString(@"预约审核",nil);
    navigationBarViewController.nowTitle = title;
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
            if (ws.cancelButtonClicked) {
                ws.cancelButtonClicked();
            }
            [ws.navigationController popViewControllerAnimated:YES];
            blockVc = nil;
        }
    }];

    _pullDownMenu = [UIButton getCustomImgBtnWithImageStr:@"filter_icon" WithSelectedImageStr:nil];
    [_containerView addSubview:_pullDownMenu];
    [_pullDownMenu mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.bottom.mas_equalTo(-1);
        make.width.mas_equalTo(100);
        make.right.mas_equalTo(-17);
    }];
    [_pullDownMenu setTitle:NSLocalizedString(@"筛选", nil) forState:UIControlStateNormal];
    _pullDownMenu.titleLabel.font = [UIFont systemFontOfSize:16];
    [_pullDownMenu setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _pullDownMenu.imageEdgeInsets = UIEdgeInsetsMake(0, -8, 0, 0);
    _pullDownMenu.contentEdgeInsets = UIEdgeInsetsMake(0, 4, 0, 0);
    [_pullDownMenu addTarget:self action:@selector(showMenuUI:) forControlEvents:UIControlEventTouchUpInside];

}
-(void)showMenuUI:(id)sender{
    NSInteger menuUIWidth = 154;
    NSInteger menuUIHeight = 300;
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
    
    if(type == 1){
        //全部
        self.status = nil;
    }else if(type == 2){
        //待审核
        self.status = @"TO_BE_VERIFIED";
    }else if(type == 3){
        //已通过
        self.status = @"VERIFIED";
    }else if(type == 4){
        //已拒绝
        self.status = @"REJECTED";
    }else if(type == 5){
        //已取消
        self.status = @"CANCELLED";
    }else if(type == 6){
        //已失效
        self.status = @"INVALIDATED";
    }

    NSArray *btnInfo =  [_menuBtnsData objectAtIndex:(type-1)];
    NSString *btnTxt = ((type == 1)?NSLocalizedString(@"筛选", nil):[btnInfo objectAtIndex:1]);
    [_pullDownMenu setTitle:btnTxt forState:UIControlStateNormal];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self loadListFromServerByPageIndex:1 endRefreshing:NO];
}
#pragma mark - --------------UIConfig----------------------
-(void)UIConfig{
    [self CreateTableView];
    [self CreateNoDataView];
}
-(void)CreateTableView
{
    _tableView=[[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    [self.view addSubview:_tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        make.top.mas_equalTo(_containerView.mas_bottom).with.offset(0);
    }];
    _tableView.delegate=self;
    _tableView.dataSource=self;
    _tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = [UIColor colorWithHex:@"f8f8f8"];

    [self addHeader];
    [self addFooter];
}
-(void)CreateNoDataView{
    _noDataView = (YYNoDataView *)addNoDataView_pad(self.view,[NSString stringWithFormat:@"%@|icon:notxt_icon",NSLocalizedString(@"未筛选到相关预约", nil)],@"919191",@"no_ordering_icon");
    _noDataView.hidden = YES;
}
- (void)addHeader{
    WeakSelf(ws);
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        if (![YYCurrentNetworkSpace isNetwork]) {
            [YYToast showToastWithTitle:kNetworkIsOfflineTips andDuration:kAlertToastDuration];
            [ws.tableView.mj_header endRefreshing];
            return;
        }
        [ws loadListFromServerByPageIndex:1 endRefreshing:YES];
    }];
    self.tableView.mj_header = header;
    self.tableView.mj_header.automaticallyChangeAlpha = YES;
    header.lastUpdatedTimeLabel.hidden = YES;
}

- (void)addFooter{
    WeakSelf(ws);
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        if (![YYCurrentNetworkSpace isNetwork]) {
            [YYToast showToastWithTitle:kNetworkIsOfflineTips andDuration:kAlertToastDuration];
            [ws.tableView.mj_footer endRefreshing];
            return;
        }
        if (!ws.currentPageInfo.isLastPage) {
            [ws loadListFromServerByPageIndex:[ws.currentPageInfo.pageIndex intValue]+1 endRefreshing:YES];
        }else{
            //弹出提示
            [ws.tableView.mj_footer endRefreshing];
        }
    }];
}
- (void)loadListFromServerByPageIndex:(int)pageIndex endRefreshing:(BOOL)endrefreshing{
    WeakSelf(ws);

    __block BOOL blockEndrefreshing = endrefreshing;
    [YYShowroomApi getOrderingCheckListWithAppointmentId:_appointmentId status:_status PageIndex:pageIndex pageSize:kPageSize andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYShowroomOrderingCheckListModel *showroomOrderingCheckListModel, NSError *error) {
        if (rspStatusAndMessage.status == kCode100) {
            if (pageIndex == 1) {
                [ws.dataArray removeAllObjects];
            }
            ws.currentPageInfo = showroomOrderingCheckListModel.pageInfo;

            if (showroomOrderingCheckListModel && showroomOrderingCheckListModel.result
                && [showroomOrderingCheckListModel.result count] > 0){
                [ws.dataArray addObjectsFromArray:showroomOrderingCheckListModel.result];
            }
            //如果没有数据
            if (pageIndex == 1 && _noDataView) {
                if(ws.dataArray.count){
                    ws.noDataView.hidden = YES;
                    ws.view.backgroundColor = [UIColor colorWithHex:@"f8f8f8"];
                    ws.tableView.backgroundColor = [UIColor colorWithHex:@"f8f8f8"];
                    ws.containerView.backgroundColor = [UIColor colorWithHex:@"f8f8f8"];
                }else{
                    ws.noDataView.hidden = NO;
                    if(ws.status){
                        ws.noDataView.titleLabel.text = NSLocalizedString(@"未筛选到相关预约", nil);
                    }else{
                        ws.noDataView.titleLabel.text = NSLocalizedString(@"暂无买手预约订货会", nil);
                    }
                    ws.view.backgroundColor = _define_white_color;
                    ws.tableView.backgroundColor = _define_white_color;
                    ws.containerView.backgroundColor = _define_white_color;
                }
            }
        }

        if(blockEndrefreshing){
            [ws.tableView.mj_header endRefreshing];
            [ws.tableView.mj_footer endRefreshing];
        }
        [ws.tableView reloadData];

        [MBProgressHUD hideAllHUDsForView:ws.view animated:YES];
    }];
}
#pragma mark - --------------请求数据----------------------
-(void)RequestData{
    //获取列表数据
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [_tableView.mj_header beginRefreshing];
}

#pragma mark - --------------系统代理----------------------
#pragma mark -UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //    数据还未获取时候
    if(!_dataArray.count)
    {
        static NSString *cellid=@"null_data_cell";
        UITableViewCell *cell=[_tableView dequeueReusableCellWithIdentifier:cellid];
        if(!cell)
        {
            cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
        }
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        return cell;
    }

    WeakSelf(ws);
    static NSString *cellid=@"YYShowroomOrderingCheckCell";
    YYShowroomOrderingCheckCell *cell=[_tableView dequeueReusableCellWithIdentifier:cellid];
    if(!cell)
    {
        cell=[[YYShowroomOrderingCheckCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid WithBlock:^(NSString *type,YYShowroomOrderingCheckModel *showroomOrderingCheckModel) {
            if([type isEqualToString:@"refuse"]){
                //拒绝
                [ws refuseOrderCheckByCheckModel:showroomOrderingCheckModel];

            }else if([type isEqualToString:@"agree"]){
                //通过
                [ws agreeOrderCheckByCheckModel:showroomOrderingCheckModel];
            }
        }];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
    }
    cell.showroomOrderingCheckModel = _dataArray[indexPath.row];
    return cell;
}
#pragma mark -UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(_dataArray.count){
        return 134.f;
    }
    return 0;
}

#pragma mark - --------------自定义代理/block----------------------


#pragma mark - --------------自定义响应----------------------
-(void)GoBack:(id)sender {
    if(_cancelButtonClicked)
    {
        _cancelButtonClicked();
    }
}
-(void)userOperation{
    if(_block){
        _block(@"user_operation",_appointmentId);
    }
}
//拒绝
-(void)refuseOrderCheckByCheckModel:(YYShowroomOrderingCheckModel *)showroomOrderingCheckModel{
    WeakSelf(ws);
    NSString *ids = [[NSString alloc] initWithFormat:@"%ld",[showroomOrderingCheckModel.id integerValue]];
    [YYShowroomApi refuseOrderingApplicationWithIds:ids andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSError *error) {
        if(rspStatusAndMessage.status == kCode100){
            showroomOrderingCheckModel.status = @"REJECTED";
            [ws.tableView reloadData];
            [ws userOperation];
        }else{
            [YYToast showToastWithView:self.view title:rspStatusAndMessage.message andDuration:kAlertToastDuration];
        }
    }];
}
//通过
-(void)agreeOrderCheckByCheckModel:(YYShowroomOrderingCheckModel *)showroomOrderingCheckModel{
    WeakSelf(ws);
    NSString *ids = [[NSString alloc] initWithFormat:@"%ld",[showroomOrderingCheckModel.id integerValue]];
    [YYShowroomApi agreeOrderingApplicationWithIds:ids andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSError *error) {
        if(rspStatusAndMessage.status == kCode100){
            showroomOrderingCheckModel.status = @"VERIFIED";
            [ws.tableView reloadData];
            [ws userOperation];
        }else{
            [YYToast showToastWithView:self.view title:rspStatusAndMessage.message andDuration:kAlertToastDuration];
        }
    }];
}
#pragma mark - --------------自定义方法----------------------


#pragma mark - --------------other----------------------

@end

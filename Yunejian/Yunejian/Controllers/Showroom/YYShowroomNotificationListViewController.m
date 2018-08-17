//
//  YYShowroomNotificationListViewController.m
//  yunejianDesigner
//
//  Created by yyj on 2018/3/8.
//  Copyright © 2018年 Apple. All rights reserved.
//

#import "YYShowroomNotificationListViewController.h"

// c文件 —> 系统文件（c文件在前）

// 控制器
#import "YYNavigationBarViewController.h"
#import "YYShowroomOrderingCheckViewController.h"

// 自定义视图
#import "MBProgressHUD.h"
#import "YYShowroomNotificationListCell.h"
#import "YYNoDataView.h"

// 接口
#import "YYShowroomApi.h"

// 分类

// 自定义类和三方类（ cocoapods类 > model > 工具类 > 其他）
#import <MJRefresh.h>

#import "YYShowroomOrderingListModel.h"

@interface YYShowroomNotificationListViewController ()<UICollectionViewDataSource,UICollectionViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewLayout *collectionLayout;
@property (nonatomic, strong) YYPageInfoModel *currentPageInfo;
@property (nonatomic, strong) NSMutableArray *dataArray;

@property (nonatomic, strong) YYNoDataView *noDataView;
@property (nonatomic, strong) UIView *containerView;

@property (nonatomic, strong) YYShowroomOrderingListModel *showroomOrderingListModel;

@property (nonatomic,strong) YYNavigationBarViewController *navigationBarViewController;

@end

@implementation YYShowroomNotificationListViewController
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

    NSString *title = NSLocalizedString(@"订货会列表",nil);
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

    NSLog(@"111");
}

#pragma mark - --------------UIConfig----------------------
-(void)UIConfig{
    [self CreateCollectionView];
    [self CreateNoDataView];
}
-(void)CreateCollectionView
{

    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];

    NSInteger cellWidth = (SCREEN_WIDTH-94-30)/2;
    layout.itemSize = CGSizeMake(cellWidth, 139);
    layout.footerReferenceSize  = CGSizeMake(0, 0);
    layout.headerReferenceSize = CGSizeMake(0, 0);

    layout.sectionInset            = UIEdgeInsetsMake(20, 47, 20, 47);
    layout.minimumInteritemSpacing = 30.f;
    layout.minimumLineSpacing      = 20.f;

    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    [self.view addSubview:_collectionView];
    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        make.top.mas_equalTo(_containerView.mas_bottom).with.offset(0);
    }];
    _collectionView.backgroundColor = [UIColor colorWithHex:@"f8f8f8"];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;

    [_collectionView registerClass:[YYShowroomNotificationListCell class] forCellWithReuseIdentifier:@"YYShowroomNotificationListCell"];

    [self addHeader];
    [self addFooter];
}
-(void)CreateNoDataView{
    _noDataView = (YYNoDataView *)addNoDataView_pad(self.view,[NSString stringWithFormat:@"%@|icon:notxt_icon",NSLocalizedString(@"暂无被指定的订货会/n请微信搜索“yunejianhelper”或扫码联系小助手发布订货会。", nil)],@"000000",@"weixincode_img");
    _noDataView.hidden = YES;
}
- (void)addHeader{
    WeakSelf(ws);
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        if (![YYCurrentNetworkSpace isNetwork]) {
            [YYToast showToastWithTitle:kNetworkIsOfflineTips andDuration:kAlertToastDuration];
            [ws.collectionView.mj_header endRefreshing];
            return;
        }
        [ws loadListFromServerByPageIndex:1 endRefreshing:YES];
    }];
    self.collectionView.mj_header = header;
    self.collectionView.mj_header.automaticallyChangeAlpha = YES;
    header.lastUpdatedTimeLabel.hidden = YES;
}

- (void)addFooter{
    WeakSelf(ws);
    self.collectionView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        if (![YYCurrentNetworkSpace isNetwork]) {
            [YYToast showToastWithTitle:kNetworkIsOfflineTips andDuration:kAlertToastDuration];
            [ws.collectionView.mj_footer endRefreshing];
            return;
        }
        if (!ws.currentPageInfo.isLastPage) {
            [ws loadListFromServerByPageIndex:[ws.currentPageInfo.pageIndex intValue]+1 endRefreshing:YES];
        }else{
            //弹出提示
            [ws.collectionView.mj_footer endRefreshing];
        }
    }];
}
#pragma mark - --------------请求数据----------------------
-(void)RequestData{
    //清空订货会消息红点
    [self clearOrderingMsg];

    //获取列表数据
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [_collectionView.mj_header beginRefreshing];
}
-(void)clearOrderingMsg{
    //清空订货会消息红点
    if(_hasOrderingMsg){
        [YYShowroomApi clearOrderingMsgWithBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSError *error) {
            
        }];
    }
}
- (void)loadListFromServerByPageIndex:(int)pageIndex endRefreshing:(BOOL)endrefreshing{
    WeakSelf(ws);

    __block BOOL blockEndrefreshing = endrefreshing;
    [YYShowroomApi getOrderingListWithPageIndex:pageIndex pageSize:kPageSize andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYShowroomOrderingListModel *showroomOrderingListModel, NSError *error) {
        if (rspStatusAndMessage.status == YYReqStatusCode100) {
            if (pageIndex == 1) {
                [ws.dataArray removeAllObjects];
            }
            ws.currentPageInfo = showroomOrderingListModel.pageInfo;

            if (showroomOrderingListModel && showroomOrderingListModel.result
                && [showroomOrderingListModel.result count] > 0){
                [ws.dataArray addObjectsFromArray:showroomOrderingListModel.result];
            }
            //如果没有数据
            if (pageIndex == 1 && _noDataView) {
                if(ws.dataArray.count){
                    self.noDataView.hidden = YES;
                    self.view.backgroundColor = [UIColor colorWithHex:@"f8f8f8"];
                    self.collectionView.backgroundColor = [UIColor colorWithHex:@"f8f8f8"];
                    self.containerView.backgroundColor = [UIColor colorWithHex:@"f8f8f8"];
                }else{
                    self.noDataView.hidden = NO;
                    self.view.backgroundColor = _define_white_color;
                    self.collectionView.backgroundColor = _define_white_color;
                    self.containerView.backgroundColor = _define_white_color;
                }
            }
        }

        if(blockEndrefreshing){
            [self.collectionView.mj_header endRefreshing];
            [self.collectionView.mj_footer endRefreshing];
        }
        [ws.collectionView reloadData];

        [MBProgressHUD hideAllHUDsForView:ws.view animated:YES];
    }];
}

#pragma mark - --------------系统代理----------------------
#pragma mark -  UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{

    if ([_dataArray count] > 0) {
        return [_dataArray count];
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    WeakSelf(ws);
    static NSString* reuseIdentifier = @"YYShowroomNotificationListCell";
    YYShowroomNotificationListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    [cell setBlock:^(NSString *type, NSNumber *orderingID,UIView *touchView) {
        if([type isEqualToString:@"enter_ordering_detail"]){
            //点击此区域进入订货会详情页
            [ws enterOrderingDetailView:orderingID touchView:touchView];
        }else if([type isEqualToString:@"enter_ordering_checkview"]){
            //点击此区域进入审核页
            [ws enterOrderingCheckView:orderingID];
        }
    }];
    cell.logisticsModel = _dataArray[indexPath.row];
    return cell;
}
#pragma mark - --------------自定义代理/block----------------------


#pragma mark - --------------自定义响应----------------------
-(void)GoBack:(id)sender {
    if(_cancelButtonClicked)
    {
        _cancelButtonClicked();
    }
}

#pragma mark - --------------自定义方法----------------------
//点击此区域进入审核页
-(void)enterOrderingCheckView:(NSNumber *)orderingID{
    WeakSelf(ws);
    YYShowroomOrderingCheckViewController *showroomOrderingCheckViewController = [[YYShowroomOrderingCheckViewController alloc] init];
    [showroomOrderingCheckViewController setCancelButtonClicked:^(){
    }];
    [showroomOrderingCheckViewController setBlock:^(NSString *type, NSNumber *appointmentId) {
        if([type isEqualToString:@"user_operation"]){
            [ws userOperation:appointmentId];
        }
    }];
    showroomOrderingCheckViewController.appointmentId = orderingID;
    [self.navigationController pushViewController:showroomOrderingCheckViewController animated:YES];
}
-(void)userOperation:(NSNumber *)appointmentId{
    if(_dataArray){
        for (YYShowroomOrderingModel *showroomOrderingModel in _dataArray) {
            if([showroomOrderingModel.id integerValue] == [appointmentId integerValue]){
                NSInteger peopleToBeVerified = [showroomOrderingModel.peopleToBeVerified integerValue];
                if(peopleToBeVerified){
                    peopleToBeVerified--;
                    showroomOrderingModel.peopleToBeVerified = @(peopleToBeVerified);
                    [_collectionView reloadData];
                }
            }
        }
    }
}
//点击此区域进入订货会详情页
-(void)enterOrderingDetailView:(NSNumber *)orderingID touchView:(UIView *)touchView{
    NSString *weburl = [self getOrderingWebUrl:orderingID];
    if(weburl){
        clickWebUrl_pad(weburl,touchView);
    }
}
-(NSString *)getOrderingWebUrl:(NSNumber *)orderingID{
    NSString *weburl = nil;
    NSString *_kLastYYServerURL = [[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL];
    //字条串是否包含有某字符串
    if ([_kLastYYServerURL containsString:@"show.ycofoundation.com"]) {
        //展示
        weburl = [[NSString alloc] initWithFormat:@"http://mshow.ycosystem.com/orderMeet/detail?id=%ld",(long)[orderingID integerValue]];
    }else if ([_kLastYYServerURL containsString:@"test.ycosystem.com"]){
        //测试
        weburl = [[NSString alloc] initWithFormat:@"http://mt.ycosystem.com/orderMeet/detail?id=%ld",(long)[orderingID integerValue]];
    }else if ([_kLastYYServerURL containsString:@"ycosystem.com"]){
        //生产
        weburl = [[NSString alloc] initWithFormat:@"http://m.ycosystem.com/orderMeet/detail?id=%ld",(long)[orderingID integerValue]];
    }
    if(weburl && [LanguageManager isEnglishLanguage]){
        weburl = [[NSString alloc] initWithFormat:@"%@&lang=en",weburl];
    }
    return weburl;
}
#pragma mark - --------------other----------------------

@end

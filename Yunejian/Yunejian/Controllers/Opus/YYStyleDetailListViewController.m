//
//  YYStyleDetailListViewController.m
//  Yunejian
//
//  Created by yyj on 15/7/26.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import "YYStyleDetailListViewController.h"

// c文件 —> 系统文件（c文件在前）

// 控制器
#import "YYStyleDetailViewController.h"
#import "YYEditMyPageViewController.h"
#import "YYCartDetailViewController.h"

// 自定义视图
#import "YYTopBarShoppingCarButton.h"
#import "MBProgressHUD.h"
#import "YYSeriesDetailInfoViewCell.h"
#import "YYOpusStyleCell.h"
#import "YYYellowPanelManage.h"
#import "YYShareSeriesView.h"
#import "YYSeriesTagsView.h"
#import "YYTopAlertView.h"

// 接口
#import "YYOpusApi.h"
#import "YYUserApi.h"

// 分类
#import "UIImage+YYImage.h"
#import "NSManagedObject+helper.h"
#import "UIView+UpdateAutoLayoutConstraints.h"

// 自定义类和三方类（ cocoapods类 > model > 工具类 > 其他）
#import <MJRefresh.h>

#import "YYBrandSeriesToCartTempModel.h"
#import "YYOpusSeriesModel.h"
#import "Series.h"
#import "YYSeriesInfoModel.h"
#import "YYOrderInfoModel.h"
#import "StyleColors.h"
#import "YYUser.h"
#import "StyleDetail.h"
#import "StyleDeatilSizes.h"
#import "StyleDetailColors.h"
#import "StyleDetailColorImages.h"
#import "StyleDateRange.h"
#import "YYUserHomePageModel.h"
#import "YYStylesAndTotalPriceModel.h"

#import "AppDelegate.h"
#import "StyleSummary.h"
#import "regular.h"
#import "YYVerifyTool.h"
#import "UserDefaultsMacro.h"

static CGFloat searchFieldWidthDefaultConstraint = 45;
static CGFloat searchFieldWidthMaxConstraint = 200;

@interface YYStyleDetailListViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UITextFieldDelegate,UIScrollViewDelegate,YYTableCellDelegate>

@property (weak, nonatomic) IBOutlet UIButton *gobackButton;
@property (weak, nonatomic) IBOutlet UIButton *gobackButton2;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (weak, nonatomic) IBOutlet UITextField *searchField;
@property (weak, nonatomic) IBOutlet YYTopBarShoppingCarButton *topBarShoppingCarButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchFieldWidthConstraint;
@property (nonatomic,strong) UIView *noDataView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *collectionLayoutTopConstraints;//30
@property (weak, nonatomic) IBOutlet UIView *buyerTipView;
@property (weak, nonatomic) IBOutlet UIButton *backTopBtn;

@property (nonatomic,strong) NSMutableArray *onlineOpusStyleArray;
@property (nonatomic,strong) NSMutableArray *offlineOpusStyleArray;
@property (nonatomic,strong) NSMutableArray *cachedOpusStyleArray;
@property (nonatomic,strong) YYPageInfoModel *currentPageInfo;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchBtnRightLayout;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *splitViewRightLayout;

//修改订单
@property (nonatomic, strong) UIView *seriesview;
@property (nonatomic, strong) UIButton *allSeriesBtn;
@property (nonatomic, strong) UIScrollView *scrollV;
@property (nonatomic, strong) NSMutableArray *online_opusSeriesArray;//修改订单时用
@property (nonatomic, strong) NSMutableArray *cache_opusSeriesArray;//修改订单时用
@property (nonatomic, strong) NSMutableArray *offline_opusSeriesArray;//修改订单时用

@property(nonatomic,strong) YYStylesAndTotalPriceModel *stylesAndTotalPriceModel;//总数
//查询结果
@property (nonatomic) BOOL searchFlag;
@property (nonatomic,strong) NSMutableArray *searchResultArray;
@property (nonatomic,strong) YYPageInfoModel *currentSearchPageInfo;

//排序方式
@property (nonatomic,strong) NSString *sortType;
//过滤时间波段
@property (nonatomic,assign) NSInteger dateRangIndex;// -1 没过滤
@property (nonatomic,strong) NSMutableArray *filterResultArray;

@property (assign, nonatomic) NSInteger selectTaxType;


@property(nonatomic,strong) YYSeriesInfoDetailModel *seriesInfoDetailModel;
@property (nonatomic,assign) float tmpTopCellheight;

@property (nonatomic,strong) YYUserHomePageModel *homePageMode;
@property (nonatomic,strong) YYShareSeriesView *shareSeriesView;

@property (nonatomic,assign) BOOL haveGetMuCurrency;
@property (nonatomic,assign) BOOL isMuCurrency;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic, assign) BOOL isSelect;

@property (nonatomic, strong) NSMutableArray *intentionStyleArray;//意向单临时存储

@end

@implementation YYStyleDetailListViewController
#pragma mark - --------------生命周期--------------
- (void)viewDidLoad {
    [super viewDidLoad];
    [self SomePrepare];
    [self UIConfig];
    [self RequestData];
    NSLog(@"111");
}
//在视图出现的时候更新购物车数据
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self updateShoppingCar];
    // 进入埋点
    [MobClick beginLogPageView:kYYPageStyleDetailList];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    // 退出埋点
    [MobClick endLogPageView:kYYPageStyleDetailList];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}
#pragma mark - --------------SomePrepare--------------
- (void)SomePrepare
{
    [self PrepareData];
    [self PrepareUI];
}
- (void)PrepareData{
    _haveGetMuCurrency = NO;
    _isMuCurrency = NO;
    _isSelect = NO;

    self.onlineOpusStyleArray = [[NSMutableArray alloc] initWithCapacity:0];
    self.cachedOpusStyleArray = [[NSMutableArray alloc] initWithCapacity:0];
    self.offlineOpusStyleArray = [[NSMutableArray alloc] initWithCapacity:0];

    self.intentionStyleArray = [[NSMutableArray alloc] init];

    _sortType = kSORT_STYLE_CODE_DESC;
    _dateRangIndex = -1;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateShoppingCarNotification:) name:kUpdateShoppingCarNotification object:nil];
}
- (void)PrepareUI{
    if(_isModifyOrder){
        _shareButton.hidden = YES;
        _searchBtnRightLayout.constant = 87;
        _splitViewRightLayout.constant = 87;
    }else{
        _shareButton.hidden = NO;
        _searchBtnRightLayout.constant = 157;
        _splitViewRightLayout.constant = 157;
    }

    self.collectionView.alwaysBounceVertical = YES;
    self.backTopBtn.hidden = YES;
    UIView *superView = self.view;

    UIView *tempView = [[UIView alloc] init];
    tempView.backgroundColor = [UIColor whiteColor];
    superView.backgroundColor = [UIColor clearColor];
    [superView insertSubview:tempView atIndex:0];
    __weak UIView *_weakView = superView;
    [tempView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_weakView.mas_top).with.offset(20);
        make.left.equalTo(_weakView.mas_left);
        make.bottom.equalTo(_weakView.mas_bottom);
        make.right.equalTo(_weakView.mas_right);
    }];


    [_gobackButton2 setTitle:NSLocalizedString(@"作品浏览",nil) forState:UIControlStateNormal];
    
    _searchField.alpha = 0.0;
    _searchFieldWidthConstraint.constant = searchFieldWidthDefaultConstraint;
    _searchField.layer.borderColor = [UIColor blackColor].CGColor;
    _searchField.layer.borderWidth = 1;
    _searchField.layer.cornerRadius = 15;
    _searchField.clearButtonMode = UITextFieldViewModeAlways;
    _searchField.returnKeyType = UIReturnKeySearch;
    _searchField.enablesReturnKeyAutomatically = YES;
    _searchField.delegate = self;

    if (_searchField.alpha == 0.0) {
        _searchField.alpha = 1.0;
        _searchField.transform = CGAffineTransformMakeScale(1.00f, 1.00f);
        _searchButton.alpha = 0.0;
        if(SYSTEM_VERSION_LESS_THAN(@"8.0")){
            //_searchButton.transform = CGAffineTransformMakeScale(1.00f, 1.00);
        }else{
            _searchButton.transform = CGAffineTransformMakeScale(0.01f, 0.01f);
        }
        _searchFieldWidthConstraint.constant = searchFieldWidthMaxConstraint;
        _searchField.placeholder = NSLocalizedString(@"输入款式名称/款号/颜色搜索",nil);

        [_searchField layoutIfNeeded];
    }

    UIImage *image = [UIImage imageNamed:@"goBack_normal"];
    [_gobackButton setImage:[image imageByApplyingAlpha:0.6] forState:UIControlStateHighlighted];

    [self.topBarShoppingCarButton initButton];

    self.noDataView = addNoDataView_pad(self.view,[NSString stringWithFormat:@"%@|icon",NSLocalizedString(@"暂无款式",nil)],nil,nil);
    self.noDataView.hidden = YES;

    if (self.orderDueCompareResult == NSOrderedAscending) {
        [YYToast showToastWithTitle:[NSString stringWithFormat:@"%@\n%@",NSLocalizedString(@"此系列已过最晚下单日期，不能下单。",nil),NSLocalizedString(@"可登录Web端YCO System修改最晚下单日期。",nil)] andDuration:kAlertToastDuration];
    }
}

#pragma mark - --------------UIConfig----------------------
-(void)UIConfig{
    [self updateUI];
    [self addHeader];
    [self addFooter];
}
-(void)CreateOrUpdateShareView{
    if(_homePageMode){
        if(!_shareSeriesView){
            WeakSelf(ws);
            _shareSeriesView = [[YYShareSeriesView alloc] init];
            [self.view addSubview:_shareSeriesView];
            [_shareSeriesView setBlockEdit:^{
                NSLog(@"Edit");
                //跳转信息修改界面
                [ws editInfoAction];
            }];
            [_shareSeriesView setBlockHide:^{
                NSLog(@"Hide");
                ws.shareSeriesView.hidden = YES;
                [regular dismissKeyborad];
            }];
            [_shareSeriesView setBlockSend:^{
                NSLog(@"Send");
                //发送过去吧
                [ws SendShareAction];
                [regular dismissKeyborad];
            }];
            [_shareSeriesView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.mas_equalTo(self.view);
            }];
        }
        _shareSeriesView.homePageModel = _homePageMode;
        _shareSeriesView.hidden = NO;
    }
}
- (void)addHeader{
    WeakSelf(ws);
    // 添加下拉刷新头部控件
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        // 进入刷新状态就会回调这个Block

        if ([YYNetworkReachability connectedToNetwork]){
            if(ws.searchResultArray == nil){
                [ws loadStyleListByPageIndex:1 queryStr:@""];
            }else{
                if(![ws.searchField.text isEqualToString:@""]){
                    [ws loadStyleListByPageIndex:1 queryStr:ws.searchField.text];
                }
            }
        }else{
            [ws.collectionView.mj_header endRefreshing];
            [YYToast showToastWithTitle:kNetworkIsOfflineTips andDuration:kAlertToastDuration];
        }
    }];
    self.collectionView.mj_header = header;
    self.collectionView.mj_header.automaticallyChangeAlpha = YES;
    header.lastUpdatedTimeLabel.hidden = YES;
}

- (void)addFooter{
    WeakSelf(ws);
    // 添加上拉刷新尾部控件
    self.collectionView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        // 进入刷新状态就会回调这个Block

        if (![YYNetworkReachability connectedToNetwork]) {
            [YYToast showToastWithTitle:kNetworkIsOfflineTips andDuration:kAlertToastDuration];
            [ws.collectionView.mj_footer endRefreshing];
            return;
        }

        if(ws.searchResultArray == nil){
            if( [ws.onlineOpusStyleArray count] > 0 && ws.currentPageInfo
               && !ws.currentPageInfo.isLastPage){
                [ws loadStyleListByPageIndex:[ws.currentPageInfo.pageIndex intValue]+1 queryStr:@""];
                return;
            }
        }else if(![ws.searchField.text isEqualToString:@""] && [ws.searchResultArray count] > 0 && ws.currentSearchPageInfo
                 && !ws.currentSearchPageInfo.isLastPage){
            [ws loadStyleListByPageIndex:[ws.currentSearchPageInfo.pageIndex intValue]+1 queryStr:ws.searchField.text];
            return;
        }

        [ws.collectionView.mj_footer endRefreshing];
    }];
}

#pragma mark - --------------请求数据----------------------
-(void)RequestData{
    [self getHomePageBrandInfo];

    if (self.isModifyOrder) {
        //修改订单的时候添加款式
        self.searchButton.hidden = NO;
        self.online_opusSeriesArray = [[NSMutableArray alloc] initWithCapacity:0];
        self.cache_opusSeriesArray = [[NSMutableArray alloc] initWithCapacity:0];
        self.offline_opusSeriesArray = [[NSMutableArray alloc] initWithCapacity:0];

        [self.topBarShoppingCarButton hideByWidth:YES];
        //修改NavigatioBar为订单修改所需样式
        [self updateNavUI];
        self.collectionLayoutTopConstraints.constant = 0;
        self.buyerTipView.hidden = YES;
        [self loadSeriesListForModifyOrder];
    }else{
        //正常浏览作品款式
        self.collectionLayoutTopConstraints.constant = 0;
        self.buyerTipView.hidden = YES;
        self.searchButton.hidden = NO;
        [self.topBarShoppingCarButton hideByWidth:NO];
        if ([self readOfflineSeriesDataIsSuccess]) {
            NSLog(@"111");
        }else{
            if (![YYNetworkReachability connectedToNetwork]) {
                //如果网络不通的，取本地数据库缓存的数据
                [self fetchStyleSummaryEntitys];
                [self fetchSeriesEntitys];
                [self fetchSeriesDateRangEntitys];
                NSLog(@"1111");
            }else{
                [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                [self loadStyleListByPageIndex:1 queryStr:@""];
                [self loadSeriesDetailInfo];

            }
        }

    }
}
-(void)getHomePageBrandInfo{
    if ([YYNetworkReachability connectedToNetwork]) {
        WeakSelf(ws);
        [YYUserApi getHomePageBrandInfoWithBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYUserHomePageModel *homePageModel, NSError *error) {
            if(rspStatusAndMessage.status == kCode100){
                ws.homePageMode = homePageModel;
            }
        }];
    }
}
//在线请求所有系列
- (void)loadOnlineAllSeries{
    WeakSelf(ws);
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    YYUser *user = [YYUser currentUser];
    [YYOpusApi getSeriesListWithId:[user.userId intValue] pageIndex:1 pageSize:20 withDraft:@"false" andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYOpusSeriesListModel *opusSeriesListModel, NSError *error) {
        if (rspStatusAndMessage.status == kCode100
            && opusSeriesListModel.result
            && [opusSeriesListModel.result count] > 0) {

            [ws.online_opusSeriesArray addObjectsFromArray:opusSeriesListModel.result];

            ws.opusSeriesModel = ws.online_opusSeriesArray[0];
            ws.seriesId = [ws.opusSeriesModel.id longValue];
            [self updateNavUI];
            [ws loadStyleListByPageIndex:1 queryStr:@""];
        }else{
            [MBProgressHUD hideAllHUDsForView:ws.view animated:YES];
        }
    }];
}

-(void)loadSeriesDetailInfo{
    WeakSelf(ws);
    [YYOpusApi getSeriesInfo:_seriesId andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYSeriesInfoDetailModel *infoDetailModel, NSError *error) {
        if (rspStatusAndMessage.status == kCode100){
            ws.seriesInfoDetailModel = infoDetailModel;
            [ws insertObjectToDbFromSeriesModel:infoDetailModel];
            [ws insertDateRangToDbFromArray:infoDetailModel.dateRanges];
            [ws.collectionView reloadData];
        }
    }];
}
- (void)loadStyleListByPageIndex:(int)pageIndex queryStr:(NSString*)str{
    WeakSelf(ws);
    [YYOpusApi getStyleListWithDesignerId:_designerId seriesId:_seriesId orderBy:_sortType queryStr:str pageIndex:pageIndex pageSize:kPageSize andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYOpusStyleListModel *opusStyleListModel, NSError *error) {
        if (rspStatusAndMessage.status == kCode100
            && opusStyleListModel.result
            && [opusStyleListModel.result count] > 0) {
            if(ws.searchResultArray == nil){
                [ws.cachedOpusStyleArray removeAllObjects];//不共存
                [ws.offlineOpusStyleArray removeAllObjects];//不共存

                if (pageIndex == 1) {
                    [ws.onlineOpusStyleArray removeAllObjects];
                }
                ws.currentPageInfo = opusStyleListModel.pageInfo;

                [ws.onlineOpusStyleArray addObjectsFromArray:opusStyleListModel.result];

                [ws insertObjectToDbFromArray:opusStyleListModel.result];
            }else{
                if (pageIndex == 1) {
                    [ws.searchResultArray removeAllObjects];
                }
                ws.currentSearchPageInfo = opusStyleListModel.pageInfo;

                [ws.searchResultArray addObjectsFromArray:opusStyleListModel.result];
            }
        }

        [MBProgressHUD hideAllHUDsForView:ws.view animated:YES];

        if (rspStatusAndMessage.status != kCode100) {
            [YYToast showToastWithTitle:rspStatusAndMessage.message  andDuration:kAlertToastDuration];
        }

        [ws reloadCollectionViewData];
    }];
}

- (void)getStyleDetailInfoByStyleId:(long)styleId successed:(void (^) (YYStyleInfoModel *styleInfoModel))successBlock {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    WeakSelf(ws);
    [YYOpusApi getStyleInfoByStyleId:styleId orderCode:nil andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYStyleInfoModel *styleInfoModel, NSError *error) {
        [MBProgressHUD hideHUDForView:ws.view animated:YES];
        if (!error && rspStatusAndMessage.status == kCode100) {
            if (successBlock) {
                successBlock(styleInfoModel);
            }
        }
    }];
}

#pragma mark - --------------系统代理----------------------
#pragma mark -UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 2;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if(section == 0){
        return 1;
    }
    NSInteger styleCount = [self checkNullStyle];
    if(styleCount==0){
        return 1;
    }else{
        return styleCount;
    }
}

////定义每个Section 的 margin
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    if (section == 0) {

        return UIEdgeInsetsMake(0, 0, 0, 0);
    }
    if (_seriesInfoDetailModel == nil || self.searchResultArray != nil) {
        return UIEdgeInsetsMake(30, 0, 0, 0);

    }
    return UIEdgeInsetsMake(0, 0, 0, -10);//分别为上、左、下、右
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0){
        if (_seriesInfoDetailModel == nil || self.searchResultArray != nil) {
            return CGSizeMake(CGRectGetWidth(collectionView.frame), 0.1);

        }
        NSInteger cellheight = 247;
        if(true || _seriesInfoDetailModel.dateRanges != nil){
            NSMutableArray *tagArr = [[NSMutableArray alloc] init];
            for (YYDateRangeModel *dateRang in _seriesInfoDetailModel.dateRanges) {
                [tagArr addObject:[dateRang getShowStr]];
            }
            float viewHeight = [YYSeriesTagsView viewHeight:tagArr viewWidth:SCREEN_WIDTH-250-60-80];
            if(viewHeight > 82){
                cellheight = cellheight + viewHeight-82;
            }
        }

        _tmpTopCellheight = cellheight;
        return CGSizeMake(SCREEN_WIDTH-80, cellheight);
    }
    if([self checkNullStyle] > 0){
        return CGSizeMake(211, 333);
    }else{
        if (_seriesInfoDetailModel == nil || self.searchResultArray != nil) {
            return  CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT - 80);

        }
        return CGSizeMake(SCREEN_WIDTH, 260);
    }
}
-(void)setSelectedTagWithValue:(NSString *)value{
    NSArray *infoArr = [value componentsSeparatedByString:@"|"];
    NSInteger index = [[infoArr objectAtIndex:0] integerValue];
    NSInteger isSelect = [[infoArr objectAtIndex:1] integerValue];
    if(isSelect){
        self.dateRangIndex = index;
    }else{
        self.dateRangIndex = -1;
    }

    [self filterDateRangType];
}
-(void)setSelectedTaxTagWithValue:(NSString *)value{
    NSArray *infoArr = [value componentsSeparatedByString:@"|"];
    NSInteger index = [[infoArr objectAtIndex:0] integerValue];
    NSInteger isSelect = [[infoArr objectAtIndex:1] integerValue];
    if(isSelect){
        self.selectTaxType = index;
    }else{
        self.selectTaxType = 0;
    }

    [self.collectionView reloadData];
}
-(void)setSelectButtonClickedWithIsSelectedNow:(BOOL )isSelectedNow{
    if(isSelectedNow){
        self.sortType = kSORT_STYLE_CODE_DESC;
    }else{
        self.sortType = kSORT_STYLE_CODE;
    }
    if(self.filterResultArray !=nil){
        NSSortDescriptor* sortByA = nil;
        if([self.filterResultArray count] > 0){
            if(![[self.filterResultArray objectAtIndex:0] isKindOfClass:[StyleSummary class]]){
                sortByA = [NSSortDescriptor sortDescriptorWithKey:@"styleCode" ascending:!isSelectedNow];
            }else{
                sortByA = [NSSortDescriptor sortDescriptorWithKey:@"style_code" ascending:!isSelectedNow];
            }
            [self.filterResultArray sortUsingDescriptors:[NSArray arrayWithObject:sortByA]];
            [self.collectionView reloadData];
        }
    }else if([self.offlineOpusStyleArray count] >0){
        NSSortDescriptor* sortByA = [NSSortDescriptor sortDescriptorWithKey:@"styleCode" ascending:!isSelectedNow];
        [self.offlineOpusStyleArray sortUsingDescriptors:[NSArray arrayWithObject:sortByA]];
        [self.collectionView reloadData];
    }else if([self.cachedOpusStyleArray count]>0){
        NSSortDescriptor* sortByA = [NSSortDescriptor sortDescriptorWithKey:@"style_code" ascending:!isSelectedNow];
        [self.cachedOpusStyleArray sortUsingDescriptors:[NSArray arrayWithObject:sortByA]];
        [self.collectionView reloadData];
    }else{
        [self.collectionView.mj_header beginRefreshing];
    }
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0){
        static NSString* reuseIdentifier =@"YYSeriesDetailInfoViewCell";
        YYSeriesDetailInfoViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
        if(_seriesInfoDetailModel && self.searchResultArray == nil){
            cell.seriesInfoDetailModel = _seriesInfoDetailModel;
        }else{
            cell.seriesInfoDetailModel = nil;
        }
        cell.orderDueCompareResult = _orderDueCompareResult;
        cell.dateRangIndex = _dateRangIndex;
        cell.selectTaxType = _selectTaxType;
        cell.sortType = _sortType;
        cell.isSelect = _isSelect;
        cell.delegate = self;
        cell.indexPath = indexPath;
        cell.selectCount = _intentionStyleArray.count;

        WeakSelf(ws);
        [cell setSelectedTagValue:^(NSString *value){
            [ws setSelectedTagWithValue:value];
        }];
        [cell setSelectedTaxTagValue:^(NSString *value){
            [ws setSelectedTaxTagWithValue:value];
        }];
        [cell setShowSeriesInfo:^(BOOL isSelectedNow){
            [[YYYellowPanelManage instance ] showSeriesInfoDetailViewWidthParentView:ws.view info:ws.seriesInfoDetailModel andCallBack:nil];
        }];
        [cell setSelectButtonClicked:^(BOOL isSelectedNow){
            [ws setSelectButtonClickedWithIsSelectedNow:isSelectedNow];
        }];
        [cell updateUI];
        return cell;
    }

    if([self checkNullStyle] > 0){
        static NSString* reuseIdentifier = @"YYOpusStyleCell";
        YYOpusStyleCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
        YYOpusStyleModel *opusStyleModel = [self getOpusStyleModelWithIndexPath:indexPath];
        cell.opusStyleModel = opusStyleModel;
        cell.isModifyOrder = _isModifyOrder;
        cell.isSelect = _isSelect;
        cell.opusStyleIsSelect = [self opusStyleIsSelect:opusStyleModel];
        cell.selectTaxType = _selectTaxType;
        cell.delegate = self;
        cell.indexPath = indexPath;
        [cell updateUI];
        return cell;
    }else{
        static NSString* reuseIdentifier = @"YYStyleViewNullCell";
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
        self.noDataView = addNoDataView_pad(cell.contentView,[NSString stringWithFormat:@"%@|icon",NSLocalizedString(@"暂无款式",nil)],nil,nil);
        return cell;
    }
}
-(BOOL )opusStyleIsSelect:(YYOpusStyleModel *)opusStyleModel{
    BOOL isexit = NO;
    for (YYBrandSeriesToCartTempModel *brandSeriesToCardTempModel in _intentionStyleArray) {
        //遍历看看有没有
        if([brandSeriesToCardTempModel.styleInfoModel.style.id integerValue] == [opusStyleModel.id integerValue]){
            isexit = YES;
        }
    }
    return isexit;
}
- (YYOpusStyleModel *)getOpusStyleModelWithIndexPath:(NSIndexPath *)indexPath{
    YYOpusStyleModel *opusStyleModel = nil;
    if([self checkNullStyle] > 0){
        if(_searchResultArray != nil || _filterResultArray != nil){
            NSMutableArray *resultArray = (_searchResultArray!= nil?_searchResultArray:_filterResultArray);
            if(![[resultArray objectAtIndex:indexPath.row] isKindOfClass:[StyleSummary class]]){
                opusStyleModel =[resultArray objectAtIndex:indexPath.row];
            }else{
                StyleSummary *styleSummary = [resultArray objectAtIndex:indexPath.row];
                opusStyleModel = [styleSummary toOpusStyleModel];
                NSLog(@"111");
            }
        }else if ([_offlineOpusStyleArray count] > indexPath.row || [_onlineOpusStyleArray count] > indexPath.row) {

            if ([_offlineOpusStyleArray count] > 0) {
                opusStyleModel = [_offlineOpusStyleArray objectAtIndex:indexPath.row];
            }else if([_onlineOpusStyleArray count] > 0){
                opusStyleModel = [_onlineOpusStyleArray objectAtIndex:indexPath.row];
            }
        }else if ([_cachedOpusStyleArray count] > 0){

            StyleSummary *styleSummary = [_cachedOpusStyleArray objectAtIndex:indexPath.row];
            opusStyleModel = [styleSummary toOpusStyleModel];
            NSLog(@"111");
        }
    }
    return opusStyleModel;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0){
        return;
    }
    if (!self.isModifyOrder && [self checkNullStyle] > 0 && !_isSelect) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Opus" bundle:[NSBundle mainBundle]];

        YYStyleDetailViewController *styleDetailViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYStyleDetailViewController"];
        styleDetailViewController.currentIndex = indexPath.row;
        if(_searchResultArray != nil){
            if(self.currentSearchPageInfo == nil){
                styleDetailViewController.totalPages = [self.searchResultArray count];
            }else{
                styleDetailViewController.totalPages = [self.currentSearchPageInfo.recordTotalAmount integerValue];
            }
            styleDetailViewController.opusSeriesModel = self.opusSeriesModel;
            if ([_offlineOpusStyleArray count] > 0) {
                styleDetailViewController.onlineOrOfflineOpusStyleArray = self.searchResultArray;
                styleDetailViewController.currentDataReadType = DataReadTypeOffline;
            }else if([self.cachedOpusStyleArray count]>0){
                styleDetailViewController.cachedOpusStyleArray = self.searchResultArray;
                styleDetailViewController.currentDataReadType = DataReadTypeCached;
            }else{
                styleDetailViewController.onlineOrOfflineOpusStyleArray = self.searchResultArray;
                styleDetailViewController.currentDataReadType = DataReadTypeOnline;
            }
        }else if(_filterResultArray != nil){

            styleDetailViewController.totalPages = [self.filterResultArray count];
            styleDetailViewController.opusSeriesModel = self.opusSeriesModel;
            if ([_offlineOpusStyleArray count] > 0) {
                styleDetailViewController.onlineOrOfflineOpusStyleArray = self.filterResultArray;
                styleDetailViewController.currentDataReadType = DataReadTypeOffline;
            }else if([self.cachedOpusStyleArray count]>0){
                styleDetailViewController.cachedOpusStyleArray = self.filterResultArray;
                styleDetailViewController.currentDataReadType = DataReadTypeCached;
            }else{
                styleDetailViewController.onlineOrOfflineOpusStyleArray = self.filterResultArray;
                styleDetailViewController.currentDataReadType = DataReadTypeOnline;
            }
        }else if ([_offlineOpusStyleArray count] > 0) {
            styleDetailViewController.onlineOrOfflineOpusStyleArray = self.offlineOpusStyleArray;
            styleDetailViewController.totalPages = [self.offlineOpusStyleArray count];
            styleDetailViewController.opusSeriesModel = self.opusSeriesModel;
            styleDetailViewController.currentDataReadType = DataReadTypeOffline;

        }else if([_onlineOpusStyleArray count] > 0){
            styleDetailViewController.onlineOrOfflineOpusStyleArray = self.onlineOpusStyleArray;
            styleDetailViewController.totalPages = [self.currentPageInfo.recordTotalAmount integerValue];
            styleDetailViewController.opusSeriesModel = self.opusSeriesModel;
            styleDetailViewController.currentDataReadType = DataReadTypeOnline;

        }else if ([_cachedOpusStyleArray count] > 0){
            styleDetailViewController.cachedOpusStyleArray = self.cachedOpusStyleArray;
            styleDetailViewController.totalPages = [self.cachedOpusStyleArray count];
            styleDetailViewController.series = self.series;
            styleDetailViewController.currentDataReadType = DataReadTypeCached;

        }
        styleDetailViewController.selectTaxType = _selectTaxType;
        [self.navigationController pushViewController:styleDetailViewController animated:YES];
    }
}
#pragma mark -UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    return YES ;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if ([textField isFirstResponder]) {
        _searchFlag = YES;
        [textField resignFirstResponder];
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{

    if(_searchFlag){
        //NSLog(@"textFieldDidEndEditing.....");
        _searchFlag = NO;
        self.searchResultArray = [[NSMutableArray alloc] init];
        _currentSearchPageInfo = nil;
        if(![textField.text isEqualToString:@""]){
            if([self.offlineOpusStyleArray count] >0){
                for (YYOpusStyleModel *stylemodel in self.offlineOpusStyleArray) {
                    if([[stylemodel.name uppercaseString] containsString:[textField.text uppercaseString]] || [[stylemodel.styleCode uppercaseString] containsString:[textField.text uppercaseString]]){
                        [self.searchResultArray addObject:stylemodel];
                    }else{
                        for (YYColorModel *colorMode in stylemodel.color) {
                            if([[colorMode.name uppercaseString] containsString:[textField.text uppercaseString]] || [[colorMode.value uppercaseString] containsString:[textField.text uppercaseString]]){
                                [self.searchResultArray addObject:stylemodel];
                            }
                        }
                    }
                }
            }else if([self.cachedOpusStyleArray count]>0){
                for (StyleSummary *stylemodel1 in self.cachedOpusStyleArray) {
                    if([stylemodel1.name containsString:textField.text] || [stylemodel1.style_code containsString:textField.text]){
                        [self.searchResultArray addObject:stylemodel1];
                    }else{
                        for (StyleColors *colorMode in stylemodel1.colors) {
                            if([colorMode.color_name containsString:textField.text] || [colorMode.color_value containsString:textField.text]){
                                [self.searchResultArray addObject:stylemodel1];
                            }
                        }
                    }
                }
            }else{
                [self loadStyleListByPageIndex:1 queryStr:textField.text];
            }
        }
    }else{
        if(![textField.text isEqualToString:@""]){
            textField.text = nil;
        }
        self.searchResultArray = nil;
    }
    [self reloadCollectionViewData];
}
#pragma mark -UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if(_dateRangIndex > -1 && _tmpTopCellheight > 0){
        if(scrollView.contentOffset.y > _tmpTopCellheight && self.titleLabel.alpha == 1){
            YYDateRangeModel *dateRange = [_seriesInfoDetailModel.dateRanges objectAtIndex:_dateRangIndex];
            [UIView animateWithDuration:0.3 animations:^{
                self.titleLabel.alpha = 1.1;
                self.titleLabel.transform = CGAffineTransformMakeScale(1.00f, 0.01f);
            } completion:^(BOOL finished) {
                if(dateRange != nil){
                    self.titleLabel.text = [dateRange getShowStr];
                    self.titleLabel.alpha = 2;
                    self.titleLabel.layer.backgroundColor = [UIColor colorWithHex:@"efefef"].CGColor;
                    self.titleLabel.layer.cornerRadius = 14;
                    self.titleLabel.font = [UIFont systemFontOfSize:14];
                    float titleLabelWidth = [self.titleLabel.text sizeWithAttributes:@{NSFontAttributeName:self.titleLabel.font}].width;
                    [self.titleLabel setConstraintConstant:(titleLabelWidth + 28) forAttribute:NSLayoutAttributeWidth];
                    [UIView animateWithDuration:0.2 animations:^{
                        self.titleLabel.transform = CGAffineTransformMakeScale(1.00f, 1.00f);
                    }];
                }
            }];
        }else if(scrollView.contentOffset.y < _tmpTopCellheight && self.titleLabel.alpha == 2){
            [UIView animateWithDuration:0.3 animations:^{
                self.titleLabel.alpha = 1.1;
                self.titleLabel.transform = CGAffineTransformMakeScale(1.00f, 0.01f);
            } completion:^(BOOL finished) {
                [self updateUI];
                self.titleLabel.alpha = 1;
                self.titleLabel.layer.backgroundColor = [UIColor clearColor].CGColor;
                self.titleLabel.font = [UIFont systemFontOfSize:15];
                [self.titleLabel setConstraintConstant:300 forAttribute:NSLayoutAttributeWidth];
                [UIView animateWithDuration:0.2 animations:^{
                    self.titleLabel.transform = CGAffineTransformMakeScale(1.00f, 1.00f);
                }];
            }];
        }
    }
    if(scrollView.contentOffset.y > (SCREEN_HEIGHT - 70)){
        _backTopBtn.hidden = NO;
    }else{
        _backTopBtn.hidden = YES;
    }
}
#pragma mark - --------------自定义代理/block----------------------
#pragma mark -YYTableCellDelegate
-(void)btnClick:(NSInteger)row section:(NSInteger)section andParmas:(NSArray *)parmas{
    NSString *type = [parmas objectAtIndex:0];
    if([type isEqualToString:@"addToCart"]){
        //加入购物车
        [self addToCart];
    }else if([type isEqualToString:@"cancelAddToCart"]){
        //取消购物车
        [self cancelAddToCart];
    }else if([type isEqualToString:@"sureToAddToCart"]){
        //确认加入
        [self sureToAddToCart];
    }else if([type isEqualToString:@"selectStyle"]){
        //锁定（取消锁定)款式
        YYOpusStyleModel *opusStyleModel = [parmas objectAtIndex:1];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
        [self selectStyleWithIndexPath:indexPath WithOpusStyleModel:opusStyleModel];
    }else if([type isEqualToString:@"addOrder"]){
        UIEvent *event = [parmas objectAtIndex:1];
        [self addStyleToOrderWithEvent:event];
    }
}
//加入购物车
-(void)addToCart{
    if(self.orderDueCompareResult == NSOrderedAscending){
        [YYTopAlertView showWithType:YYTopAlertTypeError text:NSLocalizedString(@"此系列已过最晚下单日期，不能下单。",nil)parentView:self.view];
    }else{
        _isSelect = YES;
        [self reloadCollectionViewData];
    }
}
//取消购物车
-(void)cancelAddToCart{
    _isSelect = NO;
    [self reloadCollectionViewData];
}
//确认加入
-(void)sureToAddToCart{

    //当购物车中无数据时
    //需要判断当前所选款式中否是含多币种
    BOOL isContainMultiCurType = NO;
    if (self.stylesAndTotalPriceModel.totalStyles <= 0) {
        if(_intentionStyleArray.count > 1){
            NSInteger moneyType = -1;
            for (YYBrandSeriesToCartTempModel *brandSeriesToCardTempModel in _intentionStyleArray) {
                if (brandSeriesToCardTempModel) {
                    if(moneyType < 0){
                        moneyType = [brandSeriesToCardTempModel.styleInfoModel.style.curType integerValue];
                    }else{
                        if(moneyType != [brandSeriesToCardTempModel.styleInfoModel.style.curType integerValue]){
                            isContainMultiCurType = YES;
                            break;
                        }
                    }
                }
            }
        }
    }

    if(isContainMultiCurType){
        [YYToast showToastWithView:self.view title:NSLocalizedString(@"不同币种的款式不能同时加入购物车",nil) andDuration:kAlertToastDuration];
        return;
    }

    //遍历 加入购物车
    for (YYBrandSeriesToCartTempModel *brandSeriesToCardTempModel in _intentionStyleArray) {
        [self addToLocalCartWithTempModel:brandSeriesToCardTempModel];
        NSLog(@"1111");
    }
    //发出通知，更新购物车图标
    [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateShoppingCarNotification object:nil];
    _isSelect = NO;
    [_intentionStyleArray removeAllObjects];
    [self removeTempIsSelect];
    [self reloadCollectionViewData];
    [YYTopAlertView showWithType:YYTopAlertTypeSuccess text:NSLocalizedString(@"成功加入购物车",nil) parentView:nil];
}
-(void)addToLocalCartWithTempModel:(YYBrandSeriesToCartTempModel *)brandSeriesToCardTempModel{

    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    NSMutableArray *tempSeriesArray = appDelegate.seriesArray;
    if(tempSeriesArray == nil){
        tempSeriesArray = [[NSMutableArray alloc] init];
    }
    YYStyleInfoModel *styleInfoModel = brandSeriesToCardTempModel.styleInfoModel;
    YYOrderInfoModel *tempOrderInfoModel = brandSeriesToCardTempModel.tempOrderInfoModel;
    NSArray *sizeNameArr = brandSeriesToCardTempModel.sizeNameArr;
    NSArray *amountSizeArr = brandSeriesToCardTempModel.amountSizeArr;
    BOOL isModifyOrder = brandSeriesToCardTempModel.isModifyOrder;

    NSString *_remark = @"";
    YYDateRangeModel *_tmpDateRange = nil;
    NSString *_tmpRemark = @"";

    YYOrderOneInfoModel *orderOneInfoM = nil;
    if ([tempSeriesArray count] > 0) {
        //已经有系列创建
        //查询是否已经有该系列

        for (YYOrderOneInfoModel *orderOneInfoModel in tempSeriesArray) {
            if((styleInfoModel.dateRange && [styleInfoModel.dateRange.id integerValue] > 0 &&  [orderOneInfoModel.dateRange.id  integerValue] == [styleInfoModel.dateRange.id integerValue]) || ((!styleInfoModel.dateRange || [styleInfoModel.dateRange.id integerValue] == 0) &&(orderOneInfoModel.dateRange == nil || [orderOneInfoModel.dateRange.id  integerValue] == 0))){
                orderOneInfoM = orderOneInfoModel;
                break;
            }
        }

        if (orderOneInfoM) {
            NSArray *arr = orderOneInfoM.styles; //当前系列所有款式
            for (YYOrderStyleModel *style in arr){
                if ([style.styleId intValue] == [styleInfoModel.style.id intValue]) {
                    _remark = style.remark;
                    _tmpDateRange = style.tmpDateRange;
                    _tmpRemark = style.tmpRemark;
                    [orderOneInfoM.styles removeObject:style];
                    break;
                }
            }
        }
    }

    if (!orderOneInfoM) {
        orderOneInfoM = [[YYOrderOneInfoModel alloc] init];
        orderOneInfoM.dateRange = styleInfoModel.dateRange;
        orderOneInfoM.styles = (NSMutableArray<YYOrderStyleModel>*)[[NSMutableArray alloc] init];
        [tempSeriesArray addObject:orderOneInfoM];
    }

    //增加系列队列
    if(_opusSeriesModel){
        if(!tempOrderInfoModel.seriesMap){
            tempOrderInfoModel = [[YYOrderInfoModel alloc] init];
            tempOrderInfoModel.seriesMap = (NSMutableDictionary<YYOrderSeriesModel, Optional,ConvertOnDemand> *)[[NSMutableDictionary alloc] init];
        }
        YYOrderSeriesModel *seriesModel = [[YYOrderSeriesModel alloc] init];
        seriesModel.seriesId = _opusSeriesModel.id;
        seriesModel.name = _opusSeriesModel.name;
        seriesModel.orderAmountMin = _opusSeriesModel.orderAmountMin;// style 有orderAmountMin
        seriesModel.supplyStatus = _opusSeriesModel.supplyStatus;
        [tempOrderInfoModel.seriesMap setObject:seriesModel forKey:[seriesModel.seriesId stringValue]];
    }


    YYOrderStyleModel *orderStyleModel = [[YYOrderStyleModel alloc] init];
    orderStyleModel.styleId = styleInfoModel.style.id;
    orderStyleModel.albumImg = styleInfoModel.style.albumImg;
    orderStyleModel.name = styleInfoModel.style.name;
    orderStyleModel.finalPrice = (styleInfoModel.style.finalPrice !=nil?styleInfoModel.style.finalPrice: styleInfoModel.style.tradePrice);
    orderStyleModel.originalPrice = styleInfoModel.style.tradePrice;
    orderStyleModel.retailPrice = styleInfoModel.style.retailPrice;
    orderStyleModel.orderAmountMin = styleInfoModel.style.orderAmountMin;
    orderStyleModel.styleCode = styleInfoModel.style.styleCode;
    orderStyleModel.styleModifyTime = styleInfoModel.style.modifyTime;
    orderStyleModel.sizeNameList = (NSArray<YYSizeModel, ConvertOnDemand> *) sizeNameArr;
    orderStyleModel.stockEnabled = styleInfoModel.stockEnabled;
    orderStyleModel.colors =(NSArray<YYOrderOneColorModel, ConvertOnDemand> *) amountSizeArr;
    orderStyleModel.curType = styleInfoModel.style.curType;
    orderStyleModel.seriesId = self.opusSeriesModel.id;
    orderStyleModel.supportAdd = styleInfoModel.style.supportAdd;
    orderStyleModel.remark = _remark;
    orderStyleModel.tmpDateRange = _tmpDateRange;
    orderStyleModel.tmpRemark = _remark;

    [orderOneInfoM.styles insertObject:orderStyleModel atIndex:0];


    if (isModifyOrder) {
        //修改订单
        appDelegate.orderModel.groups = (NSMutableArray<YYOrderOneInfoModel> *)tempSeriesArray;
        appDelegate.orderModel.seriesMap = tempOrderInfoModel.seriesMap;
        appDelegate.orderSeriesArray =(NSMutableArray<YYOrderOneInfoModel> *)tempSeriesArray;
    }else{
        //修改购物车
        appDelegate.cartMoneyType = [styleInfoModel.style.curType integerValue];
        //修改购物车
        //组合最终的YYOrderInfoModel模型对象。
        if (appDelegate.cartModel.designerId) {
            appDelegate.cartModel.groups = (NSMutableArray<YYOrderOneInfoModel> *)tempSeriesArray;
            appDelegate.cartModel.seriesMap = tempOrderInfoModel.seriesMap;
            appDelegate.cartModel.stockEnabled = styleInfoModel.stockEnabled;
            appDelegate.seriesArray=(NSMutableArray<YYOrderOneInfoModel> *)tempSeriesArray;
        }else{
            YYOrderInfoModel *orderInfoModel = [[YYOrderInfoModel alloc] init];
            orderInfoModel.stockEnabled = styleInfoModel.stockEnabled;
            orderInfoModel.designerId = _opusSeriesModel.designerId;
            orderInfoModel.orderDescription = nil;
            orderInfoModel.groups = (NSMutableArray<YYOrderOneInfoModel> *)tempSeriesArray;
            orderInfoModel.seriesMap = tempOrderInfoModel.seriesMap;
            appDelegate.cartModel = orderInfoModel;
            appDelegate.seriesArray=(NSMutableArray<YYOrderOneInfoModel> *)tempSeriesArray;
        }

        //重设isColorSelect
        [self resetCartModelWithTempModel:brandSeriesToCardTempModel];

        //储存对象的JSONString
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        NSString *jsonString = appDelegate.cartModel.toJSONString;
        [userDefault setObject:jsonString forKey:KUserCartKey];
        [userDefault setObject:[NSString stringWithFormat:@"%ld",(long)appDelegate.cartMoneyType] forKey:KUserCartMoneyTypeKey];
        [userDefault synchronize];
    }
}
- (void)resetCartModelWithTempModel:(YYBrandSeriesToCartTempModel *)brandSeriesToCardTempModel{

    YYStyleInfoModel *styleInfoModel = brandSeriesToCardTempModel.styleInfoModel;
    BOOL isOnlyColor = [brandSeriesToCardTempModel.isOnlyColor boolValue];
    NSMutableArray *selectColorArr = brandSeriesToCardTempModel.selectColorArr;

    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    for (YYOrderOneInfoModel *orderOneInfoModel in appDelegate.cartModel.groups) {
        for (YYOrderStyleModel *orderStyleModel in orderOneInfoModel.styles) {
            if ([orderStyleModel.styleId intValue] == [styleInfoModel.style.id intValue]) {
                for (YYOrderOneColorModel *orderOneColorModel in orderStyleModel.colors) {
                    if(isOnlyColor){
                        //锁定的情况下清空amout
                        BOOL colorIsSelect = NO;
                        for (NSDictionary *tempDict in selectColorArr) {
                            if([[tempDict objectForKey:@"colorId"] integerValue] == [orderOneColorModel.colorId integerValue]){
                                colorIsSelect = [[tempDict objectForKey:@"colorIsSelect"] boolValue];
                            }
                        }
                        if(colorIsSelect){
                            orderOneColorModel.isColorSelect = @(YES);
                            for (YYOrderSizeModel *orderSizeModel in orderOneColorModel.sizes) {
                                orderSizeModel.amount = @(0);
                            }
                        }else{
                            orderOneColorModel.isColorSelect = @(NO);
                            for (YYOrderSizeModel *orderSizeModel in orderOneColorModel.sizes) {
                                //给他设原来的amout    colorId  sizeId
                                orderSizeModel.amount = [self getOldAmountWithColorId:[orderOneColorModel.colorId integerValue] WithSizeId:[orderSizeModel.sizeId integerValue] WithTempModel:brandSeriesToCardTempModel];
                            }
                        }
                    }else{
                        //如果有数量，则设置为NO，不然保持原样
                        BOOL haveAmount = NO;
                        for (YYOrderSizeModel *orderSizeModel in orderOneColorModel.sizes) {
                            if([orderSizeModel.amount integerValue]){
                                haveAmount = YES;
                            }
                        }

                        if(haveAmount){
                            orderOneColorModel.isColorSelect = @(NO);
                        }
                    }
                }
            }
        }
    }
}
- (NSNumber *)getOldAmountWithColorId:(NSInteger )colorId WithSizeId:(NSInteger )sizeId WithTempModel:(YYBrandSeriesToCartTempModel *)brandSeriesToCardTempModel{

    YYStyleInfoModel *styleInfoModel = brandSeriesToCardTempModel.styleInfoModel;

    YYOrderStyleModel *oldOrderStyleModel = nil;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    for (YYOrderOneInfoModel *orderOneInfoModel in appDelegate.cartModel.groups) {
        for (YYOrderStyleModel *orderStyleModel in orderOneInfoModel.styles) {
            if ([orderStyleModel.styleId intValue] == [styleInfoModel.style.id intValue]) {
                oldOrderStyleModel = orderStyleModel;
            }
        }
    }

    NSInteger returnamount = 0;
    if(oldOrderStyleModel){
        for (YYOrderOneColorModel *orderOneColorModel in oldOrderStyleModel.colors) {
            if([orderOneColorModel.colorId integerValue] == colorId){
                for (YYOrderSizeModel *orderSizeModel in orderOneColorModel.sizes) {
                    if([orderSizeModel.sizeId integerValue] == sizeId){
                        returnamount = [orderSizeModel.amount integerValue];
                    }
                }
            }
        }
    }
    return @(returnamount);
}
-(void)removeTempIsSelect{

    NSMutableArray *tempArr = [[NSMutableArray alloc] init];
    if(_searchResultArray){
        [tempArr addObject:_searchResultArray];
    }
    if(_filterResultArray){
        [tempArr addObject:_filterResultArray];
    }
    if(_offlineOpusStyleArray){
        [tempArr addObject:_offlineOpusStyleArray];
    }
    if(_onlineOpusStyleArray){
        [tempArr addObject:_onlineOpusStyleArray];
    }
    if(_cachedOpusStyleArray){
        [tempArr addObject:_cachedOpusStyleArray];
    }

    for (NSMutableArray *tempDataArr in tempArr) {
        for (id obj in tempDataArr) {
            if([obj isKindOfClass:[StyleSummary class]]){
                StyleSummary *styleSummary = (StyleSummary *)obj;
                //集合也可以用枚举器来遍历
                NSEnumerator * enumerator = [styleSummary.colors objectEnumerator];
                YYColorModel *colorModel = nil;
                while (colorModel = [enumerator nextObject]) {
                    colorModel.isSelect = @(NO);
                }
            }else{
                YYOpusStyleModel *opusStyleModel = (YYOpusStyleModel *)obj;
                for (YYColorModel *colorModel in opusStyleModel.color) {
                    colorModel.isSelect = @(NO);
                }
            }
        }
    }
}
//锁定（取消锁定)款式
-(void)selectStyleWithIndexPath:(NSIndexPath *)indexPath WithOpusStyleModel:(YYOpusStyleModel *)opusStyleModel{
    BOOL isexit = [self opusStyleIsSelect:opusStyleModel];
    if(!isexit){
        //添加
        [self addShoppingCarAction:opusStyleModel];
    }else{
        //删除
        [self removeShoppingCarWithOpusStyleModel:opusStyleModel];
    }
    [self reloadCollectionViewData];
}
-(void)removeShoppingCarWithOpusStyleModel:(YYOpusStyleModel *)opusStyleModel{
    BOOL isExit = NO;
    NSInteger index = 0;
    for (int i=0; i < _intentionStyleArray.count; i++) {
        YYBrandSeriesToCartTempModel *tempBrandSeriesToCardTempModel = _intentionStyleArray[i];
        //遍历看看有没有
        if([tempBrandSeriesToCardTempModel.styleInfoModel.style.id integerValue] == [opusStyleModel.id integerValue]){
            isExit = YES;
            index = i;
        }
    }
    [_intentionStyleArray removeObjectAtIndex:index];
    [self reloadCollectionViewData];
}
- (void)addShoppingCarAction:(YYOpusStyleModel *)opusStyleModel{
    WeakSelf(ws);
    if(_opusSeriesModel){
        if([_opusSeriesModel.status integerValue] == kOpusDraft){
            [YYTopAlertView showWithType:YYTopAlertTypeError text:NSLocalizedString(@"请先发布作品！",nil) parentView:self.view];
            return;
        }
    }else if(_series){
        if([_opusSeriesModel.status integerValue] == kOpusDraft){
            [YYTopAlertView showWithType:YYTopAlertTypeError text:NSLocalizedString(@"请先发布作品！",nil) parentView:self.view];
            return;
        }
    }

    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if ( self.orderDueCompareResult == NSOrderedAscending) {
        [YYTopAlertView showWithType:YYTopAlertTypeError text:NSLocalizedString(@"此系列已过最晚下单日期，不能下单。",nil)parentView:self.view];
        return;
    }
    NSInteger moneyType = -1;
    if (opusStyleModel) {
        moneyType = [opusStyleModel.curType integerValue];
    }

    if(appDelegate.cartModel == nil){
        appDelegate.cartMoneyType = -1;
    }

    if(appDelegate.cartMoneyType > -1 && moneyType != appDelegate.cartMoneyType){
        [YYToast showToastWithView:self.view title:NSLocalizedString(@"购物车中存在其他币种的款式，不能将此款式加入购物车。您可以清空购物车后，将此款式加入购物车。",nil) andDuration:kAlertToastDuration];
        return;
    }
    
    [self getStyleDetailInfoByStyleId:[opusStyleModel.id longValue] successed:^(YYStyleInfoModel *styleInfoModel) {
        [ws showShoppingView:styleInfoModel];
    }];
}
-(void)addStyleToOrderWithEvent:(UIEvent *)event{
    WeakSelf(ws);
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSSet *touchSets = [event allTouches];
    UITouch *touch = [touchSets anyObject];
    CGPoint currentPoint = [touch locationInView:self.collectionView];
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:currentPoint];
    NSInteger moneyType = -1;
    NSInteger orderMoneyType = -1;
    if(appDelegate.orderModel == nil){
        orderMoneyType = -1;
    }else{
        orderMoneyType = [appDelegate.orderModel.curType integerValue];
    }
    if(_searchResultArray != nil && [_searchResultArray count] > indexPath.row){
        YYOpusStyleModel *opusStyleModel = _searchResultArray[indexPath.row];
        moneyType = [opusStyleModel.curType integerValue];

        if(orderMoneyType > -1 && moneyType != orderMoneyType){
            [YYToast showToastWithView:self.view title:NSLocalizedString(@"订单中存在其他币种的款式，不能将此款式加入当前订单。",nil) andDuration:kAlertToastDuration];
            return;
        }

        UIView *superView = self.view;
        [appDelegate showShoppingViewNew:YES styleInfoModel:nil seriesModel:_opusSeriesModel opusStyleModel:opusStyleModel currentYYOrderInfoModel:_currentYYOrderInfoModel parentView:superView fromBrandSeriesView:!_isModifyOrder WithBlock:^(YYBrandSeriesToCartTempModel *brandSeriesToCardTempModel) {
            [ws shoppingViewBlockWithCartTempModel:brandSeriesToCardTempModel];
        }];
    }else if ([self.onlineOpusStyleArray count] > indexPath.row
              || [self.offlineOpusStyleArray count] > indexPath.row) {
        YYOpusStyleModel *opusStyleModel = nil;
        if ([self.onlineOpusStyleArray count] > indexPath.row){
            opusStyleModel = self.onlineOpusStyleArray[indexPath.row];

        }else if ([self.offlineOpusStyleArray count] > indexPath.row) {
            opusStyleModel = self.offlineOpusStyleArray[indexPath.row];
        }
        moneyType = [opusStyleModel.curType integerValue];

        if(orderMoneyType > -1 && moneyType != orderMoneyType){
            [YYToast showToastWithView:self.view title:NSLocalizedString(@"订单中存在其他币种的款式，不能将此款式加入当前订单。",nil) andDuration:kAlertToastDuration];
            return;
        }
        UIView *superView = self.view;
        [appDelegate showShoppingViewNew:YES styleInfoModel:nil seriesModel:_opusSeriesModel opusStyleModel:opusStyleModel currentYYOrderInfoModel:_currentYYOrderInfoModel parentView:superView fromBrandSeriesView:!_isModifyOrder WithBlock:^(YYBrandSeriesToCartTempModel *brandSeriesToCardTempModel) {
            [ws shoppingViewBlockWithCartTempModel:brandSeriesToCardTempModel];
        }];
    }else if ([self.cache_opusSeriesArray count] > 0){
        StyleSummary *styleSummary = [_cachedOpusStyleArray objectAtIndex:indexPath.row];
        NSString *predicate = [NSString stringWithFormat:@"style_id=%i",[styleSummary.style_id intValue]];
        StyleDetail *nowStyleDetail = [StyleDetail one:predicate];
        if (nowStyleDetail) {
            //数据不全，给出提示
            return;
        }
        moneyType = [styleSummary.cur_type integerValue];
        if(orderMoneyType > -1 && moneyType != orderMoneyType){
            [YYToast showToastWithView:self.view title:NSLocalizedString(@"订单中存在其他币种的款式，不能将此款式加入当前订单。",nil) andDuration:kAlertToastDuration];
            return;
        }

        UIView *superView = self.view;
        [appDelegate showShoppingViewNew:YES styleInfoModel:nowStyleDetail seriesModel:_series opusStyleModel:nil currentYYOrderInfoModel:_currentYYOrderInfoModel parentView:superView fromBrandSeriesView:!_isModifyOrder WithBlock:^(YYBrandSeriesToCartTempModel *brandSeriesToCardTempModel) {
            [ws shoppingViewBlockWithCartTempModel:brandSeriesToCardTempModel];
        }];
    }
}
-(void)shoppingViewBlockWithCartTempModel:(YYBrandSeriesToCartTempModel *)brandSeriesToCardTempModel{
    if(brandSeriesToCardTempModel){

        BOOL isExit = NO;
        NSInteger index = 0;
        for (int i = 0; i < _intentionStyleArray.count; i++) {
            YYBrandSeriesToCartTempModel *tempBrandSeriesToCardTempModel = _intentionStyleArray[i];
            //遍历看看有没有
            if([tempBrandSeriesToCardTempModel.styleInfoModel.style.id integerValue] == [brandSeriesToCardTempModel.styleInfoModel.style.id integerValue]){
                isExit = YES;
                index = i;
            }
        }
        if(isExit){
            [_intentionStyleArray removeObjectAtIndex:index];
        }
        [_intentionStyleArray addObject:brandSeriesToCardTempModel];
        [self reloadCollectionViewData];

    }
}
#pragma mark - --------------自定义响应----------------------
- (IBAction)ShareAction:(id)sender {
    [self hasMultiCurrency];
}
- (IBAction)goBackButtonClicked:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)shoppingCarClicked:(id)sender{
    
    if (self.stylesAndTotalPriceModel.totalStyles <= 0) {
        [YYToast showToastWithView:self.view title:NSLocalizedString(@"购物车暂无数据",nil)  andDuration:kAlertToastDuration];
        return;
    }

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Order" bundle:[NSBundle mainBundle]];
    YYCartDetailViewController *cartVC = [storyboard instantiateViewControllerWithIdentifier:@"YYCartDetailViewController"];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:cartVC];
    nav.navigationBar.hidden = YES;

    WeakSelf(ws);
    [cartVC setGoBackButtonClicked:^(){
        [ws dismissViewControllerAnimated:YES completion:^{
            //刷新购物车图标数据

            AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            ws.stylesAndTotalPriceModel = [appdelegate.cartModel getTotalValueByOrderInfo:NO];
            [ws.topBarShoppingCarButton updateButtonNumber:[NSString stringWithFormat:@"%i", self.stylesAndTotalPriceModel.totalStyles]];

        }];
    }];

    [cartVC setToOrderList:^(){
        [ws dismissViewControllerAnimated:NO completion:^{
            //刷新购物车图标数据

            AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            ws.stylesAndTotalPriceModel = [appdelegate.cartModel getTotalValueByOrderInfo:NO];

            [ws.topBarShoppingCarButton updateButtonNumber:[NSString stringWithFormat:@"%i", self.stylesAndTotalPriceModel.totalStyles]];

            //如果购物车为空了，进入订单列表界面
            [[NSNotificationCenter defaultCenter] postNotificationName:kShowOrderListNotification object:nil];
        }];
    }];

    [self presentViewController:nav animated:YES completion:nil];
}
- (IBAction)backToTop:(id)sender {
    NSIndexPath *index =  [NSIndexPath indexPathForRow:0 inSection:0];
    [self.collectionView scrollToItemAtIndexPath:index atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
}

- (IBAction)searchButtonClicked:(id)sender{
    //    _searchField.text = nil;
    //    if (_searchField.alpha == 0.0) {
    //        _searchField.alpha = 1.0;
    //        _searchField.transform = CGAffineTransformMakeScale(1.00f, 1.00f);
    //        _searchButton.alpha = 0.0;
    //        if(SYSTEM_VERSION_LESS_THAN(@"8.0")){
    //        //_searchButton.transform = CGAffineTransformMakeScale(1.00f, 1.00);
    //        }else{
    //        _searchButton.transform = CGAffineTransformMakeScale(0.01f, 0.01f);
    //        }
    //        _searchFieldWidthConstraint.constant = searchFieldWidthMaxConstraint;
    //        _searchField.placeholder = NSLocalizedString(@"输入款式名称/款号/颜色搜索",nil);
    //
    //        __weak UITextField *weakField = _searchField;
    //        [UIView animateWithDuration:animateDuration animations:^{
    //            [weakField layoutIfNeeded];
    //        } completion:^(BOOL finished) {
    //            [weakField becomeFirstResponder];
    //        }];
    //    }
}
#pragma mark - --------------自定义方法----------------------
- (void)updateUI{
    if (_opusSeriesModel) {
        NSString *seriesTitle = _opusSeriesModel.name;
        if (seriesTitle
            && [seriesTitle length] > 10) {
            seriesTitle = [seriesTitle substringToIndex:10];
        }

        NSString *titleValue = [NSString stringWithFormat:@"%@",seriesTitle];
        _titleLabel.text = titleValue;
    }

    if (_series) {
        NSString *seriesTitle = _series.name;
        if (seriesTitle
            && [seriesTitle length] > 10) {
            seriesTitle = [seriesTitle substringToIndex:10];
        }
        _titleLabel.text = seriesTitle;
    }
}
-(void)hasMultiCurrency{
    if(_haveGetMuCurrency){
        //有获取过
        if(_isMuCurrency){
            //暂不能分享多币种系列
            [YYToast showToastWithTitle:NSLocalizedString(@"暂不能分享多币种系列",nil) andDuration:kAlertToastDuration];
        }else{
            [self CreateOrUpdateShareView];
        }
    }else{
        //获取是否存在多币种
        [YYOpusApi hasMultiCurrencyWithSeriesId:_seriesId andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, BOOL hasMultiCurrency, NSError *error) {
            if((rspStatusAndMessage.status = kCode100)){
                _haveGetMuCurrency = YES;
                _isMuCurrency = hasMultiCurrency;
                //有获取过
                if(_isMuCurrency){
                    //暂不能分享多币种系列
                    [YYToast showToastWithTitle:NSLocalizedString(@"暂不能分享多币种系列",nil) andDuration:kAlertToastDuration];
                }else{
                    [self CreateOrUpdateShareView];
                }
            }else{
                [YYToast showToastWithTitle:rspStatusAndMessage.message andDuration:kAlertToastDuration];
            }
        }];
    }
}
-(void)editInfoAction{
    YYEditMyPageViewController *editMyPage = [[YYEditMyPageViewController alloc] init];
    editMyPage.homePageMode = _homePageMode;
    WeakSelf(ws);
    editMyPage.blockSaveSuccess = ^(NSArray *contactArr) {
        StrongSelf(ws);
        _homePageMode.userContactInfos = contactArr;
        [strongSelf CreateOrUpdateShareView];
    };
    [self.navigationController pushViewController:editMyPage animated:YES];

}
-(void)SendShareAction{
    if(![NSString isNilOrEmpty:_shareSeriesView.emailTextField.text]){
        if([YYVerifyTool emailVerify:_shareSeriesView.emailTextField.text]){
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            NSString *noBlankValue = [_shareSeriesView.emailTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            [YYOpusApi sendlineSheetWithHomePageModel:_homePageMode withSeriesId:_seriesId withEmail:noBlankValue andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSError *error) {
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                _shareSeriesView.hidden = YES;
                _shareSeriesView.emailTextField.text = @"";
                _shareSeriesView.emailTipButton.hidden = YES;
                if((rspStatusAndMessage.status = kCode100)){
                    [YYToast showToastWithTitle:NSLocalizedString(@"发送成功！", @"") andDuration:kAlertToastDuration];
                }else{
                    [YYToast showToastWithTitle:rspStatusAndMessage.message andDuration:kAlertToastDuration];
                }

            }];
        }
    }
}

//读取离线下载的系列列表
- (void)loadOfflineSeriesArray{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *offlineFileDir = yyjOfflineSeriesDirectory();
    NSArray *files = [fileManager contentsOfDirectoryAtPath:offlineFileDir error:nil];
    if (files) {
        for (NSString *fileName in files) {
            NSString *offlineFilePath = [yyjOfflineSeriesDirectory() stringByAppendingPathComponent:fileName];
            NSString *path = [offlineFilePath stringByAppendingPathComponent:@"series.json"];

            if (path
                && [fileManager fileExistsAtPath:path]) {
                NSData *data = [NSData dataWithContentsOfFile:path];

                if (data) {

                    NSError* error;
                    NSDictionary* json = [NSJSONSerialization
                                          JSONObjectWithData:data
                                          options:NSJSONReadingAllowFragments
                                          error:&error];
                    if (json) {
                        YYOpusSeriesModel *opusSeriesModel = [[YYOpusSeriesModel alloc] initWithDictionary:json error:nil];
                        [self.offline_opusSeriesArray addObject:opusSeriesModel];
                    }

                }

            }

        }
    }
    if ([self.offline_opusSeriesArray count] > 0) {
        self.opusSeriesModel = self.offline_opusSeriesArray[0];
        [self updateNavUI];
        self.seriesId = [_opusSeriesModel.id longValue];
        self.designerId = [_opusSeriesModel.designerId longValue];
        if ([self readOfflineSeriesDataIsSuccess]) {
            [self reloadCollectionViewData];
        };
    }
}

//加载系列系列，用于修改订单时添加款式
- (void)loadSeriesListForModifyOrder{
    if ([YYNetworkReachability connectedToNetwork]) {
        [self loadOnlineAllSeries];
    }else{
        [self loadOfflineSeriesArray];
        if([self.offline_opusSeriesArray count] == 0){
            [self loadCachedAllSeries];
        }
    }
}

//读取离线下载的系列数据
- (BOOL)readOfflineSeriesDataIsSuccess{
    //读取本地的离线数据
    NSString *folderName = [NSString stringWithFormat:@"%li",_seriesId];
    NSString *offlineFilePath = [yyjOfflineSeriesDirectory() stringByAppendingPathComponent:folderName];
    NSString *styleListJsonPath = [offlineFilePath stringByAppendingPathComponent:@"styleList.json"];

    BOOL readOfflineDataSuccess = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:styleListJsonPath]) {
        NSData *data = [NSData dataWithContentsOfFile:styleListJsonPath];

        if (data) {

            NSError* error;
            NSDictionary* json = [NSJSONSerialization
                                  JSONObjectWithData:data
                                  options:NSJSONReadingAllowFragments
                                  error:&error];
            if (json) {
                YYOpusStyleListModel *opusStyleListModel = [[YYOpusStyleListModel alloc] initWithDictionary:json error:nil];
                if (opusStyleListModel) {
                    [self.offlineOpusStyleArray removeAllObjects];
                    [self.offlineOpusStyleArray addObjectsFromArray:opusStyleListModel.result];
                    readOfflineDataSuccess = YES;

                    [self.cachedOpusStyleArray removeAllObjects];//离线的和缓存的不共存
                    [self.onlineOpusStyleArray removeAllObjects];//离线的和在线的不共存
                    self.currentPageInfo = nil;
                }
                NSString *seriesJsonPath = [offlineFilePath stringByAppendingPathComponent:@"series.json"];
                [self loadOfflineSeriesByPath:seriesJsonPath];
            }
        }
    }
    [self reloadCollectionViewData];
    return readOfflineDataSuccess;
}

//读取离线下载的系列信息
- (void)loadOfflineSeriesByPath:(NSString *)path{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (path
        && [fileManager fileExistsAtPath:path]) {
        NSData *data = [NSData dataWithContentsOfFile:path];

        if (data) {
            NSError* error;
            NSDictionary* json = [NSJSONSerialization
                                  JSONObjectWithData:data
                                  options:NSJSONReadingAllowFragments
                                  error:&error];
            if (json) {
                YYOpusSeriesModel *opusSeriesModel = [[YYOpusSeriesModel alloc] initWithDictionary:json error:nil];
                if (opusSeriesModel) {
                    self.opusSeriesModel = opusSeriesModel;
                    self.seriesInfoDetailModel = [[YYSeriesInfoDetailModel alloc] init];
                    self.seriesInfoDetailModel.series = [[YYSeriesInfoModel alloc] init];
                    self.seriesInfoDetailModel.series.id = opusSeriesModel.id;
                    self.seriesInfoDetailModel.series.name = opusSeriesModel.name;
                    self.seriesInfoDetailModel.series.styleAmount = opusSeriesModel.styleAmount;
                    self.seriesInfoDetailModel.series.season = opusSeriesModel.season;
                    self.seriesInfoDetailModel.series.supplyStartTime =  opusSeriesModel.supplyStartTime;               self.seriesInfoDetailModel.series.supplyEndTime = opusSeriesModel.supplyEndTime;
                    self.seriesInfoDetailModel.series.orderDueTime=opusSeriesModel.orderDueTime;
                    self.seriesInfoDetailModel.brandDescription =  [json objectForKey:@"description"];//opusSeriesModel.description;
                    self.seriesInfoDetailModel.lookBookId = opusSeriesModel.lookBookId;
                    self.seriesInfoDetailModel.dateRanges = opusSeriesModel.dateRanges;
                }
            }

        }

    }
}
//刷新界面
- (void)reloadCollectionViewData{
    [self.collectionView.mj_header endRefreshing];
    [self.collectionView.mj_footer endRefreshing];

    [self.collectionView reloadData];
}


- (void)updateShoppingCarNotification:(NSNotification *)note{
    [self updateShoppingCar];
}

- (void)updateShoppingCar{
    WeakSelf(ws);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            ws.stylesAndTotalPriceModel = [appdelegate.cartModel getTotalValueByOrderInfo:NO];
            [ws.topBarShoppingCarButton updateButtonNumber:[NSString stringWithFormat:@"%i", self.stylesAndTotalPriceModel.totalStyles]];
        });
    });
}

//获取本地缓存的所有系列
- (void)loadCachedAllSeries{
    WeakSelf(ws);

    [Series async:^id(NSManagedObjectContext *ctx, NSString *className) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:className];

        NSError *error;
        NSArray *dataArray = [ctx executeFetchRequest:request error:&error];
        if (error) {
            return error;
        }else{
            return dataArray;
        }

    } result:^(NSArray *result, NSError *error) {
        if (result
            && [result count] > 0) {
            [ws.cache_opusSeriesArray removeAllObjects];
            [ws.cache_opusSeriesArray addObjectsFromArray:result];

            ws.series = [ws.cache_opusSeriesArray objectAtIndex:0];
            [self updateNavUI];
            [ws fetchStyleSummaryEntitys];

        }else{
            [ws reloadCollectionViewData];
        }
    }];
}

- (void)insertObjectToDbFromSeriesModel:(YYSeriesInfoDetailModel *)infoDetailModel{
    NSString *predicate = [NSString stringWithFormat:@"series_id=%i",[infoDetailModel.series.id intValue]];
    NSLog(@"predicate: %@",predicate);
    Series *series = [Series one:predicate];
    if (series) {
        series.series_description = infoDetailModel.brandDescription;
        series.lookBookId = infoDetailModel.lookBookId;
        series.region = infoDetailModel.series.region;
        [Series save:^(NSError *error) {
            NSLog(@"error %@",error);
        }];
    }

}
- (void)insertDateRangToDbFromArray:(NSArray *)array{
    if (array && [array count] > 0) {
        for(YYDateRangeModel *dateRangModel in array){
            transferToStyleDateRange(dateRangModel);
        }
        [StyleDateRange save:^(NSError *error) {
            NSLog(@"保存波段列表信息成功");
        }];
    }
}

- (void)insertObjectToDbFromArray:(NSArray *)array{
    if (array && [array count] > 0) {
        for (YYOpusStyleModel *opusStyleModel in array) {
            NSString *predicate = [NSString stringWithFormat:@"series_id=%i and style_id=%i",[opusStyleModel.seriesId intValue],[opusStyleModel.id intValue]];
            NSLog(@"predicate: %@",predicate);
            StyleSummary *style = [StyleSummary one:predicate];
            if (!style) {
                style = [StyleSummary createNew];
                style.series_id = _opusSeriesModel.id;
                style.designer_id = _opusSeriesModel.designerId;
                style.style_id = opusStyleModel.id;
            }

            style.name = opusStyleModel.name;
            style.category = opusStyleModel.category;
            style.style_code = opusStyleModel.styleCode;
            style.region = opusStyleModel.region;
            style.style_description = opusStyleModel.description;
            style.album_img = opusStyleModel.albumImg;
            style.trade_price = opusStyleModel.tradePrice;
            style.retail_price = opusStyleModel.retailPrice;
            style.cur_type = opusStyleModel.curType;
            style.date_range_id = opusStyleModel.dateRangeId;
            if(opusStyleModel.dateRange){
                style.date_range = transferToStyleDateRange(opusStyleModel.dateRange);
            }
            NSArray *colorArray = opusStyleModel.color;
            if (colorArray && [colorArray count] > 0) {
                NSMutableArray *tempColorArray = [[NSMutableArray alloc] initWithCapacity:0];
                NSString *color_predicate = nil;
                for (YYColorModel *colorModel in colorArray) {
                    color_predicate = [NSString stringWithFormat:@"color_id=%i and style_id=%i",[colorModel.id intValue],[opusStyleModel.id intValue]];
                    StyleColors *styleColor = [StyleColors one:color_predicate];
                    if (!styleColor) {
                        styleColor = [StyleColors createNew];
                        styleColor.color_id = colorModel.id;
                    }
                    styleColor.color_name = colorModel.name;
                    styleColor.color_value = colorModel.value;
                    styleColor.style_id = opusStyleModel.id;
                    styleColor.style_code = colorModel.styleCode;
                    styleColor.materials = colorModel.materials;
                    styleColor.trade_price = colorModel.tradePrice;
                    styleColor.retail_price = colorModel.retailPrice;
                    styleColor.stock = colorModel.stock;
                    styleColor.size_stocks = colorModel.sizeStocks;
                    [tempColorArray addObject:styleColor];
                }
                style.colors = [[NSSet alloc] initWithArray:tempColorArray];
            }

            [StyleSummary save:^(NSError *error) {
                NSLog(@"保存款式列表信息成功");
            }];
        }
    }
}

-(void)fetchSeriesEntitys{

    WeakSelf(ws);
    [Series async:^id(NSManagedObjectContext *ctx, NSString *className) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:className];
        NSString *predicate = [NSString stringWithFormat:@"series_id=%ld",_seriesId];
        [request setPredicate:[NSPredicate predicateWithFormat:predicate]];
        NSError *error;
        NSArray *dataArray = [ctx executeFetchRequest:request error:&error];
        if (error) {
            return error;
        }else{
            return dataArray;
        }
    } result:^(NSArray *result, NSError *error) {
        if (result
            && [result count] > 0) {
            Series *series = [result objectAtIndex:0];
            if(ws.seriesInfoDetailModel == nil)
                ws.seriesInfoDetailModel = [[YYSeriesInfoDetailModel alloc] init];
            ws.seriesInfoDetailModel.series = [[YYSeriesInfoModel alloc] init];
            ws.seriesInfoDetailModel.series.name = series.name;
            ws.seriesInfoDetailModel.series.styleAmount = series.styleAmount;
            ws.seriesInfoDetailModel.series.season = series.season;
            ws.seriesInfoDetailModel.series.supplyStartTime = [[NSNumber alloc] initWithDouble:[series.supply_start_time doubleValue]];
            ws.seriesInfoDetailModel.series.supplyEndTime = [[NSNumber alloc] initWithDouble:[series.supply_end_time doubleValue]];
            ws.seriesInfoDetailModel.series.orderDueTime=series.order_due_time;
            ws.seriesInfoDetailModel.brandDescription = series.series_description;
            ws.seriesInfoDetailModel.lookBookId = series.lookBookId;
            ws.seriesInfoDetailModel.series.region = series.region;
            ws.seriesInfoDetailModel.series.status = series.status;
        }
        [ws.collectionView reloadData];
    }];
}

-(void)fetchSeriesDateRangEntitys{
    WeakSelf(ws);

    [StyleDateRange async:^id(NSManagedObjectContext *ctx, NSString *className) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:className];
        NSString *predicate = [NSString stringWithFormat:@"series_id=%ld",_seriesId];
        [request setPredicate:[NSPredicate predicateWithFormat:predicate]];

        NSError *error;
        NSArray *dataArray = [ctx executeFetchRequest:request error:&error];
        if (error) {
            return error;
        }else{
            return dataArray;
        }

    } result:^(NSArray *result, NSError *error) {
        if (result && [result count] > 0) {
            if( ws.seriesInfoDetailModel == nil)
                ws.seriesInfoDetailModel = [[YYSeriesInfoDetailModel alloc] init];
            NSMutableArray *tempArr = [[NSMutableArray alloc] init];
            YYDateRangeModel *dateRangMode = nil;
            for (StyleDateRange *daterang in result) {
                dateRangMode = transferToYYDateRangeModel(daterang);
                [tempArr addObject:dateRangMode];
            }
            ws.seriesInfoDetailModel.dateRanges = [tempArr copy];
        }
        [ws reloadCollectionViewData];
    }];

}

-(void)fetchStyleSummaryEntitys{

    WeakSelf(ws);

    [StyleSummary async:^id(NSManagedObjectContext *ctx, NSString *className) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:className];
        NSString *predicate = [NSString stringWithFormat:@"series_id=%ld",_seriesId];
        [request setPredicate:[NSPredicate predicateWithFormat:predicate]];
        NSError *error;
        NSArray *dataArray = [ctx executeFetchRequest:request error:&error];
        if (error) {
            return error;
        }else{
            return dataArray;
        }

    } result:^(NSArray *result, NSError *error) {
        [ws.cachedOpusStyleArray removeAllObjects];
        if (result
            && [result count] > 0) {
            ws.currentPageInfo = nil;
            [ws.onlineOpusStyleArray removeAllObjects];//不共存
            [ws.offlineOpusStyleArray removeAllObjects];//不共存

            [ws.cachedOpusStyleArray removeAllObjects];
            [ws.cachedOpusStyleArray addObjectsFromArray:result];

        }
        [ws reloadCollectionViewData];

    }];
}
- (void)filterDateRangType{
    if(_dateRangIndex > -1){
        self.filterResultArray = [[NSMutableArray alloc] init];
        YYDateRangeModel *dateRange = [_seriesInfoDetailModel.dateRanges objectAtIndex:_dateRangIndex];
        if(dateRange){
            if([self.offlineOpusStyleArray count] >0){
                for (YYOpusStyleModel *stylemodel in self.offlineOpusStyleArray) {
                    if([stylemodel.dateRangeId integerValue] == [dateRange.id integerValue]){
                        [self.filterResultArray addObject:stylemodel];
                    }
                }
            }else if([self.cachedOpusStyleArray count]>0){
                for (StyleSummary *stylemodel1 in self.cachedOpusStyleArray) {
                    if([stylemodel1.date_range_id integerValue] == [dateRange.id integerValue]){
                        [self.filterResultArray addObject:stylemodel1];
                    }
                }
            }else{
                for (YYOpusStyleModel *stylemodel in self.onlineOpusStyleArray) {
                    if([stylemodel.dateRangeId integerValue] == [dateRange.id integerValue]){
                        [self.filterResultArray addObject:stylemodel];
                    }
                }
            }
        }
    }else{
        self.filterResultArray = nil;
    }
    [self reloadCollectionViewData];
}
-(NSInteger)checkNullStyle{
    if(_searchResultArray != nil ){
        return [_searchResultArray count];
    }
    if(_filterResultArray  != nil){
        return [_filterResultArray count];
    }
    if ([_offlineOpusStyleArray count] > 0) {
        return [_offlineOpusStyleArray count];

    }else if([_onlineOpusStyleArray count] > 0){
        return [_onlineOpusStyleArray count];

    }else if ([_cachedOpusStyleArray count] > 0){
        return [_cachedOpusStyleArray count];
    }
    return 0;
}
#pragma mark -修改订单部分

- (void)updateNavUI{
    WeakSelf(ws);
    if(self.allSeriesBtn == nil){
        self.allSeriesBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.allSeriesBtn.titleLabel setFont:[UIFont systemFontOfSize:16]];
        [self.allSeriesBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];

        [self.allSeriesBtn addTarget:self action:@selector(showsAllSeries:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.allSeriesBtn];
        [self.allSeriesBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.and.bottom.and.left.and.right.equalTo(ws.titleLabel);
        }];
    }

    [_gobackButton2 setTitle:NSLocalizedString(@"修改订单",nil) forState:UIControlStateNormal];
    self.titleLabel.hidden = YES;

    NSString *currentSeriesName = @"";

    if ([self.online_opusSeriesArray count] > 0){
        currentSeriesName = self.opusSeriesModel.name;
    }else if ([self.offline_opusSeriesArray count] > 0) {
        currentSeriesName = self.opusSeriesModel.name;
    }else if ([self.cache_opusSeriesArray count] > 0){
        currentSeriesName = self.series.name;
    }
    //动态更新按钮标题
    [self.allSeriesBtn setTitle:@"    " forState:UIControlStateNormal];
    [self.allSeriesBtn setImage:nil forState:UIControlStateNormal];
    if(![currentSeriesName isEqualToString:@""]){
        [self.allSeriesBtn setImage:[UIImage imageNamed:@"down"] forState:UIControlStateNormal];
        [self.allSeriesBtn setTitle:[[NSString alloc] initWithFormat:@"%@  ",currentSeriesName] forState:UIControlStateNormal];
        //self.titleLabel.text = currentSeriesName;
        CGSize seriesNameTextSize =[[[NSString alloc] initWithFormat:@"%@  ",currentSeriesName] sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16]}];
        CGSize imageSize = [UIImage imageNamed:@"down"].size;
        float labelWidth = seriesNameTextSize.width;
        float imageWith = imageSize.width;
        self.allSeriesBtn.imageEdgeInsets = UIEdgeInsetsMake(0, labelWidth, 0, -labelWidth);
        self.allSeriesBtn.titleEdgeInsets = UIEdgeInsetsMake(0, -imageWith, 0, imageWith);
    }
}

- (void)showsAllSeries:(UIButton *)sender{
    WeakSelf(ws);
    sender.selected = !sender.selected;
    if (sender.selected) {
        self.seriesview= [[UIView alloc] init];
        self.seriesview.backgroundColor = [UIColor clearColor];
        [self.view addSubview:self.seriesview];
        [self.seriesview mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.and.bottom.and.left.and.right.equalTo(ws.collectionView);
        }];


        self.scrollV = [self aScrollView];
        [self.seriesview addSubview:_scrollV];
        [_scrollV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(ws.seriesview.mas_top).with.offset(0);
            make.centerX.equalTo(ws.seriesview);
            make.width.mas_equalTo(245);
            make.height.mas_equalTo(300);
        }];

    }else{
        [self.seriesview removeFromSuperview];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    self.allSeriesBtn.selected = NO;
    [self.seriesview removeFromSuperview];
}

- (UIScrollView *)aScrollView{
    WeakSelf(ws);
    self.scrollV = [[UIScrollView alloc] init];
    _scrollV.backgroundColor = [UIColor whiteColor];

    long seriesCount = 0;
    NSString *currentSeriesName = nil;
    NSString *currentSeriesId = nil;
    if ([self.online_opusSeriesArray count] > 0){
        seriesCount = self.online_opusSeriesArray.count;
        currentSeriesName = self.opusSeriesModel.name;
        currentSeriesId = [self.opusSeriesModel.id stringValue];
    }else if ([self.offline_opusSeriesArray count] > 0) {
        seriesCount = self.offline_opusSeriesArray.count;
        currentSeriesName = self.opusSeriesModel.name;
        currentSeriesId = [self.opusSeriesModel.id stringValue];
    }
    else if ([self.cache_opusSeriesArray count] > 0){
        seriesCount = self.cache_opusSeriesArray.count;
        currentSeriesName = self.series.name;
        currentSeriesId = [self.series.series_id stringValue];
    }
    NSInteger rowHeight = 58;
    NSInteger tableHeight = 245;
    _scrollV.contentSize = CGSizeMake(0, seriesCount * rowHeight);
    for (int i = 0; i < seriesCount; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        NSString *nowSeriesName = nil;
        NSString *nowSeriesId = nil;
        if([self.online_opusSeriesArray count] > i){
            YYOpusSeriesModel *opusSeriesMod = self.online_opusSeriesArray[i];
            nowSeriesName = opusSeriesMod.name;
            nowSeriesId = [opusSeriesMod.id stringValue];
        }else if ([self.offline_opusSeriesArray count] > i) {
            YYOpusSeriesModel *opusSeriesMod = self.offline_opusSeriesArray[i];
            nowSeriesName = opusSeriesMod.name;
            nowSeriesId = [opusSeriesMod.id stringValue];
        }else if ([self.cache_opusSeriesArray count] > i){
            Series *series = [self.cache_opusSeriesArray objectAtIndex:i];
            nowSeriesName = series.name;
            nowSeriesId = [series.series_id stringValue];
        }

        [btn setTitle:nowSeriesName forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:14];
        btn.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        btn.titleLabel.numberOfLines = 2;
        btn.titleEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 15);
        btn.tag = 100 * i;

        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];

        if ([nowSeriesId isEqualToString:currentSeriesId]) {
            btn.enabled = NO;
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [btn setBackgroundColor:[UIColor blackColor]];
        }

        [btn addTarget:self action:@selector(swithSeries:) forControlEvents:UIControlEventTouchUpInside];

        [btn setBackgroundImage:[UIImage imageNamed:@"black"] forState:UIControlStateHighlighted];
        _scrollV.layer.borderWidth = 6;
        _scrollV.layer.borderColor = [UIColor blackColor].CGColor;
        [_scrollV addSubview:btn];
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(ws.scrollV);
            make.top.mas_equalTo(i * rowHeight);
            make.width.mas_equalTo(tableHeight);
            make.height.mas_equalTo(rowHeight-1);
        }];
        UIView *line = [[UIView alloc] init];
        line.backgroundColor = [UIColor blackColor];
        [_scrollV addSubview:line];
        [line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(ws.scrollV);
            make.top.mas_equalTo(i * rowHeight+rowHeight-1);
            make.width.mas_equalTo(tableHeight);
            make.height.mas_equalTo(1);
        }];
    }
    return _scrollV;
}

#pragma mark -数据为空的时候仍有数据显示
- (void)swithSeries:(UIButton *)sender{
    long index = sender.tag / 100;

    if ([self.online_opusSeriesArray count] > 0){
        YYOpusSeriesModel *opusSeriesModel = _online_opusSeriesArray[index];
        self.opusSeriesModel = opusSeriesModel;
        self.seriesId = [_opusSeriesModel.id longValue];
        self.designerId = [_opusSeriesModel.designerId longValue];

        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [self loadStyleListByPageIndex:1 queryStr:@""];

    }else if ([self.offline_opusSeriesArray count] > 0) {
        YYOpusSeriesModel *opusSeriesModel = _offline_opusSeriesArray[index];
        self.opusSeriesModel = opusSeriesModel;
        self.seriesId = [_opusSeriesModel.id longValue];
        self.designerId = [_opusSeriesModel.designerId longValue];
        if ([self readOfflineSeriesDataIsSuccess]) {
            [self reloadCollectionViewData];
        };

    }else if ([self.cache_opusSeriesArray count] > 0){
        Series *series = [self.cache_opusSeriesArray objectAtIndex:index];
        self.series = series;
        self.seriesId = [series.series_id integerValue];
        [self fetchStyleSummaryEntitys];
    }
    [self updateNavUI];
    self.allSeriesBtn.selected = NO;
    [self.seriesview removeFromSuperview];
}

#pragma mark - --------------other----------------------
- (void)showShoppingView:(YYStyleInfoModel *)styleInfo {
    UIView *superView = self.view;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    WeakSelf(ws);
    [appDelegate showShoppingViewNew:NO styleInfoModel:styleInfo seriesModel:_opusSeriesModel opusStyleModel:nil currentYYOrderInfoModel:nil parentView:superView fromBrandSeriesView:!_isModifyOrder WithBlock:^(YYBrandSeriesToCartTempModel *brandSeriesToCardTempModel) {
        [ws shoppingViewBlockWithCartTempModel:brandSeriesToCardTempModel];
    }];
}

@end

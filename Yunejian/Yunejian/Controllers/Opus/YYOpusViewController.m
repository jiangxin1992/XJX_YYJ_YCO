//
//  YYOpusViewController.m
//  Yunejian
//
//  Created by yyj on 15/7/9.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import "YYOpusViewController.h"

#import "YYOpusApi.h"
#import "YYUser.h"
#import "SDWebImageManager.h"
#import <MJRefresh.h>
#import "YYTopBarShoppingCarButton.h"
#import "YYStyleDetailListViewController.h"
#import "Series.h"
#import "NSManagedObject+helper.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"
#import "UIImage+YYImage.h"
#import "YYOpusSeriesModel.h"
#import "YYTopAlertView.h"
#import "YYCartDetailViewController.h"
#import "YYSeriesCollectionViewCell.h"
#import "YYYellowPanelManage.h"
#import "YYScanFunctionModel.h"

#import "YYQRCode.h"

#import "YYStylesAndTotalPriceModel.h"
#import "YYOpusSeriesListModel.h"

@interface YYOpusViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,YYSeriesCollectionViewCellDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet YYTopBarShoppingCarButton *topBarShoppingCarButton;

@property (nonatomic,strong)NSMutableArray *online_opusSeriesArray;
@property (nonatomic,strong)NSMutableArray *cache_opusSeriesArray;
@property (nonatomic,strong)YYPageInfoModel *currentPageInfo;

@property(nonatomic,strong) YYStylesAndTotalPriceModel *stylesAndTotalPriceModel;//总数

@property (nonatomic,strong) UIView *noDataView;
@property (nonatomic,assign) double loadImageDate;
@end

@implementation YYOpusViewController{
    dispatch_source_t _timer;
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    // 退出埋点
    [MobClick endLogPageView:kYYPageOpusList];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)_collectionView.collectionViewLayout;
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 15);
    
    [self.topBarShoppingCarButton initButton];
    self.online_opusSeriesArray = [[NSMutableArray alloc] initWithCapacity:0];
    self.cache_opusSeriesArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    [self addHeader];
    [self addFooter];

    self.collectionView.alwaysBounceVertical = YES;
    
    self.noDataView = addNoDataView_pad(self.view,[NSString stringWithFormat:@"%@/n%@|icon:noopus_icon|45",NSLocalizedString(@"还未创建作品",nil),NSLocalizedString(@"请登录YCO SYSTEM网页版，进行创建。",nil)],nil,nil);
    
    self.noDataView.hidden = YES;
    
    if ([YYNetworkReachability connectedToNetwork]) {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        UIView *superView = appDelegate.window.rootViewController.view;
        
        [MBProgressHUD showHUDAddedTo:superView animated:YES];
     }
    [self loadDataByPageIndex:1];
}

//在视图出现的时候更新购物车数据
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    self.stylesAndTotalPriceModel = [appdelegate.cartModel getTotalValueByOrderInfo:NO];
    [self.topBarShoppingCarButton updateButtonNumber:[NSString stringWithFormat:@"%i", self.stylesAndTotalPriceModel.totalStyles]];

    // 进入埋点
    [MobClick beginLogPageView:kYYPageOpusList];
}

#pragma mark - 扫码
- (IBAction)sweepYardButtonClicked:(id)sender {
    YYQRCodeController *QRCode = [YYQRCodeController QRCodeSuccessMessageBlock:^(YYQRCodeController *code, NSString *messageString) {

        NSData *JSONData = [messageString dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *responseJSON = [NSJSONSerialization JSONObjectWithData:JSONData options:NSJSONReadingMutableLeaves error:nil];
        //扫码回调
        YYScanFunctionModel *scanModel = [[YYScanFunctionModel alloc] init];

        scanModel.env = responseJSON[@"env"];// @"TEST";
        scanModel.type = responseJSON[@"type"];// @"STYLE";
        scanModel.id = responseJSON[@"id"]; // @"2690";

        //判断环境
        if([scanModel isRightEnvironment]){
            if([scanModel. type isEqualToString:@"STYLE"]){
                //扫码款式类型处理
                [self sweepYardStyleTypeAction:scanModel code:code];
            }
        }else{
            [code toast:NSLocalizedString(@"您没有查看此款式的权限",nil) collback:^(YYQRCodeController *code) {
                [code scanningAgain];
            }];
        }
    }];

    [self.navigationController pushViewController:QRCode animated:YES];
}
-(void)sweepYardStyleTypeAction:(YYScanFunctionModel *)scanModel code:(YYQRCodeController *)code{
    // WeakSelf(ws);
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [YYOpusApi getStyleInfoByStyleId:[scanModel.id longLongValue] orderCode:nil andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYStyleInfoModel *styleInfoModel, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if(rspStatusAndMessage){
            if (rspStatusAndMessage.status == YYReqStatusCode100) {
                [code dismissController];
                //表示有权限访问，跳转款式详情页
                if(styleInfoModel){
                    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                    [appDelegate showStyleInfoViewController:styleInfoModel parentViewController:self IsShowroomToScan:NO];
                }
            }else{
                [code toast:NSLocalizedString(@"您没有查看此款式的权限",nil) collback:^(YYQRCodeController *code) {
                    [code scanningAgain];
                }];
            }
        }else{
            [code toast:kNetworkIsOfflineTips collback:^(YYQRCodeController *code) {
                [code scanningAgain];
            }];
        }
    }];
}

- (IBAction)shoppingCarClicked:(id)sender{
    
    if (self.stylesAndTotalPriceModel.totalStyles <= 0) {
        [YYToast showToastWithTitle:NSLocalizedString(@"购物车暂无数据",nil) andDuration:kAlertToastDuration];
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
            
            //AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            //if (!appDelegate.cartModel){
                //如果购物车为空了，进入订单列表界面
            [[NSNotificationCenter defaultCenter] postNotificationName:kShowOrderListNotification object:nil];
            //}
        }];
    }];
    
    [self presentViewController:nav animated:YES completion:nil];
}

//刷新界面
- (void)reloadCollectionViewData{
    [self.collectionView.mj_header endRefreshing];
    [self.collectionView.mj_footer endRefreshing];
    
    [self.collectionView reloadData];
    
    if ([self.online_opusSeriesArray count] == 0
        && [self.cache_opusSeriesArray count] == 0) {
        self.noDataView.hidden = NO;
    }else{
        self.noDataView.hidden = YES;
    }
}

- (void)loadDataByPageIndex:(int)pageIndex{

    if (![YYNetworkReachability connectedToNetwork]) {
        //如果网络不通的，取本地数据库缓存的数据
        [self fetchEntitys];
        [YYToast showToastWithTitle:kNetworkIsOfflineTips andDuration:kAlertToastDuration];
        return;
    }
    
    YYUser *user = [YYUser currentUser];
    WeakSelf(ws);

    [YYOpusApi getSeriesListWithId:[user.userId intValue] pageIndex:pageIndex pageSize:kPageSize withDraft:@"true" andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYOpusSeriesListModel *opusSeriesListModel, NSError *error) {
        if (rspStatusAndMessage.status == YYReqStatusCode100
            && opusSeriesListModel.result
            && [opusSeriesListModel.result count] > 0) {
            
            [ws.cache_opusSeriesArray removeAllObjects];//本地的和在线的不要共存
            
            if (pageIndex == 1) {
                [_online_opusSeriesArray removeAllObjects];
            }
            ws.currentPageInfo = opusSeriesListModel.pageInfo;
            [ws.online_opusSeriesArray addObjectsFromArray:opusSeriesListModel.result];
            [ws insertObjectToDbFromArray:opusSeriesListModel.result];
        }
        [ws reloadCollectionViewData];
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        UIView *superView = appDelegate.window.rootViewController.view;
        [MBProgressHUD hideAllHUDsForView:superView animated:YES];
        
        if (rspStatusAndMessage.status != YYReqStatusCode100) {
            [YYToast showToastWithTitle:rspStatusAndMessage.message  andDuration:kAlertToastDuration];
        }
    }];
}

-(void)fetchEntitys{
    
    WeakSelf(ws);
    
    [Series async:^id(NSManagedObjectContext *ctx, NSString *className) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:className];
        //[request setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"series_id" ascending:YES]]];
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
            
            if ([ws.cache_opusSeriesArray count] > 0) {
                [ws.cache_opusSeriesArray removeAllObjects];
            }
            for (int i=0; i<result.count; i++) {
                Series *series = [result objectAtIndex:i];
                if(![NSString isNilOrEmpty:series.brand_id]){
                    if([[YYUser getBrandID] isEqualToString:series.brand_id]){
                        [ws.cache_opusSeriesArray addObject:series];
                    }
                }
            }
            [ws.online_opusSeriesArray removeAllObjects]; //本地的和在线的不要共存
            ws.currentPageInfo = nil;
        }
        
        [ws reloadCollectionViewData];
    }];
}

- (void)insertObjectToDbFromArray:(NSArray *)array{
    if (array
        && [array count] > 0) {
        for (YYOpusSeriesModel *opusSeriesModel in array) {
            NSString *predicate = [NSString stringWithFormat:@"series_id=%i",[opusSeriesModel.id intValue]];
            NSLog(@"predicate: %@",predicate);
            Series *series = [Series one:predicate];
            if (!series) {
                series = [Series createNew];
                series.series_id = opusSeriesModel.id;
                series.designer_id = opusSeriesModel.designerId;
                series.brand_id = opusSeriesModel.brandID;
            }
            series.name = opusSeriesModel.name;
            //series.series_description = opusSeriesModel.description;
            series.year = opusSeriesModel.year;
            series.season = opusSeriesModel.season;
            series.album_img = opusSeriesModel.albumImg;
            series.order_due_time = opusSeriesModel.orderDueTime;
            series.supply_status = opusSeriesModel.supplyStatus;
            series.auth_type = opusSeriesModel.authType;
            series.supply_start_time = [opusSeriesModel.supplyStartTime stringValue];
            series.supply_end_time = [opusSeriesModel.supplyEndTime stringValue];
            series.styleAmount = opusSeriesModel.styleAmount;
            series.order_amount_min = opusSeriesModel.orderAmountMin;
            series.date_range_amount = opusSeriesModel.dateRangeAmount;
            series.status = opusSeriesModel.status;
            series.stock_enabled = [opusSeriesModel.stockEnabled boolValue];
            [Series save:^(NSError *error) {
                NSLog(@"error %@",error);
                //[self fetchEntitys];显示的时候调该方法
            }];
            
        }
    }
}

- (void)addHeader{
    WeakSelf(ws);
    // 添加下拉刷新头部控件
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        // 进入刷新状态就会回调这个Block
        [ws loadDataByPageIndex:1];
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
        if ([ws.online_opusSeriesArray count] > 0
            && ws.currentPageInfo
            && !ws.currentPageInfo.isLastPage) {
            [ws loadDataByPageIndex:[ws.currentPageInfo.pageIndex intValue]+1];
        }else{
            [ws.collectionView.mj_footer endRefreshing];
        }
    }];
}

#pragma mark -  UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
//    self.automaticallyAdjustsScrollViewInsets = NO;
//    
//    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)collectionView.collectionViewLayout;
//    layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 15);
    
    NSInteger numberOfItemsInSection = 0;
    if ([_online_opusSeriesArray count] > 0) {
        numberOfItemsInSection = [_online_opusSeriesArray count];
    }else if ([_cache_opusSeriesArray count] > 0){
        numberOfItemsInSection = [_cache_opusSeriesArray count];
    }
    
    return numberOfItemsInSection;
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* reuseIdentifier = @"YYSeriesCollectionViewCell";
    YYSeriesCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];

    NSString *imageRelativePath = nil;
    NSString *title = nil;
    NSString *beginDate = @"";
    NSString *endDate = @"";

    NSString *order = nil;
    NSString *styleAmount = nil;
    long series_id = 0;
    NSInteger supplyStatus = -1;
    NSInteger dateRangeAmount = 0;
    NSInteger authType= 0;
    NSInteger status = -1;
    BOOL stockEnabled = false;
    NSComparisonResult compareResult1 = NSOrderedDescending;
    NSComparisonResult compareResult2 = NSOrderedDescending;

    if (indexPath.row < [_online_opusSeriesArray count]) {
        if (_online_opusSeriesArray
            && [_online_opusSeriesArray count] > indexPath.row) {
            YYOpusSeriesModel *opusSeriesModel = [_online_opusSeriesArray objectAtIndex:indexPath.row];
            imageRelativePath = opusSeriesModel.albumImg;
            series_id = [opusSeriesModel.id longValue];
            title = opusSeriesModel.name;
            beginDate = getShowDateByFormatAndTimeInterval(@"yy/MM/dd",[opusSeriesModel.supplyStartTime stringValue]);
            endDate = getShowDateByFormatAndTimeInterval(@"yy/MM/dd",[opusSeriesModel.supplyEndTime stringValue]);
            order = [NSString stringWithFormat:NSLocalizedString(@"最晚下单：%@",nil), [NSString isNilOrEmpty:opusSeriesModel.orderDueTime] ? NSLocalizedString(@"随时可以下单", nil) : getShowDateByFormatAndTimeInterval(@"yy/MM/dd", opusSeriesModel.orderDueTime)];
            styleAmount =  [NSString stringWithFormat:NSLocalizedString(@"%i 款",nil),[opusSeriesModel.styleAmount intValue]];

            supplyStatus = [opusSeriesModel.supplyStatus integerValue];
            compareResult1 = compareNowDate([opusSeriesModel.supplyEndTime stringValue]);
            compareResult2 = [NSString isNilOrEmpty:opusSeriesModel.orderDueTime] ? NSOrderedDescending : compareNowDate(opusSeriesModel.orderDueTime);
            authType = [opusSeriesModel.authType integerValue];
            dateRangeAmount = [opusSeriesModel.dateRangeAmount integerValue];
            status = [opusSeriesModel.status integerValue];
            stockEnabled = [opusSeriesModel.stockEnabled boolValue];
        }
    }else{
        if (indexPath.row < [_cache_opusSeriesArray count]) {
            Series *series = [_cache_opusSeriesArray objectAtIndex:indexPath.row];
            series_id = [series.series_id longValue];
            imageRelativePath = series.album_img;
            title = series.name;
            beginDate = getShowDateByFormatAndTimeInterval(@"yy/MM/dd",series.supply_start_time);
            endDate = getShowDateByFormatAndTimeInterval(@"yy/MM/dd",series.supply_end_time);
            order = [NSString stringWithFormat:NSLocalizedString(@"最晚下单：%@",nil), [NSString isNilOrEmpty:series.order_due_time] ?  NSLocalizedString(@"随时可以下单", nil) : getShowDateByFormatAndTimeInterval(@"yy/MM/dd",series.order_due_time)];
            styleAmount =  [NSString stringWithFormat:NSLocalizedString(@"%i 款",nil),[series.styleAmount intValue]];
            supplyStatus = [series.supply_status integerValue];
            compareResult1 = compareNowDate(series.supply_end_time);
            compareResult2 = [NSString isNilOrEmpty:series.order_due_time] ? NSOrderedDescending : compareNowDate(series.order_due_time);
            authType = [series.auth_type integerValue];
            dateRangeAmount = [series.date_range_amount integerValue];
            status = [series.status integerValue];
            stockEnabled = series.stock_enabled;
        }
    }
    cell.series_id = series_id ;
    if(cell.series_id == 100){
        NSLog(@"111");
    }
    cell.imageRelativePath = imageRelativePath;
    cell.title = title;
    cell.order = order;
    cell.styleAmount = styleAmount;
    cell.authType = authType;
    cell.supplyStatus = supplyStatus;
    cell.status = status;
    cell.stockEnabled = stockEnabled;
    cell.dateRangeAmount = dateRangeAmount;
    if (supplyStatus == 0) {
        cell.produce = NSLocalizedString(@"发货日期 马上发货",nil);
        compareResult1 = NSOrderedSame;
    }else{
        cell.produce = [NSString stringWithFormat:NSLocalizedString(@"发货日期：%@-%@",nil),beginDate,endDate];
    }
    cell.compareResult1 = compareResult1;
    cell.compareResult2 = compareResult2;
    cell.indexPath = indexPath;
    cell.delegate = self;


    //    没有的时候让他去请求
    if(![YYUser haveTempSeriesID:cell.series_id]){
        cell.haveLoadData = NO;
        NSString *folderName = [NSString stringWithFormat:@"%li",cell.series_id];
        NSString *offlineFilePath = [yyjOfflineSeriesDirectory() stringByAppendingPathComponent:folderName];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL fileExists = [fileManager fileExistsAtPath:offlineFilePath];
        if (fileExists || ([cell checkOperation:cell.series_id] != nil )) {
            //已经下载过
            NSArray *countInfo = [cell getDownLoadCount:cell.series_id];
            if(countInfo != nil){
                cell.loadImageCount = [[countInfo objectAtIndex:0] integerValue];
                cell.totalImageCount = [[countInfo objectAtIndex:1] integerValue];
            }
            //thread 更新
            __block long blockSeriesId = cell.series_id;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSArray *countArr = [cell checkImagesDownloadAll];
                [cell addDownLoadCount:countArr];
                if(blockSeriesId == cell.series_id){
                    cell.loadImageCount = [[countArr objectAtIndex:0] integerValue];
                    cell.totalImageCount = [[countArr objectAtIndex:1] integerValue];
                    if(cell.totalImageCount > cell.loadImageCount){
                        cell.haveLoadData = NO;
                    }else{
                        cell.haveLoadData = YES;
                    }
                }
            });
        }
    }else{
        cell.haveLoadData = YES;
    }

    if(cell.series_id == 100){
        NSLog(@"111");
    }
    //    WeakSelf(weakSelf);
    //    [cell setModifySuccess:^(){
    //        [weakSelf.collectionView reloadData];
    //    }];
    [cell updateUI];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    //这里要判断是用离线数据，还是缓存数据，还是在线数据
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Opus" bundle:[NSBundle mainBundle]];
    YYStyleDetailListViewController *styleDetailListViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYStyleDetailListViewController"];
    BOOL isHaveOfflineData = NO;//有没有离线数据，如果有，直接读离线数据
    long _series_id = 0;
    int _designer_id = 0;
    NSInteger _status = 0;
    YYOpusSeriesModel *opusSeriesModel = nil;
    Series *series = nil;
    NSComparisonResult compareResult = NSOrderedDescending;

    if ([_online_opusSeriesArray count] > indexPath.row ) {
         opusSeriesModel = [_online_opusSeriesArray objectAtIndex:indexPath.row];
        _series_id = [opusSeriesModel.id longValue];
        _designer_id = [opusSeriesModel.designerId intValue];
        compareResult = compareNowDate(opusSeriesModel.orderDueTime);
        _status = [opusSeriesModel.status integerValue];
    }else if ([_cache_opusSeriesArray count] > indexPath.row){
        series = [_cache_opusSeriesArray objectAtIndex:indexPath.row];
        _series_id = [series.series_id longValue];
        _designer_id = [series.designer_id intValue];
        compareResult = compareNowDate(series.order_due_time);
        _status = [series.status integerValue];
    }
    
    NSString *folderName = [NSString stringWithFormat:@"%li",_series_id];
    NSString *offlineFilePath = [yyjOfflineSeriesDirectory() stringByAppendingPathComponent:folderName];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:offlineFilePath]) {
        //已经下载过
        isHaveOfflineData = YES;
    }
    
    if (isHaveOfflineData) {
        styleDetailListViewController.series = series;
        styleDetailListViewController.opusSeriesModel = opusSeriesModel;
        styleDetailListViewController.seriesId = _series_id;
    }else{
        
        if ([_online_opusSeriesArray count] > indexPath.row){

            styleDetailListViewController.opusSeriesModel = opusSeriesModel;
            styleDetailListViewController.seriesId = _series_id;
            styleDetailListViewController.designerId = _designer_id;
        }else if ([_cache_opusSeriesArray count] > indexPath.row){
 
            styleDetailListViewController.series = series;
            styleDetailListViewController.seriesId = _series_id;
            styleDetailListViewController.designerId = _designer_id;
        }
    }
    styleDetailListViewController.orderDueCompareResult = compareResult;
    [self.navigationController pushViewController:styleDetailListViewController animated:YES];
    
    
}

#pragma mark - YYSeriesCollectionViewCellDelegate
-(void)downloadImages:(NSURL *)url andStorePath:(NSString *)storePath{
    WeakSelf(ws);
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager downloadImageWithURL:url options:SDWebImageRetryFailed|SDWebImageLowPriority progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        if (image) {
            if(manager.isRunning){
                [ws testDownloadCompleted];
            }else{
                if(_timer){
                    [self dispatch_cancel:_timer];
                }

                double nowDate = (double)[[NSDate date] timeIntervalSince1970];
                if(nowDate > ws.loadImageDate + 30){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSLog(@"testDownload_completed");
                        [ws.collectionView reloadData];
                        [self performSelector:@selector(reloadAgain) withObject:self afterDelay:1];
                    });
                    ws.loadImageDate = nowDate;
                }
            }
        }
        return ;
    }];
}

-(void)testDownloadCompleted{
    BOOL canStartTimer = NO;
    if(!_timer){
        canStartTimer = YES;
    }else{
        if(dispatch_source_testcancel(_timer)){
            canStartTimer = YES;
        }
    }
    if(canStartTimer){
        NSLog(@"testDownload_start");
        [self.collectionView reloadData];
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);

        dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
        dispatch_source_set_event_handler(_timer, ^{
            SDWebImageManager *manager = [SDWebImageManager sharedManager];
            if(manager.isRunning){
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"testDownload_dispatch_async");
                    [self.collectionView reloadData];
                });
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"testDownload_completed");
                    [self.collectionView reloadData];
                    [self performSelector:@selector(reloadAgain) withObject:self afterDelay:1];
                });
                [self dispatch_cancel:_timer];
            }
        });
        dispatch_resume(_timer);
    }
}
-(void)dispatch_cancel:(dispatch_source_t )timer
{
    if(timer)
    {
        if(!dispatch_source_testcancel(timer))
        {
            dispatch_source_cancel(timer);
        }
    }
}
//懒得看代码了  干脆后面给个reload
-(void)reloadAgain{
    [self.collectionView reloadData];
}
-(void)operateHandler:(NSInteger)section androw:(NSInteger)row type:(NSString *)type{
     WeakSelf(ws);
    if([type isEqualToString:@"refresh"]){//更新下载进度
        [self.collectionView reloadData];
    }else if([type isEqualToString:@"updateAuthType"]){//更新权限更改
        if ([_online_opusSeriesArray count] > row ) {
            YYOpusSeriesModel *opusSeriesModel = [_online_opusSeriesArray objectAtIndex:row];
            __block YYOpusSeriesModel *blockopusSeriesModel = opusSeriesModel;
            if(section == YYOpusAuthDefined){
                if(opusSeriesModel.id && opusSeriesModel.authType){
                    [[YYYellowPanelManage instance] showOpusSettingDefinedViewWidthParentView:nil info:@[opusSeriesModel.id,opusSeriesModel.authType] andCallBack:^(NSArray *value) {
                        NSString *authTypeInfo = [value objectAtIndex:0];
                        NSArray *authTypeInfoArr = [authTypeInfo componentsSeparatedByString:@"|"];
                        if([authTypeInfoArr count] == 2){
                            NSInteger authType = [[authTypeInfoArr objectAtIndex:0] integerValue];
                            NSString *buyerIds = [authTypeInfoArr objectAtIndex:1];
                            [YYOpusApi updateSeriesAuthType:[blockopusSeriesModel.id integerValue] authType:authType buyerIds:buyerIds andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSError *error) {
                                if(rspStatusAndMessage.status == YYReqStatusCode100){
                                    blockopusSeriesModel.authType = [[NSNumber alloc] initWithInteger:authType];
                                    [ws.collectionView reloadData];
                                    [YYToast showToastWithTitle:NSLocalizedString(@"修改成功",nil) andDuration:kAlertToastDuration];
                                }
                            }];
                        }
                    }];
                }
                return;
            }
            [YYOpusApi updateSeriesAuthType:[opusSeriesModel.id integerValue] authType:section buyerIds:@"" andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSError *error) {
                if(rspStatusAndMessage.status == YYReqStatusCode100){
                    blockopusSeriesModel.authType = [[NSNumber alloc] initWithInt:section];
                    [ws.collectionView reloadData];
                    [YYToast showToastWithTitle:NSLocalizedString(@"修改成功",nil) andDuration:kAlertToastDuration];
                }
            }];

        }else if ([_cache_opusSeriesArray count] > row){
            [YYToast showToastWithTitle:kNetworkIsOfflineTips andDuration:kAlertToastDuration];
        }
    }else if([type isEqualToString:@"updatePubStatus"]){    
        YYOpusSeriesModel *opusSeriesModel = [_online_opusSeriesArray objectAtIndex:row];
        __block YYOpusSeriesModel *blockopusSeriesModel = opusSeriesModel;
        [[YYYellowPanelManage instance] showOpusSettingpanelWidthParentView:nil seriesId:[opusSeriesModel.id integerValue] andCallBack:^(NSArray *value) {
            NSString *authType = nil;
            NSString *buyerIds = @"";
            NSString *authTypeInfo = [value objectAtIndex:0];
            NSArray *authTypeInfoArr = [authTypeInfo componentsSeparatedByString:@"|"];
            if([authTypeInfoArr count] == 2){
                authType = [authTypeInfoArr objectAtIndex:0];
                buyerIds = [authTypeInfoArr objectAtIndex:1];
            }else{
                authType = authTypeInfo ;
            }
            __block NSInteger blockType = [authType integerValue];
            [YYOpusApi updateSeriesPubStatus:[blockopusSeriesModel.id integerValue] status:0 authType:authType buyerIds:buyerIds andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSError *error) {
                if(rspStatusAndMessage.status == YYReqStatusCode100){
                    blockopusSeriesModel.authType = [[NSNumber alloc] initWithInt:blockType];
                    blockopusSeriesModel.status = [[NSNumber alloc] initWithInt:0];
                    [ws.collectionView reloadData];
                    [YYToast showToastWithTitle:NSLocalizedString(@"修改成功",nil) andDuration:kAlertToastDuration];
                }
            }];
            
        }];
        
    }
}

-(UIView *)getview{
    return self.view;
}

@end

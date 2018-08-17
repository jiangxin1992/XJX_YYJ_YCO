//
//  YYStyleDetailViewController.m
//  Yunejian
//
//  Created by yyj on 15/7/24.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import "YYStyleDetailViewController.h"

#import "YYDetailContentViewController.h"
#import "YYNavigationBarViewController.h"
#import "YYTopBarShoppingCarButton.h"
#import "YYOpusStyleModel.h"
#import "StyleSummary.h"
#import "YYCartDetailViewController.h"
#import "YYStylesAndTotalPriceModel.h"
#import "AppDelegate.h"
#import "StyleDateRange.h"
#import "YYUser.h"
#import "YYOrderInfoModel.h"
#import "YYShowroomApi.h"
#import "MBProgressHUD.h"

#define kDicKeyPrefix @"kDicKeyPrefix_"

static NSInteger tagOffset = 90000;

@interface YYStyleDetailViewController ()

@property (weak, nonatomic) IBOutlet UIView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *closeBtn;

@property (nonatomic,strong) UIImageView *viewImage1;
@property (nonatomic,strong) UIImageView *viewImage2;
@property (nonatomic,strong) UIImageView *viewImage3;
@property (nonatomic,strong) YYDetailContentViewController *detailContentViewController1;
@property (nonatomic,strong) YYDetailContentViewController *detailContentViewController2;
@property (nonatomic,strong) YYDetailContentViewController *detailContentViewController3;

//@property (nonatomic,strong) UIView *tempView;

@property (nonatomic,strong) NSMutableDictionary *localCacheDic;
@property (nonatomic,strong) NSMutableArray *templocalCacheArr;


@property (nonatomic,assign) int currentPage; //当前页

@property(nonatomic,strong) YYStylesAndTotalPriceModel *stylesAndTotalPriceModel;//总数
@property (nonatomic, strong) YYTopBarShoppingCarButton *topBarShoppingCarButton;
@end

@implementation YYStyleDetailViewController{
    BOOL anibool;
    NSInteger viewndex;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    self.currentPage = self.currentIndex;
    switch (_currentDataReadType) {
        case EDataReadTypeOffline:
        case EDataReadTypeOnline:{
            self.totalPages = [self.onlineOrOfflineOpusStyleArray count];
        }
            break;
        case EDataReadTypeCached:{
            self.totalPages = [self.cachedOpusStyleArray count];
        }
            break;
            
        default:
            break;
    }
    
    self.localCacheDic = [[NSMutableDictionary alloc] initWithCapacity:0];
    self.templocalCacheArr = [[NSMutableArray alloc] init];
    
    AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    self.stylesAndTotalPriceModel = [appdelegate.cartModel getTotalValueByOrderInfo:NO];
    self.topBarShoppingCarButton = [YYTopBarShoppingCarButton buttonWithType:UIButtonTypeCustom];
    [self.topBarShoppingCarButton initButton];
    [self.topBarShoppingCarButton addTarget:self action:@selector(shoppingCarButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.topBarShoppingCarButton];
//     __weak UIView *weakBarView = self.view;
    [self.topBarShoppingCarButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@70);
        make.height.equalTo(@50);
        make.top.mas_equalTo(25);
        make.right.mas_equalTo(-20);
    }];
    

   
    if (self.isModityCart) {
        self.topBarShoppingCarButton.hidden = YES;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateShoppingCarNotification:)
                                                 name:kUpdateShoppingCarNotification
                                               object:nil];
    
    //滚动图片集
    anibool=YES;
    //_totalPages = 2;
    if (_totalPages > 1) {
        UISwipeGestureRecognizer *recRight=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeLeftRight:)];
        recRight.direction=UISwipeGestureRecognizerDirectionLeft;
        [_scrollView addGestureRecognizer:recRight];
        UISwipeGestureRecognizer *recdown=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeLeftRight:)];
        recdown.direction=UISwipeGestureRecognizerDirectionRight;
        [_scrollView addGestureRecognizer:recdown];
    }
    [self setViews];
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

- (IBAction)closeBtnHandler:(id)sender {
    //判断当前用户角色，是否是showroom->brand
    if([YYUser isShowroomToBrand]){
        if(_isShowroomToScan){
            AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            YYStylesAndTotalPriceModel *stylesAndTotalPriceModel = [appdelegate.cartModel getTotalValueByOrderInfo:NO];
            if(stylesAndTotalPriceModel.totalStyles)
            {
                WeakSelf(ws);
                CMAlertView *alertView = [[CMAlertView alloc] initWithTitle:NSLocalizedString(@"确定返回Showroom？",nil) message:NSLocalizedString(@"返回后，此品牌购物车内的款式将被清空",nil) needwarn:NO delegate:nil cancelButtonTitle:NSLocalizedString(@"暂不返回_no",nil) otherButtonTitles:@[NSLocalizedString(@"返回主页_yes",nil)] otherBtnBackColor:@"000000"];
                alertView.specialParentView = self.view;
                [alertView setAlertViewBlock:^(NSInteger selectedIndex){
                    if (selectedIndex == 1) {
                        [ws backAction];
                    }
                }];
                [alertView show];
            }else
            {
                [self backAction];
            }
        }else{
            [self.navigationController popViewControllerAnimated:YES];
        }
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}
-(void)backAction
{
    if (![YYNetworkReachability connectedToNetwork]) {
        //清除购物车
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate clearBuyCar];
        appDelegate.leftMenuIndex = 0;
        [YYUser removeTempUser];
        [self.navigationController popViewControllerAnimated:YES];
    }else{

        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [YYShowroomApi brandToShowroomBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYUserModel *userModel, NSError *error) {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            if(rspStatusAndMessage.status == YYReqStatusCode100){
                //清除购物车
                AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                [appDelegate clearBuyCar];
                appDelegate.leftMenuIndex = 0;
                [self.navigationController popViewControllerAnimated:YES];
            }else{

                [YYToast showToastWithView:self.view title:rspStatusAndMessage.message andDuration:kAlertToastDuration];
            }
        }];
    }
}
//在视图出现的时候更新购物车数据
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self updateShoppingCar];

    // 进入埋点
    [MobClick beginLogPageView:kYYPageStyleDetail];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    // 退出埋点
    [MobClick endLogPageView:kYYPageStyleDetail];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark --进入购物车
- (void)shoppingCarButtonClicked:(id)sender{
    
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
            
            //AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            //if (!appDelegate.cartModel){
                //如果购物车为空了，进入订单列表界面
            [[NSNotificationCenter defaultCenter] postNotificationName:kShowOrderListNotification object:nil];
            //}
        }];
    }];
    
    [self presentViewController:nav animated:YES completion:nil];
}

//缓存到内存
- (void)cacheDataByCurrentPage{
    int offset = 1;
    
    NSMutableArray *needCacheArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    for (int j= _currentPage-offset; j<=_currentPage+offset; j++) {
        int nowIndex = j;
        if (nowIndex < 0) {
            nowIndex = _totalPages-abs(nowIndex);
        }
        
        if (nowIndex >= _totalPages) {
            nowIndex = nowIndex-_totalPages;
        }
        
        if (nowIndex>=0 && nowIndex<_totalPages) {
            [needCacheArray addObject:[NSNumber numberWithInt:nowIndex]];
            
            NSString *key = [NSString stringWithFormat:@"%@%i",kDicKeyPrefix,nowIndex];
            YYOpusStyleModel *tempStyleModel = nil;
            StyleSummary *tempStyleSummary = nil;
            if (![_localCacheDic objectForKey:key]) {
                
                if (_currentDataReadType == EDataReadTypeOffline
                    || _currentDataReadType == EDataReadTypeOnline) {
                    tempStyleModel = [_onlineOrOfflineOpusStyleArray objectAtIndex:nowIndex];
                }else if (_currentDataReadType == EDataReadTypeCached){
                    tempStyleSummary = [_cachedOpusStyleArray objectAtIndex:nowIndex];
                }
                
                
                
                UIViewController *viewController = [self loadViewByYYOpusStyleModel:tempStyleModel orStyleSummary:tempStyleSummary];
                UIView *tempView = viewController.view;
                tempView.tag = tagOffset+nowIndex;
                tempView.layer.shadowColor = [UIColor lightGrayColor].CGColor;//阴影颜色
                tempView.layer.shadowOffset = CGSizeMake(0,0);//偏移距离
                tempView.layer.shadowOpacity = 0.5;//不透明度
                tempView.layer.shadowRadius = 4.0;//半径
                [_localCacheDic setObject:viewController forKey:key];
            }

            UIView *tempView = nil;
            CGAffineTransform newTransform = CGAffineTransformIdentity;
            __block CGRect blockrect = [self getViewFrameTag:0];
            if(j == _currentPage-1 && _totalPages>2){
                blockrect = [self getViewControllerFrameTag:3];
                _detailContentViewController3 = [_localCacheDic objectForKey:key];
                tempView = _detailContentViewController3.view;
                
                newTransform = CGAffineTransformMakeScale(0.9, 0.9);
                [tempView setTransform:newTransform];

            }else if(j == _currentPage){
                blockrect = [self getViewControllerFrameTag:1];
                _detailContentViewController1 = [_localCacheDic objectForKey:key];
                tempView = _detailContentViewController1.view;
               // newTransform =CGAffineTransformMakeScale( 1.0, 1.0);
                [tempView setTransform:newTransform];
            }else if(j == _currentPage+1 && _totalPages>1){
                blockrect = [self getViewControllerFrameTag:2];
                _detailContentViewController2 = [_localCacheDic objectForKey:key];
                tempView = _detailContentViewController2.view;
                tempView.layer.contentsScale = 0.9/[UIScreen mainScreen].scale;
                newTransform =CGAffineTransformMakeScale( 0.9, 0.9);
                [tempView setTransform:newTransform];
            }
            //[_scrollView addSubview:tempView];
            [_scrollView insertSubview:tempView atIndex:0];
            [tempView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(CGRectGetMinX(blockrect));
                make.top.mas_equalTo(CGRectGetMinY(blockrect));
                make.width.mas_equalTo(CGRectGetWidth(blockrect));
                make.height.mas_equalTo(CGRectGetHeight(blockrect));
            }];
        }
    }
    
    NSArray *keys = [_localCacheDic allKeys];

    if (keys
        && [keys count] > 0) {
        for (NSString *key in keys) {
            NSString *index = [key substringFromIndex:14];
            
            NSNumber *number = [NSNumber numberWithInt:[index integerValue]];
            if (![needCacheArray containsObject:number]) {
                UIViewController *viewController = [_localCacheDic objectForKey:key];
                [_localCacheDic removeObjectForKey:key];
                [_templocalCacheArr addObject:viewController];
            }
        }
    }
}


- (UIViewController *)loadViewByYYOpusStyleModel:(YYOpusStyleModel *)opusStyleModel orStyleSummary:(StyleSummary *)styleSummary{
    YYDetailContentViewController *detailContentViewController = nil;
    bool iscacheViewController = NO;
    if([_templocalCacheArr count] > 0){
        detailContentViewController = [_templocalCacheArr objectAtIndex:0];
        [_templocalCacheArr removeObjectAtIndex:0];
        iscacheViewController = YES;
    }else{
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Opus" bundle:[NSBundle mainBundle]];
        detailContentViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYDetailContentViewController"];
    }
    detailContentViewController.currentStyleSummary = styleSummary;
    detailContentViewController.series = self.series;
    
    detailContentViewController.currentDataReadType = self.currentDataReadType;
    
    detailContentViewController.currentOpusStyleModel = opusStyleModel;
    detailContentViewController.opusSeriesModel = _opusSeriesModel;
    detailContentViewController.selectTaxType=_selectTaxType;

    detailContentViewController.styleDetailViewController = self;
    detailContentViewController.isToScan = _isToScan;
    if(iscacheViewController){
        [detailContentViewController laodData];
    }
    return detailContentViewController;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

-(void)setChildView:(UIView *)view{
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(600);
        make.height.mas_equalTo(400);
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(0);
    }];
}

-(NSString *)getShowDateRangeStr:(StyleDateRange *)dateRange{
    
    return  [NSString stringWithFormat:NSLocalizedString(@"%@ :%@-%@",nil),dateRange.name,getShowDateByFormatAndTimeInterval(@"yyyy/MM/dd",[dateRange.start stringValue]),getShowDateByFormatAndTimeInterval(@"yyyy/MM/dd",[dateRange.end stringValue])];
}

-(CGRect)getViewFrameTag:(NSInteger)tag{
    CGFloat leftSpcae = 29;
    CGFloat viewSpace = 42;
    CGFloat myH=636;
    CGFloat myW = SCREEN_WIDTH - leftSpcae - viewSpace - 40;
    CGFloat smallH = myH*0.9;
    CGFloat smallW = myW*0.9;
    
    
    if(tag == 1){
        return CGRectMake(leftSpcae, 4, myW, myH);
    }else if(tag == 2){
        return CGRectMake(leftSpcae+myW+viewSpace, (myH - smallH)/2, smallW, smallH);
    }else if(tag == 3){//
        return  CGRectMake(leftSpcae-smallW-viewSpace, (myH - smallH)/2, smallW, smallH);
    }
    return CGRectMake(0,0,0,0);
}

-(CGRect)getViewControllerFrameTag:(NSInteger)tag{
    CGFloat leftSpcae = 29;
    CGFloat viewSpace = 42;
    CGFloat myH=636;//SCREEN_HEIGHT - 70-70 ;
    CGFloat myW = SCREEN_WIDTH - leftSpcae - viewSpace - 40;
//    CGFloat smallH = myH*0.9;
    CGFloat smallW = myW*0.9;
    CGFloat offsetX = (myW-smallW)/2;

    
    if(tag == 1){
        return CGRectMake(leftSpcae, 4, myW, myH);
    }else if(tag == 2){
        return CGRectMake(leftSpcae+myW+viewSpace-offsetX, 0, myW, myH);
    }else if(tag == 3){//
        return  CGRectMake(leftSpcae-myW-viewSpace+offsetX, 0, myW, myH);
    }
    return CGRectMake(0,0,0,0);
}

-(void)setViews{
    self.viewImage1 = [[UIImageView alloc] init];//
    self.viewImage2 =  [[UIImageView alloc] init];//
    self.viewImage3 = [[UIImageView alloc] init];//
    [_scrollView.layer setMasksToBounds:YES];

    viewndex = 1;
    for ( int i = 1 ; i <= 3 ; ++i ){
        UIView *subv = nil;
        if (i == 1) {
            subv = _viewImage1;
            //subv.frame = CGRectMake(leftSpcae, 0, myW, myH);
            subv .backgroundColor = [UIColor redColor];
        }else if (i == 2) {
            subv = _viewImage2;
            //subv.frame = CGRectMake(leftSpcae+myW+viewSpace, (myH - smallH)/2, smallW, smallH);
            subv .backgroundColor = [UIColor yellowColor];
        }else if (i == 3) {
            subv = _viewImage3;
           // subv.frame = CGRectMake(leftSpcae-smallW-viewSpace, (myH - smallH)/2, smallW, smallH);
            subv .backgroundColor = [UIColor greenColor];
        }
        subv.frame = [self getViewFrameTag:i];
        subv.tag=i;
        //subv.clipsToBounds  = YES;
        //添加四个边阴影
        subv.layer.shadowColor = [UIColor lightGrayColor].CGColor;//阴影颜色
        subv.layer.shadowOffset = CGSizeMake(0,0);//偏移距离
        subv.layer.shadowOpacity = 0.5;//不透明度
        subv.layer.shadowRadius = 4.0;//半径
        [_scrollView addSubview:subv];

    }
    self.viewImage1.hidden = YES;
    self.viewImage2.hidden = YES;
    self.viewImage3.hidden = YES;
    [self updatePageUI];
}

-(void)swipeLeftRight:(UISwipeGestureRecognizer *)zer
{
    if (zer.direction==UISwipeGestureRecognizerDirectionLeft) {
        [self setAllFramge:0];
    }else if(zer.direction==UISwipeGestureRecognizerDirectionRight){
        [self setAllFramge:1];
    }
}

-(void)setAllFramge:(int)tag{
    
    if (anibool==NO) {
        return;
    }
    anibool=NO;
    [self initScrollViewImages:tag];
    
    if (_totalPages >= 2) {
        if (tag == 0) {
            if (_currentPage < (_totalPages - 1)) {
                _currentPage ++;
            } else {
                _currentPage = 0;
            }
            
        } else if (tag == 1) {
            if (_currentPage > 0) {
                _currentPage --;
            } else {
                _currentPage = _totalPages - 1;
            }
            
        }
    }else  if(_totalPages == 1){
        _currentPage = 0;
    }
    unsigned long count=3;
    if (tag==1) {
        [UIView animateWithDuration:0.4 animations:^{
            CGRect rect=[self getViewFrameTag:1];
            CGRect rect1=[self getViewFrameTag:2];
            [[_scrollView viewWithTag:1] setFrame:rect1];
            [_scrollView viewWithTag:2].hidden = YES;
            [[_scrollView viewWithTag:3] setFrame:rect];
        } completion:^(BOOL finished) {
            anibool=YES;
            [self bigtop];
        }];
        
    }else{
        [UIView animateWithDuration:0.4 animations:^{
            CGRect rect=[self getViewFrameTag:count];//[[_scrollView
            [_scrollView viewWithTag:3].hidden = YES;
            CGRect rect1=[self getViewFrameTag:1];
            [[_scrollView viewWithTag:2] setFrame:rect1];
            [[_scrollView viewWithTag:1] setFrame:rect];
        } completion:^(BOOL finished) {
            anibool=YES;
            [self bigtop];
            
        }];
    }
}

-(void)bigtop{
    [self updatePageUI];
    self.viewImage1.hidden = YES;
    self.viewImage2.hidden = YES;
    self.viewImage3.hidden = YES;
}

-(void)updatePageUI{
    [self cacheDataByCurrentPage];
}

-(void) initScrollViewImages:(NSInteger)tag{
    if (_totalPages == 2) {
        [self reloadViewControllerData:self.viewImage1 data:_detailContentViewController1];
        [self reloadViewControllerData:self.viewImage2 data:_detailContentViewController2];
        [self reloadViewControllerData:self.viewImage3 data:_detailContentViewController2];

    }else if (_totalPages == 1){
        [self reloadViewControllerData:self.viewImage1 data:_detailContentViewController1];
    }else{
        [self reloadViewControllerData:self.viewImage1 data:_detailContentViewController1];
        [self reloadViewControllerData:self.viewImage2 data:_detailContentViewController2];
        [self reloadViewControllerData:self.viewImage3 data:_detailContentViewController3];

    }
    self.viewImage1.hidden = NO;
    self.viewImage2.hidden = NO;
    self.viewImage3.hidden = NO;
    self.viewImage1.frame = [self getViewFrameTag:1];
    self.viewImage2.frame = [self getViewFrameTag:2];
    self.viewImage3.frame = [self getViewFrameTag:3];
    if(_detailContentViewController1){
        [_detailContentViewController1.view removeFromSuperview];
    }
    if(_detailContentViewController2){
        [_detailContentViewController2.view removeFromSuperview];
    }
    if(_detailContentViewController3){
        [_detailContentViewController3.view removeFromSuperview];
    }
}

-(void)reloadViewControllerData:(UIImageView *)viewController0 data:(UIViewController*)data{
    UIImage *viewControllerImage = [self snapshot:data.view];
    viewController0.contentMode = UIViewContentModeScaleToFill;
    viewController0.image = viewControllerImage;
}

#pragma mark - Private method

- (UIImage *)snapshot:(UIView *)view{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size,YES,0);
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:YES];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end

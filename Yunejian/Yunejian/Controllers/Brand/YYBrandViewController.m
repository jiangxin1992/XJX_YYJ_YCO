//
//  YYBrandViewController.m
//  Yunejian
//
//  Created by Apple on 15/12/2.
//  Copyright © 2015年 yyj. All rights reserved.
//

#import "YYBrandViewController.h"

#import "YYTopBarShoppingCarButton.h"
#import "YYPageInfoModel.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import <MJRefresh.h>
#import "YYBrandViewCell.h"
#import "YYMessageButton.h"
#import "YYConnMsgListController.h"
#import "YYOrderApi.h"
#import "YYConnApi.h"
#import "YYBrandSeriesViewController.h"
#import "YYConnAddViewController.h"

@interface YYBrandViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,YYTableCellDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet YYTopBarShoppingCarButton *topBarShoppingCarButton;
@property (weak, nonatomic) IBOutlet UIView *msgBtnContainer;
@property (weak, nonatomic) IBOutlet UIButton *connedBtn;
@property (weak, nonatomic) IBOutlet UIButton *conningBtn;
@property (nonatomic,strong)YYPageInfoModel *currentPageInfo;
@property (nonatomic,strong) UIView *noDataView;
@property (nonatomic,assign) NSInteger currentListType;
@property (nonatomic,strong) YYMessageButton *messageButton;
@property (nonatomic,strong) NSMutableArray *brandListArray;
@end

@implementation YYBrandViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.topBarShoppingCarButton initButton];
    
    _messageButton = [[YYMessageButton alloc] init];
    [_messageButton initButton:NSLocalizedString(@"合作消息_pad",nil)];
    [self messageCountChanged:nil];
    [_msgBtnContainer addSubview:_messageButton];
    [_messageButton addTarget:self action:@selector(messageButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageCountChanged:) name:UnreadConnNotifyMsgAmount object:nil];
    __weak UIView *weakContainerView = _msgBtnContainer;
    [_messageButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(weakContainerView.mas_bottom);
        make.left.equalTo(weakContainerView.mas_left);
        make.top.equalTo(weakContainerView.mas_top);
        make.right.equalTo(weakContainerView.mas_right);
    }];
    
    _currentListType = 1;
    [_conningBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    
    
    [self addHeader];
    [self addFooter];
    
    self.collectionView.alwaysBounceVertical = YES;
    self.noDataView = addNoDataView_pad(self.view,nil,nil,nil);
    self.noDataView.hidden = YES;
    
    if ([YYNetworkReachability connectedToNetwork]) {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        UIView *superView = appDelegate.window.rootViewController.view;
        
        [MBProgressHUD showHUDAddedTo:superView animated:YES];
    }
    [self connedBtnHandler:nil];
}

- (void)messageCountChanged:(NSNotification *)notification{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if(appDelegate.unreadConnNotifyMsgAmount > 0){
        [_messageButton updateButtonNumber:[NSString stringWithFormat:@"%ld",(long)appDelegate.unreadConnNotifyMsgAmount]];
    }else{
        [_messageButton updateButtonNumber:@""];
    }
}

- (void)messageButtonClicked:(id)sender {  
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Account" bundle:[NSBundle mainBundle]];
    YYConnMsgListController *messageViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYConnMsgListController"];
    [messageViewController setMarkAsReadHandler:^(void){
        [YYConnMsgListController markAsRead];
    }];
    [self.navigationController pushViewController:messageViewController animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)shoppingCarClicked:(id)sender{
}

- (IBAction)addBrandHandler:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Brand" bundle:[NSBundle mainBundle]];
    YYConnAddViewController *addBrandViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYConnAddViewController"];
    [self.navigationController pushViewController:addBrandViewController animated:YES];

}
- (IBAction)connedBtnHandler:(id)sender {
    if (!sender || _currentListType != 1) {
        _connedBtn.enabled = NO;
        [_connedBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        _currentListType = 1;
        [_conningBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        _conningBtn.enabled = YES;

        [self loadDataByPageIndex:1];
    }
}
- (IBAction)conningBtnHandler:(id)sender {
    if (_currentListType != 2) {
        _conningBtn.enabled = NO;
        [_conningBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        _currentListType = 2;
        [_connedBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        _connedBtn.enabled = YES;
        
        
        [self loadDataByPageIndex:1];
    }
}
#pragma MJRefresh.h
//刷新界面
- (void)reloadCollectionViewData{
    [self.collectionView.mj_header endRefreshing];
    [self.collectionView.mj_footer endRefreshing];
    [self.collectionView reloadData];
    
    if (!self.brandListArray || [self.brandListArray count ]==0) {
        self.noDataView.hidden = NO;
    }else{
        self.noDataView.hidden = YES;
    }
}

- (void)loadDataByPageIndex:(int)pageIndex{
    WeakSelf(ws);
    [YYConnApi getConnBrands:_currentListType andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYConnBrandInfoListModel *listModel, NSError *error) {
        if (rspStatusAndMessage.status == kCode100){
            ws.currentPageInfo = listModel.pageInfo;
            if( !ws.currentPageInfo || ws.currentPageInfo.isFirstPage){
                ws.brandListArray =  [[NSMutableArray alloc] init];//;
            }
            [ws.brandListArray addObjectsFromArray:listModel.result];
            dispatch_async(dispatch_get_main_queue(), ^{
                [ws reloadCollectionViewData];
            });
        }

        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        UIView *superView = appDelegate.window.rootViewController.view;
        
        [MBProgressHUD hideAllHUDsForView:superView animated:YES];
        
        if (rspStatusAndMessage.status != kCode100) {
            [YYToast showToastWithTitle:rspStatusAndMessage.message  andDuration:kAlertToastDuration];
        }
    }];
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

        if ([ws.brandListArray count] > 0
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
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)collectionView.collectionViewLayout;
    
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 15);
    
    
    return [self.brandListArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    YYConnBrandInfoModel * brandInfoModel = [self.brandListArray objectAtIndex:indexPath.row];
    static NSString* reuseIdentifier = @"YYBrandViewCell";
    YYBrandViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.indexPath = indexPath;
    cell.delegate = self;
    cell.brandInfoModel = brandInfoModel;
    if(_currentListType == 1){
        
        [cell.cancelBtn setTitle:[[NSString alloc] initWithFormat:@"— %@",NSLocalizedString(@"解除合作",nil)] forState:UIControlStateNormal];
    }else{
        [cell.cancelBtn setTitle:[[NSString alloc] initWithFormat:@"— %@",NSLocalizedString(@"取消邀请",nil)] forState:UIControlStateNormal];
    }
    [cell updateUI];
    
    return cell;
}

#pragma YYTableCellDelegate
-(void)btnClick:(NSInteger)row section:(NSInteger)section andParmas:(NSArray *)parmas{
    if(parmas == nil){
        if(_currentListType == 2){
            
            [YYToast showToastWithTitle:NSLocalizedString(@"还没建立合作关系，无法查看",nil) andDuration:kAlertToastDuration];
            return;
        }
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Brand" bundle:[NSBundle mainBundle]];
        YYBrandSeriesViewController *seriesDetailViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYBrandSeriesViewController"];
        YYConnBrandInfoModel * brandInfoModel = [self.brandListArray objectAtIndex:row];
        seriesDetailViewController.designerId = [brandInfoModel.designerId integerValue];
        [self.navigationController pushViewController:seriesDetailViewController animated:YES];
    }else{
        WeakSelf(ws);
        YYConnBrandInfoModel * brandInfoModel = [self.brandListArray objectAtIndex:row];
        __block YYConnBrandInfoModel * blockBrandInfoModel = brandInfoModel;
        if(_currentListType == 1){
            
            CMAlertView *alertView = [[CMAlertView alloc] initWithTitle:NSLocalizedString(@"解除合作吗？",nil) message:NSLocalizedString(@"解除合作后，将不能浏览本品牌作品。确认解除合作吗？",nil) needwarn:NO delegate:nil cancelButtonTitle:NSLocalizedString(@"继续合作_no",nil) otherButtonTitles:@[NSLocalizedString(@"解除合作_yes",nil)]];
            [alertView setAlertViewBlock:^(NSInteger selectedIndex){
                if (selectedIndex == 1) {
                    [ws oprateConnWithDesigner:[blockBrandInfoModel.designerId integerValue] status:3];
                }
            }];
            
            [alertView show];
        }else if(_currentListType == 2){
            CMAlertView *alertView = [[CMAlertView alloc] initWithTitle:NSLocalizedString(@"取消邀请吗？",nil) message:nil needwarn:NO delegate:nil cancelButtonTitle:NSLocalizedString(@"继续邀请_no",nil) otherButtonTitles:@[NSLocalizedString(@"取消邀请_yes",nil)]];
            [alertView setAlertViewBlock:^(NSInteger selectedIndex){
                if (selectedIndex == 1) {
                    [ws oprateConnWithDesigner:[blockBrandInfoModel.designerId integerValue] status:2];
                }
            }];
            
            [alertView show];
        }
    }
}

// 1->同意邀请	2->拒绝邀请	3->移除合作
- (void)oprateConnWithDesigner:(NSInteger)designerId status:(NSInteger)status{
    WeakSelf(ws);
    [YYConnApi OprateConnWithDesignerBrand:designerId status:status andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSError *error) {
        if(rspStatusAndMessage.status == kCode100){
            [YYToast showToastWithTitle:rspStatusAndMessage.message andDuration:kAlertToastDuration];
            [ws loadDataByPageIndex:1];
        }
        
    }];
}
@end

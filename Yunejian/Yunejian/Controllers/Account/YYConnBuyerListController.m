//
//  YYConnInfoListController.m
//  Yunejian
//
//  Created by Apple on 15/12/1.
//  Copyright © 2015年 yyj. All rights reserved.
//

#import "YYConnBuyerListController.h"

#import "YYUserApi.h"
#import "YYNavigationBarViewController.h"
#import <MJRefresh.h>
#import "MBProgressHUD.h"
#import "YYConnApi.h"
#import "YYConnBuyerInfoViewController.h"
#import "YYConnBuyerInfoListCell.h"
#import "UIImage+Tint.h"
#import "YYNoDataView.h"

@interface YYConnBuyerListController ()<YYTableCellDelegate,UICollectionViewDataSource,UICollectionViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *editBtn;

@property (nonatomic,strong)YYPageInfoModel *currentPageInfo;
@property (strong, nonatomic) NSMutableArray *msgListArray;
@property (weak, nonatomic) IBOutlet UIButton *connedBtn;
@property (weak, nonatomic) IBOutlet UIButton *conningBtn;

@property (nonatomic,strong) YYNoDataView *noDataView;
@property (nonatomic,assign) NSInteger currentListType;
@property (strong, nonatomic) NSMutableArray *currentListTypeArray;
@property (nonatomic , assign) BOOL isModity;

@property (nonatomic,strong) YYNavigationBarViewController *navigationBarViewController;
@end

@implementation YYConnBuyerListController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    YYNavigationBarViewController *navigationBarViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYNavigationBarViewController"];
    navigationBarViewController.previousTitle = NSLocalizedString(@"账户",nil);
    
    NSString *title = NSLocalizedString(@"我的买手店",nil);
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
    
    self.noDataView = (YYNoDataView*)addNoDataView_pad(self.view,[NSString stringWithFormat:@"%@/n%@|icon:noconn_icon",NSLocalizedString(@"还没有合作的买手店",nil),NSLocalizedString(@"请登录YCO SYSTEM官网，邀请合作买手店。",nil)],nil,nil);
    _noDataView.hidden = YES;
//    _tableView.separatorColor = [UIColor colorWithHex:kDefaultImageColor];
//    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//    _tableView.separatorInset = UIEdgeInsetsMake(0, 40, 0,40 );
    
    self.collectionView.alwaysBounceVertical = YES;

    
    [self addHeader];
    [self addFooter];
    
    [self setTabListData];
    
    _currentListType = 1;//默认正常的，1是已经取消的
    [self connedButtonClicked:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    // 进入埋点
    [MobClick beginLogPageView:kYYPageConnBuyerList];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    // 退出埋点
    [MobClick endLogPageView:kYYPageConnBuyerList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)editHandler:(id)sender {
    _isModity = !_isModity;
    if(_isModity == NO){
        [_editBtn setTitle:NSLocalizedString(@"编辑",nil) forState:UIControlStateNormal];
        [_editBtn setImage:[UIImage imageNamed:@"pencil1"] forState:UIControlStateNormal];
    }else{
        [_editBtn setTitle:NSLocalizedString(@"完成",nil) forState:UIControlStateNormal];
        [_editBtn setImage:nil forState:UIControlStateNormal];
    }
    [_collectionView reloadData];
}


#pragma MJRefresh.h
- (void)addHeader{
    WeakSelf(ws);
    // 添加下拉刷新头部控件
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        // 进入刷新状态就会回调这个Block
        [ws loadMsgListWithpageIndex:1];
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
            //[YYToast showToastWithTitle:kNetworkIsOfflineTips andDuration:kAlertToastDuration];
            [ws.collectionView.mj_footer endRefreshing];
            return;
        }
        if ([ws.msgListArray count] > 0
            && ws.currentPageInfo
            && !ws.currentPageInfo.isLastPage) {
            [ws loadMsgListWithpageIndex:[ws.currentPageInfo.pageIndex intValue]+1];
        }else{
            [ws.collectionView.mj_footer endRefreshing];
        }
    }];
}

//请求买家地址列表
-(void)loadMsgListWithpageIndex:(NSInteger)pageIndex{
    WeakSelf(ws);
    [YYConnApi getConnBuyers:_currentListType pageIndex:pageIndex pageSize:8 andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYConnBuyerListModel *listModel, NSError *error) {
        if(rspStatusAndMessage.status == kCode100){
            ws.currentPageInfo = listModel.pageInfo;
            if( !ws.currentPageInfo || ws.currentPageInfo.isFirstPage){
                ws.msgListArray =  [[NSMutableArray alloc] init];//;
            }
            [ws.msgListArray addObjectsFromArray:listModel.result];
            [ws setTabListData];
            dispatch_async(dispatch_get_main_queue(), ^{
                [ws.collectionView reloadData];
            });
        }
        [ws.collectionView.mj_header endRefreshing];
        [ws.collectionView.mj_footer endRefreshing];
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }];
    
}

-(void)setTabListData{
//    _currentListTypeArray = [[NSMutableArray alloc] init];
//    NSInteger connedNum = 0;
//    NSInteger conningNum = 0;
//    for (YYConnBuyerModel *model in self.msgListArray) {
//        if([model.status integerValue] == 1){
//            if(_currentListType == 0){
//                [_currentListTypeArray addObject:model];
//            }
//            connedNum ++;
//        }else if( [model.status integerValue] == 0){
//            if(_currentListType == 1){
//                [_currentListTypeArray addObject:model];
//            }
//            conningNum ++;
//        }
//    }
    _currentListTypeArray = self.msgListArray;
    if(_currentListType == 1){
        if(_currentPageInfo){
            _connedNum = [_currentPageInfo.recordTotalAmount integerValue];
        }
        _noDataView.titleLabel.text = NSLocalizedString(@"还没有合作的买手店",nil);
    }else{
        if(_currentPageInfo){
            _conningNum = [_currentPageInfo.recordTotalAmount integerValue];
        }
        
        _noDataView.titleLabel.text = NSLocalizedString(@"还没有邀请中的买手店",nil);
    }
    if([_currentListTypeArray count] > 0){
        _noDataView.hidden = YES;
    }else{
        _noDataView.hidden = NO;
    }
    [_connedBtn setTitle:[NSString stringWithFormat:NSLocalizedString(@"合作的买手店 %d",nil),_connedNum] forState:UIControlStateNormal];
    [_conningBtn setTitle:[NSString stringWithFormat:NSLocalizedString(@"邀请中的买手店 %d",nil),_conningNum] forState:UIControlStateNormal];

}

- (IBAction)connedButtonClicked:(id)sender{
    if (!sender || _currentListType != 1) {
        _connedBtn.enabled = NO;
        [_connedBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        _currentListType = 1;
        [_conningBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        _conningBtn.enabled = YES;

        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [self loadMsgListWithpageIndex:1];
    }
}

- (IBAction)conningButtonClicked:(id)sender{
    if (_currentListType != 0) {
        _conningBtn.enabled = NO;
        [_conningBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        _currentListType = 0;
        [_connedBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        _connedBtn.enabled = YES;

        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [self loadMsgListWithpageIndex:1];

    }
}
#pragma YYTableCellDelegate
-(void)btnClick:(NSInteger)row section:(NSInteger)section andParmas:(NSArray *)parmas{
   WeakSelf(ws);
    YYConnBuyerModel * infoModel = [self.currentListTypeArray objectAtIndex:row];
    if([infoModel.status integerValue] == kConnStatus1){
        CMAlertView *alertView = [[CMAlertView alloc] initWithTitle:NSLocalizedString(@"解除合作吗？",nil) message:NSLocalizedString(@"解除合作后，买手店将不能浏览本品牌作品。确认解除合作吗？",nil) needwarn:NO delegate:nil cancelButtonTitle:NSLocalizedString(@"继续合作_no",nil) otherButtonTitles:@[NSLocalizedString(@"解除合作_yes",nil)]];
        alertView.specialParentView = self.view;
        [alertView setAlertViewBlock:^(NSInteger selectedIndex){
            if (selectedIndex == 1) {
                [ws oprateConnWithBuyer:[infoModel.buyerId integerValue] status:3];
            }
        }];
        
        [alertView show];
    }else if([infoModel.status integerValue] == kConnStatus0){
        CMAlertView *alertView = [[CMAlertView alloc] initWithTitle:NSLocalizedString(@"取消邀请吗？",nil) message:nil needwarn:NO delegate:nil cancelButtonTitle:NSLocalizedString(@"继续邀请_no",nil) otherButtonTitles:@[NSLocalizedString(@"取消邀请_yes",nil)]];
        alertView.specialParentView = self.view;
        [alertView setAlertViewBlock:^(NSInteger selectedIndex){
            if (selectedIndex == 1) {
                 [ws oprateConnWithBuyer:[infoModel.buyerId integerValue] status:4];
            }
        }];
        
        [alertView show];
    }
}
// 1->同意邀请	2->拒绝邀请	3->移除合作
- (void)oprateConnWithBuyer:(NSInteger)buyerId status:(NSInteger)status{
    WeakSelf(ws);
    [YYConnApi OprateConnWithBuyer:buyerId status:status andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSError *error) {
        if(rspStatusAndMessage.status == kCode100){
            [YYToast showToastWithTitle:rspStatusAndMessage.message andDuration:kAlertToastDuration];
            [ws loadMsgListWithpageIndex:1];
        }
    }];
}

#pragma mark -  UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_currentListTypeArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    YYConnBuyerModel * infoModel = [self.currentListTypeArray objectAtIndex:indexPath.row];
    
    static NSString* reuseIdentifier = @"YYConnBuyerInfoListCell";
    YYConnBuyerInfoListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.indexPath = indexPath;
    cell.delegate = self;
    cell.buyermodel = infoModel;
    cell.isModity = _isModity;

    [cell updateUI];
    
    return cell;
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(10, 40, 0, 40);//分别为上、左、下、右
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 10;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    WeakSelf(ws);
    YYConnBuyerModel * infoModel = [self.currentListTypeArray objectAtIndex:indexPath.row];
    [YYUserApi getUserStatus:[infoModel.buyerId integerValue] andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSInteger status, NSError *error) {
        if(rspStatusAndMessage.status == kCode100){
            if(status != kUserStatusStop && status >-1){
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Account" bundle:[NSBundle mainBundle]];
                YYConnBuyerInfoViewController *connInfoController = [storyboard instantiateViewControllerWithIdentifier:@"YYConnBuyerInfoViewController"];
                connInfoController.buyerId = [infoModel.buyerId integerValue];
                connInfoController.previousTitle =  _navigationBarViewController.nowTitle;
                
                //    __block YYConnBuyerModel *blockBuyerModel = infoModel;
                
                [connInfoController setCancelButtonClicked:^(){
                    //        blockBuyerModel.status = [[NSNumber alloc] initWithInt:kConnStatus];//;
                    //        [weakself.collectionView reloadData];
                    [ws.navigationController popViewControllerAnimated:YES];
                    [ws loadMsgListWithpageIndex:1];
                }];

                [ws.navigationController pushViewController:connInfoController animated:YES];
            }else{
                [YYToast showToastWithView:ws.view title:NSLocalizedString(@"此买手店账号已停用",nil) andDuration:kAlertToastDuration];
            }
        }else{
            [YYToast showToastWithView:ws.view title:rspStatusAndMessage.message andDuration:kAlertToastDuration];
        }
    }];
    
    

}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
@end

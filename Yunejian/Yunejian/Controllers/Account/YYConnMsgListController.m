//
//  YYConnMsgListController.m
//  Yunejian
//
//  Created by Apple on 15/12/2.
//  Copyright © 2015年 yyj. All rights reserved.
//

#import "YYConnMsgListController.h"

#import "YYConnBuyerListController.h"
#import "YYUserApi.h"
#import "YYNavigationBarViewController.h"
#import <MJRefresh.h>
#import "MBProgressHUD.h"
#import "YYConnMsgListCell.h"
#import "YYOrderApi.h"
#import "YYConnApi.h"
#import "YYUser.h"
#import "AppDelegate.h"
#import "YYOrderMessageInfoListModel.h"
#import "YYOrderMessageInfoModel.h"
#import "YYConnBuyerInfoViewController.h"

@interface YYConnMsgListController ()<UITableViewDataSource,UITableViewDelegate,YYTableCellDelegate>
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong)YYPageInfoModel *currentPageInfo;
@property (strong, nonatomic) NSMutableArray *msgListArray;

@property (nonatomic,strong) UIView *noDataView;
@property (nonatomic,strong) YYConnBuyerInfoViewController *connInfoController;
@end

@implementation YYConnMsgListController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    YYNavigationBarViewController *navigationBarViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYNavigationBarViewController"];
    navigationBarViewController.previousTitle = NSLocalizedString(@"账户",nil);
    
    NSString *title = @"";
    navigationBarViewController.nowTitle = title;
    
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
            if(ws.markAsReadHandler){
                ws.markAsReadHandler();
            }
            [ws.navigationController popViewControllerAnimated:YES];
            blockVc = nil;
        }
    }];
    
    self.noDataView = addNoDataView_pad(self.view,NSLocalizedString(@"暂无合作消息|icon:nomsg_icon",nil),nil,nil);
    _noDataView.hidden = YES;
    _tableView.separatorColor = [UIColor colorWithHex:kDefaultImageColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0,0 );
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    if(appDelegate.unreadConnNotifyMsgAmount > 0){
//        appDelegate.unreadConnNotifyMsgAmount = 0;
//        
//        [[NSNotificationCenter defaultCenter] postNotificationName:UnreadConnNotifyMsgAmount object:nil userInfo:nil];
//    }
    appDelegate.isOnConnNotifyMsgAUI = YES;

    [self addHeader];
    [self addFooter];
    
    [self loadMsgListWithpageIndex:1];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    // 进入埋点
    [MobClick beginLogPageView:kYYPageConnMsgList];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    // 退出埋点
    [MobClick endLogPageView:kYYPageConnMsgList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark - UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.msgListArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    YYOrderMessageInfoModel *infoModel = [self.msgListArray objectAtIndex:indexPath.row];
    static NSString* reuseIdentifier = @"YYConnMsgListCell";
    YYConnMsgListCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.msgInfoModel = infoModel;
    cell.delegate = self;
    cell.indexPath = indexPath;
    [cell updateUI];
    return cell;
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 110;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    YYOrderMessageInfoModel *infoModel = [self.msgListArray objectAtIndex:indexPath.row];
    if(infoModel && infoModel.msgContent){
        WeakSelf(ws);
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [YYUserApi getUserStatus:[infoModel.msgContent.fromId integerValue] andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSInteger status, NSError *error) {
            if(rspStatusAndMessage.status == YYReqStatusCode100){
                if(status != YYUserStatusStop && status >-1){
                    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Account" bundle:[NSBundle mainBundle]];
                    YYConnBuyerInfoViewController *connInfoController = [storyboard instantiateViewControllerWithIdentifier:@"YYConnBuyerInfoViewController"];
                    connInfoController.buyerId = [infoModel.msgContent.fromId integerValue];
                    connInfoController.previousTitle = infoModel.msgContent.buyerName;
                    ws.connInfoController = connInfoController;
                    //[weakSelf.navigationController pushViewController:connInfoController animated:YES];
                    //[appDelegate.mainViewController pushViewController:connInfoController animated:YES];
                    
                    __weak UIView *weakSuperView = appDelegate.mainViewController.view;
                    UIView *showView = connInfoController.view;
                    __weak UIView *weakShowView = showView;
                    [connInfoController setCancelButtonClicked:^(){
                        removeFromSuperviewUseUseAnimateAndDeallocViewController(weakShowView,ws.connInfoController);
                    }];
                
                    [weakSuperView addSubview:showView];
                    [showView mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.top.equalTo(weakSuperView.mas_top);
                        make.left.equalTo(weakSuperView.mas_left);
                        make.bottom.equalTo(weakSuperView.mas_bottom);
                        make.right.equalTo(weakSuperView.mas_right);
                    }];
                    addAnimateWhenAddSubview(showView);
                
                }else{
                    [YYToast showToastWithView:appDelegate.mainViewController.view title:NSLocalizedString(@"此买手店账号已停用",nil) andDuration:kAlertToastDuration];
                }
            }else{
                [YYToast showToastWithView:appDelegate.mainViewController.view title:rspStatusAndMessage.message andDuration:kAlertToastDuration];
            }
        }];
    }
}
//设置可删除
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.msgListArray.count){
        YYOrderMessageInfoModel *infoModel = [self.msgListArray objectAtIndex:indexPath.row];
        if(infoModel.isPlainMsg == NO){
            if([infoModel.dealStatus integerValue] == -1){
                return YES;
            }
        }
    }
    return NO;
}
// 自定义左滑显示编辑按钮
-(NSArray<UITableViewRowAction*>*)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewRowAction *rowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal
                                                                         title:NSLocalizedString(@"拒绝",nil) handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {

                                                                             if(self.msgListArray.count > 0){
                                                                                 YYOrderMessageInfoModel *infoModel = self.msgListArray[indexPath.row];
                                                                                 [self oprateConnWithMsgInfoModel:infoModel status:2 indexPath:indexPath];
                                                                             }
                                                                         }];
    rowAction.backgroundColor = [UIColor colorWithHex:@"EF4E31"];

    NSArray *arr = @[rowAction];
    return arr;
}
// 1->同意邀请	2->拒绝邀请	3->移除合作 4->取消邀请
- (void)oprateConnWithMsgInfoModel:(YYOrderMessageInfoModel *)infoModel status:(NSInteger)status indexPath:(NSIndexPath *)indexPath{
    WeakSelf(ws);
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [YYConnApi OprateConnWithBuyer:[infoModel.msgContent.fromId integerValue] status:status andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if(rspStatusAndMessage.status == YYReqStatusCode100){
            [YYToast showToastWithTitle:rspStatusAndMessage.message andDuration:kAlertToastDuration];
            //移除并刷新
            if(_tableView){
                if(ws.msgListArray && self.msgListArray.count > indexPath.row){
                    infoModel.dealStatus = @(2);
                    [_tableView reloadData];
                }
            }
        }
    }];
}
#pragma MJRefresh.h
- (void)addHeader{
    WeakSelf(ws);
    // 添加下拉刷新头部控件
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        // 进入刷新状态就会回调这个Block
        [ws loadMsgListWithpageIndex:1];
    }];
    self.tableView.mj_header = header;
    self.tableView.mj_header.automaticallyChangeAlpha = YES;
    header.lastUpdatedTimeLabel.hidden = YES;
}


- (void)addFooter{
    WeakSelf(ws);
    // 添加上拉刷新尾部控件
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        // 进入刷新状态就会回调这个Block

        if (![YYNetworkReachability connectedToNetwork]) {
            //[YYToast showToastWithTitle:kNetworkIsOfflineTips andDuration:kAlertToastDuration];
            [ws.tableView.mj_footer endRefreshing];
            return;
        }

        if ([ws.msgListArray count] > 0
            && ws.currentPageInfo
            && !ws.currentPageInfo.isLastPage) {
            [ws loadMsgListWithpageIndex:[ws.currentPageInfo.pageIndex intValue]+1];
        }else{
            [ws.tableView.mj_footer endRefreshing];
        }
    }];
}

//请求买手地址列表
-(void)loadMsgListWithpageIndex:(NSInteger)pageIndex{
    WeakSelf(ws);
    NSString *type = @"0";
    
    NSInteger pageSize = 10;
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [YYOrderApi getNotifyMsgList:type pageIndex:pageIndex pageSize:pageSize andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYOrderMessageInfoListModel *msgListModel, NSError *error) {
        if(rspStatusAndMessage.status == YYReqStatusCode100){
            ws.currentPageInfo = msgListModel.pageInfo;
            if(ws.currentPageInfo.isFirstPage){
                ws.msgListArray =  [[NSMutableArray alloc] init];//;
            }
            [ws.msgListArray addObjectsFromArray:msgListModel.result];
            if([ws.msgListArray count]){
                ws.noDataView.hidden = YES;
            }else{
                ws.noDataView.hidden = NO;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [ws.tableView reloadData];
            });
        }
        [ws.tableView.mj_header endRefreshing];
        [ws.tableView.mj_footer endRefreshing];
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
    }];
    
}

#pragma YYTableCellDelegate
-(void)btnClick:(NSInteger)row section:(NSInteger)section andParmas:(NSArray *)parmas{
    WeakSelf(ws);
    YYOrderMessageInfoModel *infoModel = [self.msgListArray objectAtIndex:row];
    if([[parmas objectAtIndex:0] integerValue] == 1){
        
        CMAlertView *alertView = [[CMAlertView alloc] initWithTitle:NSLocalizedString(@"同意邀请吗？",nil) message:nil needwarn:NO delegate:nil cancelButtonTitle:NSLocalizedString(@"取消", nil) otherButtonTitles:@[[NSString stringWithFormat:@"%@|000000",NSLocalizedString(@"确定",nil)]]];
        alertView.specialParentView = self.view;
        [alertView setAlertViewBlock:^(NSInteger selectedIndex){
            if (selectedIndex == 1) {
                [ws oprateConnWithBuyer:[infoModel.senderId integerValue] status:1 row:row];
            }
        }];
        
        [alertView show];
    }else if([[parmas objectAtIndex:0] integerValue] == 2){
        
        CMAlertView *alertView = [[CMAlertView alloc] initWithTitle:NSLocalizedString(@"拒绝邀请吗？",nil) message:nil needwarn:NO delegate:nil cancelButtonTitle:NSLocalizedString(@"取消", nil) otherButtonTitles:@[[NSString stringWithFormat:@"%@|000000",NSLocalizedString(@"确定",nil)]]];
        alertView.specialParentView = self.view;
        [alertView setAlertViewBlock:^(NSInteger selectedIndex){
            if (selectedIndex == 1) {
                [ws oprateConnWithBuyer:[infoModel.senderId integerValue] status:2 row:row];
            }
        }];
        
        [alertView show];
    }
}
// 1->同意邀请	2->拒绝邀请	3->移除合作 4取消邀请
- (void)oprateConnWithBuyer:(NSInteger)buyerId status:(NSInteger)status row:(NSInteger)row{
    WeakSelf(ws);
    __block NSInteger blockStatus = status;
    __block NSInteger blockRow = row;
    YYUser *user = [YYUser currentUser];
    if(user.userType != YYUserTypeRetailer){
    [YYConnApi OprateConnWithBuyer:buyerId status:status andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSError *error) {
        if(rspStatusAndMessage.status == YYReqStatusCode100){
            [YYToast showToastWithTitle:rspStatusAndMessage.message andDuration:kAlertToastDuration];
            YYOrderMessageInfoModel *infoModel = [ws.msgListArray objectAtIndex:blockRow];

            infoModel.dealStatus = [[NSNumber alloc] initWithInt:blockStatus];
            [ws.tableView reloadData];
            //[ws loadMsgListWithpageIndex:1];
        }
    }];
    }else{
        [YYConnApi OprateConnWithDesignerBrand: buyerId status:status andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSError *error) {
            if(rspStatusAndMessage.status == YYReqStatusCode100){
                [YYToast showToastWithTitle:rspStatusAndMessage.message andDuration:kAlertToastDuration];
                YYOrderMessageInfoModel *infoModel = [ws.msgListArray objectAtIndex:blockRow];
                
                infoModel.dealStatus = [[NSNumber alloc] initWithInt:blockStatus];
                [ws.tableView reloadData];
                //[weakSwself loadMsgListWithpageIndex:1];
            }
        }];
    }
}


+(void)markAsRead{
    [YYOrderApi markAsRead:0 andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSError *error) {
        
    }];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if(appDelegate.unreadConnNotifyMsgAmount > 0){
        appDelegate.unreadConnNotifyMsgAmount = 0;
        [[NSNotificationCenter defaultCenter] postNotificationName:UnreadConnNotifyMsgAmount object:nil userInfo:nil];
    }
    appDelegate.isOnConnNotifyMsgAUI = NO;
}
@end

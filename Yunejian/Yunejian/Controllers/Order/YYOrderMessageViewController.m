//
//  YYOrderMessageViewController.m
//  Yunejian
//
//  Created by Apple on 15/10/26.
//  Copyright © 2015年 yyj. All rights reserved.
//

#import "YYOrderMessageViewController.h"

// c文件 —> 系统文件（c文件在前）

// 控制器
#import "YYOrderDetailViewController.h"
#import "YYNavigationBarViewController.h"
#import "YYConnBuyerInfoViewController.h"

// 自定义视图
#import "MBProgressHUD.h"
#import "YYOrderMessageViewCell.h"

// 接口
#import "YYOrderApi.h"
#import "YYUserApi.h"

// 分类

// 自定义类和三方类（ cocoapods类 > model > 工具类 > 其他）
#import <MJRefresh.h>

#import "YYUser.h"

#import "AppDelegate.h"
#import "YYRspStatusAndMessage.h"

@interface YYOrderMessageViewController ()<YYTableCellDelegate>

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong)YYPageInfoModel *currentPageInfo;
@property (strong, nonatomic) NSMutableArray *msgListArray;

@property (nonatomic,strong) UIView *noDataView;

@end

@implementation YYOrderMessageViewController
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
    [MobClick beginLogPageView:kYYPageOrderMessage];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    // 退出埋点
    [MobClick endLogPageView:kYYPageOrderMessage];
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
- (void)PrepareData{}
- (void)PrepareUI{
    _tableView.separatorColor = [UIColor colorWithHex:kDefaultImageColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _tableView.separatorInset = UIEdgeInsetsMake(0, 40, 0,40 );
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.isOnOrderNotifyMsgUI = YES;
    [self addHeader];
    [self addFooter];
}

#pragma mark - --------------UIConfig----------------------
-(void)UIConfig{
    [self CreateNavView];
    [self CreateNoDataView];
}
-(void)CreateNavView{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    YYNavigationBarViewController *navigationBarViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYNavigationBarViewController"];
    navigationBarViewController.previousTitle = NSLocalizedString(@"订单列表",nil);

    NSString *title = NSLocalizedString(@"消息列表",nil);
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
}
-(void)CreateNoDataView{
    self.noDataView = addNoDataView_pad(self.view,NSLocalizedString(@"暂无订单消息|icon:nomsg_icon",nil),nil,nil);
    _noDataView.hidden = YES;
}

#pragma mark - --------------请求数据----------------------
-(void)RequestData{
    [self loadMsgListWithpageIndex:1];
}

#pragma mark - --------------系统代理----------------------
#pragma mark -UITableViewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_msgListArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    YYOrderMessageInfoModel* infoModel = _msgListArray[indexPath.row];
    static NSString* reuseIdentifier = @"YYOrderMessageViewCell";
    YYOrderMessageViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.msgInfoModel = infoModel;
    cell.indexPath = indexPath;
    cell.delegate = self;
    [cell updateUI];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    YYOrderMessageInfoModel* _msgInfoModel = _msgListArray[indexPath.row];

    BOOL btnIsHide = YES;
    if(_msgInfoModel.msgContent && ![NSString isNilOrEmpty:_msgInfoModel.msgContent.op]){
        if([_msgInfoModel.msgContent.op isEqualToString:@"need_confirm"]){
            if([_msgInfoModel.dealStatus integerValue] == -1){
                if(_msgInfoModel.orderTransStatus && [_msgInfoModel.orderTransStatus integerValue] != 4){
                    //双方都已确认
                    btnIsHide = YES;
                }else{
                    //我待确认(对方已确认)
                    btnIsHide = NO;
                }
            }else if([_msgInfoModel.dealStatus integerValue] == 1){
                //我已确认
                btnIsHide = YES;
            }if([_msgInfoModel.dealStatus integerValue] == 2){
                //我已拒绝
                btnIsHide = YES;
            }
        }else if([_msgInfoModel.msgContent.op isEqualToString:@"order_rejected"]){
            //对方已拒绝
            btnIsHide = YES;
        }
    }
    if(btnIsHide){
        return 150;
    }else{
        return 200;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    YYOrderMessageInfoModel* infoModel = [_msgListArray objectAtIndex:indexPath.row];
    if(infoModel.msgContent == nil){
        return;
    }
    NSString *orderCode = infoModel.msgContent.orderCode;
    WeakSelf(ws);
    __block YYOrderMessageInfoModel* blockInfoModel = infoModel;
    [YYOrderApi getOrderTransStatus:orderCode andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYOrderTransStatusModel *transStatusModel, NSError *error) {
        if(rspStatusAndMessage.status == kCode100){
            NSInteger transStatus = getOrderTransStatus(transStatusModel.designerTransStatus, transStatusModel.buyerTransStatus);
            if (transStatusModel == nil || transStatus == kOrderCode_DELETED) {
                [YYToast showToastWithView:self.view title:NSLocalizedString(@"此订单已被删除",nil) andDuration:kAlertToastDuration];//“
                return ;
            }else{
                if(infoModel.isPlainMsg == NO){
                    if([infoModel.dealStatus integerValue]== 1 && blockInfoModel.msgContent){
                        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"OrderDetail" bundle:[NSBundle mainBundle]];
                        YYOrderDetailViewController *orderDetailViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYOrderDetailViewController"];
                        orderDetailViewController.currentOrderCode = blockInfoModel.msgContent.orderCode;
                        orderDetailViewController.currentOrderLogo =  blockInfoModel.msgContent.designerBrandLogo;
                        orderDetailViewController.currentOrderConnStatus = kOrderStatusNUll;
                        [ws.navigationController pushViewController:orderDetailViewController animated:YES];
                    }else{

                        [YYToast showToastWithView:self.view title:NSLocalizedString(@"对不起，您没有权限查看订单",nil) andDuration:kAlertToastDuration];//“
                    }
                }else{
                    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"OrderDetail" bundle:[NSBundle mainBundle]];
                    YYOrderDetailViewController *orderDetailViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYOrderDetailViewController"];
                    orderDetailViewController.currentOrderCode = blockInfoModel.msgContent.orderCode;
                    orderDetailViewController.currentOrderLogo =  blockInfoModel.msgContent.designerBrandLogo;
                    orderDetailViewController.currentOrderConnStatus = kOrderStatusNUll;
                    [ws.navigationController pushViewController:orderDetailViewController animated:YES];
                }
            }
        }
    }];
}


#pragma mark - --------------自定义代理/block----------------------
#pragma mark -YYTableCellDelegate
-(void)btnClick:(NSInteger)row section:(NSInteger)section andParmas:(NSArray *)parmas{
    YYOrderMessageInfoModel* infoModel = [_msgListArray objectAtIndex:row];
    if(infoModel.msgContent == nil){
        return;
    }
    __block YYOrderMessageInfoModel* blockInfoModel = infoModel;
    NSString *type = [parmas objectAtIndex:0];
    if([type isEqualToString:@"buyerInfo"]){
        WeakSelf(ws);
        [YYUserApi getUserStatus:[infoModel.senderId integerValue] andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSInteger status, NSError *error) {
            if(rspStatusAndMessage.status == kCode100){
                if(status != kUserStatusStop && status >-1){
                    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Account" bundle:[NSBundle mainBundle]];
                    YYConnBuyerInfoViewController *connInfoController = [storyboard instantiateViewControllerWithIdentifier:@"YYConnBuyerInfoViewController"];
                    connInfoController.buyerId = [blockInfoModel.senderId integerValue];
                    connInfoController.previousTitle = blockInfoModel.msgContent.buyerName;
                    [ws.navigationController pushViewController:connInfoController animated:YES];
                }else{
                    [YYToast showToastWithView:ws.view title:NSLocalizedString(@"此买手店账号已停用",nil) andDuration:kAlertToastDuration];
                }
            }else{
                [YYToast showToastWithView:ws.view title:rspStatusAndMessage.message andDuration:kAlertToastDuration];
            }
        }];
    }else if ([type isEqualToString:@"orderInfo"]){
        NSString *orderCode = infoModel.msgContent.orderCode;
        WeakSelf(ws);
        [YYOrderApi getOrderTransStatus:orderCode andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYOrderTransStatusModel *transStatusModel, NSError *error) {
            NSInteger transStatus = getOrderTransStatus(transStatusModel.designerTransStatus, transStatusModel.buyerTransStatus);
            if (transStatusModel == nil || transStatus == kOrderCode_DELETED) {
                [YYToast showToastWithView:self.view title:NSLocalizedString(@"此订单已被删除",nil) andDuration:kAlertToastDuration];//“
                return ;
            }else{
                if(infoModel.isPlainMsg == NO){
                    if([infoModel.dealStatus integerValue]== 1 && blockInfoModel.msgContent){
                        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"OrderDetail" bundle:[NSBundle mainBundle]];
                        YYOrderDetailViewController *orderDetailViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYOrderDetailViewController"];
                        orderDetailViewController.currentOrderCode = blockInfoModel.msgContent.orderCode;
                        orderDetailViewController.currentOrderLogo =  blockInfoModel.msgContent.designerBrandLogo;
                        orderDetailViewController.currentOrderConnStatus = kOrderStatusNUll;
                        [ws.navigationController pushViewController:orderDetailViewController animated:YES];
                    }else{
                        [YYToast showToastWithView:self.view title:NSLocalizedString(@"对不起，您没有权限查看订单",nil)  andDuration:kAlertToastDuration];//“
                    }
                }else{
                    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"OrderDetail" bundle:[NSBundle mainBundle]];
                    YYOrderDetailViewController *orderDetailViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYOrderDetailViewController"];
                    orderDetailViewController.currentOrderCode = blockInfoModel.msgContent.orderCode;
                    orderDetailViewController.currentOrderLogo =  blockInfoModel.msgContent.designerBrandLogo;
                    orderDetailViewController.currentOrderConnStatus = kOrderStatusNUll;
                    [ws.navigationController pushViewController:orderDetailViewController animated:YES];
                }
            }
        }];
    }else if([type isEqualToString:@"refresh"]){
        [_tableView reloadData];
    }else if([type isEqualToString:@"reload"]){
        [_tableView reloadData];
    }
}

#pragma mark - --------------自定义响应----------------------


#pragma mark - --------------自定义方法----------------------
//请求买家地址列表
-(void)loadMsgListWithpageIndex:(NSInteger)pageIndex{
    WeakSelf(ws);
    NSString *type = @"1";

    NSInteger pageSize = 10;

    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    [YYOrderApi getNotifyMsgList:type pageIndex:pageIndex pageSize:pageSize andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYOrderMessageInfoListModel *msgListModel, NSError *error) {
        if(rspStatusAndMessage.status == kCode100){
            ws.currentPageInfo = msgListModel.pageInfo;
            if(ws.currentPageInfo.isFirstPage){
                ws.msgListArray =  [[NSMutableArray alloc] init];//;
            }
            [ws.msgListArray addObjectsFromArray:msgListModel.result];
            //[ws setMsgListGroupArray];
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

+(void)markAsRead{

    [YYOrderApi markAsRead:1 andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSError *error) {

    }];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if(appDelegate.unreadOrderNotifyMsgAmount > 0){
        appDelegate.unreadOrderNotifyMsgAmount = 0;
        [[NSNotificationCenter defaultCenter] postNotificationName:UnreadOrderNotifyMsgAmount object:nil userInfo:nil];
    }
    appDelegate.isOnOrderNotifyMsgUI = NO;
}

#pragma mark - --------------other----------------------


@end

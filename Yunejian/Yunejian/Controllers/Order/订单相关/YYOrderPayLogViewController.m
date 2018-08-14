//
//  YYOrderPayLogViewController.m
//  YunejianBuyer
//
//  Created by Apple on 16/7/20.
//  Copyright © 2016年 Apple. All rights reserved.
//

#import "YYOrderPayLogViewController.h"

// c文件 —> 系统文件（c文件在前）

// 控制器
#import "YYNavigationBarViewController.h"

// 自定义视图
#import "YYYellowPanelManage.h"
#import "YYOrderPayLogViewCell.h"

// 接口
#import "YYOrderApi.h"

// 分类
#import "UIView+UpdateAutoLayoutConstraints.h"

// 自定义类和三方类（ cocoapods类 > model > 工具类 > 其他）
#import "YYUser.h"
#import "YYPaymentNoteListModel.h"

@interface YYOrderPayLogViewController ()<UITableViewDelegate,UITableViewDataSource,YYTableCellDelegate>

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *giveMoneyLabel;
@property (weak, nonatomic) IBOutlet UILabel *giveMoneyRateLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastMoneyLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastMoneyRateLabel;
@property (weak, nonatomic) IBOutlet UIButton *addLogBtn;

@property (nonatomic, strong) YYPaymentNoteListModel *paymentNoteList;

@property (nonatomic, assign) double totalMoney;

@property (nonatomic, strong) NSIndexPath *detailIndexPath;

@end

@implementation YYOrderPayLogViewController
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
    [MobClick beginLogPageView:kYYPageOrderPayLog];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    // 退出埋点
    [MobClick endLogPageView:kYYPageOrderPayLog];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
#pragma mark - --------------SomePrepare--------------
- (void)SomePrepare {
    [self PrepareData];
    [self PrepareUI];
}
- (void)PrepareData {}
- (void)PrepareUI {

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    YYNavigationBarViewController *navigationBarViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYNavigationBarViewController"];
    navigationBarViewController.previousTitle = NSLocalizedString(@"订单详情",nil);
    navigationBarViewController.nowTitle = NSLocalizedString(@"收款记录",nil);

    [_containerView insertSubview:navigationBarViewController.view atIndex:0];
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
            blockVc = nil;
        }
    }];

    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.addLogBtn.hidden = !_addEnable;

}

#pragma mark - --------------UIConfig----------------------
- (void)UIConfig {

}

#pragma mark - --------------请求数据----------------------
- (void)RequestData {
    if(_currentYYOrderInfoModel != nil){
        [self loadPaymentNoteList:_currentYYOrderInfoModel.orderCode];
    }
}
-(void)loadPaymentNoteList:(NSString *)orderCode{
    WeakSelf(ws);
    [YYOrderApi getPaymentNoteList:orderCode finalTotalPrice:[_currentYYOrderInfoModel.finalTotalPrice doubleValue] andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYPaymentNoteListModel *paymentNoteList, NSError *error) {
        if(rspStatusAndMessage.status == YYReqStatusCode100){
            ws.paymentNoteList = paymentNoteList;
        }
        [ws updateUI];
        [ws.tableView reloadData];
    }];
}

#pragma mark - --------------系统代理----------------------
#pragma mark -UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(!_paymentNoteList || [NSArray isNilOrEmpty:_paymentNoteList.result]){
        return 0;
    }
    return [_paymentNoteList.result count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(!_paymentNoteList || [NSArray isNilOrEmpty:_paymentNoteList.result]){
        return 0;
    }

    if(_detailIndexPath == nil || _detailIndexPath.row != indexPath.row){
        return 83;
    }else{
        YYPaymentNoteModel *noteModel = [_paymentNoteList.result objectAtIndex:([_paymentNoteList.result count]-indexPath.row-1)];
        if([noteModel.payType integerValue] == 1){
            //成功
            return 170;
        }else{
            return 170+55;;
        }
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(!_paymentNoteList || [NSArray isNilOrEmpty:_paymentNoteList.result]){
        static NSString *cellid = @"cellid";
        UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:cellid];
        if(!cell)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }

    NSString *CellIdentifier = @"YYOrderPayLogViewCell";
    YYOrderPayLogViewCell *cell = (YYOrderPayLogViewCell*)[tableView  dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil){
        cell = [[YYOrderPayLogViewCell alloc] init];
        cell.backgroundColor = [UIColor redColor];
    }
    YYPaymentNoteModel *noteModel = [_paymentNoteList.result objectAtIndex:([_paymentNoteList.result count]-indexPath.row-1)];
    noteModel.tmpPercent = _paymentNoteList.hasGiveRate;
    cell.noteModel = noteModel;
    cell.delegate =self;
    cell.indexPath = indexPath;
    cell.detailIndexPath = _detailIndexPath;
    [cell updateUI];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    if(!_paymentNoteList || [NSArray isNilOrEmpty:_paymentNoteList.result]){
        return;
    }

    if(!_addEnable){
        return;
    }

    //线上付款 详情
    if(_detailIndexPath == nil || _detailIndexPath.row != indexPath.row){
        [self btnClick:indexPath.row section:indexPath.section andParmas:@[@"show"]];
    }else{
        [self btnClick:indexPath.row section:indexPath.section andParmas:@[@"hide"]];

    }
}

#pragma mark - --------------自定义代理/block----------------------
-(void)btnClick:(NSInteger)row section:(NSInteger)section andParmas:(NSArray *)parmas{
    NSString *handler = [parmas objectAtIndex:0];
    YYPaymentNoteModel *noteModel = [_paymentNoteList.result objectAtIndex:([_paymentNoteList.result count]-row-1)];
    WeakSelf(ws);
    if([handler isEqualToString:@"show"]){
        _detailIndexPath = [NSIndexPath indexPathForRow:row inSection:section];
        [self.tableView reloadData];
    }else if([handler isEqualToString:@"hide"]){
        _detailIndexPath = nil;
        [self.tableView reloadData];
    }else if([handler isEqualToString:@"makesure"]){

        __block YYPaymentNoteModel *blocknoteModel = noteModel;
        CMAlertView *alertView =nil;

        alertView = [[CMAlertView alloc] initWithTitle:NSLocalizedString(@"确认货款已到账？",nil) message:NSLocalizedString(@"确认后，到账状态不可修改",nil) needwarn:NO delegate:nil cancelButtonTitle:NSLocalizedString(@"还未收到",nil) otherButtonTitles:@[[[NSString alloc] initWithFormat:@"%@|000000",NSLocalizedString(@"确认到账",nil)]]];

        alertView.specialParentView = self.view;
        [alertView setAlertViewBlock:^(NSInteger selectedIndex){
            if (selectedIndex == 1) {
                [YYOrderApi confirmPayment:[blocknoteModel.id integerValue] andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSError *error) {
                    if(rspStatusAndMessage.status == YYReqStatusCode100){
                        if(ws.currentYYOrderInfoModel != nil){
                            [ws loadPaymentNoteList:ws.currentYYOrderInfoModel.orderCode];
                        }
                    }else{
                        [YYToast showToastWithTitle:rspStatusAndMessage.message andDuration:kAlertToastDuration];
                    }
                }];
            }
        }];

        [alertView show];

    }else if([handler isEqualToString:@"cancel"]){
        [YYOrderApi discardPayment:[noteModel.id integerValue] andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSError *error) {
            if(rspStatusAndMessage.status == YYReqStatusCode100){
                if(ws.currentYYOrderInfoModel != nil){
                    [ws loadPaymentNoteList:ws.currentYYOrderInfoModel.orderCode];
                }
            }else{
                [YYToast showToastWithTitle:rspStatusAndMessage.message andDuration:kAlertToastDuration];
            }
        }];

    }else if([handler isEqualToString:@"delete"]){
        [YYOrderApi deletePayment:[noteModel.id integerValue] andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSError *error) {
            if(rspStatusAndMessage.status == YYReqStatusCode100){
                if(ws.currentYYOrderInfoModel != nil){
                    [ws loadPaymentNoteList:ws.currentYYOrderInfoModel.orderCode];
                }
            }else{
                [YYToast showToastWithTitle:rspStatusAndMessage.message andDuration:kAlertToastDuration];
            }
        }];
    }
}

#pragma mark - --------------自定义响应----------------------
- (IBAction)addPayLogHandler:(id)sender {
    WeakSelf(ws);
    if([_paymentNoteList.hasGiveRate floatValue] != 100.f){
        BOOL isNeedRefund = NO;
        if([_paymentNoteList.hasGiveRate floatValue] > 100.f){
            isNeedRefund = YES;
        }

        [[YYYellowPanelManage instance] showOrderAddMoneyLogPanel:@"Order" andIdentifier:@"YYOrderAddMoneyLogController" totalMoney:_totalMoney moneyType:[_currentYYOrderInfoModel.curType integerValue] orderCode:_currentYYOrderInfoModel.orderCode isNeedRefund:isNeedRefund parentView:self.view andCallBack:^(NSString *orderCode, NSNumber *totalPercent) {

            [ws loadPaymentNoteList:ws.currentYYOrderInfoModel.orderCode];

        }];
    }
}

#pragma mark - --------------自定义方法----------------------
-(void)updateUI{
    NSInteger _moneyType = [_currentYYOrderInfoModel.curType integerValue];
    _totalMoney = [_currentYYOrderInfoModel.finalTotalPrice doubleValue];

    _giveMoneyRateLabel.text = [NSString stringWithFormat:@"%.2lf%@",[_paymentNoteList.hasGiveRate floatValue],@"%"];
    _lastMoneyRateLabel.text = [NSString stringWithFormat:@"%.2lf%@",(MAX(0,100-[_paymentNoteList.hasGiveRate floatValue])),@"%"];
    CGSize giveRateSize = [_giveMoneyRateLabel.text sizeWithAttributes:@{NSFontAttributeName:_giveMoneyRateLabel.font}];
    CGSize lastRateSize = [_lastMoneyRateLabel.text sizeWithAttributes:@{NSFontAttributeName:_lastMoneyRateLabel.font}];
    [_giveMoneyRateLabel setConstraintConstant:giveRateSize.width+1 forAttribute:NSLayoutAttributeWidth];
    [_lastMoneyRateLabel setConstraintConstant:lastRateSize.width+1 forAttribute:NSLayoutAttributeWidth];

    _giveMoneyLabel.text = replaceMoneyFlag([NSString stringWithFormat:@"￥%.2f",[_paymentNoteList.hasGiveMoney doubleValue]],_moneyType);
    CGSize giveMoneySize = [_giveMoneyLabel.text sizeWithAttributes:@{NSFontAttributeName:_giveMoneyLabel.font}];
    [_giveMoneyLabel setConstraintConstant:giveMoneySize.width+1 forAttribute:NSLayoutAttributeWidth];

    _lastMoneyLabel.text = replaceMoneyFlag([NSString stringWithFormat:@"￥%.2f",(MAX(0,_totalMoney-[_paymentNoteList.hasGiveMoney doubleValue]))],_moneyType);
}
#pragma mark - --------------other----------------------


@end

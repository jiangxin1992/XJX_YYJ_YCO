//
//  YYOrderPayLogViewController.m
//  YunejianBuyer
//
//  Created by Apple on 16/7/20.
//  Copyright © 2016年 Apple. All rights reserved.
//

#import "YYOrderPayLogViewController.h"

#import "YYNavigationBarViewController.h"

#import "YYPaymentNoteListModel.h"
#import "YYOrderApi.h"
#import "YYUser.h"
#import "YYOrderPayLogViewCell.h"
#import "YYOrderApi.h"
#import "UIView+UpdateAutoLayoutConstraints.h"
#import "YYYellowPanelManage.h"

@interface YYOrderPayLogViewController ()<UITableViewDelegate,UITableViewDataSource,YYTableCellDelegate>
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong)NSArray* reversedArray;
@property (weak, nonatomic) IBOutlet UILabel *giveMoneyLabel;
@property (weak, nonatomic) IBOutlet UILabel *giveMoneyRateLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastMoneyLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastMoneyRateLabel;

@property (nonatomic,assign)double totalMoney;
@property (nonatomic,assign)double hasGiveMoney;
@property (strong,nonatomic) NSIndexPath *detailIndexPath;
@property (nonatomic,assign)NSInteger hasGiveRate;
@property (weak, nonatomic) IBOutlet UIButton *addLogBtn;

@end

@implementation YYOrderPayLogViewController

#pragma mark - 生命周期

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    YYNavigationBarViewController *navigationBarViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYNavigationBarViewController"];
    navigationBarViewController.previousTitle = NSLocalizedString(@"订单详情",nil);
    //self.navigationBarViewController = navigationBarViewController;
    navigationBarViewController.nowTitle = NSLocalizedString(@"收款记录",nil);
    
    [_containerView insertSubview:navigationBarViewController.view atIndex:0];
    //[_containerView addSubview:navigationBarViewController.view];
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
    if(_currentYYOrderInfoModel != nil){
        [self loadPaymentNoteList:_currentYYOrderInfoModel.orderCode];
    }
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

#pragma mark - 生命周期end


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loadPaymentNoteList:(NSString *)orderCode{
    WeakSelf(ws);
    __block NSString *blockOrderCode = orderCode;
    [YYOrderApi getPaymentNoteList:orderCode andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYPaymentNoteListModel *paymentNoteList, NSError *error) {
        if(rspStatusAndMessage.status == kCode100){
            ws.reversedArray = paymentNoteList.result;
        }else{
            ws.reversedArray = nil;
        }
        [ws updateUI];
        [ws.tableView reloadData];
    }];
}

-(void)updateUI{
    double totalAmount=0;
    _hasGiveRate=0;
    if(_reversedArray){
        for (YYPaymentNoteModel *noteModel in _reversedArray) {
            if([noteModel.payType integerValue] == 0 && ([noteModel.payStatus integerValue] == 0 || [noteModel.payStatus integerValue] == 2)){
                
            }else{
                totalAmount += [noteModel.amount doubleValue];
                _hasGiveRate += [noteModel.percent integerValue];
            }

        }
    }
    NSInteger _moneyType = [_currentYYOrderInfoModel.curType integerValue];
    _hasGiveMoney = totalAmount;
    _totalMoney = [_currentYYOrderInfoModel.finalTotalPrice doubleValue];
    NSInteger hasGiveRate = [self getHasGiveRate];
    
    _giveMoneyRateLabel.text = [NSString stringWithFormat:@"%ld%@",(long)hasGiveRate,@"%"];
    _lastMoneyRateLabel.text = [NSString stringWithFormat:@"%ld%@",(long)(MAX(0,100-hasGiveRate)),@"%"];
    CGSize giveRateSize = [_giveMoneyRateLabel.text sizeWithAttributes:@{NSFontAttributeName:_giveMoneyRateLabel.font}];
    CGSize lastRateSize = [_lastMoneyRateLabel.text sizeWithAttributes:@{NSFontAttributeName:_lastMoneyRateLabel.font}];
    [_giveMoneyRateLabel setConstraintConstant:giveRateSize.width+1 forAttribute:NSLayoutAttributeWidth];
    [_lastMoneyRateLabel setConstraintConstant:lastRateSize.width+1 forAttribute:NSLayoutAttributeWidth];

    
    _giveMoneyLabel.text = replaceMoneyFlag([NSString stringWithFormat:@"￥%.2f",_hasGiveMoney],_moneyType);
    CGSize giveMoneySize = [_giveMoneyLabel.text sizeWithAttributes:@{NSFontAttributeName:_giveMoneyLabel.font}];
    [_giveMoneyLabel setConstraintConstant:giveMoneySize.width+1 forAttribute:NSLayoutAttributeWidth];

    _lastMoneyLabel.text = replaceMoneyFlag([NSString stringWithFormat:@"￥%.2f",(MAX(0,_totalMoney-_hasGiveMoney))],_moneyType);
    

}

-(NSInteger) getHasGiveRate{
    //return (_hasGiveMoney/_totalMoney)*100;
    return _hasGiveRate;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_reversedArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(_detailIndexPath == nil || _detailIndexPath.row != indexPath.row){
        return 83;
    }else{
        YYPaymentNoteModel *noteModel = [_reversedArray objectAtIndex:([_reversedArray count]-indexPath.row-1)];
        if([noteModel.payType integerValue] == 0 && ([noteModel.payStatus integerValue] ==0 ||[noteModel.payStatus integerValue] ==2) ){
            return  170+55;
        }else{
            return 170;
        }
    }
}


- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    static NSString *CellIdentifier = @"YYOrderPayLogCell";
//    YYOrderPayLogCell *cell1 = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
//    NSString *info = [reversedArray objectAtIndex:indexPath.row];
//    [cell1 updateCellInfo:@[info]];
//    return cell1;
    
    
    NSString *CellIdentifier = @"YYOrderPayLogViewCell";
    YYOrderPayLogViewCell *cell = (YYOrderPayLogViewCell*)[tableView  dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil){
        cell = [[YYOrderPayLogViewCell alloc] init];
        cell.backgroundColor = [UIColor redColor];
    }
    YYPaymentNoteModel *noteModel = [_reversedArray objectAtIndex:([_reversedArray count]-indexPath.row-1)];
    noteModel.tmpPercent = [NSNumber numberWithInteger:[self getHasGiveRate]];//;
    cell.noteModel = noteModel;
    cell.delegate =self;
    cell.indexPath = indexPath;
    cell.detailIndexPath = _detailIndexPath;
    [cell updateUI];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
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
#pragma YYTableCellDelegate
-(void)btnClick:(NSInteger)row section:(NSInteger)section andParmas:(NSArray *)parmas{
    NSString *handler = [parmas objectAtIndex:0];
    YYPaymentNoteModel *noteModel = [_reversedArray objectAtIndex:([_reversedArray count]-row-1)];
    //__block YYPaymentNoteModel *blocknoteModel = noteModel;
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
                    if(rspStatusAndMessage.status == kCode100){
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
            if(rspStatusAndMessage.status == kCode100){
                if(ws.currentYYOrderInfoModel != nil){
                    [ws loadPaymentNoteList:ws.currentYYOrderInfoModel.orderCode];
                }
            }else{
                [YYToast showToastWithTitle:rspStatusAndMessage.message andDuration:kAlertToastDuration];
            }
        }];
        
    }else if([handler isEqualToString:@"delete"]){
        [YYOrderApi deletePayment:[noteModel.id integerValue] andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSError *error) {
            if(rspStatusAndMessage.status == kCode100){
                if(ws.currentYYOrderInfoModel != nil){
                    [ws loadPaymentNoteList:ws.currentYYOrderInfoModel.orderCode];
                }
            }else{
                [YYToast showToastWithTitle:rspStatusAndMessage.message andDuration:kAlertToastDuration];
            }
        }];
    }
}

- (IBAction)addPayLogHandler:(id)sender {
    WeakSelf(ws);
    [[YYYellowPanelManage instance] showOrderAddMoneyLogPanel:@"Order" andIdentifier:@"YYOrderAddMoneyLogController" totalMoney:_totalMoney moneyType:[_currentYYOrderInfoModel.curType integerValue] orderCode:_currentYYOrderInfoModel.orderCode parentView:self.view andCallBack:^(NSString *orderCode, NSNumber *totalPercent) {

        [ws loadPaymentNoteList:ws.currentYYOrderInfoModel.orderCode];
        
    }];
}
@end

//
//  YYOrderAddMoneyLogController.m
//  Yunejian
//
//  Created by Apple on 15/11/26.
//  Copyright © 2015年 yyj. All rights reserved.
//

#import "YYOrderAddMoneyLogController.h"

// c文件 —> 系统文件（c文件在前）

// 控制器

// 自定义视图
#import "MBProgressHUD.h"
#import "MLInputDodger.h"

// 接口
#import "YYOrderApi.h"

// 分类

// 自定义类和三方类（ cocoapods类 > model > 工具类 > 其他）
#import "YYPaymentNoteListModel.h"

@interface YYOrderAddMoneyLogController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titlelabel;

@property (weak, nonatomic) IBOutlet UILabel *totalMoneyLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalMoneyRateLabel;

@property (weak, nonatomic) IBOutlet UILabel *giveMoneyLabel;
@property (weak, nonatomic) IBOutlet UILabel *giveMoneyRateLabel;

@property (weak, nonatomic) IBOutlet UILabel *pendingMoneyRateLabel;
@property (weak, nonatomic) IBOutlet UILabel *pendingMoneyLabel;

@property (weak, nonatomic) IBOutlet UILabel *lastMoneyLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastMoneyRateLabel;

@property (weak, nonatomic) IBOutlet UILabel *addMoneyTipLabel;
@property (weak, nonatomic) IBOutlet UIButton *warnTipBtn;

@property (weak, nonatomic) IBOutlet UILabel *moneyTypeLabel;
@property (weak, nonatomic) IBOutlet UIButton *makeSureBtn;
@property (weak, nonatomic) IBOutlet UITextField *inputText;

@property (nonatomic, strong) YYPaymentNoteListModel *paymentNoteList;

@end

@implementation YYOrderAddMoneyLogController
#pragma mark - --------------生命周期--------------
- (void)viewDidLoad {
    [super viewDidLoad];
    [self SomePrepare];
    [self RequestData];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
#pragma mark - --------------SomePrepare--------------
- (void)SomePrepare
{
    [self PrepareData];
    [self PrepareUI];
}
- (void)PrepareData{}
- (void)PrepareUI{

    self.view.shiftHeightAsDodgeViewForMLInputDodger = 44.0f + 5.0f;
    [self.view registerAsDodgeViewForMLInputDodger];
    [self.view layoutSubviews];
    
    _titlelabel.text = NSLocalizedString(@"添加线下收款记录",nil);

    _inputText.delegate = self;
    _inputText.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    _inputText.layer.borderColor = [UIColor colorWithHex:kDefaultBorderColor].CGColor;
    _inputText.layer.borderWidth = 1;
    _inputText.text = @"0";
    _inputText.enabled = YES;

    _warnTipBtn.hidden = YES;
    [_warnTipBtn setTitle:NSLocalizedString(@"填写金额不能大于尚未收款金额",nil) forState:UIControlStateNormal];

    _makeSureBtn.enabled = NO;
    _makeSureBtn.alpha = 0.5;

    _moneyTypeLabel.text = replaceMoneyFlag(@"￥",_moneyType);

    _totalMoneyRateLabel.text = @"100%";
    _totalMoneyLabel.text = replaceMoneyFlag([NSString stringWithFormat:@"￥%.2f",_totalMoney],_moneyType);

    _pendingMoneyRateLabel.text = [[NSString alloc] initWithFormat:@"%.2lf%@",[_paymentNoteList.pendingRate floatValue],@"%"];
    _pendingMoneyLabel.text = replaceMoneyFlag([NSString stringWithFormat:@"￥%.2f",[_paymentNoteList.pendingMoney doubleValue]],_moneyType);

    [self setWillCostMoney:0.f];

}
//#pragma mark - --------------UIConfig----------------------
//-(void)UIConfig{}
//
#pragma mark - --------------请求数据----------------------
-(void)RequestData{
    WeakSelf(ws);
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [YYOrderApi getPaymentNoteList:_orderCode finalTotalPrice:_totalMoney andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYPaymentNoteListModel *paymentNoteList, NSError *error) {
        [hud hideAnimated:YES];
        if (rspStatusAndMessage.status == YYReqStatusCode100) {
            ws.paymentNoteList = paymentNoteList;
            [ws updateUI];
        } else {
            [YYToast showToastWithView:ws.view title:rspStatusAndMessage.message andDuration:kAlertToastDuration];
        }
    }];
}
-(void)addPaymentNote:(double)costMoney{
    WeakSelf(ws);
    [YYOrderApi addPaymentNote:_orderCode amount:[[NSString stringWithFormat:@"%.2f",costMoney] floatValue] andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSError *error) {
        if(rspStatusAndMessage.status == YYReqStatusCode100){
            [YYToast showToastWithTitle:NSLocalizedString(@"成功",nil) andDuration:kAlertToastDuration];
            [ws getPaymentNoteList];
        }else{
            [YYToast showToastWithTitle:rspStatusAndMessage.message andDuration:kAlertToastDuration];
        }
    }];
}
-(void)getPaymentNoteList{
    WeakSelf(ws);
    [YYOrderApi getPaymentNoteList:_orderCode finalTotalPrice:_totalMoney andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYPaymentNoteListModel *paymentNoteList, NSError *error) {
        CGFloat hasGiveRate = 0.f;
        if(rspStatusAndMessage.status == YYReqStatusCode100){
            if(ws.paymentNoteList){
                hasGiveRate = [paymentNoteList.hasGiveRate floatValue];
            }
        }
        ws.modifySuccess(ws.orderCode,@(hasGiveRate));
    }];
}

#pragma mark - --------------系统代理----------------------
#pragma mark -UITextFieldDelegate
- (BOOL)textField:(UITextField*)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString*)string{

    NSCharacterSet *cs = [NSCharacterSet characterSetWithCharactersInString:@"0123456789."];
    NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    NSLog(@"test %@",filtered);
    BOOL basicTest = [NSString isNilOrEmpty:filtered];

    if(basicTest) {

        _warnTipBtn.hidden = YES;
        if ([textField.text containsString:@"."]) {
            if([string isEqualToString:@"."]){
                //如果有两个点
                return NO;
            }else{
                //已存在一个点.输入的不是，
                NSArray *separatedArray = [textField.text componentsSeparatedByString:@"."];
                if(separatedArray.count == 2){
                    NSInteger decimalsLength = ((NSString *)separatedArray[1]).length;
                    if((decimalsLength >= 2) && ![NSString isNilOrEmpty:string]){
                        return NO;
                    }
                }else{
                    return NO;
                }
            }
        }

        //删到底给默认"0"
        if([NSString isNilOrEmpty:string] && textField.text.length == 1){
            textField.text = @"0";
            [self updateState:textField.text];
            return NO;
        }

        //为"0"的时候，输入，去除0，并键入输入内容（除非输入"."）
        if([textField.text isEqualToString:@"0"] && ![NSString isNilOrEmpty:string] && ![string isEqualToString:@"."]){
            textField.text = string;
            [self updateState:textField.text];
            return NO;
        }

        //为空是不能输入"."
        if([string isEqualToString:@"."] && [NSString isNilOrEmpty:textField.text]){
            return NO;
        }

        NSString *numStr = [_inputText.text stringByReplacingCharactersInRange:range withString:string];
        [self updateState:numStr];
        return YES;
    }
    return NO;
}
#pragma mark - --------------自定义代理/block----------------------


#pragma mark - --------------自定义响应----------------------
- (IBAction)closeHandler:(id)sender {
    if (self.cancelButtonClicked) {
        self.cancelButtonClicked();
    }
}

- (IBAction)makeSureHandler:(id)sender {
    if(self.modifySuccess){
        double costMoney = [_inputText.text floatValue];
        costMoney = MIN(costMoney, (_totalMoney-[_paymentNoteList.hasGiveMoney doubleValue]));
        if(costMoney > 0){
            [self addPaymentNote:costMoney];
        }
    }
}

#pragma mark - --------------自定义方法----------------------
-(void)updateUI{

    _pendingMoneyRateLabel.text = [[NSString alloc] initWithFormat:@"%.2lf%@",[_paymentNoteList.pendingRate floatValue],@"%"];
    _pendingMoneyLabel.text = replaceMoneyFlag([NSString stringWithFormat:@"￥%.2f",[_paymentNoteList.pendingMoney doubleValue]],_moneyType);

    [self setWillCostMoney:0.f];

}
-(void)updateState:(NSString *)numStr{
    CGFloat lastGiveAmount = [self getLastGiveAmount];
    CGFloat num = [numStr floatValue];
    if(num > lastGiveAmount){
        _warnTipBtn.hidden = NO;
        if(lastGiveAmount){
            _inputText.text = [NSString stringWithFormat:@"%.2lf",lastGiveAmount];
        }else{
            _inputText.text = [NSString stringWithFormat:@"%.lf",lastGiveAmount];
        }
        [_inputText resignFirstResponder];
    }
    if(num == 0){
        _makeSureBtn.alpha = 0.5;
        _makeSureBtn.enabled = NO;
    }else{
        _makeSureBtn.alpha = 1;
        _makeSureBtn.enabled = YES;
    }
    lastGiveAmount = MIN(lastGiveAmount, num);
    [self setWillCostMoney:lastGiveAmount];
}
-(void)setWillCostMoney:(CGFloat)costMoney{

    CGFloat costRate = (costMoney/_totalMoney)*100.f;

    _addMoneyTipLabel.text = [[NSString alloc] initWithFormat:@"    %.2lf%%",costRate];

    _giveMoneyRateLabel.text = [NSString stringWithFormat:@"%ld%@",(long)([_paymentNoteList.hasGiveRate floatValue] + costRate),@"%"];
    _lastMoneyRateLabel.text = [NSString stringWithFormat:@"%ld%@",(long)(MAX(0,100 - [_paymentNoteList.hasGiveRate floatValue] - costRate - [_paymentNoteList.pendingRate floatValue])),@"%"];

    _giveMoneyLabel.text = replaceMoneyFlag([NSString stringWithFormat:@"￥%.2f",[_paymentNoteList.hasGiveMoney doubleValue] + costMoney],_moneyType);
    _lastMoneyLabel.text = replaceMoneyFlag([NSString stringWithFormat:@"￥%.2f",(MAX(0,_totalMoney - [_paymentNoteList.hasGiveMoney doubleValue] - costMoney - [_paymentNoteList.pendingMoney doubleValue]))],_moneyType);

}
#pragma mark -other

/**
 剩余支付比例

 @return ...
 */
-(CGFloat) getLastGiveRate{
    return MAX(0,100 - [_paymentNoteList.hasGiveRate floatValue] - [_paymentNoteList.pendingRate floatValue]);
}

/**
 剩余可付款

 @return ...
 */
-(double)getLastGiveAmount{
    return MAX(0,_totalMoney - [_paymentNoteList.hasGiveMoney doubleValue] - [_paymentNoteList.pendingMoney doubleValue]);
}

- (void)closeAction{
    if (self.cancelButtonClicked) {
        self.cancelButtonClicked();
    }
}
#pragma mark - --------------other----------------------

@end

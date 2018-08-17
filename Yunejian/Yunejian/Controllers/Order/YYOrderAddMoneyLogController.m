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

// 接口
#import "YYOrderApi.h"

// 分类

// 自定义类和三方类（ cocoapods类 > model > 工具类 > 其他）
#import "YYPaymentNoteListModel.h"

@interface YYOrderAddMoneyLogController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIButton *makeSureBtn;
@property (weak, nonatomic) IBOutlet UITextField *inputText;
@property (weak, nonatomic) IBOutlet UILabel *addMoneyTipLabel;
@property (weak, nonatomic) IBOutlet UIButton *warnTipBtn;
@property (weak, nonatomic) IBOutlet UILabel *titlelabel;

@property (weak, nonatomic) IBOutlet UILabel *totalMoneyLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalMoneyRateLabel;
@property (weak, nonatomic) IBOutlet UILabel *giveMoneyLabel;
@property (weak, nonatomic) IBOutlet UILabel *giveMoneyRateLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastMoneyLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastMoneyRateLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *layoutCenterYConstraint;

@property (nonatomic,assign)double hasGiveMoney;
@property (nonatomic,assign)NSInteger hasGiveRate;

@end

@implementation YYOrderAddMoneyLogController
#pragma mark - --------------生命周期--------------
- (void)viewDidLoad {
    [super viewDidLoad];
    [self SomePrepare];
//    [self UIConfig];
//    [self RequestData];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}
#pragma mark - --------------SomePrepare--------------
- (void)SomePrepare
{
    [self PrepareData];
    [self PrepareUI];
}
- (void)PrepareData{
    _hasGiveMoney = 0;
    _hasGiveRate = 0;
    if(_paymentNoteList){
        for (YYPaymentNoteModel *noteModel in _paymentNoteList.result) {
            if([noteModel.payType integerValue] == 0 && ([noteModel.payStatus integerValue] == 0 || [noteModel.payStatus integerValue] == 2)){
            }else{
                _hasGiveMoney += [noteModel.amount doubleValue];
                _hasGiveRate += [noteModel.percent integerValue];
            }
        }
    }
    [self addObserverForKeyboard];
}
- (void)addObserverForKeyboard{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)keyboardWillHide:(NSNotification *)note{

    _layoutCenterYConstraint.constant = 0;
}
- (void)PrepareUI{

    _inputText.delegate = self;
    _inputText.keyboardType = UIKeyboardTypeNumberPad;
    _inputText.layer.borderColor = [UIColor colorWithHex:kDefaultBorderColor].CGColor;
    _inputText.layer.borderWidth = 1;
    _inputText.text = @"";

    _titlelabel.text = NSLocalizedString(@"添加线下收款记录",nil);
    NSInteger hasGiveRate = [self getHasGiveRate];

    _totalMoneyRateLabel.text = @"100%";
    _giveMoneyRateLabel.text = [NSString stringWithFormat:@"%ld%@",(long)hasGiveRate,@"%"];
    _lastMoneyRateLabel.text = [NSString stringWithFormat:@"%ld%@",(long)(100-hasGiveRate),@"%"];

    _totalMoneyLabel.text = replaceMoneyFlag([NSString stringWithFormat:@"￥%.2f",_totalMoney],_moneyType);
    _giveMoneyLabel.text = replaceMoneyFlag([NSString stringWithFormat:@"￥%.2f",_hasGiveMoney],_moneyType);
    _lastMoneyLabel.text = replaceMoneyFlag([NSString stringWithFormat:@"￥%.2f",(_totalMoney-_hasGiveMoney)],_moneyType);

    _inputText.enabled = YES;
    _warnTipBtn.hidden = YES;
    [_warnTipBtn setTitle:NSLocalizedString(@"填写的比例需小于余款的比例",nil) forState:UIControlStateNormal];
    _makeSureBtn.enabled = YES;
    _makeSureBtn.alpha = 1;

    NSInteger editpercent = 0;
    [self setWillCostMoney:editpercent];
    _inputText.text = [NSString stringWithFormat:@"%ld",(long)editpercent];
}

//#pragma mark - --------------UIConfig----------------------
//-(void)UIConfig{}
//
//#pragma mark - --------------请求数据----------------------
//-(void)RequestData{}

#pragma mark - --------------系统代理----------------------
#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField*)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString*)string
{

    NSCharacterSet* cs = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    NSLog(@"test %@",filtered);
    BOOL basicTest = [filtered isEqualToString:@""];
    if(basicTest) {
        _warnTipBtn.hidden = YES;
        NSString *numStr = [_inputText.text stringByReplacingCharactersInRange:range withString:string];
        NSInteger lastGiveRate = [self getLastGiveRate];
        if([numStr integerValue] > lastGiveRate){
            _warnTipBtn.hidden = NO;
            _inputText.text = [NSString stringWithFormat:@"%ld",(long)lastGiveRate];
            [_inputText resignFirstResponder];
        }
        if([numStr integerValue] == 0){
            _makeSureBtn.alpha = 0.5;
            _makeSureBtn.enabled = NO;
        }else{

            _makeSureBtn.alpha = 1;
            _makeSureBtn.enabled = YES;
        }
        lastGiveRate = MIN(lastGiveRate, [numStr integerValue]);
        [self setWillCostMoney:lastGiveRate];
        return YES;
    }
    return NO;
}

-(void) textFieldDidBeginEditing:(UITextField *)textField{
    _layoutCenterYConstraint.constant = -100;
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
        NSInteger rate = [_inputText.text integerValue];
        double costMeoney = _totalMoney*rate/100;
        costMeoney = MIN(costMeoney, (_totalMoney-_hasGiveMoney));
        if(rate > 0 && costMeoney > 0){
            [YYOrderApi addPaymentNote:_orderCode percent:[_inputText.text integerValue] amount:[[NSString stringWithFormat:@"%.2f",costMeoney] floatValue] andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSError *error) {
                if(rspStatusAndMessage.status == kCode100){
                    [YYOrderApi getPaymentNoteList:_orderCode andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYPaymentNoteListModel *paymentNoteList, NSError *error) {
                        NSInteger totalPercent = 0;
                        if(rspStatusAndMessage.status == kCode100){
                            if(_paymentNoteList){
                                for (YYPaymentNoteModel *noteModel in paymentNoteList.result) {
                                    if([noteModel.payType integerValue] == 0 && ([noteModel.payStatus integerValue] == 0 || [noteModel.payStatus integerValue] == 2)){
                                    }else{
                                        totalPercent += [noteModel.percent integerValue];
                                    }
                                }
                            }
                        }
                        self.modifySuccess(_orderCode,@(totalPercent));
                    }];
                    [YYToast showToastWithTitle:NSLocalizedString(@"成功",nil) andDuration:kAlertToastDuration];
                }else{
                    [YYToast showToastWithTitle:rspStatusAndMessage.message andDuration:kAlertToastDuration];
                }
            }];
        }
    }
}

#pragma mark - --------------自定义方法----------------------
-(void)setWillCostMoney:(NSInteger)rate{
    double costMeoney = _totalMoney*rate/100;
    costMeoney = (costMeoney<0.01?0:costMeoney);

    NSString *addMoneyStr = replaceMoneyFlag([NSString stringWithFormat:@"    ￥ %.2f",costMeoney],_moneyType);
    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString: addMoneyStr];
    _addMoneyTipLabel.attributedText = attributedStr;

    _giveMoneyRateLabel.text = [NSString stringWithFormat:@"%ld%@",(long)(_hasGiveRate+rate),@"%"];
    _lastMoneyRateLabel.text = [NSString stringWithFormat:@"%ld%@",(long)(MAX(0,100-_hasGiveRate-rate)),@"%"];

    _giveMoneyLabel.text = replaceMoneyFlag([NSString stringWithFormat:@"￥%.2f",_hasGiveMoney+costMeoney],_moneyType);
    _lastMoneyLabel.text = replaceMoneyFlag([NSString stringWithFormat:@"￥%.2f",(MAX(0,_totalMoney-_hasGiveMoney -costMeoney))],_moneyType);

}

-(NSInteger) getHasGiveRate{
    return _hasGiveRate;
}

-(NSInteger) getLastGiveRate{
    return MAX(0,100 - [self getHasGiveRate]);
}

#pragma mark - --------------other----------------------

@end

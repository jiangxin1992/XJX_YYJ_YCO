//
//  YYDiscountViewController.m
//  Yunejian
//
//  Created by yyj on 15/8/26.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import "YYDiscountViewController.h"

#import "RegexKitLite.h"
#import "UIImage+YYImage.h"
#import "YYVerifyTool.h"
#import "MLInputDodger.h"

static CGFloat style_yellowView_default_constant = 132;
static CGFloat total_yellowView_default_constant = 194;

static int   multiple = 10; //倍数

@interface YYDiscountViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *originalPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *discountShortTitleLabel;


@property (weak, nonatomic) IBOutlet UITextField *discountField;
@property (weak, nonatomic) IBOutlet UITextField *reduceField;
@property (weak, nonatomic) IBOutlet UITextField *finalPriceField;

@property (weak, nonatomic) IBOutlet UIButton *reduceButton;
@property (weak, nonatomic) IBOutlet UIButton *increaseButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *yellowViewTopLayoutConstraint;
@property (weak, nonatomic) IBOutlet UIView *yellowView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *yellowViewHeightLayoutConstraint;

@property (strong, nonatomic) NSNumber <Optional>*curType;//货币类型


@end

@implementation YYDiscountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self SomePrepare];
    [self updateUI];
}
#pragma mark - SomePrepare
-(void)SomePrepare
{
    [self PrepareData];
    [self PrepareUI];
}
-(void)PrepareData{}
-(void)PrepareUI{

    self.discountField.keyboardType = UIKeyboardTypeNumberPad;
    self.discountField.layer.borderColor = [UIColor colorWithHex:@"d3d3d3"].CGColor;
    self.discountField.layer.borderWidth = 1;
    self.discountField.layer.cornerRadius = 2.5;
    self.discountField.layer.masksToBounds = YES;
    self.discountField.delegate = self;
    [self.view registerAsDodgeViewForMLInputDodger];
    
    if([LanguageManager isEnglishLanguage]){
        _reduceButton.hidden = YES;
        _increaseButton.hidden = YES;
        self.discountField.enabled = YES;
        _discountShortTitleLabel.hidden = NO;
    }else{
        _reduceButton.hidden = NO;
        _increaseButton.hidden = NO;
        self.discountField.enabled = NO;
        _discountShortTitleLabel.hidden = YES;
    }
    
    self.reduceField.delegate = self;
    self.reduceField.keyboardType = UIKeyboardTypeNumberPad;
    self.reduceField.enabled = NO;
    self.reduceField.adjustsFontSizeToFitWidth = YES;
    
//    self.finalPriceField.delegate = self;
//    self.finalPriceField.keyboardType = UIKeyboardTypeNumberPad;
    self.finalPriceField.enabled = NO;
    if(_orderStyleModel != nil){
        _curType = _orderStyleModel.curType;
    }else if(_currentYYOrderInfoModel != nil){
        _curType = _currentYYOrderInfoModel.curType;
    }
    
    popWindowAddBgView(self.view);
}
#pragma mark - SomeAction
//减
- (IBAction)reduceButtonClicked:(id)sender{
    NSString *discountValue = _discountField.text;
    double nowDiscount = [discountValue doubleValue];
    if (nowDiscount > 0.1) {
        nowDiscount = round((nowDiscount-0.1)*10)/10.0;
        [self updateReduceAndFinalbyDiscount:nowDiscount];
    }
}
//加
- (IBAction)increaseButtonClicked:(id)sender{
    NSString *discountValue = _discountField.text;
    double nowDiscount = [discountValue doubleValue];
    if (nowDiscount < 9.9) {
        nowDiscount =  round((nowDiscount+0.1)*10)/10.0;
        [self updateReduceAndFinalbyDiscount:nowDiscount];
    }
}

- (void)updateReduceAndFinalbyDiscount:(double)discount{
    if([LanguageManager isEnglishLanguage]){
        if (discount >= 0
            && discount < 100) {
            _discountField.text = [NSString stringWithFormat:@"%.0f",discount];
            double finalValue = _originalTotalPrice*(100-discount)/100.0f;
            _finalPriceField.text = replaceMoneyFlag([NSString stringWithFormat:@"￥%.2f",finalValue],[_curType integerValue]);
            _reduceField.text = replaceMoneyFlag([NSString stringWithFormat:@"￥%.2f",(_originalTotalPrice-finalValue)],[_curType integerValue]);
            [self updateButtonStauts];
        }
    }else{
        if (discount > 0
            && discount <= 10) {
            _discountField.text = [NSString stringWithFormat:@"%.2f",discount];
            double finalValue = _originalTotalPrice*discount/multiple;
            _finalPriceField.text = replaceMoneyFlag([NSString stringWithFormat:@"￥%.2f",finalValue],[_curType integerValue]);
            _reduceField.text = replaceMoneyFlag([NSString stringWithFormat:@"￥%.2f",(_originalTotalPrice-finalValue)],[_curType integerValue]);
            [self updateButtonStauts];
        }
    }
}

//更新那两个加减按钮（是否可点击）
- (void)updateButtonStauts{
    _reduceButton.enabled = YES;
    _increaseButton.enabled = YES;
    
    if([LanguageManager isEnglishLanguage]){
        _reduceButton.enabled = NO;
        _increaseButton.enabled = NO;
    }else{
        NSString *discountValue = _discountField.text;
        float nowDiscount = [discountValue floatValue];
        if (nowDiscount < 0.2) {
            _reduceButton.enabled = NO;
        }else if (nowDiscount > 9.9){
            _increaseButton.enabled = NO;
        }
        NSLog(@"nowDiscount: %f",nowDiscount);
    }
}

- (void)updateUI{
    if (_currentDiscountType == DiscountTypeStylePrice) {
        //给款式打折
    }else if (_currentDiscountType == DiscountTypeTotalPrice) {
        //给总价打折
        _yellowViewTopLayoutConstraint.constant = 230;

    }
    
    _originalPriceLabel.adjustsFontSizeToFitWidth = YES;
    _originalPriceLabel.text = replaceMoneyFlag([NSString stringWithFormat:@"￥%.2f",_originalTotalPrice],[_curType integerValue]);
    _finalPriceField.text = replaceMoneyFlag([NSString stringWithFormat:@"￥%.2f",_finalTotalPrice],[_curType integerValue]);
    
    if([LanguageManager isEnglishLanguage]){
        NSString *reduceValue = @"0";
        NSString *discountValue = @"0";
        if (_originalTotalPrice > _finalTotalPrice) {
            reduceValue = replaceMoneyFlag([NSString stringWithFormat:@"￥%.2f",(_originalTotalPrice-_finalTotalPrice)],[_curType integerValue]);
            discountValue = [NSString stringWithFormat:@"%.0f",(100-100*_finalTotalPrice/_originalTotalPrice)];
        }
        
        _reduceField.text = reduceValue;
        _discountField.text = discountValue;
    }else{
        NSString *reduceValue = @"0";
        NSString *discountValue = @"10.00";
        if (_originalTotalPrice > _finalTotalPrice) {
            reduceValue = replaceMoneyFlag([NSString stringWithFormat:@"￥%.2f",(_originalTotalPrice-_finalTotalPrice)],[_curType integerValue]);
            discountValue = [NSString stringWithFormat:@"%.2f",_finalTotalPrice/_originalTotalPrice*multiple];
        }
        
        _reduceField.text = reduceValue;
        _discountField.text = discountValue;
    }
    
    [self updateButtonStauts];
}


- (IBAction)clearDiscountHandler:(id)sender {
    [self updateReduceAndFinalbyDiscount:[LanguageManager isEnglishLanguage]?0:10];
    [self saveClicked:nil];
}

- (IBAction)cancelClicked:(id)sender{
    if (_cancelButtonClicked) {
        _cancelButtonClicked();
    }
}

- (IBAction)saveClicked:(id)sender{
    
    NSString *finalValue = [_finalPriceField.text substringFromIndex:1];
    double nowFinalValue = [finalValue doubleValue];
    
    double discountValue = 0;
    if([LanguageManager isEnglishLanguage]){
        discountValue = [_discountField.text doubleValue];
    }else{
        discountValue = [_discountField.text doubleValue]*10;
    }
    if (nowFinalValue > 0
        && nowFinalValue <= _originalTotalPrice) {
        if([LanguageManager isEnglishLanguage]){
            if(discountValue <= 0){
                _currentYYOrderInfoModel.discount = [NSNumber numberWithDouble:0];
            }else{
                _currentYYOrderInfoModel.discount = [NSNumber numberWithDouble:discountValue];
            }
        }else{
            if(discountValue >= 100){
                _currentYYOrderInfoModel.discount = [NSNumber numberWithDouble:100];
            }else{
                _currentYYOrderInfoModel.discount = [NSNumber numberWithDouble:discountValue];
            }
        }
    }

    
    if (_modifySuccess ) {
        _modifySuccess();
    }
    
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if(textField == _discountField){
        BOOL returnValue = NO;
        NSString *message = NSLocalizedString(@"数据格式错误",nil);
        NSString *str = [textField.text stringByReplacingCharactersInRange:range withString:string];
        
        if (![NSString isNilOrEmpty:str]) {
            if([YYVerifyTool numberVerift:str]){
                message = nil;
                if([str length] > 0 && [str length] < 3){
                    if([str length] == 2){
                        if([str hasPrefix:@"0"]){
                            textField.text = [str substringFromIndex:1];
                            str = [str substringFromIndex:1];
                            returnValue = NO;
                        }else{
                            returnValue = YES;
                        }
                    }else{
                        returnValue = YES;
                    }
                }else if([str length] >= 3){
                    textField.text = [str substringToIndex:2];
                    str = [str substringToIndex:2];
                    returnValue = NO;
                }
            }
        }else{
            message = nil;
            textField.text = @"0";
            str = @"0";
            returnValue = NO;
        }
        NSLog(@"message: %@",message);
        if ([NSString isNilOrEmpty:message]) {
            [self updateButtonStauts];
            
            CGFloat discount = [str integerValue];
            [self updateReduceFieldWithDiscount:discount];
            
        }else{
            [YYToast showToastWithView:self.view title:message  andDuration:kAlertToastDuration];
            
        }
        return returnValue;
    }

    return YES;
}
-(void)updateReduceFieldWithDiscount:(CGFloat )discount{
    if([LanguageManager isEnglishLanguage]){
        if (discount >= 0
            && discount < 100) {
            double finalValue = _originalTotalPrice*(100-discount)/100.0f;
            _finalPriceField.text = replaceMoneyFlag([NSString stringWithFormat:@"￥%.2f",finalValue],[_curType integerValue]);
            _reduceField.text = replaceMoneyFlag([NSString stringWithFormat:@"￥%.2f",(_originalTotalPrice-finalValue)],[_curType integerValue]);
        }
    }else{
        if (discount > 0
            && discount <= 10) {
            double finalValue = _originalTotalPrice*discount/multiple;
            _finalPriceField.text = replaceMoneyFlag([NSString stringWithFormat:@"￥%.2f",finalValue],[_curType integerValue]);
            _reduceField.text = replaceMoneyFlag([NSString stringWithFormat:@"￥%.2f",(_originalTotalPrice-finalValue)],[_curType integerValue]);
        }
    }
}
#pragma mark - Other
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

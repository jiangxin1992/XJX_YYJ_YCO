//
//  YYOrderRemarkCell.m
//  Yunejian
//
//  Created by yyj on 15/8/20.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import "YYOrderRemarkCell.h"

#import "YYDiscountView.h"
#import "YYUser.h"
#import "YYStylesAndTotalPriceModel.h"
#import "YYOrderTaxInfoView.h"

@interface YYOrderRemarkCell ()<UITextViewDelegate,YYTableCellDelegate>{
    
}

@property (weak, nonatomic) IBOutlet UIButton *firstButton;
@property (weak, nonatomic) IBOutlet UIImageView *firstView;
@property (weak, nonatomic) IBOutlet UIButton *secondButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *layoutleftConstraints;

//@property (weak, nonatomic) IBOutlet UILabel *countLabel;
//@property (weak, nonatomic) IBOutlet UIButton *discountButton;
//@property (weak, nonatomic) IBOutlet YYDiscountView *discountView;

@property (weak, nonatomic) IBOutlet UIView *taxInfoContainerView;

@property (weak, nonatomic) IBOutlet UILabel *tipsLabel;

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *discountViewLayoutWidthConstrait;
@property (assign, nonatomic) NSInteger maxLength;
@property (strong, nonatomic)YYOrderTaxInfoView *orderTaxInfoView;

@end

@implementation YYOrderRemarkCell
#pragma mark - UI

- (void)updateUI{
    YYUser *user = [YYUser currentUser];
    if(user.userType == 5||user.userType == 6||user.userType == 2)
    {
        _firstView.hidden = YES;
        [_firstButton setTitleColor:[UIColor colorWithHex:@"919191"] forState:UIControlStateNormal];
    }else{
        _firstView.hidden = NO;
        [_firstButton setTitleColor:_define_black_color forState:UIControlStateNormal];
    }
    self.maxLength = 250;
    UILabel *totalNumLabel = [self.contentView viewWithTag:10001];
    [totalNumLabel setAdjustsFontSizeToFitWidth:YES];
    UILabel *totalPriceLabel = [self.contentView viewWithTag:10002];
    [totalPriceLabel setAdjustsFontSizeToFitWidth:YES];
    UILabel *totalNumInfoLabel = [self.contentView viewWithTag:10003];
    [totalNumInfoLabel setAdjustsFontSizeToFitWidth:YES];
    
    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    self.textView.delegate = self;

    [self updateTaxInfoUI];
    
    if (_currentYYOrderInfoModel) {
        
        if (!_currentYYOrderInfoModel.billCreatePersonId) {
            [_firstButton setTitle:user.name forState:UIControlStateNormal];
            _currentYYOrderInfoModel.billCreatePersonName = user.name;
            
            NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
            [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
            
            NSNumber *tempBillCreatePersonId = [numberFormatter numberFromString:user.userId];
            _currentYYOrderInfoModel.billCreatePersonId = tempBillCreatePersonId;
            
        }else{
            NSString *name = @"";
            if (_currentYYOrderInfoModel.billCreatePersonName) {
                name = _currentYYOrderInfoModel.billCreatePersonName;
            }
            [_firstButton setTitle:name forState:UIControlStateNormal];
        }
        
        if (_currentYYOrderInfoModel.occasion
            && [_currentYYOrderInfoModel.occasion length] > 0) {
            [_secondButton setTitle:_currentYYOrderInfoModel.occasion forState:UIControlStateNormal];
        }else{
            [_secondButton setTitle:NSLocalizedString(@"选择建单场合",nil) forState:UIControlStateNormal];
        }
        

        
        if (_currentYYOrderInfoModel.orderDescription
            && [_currentYYOrderInfoModel.orderDescription length] > 0) {
            _textView.text = _currentYYOrderInfoModel.orderDescription;
            _tipsLabel.hidden = YES;
        }else{
            _tipsLabel.hidden = NO;
        }
    }
}

-(void)updateTaxInfoUI{
    
    if(_orderTaxInfoView == nil){
        NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"YYOrderTaxInfoView" owner:nil options:nil];
        Class targetClass = NSClassFromString(@"YYOrderTaxInfoView");
        for (UIView *view in views) {
            if ([view isMemberOfClass:targetClass]) {
                _orderTaxInfoView =  (YYOrderTaxInfoView *)view;
                break;
            }
        }
        [_taxInfoContainerView addSubview:_orderTaxInfoView];
        __weak UIView *weakView = _taxInfoContainerView;
        [_orderTaxInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(weakView.mas_top);
            make.left.mas_equalTo(weakView.mas_left);
            //make.bottom.mas_equalTo(weakView.mas_bottom);
            make.right.mas_equalTo(weakView.mas_right);
            make.height.mas_equalTo(200);
        }];
    }
    _orderTaxInfoView.menuData = _menuData;
    _orderTaxInfoView.delegate = self;
    _orderTaxInfoView.selectTaxType = _selectTaxType;
    _orderTaxInfoView.stylesAndTotalPriceModel = _stylesAndTotalPriceModel;
    _orderTaxInfoView.currentYYOrderInfoModel = _currentYYOrderInfoModel;
    _orderTaxInfoView.moneyType = [_currentYYOrderInfoModel.curType integerValue];
    if(_isAppendOrder || [_currentYYOrderInfoModel.isAppend integerValue] == 1){
        _orderTaxInfoView.viewType = 4;
    }else{
        _orderTaxInfoView.viewType = (_isCreatOrder?1:2);
    }
    WeakSelf(ws);
    [_orderTaxInfoView setTaxChooseBlock:^{
        if(ws.taxChooseBlock){
            ws.taxChooseBlock();
        }
    }];
    _orderTaxInfoView.parentController = _parentController;
    [_orderTaxInfoView updateUI];
    float viewHeight = [_orderTaxInfoView CellHeight];
    [_orderTaxInfoView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(viewHeight);
    }];
    
}

#pragma mark - SomeAction
- (IBAction)firstButtonClicked:(id)sender{
    if (self.buyerButtonClicked) {
        self.buyerButtonClicked(sender);
    }
}

- (IBAction)secondButtonClicked:(id)sender{
    if (self.orderSituationButtonClicked) {
        self.orderSituationButtonClicked(sender);
    }
}

- (IBAction)discountButtonClicked:(id)sender{
    if (self.discountButtonClicked) {
        self.discountButtonClicked();
    }
}

#pragma mark - UITextViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView{
    if (self.textViewIsEditCallback) {
        self.textViewIsEditCallback(YES);
    }
    _tipsLabel.hidden = YES;
}


- (void)textViewDidEndEditing:(UITextView *)textView{
    if (self.textViewIsEditCallback) {
        self.textViewIsEditCallback(NO);
    }
    
    if (textView.text
        && [textView.text length] > 0) {
        _currentYYOrderInfoModel.orderDescription = textView.text;
    }else{
        _tipsLabel.hidden = NO;
    }
    
}

-(void)textFiledEditChanged:(NSNotification *)obj{
    NSString *toBeString = _textView.text;
    NSString *lang = [[UIApplication sharedApplication] textInputMode].primaryLanguage; // 键盘输入模式
    if ([lang isEqualToString:@"zh-Hans"]) { // 简体中文输入，包括简体拼音，健体五笔，简体手写
        UITextRange *selectedRange = [_textView markedTextRange];
        //高亮部分
        UITextPosition *position = [_textView positionFromPosition:selectedRange.start offset:0];
        //已输入的文字进行字数统计和限制
        if (!position) {
            if (toBeString.length > self.maxLength) {
                _textView.text = [toBeString substringToIndex:self.maxLength];
//                AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//                [YYToast showToastWithView:appDelegate.mainViewController.view title:[NSString stringWithFormat:@"文字字数最多%ld字",(long)self.maxLength] andDuration:kAlertToastDuration];
            }
            
        }
    }
    else{
        if (toBeString.length > self.maxLength) {
            _textView.text = [toBeString substringToIndex:self.maxLength];
//            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//            [YYToast showToastWithView:appDelegate.mainViewController.view title:[NSString stringWithFormat:@"文字字数最多%ld字",(long)self.maxLength] andDuration:kAlertToastDuration];
        }
    }
    
}


#pragma YYTableCellDelegate
-(void)btnClick:(NSInteger)row section:(NSInteger)section andParmas:(NSArray *)parmas{
    NSString *type = [parmas objectAtIndex:0];
    if([type isEqualToString:@"taxType"]){
        _selectTaxType = [[parmas objectAtIndex:1] integerValue];
        if(self.taxTypeButtonClicked){
            self.taxTypeButtonClicked(_selectTaxType);
        }
    }else if([type isEqualToString:@"discount"]){
        if(self.discountButtonClicked){
            self.discountButtonClicked();
        }
    }

}
#pragma mark - Other

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFiledEditChanged:) name:@"UITextViewTextDidChangeNotification" object:_textView];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UITextViewTextDidChangeNotification" object:_textView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end

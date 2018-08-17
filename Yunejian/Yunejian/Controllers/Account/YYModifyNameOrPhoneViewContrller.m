//
//  YYModifyNameOrPhoneViewContrller.m
//  Yunejian
//
//  Created by yyj on 15/7/16.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import "YYModifyNameOrPhoneViewContrller.h"

#import "YYUserApi.h"
#import "YYTopAlertView.h"
#import "YYRspStatusAndMessage.h"
#import "RegexKitLite.h"

static CGFloat yellowView_default_constant = 233;

@interface YYModifyNameOrPhoneViewContrller ()<UITextFieldDelegate,UIPickerViewDelegate,UIPickerViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextField *textField;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *yellowViewTopLayoutConstraint;
@property (weak, nonatomic) IBOutlet UIView *yellowView;

@property (weak, nonatomic) IBOutlet UIButton *chooseCountryCodeButton;
@property (weak, nonatomic) IBOutlet UILabel *countryCodeLabel;
@property (weak, nonatomic) IBOutlet UILabel *countryCodeTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *countryCodeLine;
@property (weak, nonatomic) IBOutlet UILabel *downTitleLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *downLabelLeadLayout;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *downLabelTopLayout;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *yellowViewHightLayout;

@property (nonatomic,strong)NSArray *cityArr;
@property (nonatomic,strong) UIView *loactionPickerView;
@property (nonatomic,strong) UIButton *mengbanView;
@property (nonatomic,strong) UIPickerView *loactionPicker;

@end

@implementation YYModifyNameOrPhoneViewContrller


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
-(void)PrepareData{
    NSString* path = nil;
    if([LanguageManager isEnglishLanguage]){
        path = [[NSBundle mainBundle] pathForResource:@"englishCountryJson" ofType:@"json"];
    }else{
        path = [[NSBundle mainBundle] pathForResource:@"chineseCountryJson" ofType:@"json"];
    }
    NSData *theData = [NSData dataWithContentsOfFile:path];
    _cityArr = [[NSJSONSerialization JSONObjectWithData:theData options:NSJSONReadingMutableContainers error:nil] objectForKey:@"data"];
}
-(void)PrepareUI{
    popWindowAddBgView(self.view);
    _textField.delegate = self;
//    _textField.clearButtonMode = UITextFieldViewModeAlways;
    _countryCodeTitleLabel.text = NSLocalizedString(@"地区/区号",nil);
    _countryCodeLabel.text = @"";

    if (_currentShowType == ShowTypeUsername) {
        _textField.textAlignment = 0;
        _textField.keyboardType = UIKeyboardTypeDefault;
        _titleLabel.text = NSLocalizedString(@"修改用户名",nil);
        _chooseCountryCodeButton.hidden = YES;
        _countryCodeTitleLabel.hidden = YES;
        _countryCodeLabel.hidden = YES;
        _countryCodeLine.hidden = YES;
        _downTitleLabel.hidden = YES;
        
        _downLabelLeadLayout.constant = 17;
        _downLabelTopLayout.constant = 5;
        _yellowViewHightLayout.constant = 302;
        _yellowViewTopLayoutConstraint.constant = 233;
    }else if (_currentShowType == ShowTypePhone) {
        _textField.textAlignment = 2;
        _textField.keyboardType = UIKeyboardTypePhonePad;
        _titleLabel.text = NSLocalizedString(@"修改电话",nil);
        _chooseCountryCodeButton.hidden = NO;
        _countryCodeTitleLabel.hidden = NO;
        _countryCodeLabel.hidden = NO;
        _countryCodeLine.hidden = NO;
        _downTitleLabel.hidden = NO;
        
        _downLabelLeadLayout.constant = 87;
        _downLabelTopLayout.constant = 60;
        _yellowViewHightLayout.constant = 360;
        _yellowViewTopLayoutConstraint.constant = 203;
    }
}
#pragma mark - updateUI
//改为私有方法 防止反复调用这个方法
- (void)updateUI{
    
    if (_userInfo) {
        if (_currentShowType == ShowTypeUsername) {
            _textField.text = _userInfo.username;
            _countryCodeLabel.text = @"";
        }else if (_currentShowType == ShowTypePhone) {
            _textField.text = getPhoneNum(_userInfo.phone);
            _countryCodeLabel.text = getCountryCodeDetailDes(_userInfo.phone);
        }
    }
}
#pragma mark - 实现UIPickerViewDelegate/UIPickerViewDataSource的协议的方法

//返回的是 选择器的 列数 因为我们上图可以看到，是两列，所以返回的是2
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

//返回的是每一列的个数
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return _cityArr.count;
}

//返回的是component列的行显示的内容
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSDictionary *dict = [_cityArr objectAtIndex:row];
    NSString *_countryName=[dict objectForKey:@"countryName"];
    NSString *_phoneCode=[dict objectForKey:@"phoneCode"];
    
    if((![NSString isNilOrEmpty:_countryName])&&(![NSString isNilOrEmpty:_phoneCode]))
    {
        return [[NSString alloc] initWithFormat:@"%@+%@",_countryName,_phoneCode];
    }
    return @"";
}

// 每列宽度
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    
    return SCREEN_WIDTH;
}
#pragma mark - SomeAction
- (IBAction)chooseCountryAction:(id)sender {
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    if(!_mengbanView)
    {
        _mengbanView=[UIButton getCustomBackImgBtnWithImageStr:@"System_Mask" WithSelectedImageStr:nil];
        _mengbanView.frame=CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        [_mengbanView addTarget:self action:@selector(pickerViewHideAction) forControlEvents:UIControlEventTouchUpInside];
        _mengbanView.hidden=NO;
        [self.view.window addSubview:_mengbanView];
    }else
    {
        _mengbanView.hidden=NO;
    }
    
    if(!_loactionPickerView)
    {
        _loactionPickerView=[UIView getCustomViewWithColor:_define_white_color];
        _loactionPickerView.frame=CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 250);
        [_mengbanView addSubview:_loactionPickerView];
        _loactionPickerView.backgroundColor=_define_white_color;
        
        UIButton *cancelButton=[UIButton getCustomTitleBtnWithAlignment:0 WithFont:15.0f WithSpacing:0 WithNormalTitle:NSLocalizedString(@"取消", nil) WithNormalColor:nil WithSelectedTitle:nil WithSelectedColor:nil];
        [cancelButton addTarget:self action:@selector(pickerViewHideAction) forControlEvents:UIControlEventTouchUpInside];
        [_loactionPickerView addSubview:cancelButton];
        [cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.mas_equalTo(0);
            make.height.mas_equalTo(40);
            make.width.mas_equalTo(100);
        }];
        
        UIButton *submitButton=[UIButton getCustomTitleBtnWithAlignment:0 WithFont:15.0f WithSpacing:0 WithNormalTitle:NSLocalizedString(@"确定",nil) WithNormalColor:nil WithSelectedTitle:nil WithSelectedColor:nil];
        [submitButton addTarget:self action:@selector(chooseAction) forControlEvents:UIControlEventTouchUpInside];
        [_loactionPickerView addSubview:submitButton];
        [submitButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.top.mas_equalTo(0);
            make.height.mas_equalTo(40);
            make.width.mas_equalTo(100);
        }];
        
        //初始化mainPickView
        _loactionPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 40, SCREEN_WIDTH, 210)];
        _loactionPicker.backgroundColor = [UIColor groupTableViewBackgroundColor];
        [_loactionPickerView addSubview:_loactionPicker];
        //将自己设置为pickView的数据源
        _loactionPicker.dataSource = self;
        //将自己设置为pickView的代理
        _loactionPicker.delegate = self;
    }else
    {
        _loactionPickerView.frame=CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 250);
    }
    [_loactionPicker reloadAllComponents];
    [_loactionPicker reloadInputViews];
    [UIView animateWithDuration:0.3 animations:^{
        _loactionPickerView.frame=CGRectMake(0, SCREEN_HEIGHT-250, SCREEN_WIDTH, 250);
    } completion:^(BOOL finished) {
        
    }];
}
-(void)chooseAction
{
    NSInteger row=[_loactionPicker selectedRowInComponent:0];
    NSDictionary *dict = [_cityArr objectAtIndex:row];
    NSString *_phoneCode=[dict objectForKey:@"phoneCode"];
    NSString *countryCodeDes = getContactLocalType([_phoneCode integerValue]);
    //    +44 英国
    _countryCodeLabel.text = countryCodeDes;
    [self pickerViewHideAction];
}

-(void)pickerViewHideAction
{
    [UIView animateWithDuration:0.3 animations:^{
        _loactionPickerView.frame=CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 250);
    } completion:^(BOOL finished) {
        _mengbanView.hidden=YES;
    }];
}
- (IBAction)cancelClicked:(id)sender{
    if (_cancelButtonClicked) {
        _cancelButtonClicked();
    }
}

- (IBAction)saveClicked:(id)sender{
    NSString *textFiedlValue = trimWhitespaceOfStr(_textField.text);
    
    NSString *username = nil;
    NSString *phone = nil;
    
    if (_currentShowType == ShowTypeUsername) {
        if (! textFiedlValue || [textFiedlValue length] == 0) {
            [YYTopAlertView showWithType:YYTopAlertTypeError text:NSLocalizedString(@"请输入用户名",nil) parentView:nil];

            return;
        }
        username = textFiedlValue;
        phone = _userInfo.phone;
    
    }else if (_currentShowType == ShowTypePhone) {
        if (! textFiedlValue || [textFiedlValue length] == 0) {
            [YYTopAlertView showWithType:YYTopAlertTypeError text:NSLocalizedString(@"请输入电话",nil) parentView:nil];

            return;
        }
        
        BOOL isNumbers = [textFiedlValue isMatchedByRegex:@"^[0-9]*$"];
        if (!isNumbers) {
            [YYTopAlertView showWithType:YYTopAlertTypeError text:NSLocalizedString(@"电话号码请输入数字！",nil) parentView:nil];

            return;
        }
        
        if ([textFiedlValue length] < 6) {
            [YYTopAlertView showWithType:YYTopAlertTypeError text:NSLocalizedString(@"电话号码最少为6位",nil) parentView:nil];
            
            return;
        }
        
        username = _userInfo.username;
        phone = textFiedlValue;
    }
    
    if (_userInfo.userType == YYUserTypeDesigner) {
        
        if (_currentShowType == ShowTypeUsername) {
            NSArray *phoneArr = [phone componentsSeparatedByString:@" "];
            if(phoneArr.count > 1){
                
            }else{
                phone = [[NSString alloc] initWithFormat:@"+86 %@",phone];
            }
            phone = [phone stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
        }else if (_currentShowType == ShowTypePhone) {
            NSArray *getCodeArr = [_countryCodeLabel.text componentsSeparatedByString:@" "];
            if(getCodeArr.count){
                NSString *countryCode = [getCodeArr[0] stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
                phone = [[NSString alloc] initWithFormat:@"%@ %@",countryCode,phone];
            }
        }
        
        [YYUserApi updateDesignerUsername:username phone:phone andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSError *error) {
            if (rspStatusAndMessage.status == YYReqStatusCode100) {
                [YYTopAlertView showWithType:YYTopAlertTypeSuccess text:NSLocalizedString(@"修改成功",nil) parentView:nil];
                if (_modifySuccess) {
                    _modifySuccess();
                }
            }else{
                [YYTopAlertView showWithType:YYTopAlertTypeError text:rspStatusAndMessage.message parentView:nil];
            }
            
        }];
    }else if (_userInfo.userType == YYUserTypeRetailer){
        NSString *province = [LanguageManager isEnglishLanguage]?self.userInfo.provinceEn:self.userInfo.province;
        NSString *city = [LanguageManager isEnglishLanguage]?self.userInfo.cityEn:self.userInfo.city;
        [YYUserApi updateBuyerUsername:username phone:phone  province:province city:city andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSError *error) {
            if (rspStatusAndMessage.status == YYReqStatusCode100) {
                [YYTopAlertView showWithType:YYTopAlertTypeSuccess text:NSLocalizedString(@"修改成功",nil) parentView:nil];

                if (_modifySuccess) {
                    _modifySuccess();
                }
            }else{
                [YYTopAlertView showWithType:YYTopAlertTypeError text:rspStatusAndMessage.message parentView:nil];
            }
            
        }];
    }else{
    
    }
    
}

@end

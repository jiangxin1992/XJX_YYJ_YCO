//
//  YYPhoneTableViewCell.m
//  Yunejian
//
//  Created by chuanjun sun on 2017/8/21.
//  Copyright © 2017年 yyj. All rights reserved.
//

#import "YYPhoneTableViewCell.h"

#import "YYPickerViewController.h"

#import "YYVerifyTool.h"

#define equalTo(mas) mas_equalTo(mas)
#define offset(mas) mas_offset(mas)


typedef NS_ENUM(NSInteger, pickerType) {
    /** 手机号选择地域 */
    kYYPhoneArea,
    /** 手机号查看权限 */
    kYYPhonePover,
};

@interface YYPhoneTableViewCell()<YYPickerDelegate, UITextFieldDelegate>

/** 手机号标题 */
@property (nonatomic, strong) UILabel *titleLabel;
/** 手机号浮标图 */
@property (nonatomic, strong) UILabel *subtitleLabel;
/** 手机号 */
@property(nonatomic,strong) UITextField *phoneTextField;
/** 手机号选择地区 */
@property(nonatomic,strong) UIButton *choosePhoneLocationBtn;
/** 手机号警告 */
@property(nonatomic,strong) UIView *phoneWarnView;

/** 数据 */
@property(nonatomic,strong) NSArray *dataArr;
/** 城市 */
@property(nonatomic,strong) NSArray *cityArr;

/** 固定电话的权限选择 */
@property (nonatomic, strong) UIButton *phoneCheckState;

/** 当前弹出的picker */
@property (nonatomic, assign) pickerType pickerTag;

/** 手机号的代码 */
@property (nonatomic, copy) NSString *phoneCode;

/** 完整的手机号 */
@property (nonatomic, copy) NSString *phoneNumber;

/** 权限 */
@property (nonatomic, assign) NSInteger phonePowerNumber;

@end

#define textFieldHeight 44

@implementation YYPhoneTableViewCell

#pragma mark - --------------生命周期--------------
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{

    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        [self somePrepare];
    }

    return self;
}

#pragma mark - --------------SomePrepare--------------
- (void)somePrepare
{
    [self prepareData];
    [self prepareUI];
}
- (void)prepareData{
    self.dataArr = @[NSLocalizedString(@"固定电话",nil),NSLocalizedString(@"手机号",nil),];
    NSString* path = nil;
    if([LanguageManager isEnglishLanguage]){
        path = [[NSBundle mainBundle] pathForResource:@"englishCountryJson" ofType:@"json"];
    }else{
        path = [[NSBundle mainBundle] pathForResource:@"chineseCountryJson" ofType:@"json"];
    }

    NSData *theData = [NSData dataWithContentsOfFile:path];

    self.cityArr = [[NSJSONSerialization JSONObjectWithData:theData options:NSJSONReadingMutableContainers error:nil] objectForKey:@"data"];

}

#pragma mark - --------------UI----------------------
// 创建子控件
- (void)prepareUI{

    // 手机号 -- 头部
    UILabel *phoneLabel = [[UILabel alloc] init];
    phoneLabel.font = [UIFont boldSystemFontOfSize:14];  // height 17
    phoneLabel.text = NSLocalizedString(@"手机号",nil);
    self.titleLabel = phoneLabel;
    [self addSubview:phoneLabel];

    [phoneLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(17);
        make.top.mas_equalTo(19);
        make.right.mas_equalTo(0);
    }];

    UILabel *subTitleLabel = [[UILabel alloc] init];
    subTitleLabel.font = [UIFont systemFontOfSize:13];
    subTitleLabel.textColor = [UIColor colorWithHex:@"919191"];
    self.subtitleLabel = subTitleLabel;
    [self addSubview:subTitleLabel];

    [subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(phoneLabel.mas_right).mas_offset(4);
        make.centerY.mas_equalTo(phoneLabel.mas_centerY);
    }];

    // 地区选择
    _choosePhoneLocationBtn = [UIButton getCustomTitleBtnWithAlignment:1 WithFont:14.0f WithSpacing:0 WithNormalTitle:nil WithNormalColor:nil WithSelectedTitle:nil WithSelectedColor:nil];
    [_choosePhoneLocationBtn addTarget:self action:@selector(ChooseLocationAction:) forControlEvents:UIControlEventTouchUpInside];

    _choosePhoneLocationBtn.tag = kYYPhoneArea;
    _choosePhoneLocationBtn.imageEdgeInsets = UIEdgeInsetsMake(19, 75, 19, 10);
    _choosePhoneLocationBtn.titleEdgeInsets = UIEdgeInsetsMake(0, -15, 0, 0);
    [_choosePhoneLocationBtn setImage:[UIImage imageNamed:@"System_Triangle"] forState:UIControlStateNormal];
    setCornerRadiusBorder(_choosePhoneLocationBtn);
    [self addSubview:_choosePhoneLocationBtn];

    [_choosePhoneLocationBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(17);
        make.top.mas_equalTo(phoneLabel.mas_bottom).with.offset(12);
        make.height.mas_equalTo(textFieldHeight);
        make.width.mas_equalTo(95);
        make.bottom.mas_equalTo(0);
    }];

    _phoneTextField = [UITextField getTextFieldWithPlaceHolder:NSLocalizedString(@"商务联系手机号",nil) WithAlignment:0 WithFont:13.0f WithTextColor:_define_black_color WithLeftWidth:8 WithRightWidth:8 WithSecureTextEntry:NO HaveBorder:YES WithBorderColor:[UIColor colorWithHex:kDefaultBorderColor]];
    _phoneTextField.borderStyle = UITextBorderStyleNone;
    _phoneTextField.keyboardType = UIKeyboardTypeNumberPad;
    _phoneTextField.delegate = self;
//    _phoneTextField.tag = kYYTextFieldTypephone;
    [_phoneTextField addTarget:self action:@selector(changeTextField) forControlEvents:UIControlEventEditingChanged];
    setCornerRadiusBorder(_phoneTextField);

    [self addSubview:_phoneTextField];
    [_phoneTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_choosePhoneLocationBtn.mas_right).with.offset(10);
        make.centerY.mas_equalTo(_choosePhoneLocationBtn);
        make.width.mas_equalTo(245);
        make.height.mas_equalTo(textFieldHeight);
    }];

    {
        // 下拉选择
        UIButton *checkState = [UIButton getCustomTitleBtnWithAlignment:1 WithFont:14.0f WithSpacing:0 WithNormalTitle:nil WithNormalColor:nil WithSelectedTitle:nil WithSelectedColor:nil];
        [self addSubview:checkState];

        self.phoneCheckState = checkState;
        //125
        if([LanguageManager isEnglishLanguage]){
            checkState.imageEdgeInsets=UIEdgeInsetsMake(19, 220, 19, 10);
        }else{
            checkState.imageEdgeInsets=UIEdgeInsetsMake(19, 125, 19, 10);
        }

        [checkState addTarget:self action:@selector(CheckStateAction:) forControlEvents:UIControlEventTouchUpInside];
        checkState.tag = kYYPhonePover;
        checkState.titleEdgeInsets=UIEdgeInsetsMake(0, -15, 0, 0);
        [checkState setImage:[UIImage imageNamed:@"System_Triangle"] forState:UIControlStateNormal];
        // 默认值
        [checkState setTitle:NSLocalizedString(@"仅合作买手店可见",nil) forState:UIControlStateNormal];
        checkState.selected=NO;
        setCornerRadiusBorder(checkState);
        [checkState mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(390);
            make.top.mas_equalTo(phoneLabel.mas_bottom).with.offset(12);
            make.height.mas_equalTo(textFieldHeight);
            if([LanguageManager isEnglishLanguage]){
                make.width.mas_equalTo(240);
            }else{
                make.width.mas_equalTo(145);
            }
        }];

        UIView *warnView = [UIView getCustomViewWithColor:_define_white_color];
        [self addSubview:warnView];
        self.phoneWarnView = warnView;
        [warnView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(0);
            make.left.mas_equalTo(checkState.mas_right).with.offset(0);
            make.height.mas_equalTo(checkState.mas_height);
            make.centerY.mas_equalTo(checkState);
        }];

        UIImageView *warnImg=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"warn"]];
        [warnView addSubview:warnImg];
        [warnImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(warnView);
            make.left.mas_equalTo(9);
            make.height.width.mas_equalTo(15);
        }];

        UILabel *warnLabel = [UILabel getLabelWithAlignment:0 WithTitle:NSLocalizedString(@"",nil) WithFont:13.0f WithTextColor:[UIColor redColor] WithSpacing:0];
        warnLabel.text = NSLocalizedString(@"手机号码格式错误",nil);
        [warnView addSubview:warnLabel];
        [warnLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(warnImg.mas_right).with.offset(4);
            make.centerY.mas_equalTo(warnView);
        }];

        warnView.hidden=YES;
    }

}

#pragma mark - --------------系统代理----------------------
#pragma mark - 失去焦点
- (void)textFieldDidEndEditing:(UITextField *)textField{
    [self CheckLegal];
}

#pragma mark - --------------自定义代理/block----------------------
- (void)YYPickerController:(YYPickerViewController *)controller index:(NSInteger)index content:(NSString *)content{
    switch (self.pickerTag) {

        case kYYPhonePover:
            [self.phoneCheckState setTitle:content forState:UIControlStateNormal];
            self.phonePowerNumber = index;
            // 将改变后的值传递出去
            // 安全判断
            if (self.phonePowerContent) {
                self.phonePowerContent(index);
            }

            break;
        case kYYPhoneArea:
        {
            NSDictionary *dict = self.cityArr[index];
            [self.choosePhoneLocationBtn setTitle:[NSString stringWithFormat:@"%@ +%@", dict[@"countryName"], dict[@"phoneCode"]] forState:UIControlStateNormal];
            self.phoneCode = dict[@"phoneCode"];
            // 安全判断
            if (self.phoneContent) {
                self.phoneContent([NSString stringWithFormat:@"+%@ %@", self.phoneCode, self.phoneTextField.text]);
            }
        }
            break;

        default:
            break;
    }
}

#pragma mark - --------------自定义响应----------------------
-(void)ChooseLocationAction:(UIButton *)button{

    self.pickerTag = button.tag;
    // 创建选择器
    YYPickerViewController *datePickerController = [[YYPickerViewController alloc] init];
    datePickerController.view.frame = self.bounds;
    datePickerController.delegate = self;

    NSMutableArray *area = [NSMutableArray array];
    for (NSDictionary *dict in self.cityArr) {
        NSString *str = [NSString stringWithFormat:@"%@+%@", dict[@"countryName"], dict[@"phoneCode"]];
        [area addObject:str];
    }
    // 设置默认值
    datePickerController.data = area;

    [[self getController:self] presentViewController:datePickerController animated:NO completion:nil];
}

- (void)CheckStateAction:(UIButton *)button{
    self.pickerTag = button.tag;
    // 创建选择器
    YYPickerViewController *datePickerController = [[YYPickerViewController alloc] init];
    datePickerController.view.frame = self.bounds;
    datePickerController.delegate = self;
    // 设置默认值
    datePickerController.data = self.phonePickerData[1];

    [[self getController:self] presentViewController:datePickerController animated:NO completion:nil];
}

#pragma mark - --------------自定义方法----------------------
// 占位 宽度8
-(UIView *)getTextBlockView
{
    UIView *view=[UIView getCustomViewWithColor:_define_white_color];
    view.frame=CGRectMake(0, 0, 8, textFieldHeight);
    return view;

}
// 短划线
-(UIView *)getMiddleLineView
{
    UIView *view=[UIView getCustomViewWithColor:_define_white_color];
    view.frame=CGRectMake(0, 0, 7, textFieldHeight);

    UIView *middleLine=[UIView getCustomViewWithColor:_define_black_color];
    [view addSubview:middleLine];
    [middleLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.width.mas_equalTo(view);
        make.height.mas_equalTo(2);
    }];
    return view;
}

#pragma mark - get/set
// 手机号
- (void)setPhone:(NSString *)phone{
    NSArray *array = [phone componentsSeparatedByString:@" "];

    NSString *block = [[array[0] componentsSeparatedByString:@"+"] lastObject];
    for (NSDictionary *dict in self.cityArr) {
        if ([dict[@"phoneCode"] isEqualToString:block]) {
            [self.choosePhoneLocationBtn setTitle:[NSString stringWithFormat:@"%@ +%@", dict[@"countryName"], dict[@"phoneCode"]] forState:UIControlStateNormal];
            self.phoneCode = dict[@"phoneCode"];
            break;
        }
    }

    if ([NSString isNilOrEmpty:block]) {
        // 为空 应该设置默认值
        [self.choosePhoneLocationBtn setTitle:NSLocalizedString(@"中国 +86",nil) forState:UIControlStateNormal];
        self.phoneCode = @"86";
    }

    // 说明按照空格没有切出东西，说明手机号为空
    if (array.count <= 1) {
        self.phoneTextField.text = @"";
    }else{
        // 初始值
        self.phoneTextField.text = array[1];
    }

    // 默认值
    // 安全判断
    if (self.phoneContent) {
        self.phoneContent([NSString stringWithFormat:@"+%@ %@", self.phoneCode, self.phoneTextField.text]);
    }
}

// 手机号数据
- (void)setPhonePickerData:(NSArray *)phonePickerData{

    _phonePickerData = phonePickerData;
    NSInteger index = [phonePickerData[0] integerValue];
    NSArray *array = phonePickerData[1];
    self.phonePowerNumber = index;
    [self.phoneCheckState setTitle:array[index] forState:UIControlStateNormal];

    // 将改变后的值传递出去
    // 安全判断
    if (self.phonePowerContent) {
        self.phonePowerContent(index);
    }
}

// 给标题赋值
- (void)setTitle:(NSString *)title{
    _title = title;
    self.titleLabel.text = title;
}

// 给副标题赋值
- (void)setSubtitle:(NSString *)subtitle{
    _subtitle = subtitle;
    self.subtitleLabel.text = subtitle;
}
#pragma mark - 检查

- (void)CheckLegal{
    //电话
    if([NSString isNilOrEmpty:_phoneTextField.text]){
        //为空
        _phoneWarnView.hidden=YES;
    }else{
        if([YYVerifyTool numberVerift:_phoneTextField.text]){
            if([self.phoneCode isEqualToString:@"86"]){
                //中国时，号码验证
                if([YYVerifyTool phoneVerify:_phoneTextField.text]){
                    _phoneWarnView.hidden=YES;
                }else{
                    _phoneWarnView.hidden=NO;
                }
            }else{
                //非中国时，长度验证（6-20位）
                if(_phoneTextField.text.length<=20 && _phoneTextField.text.length>=6){
                    _phoneWarnView.hidden=YES;

                }else{
                    _phoneWarnView.hidden=NO;

                }
            }
        }else{
            _phoneWarnView.hidden=NO;
        }
    }
}

#pragma mark - 监听输入框变化
- (void)changeTextField{
    // 安全判断
    if (self.phoneContent) {
        self.phoneContent([NSString stringWithFormat:@"+%@ %@", self.phoneCode, self.phoneTextField.text]);
    }
}

#pragma mark - 设置隐藏权限按钮
- (void)hiddenPicker{
    self.phoneCheckState.hidden = YES;
    [self.phoneWarnView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(0);
        make.left.mas_equalTo(self.phoneTextField.mas_right).with.offset(5);
        make.height.mas_equalTo(self.phoneTextField.mas_height);
        make.centerY.mas_equalTo(self.phoneTextField.mas_centerY);
    }];
    
}

#pragma mark - --------------other----------------------
#pragma mark - 可以获取到父容器的控制器的方法,就是这个黑科技.
- (UIViewController *)getController:(UIView *)view{
    UIResponder *responder = view;
    //循环获取下一个响应者,直到响应者是一个UIViewController类的一个对象为止,然后返回该对象.
    while ((responder = [responder nextResponder])) {
        if ([responder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)responder;
        }
    }
    return [UIApplication sharedApplication].keyWindow.rootViewController;
}


@end

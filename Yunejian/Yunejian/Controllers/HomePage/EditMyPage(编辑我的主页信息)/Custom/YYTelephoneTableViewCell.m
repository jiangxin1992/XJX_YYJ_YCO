//
//  YYTelephoneTableViewCell.m
//  Yunejian
//
//  Created by chuanjun sun on 2017/8/23.
//  Copyright © 2017年 yyj. All rights reserved.
//

#import "YYTelephoneTableViewCell.h"

#import "YYPickerViewController.h"

#import "YYVerifyTool.h"

#define equalTo(mas) mas_equalTo(mas)
#define offset(mas) mas_offset(mas)


typedef NS_ENUM(NSInteger, pickerType) {
    /** 固定电话选择地域 */
    kYYTelePhoneArea,
    /** 固定电话查看权限 */
    kYYTelePhonePover,
};

@interface YYTelephoneTableViewCell()<YYPickerDelegate, UITextFieldDelegate>

/** 区号 */
@property(nonatomic,strong) UITextField *telephoneBlockTextField;
/** 电话号码 */
@property(nonatomic,strong) UITextField *telephoneTextField;
/** 分机号 */
@property(nonatomic,strong) UITextField *telephoneExtensionTextField;
/** 电话选择地区 */
@property(nonatomic,strong) UIButton *chooseTelephoneLocationBtn;
/** 电话号警告 */
@property(nonatomic,strong) UIView *telephoneWarnView;

/** 数据 */
@property(nonatomic,strong) NSArray *dataArr;
/** 城市 */
@property(nonatomic,strong) NSArray *cityArr;

/** 固定电话的权限选择 */
@property (nonatomic, strong) UIButton *telephoneCheckState;

/** 当前弹出的picker */
@property (nonatomic, assign) pickerType pickerTag;

/** 固定电话的代码 */
@property (nonatomic, copy) NSString *telephoneCode;

/** 完整的固定电话 */
@property (nonatomic, copy) NSString *telephoneNumber;

/** 权限 */
@property (nonatomic, assign) NSInteger telephonePowerNumber;

@end

#define textFieldHeight 44

@implementation YYTelephoneTableViewCell

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
    self.dataArr = @[NSLocalizedString(@"固定电话",nil)];
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
    // 固定电话 -- 头部
    UILabel *telephoneLabel = [[UILabel alloc] init];
    telephoneLabel.font = [UIFont boldSystemFontOfSize:14];  // height 17
    telephoneLabel.text = NSLocalizedString(@"固定电话",nil);
    [self addSubview:telephoneLabel];

    [telephoneLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(17);
        make.top.mas_equalTo(19);
        make.right.mas_equalTo(0);
    }];
    // 地区选择
    _chooseTelephoneLocationBtn = [UIButton getCustomTitleBtnWithAlignment:1 WithFont:14.0f WithSpacing:0 WithNormalTitle:nil WithNormalColor:nil WithSelectedTitle:nil WithSelectedColor:nil];
    [_chooseTelephoneLocationBtn addTarget:self action:@selector(ChooseLocationAction:) forControlEvents:UIControlEventTouchUpInside];
    _chooseTelephoneLocationBtn.imageEdgeInsets=UIEdgeInsetsMake(19, 80, 19, 5);
    _chooseTelephoneLocationBtn.tag = kYYTelePhoneArea;
    _chooseTelephoneLocationBtn.titleEdgeInsets=UIEdgeInsetsMake(0, -15, 0, 0);
    [_chooseTelephoneLocationBtn setImage:[UIImage imageNamed:@"System_Triangle"] forState:UIControlStateNormal];
    setCornerRadiusBorder(_chooseTelephoneLocationBtn);

    [self addSubview:_chooseTelephoneLocationBtn];
    [_chooseTelephoneLocationBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(17);
        make.top.mas_equalTo(telephoneLabel.mas_bottom).with.offset(12);
        make.height.mas_equalTo(textFieldHeight);
        make.width.mas_equalTo(95);
    }];

    // 电话输入框，大框
    UIView *middleView=[UIView getCustomViewWithColor:nil];
    [self addSubview:middleView];
    middleView.layer.masksToBounds=YES;
    middleView.layer.borderWidth=1;
    middleView.layer.borderColor=[UIColor colorWithHex:kDefaultBorderColor].CGColor;
    [middleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_chooseTelephoneLocationBtn.mas_right).with.offset(10);
        make.centerY.mas_equalTo(_chooseTelephoneLocationBtn);
        make.height.mas_equalTo(_chooseTelephoneLocationBtn);
        make.width.mas_equalTo(245);
    }];

    // 区号
    _telephoneBlockTextField = [UITextField getTextFieldWithPlaceHolder:NSLocalizedString(@"区号",nil) WithAlignment:0 WithFont:13.0f WithTextColor:_define_black_color WithLeftView:[self getTextBlockView] WithRightView:[self getMiddleLineView] WithSecureTextEntry:NO];
    _telephoneBlockTextField.borderStyle = UITextBorderStyleNone;
    _telephoneBlockTextField.delegate = self;
    _telephoneBlockTextField.keyboardType = UIKeyboardTypeNumberPad;
    //    _telephoneBlockTextField.tag = kYYTextFieldTypeBlock;
    [_telephoneBlockTextField addTarget:self action:@selector(changeTextField) forControlEvents:UIControlEventEditingChanged];
    [middleView addSubview:_telephoneBlockTextField];

    [_telephoneBlockTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.mas_equalTo(0);
        if([LanguageManager isEnglishLanguage]){
            make.width.mas_equalTo(79);
        }else{
            make.width.mas_equalTo(60);
        }
    }];
    // 电话号码
    _telephoneTextField = [UITextField getTextFieldWithPlaceHolder:NSLocalizedString(@"电话号码",nil) WithAlignment:0 WithFont:13.0f WithTextColor:_define_black_color WithLeftView:[self getTextBlockView] WithRightView:[self getMiddleLineView] WithSecureTextEntry:NO];
    _telephoneTextField.delegate = self;
    _telephoneTextField.borderStyle = UITextBorderStyleNone;
    _telephoneTextField.keyboardType = UIKeyboardTypeNumberPad;
    //    _telephoneTextField.tag = kYYTextFieldTypeTelephone;
    [_telephoneTextField addTarget:self action:@selector(changeTextField) forControlEvents:UIControlEventEditingChanged];

    [middleView addSubview:_telephoneTextField];

    [_telephoneTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.mas_equalTo(0);
        make.left.equalTo(_telephoneBlockTextField.mas_right);
        if([LanguageManager isEnglishLanguage]){
            make.width.mas_equalTo(96);
        }else{
            make.width.mas_equalTo(110);
        }
    }];

    // 分机号
    _telephoneExtensionTextField = [UITextField getTextFieldWithPlaceHolder:NSLocalizedString(@"分机号",nil) WithAlignment:0 WithFont:13.0f WithTextColor:_define_black_color WithLeftWidth:8 WithRightWidth:0 WithSecureTextEntry:NO HaveBorder:NO WithBorderColor:nil];
    _telephoneExtensionTextField.borderStyle = UITextBorderStyleNone;
    _telephoneExtensionTextField.delegate = self;
    _telephoneExtensionTextField.keyboardType = UIKeyboardTypeNumberPad;
    //    _telephoneExtensionTextField.tag = kYYTextFieldTypeTelephoneExtension;
    [_telephoneExtensionTextField addTarget:self action:@selector(changeTextField) forControlEvents:UIControlEventEditingChanged];

    [middleView addSubview:_telephoneExtensionTextField];

    [_telephoneExtensionTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.top.bottom.mas_equalTo(0);
        if([LanguageManager isEnglishLanguage]){
            make.width.mas_equalTo(70);
        }else{
            make.width.mas_equalTo(75);
        }
    }];

    if([LanguageManager isEnglishLanguage]){
        _telephoneBlockTextField.font = getFont(11.0f);
        _telephoneTextField.font = getFont(11.0f);
        _telephoneExtensionTextField.font = getFont(11.0f);
    }else{
        _telephoneBlockTextField.font = getFont(13.0f);
        _telephoneTextField.font = getFont(13.0f);
        _telephoneExtensionTextField.font = getFont(13.0f);
    }

    // 下拉选择
    UIButton *checkState=[UIButton getCustomTitleBtnWithAlignment:1 WithFont:14.0f WithSpacing:0 WithNormalTitle:nil WithNormalColor:nil WithSelectedTitle:nil WithSelectedColor:nil];
    [self addSubview:checkState];

    //125
    if([LanguageManager isEnglishLanguage]){
        checkState.imageEdgeInsets=UIEdgeInsetsMake(19, 220, 19, 10);
    }else{
        checkState.imageEdgeInsets=UIEdgeInsetsMake(19, 125, 19, 10);
    }

    [checkState addTarget:self action:@selector(CheckStateAction:) forControlEvents:UIControlEventTouchUpInside];
    checkState.titleEdgeInsets=UIEdgeInsetsMake(0, -15, 0, 0);
    checkState.tag = kYYTelePhonePover;
    self.telephoneCheckState = checkState;
    [checkState setImage:[UIImage imageNamed:@"System_Triangle"] forState:UIControlStateNormal];
    [checkState setTitle:NSLocalizedString(@"公开",nil) forState:UIControlStateNormal];
    checkState.selected=NO;
    setCornerRadiusBorder(checkState);
    [checkState mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(390);
        make.top.mas_equalTo(telephoneLabel.mas_bottom).with.offset(12);
        make.height.mas_equalTo(textFieldHeight);
        if([LanguageManager isEnglishLanguage]){
            make.width.mas_equalTo(240);
        }else{
            make.width.mas_equalTo(145);
        }
    }];

    UIView *warnView = [UIView getCustomViewWithColor:_define_white_color];
    [self addSubview:warnView];
    self.telephoneWarnView = warnView;
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
    warnLabel.text = NSLocalizedString(@"区号或电话号码错误",nil);
    [warnView addSubview:warnLabel];
    [warnLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(warnImg.mas_right).with.offset(4);
        make.centerY.mas_equalTo(warnView);
    }];

    warnView.hidden=YES;

}

#pragma mark - --------------系统代理----------------------
#pragma mark - 失去焦点
- (void)textFieldDidEndEditing:(UITextField *)textField{
    [self CheckLegal];
}

#pragma mark - --------------自定义代理/block----------------------
- (void)YYPickerController:(YYPickerViewController *)controller index:(NSInteger)index content:(NSString *)content{
    switch (self.pickerTag) {
        case kYYTelePhonePover:
            [self.telephoneCheckState setTitle:content forState:UIControlStateNormal];
            self.telephonePowerNumber = index;
            // 将改变后的值传递出去
            // 安全判断
            if (self.telephonePowerContent) {
                self.telephonePowerContent(index);
            }

            break;
        case kYYTelePhoneArea:
        {
            NSDictionary *dict = self.cityArr[index];
            [self.chooseTelephoneLocationBtn setTitle:[NSString stringWithFormat:@"%@ +%@", dict[@"countryName"], dict[@"phoneCode"]] forState:UIControlStateNormal];
            self.telephoneCode = dict[@"phoneCode"];
            // 安全判断
            if (self.telephoneContent) {
                self.telephoneContent([NSString stringWithFormat:@"+%@ %@-%@-%@", self.telephoneCode,
                                       self.telephoneBlockTextField.text,
                                       self.telephoneTextField.text,
                                       self.telephoneExtensionTextField.text]);
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
    datePickerController.data = self.telePhonePickerData[1];

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
// 固定电话
- (void)setTelePhone:(NSString *)telePhone{

    NSArray *array = [telePhone componentsSeparatedByString:@" "];

    NSString *block = [[array[0] componentsSeparatedByString:@"+"] lastObject];
    for (NSDictionary *dict in self.cityArr) {
        if ([dict[@"phoneCode"] isEqualToString:block]) {
            [self.chooseTelephoneLocationBtn setTitle:[NSString stringWithFormat:@"%@ +%@", dict[@"countryName"], dict[@"phoneCode"]] forState:UIControlStateNormal];
            self.telephoneCode = dict[@"phoneCode"];
            break;
        }
    }

    if ([NSString isNilOrEmpty:block]) {
        // 为空 应该设置默认值
        [self.chooseTelephoneLocationBtn setTitle:NSLocalizedString(@"中国 +86",nil) forState:UIControlStateNormal];
        self.telephoneCode = @"86";
    }

    // 说明按照空格没有切出东西，说明手机号为空
    if (array.count <= 1) {
        self.telephoneBlockTextField.text = @"";
        self.telephoneTextField.text = @"";
        self.telephoneExtensionTextField.text = @"";
    }else{
        // 初始值, 传递过来的有多种情况，例： +86 , +86 0088, +86 0088-1283744, +86 0088-00888899-023, 需要考虑越界的情况
        NSArray *text = [array[1] componentsSeparatedByString:@"-"];
        for (int x = 0; x < text.count; x++) {
            if (x == 0) {
                self.telephoneBlockTextField.text = [NSString isNilOrEmpty:text[0]]? @"": text[0];
            }else if (x == 1){
                self.telephoneTextField.text = [NSString isNilOrEmpty:text[1]]? @"": text[1];
            }else if (x == 2){
                self.telephoneExtensionTextField.text = [NSString isNilOrEmpty:text[2]]? @"": text[2];
            }
        }
    }


    // 默认值
    // 安全判断
    if (self.telephoneContent) {
        self.telephoneContent([NSString stringWithFormat:@"+%@ %@-%@-%@", self.telephoneCode,
                               self.telephoneBlockTextField.text,
                               self.telephoneTextField.text,
                               self.telephoneExtensionTextField.text]);
    }
}

// 固定电话数据
- (void)setTelePhonePickerData:(NSArray *)telePhonePickerData{
    _telePhonePickerData = telePhonePickerData;
    NSInteger index = [telePhonePickerData[0] integerValue];

    NSArray *array = telePhonePickerData[1];
    self.telephonePowerNumber = index;
    [self.telephoneCheckState setTitle:array[index] forState:UIControlStateNormal];

    // 将默认的值传递出去
    // 安全判断
    if (self.telephonePowerContent) {
        self.telephonePowerContent(index);
    }
}

#pragma mark - 检查

- (void)CheckLegal{
    //固定电话
    __block BOOL _uncorrectFormat=NO;
    NSArray *textfieldViewArr=@[_telephoneBlockTextField, _telephoneTextField, _telephoneExtensionTextField];
    [textfieldViewArr enumerateObjectsUsingBlock:^(UITextField *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if(![NSString isNilOrEmpty:obj.text]){
            if([YYVerifyTool numberVerift:obj.text]){
                if([self.telephoneCode isEqualToString:@"86"]){
                    //中国
                    if(idx==0){
                        if([YYVerifyTool telephoneAreaCode:obj.text]){
                            _uncorrectFormat=NO;
                        }else{
                            _uncorrectFormat=YES;
                            *stop=YES;
                        }
                    }else if(idx==1){
                        if(obj.text.length<=10&&obj.text.length>=5){
                            _uncorrectFormat=NO;
                        }else{
                            _uncorrectFormat=YES;
                            *stop=YES;
                        }
                    }
                }else{
                    if(idx==0){
                        if(obj.text.length<=6&&obj.text.length>=3){
                            _uncorrectFormat=NO;
                        }else{
                            _uncorrectFormat=YES;
                            *stop=YES;
                        }
                    }else if(idx==1){
                        if(obj.text.length<=10&&obj.text.length>=5){
                            _uncorrectFormat=NO;
                        }else{
                            _uncorrectFormat=YES;
                            *stop=YES;
                        }
                    }
                }
            }else{
                _uncorrectFormat = YES;
                *stop = YES;
            }
        }
    }];

    if(_uncorrectFormat){
        _telephoneWarnView.hidden=NO;
    }else{
        _telephoneWarnView.hidden=YES;
    }
}

#pragma mark - 监听输入框变化
- (void)changeTextField{

    // 安全判断
    if (self.telephoneContent) {
        self.telephoneContent([NSString stringWithFormat:@"+%@ %@-%@-%@", self.telephoneCode,
                               self.telephoneBlockTextField.text,
                               self.telephoneTextField.text,
                               self.telephoneExtensionTextField.text]);
    }
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

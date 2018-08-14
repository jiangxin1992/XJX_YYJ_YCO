//
//  YYEditMyPageTableViewCell.m
//  Yunejian
//
//  Created by chuanjun sun on 2017/8/18.
//  Copyright © 2017年 yyj. All rights reserved.
//

#import "YYEditMyPageCurrencyCell.h"

#import "YYPickerViewController.h"

#import "YYVerifyTool.h"

#define equalTo(mas) mas_equalTo(mas)
#define offset(mas) mas_offset(mas)

@interface YYEditMyPageCurrencyCell()<YYPickerDelegate, UITextFieldDelegate>
/** 标题 */
@property (nonatomic, strong) UILabel *titleLabel;
/** 副标题 */
@property (nonatomic, strong) UILabel *subTitleLabel;
/** 输入框样式 */
@property (nonatomic, strong) UITextField *contentTextField;

/** picker按钮 */
@property (nonatomic, strong) UIButton *selectButton;
/** 警告 */
@property (nonatomic, strong) UIView *warnView;
/** 警告的内容 */
@property (nonatomic, strong) UILabel *warnLabel;
@end

@implementation YYEditMyPageCurrencyCell

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

}

#pragma mark - --------------UI----------------------
// 创建子控件
- (void)prepareUI{
    // 标题
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.font = [UIFont boldSystemFontOfSize:14];  // height 17
    self.titleLabel = titleLabel;
    [self addSubview:titleLabel];

    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(17);
        make.top.mas_equalTo(19);
    }];

    UILabel *subTitleLabel = [[UILabel alloc] init];
    subTitleLabel.font = [UIFont systemFontOfSize:13];
    subTitleLabel.textColor = [UIColor colorWithHex:@"919191"];
    self.subTitleLabel = subTitleLabel;
    [self addSubview:subTitleLabel];

    [subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(titleLabel.mas_right).mas_offset(4);
        make.centerY.mas_equalTo(titleLabel.mas_centerY);
    }];

    // 输入框
    UITextField *contentTextField = [[UITextField alloc] init];
    contentTextField.font = [UIFont systemFontOfSize:13];
    contentTextField.textColor = [UIColor colorWithHex:kDefaultTitleColor_pad];
    contentTextField.layer.borderWidth = 1;
    contentTextField.layer.borderColor = [UIColor colorWithHex:kDefaultBorderColor].CGColor;
    contentTextField.layer.masksToBounds = YES;
    contentTextField.layer.cornerRadius = 2;
    contentTextField.secureTextEntry = NO;

    [contentTextField addTarget:self action:@selector(changeTextField) forControlEvents:UIControlEventEditingChanged];
    contentTextField.delegate = self;
    
    self.contentTextField = contentTextField;
    [self addSubview:contentTextField];

    [contentTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(17);
        make.top.mas_equalTo(titleLabel.mas_bottom).mas_offset(12);
        make.height.mas_equalTo(44);
        make.width.mas_equalTo(350);
    }];

    // 选择菜单按钮
    UIButton *selectButton = [[UIButton alloc] init];
    selectButton.layer.cornerRadius = 2;
    selectButton.layer.masksToBounds = YES;
    selectButton.layer.borderColor = [UIColor colorWithHex:kDefaultBorderColor].CGColor;
    selectButton.layer.borderWidth = 1;
    selectButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    selectButton.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    selectButton.titleLabel.font = [UIFont systemFontOfSize:13];
    [selectButton setTitleColor:_define_black_color forState:UIControlStateNormal];
    self.selectButton = selectButton;
    [selectButton addTarget:self action:@selector(showPicker:) forControlEvents:UIControlEventTouchUpInside];
    UIImageView *selectImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"System_Triangle"]];
    [selectButton addSubview:selectImage];

    [selectImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(-10);
        make.centerY.equalTo(0);
        make.width.equalTo(10);
        make.height.equalTo(7);
    }];

    [self addSubview:selectButton];

    [selectButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(contentTextField.mas_right).offset(25);
        make.top.equalTo(contentTextField.mas_top);
        make.height.equalTo(contentTextField.mas_height);
        if([LanguageManager isEnglishLanguage]){
            make.width.equalTo(240);
        }else{
            make.width.equalTo(145);
        }
    }];


    selectButton.hidden = YES;

    // 警告框
    UIView *warnView = [UIView getCustomViewWithColor:_define_white_color];
    [self addSubview:warnView];
    self.warnView = warnView;
    [warnView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(0);
        make.left.mas_equalTo(selectButton.mas_right).with.offset(0);
        make.height.mas_equalTo(selectButton.mas_height);
        make.centerY.mas_equalTo(selectButton);
    }];

    UIImageView *warnImg=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"warn"]];
    [warnView addSubview:warnImg];
    [warnImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(warnView);
        make.left.mas_equalTo(9);
        make.height.width.mas_equalTo(15);
    }];

    UILabel *warnLabel = [UILabel getLabelWithAlignment:0 WithTitle:NSLocalizedString(@"",nil) WithFont:13.0f WithTextColor:[UIColor redColor] WithSpacing:0];
    self.warnLabel = warnLabel;
    [warnView addSubview:warnLabel];
    [warnLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(warnImg.mas_right).with.offset(4);
        make.centerY.mas_equalTo(warnView);
    }];

    warnView.hidden=YES;

}

#pragma mark - --------------系统代理----------------------
#pragma mark - UITextField
// 失去焦点
- (void)textFieldDidEndEditing:(UITextField *)textField{
    [self CheckLegal:self.checkType];
}



#pragma mark - --------------自定义代理/block----------------------
- (void)YYPickerController:(YYPickerViewController *)controller index:(NSInteger)index content:(NSString *)content{
    // block回调
    if (self.transmitPicker) {
        self.transmitPicker(index, self.indexPath);
    }

    [self.selectButton setTitle:content forState:UIControlStateNormal];
}

#pragma mark - --------------自定义响应----------------------
- (void)showPicker:(UIButton *)button{

    // 创建选择器
    YYPickerViewController *datePickerController = [[YYPickerViewController alloc] init];
    datePickerController.view.frame = self.bounds;
    datePickerController.delegate = self;

    // 设置默认值
    datePickerController.data = self.pickerData[1];//@[@"中国", @"美国", @"日本", @"澳大利亚", @"俄罗斯", @"冰岛",
                                                   //@"英国", @"加拿大", @"老挝", @"缅甸", @"巴基斯坦", @"印度",
                                                   //@"哈萨克斯坦", @"捷克", @"斯洛伐克", @"德国", @"意大利", @"埃及",
                                                   //@"新加坡", @"土耳其", @"南非", @"白尔罗斯", @"韩国", @"朝鲜"];

    [[self getController:self] presentViewController:datePickerController animated:NO completion:nil];
}

#pragma mark - --------------自定义方法----------------------
#pragma mark - get/set
// 标题
- (void)setTitle:(NSString *)title{
    _title = title;
    self.titleLabel.text = title;
    // 如果没有标题，就修改约束
    if ([NSString isNilOrEmpty:title]) {
        [self.contentTextField mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(17);
            make.top.mas_equalTo(self.titleLabel.mas_bottom).mas_offset(3);
            make.height.mas_equalTo(44);
            make.width.mas_equalTo(350);
        }];
    }
}

// 副标题
- (void)setSubTitle:(NSString *)subTitle{
    _subTitle = subTitle;
    self.subTitleLabel.text = subTitle;
}


// 输入框的提示
- (void)setInputPlaceholder:(NSString *)inputPlaceholder{
    _inputPlaceholder = inputPlaceholder;
    self.contentTextField.placeholder = inputPlaceholder;
}

// 输入框内容
- (void)setInputContent:(NSString *)inputContent{
    _inputContent = inputContent;
    self.contentTextField.text = inputContent;

    // 设置默认值
    if (self.transmitTextField) {
        self.transmitTextField(inputContent, self.indexPath, self);
    }
}

// 设置默认值
- (void)setPickerData:(NSArray *)pickerData{
    _pickerData = pickerData;
    NSInteger index = [pickerData[0] integerValue];
    NSArray *array = pickerData[1];
    [self.selectButton setTitle:array[index] forState:UIControlStateNormal];

    // 设置默认值
    if (self.transmitPicker) {
        self.transmitPicker(index, self.indexPath);
    }
}

// 设置picker按钮的可见性
- (void)setIsShowPicker:(BOOL)isShowPicker{
    _isShowPicker = isShowPicker;
    self.selectButton.hidden = !isShowPicker;

    if (!isShowPicker) {
        [self.warnView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(0);
            make.left.mas_equalTo(self.contentTextField.mas_right).with.offset(5);
            make.height.mas_equalTo(self.contentTextField.mas_height);
            make.centerY.mas_equalTo(self.contentTextField.mas_centerY);
        }];
    }else{
        [self.warnView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(0);
            make.left.mas_equalTo(self.selectButton.mas_right).with.offset(0);
            make.height.mas_equalTo(self.selectButton.mas_height);
            make.centerY.mas_equalTo(self.selectButton);
        }];
    }
}

// 文字是否是明文显示
- (void)setIsSecureTextEntry:(BOOL)isSecureTextEntry{
    _isSecureTextEntry = isSecureTextEntry;
    self.contentTextField.secureTextEntry = isSecureTextEntry;
}

- (void)setWarnContent:(NSString *)warnContent{
    _warnContent = warnContent;
    if ([NSString isNilOrEmpty:warnContent]) {
        self.warnView.hidden = YES;
    }else{
        self.warnView.hidden = NO;
        self.warnLabel.text = warnContent;
    }
}

#pragma mark - 检查
- (void)CheckLegal:(checkType)checkType{
    //邮箱
    if (checkType == kYYCheckTypeWithEmail) {
        if([NSString isNilOrEmpty:self.contentTextField.text]){
            //为空
            self.warnView.hidden=YES;

        }else{
            if([YYVerifyTool emailVerify:self.contentTextField.text]){
                self.warnView.hidden = YES;

            }else{
                self.warnLabel.text = NSLocalizedString(@"Email格式错误",nil);
                self.warnView.hidden = NO;

            }
        }
    }
}

#pragma mark - 监听textview变化
- (void)changeTextField{

    if (self.transmitTextField) {
        self.transmitTextField(self.contentTextField.text, self.indexPath, self);
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

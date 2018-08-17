//
//  YYCreateOrModifySellerViewContorller.m
//  Yunejian
//
//  Created by yyj on 15/7/17.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import "YYCreateOrModifySellerViewContorller.h"

#import "YYUserApi.h"
#import "YYShowroomApi.h"
#import "YYRspStatusAndMessage.h"
#import "YYUser.h"

#import "MLInputDodger.h"

#import "RegexKitLite.h"

@interface YYCreateOrModifySellerViewContorller ()<UITextFieldDelegate>

@property (nonatomic,assign) BOOL isShowroom;

@property (nonatomic, strong) UITextField *nameField;
@property (nonatomic, strong) UITextField *emailField;
@property (nonatomic, strong) UITextField *passwordField;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *tipLabel;
@property (nonatomic, strong) UILabel *emailLabel;

/** 黄色背景 */
@property (nonatomic, strong) UIView *yellowView;

@end

@implementation YYCreateOrModifySellerViewContorller


#pragma mark - --------------生命周期--------------
- (instancetype)init{

    if (self = [super init]) {
        // 设置显示模态父层控制器
        self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        // 设置淡入淡出的模态方式
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    }

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self SomePrepare];
}


#pragma mark - --------------SomePrepare--------------

-(void)SomePrepare
{
    [self PrepareData];
    [self PrepareUI];

    self.view.shiftHeightAsDodgeViewForMLInputDodger = 60.0f;
    [self.view registerAsDodgeViewForMLInputDodger];
    
}

-(void)PrepareData{
    YYUser *user = [YYUser currentUser];
    if(user.userType == 5){
        _isShowroom = YES;
    }else{
        _isShowroom = NO;
    }
}

#pragma mark - --------------UI----------------------

// 创建子控件
-(void)PrepareUI{

    // 乳白色的背景
    self.view.backgroundColor = [UIColor clearColor];
    // bg
    UIView *blackView = [[UIView alloc] init];
    blackView.backgroundColor = [UIColor colorWithHex:@"ffffff" alpha:0.6];
    [self.view addSubview:blackView];

    [blackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.bottom.mas_equalTo(0);
    }];


    // 黄颜色的背景
    UIView *yellowBackground = [[UIView alloc] init];
    yellowBackground.backgroundColor = [UIColor colorWithHex:@"FFE000"];
    self.yellowView = yellowBackground;
    [blackView addSubview:yellowBackground];

    [yellowBackground mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.centerY.mas_equalTo(0);
        make.width.mas_equalTo(500);
        make.height.mas_equalTo(514);
    }];

    // 黄色背景上的白色背景
    UIView *whiteBg = [[UIView alloc] init];
    whiteBg.backgroundColor = _define_white_color;
    [yellowBackground addSubview:whiteBg];

    [whiteBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(20);
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.bottom.mas_equalTo(-20);
    }];

    // 标题
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = NSLocalizedString(@"新建Showroom子账号", nil);
    titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [whiteBg addSubview:titleLabel];
    self.titleLabel = titleLabel;
    [titleLabel sizeToFit];

    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(yellowBackground.mas_centerX);
        make.top.mas_equalTo(35);
    }];

    // line
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = _define_black_color;
    [whiteBg addSubview:lineView];

    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(45);
        make.right.mas_equalTo(-45);
        make.top.mas_equalTo(90);
        make.height.mas_equalTo(1);
    }];

    // 姓名
    UILabel *nameLabel = [[UILabel alloc] init];
    nameLabel.text = NSLocalizedString(@"姓名*", nil);
    nameLabel.font = [UIFont systemFontOfSize:14];

    [whiteBg addSubview:nameLabel];

    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(lineView.mas_bottom).mas_offset(32);
        make.left.mas_equalTo(40);
        make.height.mas_equalTo(44);
        make.width.mas_equalTo(150);
    }];

    // email
    UILabel *emailLabel = [[UILabel alloc] init];
    emailLabel.font = [UIFont systemFontOfSize:14];
    emailLabel.text = NSLocalizedString(@"登录Email*",nil);
    self.emailLabel = emailLabel;

    [whiteBg addSubview:emailLabel];

    [emailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(nameLabel.mas_bottom).mas_offset(32);
        make.left.mas_equalTo(40);
        make.height.mas_equalTo(44);
        make.width.mas_equalTo(150);
    }];

    // 初始登录密码
    UILabel *passwordLabel = [[UILabel alloc] init];
    passwordLabel.text = NSLocalizedString(@"初始登录密码*",nil);
    passwordLabel.font = [UIFont systemFontOfSize:14];

    [whiteBg addSubview:passwordLabel];

    [passwordLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(emailLabel.mas_bottom).mas_offset(32);
        make.left.mas_equalTo(40);
        make.height.mas_equalTo(44);
        make.width.mas_equalTo(150);
    }];

    // 姓名输入框
    UITextField *nameField = [[UITextField alloc] init];
    setBorder(nameField);
    self.nameField = nameField;
    nameField.delegate = self;
    [whiteBg addSubview:nameField];

    [nameField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-45);
        make.height.mas_equalTo(44);
        make.width.mas_equalTo(205);
        make.top.mas_equalTo(lineView.mas_bottom).mas_offset(32);
    }];

    // email输入框
    UITextField *emailField = [[UITextField alloc] init];
    setBorder(emailField);
    self.emailField = emailField;
    emailField.delegate = self;
    [whiteBg addSubview:emailField];

    [emailField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-45);
        make.height.mas_equalTo(44);
        make.width.mas_equalTo(205);
        make.top.mas_equalTo(nameField.mas_bottom).mas_offset(32);
    }];

    // 密码输入框
    UITextField *passwordField = [[UITextField alloc] init];
    setBorder(passwordField);
    self.passwordField = passwordField;
    passwordField.delegate = self;
    [whiteBg addSubview:passwordField];

    [passwordField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-45);
        make.height.mas_equalTo(44);
        make.width.mas_equalTo(205);
        make.top.mas_equalTo(emailField.mas_bottom).mas_offset(32);
    }];

    // 提示
    UILabel *tipLabel = [[UILabel alloc] init];
    tipLabel.text = NSLocalizedString(@"新建后会向登录Email发送确认邮件",nil);
    tipLabel.font = [UIFont systemFontOfSize:11];
    self.tipLabel = tipLabel;

    [whiteBg addSubview:tipLabel];

    [tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(passwordLabel.mas_bottom).mas_offset(16);
        make.left.mas_equalTo(40);
        make.right.mas_equalTo(-40);
        make.height.mas_equalTo(44);
    }];

    // 新建按钮

    UIButton *saveButton = [[UIButton alloc] init];
    saveButton.backgroundColor = _define_black_color;
    [saveButton setTitle:NSLocalizedString(@"新建", nil) forState:UIControlStateNormal];
    [saveButton addTarget:self action:@selector(saveClicked:) forControlEvents:UIControlEventTouchUpInside];
    [whiteBg addSubview:saveButton];

    [saveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(whiteBg.mas_centerX);
        make.bottom.mas_equalTo(whiteBg.mas_bottom).mas_offset(-40);
        make.width.mas_equalTo(200);
        make.height.mas_equalTo(40);
    }];

    UIButton *cancelButton = [[UIButton alloc] init];
    [cancelButton setImage:[UIImage imageNamed:@"close_small"] forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelClicked:) forControlEvents:UIControlEventTouchUpInside];
    [whiteBg addSubview:cancelButton];

    [cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-10);
        make.top.mas_equalTo(10);
        make.width.mas_equalTo(44);
        make.height.mas_equalTo(44);
    }];


    _emailField.delegate = self;
    _passwordField.delegate = self;
    if(_isShowroom){
        _titleLabel.text = NSLocalizedString(@"新建Showroom子账号",nil);
        _tipLabel.text = NSLocalizedString(@"新建后会向登录Email发送确认邮件",nil);
        _emailLabel.text = NSLocalizedString(@"登录Email*",nil);
    }else{
        _titleLabel.text = NSLocalizedString(@"新建销售代表",nil);
        _tipLabel.text = NSLocalizedString(@"新建后会向销售代表发送确认邮件",nil);
        _emailLabel.text = @"Email*";
    }
}


#pragma mark - --------------系统代理----------------------
#pragma mark - textField
// 如果是最后一个，就显示done， 否则就是next
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    if (textField == self.passwordField) {
        textField.returnKeyType = UIReturnKeyDone;
    }else{
        textField.returnKeyType = UIReturnKeyNext;
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField  == self.nameField) {
        //点击换行 让下一个textField成为焦点 即passwordTextField成为焦点
        [self.emailField becomeFirstResponder];
    }else if (textField == self.emailField){
        [self.passwordField becomeFirstResponder];
    }else{
        [self.view endEditing:YES];
    }

    return YES;
}


#pragma mark - --------------自定义代理/block----------------------


#pragma mark - --------------自定义响应----------------------
- (void)cancelClicked:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
    if (_cancelButtonClicked) {
        _cancelButtonClicked();
    }
}

- (void)saveClicked:(UIButton *)sender{
    NSString *name = trimWhitespaceOfStr(self.nameField.text);
    NSString *email = trimWhitespaceOfStr(_emailField.text);
    NSString *password = trimWhitespaceOfStr(_passwordField.text);

    if (! name || [name length] == 0) {
        [YYToast showToastWithTitle:NSLocalizedString(@"请输入用户名",nil) andDuration:kAlertToastDuration];
        return;
    }

    if (! email || [email length] == 0) {
        [YYToast showToastWithTitle:NSLocalizedString(@"请输入email！",nil) andDuration:kAlertToastDuration];
        return;
    }

    BOOL isEmail = [email isMatchedByRegex:@"\\b([a-zA-Z0-9%_.+\\-]+)@([a-zA-Z0-9.\\-]+?\\.[a-zA-Z]{2,6})\\b"];
    if (!isEmail) {
        [YYToast showToastWithTitle:NSLocalizedString(@"email格式不对！",nil) andDuration:kAlertToastDuration];
        return;
    }

    if (! password || [password length] == 0) {
        [YYToast showToastWithTitle:NSLocalizedString(@"请输入初始密码！",nil) andDuration:kAlertToastDuration];
        return;
    }

    if(_isShowroom){
        // showroom
        [YYShowroomApi createSubShowroomWithUsername:name email:email password:password andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSNumber *userId, NSError *error) {
            if (rspStatusAndMessage.status == kCode100) {
                [YYToast showToastWithTitle:NSLocalizedString(@"创建成功！",nil) andDuration:kAlertToastDuration];
                // 退出
                [self dismissViewControllerAnimated:YES completion:nil];
                if (_modifySuccess) {
                    _modifySuccess(userId);
                }

            }else{
                [YYToast showToastWithTitle:rspStatusAndMessage.message andDuration:kAlertToastDuration];
            }
        }];
    }else{
        [YYUserApi createSellerWithUsername:name email:email password:password andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSError *error) {
            if (rspStatusAndMessage.status == kCode100) {
                [YYToast showToastWithTitle:NSLocalizedString(@"创建成功！",nil) andDuration:kAlertToastDuration];
                // 退出
                [self dismissViewControllerAnimated:YES completion:nil];
                if (_modifySuccess) {
                    // 创建销售代表不需要userid，所以传个空出去
                    _modifySuccess(@0);
                }
            }else{
                [YYToast showToastWithTitle:rspStatusAndMessage.message andDuration:kAlertToastDuration];
            }
        }];
    }
}

#pragma mark - --------------自定义方法----------------------

#pragma mark - --------------other----------------------

- (void)dealloc{
    [self.view endEditing:YES];
}

@end

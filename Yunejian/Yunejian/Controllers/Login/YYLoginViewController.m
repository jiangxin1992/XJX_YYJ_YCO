//
//  YYLoginViewController.m
//  Yunejian
//
//  Created by yyj on 15/7/5.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import "YYLoginViewController.h"

// 提交品牌信息
#import "YYBrandVerificatViewController.h"
// 设计师入驻申请
#import "YYDesignerRegisterViewController.h"

#import "AppDelegate.h"

#import "RegexKitLite.h"

#import "YYUser.h"
#import "ESSAAES.h"
#import "ESSABase64.h"
#import "YYUserApi.h"

#import "MBProgressHUD.h"
#import "YYUser.h"
#import "YYSubShowroomUserPowerModel.h"

#import "YYServerURLApi.h"
#import "YYShowroomApi.h"
#import "YYSelectRoleViewController.h"
#import "YYRspStatusAndMessage.h"
#import "YYUserModel.h"
#import "YYYellowPanelManage.h"
#import "YYForgetPasswordViewController.h"

static CGFloat animateDuration = 0.3;
static CGFloat viewMargin = 10;


@interface YYLoginViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UIGestureRecognizerDelegate>
//@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logoTopLayoutConstraint;
@property (weak, nonatomic) IBOutlet UIButton *changeLanguageButton;
@property (strong ,nonatomic) UILabel *changeLanguageLabel;

@property (weak, nonatomic) IBOutlet UIView *loginView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *loginViewTopLayoutConstraint;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIView *verificationCodeView;//验证码所在视图
@property (weak, nonatomic) IBOutlet UITextField *verificationCodeTextField;
@property (weak, nonatomic) IBOutlet UIButton *verificationCodeButton;

@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;
@property (weak, nonatomic) IBOutlet UIButton *forgetPasswordButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *loginButtonTopLayoutConstraint;

@property (nonatomic,assign) CGFloat logoTopLayoutConstantDefault;
@property (nonatomic,assign) CGFloat loginViewTopLayoutConstantDefault;

@property (nonatomic,assign) CGFloat keyBoardHeight;
@property (nonatomic,assign) CGFloat verificationCodeViewHeight;

@property (nonatomic,assign) BOOL verificationCodeViewShouldHidden;//验证码是否该隐藏

@property(nonatomic,strong)YYSelectRoleViewController *selectRoleViewController;
@property(nonatomic,strong)YYForgetPasswordViewController *forgetPasswordViewController;
@property(nonatomic,strong)UITableView *userTableView;//历史账号
@property(nonatomic,strong)NSMutableArray *usersList;
@property(nonatomic,strong)NSMutableArray *filterUsersList;
@end

@implementation YYLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self changeLanguageButtonUpdate];

    _verificationCodeViewShouldHidden = YES;
    _verificationCodeView.hidden = _verificationCodeViewShouldHidden;

    self.verificationCodeViewHeight = 50;//_verificationCodeView.frame.size.height;

    self.logoTopLayoutConstantDefault = self.loginButtonTopLayoutConstraint.constant;
    self.loginViewTopLayoutConstantDefault = self.loginViewTopLayoutConstraint.constant;

    UIGestureRecognizer *aGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tabPiece:)];
    aGesture.delegate = self;
    [self.view addGestureRecognizer:aGesture];



    [_verificationCodeButton addTarget:self action:@selector(verificationCodeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];

    [_loginButton addTarget:self action:@selector(loginButtonClicked:) forControlEvents:UIControlEventTouchUpInside];


    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    if(YYDEBUG){
        _usernameTextField.delegate = self;
        _userTableView = ({
            UITableView *tableView = [[UITableView alloc] initWithFrame:({
                CGRect frame = CGRectMake(CGRectGetMinX(self.usernameTextField.frame), CGRectGetMaxY(self.usernameTextField.frame), CGRectGetWidth(self.usernameTextField.frame), 150);
                frame;
            })];
            tableView.delegate = self;
            tableView.dataSource = self;
            tableView.hidden = YES;
            tableView.backgroundColor = [UIColor clearColor];
            tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            tableView;
        });
        [_usernameTextField.superview addSubview:_userTableView];

    }

    [self initLoginButtonIcon:_loginButton btnWidth:60];

}

#pragma mark - SomeAction
-(NSMutableAttributedString *)getTextAttributedString:(NSString *)targetStr replaceStrs:(NSArray *)replaceStrs replaceColors:(NSArray *)replaceColors{
    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString: targetStr];
    NSInteger index =0;
    for (NSString *replaceStr in replaceStrs) {
        NSRange range = [targetStr rangeOfString:replaceStr];
        if (range.location != NSNotFound) {
            [attributedStr addAttribute: NSForegroundColorAttributeName value: [UIColor colorWithHex:[replaceColors objectAtIndex:index]] range:range];
        }
        index++;
    }

    return attributedStr;
}
- (IBAction)changeLanguageAction:(id)sender {
    NSInteger index = (LanguageManager.currentLanguageIndex?0:1);
    [LanguageManager saveLanguageByIndex:index];
    [self reloadRootViewController];
}
-(void)changeLanguageButtonUpdate{
    if(!_changeLanguageLabel){
        _changeLanguageLabel = [UILabel getLabelWithAlignment:1 WithTitle:@"EN | 中文" WithFont:16.0f WithTextColor:[UIColor colorWithHex:@"ed6498"] WithSpacing:0];
        [_changeLanguageButton addSubview:_changeLanguageLabel];
        [_changeLanguageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(_changeLanguageButton);
        }];
    }
    if(LanguageManager.currentLanguageIndex == 0){
        _changeLanguageLabel.attributedText = [self getTextAttributedString:@"EN | 中文" replaceStrs:@[@"中文"] replaceColors:@[@"919191"]];
    }else if(LanguageManager.currentLanguageIndex == 1){
        _changeLanguageLabel.attributedText = [self getTextAttributedString:@"EN | 中文" replaceStrs:@[@"EN"] replaceColors:@[@"919191"]];
    }
}
- (void)reloadRootViewController
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate enterLoginPage];
}

-(void)initLoginButtonIcon:(UIButton *)button btnWidth:(NSInteger)btnWidth{
    NSString *btnStr = NSLocalizedString(@"登录",nil);
    NSString *normal_image_name = @"loginbtn_icon";
    NSString *highlighted_image_name = @"loginbtnhighlighted_icon";
    UIImage *btnImage = [UIImage imageNamed:normal_image_name];
    [button setImage:btnImage forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:highlighted_image_name] forState:UIControlStateHighlighted];
    [button setTitle:btnStr forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont systemFontOfSize:19]];
    CGSize txtSize= [btnStr sizeWithAttributes:@{NSFontAttributeName:button.titleLabel.font}];
    float imageWith = button.imageView.image.size.width;
    float imageHeight = button.imageView.image.size.height;
    float labelWidth = txtSize.width;
    float labelHeight = txtSize.height;
    CGFloat imageOffsetX = (imageWith + labelWidth) / 2 - imageWith / 2;
    CGFloat imageOffsetY = imageHeight / 2;
    button.imageEdgeInsets = UIEdgeInsetsMake(-imageOffsetY, imageOffsetX, imageOffsetY, -imageOffsetX);
    CGFloat labelOffsetX = (imageWith + labelWidth / 2) - (imageWith + labelWidth) / 2;
    CGFloat labelOffsetY = labelHeight / 2;
    button.titleEdgeInsets = UIEdgeInsetsMake(labelOffsetY+15, -labelOffsetX, -labelOffsetY, labelOffsetX);
    button.contentEdgeInsets = UIEdgeInsetsMake(10,-20,0,-20);
}



- (NSString *)trimWhitespaceOfStr:(NSString *)string{
    return [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (IBAction)verificationCodeButtonClicked:(id)sender{
    [self updateVerificationCode];
}

//更新验证码
- (void)updateVerificationCode{
    _verificationCodeButton.enabled = NO;

    WeakSelf(ws);

    [YYUserApi getCaptchaWithBlock:^(NSData *imageData, NSError *error) {
        ws.verificationCodeButton.enabled = YES;
        if (imageData) {
            if (!error
                && imageData
                && [imageData length] > 0) {
                UIImage *image = [UIImage imageWithData:imageData];
                [ws.verificationCodeButton setImage:image forState:UIControlStateNormal];
            }
        }else{
            [YYToast showToastWithTitle:NSLocalizedString(@"获取验证码失败",nil) andDuration:kAlertToastDuration];
        }
    }];

}

- (void)enterMainIndexPage{
    _usernameTextField.text = @"";
    _passwordTextField.text = @"";
    _verificationCodeTextField.text = @"";
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate enterMainIndexPage];
}


- (void)loginByEmail:(NSString *)email password:(NSString *)password verificationCode:(NSString *)verificationCode{
    if (![YYNetworkReachability connectedToNetwork]) {
        [YYToast showToastWithTitle:kNetworkIsOfflineTips andDuration:kAlertToastDuration];
        return;
    }
    WeakSelf(ws);

    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    verificationCode = verificationCode&&[verificationCode length]?verificationCode:nil;

    [YYUserApi loginWithUsername:email password:md5(password) verificationCode:verificationCode andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYUserModel *userModel, NSError *error) {

        //   NSLog(@"test login %@, %@",rspStatusAndMessage.status,rspStatusAndMessage.message);
        [MBProgressHUD hideAllHUDsForView:ws.view animated:YES];
        //rspStatusAndMessage.status = YYReqStatusCode305;
        if (rspStatusAndMessage.status == YYReqStatusCode406) {
            //需要输验证码
            [ws updateVerificationCode];
            _verificationCodeViewShouldHidden = NO;

            if (!_verificationCodeViewShouldHidden
                && _verificationCodeView.hidden) {
                _verificationCodeView.hidden = _verificationCodeViewShouldHidden;
                _loginButtonTopLayoutConstraint.constant += (viewMargin+_verificationCodeViewHeight);

                [UIView animateWithDuration:animateDuration animations:^{
                    [_loginButton layoutIfNeeded];
                    [_registerButton layoutIfNeeded];
                    [_forgetPasswordButton layoutIfNeeded];
                }];

                //[_weakSelf moveViewWhenKeyboardIsShow];


            }

        }else if (rspStatusAndMessage.status == YYReqStatusCode100 || rspStatusAndMessage.status == YYReqStatusCode1000){
            if([userModel.type integerValue]== YYUserTypeRetailer){
                [YYToast showToastWithTitle:NSLocalizedString(@"当前账户是买手店身份,不能登录",nil)  andDuration:kAlertToastDuration];
                return ;
            }
            YYUser *user = [YYUser currentUser];
            [user saveUserWithEmail:email username:userModel.name password:password userType:[userModel.type integerValue] userId:userModel.id logo:userModel.logo status:[userModel.authStatus stringValue] brandId:[[NSString alloc] initWithFormat:@"%ld",(long)[userModel.brandId integerValue]]];
            if(YYDEBUG){
                if(_usersList ==nil){
                    _usersList = [[NSMutableArray alloc] init];
                }

                BOOL isContains = YES;
                for (NSArray *curuser in _usersList) {
                    if([curuser[0] isEqualToString:user.email]){
                        isContains = NO;
                        break;
                    }
                }
                if(isContains)
                    [_usersList addObject:@[user.email,user.name,user.password]];
                //NSData *userArchiverData= [NSKeyedArchiver archivedDataWithRootObject:_usersList];
                BOOL iskeyedarchiver= [NSKeyedArchiver archiveRootObject:_usersList toFile:getUsersStorePath()];
                if(iskeyedarchiver){
                    NSLog(@"archive success ");
                }
            }

            // 获取subshowroom的权限列表, 首先是判断showroom子账号
            if (user.userType == YYUserTypeShowroomSub) {
                [YYShowroomApi selectSubShowroomPowerUserId:[NSNumber numberWithInteger:[user.userId integerValue]] andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSArray *powerArray, NSError *error) {
                    YYSubShowroomUserPowerModel *subShowroom = [YYSubShowroomUserPowerModel shareModel];
                    for (NSNumber *i in powerArray) {
                        if ([i intValue] == 1) {
                            subShowroom.isBrandAction = YES;
                        }
                    }

                }];
            }

            dispatch_async(dispatch_get_main_queue(), ^{
                NSDictionary *userInfo = @{ UserTypeChangeKey: userModel.type };
                [[NSNotificationCenter defaultCenter] postNotificationName:UserTypeChangeNotification object:nil userInfo:userInfo];
            });

            //进入首页
            [ws enterMainIndexPage];
            if([user.status integerValue] == YYReqStatusCode305){//rspStatusAndMessage.status == YYReqStatusCode1000 ||

                NSString *expireDate = getShowDateByFormatAndTimeInterval(@"yyyy/MM/dd HH:mm",userModel.expireDate);
                NSString *msg =[NSString stringWithFormat:NSLocalizedString(@"请在 %@ 前完成品牌验证，未验证的账号将被锁定|%@",nil),expireDate,expireDate];
                [[YYYellowPanelManage instance] showYellowUserCheckAlertPanel:@"Main" andIdentifier:@"YYUserCheckAlertViewController" title:NSLocalizedString(@"品牌验证",nil) msg:msg iconStr:@"identity_need_icon"  btnStr:NSLocalizedString(@"验证品牌信息",nil) align:NSTextAlignmentCenter closeBtn:YES funArray:nil andCallBack:^(NSArray *value) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kShowAccountNotification object:nil];
                }];
            }

            [LanguageManager setLanguageToServer];

        }else{
            [self tabPiece:nil];
            if(rspStatusAndMessage.status == YYReqStatusCode305){

                [self showYellowAlert:NSLocalizedString(@"品牌验证失败",nil) msg:NSLocalizedString(@"抱歉，您未通过品牌信息验证",nil) btn:NSLocalizedString(@"验证品牌信息",nil) align:NSTextAlignmentLeft needVerify:1 userModel:userModel iconStr:@"identity_refuse_icon"];
            }else if(rspStatusAndMessage.status == YYReqStatusCode301 || rspStatusAndMessage.status == YYReqStatusCode306){
                [self showYellowAlert:NSLocalizedString(@"品牌验证失败",nil) msg:NSLocalizedString(@"抱歉，您未通过品牌信息验证",nil) btn:NSLocalizedString(@"验证品牌信息",nil) align:NSTextAlignmentLeft needVerify:1 userModel:userModel iconStr:@"identity_refuse_icon"];
            }else if(rspStatusAndMessage.status == YYReqStatusCode300){
                [self showYellowAlert:NSLocalizedString(@"账号还在审核中",nil) msg:@"" btn:NSLocalizedString(@"我知道了",nil) align:NSTextAlignmentCenter needVerify:0 userModel:userModel iconStr:@"identity_check_icon"];
            }else if(rspStatusAndMessage.status ==YYReqStatusCode304){
                CMAlertView *alertView = [[CMAlertView alloc] initWithTitle:NSLocalizedString(@"您的邮箱还没有激活",nil) message:[NSString stringWithFormat:NSLocalizedString(@"我们已向邮箱 %@ 再次发送了确认邮件",nil),email] needwarn:NO delegate:nil cancelButtonTitle:NSLocalizedString(@"取消", nil) otherButtonTitles:@[[NSString stringWithFormat:@"%@|000000",NSLocalizedString(@"没收到，再发一封",nil)]]];
                //alertView.noLongerRemindKey = NoLongerRemindBrand;
                alertView.specialParentView = self.view;
                [alertView setAlertViewBlock:^(NSInteger selectedIndex){
                    if (selectedIndex == 1) {
                        [YYUserApi reSendMailConfirmMail:userModel.email andUserType:[userModel.type stringValue] andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSError *error) {
                            if(rspStatusAndMessage.status == YYReqStatusCode100){
                                [YYToast showToastWithTitle:NSLocalizedString(@"发送成功！",nil) andDuration:kAlertToastDuration];
                            }else{
                                [YYToast showToastWithTitle:rspStatusAndMessage.message andDuration:kAlertToastDuration];
                            }

                        }];
                    }}];
                [alertView show];

            }else{
                [YYToast showToastWithTitle:rspStatusAndMessage.message  andDuration:kAlertToastDuration];
                //重新获取验证码
                [ws updateVerificationCode];
            }
        }
    }];


}

- (void)loginButtonClicked:(id)sender{

    NSString *email = [self trimWhitespaceOfStr: _usernameTextField.text];
    NSString *password = [self trimWhitespaceOfStr:_passwordTextField.text];
    NSString *verificationCode = [self trimWhitespaceOfStr:_verificationCodeTextField.text];

    //设计师
    //[self loginByEmail:@"designer@yej.com"  password:@"123456" verificationCode:verificationCode];

    //买手店
    //[self loginByEmail:@"buyer@yej.com"  password:@"123456" verificationCode:verificationCode];

    //销售代表
    //[self loginByEmail:@"salesman@yej.com"  password:@"123456" verificationCode:verificationCode];

    if (! email || [email length] == 0) {

        [YYToast showToastWithTitle:NSLocalizedString(@"请输入邮箱！",nil) andDuration:kAlertToastDuration];
        return;
    }

    BOOL isEmail = [email isMatchedByRegex:@"\\b([a-zA-Z0-9%_.+\\-]+)@([a-zA-Z0-9.\\-]+?\\.[a-zA-Z]{2,6})\\b"];
    if (!isEmail) {
        [YYToast showToastWithTitle:NSLocalizedString(@"邮箱格式不对！",nil) andDuration:kAlertToastDuration];
        return;
    }

    if (! password || [password length] == 0) {
        [YYToast showToastWithTitle:NSLocalizedString(@"请输入密码！",nil) andDuration:kAlertToastDuration];
        return;
    }

    if (!_verificationCodeViewShouldHidden) {
        if (! verificationCode || [verificationCode length] == 0) {
            [YYToast showToastWithTitle:NSLocalizedString(@"请输入验证码！",nil) andDuration:kAlertToastDuration];
            return;
        }
    }
    NSString *localServerURL = nil;//[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL];
    if(YYDEBUG == 0 && localServerURL == nil){
        WeakSelf(ws);
        __block NSString *blockemail = email;
        __block NSString *blockpassword = password;
        __block NSString *blockverificationCode = verificationCode;

        if ([YYNetworkReachability connectedToNetwork]) {//&& (localServerVersin==nil || ![localServerVersin isEqualToString:kYYCurrentVersion])
            [YYServerURLApi getAppServerURLWidth:^(NSString *serverURL,BOOL isNeedUpdate, NSError *error) {
                if(serverURL != nil){
                    [[NSUserDefaults standardUserDefaults] setObject:serverURL forKey:kLastYYServerURL];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    [ws loginByEmail:blockemail  password:blockpassword verificationCode:blockverificationCode];
                }else{
                    [YYToast showToastWithTitle:kNetworkIsOfflineTips andDuration:kAlertToastDuration];
                }
            }];
        }else{
            [YYToast showToastWithTitle:kNetworkIsOfflineTips andDuration:kAlertToastDuration];
        }

    }else{
        [self loginByEmail:email  password:password verificationCode:verificationCode];
    }

    //[self loginByEmail:email  password:password verificationCode:verificationCode];
}

- (IBAction)registerButtonClicked:(id)sender{

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    YYSelectRoleViewController *selectRoleViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYSelectRoleViewController"];
    if (selectRoleViewController) {
        __weak UIView *_weakSelectRoleView = selectRoleViewController.view;
        self.selectRoleViewController = selectRoleViewController;
        WeakSelf(ws);
        __weak UIStoryboard *_weakStoryboard = storyboard;
        [selectRoleViewController setRoleButtonClicked:^(RoleButtonType buttonType){
            StrongSelf(ws)
            switch (buttonType) {
                case RoleButtonTypeDesigner:{

                    YYDesignerRegisterViewController *designerRegister = [[YYDesignerRegisterViewController alloc] init];
                    [self.navigationController pushViewController:designerRegister animated:YES]; removeFromSuperviewUseUseAnimateAndDeallocViewController(_weakSelectRoleView,strongSelf.selectRoleViewController);
                }
                    break;
                case RoleButtonTypeCancel:{
                    removeFromSuperviewUseUseAnimateAndDeallocViewController(_weakSelectRoleView,ws.selectRoleViewController);
                }
                    break;

                default:
                    break;
            }
        }];



        [self.view addSubview:_weakSelectRoleView];
        __weak UIView *_weakSelfView = self.view;
        [_weakSelectRoleView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_weakSelfView.mas_top);
            make.left.equalTo(_weakSelfView.mas_left);
            make.bottom.equalTo(_weakSelfView.mas_bottom);
            make.right.equalTo(_weakSelfView.mas_right);

        }];


        addAnimateWhenAddSubview(_weakSelectRoleView);

    }

}

- (IBAction)forgetPasswordButtonClicked:(id)sender{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    YYForgetPasswordViewController *forgetPasswordViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYForgetPasswordViewController"];
    forgetPasswordViewController.viewType = kForgetPasswordType;
    if (forgetPasswordViewController){
        __weak UIView *_forgetPasswordView= forgetPasswordViewController.view;
        self.forgetPasswordViewController = forgetPasswordViewController;
        WeakSelf(ws);
        [forgetPasswordViewController setCancelButtonClicked:^(){
            removeFromSuperviewUseUseAnimateAndDeallocViewController(_forgetPasswordView,ws.forgetPasswordViewController);
        }];



        [self.view addSubview:_forgetPasswordView];
        __weak UIView *_weakSelfView = self.view;
        __block NSInteger space = 28;
        [_forgetPasswordView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_weakSelfView.mas_top).offset(20+space);
            make.right.mas_equalTo(-space*2);
            make.bottom.equalTo(_weakSelfView.mas_bottom).offset(-space*2);
            // make.right.equalTo(_weakSelfView.mas_right).offset(space);
            make.width.mas_equalTo(514-space*2);
        }];
        [_forgetPasswordView layoutIfNeeded];
        //        [UIView animateWithDuration:0.5 animations:^{
        //            [_forgetPasswordView mas_updateConstraints:^(MASConstraintMaker *make) {
        //                make.right.mas_equalTo(-space*2);
        //            }];
        //            //必须调用此方法，才能出动画效果
        //            [_forgetPasswordView layoutIfNeeded];
        //            // update constraints now so we can animate the change
        //            [_forgetPasswordView updateConstraintsIfNeeded];
        //            [_forgetPasswordView updateConstraints];
        //
        //        }completion:^(BOOL finished) {
        //
        //        }];
        addAnimateWhenAddSubview(_forgetPasswordView);
    }
}
#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    // 输出点击的view的类名
    // NSLog(@"%@", NSStringFromClass([touch.view class]));

    // 若为UITableViewCellContentView（即点击了tableViewCell），则不截获Touch事件
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {
        return NO;
    }
    return  YES;
}

- (void)tabPiece:(UIPanGestureRecognizer *)gestureRecognizer
{
    if(YYDEBUG){
        CGPoint translatedPoint = [gestureRecognizer locationInView:self.view];
        CGPoint testPoint = [self.view convertPoint:translatedPoint toView:_userTableView];
        if([_userTableView pointInside:testPoint withEvent:nil]){
            return;
        }
    }
    if ([_usernameTextField isFirstResponder]) {
        [_usernameTextField resignFirstResponder];
    }

    if ([_passwordTextField isFirstResponder]) {
        [_passwordTextField resignFirstResponder];
    }

    if ([_verificationCodeTextField isFirstResponder]) {
        [_verificationCodeTextField resignFirstResponder];
    }
}

/*
 #pragma mark - Navigation

 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (void)moveViewWhenKeyboardIsShow{
    CGFloat viewOffset = 0;
    if (_verificationCodeViewShouldHidden) {
        viewOffset = _keyBoardHeight - (viewMargin+_verificationCodeViewHeight);
    }else{
        viewOffset = _keyBoardHeight;
    }

    //_logoTopLayoutConstraint.constant = _logoTopLayoutConstantDefault - viewOffset;

    _loginViewTopLayoutConstraint.constant = _loginViewTopLayoutConstantDefault - viewOffset + MAX(0, SCREEN_HEIGHT - 350 - _loginViewTopLayoutConstantDefault) + 60;
    //    WeakSelf(seakSelf);
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")){
        [UIView animateWithDuration:animateDuration animations:^{
            //[_logoImageView layoutIfNeeded];
            [_loginView layoutIfNeeded];
            //seakSelf.logoImageView.alpha = 0.0;
        }];
    }
}

#pragma mark - 键盘隐藏与消失

- (void)keyboardWillShow:(NSNotification *)note
{
    //获取键盘高度
    NSDictionary *info = [note userInfo];
    NSValue *value = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGSize keyboardSize = [value CGRectValue].size;

    if (SYSTEM_VERSION_LESS_THAN(@"8.0")){
        self.keyBoardHeight = keyboardSize.width;
    }else{
        self.keyBoardHeight = keyboardSize.height;
    }

    [self moveViewWhenKeyboardIsShow];
}

- (void)keyboardWillHide:(NSNotification *)note
{
    //_logoTopLayoutConstraint.constant = _logoTopLayoutConstantDefault;
    _loginViewTopLayoutConstraint.constant = _loginViewTopLayoutConstantDefault;
    //    WeakSelf(seakSelf);
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")){
        [UIView animateWithDuration:animateDuration animations:^{
            //[_logoImageView layoutIfNeeded];
            [_loginView layoutIfNeeded];
            //seakSelf.logoImageView.alpha = 1.0;
        }];
    }
}

#pragma 提示框
-(void)showYellowAlert:(NSString*)title msg:(NSString*)msg btn:(NSString*)btnStr align:(NSTextAlignment)textAlignment needVerify:(NSInteger)needVerify userModel:(YYUserModel *)userModel iconStr:(NSString *)iconStr{
    WeakSelf(ws);
    BOOL needCloseBtn = NO;
    if(needVerify == 2){
        needCloseBtn = YES;
    }
    __block NSInteger weakNeedVerify = needVerify;

    [[YYYellowPanelManage instance] showYellowUserCheckAlertPanel:@"Main" andIdentifier:@"YYUserCheckAlertViewController" title:title msg:msg iconStr:iconStr  btnStr:btnStr align:textAlignment closeBtn:needCloseBtn funArray:@[NSLocalizedString(@"1. 请在您的登录邮箱中查看验证结果邮件",nil),NSLocalizedString(@"2. 发邮件至info@ycosystem.com咨询或添加yunejianhelper微信号咨询",nil),NSLocalizedString(@"3. 再次验证品牌信息",nil)] andCallBack:^(NSArray *value) {

        //}];
        //[[YYYellowPanelManage instance] showYellowAlertPanel:@"Main" andIdentifier:@"YYAlertViewController" title:title msg:msg btn:btnStr align:textAlignment closeBtn:needCloseBtn andCallBack:^(NSArray *value) {
        if(weakNeedVerify == 1){


            // 替换register
            YYBrandVerificatViewController *brandVerificat = [[YYBrandVerificatViewController alloc] init];
            [self.navigationController pushViewController:brandVerificat animated:YES];

        }else if(weakNeedVerify == 2){
            // 已经不存在了
            [YYUserApi reSendMailConfirmMail:userModel.email andUserType:[userModel.type stringValue] andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSError *error) {
                if(rspStatusAndMessage.status == YYReqStatusCode100){
                    [YYToast showToastWithTitle:NSLocalizedString(@"发送成功！",nil) andDuration:kAlertToastDuration];
                }else{
                    [YYToast showToastWithTitle:rspStatusAndMessage.message andDuration:kAlertToastDuration];
                }

            }];
        }
    }];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{

    NSString *str = [textField.text stringByReplacingCharactersInRange:range withString:string];
    //    self.currentYYOrderInfoModel.buyerName = str;
    if(![str isEqualToString:@""]){
        //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.email CONTAINS %@",str];
        //_filterUsersList = [_usersList filteredArrayUsingPredicate:predicate];
        _usersList = [NSKeyedUnarchiver unarchiveObjectWithFile:getUsersStorePath()];
        _filterUsersList = [[NSMutableArray alloc] init];
        for (NSArray *user in _usersList) {
            NSString *emialTxt = [user objectAtIndex:0];
            NSRange range = [emialTxt rangeOfString:str];
            if(range.length > 0){
                [_filterUsersList addObject:user];
            }
            //ios7 不可用
            //            if(emialTxt && [emialTxt containsString:str]){
            //                [_filterUsersList addObject:user];
            //            }
        }
        if(_filterUsersList && [_filterUsersList count] > 0){
            _userTableView.hidden = NO;
            _userTableView.frame = CGRectMake(_userTableView.frame.origin.x, _userTableView.frame.origin.y, CGRectGetWidth(_userTableView.frame), ([_filterUsersList count]*30)) ;

        }
        [_userTableView reloadData];
        return YES;
    }
    _userTableView.hidden = YES;
    [_userTableView reloadData];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    if (textField.text
        && [textField.text length] > 0) {
        _userTableView.hidden = YES;
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return (_filterUsersList?[_filterUsersList count]:0);
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString* reuseIdentifier = @"usercelld";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
        //cell.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
        cell.backgroundColor = [UIColor colorWithWhite:1 alpha:0.8];
        cell.textLabel.textColor = [UIColor blackColor];
        cell.detailTextLabel.textColor = [UIColor blackColor];
    }

    NSArray *user = [_filterUsersList objectAtIndex:indexPath.row];
    cell.textLabel.text = user[0];
    cell.detailTextLabel.text = user[1];
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    return 30;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [_usernameTextField resignFirstResponder];
    NSArray *user = [_filterUsersList objectAtIndex:indexPath.row];
    _usernameTextField.text = user[0];
    _passwordTextField.text = user[2];
}
#pragma mark - Other
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self changeLanguageButtonUpdate];
    // 进入埋点
    [MobClick beginLogPageView:kYYPageLogin];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    // 退出埋点
    [MobClick endLogPageView:kYYPageLogin];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end

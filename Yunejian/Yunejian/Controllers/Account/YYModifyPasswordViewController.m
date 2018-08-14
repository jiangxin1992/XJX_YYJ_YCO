//
//  YYModifyPasswordViewController.m
//  Yunejian
//
//  Created by yyj on 15/7/14.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import "YYModifyPasswordViewController.h"

#import "YYUserApi.h"
#import "YYRspStatusAndMessage.h"

static CGFloat yellowView_default_constant = 140;

@interface YYModifyPasswordViewController ()<UITextFieldDelegate>


@property (weak, nonatomic) IBOutlet UITextField *oldPasswordField;
@property (weak, nonatomic) IBOutlet UITextField *nowPasswordField;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordField;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *yellowViewTopLayoutConstraint;
@property (weak, nonatomic) IBOutlet UIView *yellowView;

@end

@implementation YYModifyPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _oldPasswordField.delegate = self;
    _nowPasswordField.delegate = self;
    _confirmPasswordField.delegate = self;
    
    popWindowAddBgView(self.view);
    
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)cancelClicked:(id)sender{
    if (_cancelButtonClicked) {
        _cancelButtonClicked();
    }
}

- (IBAction)saveClicked:(id)sender{
    NSString *old = trimWhitespaceOfStr(_oldPasswordField.text);
    NSString *now = trimWhitespaceOfStr(_nowPasswordField.text);
    NSString *confirm = trimWhitespaceOfStr(_confirmPasswordField.text);
    
    if (! old || [old length] == 0) {

        [YYToast showToastWithTitle:NSLocalizedString(@"请输入原来的密码",nil) andDuration:kAlertToastDuration];
        return;
    }
    
    
    if (! now || [now length] == 0) {

        [YYToast showToastWithTitle:NSLocalizedString(@"请输入新密码！",nil) andDuration:kAlertToastDuration];
        return;
    }
    
    if (! confirm || [confirm length] == 0) {

        [YYToast showToastWithTitle:NSLocalizedString(@"请输入确认密码！",nil) andDuration:kAlertToastDuration];
        return;
    }
    
    if (![now isEqualToString:confirm]) {

        [YYToast showToastWithTitle:NSLocalizedString(@"新密码和确认密码不一致！",nil) andDuration:kAlertToastDuration];
        return;
    }
    
    [YYUserApi passwdUpdateWithOldPassword:md5(old) nowPassword:md5(now) andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSError *error) {
        if (rspStatusAndMessage.status == YYReqStatusCode100) {

            [YYToast showToastWithTitle:NSLocalizedString(@"密码修改成功！",nil) andDuration:kAlertToastDuration];
            if (_modifySuccess) {
                _modifySuccess();
            }
        }else{
            //[YYTopAlertView showWithType:YYTopAlertTypeError text:rspStatusAndMessage.message parentView:nil];

           [YYToast showToastWithTitle:rspStatusAndMessage.message andDuration:kAlertToastDuration];
        }
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

//
//  YYRegisterResultViewController.m
//  Yunejian
//
//  Created by Apple on 15/9/27.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import "YYRegisterResultViewController.h"
#import "YYUserApi.h"
#import "YYRspStatusAndMessage.h"

@interface YYRegisterResultViewController ()

@end

@implementation YYRegisterResultViewController

#pragma mark - 生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //self.view.backgroundColor = [UIColor whiteColor];
    [self updateUI];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    // 进入埋点
    [MobClick beginLogPageView:kYYPageRegisterResult];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    // 退出埋点
    [MobClick endLogPageView:kYYPageRegisterResult];
}

#pragma mark - 生命周期  end

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation

 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

-(void)updateUI{

    _view1.hidden = YES;
    _view2.hidden = YES;
    _view3.hidden = YES;
    if(_registerType == kDesignerType){
        _titleLabel.text = NSLocalizedString(@"设计师入驻申请",nil);
    }else if(_registerType == kBuyerStorUserType){
        _titleLabel.text = NSLocalizedString(@"买手店入驻申请",nil);
    }
    if (_status == 0) {
        _view1.hidden = NO;
        _tipLabel.text = [NSString stringWithFormat:NSLocalizedString(@"我们已经向邮箱%@发生了确认邮件，请查收",nil),_email];
    }else if (_status == 1){
        _view2.hidden = NO;
    }else if (_status == 2){
        _view3.hidden = NO;
    }
}

- (IBAction)lookEmailHandler:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"mailto://%@",_email]]];
}



- (IBAction)dismissHandler:(id)sender {
    //[self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)reSendEmailHandler:(id)sender {
    //用户类型0，desinger;1,buyer;2,salesman
    [YYUserApi reSendMailConfirmMail:_email andUserType:[NSString stringWithFormat:@"%ld",(long)_registerType] andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSError *error) {
        if(rspStatusAndMessage.status == kCode100){
            [YYToast showToastWithTitle:NSLocalizedString(@"发送成功！",nil) andDuration:kAlertToastDuration];
        }else{
            [YYToast showToastWithTitle:rspStatusAndMessage.message andDuration:kAlertToastDuration];
        }

    }];
}
@end

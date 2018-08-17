//
//  YYShareOrderViewController.m
//  Yunejian
//
//  Created by yyj on 15/8/28.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import "YYShareOrderViewController.h"

// c文件 —> 系统文件（c文件在前）

// 控制器

// 自定义视图

// 接口
#import "YYUserApi.h"

// 分类

// 自定义类和三方类（ cocoapods类 > model > 工具类 > 其他）
#import "YYOrderInfoModel.h"

#import "YYVerifyTool.h"

@interface YYShareOrderViewController ()

@property (weak, nonatomic) IBOutlet UITextField *emailText;

- (IBAction)sendEmailHandler:(id)sender;

@end

@implementation YYShareOrderViewController
#pragma mark - --------------生命周期--------------
- (void)viewDidLoad {
    [super viewDidLoad];
    popWindowAddBgView(self.view);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - --------------SomePrepare--------------
- (void)SomePrepare {
    [self PrepareData];
    [self PrepareUI];
}
- (void)PrepareData {

}
- (void)PrepareUI {

}

#pragma mark - --------------UIConfig----------------------
- (void)UIConfig {

}

#pragma mark - --------------请求数据----------------------
- (void)RequestData {

}

#pragma mark - --------------系统代理----------------------


#pragma mark - --------------自定义代理/block----------------------


#pragma mark - --------------自定义响应----------------------
- (IBAction)cancelClicked:(id)sender{
    if (_cancelButtonClicked) {
        _cancelButtonClicked();
    }
}

- (IBAction)sendEmailHandler:(id)sender {
    if([NSString isNilOrEmpty:_emailText.text] || ![YYVerifyTool emailVerify:_emailText.text]){
        [YYToast showToastWithTitle:NSLocalizedString(@"请输入正确邮箱",nil) andDuration:kAlertToastDuration];
        return;
    }
    WeakSelf(ws);
    NSString *noBlankValue = [_emailText.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [YYUserApi sendOrderByMail:noBlankValue andCode:_currentYYOrderInfoModel.orderCode andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSError *error) {
        if(rspStatusAndMessage.status == YYReqStatusCode100){
            ws.emailText.text = @"";
            [YYToast showToastWithTitle:NSLocalizedString(@"发送成功！",nil) andDuration:kAlertToastDuration];
            [ws cancelClicked:nil];
        }else{
            [YYToast showToastWithTitle:NSLocalizedString(@"发送失败！",nil) andDuration:kAlertToastDuration];
        }
    }];
}

#pragma mark - --------------自定义方法----------------------


#pragma mark - --------------other----------------------

@end

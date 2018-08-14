//
//  YYCreateOrModifyAddressViewController.m
//  Yunejian
//
//  Created by yyj on 15/7/20.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import "YYDeliverModifyAddressViewController.h"

// c文件 —> 系统文件（c文件在前）

// 控制器

// 自定义视图

// 接口

// 分类

// 自定义类和三方类（ cocoapods类 > model > 工具类 > 其他）
#import "YYDeliverModel.h"

#import "YYVerifyTool.h"

@interface YYDeliverModifyAddressViewController ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *phoneField;
@property (weak, nonatomic) IBOutlet UITextView *detailAddressField;

@end

@implementation YYDeliverModifyAddressViewController
#pragma mark - --------------生命周期--------------
- (void)viewDidLoad {
    [super viewDidLoad];
    [self SomePrepare];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
#pragma mark - --------------SomePrepare--------------
-(void)SomePrepare
{
    [self PrepareData];
    [self PrepareUI];
}
-(void)PrepareData{}
-(void)PrepareUI{

    _nameField.layer.borderWidth = 1;
    _nameField.layer.borderColor = [[UIColor colorWithHex:@"EFEFEF"] CGColor];
    _nameField.layer.cornerRadius = 3.0f;

    _phoneField.layer.borderWidth = 1;
    _phoneField.layer.borderColor = [[UIColor colorWithHex:@"EFEFEF"] CGColor];
    _phoneField.layer.cornerRadius = 3.0f;

    _detailAddressField.layer.borderWidth = 1;
    _detailAddressField.layer.borderColor = [[UIColor colorWithHex:@"EFEFEF"] CGColor];
    _detailAddressField.layer.cornerRadius = 3.0f;

    _phoneField.keyboardType = UIKeyboardTypeNumberPad;

    popWindowAddBgView(self.view);

    _titleLabel.text = NSLocalizedString(@"修改收件地址",nil);
    _nameField.text = _deliverModel.receiver;
    _phoneField.text = _deliverModel.receiverPhone;
    _detailAddressField.text = _deliverModel.receiverAddress;
}

//#pragma mark - --------------UIConfig----------------------
//- (void)UIConfig {
//
//}
//
//#pragma mark - --------------请求数据----------------------
//- (void)RequestData {
//
//}
//
//#pragma mark - --------------系统代理----------------------
//
//
//#pragma mark - --------------自定义代理/block----------------------

#pragma mark - --------------自定义响应----------------------
- (IBAction)cancelClicked:(id)sender{
    if (_cancelButtonClicked) {
        _cancelButtonClicked();
    }
}
- (IBAction)saveClicked:(id)sender{

    NSString *receiveName = trimWhitespaceOfStr(_nameField.text);
    NSString *receivePhone = trimWhitespaceOfStr(_phoneField.text);
    NSString *detailAddress = trimWhitespaceOfStr(_detailAddressField.text);

    if ([NSString isNilOrEmpty:receiveName]) {
        [YYToast showToastWithView:self.view title:NSLocalizedString(@"请输入收件人姓名",nil) andDuration:kAlertToastDuration];
        return;
    }

    if ([NSString isNilOrEmpty:detailAddress]) {
        [YYToast showToastWithView:self.view title:NSLocalizedString(@"请输入详细地址",nil) andDuration:kAlertToastDuration];
        return;
    }

    BOOL isValidPhone = [YYVerifyTool internationalPhoneVerify:receivePhone];
    if(!isValidPhone){
        [YYToast showToastWithView:self.view title:NSLocalizedString(@"手机号码格式错误",nil) andDuration:kAlertToastDuration];
        return;
    }

    //做保存应该做的事
    _deliverModel.receiver = receiveName;
    _deliverModel.receiverAddress = detailAddress;
    _deliverModel.receiverPhone = receivePhone;

    if(_modifySuccess){
        _modifySuccess();
    }
}

#pragma mark - --------------自定义方法----------------------


#pragma mark - --------------other----------------------

@end

//
//  YYFeedbackViewController.m
//  Yunejian
//
//  Created by yyj on 15/7/21.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import "YYFeedbackViewController.h"

#import "YYRspStatusAndMessage.h"
#import "YYUserApi.h"

@interface YYFeedbackViewController ()

@property (weak, nonatomic) IBOutlet UITextView *feedbackTextView;
@property (weak, nonatomic) IBOutlet UIView *bgView;

@end

@implementation YYFeedbackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _bgView.layer.borderColor = [UIColor blackColor].CGColor;
    _bgView.layer.borderWidth = 1;
    popWindowAddBgView(self.view);
    [_feedbackTextView becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancelClicked:(id)sender{
    if (_cancelButtonClicked) {
        _cancelButtonClicked();
    }
}

- (IBAction)saveClicked:(id)sender{
    
   NSString *feedbackString = trimWhitespaceOfStr(_feedbackTextView.text);
    
    if (! feedbackString || [feedbackString length] == 0) {
        [YYToast showToastWithTitle:NSLocalizedString(@"请输入您的反馈内容",nil) andDuration:kAlertToastDuration];
        return;
    }
    
    [YYUserApi userFeedBack:feedbackString andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSError *error) {
        if (rspStatusAndMessage.status == YYReqStatusCode100) {
            [YYToast showToastWithTitle:NSLocalizedString(@"反馈成功!",nil) andDuration:kAlertToastDuration];
            if (_modifySuccess) {
                _modifySuccess();
            }
        }else{
            [YYToast showToastWithTitle:rspStatusAndMessage.message andDuration:kAlertToastDuration];
        }
    }];
    
    
}

@end

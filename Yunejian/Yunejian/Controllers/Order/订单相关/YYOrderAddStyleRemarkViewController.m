//
//  YYOrderAddStyleRemarkViewController.m
//  Yunejian
//
//  Created by Apple on 16/8/8.
//  Copyright © 2016年 yyj. All rights reserved.
//

#import "YYOrderAddStyleRemarkViewController.h"
#import "MLInputDodger.h"

@interface YYOrderAddStyleRemarkViewController ()<UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextView *textInput;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UIButton *saveBtn;
@property (weak, nonatomic) IBOutlet UILabel *remarkTipLabel;
@property (weak, nonatomic) IBOutlet UIView *backView;
@property (assign, nonatomic) NSInteger maxLength;
@end

@implementation YYOrderAddStyleRemarkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFiledEditChanged:)
                                                name:@"UITextViewTextDidChangeNotification"
                                              object:_textInput];
    _textInput.delegate = self;
    self.maxLength = 250;
    self.cancelBtn.layer.borderWidth = 1;
    self.cancelBtn.layer.borderColor = [UIColor blackColor].CGColor;
    if(![NSString isNilOrEmpty:_orderStyleModel.remark]){
        _textInput.text = _orderStyleModel.remark;
        _remarkTipLabel.hidden = YES;
    }
}

#pragma mark - UITextViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView{
//    if (self.textViewIsEditCallback) {
//        self.textViewIsEditCallback(YES);
//    }
    _remarkTipLabel.hidden = YES;
}
- (void)textViewDidEndEditing:(UITextView *)textView{
//    if (self.textViewIsEditCallback) {
//        self.textViewIsEditCallback(NO);
//    }
    
    if (textView.text
        && [textView.text length] > 0) {
        //_currentYYOrderInfoModel.orderDescription = textView.text;
    }else{
        _remarkTipLabel.hidden = NO;
    }
    
}

-(void)textFiledEditChanged:(NSNotification *)obj{
    NSString *toBeString = _textInput.text;
    NSString *lang = [[UIApplication sharedApplication] textInputMode].primaryLanguage; // 键盘输入模式
    if ([lang isEqualToString:@"zh-Hans"]) { // 简体中文输入，包括简体拼音，健体五笔，简体手写
        UITextRange *selectedRange = [_textInput markedTextRange];
        //高亮部分
        UITextPosition *position = [_textInput positionFromPosition:selectedRange.start offset:0];
        //已输入的文字进行字数统计和限制
        if (!position) {
            if (toBeString.length > self.maxLength) {
                _textInput.text = [toBeString substringToIndex:self.maxLength];
                //                AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                //                [YYToast showToastWithView:appDelegate.mainViewController.view title:[NSString stringWithFormat:@"文字字数最多%ld字",(long)self.maxLength] andDuration:kAlertToastDuration];
            }
            
        }
    }
    else{
        if (toBeString.length > self.maxLength) {
            _textInput.text = [toBeString substringToIndex:self.maxLength];
            //            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            //            [YYToast showToastWithView:appDelegate.mainViewController.view title:[NSString stringWithFormat:@"文字字数最多%ld字",(long)self.maxLength] andDuration:kAlertToastDuration];
        }
    }
    
}
#pragma mark - SomeAction
- (IBAction)cancelBtnHandler:(id)sender {
    if(self.cancelButtonClicked){
        self.cancelButtonClicked();
    }
}
- (IBAction)saveBtnHandler:(id)sender {
    if(![NSString isNilOrEmpty:_textInput.text]){
        _orderStyleModel.remark = _textInput.text;
        if(self.modifySuccess){
            self.modifySuccess();
        }
    }
}
#pragma mark - Other
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.backView.shiftHeightAsDodgeViewForMLInputDodger = 200;
    [self.backView registerAsDodgeViewForMLInputDodger];
}
-(void)viewWillAppear:(BOOL)animated{
    if(![NSString isNilOrEmpty:_orderStyleModel.remark]){
        _textInput.text = _orderStyleModel.remark;
        _remarkTipLabel.hidden = YES;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UITextViewTextDidChangeNotification" object:_textInput];
}
@end

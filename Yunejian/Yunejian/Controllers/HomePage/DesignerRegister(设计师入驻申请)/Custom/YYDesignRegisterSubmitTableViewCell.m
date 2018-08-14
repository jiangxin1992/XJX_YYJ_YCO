//
//  YYDesignRegisterSubmitTableViewCell.m
//  Yunejian
//
//  Created by chuanjun sun on 2017/8/25.
//  Copyright © 2017年 yyj. All rights reserved.
//

#import "YYDesignRegisterSubmitTableViewCell.h"

// c文件 —> 系统文件（c文件在前）

// 控制器
#import "YYProtocolViewController.h"

// 自定义视图


// 接口


// 分类


// 自定义类和三方类（cocoapods类、model、工具类等） cocoapods类 —> model —> 其他

@interface YYDesignRegisterSubmitTableViewCell()<UITextViewDelegate>

/** 同意条款的按钮 */
@property (nonatomic, strong) UIButton *agreeButton;

/** 弹出条款 */
@property (nonatomic, strong) YYProtocolViewController *protocolViewController;

@end

@implementation YYDesignRegisterSubmitTableViewCell

#pragma mark - --------------生命周期--------------
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{

    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        [self somePrepare];
    }

    return self;
}

#pragma mark - --------------SomePrepare--------------
- (void)somePrepare{

    [self PrepareData];
    [self PrepareUI];

}
- (void)PrepareData{
    
}

#pragma mark - --------------UI----------------------
// 创建子控件
- (void)PrepareUI{
    // 是否同意按钮，默认同意
    UIButton *agreeButton = [UIButton getCustomBackImgBtnWithImageStr:@"selectCircle" WithSelectedImageStr:@"selectedCircle"];
    agreeButton.selected = YES;
    [agreeButton addTarget:self action:@selector(agreeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    self.agreeButton = agreeButton;
    [self addSubview:agreeButton];

    [agreeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(17);
        make.top.mas_equalTo(50);
        make.width.mas_equalTo(17);
        make.height.mas_equalTo(17);
    }];

    // 条款，拼接
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"已同意服务协议和隐私协议",nil)];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15] range:[[attributedString string] rangeOfString:[attributedString string]]];
    [attributedString addAttribute:NSLinkAttributeName
                             value:@"type://serviceAgreement"
                             range:[[attributedString string] rangeOfString:NSLocalizedString(@"服务协议",nil)]];
    [attributedString addAttribute:NSLinkAttributeName
                             value:@"type://secrecyAgreement"
                             range:[[attributedString string] rangeOfString:NSLocalizedString(@"隐私协议",nil)]];

    NSDictionary *linkAttributes = @{NSForegroundColorAttributeName: [UIColor colorWithHex:@"47a3dc"],
                                     NSUnderlineColorAttributeName: [UIColor lightGrayColor],
                                     NSUnderlineStyleAttributeName: @(NSUnderlinePatternSolid)};

    // assume that textView is a UITextView previously created (either by code or Interface Builder)
    UITextView *ruleTextView = [[UITextView alloc] init];
    ruleTextView.linkTextAttributes = linkAttributes; // customizes the appearance of links
    ruleTextView.attributedText = attributedString;
    ruleTextView.editable = NO;
    ruleTextView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    ruleTextView.font = [UIFont systemFontOfSize:15];
    ruleTextView.delegate = self;

    [self addSubview:ruleTextView];

    [ruleTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(agreeButton.mas_right).mas_offset(15);
        make.centerY.mas_equalTo(agreeButton.mas_centerY).mas_offset(-5);
        make.height.mas_equalTo(25);
        make.width.mas_equalTo(self.mas_width);
    }];

    UIButton *submitButton = [[UIButton alloc] init];
    [submitButton addTarget:self action:@selector(submitButtonClick) forControlEvents:UIControlEventTouchUpInside];
    submitButton.backgroundColor = _define_black_color;
    [submitButton setTitle:NSLocalizedString(@"提交申请", nil) forState:UIControlStateNormal];
    submitButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [self addSubview:submitButton];

    [submitButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(17);
        make.top.mas_equalTo(ruleTextView.mas_bottom).mas_offset(50);
        make.height.mas_equalTo(45);
        make.width.mas_equalTo(130);
    }];
}

#pragma mark - --------------系统代理----------------------
- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {

    if ([[URL scheme] isEqualToString:@"type"]) {
        NSString *type = [URL host];
        NSString *title;
        if([type isEqualToString:@"serviceAgreement"]){
            title = NSLocalizedString(@"服务协议",nil);
        }else if([type isEqualToString:@"secrecyAgreement"]){
            title = NSLocalizedString(@"隐私协议",nil);
        }

        [self showProtocolView:title protocolType:type];

        return NO;
    }

    return YES;
}

#pragma mark - --------------自定义代理/block----------------------


#pragma mark - --------------自定义响应----------------------
- (void)agreeButtonClick:(UIButton *)button{
    button.selected = !button.selected;

}

// 提交
- (void)submitButtonClick{
    if (self.submitQuestion) {
        self.submitQuestion(self.agreeButton.isSelected);
    }
}

#pragma mark - --------------自定义方法----------------------


#pragma mark - --------------other----------------------
-(void)showProtocolView:(NSString *)nowTitle protocolType:(NSString*)protocolType{

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Account" bundle:[NSBundle mainBundle]];
    YYProtocolViewController *protocolViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYProtocolViewController"];
    protocolViewController.nowTitle = nowTitle;
    protocolViewController.protocolType = protocolType;
    _protocolViewController = protocolViewController;

    UIView *superView = [self getController:self].view;

    __weak UIView *weakSuperView = superView;
    UIView *showView = _protocolViewController.view;
    __weak UIView *weakShowView = showView;
    __block YYProtocolViewController *tempCTN = _protocolViewController;
    [_protocolViewController setCancelButtonClicked:^(){
        removeFromSuperviewUseUseAnimateAndDeallocViewController(weakShowView,tempCTN);
    }];
    [superView addSubview:showView];

    [showView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(SCREEN_HEIGHT);
        make.left.equalTo(weakSuperView.mas_left);
        make.bottom.mas_equalTo(SCREEN_HEIGHT);
        make.width.mas_equalTo(SCREEN_WIDTH);
    }];
    [showView.superview layoutIfNeeded];

    [UIView animateWithDuration:kAddSubviewAnimateDuration animations:^{
        [weakShowView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(20);
        }];
        //必须调用此方法，才能出动画效果
        [weakShowView.superview layoutIfNeeded];
    }completion:^(BOOL finished) {
    }];

}

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

//
//  YYShareSeriesView.m
//  Yunejian
//
//  Created by yyj on 2017/4/17.
//  Copyright © 2017年 yyj. All rights reserved.
//

#import "YYShareSeriesView.h"

#import "YYVerifyTool.h"
#import "regular.h"

@interface YYShareSeriesView()<UITextFieldDelegate>

@property (nonatomic,strong) NSMutableArray *contactArr;

@end

@implementation YYShareSeriesView

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        _contactArr = [[NSMutableArray alloc] init];
        self.userInteractionEnabled = YES;
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyborad)]];
        
        UIView *yellowBackView = [UIView getCustomViewWithColor:[UIColor colorWithHex:@"ffe000"]];
        [self addSubview:yellowBackView];
        [yellowBackView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(self);
            make.width.mas_equalTo(500);
            make.height.mas_equalTo(548);
        }];
        
        UIView *mainBackView = [UIView getCustomViewWithColor:_define_white_color];
        [yellowBackView addSubview:mainBackView];
        [mainBackView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.mas_equalTo(20);
            make.bottom.right.mas_equalTo(-20);
        }];
        
        UIButton *closeBtn = [UIButton getCustomImgBtnWithImageStr:@"close" WithSelectedImageStr:nil];
        [mainBackView addSubview:closeBtn];
        [closeBtn addTarget:self action:@selector(closeAction) forControlEvents:UIControlEventTouchUpInside];
        [closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.right.mas_equalTo(0);
            make.width.height.mas_equalTo(50);
        }];
        
        UILabel *titleLabel = [UILabel getLabelWithAlignment:1 WithTitle:NSLocalizedString(@"分享系列",nil) WithFont:17.0f WithTextColor:nil WithSpacing:0];
        [mainBackView addSubview:titleLabel];
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(mainBackView);
            make.top.mas_equalTo(38);
        }];
        
        UILabel *emailTitle = [UILabel getLabelWithAlignment:0 WithTitle:@"Email" WithFont:14.0f WithTextColor:nil WithSpacing:0];
        [mainBackView addSubview:emailTitle];
        [emailTitle mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(90);
            make.left.mas_equalTo(41);
        }];
        
        _emailTextField = [[UITextField alloc] init];
        [mainBackView addSubview:_emailTextField];
        [_emailTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(42);
            make.top.mas_equalTo(emailTitle.mas_bottom).with.offset(10);
            make.right.mas_equalTo(-42);
            make.height.mas_equalTo(40);
        }];
        _emailTextField.font = getFont(14.0f);
        _emailTextField.textColor = _define_black_color;
        _emailTextField.returnKeyType = UIReturnKeySend;
        _emailTextField.delegate = self;
        _emailTextField.layer.masksToBounds = YES;
        _emailTextField.layer.borderWidth = 1;
        _emailTextField.layer.borderColor = [[UIColor colorWithHex:@"d3d3d3"] CGColor];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFiledWillHide:) name:UITextFieldTextDidEndEditingNotification object:_emailTextField];
        
         [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFiledBeginEditing:) name:UITextFieldTextDidBeginEditingNotification object:_emailTextField];
        
        _emailTipButton = [UIButton getCustomTitleBtnWithAlignment:1 WithFont:12.0f WithSpacing:0 WithNormalTitle:[[NSString alloc] initWithFormat:@"  %@",NSLocalizedString(@"邮箱格式不对！",nil)] WithNormalColor:[UIColor colorWithHex:@"ef4e31"] WithSelectedTitle:nil WithSelectedColor:nil];
        [mainBackView addSubview:_emailTipButton];
        [_emailTipButton setImage:[UIImage imageNamed:@"warn"] forState:UIControlStateNormal];
        [_emailTipButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(42);
            make.top.mas_equalTo(_emailTextField.mas_bottom).with.offset(0);
            make.height.mas_equalTo(22);
            make.width.mas_equalTo(200);
        }];
        _emailTipButton.hidden = YES;
        
        UILabel *tipLabel = [UILabel getLabelWithAlignment:0 WithTitle:NSLocalizedString(@"商务联系方式将与系列款式、款式大片一起分享给对方。",nil) WithFont:13.0f WithTextColor:[UIColor colorWithHex:@"919191"] WithSpacing:0];
        [mainBackView addSubview:tipLabel];
        [tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(41);
            make.right.mas_equalTo(-41);
            make.top.mas_equalTo(_emailTipButton.mas_bottom).with.offset(0);
        }];
        tipLabel.numberOfLines = 2;
        
        UIView *contactView = [UIView getCustomViewWithColor:[UIColor colorWithHex:@"f8f8f8"]];
        [mainBackView addSubview:contactView];
        [contactView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(42);
            make.right.mas_equalTo(-42);
            make.top.mas_equalTo(tipLabel.mas_bottom).with.offset(8);
            make.height.mas_equalTo(204);
        }];
        
        UILabel *contactTitle = [UILabel getLabelWithAlignment:0 WithTitle:NSLocalizedString(@"商务联系方式",nil) WithFont:14.0f WithTextColor:nil WithSpacing:0];
        [contactView addSubview:contactTitle];
        [contactTitle mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(11);
            make.top.mas_equalTo(11);
            make.height.mas_equalTo(16);
        }];
       
        
        UIButton *editButton = [UIButton getCustomTitleBtnWithAlignment:1 WithFont:14.0f WithSpacing:0 WithNormalTitle:[[NSString alloc] initWithFormat:@"  %@",NSLocalizedString(@"编辑",nil)] WithNormalColor:nil WithSelectedTitle:nil WithSelectedColor:nil];
        [contactView addSubview:editButton];
        [editButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(contactTitle);
            make.right.mas_equalTo(0);
            make.width.mas_equalTo(65);
            make.height.mas_equalTo(20);
        }];
        [editButton setImage:[UIImage imageNamed:@"edit_black"] forState:UIControlStateNormal];
        [editButton addTarget:self action:@selector(editAction) forControlEvents:UIControlEventTouchUpInside];
        
        CGFloat jiangge = (204-15*5-16-11)/6.0f;
        UIView *lastView = nil;
        for (int i=0; i<5; i++) {

            NSString *imageStr = i==0?@"email_icon2":i==1?@"phone_icon1":i==2?@"mobile_icon":i==3?@"weixin_icon1":@"qq_icon1";
            
            UILabel *label = [UILabel getLabelWithAlignment:0 WithTitle:nil WithFont:12.0f WithTextColor:nil WithSpacing:0];
            [contactView addSubview:label];
            [label mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(43);
                make.height.mas_equalTo(15);
                if(!lastView){
                    make.top.mas_equalTo(contactTitle.mas_bottom).with.offset(jiangge);
                }else{
                    make.top.mas_equalTo(lastView.mas_bottom).with.offset(jiangge);
                }
                make.right.mas_equalTo(-43);
            }];
            
            UIImageView *iconImg = [UIImageView getImgWithImageStr:imageStr];
            [contactView addSubview:iconImg];
            [iconImg mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.mas_equalTo(label);
                make.left.mas_equalTo(14);
                make.width.height.mas_equalTo(20);
            }];
            
            [_contactArr addObject:label];
            lastView = label;
        }
        
        UIButton *sendButton = [UIButton getCustomTitleBtnWithAlignment:0 WithFont:15.0f WithSpacing:0 WithNormalTitle:NSLocalizedString(@"确认发送",nil) WithNormalColor:_define_white_color WithSelectedTitle:nil WithSelectedColor:nil];
        [mainBackView addSubview:sendButton];
        [sendButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(-35);
            make.centerX.mas_equalTo(mainBackView);
            make.width.mas_equalTo(200);
            make.height.mas_equalTo(40);
        }];
        sendButton.backgroundColor = _define_black_color;
        [sendButton addTarget:self action:@selector(sendAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}
-(void)setHomePageModel:(YYUserHomePageModel *)homePageModel{
    _homePageModel = homePageModel;
    
    //0 邮箱, 4 固定电话 1 电话, 3 微信号, 2 QQ,
//    NSInteger idx=contactType==0?0:contactType==1?2:contactType==2?3:contactType==3?4:contactType==4?2:-1;
    BOOL _haveVaule = NO;
    if(_homePageModel.userContactInfos){
        if(_homePageModel.userContactInfos.count){
            _haveVaule = YES;
        }
    }
    
    if(_contactArr){
        if(_contactArr.count){
            for (int i=0; i<_contactArr.count; i++) {
                UILabel *label = _contactArr[i];
                label.textColor = [UIColor colorWithHex:@"919191"];
                label.text = NSLocalizedString(@"暂无",nil);
            }
        }
    }
    
    if(_haveVaule){
        for (int i=0; i<_homePageModel.userContactInfos.count; i++) {
            NSDictionary *obj = [_homePageModel.userContactInfos objectAtIndex:i];
            if(![self isNilOrEmptyWithContactValue:[obj objectForKey:@"contactValue"] WithContactType:[obj objectForKey:@"contactType"]]){
                NSInteger number = [[obj objectForKey:@"contactType"] integerValue];
                NSInteger index = number==0?0:number==4?1:number==1?2:number==3?3:number==2?4:-1;
                if(index>=0&&index<_contactArr.count){
                    UILabel *label = [_contactArr objectAtIndex:index];
                    label.textColor = _define_black_color;
                    label.text = [obj objectForKey:@"contactValue"];
                }
            }
        }
    }
    
}
#pragma mark - SomeAction
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    [self sendAction];
    return YES;
}
-(void)textFiledWillHide:(NSNotification *)obj{
    if([NSString isNilOrEmpty:_emailTextField.text]){
        _emailTipButton.hidden = YES;
    }else{
        if([YYVerifyTool emailVerify:_emailTextField.text]){
            _emailTipButton.hidden = YES;
        }else{
            _emailTipButton.hidden = NO;
            [_emailTipButton setTitle:[[NSString alloc] initWithFormat:@"  %@",NSLocalizedString(@"邮箱格式不对！",nil)] forState:UIControlStateNormal];
        }
    }
}

-(void)textFiledBeginEditing:(NSNotification *)obj{
    _emailTipButton.hidden = YES;
}

-(void)closeAction{
    //关闭
    if(_blockHide){
        _emailTextField.text = @"";
        _emailTipButton.hidden = YES;
        _blockHide();
    }
}
-(void)sendAction{
    if([NSString isNilOrEmpty:_emailTextField.text]){
        //空
        _emailTipButton.hidden = NO;
        [_emailTipButton setTitle:[[NSString alloc] initWithFormat:@"  %@",NSLocalizedString(@"请输入邮箱！",nil)] forState:UIControlStateNormal];
    }else{
        if([YYVerifyTool emailVerify:_emailTextField.text]){
            //通过验证
            if(_blockSend){
                _blockSend();
            }
        }else{
            //格式不对
            _emailTipButton.hidden = NO;
            [_emailTipButton setTitle:[[NSString alloc] initWithFormat:@"  %@",NSLocalizedString(@"邮箱格式不对！",nil)] forState:UIControlStateNormal];
        }
    }
}
-(void)editAction{
    if(_blockEdit){
        _blockEdit();
    }
}
-(BOOL)isNilOrEmptyWithContactValue:(NSString *)contactValue WithContactType:(NSNumber *)contactType
{
    if([NSString isNilOrEmpty:contactValue])
    {
        return YES;
    }else
    {
        if([contactType integerValue] == 1)
        {
            //移动电话
            NSArray *teleArr = [contactValue componentsSeparatedByString:@" "];
            if(teleArr.count>1)
            {
                if(![NSString isNilOrEmpty:teleArr[1]])
                {
                    return NO;
                }else
                {
                    return YES;
                }
            }
            return YES;
        }else if([contactType integerValue] == 4)
        {
            //固定电话
            NSArray *tempphoneArr = [contactValue componentsSeparatedByString:@" "];
            if(tempphoneArr.count>1)
            {
                if(![NSString isNilOrEmpty:tempphoneArr[1]])
                {
                    NSArray *phoneArr = [tempphoneArr[1] componentsSeparatedByString:@"-"];
                    NSString *vauleStr = [phoneArr componentsJoinedByString:@""];
                    if(![NSString isNilOrEmpty:vauleStr])
                    {
                        return NO;
                    }
                    return YES;
                }else
                {
                    return YES;
                }
            }
            return YES;
        }
        return NO;
    }
}
-(void)hideKeyborad{
    [regular dismissKeyborad];
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UITextFieldTextDidEndEditingNotification
                                                  object:_emailTextField];
}
@end

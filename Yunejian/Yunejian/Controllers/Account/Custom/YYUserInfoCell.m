//
//  YYUserInfoCell.m
//  Yunejian
//
//  Created by yyj on 15/7/16.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import "YYUserInfoCell.h"

#import "YYUser.h"
#import "TTTAttributedLabel.h"

@interface YYUserInfoCell ()<TTTAttributedLabelDelegate>
@property (weak, nonatomic) IBOutlet UILabel *keyLabel;
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;

@property (nonatomic,strong) UIView *ttContentView;
@property (nonatomic,assign) ShowType currentShowType;

@property (nonatomic,strong) UIView *redNoticeView;
@property (nonatomic,strong) UIView *goEmailLabel;

@property (nonatomic,strong) TTTAttributedLabel *agencyAgreementLabel;

@end

@implementation YYUserInfoCell

// 删除未激活的子账户
- (IBAction)deleteNotActiveClick:(id)sender {
    if (_deleteNotActiveWithId) {
        _deleteNotActiveWithId(self.subModel.showroomUserId);
    }
}

// 修改权限
- (IBAction)updatePowerClick:(id)sender {
    if (_updatePowerWithId) {
        _updatePowerWithId(self.subModel.showroomUserId);
    }
}


- (IBAction)buttonClicked:(id)sender{
    if (_modifyButtonClicked) {
        _modifyButtonClicked(_userInfo,_currentShowType);
    }
}


- (IBAction)switchClicked:(id)sender{
    YYUser *user = [YYUser currentUser];
    UISwitch *tempSwitch = (UISwitch *)sender;
    BOOL isOn = tempSwitch.isOn;
    if (_switchClicked) {
        if(user.userType == YYUserTypeShowroom)
        {
            _switchClicked(_subModel.showroomUserId,isOn);
        }else if(user.userType == YYUserTypeDesigner)
        {
            _switchClicked(@(_seller.salesmanId),isOn);
        }
    }    
}

- (void)setLabelStatus:(float)alpha{
    self.keyLabel.alpha = alpha;
    self.valueLabel.alpha = alpha;
}

- (void)updateUIWithShowType:(ShowType )showType{
    self.keyLabel.text = @"";
    self.valueLabel.text = @"";
    [self CreateOrHideTTLabel:YES];
    [self CreateOrHideNoticeView:YES];
    [self CreateOrHideAgencyAgreementLabel:YES];
    [self setTranslatesAutoresizingMaskIntoConstraints:YES];
    if ([YYNetworkReachability connectedToNetwork]
        && _userInfo) {
        _modifyButton.enabled = YES;
        [_modifyButton setTitleColor:[UIColor colorWithHex:@"47a3dc"] forState:UIControlStateNormal];
    }else{
        _modifyButton.enabled = NO;
        [_modifyButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    }
    
    _statusSwitch.transform = CGAffineTransformMakeScale(1, 0.9);
    
    _modifyButton.titleLabel.textAlignment = NSTextAlignmentRight;
    _modifyButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    _modifyButton.contentEdgeInsets = UIEdgeInsetsMake(0,0, 0, 10);
    _tipLabel.text = @"";

    if (showType == ShowTypeSeller) {
        if (!_seller) {
            return;
        }
    }else if(showType == ShowTypeSubShowroom){
        if(!_subModel){
            return;
        }
    }else if(showType == ShowTypeContractTime){
        if(!_ShowroomModel){
            return;
        }
    }else if(showType == ShowTypeShowroomName||showType == ShowTypeShowroomSub||showType == ShowTypeShowroomStatus){
        if(!_showroomInfoByDesignerModel){
            return;
        }
    }else{
        if (!_userInfo) {
            return;
        }
    }
    
    self.currentShowType = showType;

    switch (showType) {
        case ShowTypeEmail:{
            _keyLabel.text = NSLocalizedString(@"登录邮箱",nil);
            _valueLabel.text = _userInfo.email;
            [_modifyButton setTitle:NSLocalizedString(@"修改密码",nil) forState:UIControlStateNormal];
        }
            break;
        case ShowTypeContractTime:{
            _keyLabel.text = NSLocalizedString(@"合同起止时间",nil);
            NSString *formatter = @"yyyy.MM.dd";
            if(_ShowroomModel){
                if(_ShowroomModel.showroomInfo.contractEndTime&&_ShowroomModel.showroomInfo.contractStartTime)
                {
                    _valueLabel.text = [[NSString alloc] initWithFormat:@"%@~%@",getTimeStr([_ShowroomModel.showroomInfo.contractStartTime longLongValue]/1000, formatter),getTimeStr([_ShowroomModel.showroomInfo.contractEndTime longLongValue]/1000, formatter)];
                }else
                {
                    _valueLabel.text = @"";
                }
            }else{
                _valueLabel.text = @"";
            }
            if(_ShowroomModel.showroomInfo.contractStartTime&&_ShowroomModel.showroomInfo.contractEndTime)
            {
                
                NSCalendar *cal = [NSCalendar currentCalendar];//定义一个NSCalendar对象
//                用来得到具体的时差
                unsigned int unitFlags =  NSCalendarUnitDay;
                NSDateComponents *d = [cal components:unitFlags fromDate:[NSDate date] toDate:[NSDate dateWithTimeIntervalSince1970:[_ShowroomModel.showroomInfo.contractEndTime longLongValue]/1000] options:0];
                if(d.day<=15)
                {
                    [self CreateOrHideTTLabel:NO];
                }
            }
        }
            break;
        case ShowTypeUsername:{
            _keyLabel.text = NSLocalizedString(@"用户名",nil);
            _valueLabel.text = _userInfo.username;
            [_modifyButton setTitle:NSLocalizedString(@"修改",nil) forState:UIControlStateNormal];
        }
            break;
        case ShowTypePhone:{
            _keyLabel.text = NSLocalizedString(@"电话",nil);
            _valueLabel.text = _userInfo.phone;
            [_modifyButton setTitle:NSLocalizedString(@"修改",nil) forState:UIControlStateNormal];
        }
            break;
        case ShowTypeBrand:{
            NSString *titleStr = NSLocalizedString(@"品牌",nil);
            NSString *btnStr = NSLocalizedString(@"验证品牌信息",nil);
            NSString *btnWaitingStr = NSLocalizedString(@"品牌审核中",nil);
            NSString *tipStr = NSLocalizedString(@"请在30天内完成品牌信息验证，未验证的品牌账号将被锁定",nil);
            NSString *rufuseTipStr = NSLocalizedString(@"审核被拒,请重新验证品牌信息",nil);
            if(_userInfo.userType == YYUserTypeRetailer){
                titleStr = NSLocalizedString(@"买手店",nil);
                btnStr = NSLocalizedString(@"买手店身份审核",nil);
                btnWaitingStr = NSLocalizedString(@"身份审核中",nil);
                tipStr = @"";
                rufuseTipStr = NSLocalizedString(@"审核被拒,请重新验证身份信息",nil);
            }
            _keyLabel.text = titleStr;
            _valueLabel.text = _userInfo.brandName;
            //_userInfo.status = @"305";
            if([_userInfo.status integerValue] == YYReqStatusCode305){
                _modifyButton.enabled = YES;
            }else{
                _modifyButton.enabled = NO;
            }
            _modifyButton.hidden = YES;
            _tipLabel.hidden = YES;
            if([_userInfo.status integerValue] == YYReqStatusCode305){
                _modifyButton.hidden = NO;
                [_modifyButton setTitle:btnStr forState:UIControlStateNormal];
                [_tipLabel setAdjustsFontSizeToFitWidth:YES];
                _tipLabel.text = tipStr;
                _tipLabel.hidden = NO;
            }else if([_userInfo.status integerValue] == YYReqStatusCode300){
                _modifyButton.hidden = NO;
                [_modifyButton setTitle:btnWaitingStr forState:UIControlStateNormal];
            }else if([_userInfo.status integerValue] == YYReqStatusCode301){
                _modifyButton.hidden = NO;
                [_modifyButton setTitle:btnStr forState:UIControlStateNormal];
                [_tipLabel setAdjustsFontSizeToFitWidth:YES];
                _tipLabel.text = rufuseTipStr;
                _tipLabel.hidden = NO;
            }
        }
            break;
        case ShowTypeSeller:{
            _keyLabel.text = _seller.name;
            _valueLabel.text = _seller.email;
        }
            break;
        case ShowTypeSubShowroom:{
            _keyLabel.text = _subModel.manager;
            _valueLabel.text = _subModel.email;
        }
            break;
        case ShowTypeShowroomName:{

            if(![NSString isNilOrEmpty:_showroomInfoByDesignerModel.showroomName]){
                _keyLabel.text = NSLocalizedString(@"名称",nil);
                _valueLabel.text = _showroomInfoByDesignerModel.showroomName;
            }else{
                _keyLabel.text = NSLocalizedString(@"暂无代理",nil);
            }
        }
            break;
        case ShowTypeShowroomSub:{
            
            _keyLabel.text = NSLocalizedString(@"销售",nil);
            _valueLabel.text = [_showroomInfoByDesignerModel getSalesStr];
        }
            break;
        case ShowTypeShowroomStatus:{
            
            _keyLabel.text = NSLocalizedString(@"状态",nil);
            if([_showroomInfoByDesignerModel.status isEqualToString:@"AGREE"]){
                _valueLabel.text = NSLocalizedString(@"代理中",nil);
                [self CreateOrHideAgencyAgreementLabel:NO];
                [_modifyButton setTitle:NSLocalizedString(@"解除代理",nil) forState:UIControlStateNormal];
            }else if([_showroomInfoByDesignerModel.status isEqualToString:@"INIT"]){
                _valueLabel.text = NSLocalizedString(@"待同意",nil);
                [self CreateOrHideNoticeView:NO];
            }
        }
            break;
        default:
            break;
    }
}
-(void)CreateOrHideAgencyAgreementLabel:(BOOL)ishide{
    if(!_agencyAgreementLabel){
        if(!ishide){
            
            _agencyAgreementLabel =[[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
            [self.contentView addSubview:_agencyAgreementLabel];
            [_agencyAgreementLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(_valueLabel.mas_right).with.offset(20);
                make.centerY.mas_equalTo(_valueLabel);
            }];
            NSString *contnent = NSLocalizedString(@"代理协议",nil);
            _agencyAgreementLabel.textAlignment = 0;
            _agencyAgreementLabel.font = getFont(13.0f);
            _agencyAgreementLabel.textColor = [UIColor colorWithHex:@"919191"];
            _agencyAgreementLabel.linkAttributes = @{NSForegroundColorAttributeName:[UIColor colorWithHex:@"919191"]};
            _agencyAgreementLabel.activeLinkAttributes = @{NSForegroundColorAttributeName:[UIColor colorWithHex:@"919191"]};
            _agencyAgreementLabel.inactiveLinkAttributes = @{NSForegroundColorAttributeName:[UIColor colorWithHex:@"919191"]};
            _agencyAgreementLabel.delegate = self;
            _agencyAgreementLabel.enabledTextCheckingTypes = NSTextCheckingTypeLink;
            [_agencyAgreementLabel setText:contnent afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
                NSRange range = [[mutableAttributedString string] rangeOfString:NSLocalizedString(@"代理协议",nil) options:NSCaseInsensitiveSearch];
                
                [mutableAttributedString addAttribute:NSUnderlineStyleAttributeName
                                                value:[NSNumber numberWithInt:1]
                                                range:range];
                [mutableAttributedString addAttribute:NSUnderlineColorAttributeName
                                                value:[UIColor colorWithHex:@"919191"]
                                                range:range];
                
                return mutableAttributedString;
            }];
            
            NSURL *url = [NSURL fileURLWithPath:@""];
            [_agencyAgreementLabel addLinkToURL:url withRange:[contnent rangeOfString:NSLocalizedString(@"代理协议",nil)]];
        }
    }
    _agencyAgreementLabel.hidden = ishide;
}
-(void)CreateOrHideNoticeView:(BOOL)ishide{
    if(!_redNoticeView){
        if(!ishide){
            _redNoticeView = [UIView getCustomViewWithColor:[UIColor colorWithHex:@"ef4e31"]];
            [self.contentView addSubview:_redNoticeView];
            [_redNoticeView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(_valueLabel.mas_right).with.offset(0);
                make.width.height.mas_equalTo(6);
                make.top.mas_equalTo(_valueLabel);
            }];
            _redNoticeView.layer.masksToBounds = YES;
            _redNoticeView.layer.cornerRadius = 3;
        }
    }
    
    if(!_goEmailLabel&&_redNoticeView){
        if(!ishide){
            
            _goEmailLabel = [UILabel getLabelWithAlignment:1 WithTitle:NSLocalizedString(@"（请至主账号邮箱中处理）",nil) WithFont:14.0f WithTextColor:[UIColor colorWithHex:@"919191"] WithSpacing:0];
            [self.contentView addSubview:_goEmailLabel];
            [_goEmailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(_redNoticeView.mas_right).with.offset(0);
                make.centerY.mas_equalTo(_valueLabel);
            }];
        }
    }
    _redNoticeView.hidden = ishide;
    _goEmailLabel.hidden = ishide;
    
}
-(void)CreateOrHideTTLabel:(BOOL )ishide{
    if(!_ttContentView){
        if(!ishide){
            
            _ttContentView = [UIView getCustomViewWithColor:nil];
            [self.contentView addSubview:_ttContentView];
            [_ttContentView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(_valueLabel.mas_right).with.offset(10);
                make.centerY.mas_equalTo(self.contentView);
            }];
            
            UILabel *redLabel = [UILabel getLabelWithAlignment:0 WithTitle:NSLocalizedString(@"即将到期",nil) WithFont:13.0f WithTextColor:[UIColor colorWithHex:@"EF4E31"] WithSpacing:0];
            [_ttContentView addSubview:redLabel];
            [redLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.bottom.top.mas_equalTo(0);
                make.centerY.mas_equalTo(_ttContentView);
            }];
            
            TTTAttributedLabel *_contentLabel =[[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
            [_ttContentView addSubview:_contentLabel];
            [_contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(redLabel.mas_right).with.offset(0);
                make.centerY.mas_equalTo(_ttContentView);
                make.right.mas_equalTo(0);
            }];
            
            NSString *contnent = NSLocalizedString(@"（续签请与小助手联系）",nil);
            _contentLabel.textAlignment = 0;
            _contentLabel.font = getFont(13.0f);
            _contentLabel.textColor = [UIColor colorWithHex:@"919191"];
            _contentLabel.linkAttributes = @{NSForegroundColorAttributeName:[UIColor colorWithHex:@"919191"]};
            _contentLabel.activeLinkAttributes = @{NSForegroundColorAttributeName:[UIColor colorWithHex:@"919191"]};
            _contentLabel.inactiveLinkAttributes = @{NSForegroundColorAttributeName:[UIColor colorWithHex:@"919191"]};
            _contentLabel.delegate = self;
            _contentLabel.enabledTextCheckingTypes = NSTextCheckingTypeLink;
            [_contentLabel setText:contnent afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
                NSRange range = [[mutableAttributedString string] rangeOfString:@"小助手" options:NSCaseInsensitiveSearch];
                
                [mutableAttributedString addAttribute:NSUnderlineStyleAttributeName
                                                value:[NSNumber numberWithInt:1]
                                                range:range];
                [mutableAttributedString addAttribute:NSUnderlineColorAttributeName
                                                value:[UIColor colorWithHex:@"919191"]
                                                range:range];

                return mutableAttributedString;
            }];
            
            NSURL *url = [NSURL fileURLWithPath:@""];
            [_contentLabel addLinkToURL:url withRange:[contnent rangeOfString:@"小助手"]];
        }
    }
    _ttContentView.hidden = ishide;
}
#pragma mark - TTTAttributedLabelDelegate
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url
{
    if(label == _agencyAgreementLabel){
        if(_block){
            _block(@"agency");
        }
    }else{
        if(_block){
            _block(@"showhelp");
        }
    }
}
@end

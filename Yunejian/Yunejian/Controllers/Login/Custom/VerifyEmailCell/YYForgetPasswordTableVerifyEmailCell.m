//
//  YYForgetPasswordTableVerifyEmailCell.m
//  Yunejian
//
//  Created by Apple on 16/10/17.
//  Copyright © 2016年 yyj. All rights reserved.
//

#import "YYForgetPasswordTableVerifyEmailCell.h"

#import "YYUserApi.h"
#import "UIView+UpdateAutoLayoutConstraints.h"
#import "TTTAttributedLabel.h"

@interface YYForgetPasswordTableVerifyEmailCell()
@property (nonatomic,strong)TTTAttributedLabel *emailTTLabel;
@end

@implementation YYForgetPasswordTableVerifyEmailCell{
    NSString *_email;
    NSInteger _emailType;
}
#pragma mark - UI
-(void)updateCellInfo:(NSArray *)info{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    _email = [info objectAtIndex:0];
    NSString *emailTipStr =[NSString stringWithFormat:NSLocalizedString(@"已经向 %@ 发送邮件",nil),_email];
    _emialTipLabel.textColor = [UIColor colorWithHex:@"919191"];
    _emialTipLabel.linkAttributes = @{NSForegroundColorAttributeName:[UIColor colorWithHex:@"919191"]};
    _emialTipLabel.activeLinkAttributes = @{NSForegroundColorAttributeName:[UIColor colorWithHex:@"919191"]};
    _emialTipLabel.inactiveLinkAttributes = @{NSForegroundColorAttributeName:[UIColor colorWithHex:@"919191"]};
    _emialTipLabel.numberOfLines = 0;
    _emialTipLabel.enabledTextCheckingTypes = NSTextCheckingTypeLink;
    __block NSString *tempEmail = _email;
    [_emialTipLabel setText:emailTipStr afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
        NSRange range = [[mutableAttributedString string] rangeOfString:tempEmail options:NSCaseInsensitiveSearch];
        [mutableAttributedString addAttribute:NSUnderlineStyleAttributeName
                                        value:[NSNumber numberWithInt:1]
                                        range:range];
        [mutableAttributedString addAttribute:NSUnderlineColorAttributeName
                                        value:[UIColor colorWithHex:@"919191"]
                                        range:range];
        return mutableAttributedString;
    }];
    
}
#pragma mark - SomeAction
- (IBAction)submitHandler:(id)sender {
    if(self.delegate == nil){
        return;
    }
    [_sendBtn stop];
    [self.delegate btnClick:_indexPath.row section:_indexPath.section andParmas:@[@"",@(-1),@"submit"]];
}



- (IBAction)lookEmailHandler:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"mailto://%@",_email]]];
    
}

- (IBAction)reSendEmailHandler:(id)sender {
//    if(false){
//        [YYUserApi reSendMailConfirmMail:_email andUserType:[NSString stringWithFormat:@"%ld",(long)kBuyerStorUserType] andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSError *error) {
//            if(rspStatusAndMessage.status == kCode100){
//                [YYToast showToastWithTitle:NSLocalizedString(@"发送成功！",nil) andDuration:kAlertToastDuration];
//            }else{
//                [YYToast showToastWithTitle:rspStatusAndMessage.message andDuration:kAlertToastDuration];
//            }
//            
//        }];
//    }else if (_emailType == kEmailPasswordType){
        [YYUserApi forgetPassword:[NSString stringWithFormat:@"email=%@",_email] andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSError *error) {
            
            if( rspStatusAndMessage.status == kCode100){
                [YYToast showToastWithTitle:NSLocalizedString(@"发送成功！",nil) andDuration:kAlertToastDuration];
            }else{
                [YYToast showToastWithTitle:rspStatusAndMessage.message andDuration:kAlertToastDuration];
            }
        }];
//    }
    
    _sendBtn.enabled = NO;
    [_sendBtn setTitleColor:[UIColor colorWithHex:@"919191"] forState:UIControlStateNormal];
    [_sendBtn startWithSecond:60];
    _sendTimerLabel.text = @"60s";
    _sendTimerLabel.textColor = [UIColor colorWithHex:@"ef4e31"];
    WeakSelf(ws);
    [_sendBtn didChange:^NSString *(JKCountDownButton *countDownButton,int second) {
        NSString *title = NSLocalizedString(@"没收到，再发一封",nil);
        ws.sendTimerLabel.text = [NSString stringWithFormat:@"%ds",second];
        return title;
    }];
    [_sendBtn didFinished:^NSString *(JKCountDownButton *countDownButton, int second) {
        countDownButton.enabled = YES;
        ws.sendTimerLabel.textColor = [UIColor colorWithHex:@"919191"];
        [ws.sendBtn setTitleColor:[UIColor colorWithHex:@"ef4e31"] forState:UIControlStateNormal];
        
        return NSLocalizedString(@"没收到，再发一封",nil);
        
    }];
}
#pragma mark - Other
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
-(void)dealloc{
    [_sendBtn stop];
}
@end

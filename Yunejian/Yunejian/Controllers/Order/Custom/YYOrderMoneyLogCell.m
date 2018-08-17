//
//  YYOrderMoneyLogCell.m
//  Yunejian
//
//  Created by Apple on 15/11/25.
//  Copyright © 2015年 yyj. All rights reserved.
//

#import "YYOrderMoneyLogCell.h"

#import "ASPopUpView.h"
#import "UIView+UpdateAutoLayoutConstraints.h"

@interface YYOrderMoneyLogCell()
@property (strong, nonatomic) ASPopUpView *popUpView;

@end
@implementation YYOrderMoneyLogCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

-(void)dealloc{
    [self hidePopUpViewAnimated:NO];
}

-(void)updateUI{
    self.contentView.backgroundColor = [UIColor colorWithHex:kDefaultBGColor];
    self.addLogBtn.layer.borderColor = [UIColor blackColor].CGColor;
    self.addLogBtn.layer.borderWidth = 1;
    
    [self.pLabel setTrackWidth: 8.0];
    [self.pLabel setProgressWidth: 8];
    self.pLabel.fillColor = [[UIColor whiteColor] colorWithAlphaComponent:.3];
    self.pLabel.trackColor = [UIColor colorWithHex:kDefaultImageColor];
    self.pLabel.isStartDegreeUserInteractive = NO;
    self.pLabel.isEndDegreeUserInteractive = NO;


    NSInteger tranStatus = getOrderTransStatus(self.currentYYOrderTransStatusModel.designerTransStatus, self.currentYYOrderTransStatusModel.buyerTransStatus);

    if(tranStatus == kOrderCode_CLOSE_REQ){
        self.pLabel.progressColor = [UIColor colorWithHex:kDefaultBorderColor];
    }else{
        if(tranStatus > 0){
            self.pLabel.progressColor = [UIColor colorWithHex:@"ed6498"];
        }else{
            self.pLabel.progressColor = [UIColor clearColor];
        }
    }
    
    float rndValue =  0;
    if(_paymentNoteList == nil || [_paymentNoteList.result count] == 0){

    }else{
        for (YYPaymentNoteModel *noteModel in _paymentNoteList.result) {
            if([noteModel.payType integerValue] == 0 && ([noteModel.payStatus integerValue] == 0 || [noteModel.payStatus integerValue] == 2)){
            }else{
                rndValue += [noteModel.percent floatValue];
            }
        }

        rndValue = rndValue/100;

    }
    [self.pLabel setProgress:rndValue];
    NSInteger progressValue= rndValue*100;
    [self.pLabel setText:[NSString stringWithFormat:@"%ld%@",(long)progressValue,@"%"]];
    NSString *hasMoneyStr = [NSString stringWithFormat:NSLocalizedString(@"%d%@货款已收",nil),MIN(100,progressValue),@"%"];
    [self.hasMoneyLabel setText:hasMoneyStr];
    CGSize hasMoneyTxtSize = [hasMoneyStr sizeWithAttributes:@{NSFontAttributeName:self.hasMoneyLabel.font}];
    [self.hasMoneyLabel setConstraintConstant:hasMoneyTxtSize.width+1 forAttribute:NSLayoutAttributeWidth];
    
    [self hidePopUpViewAnimated:NO];
    if(progressValue > 100 ){
        self.hasMoneyTipBtn.hidden = NO;
    }else{
        self.hasMoneyTipBtn.hidden = YES;
    }
    
    if( tranStatus == 0 || tranStatus == kOrderCode_NEGOTIATION  || tranStatus == kOrderCode_CANCELLED || tranStatus == kOrderCode_CLOSED || tranStatus == kOrderCode_CLOSE_REQ){
        self.addLogBtn.hidden = YES;
    }else{
        self.addLogBtn.hidden = NO;
    }
}


#pragma warnOrderMinMoney
- (IBAction)showHasMoneyTip:(id)sender {
    
    [self hidePopUpViewAnimated:NO];
    
    if(self.popUpView == nil){
        self.popUpView = [[ASPopUpView alloc] initWithFrame:CGRectZero];
        self.popUpView.alpha = 0.0;
        [self.popUpView setFont:[UIFont systemFontOfSize:12]];
        [self.popUpView setTextColor:[UIColor colorWithHex:@"ef4e31"]];
        [self.popUpView setColor:[UIColor colorWithHex:@"ef4e31"]];
        [_hasMoneyTipBtn addSubview:self.popUpView];
    }
    NSString *string =  NSLocalizedString(@"收款金额已超过订单总额",nil);
    CGSize size = [self.popUpView popUpSizeForString:string];
    CGRect popUpRect = CGRectMake(-(size.width+10)/2+22,10, size.width+10, size.height+20);
    [self.popUpView setFrame:popUpRect arrowOffset:0 text:string];
    [self showPopUpViewAnimated:YES];
    [self performSelector:@selector(delayMethod) withObject:nil afterDelay:2.0f];
}

- (void)delayMethod {
    [self hidePopUpViewAnimated:YES];
}

- (void)showPopUpViewAnimated:(BOOL)animated
{
    if (self.popUpView.alpha == 1.0) return;
    [self.popUpView showAnimated:animated];
}

- (void)hidePopUpViewAnimated:(BOOL)animated
{
    if (self.popUpView.alpha == 0.0) return;
    [self.popUpView hideAnimated:animated completionBlock:^{
        //weakSelf.popUpView = nil;
    }];
}


- (IBAction)showMoneyLogView:(id)sender {
    if(self.delegate){
        [self.delegate btnClick:0 section:0 andParmas:@[@"paylog"]];
    }
}
- (IBAction)showPayLogView:(id)sender {
    if(self.delegate){
        [self.delegate btnClick:0 section:0 andParmas:@[@"payloglist"]];
    }
}

+(float)cellHeight:(NSArray *)payNoteList{

    return 107;
}
@end

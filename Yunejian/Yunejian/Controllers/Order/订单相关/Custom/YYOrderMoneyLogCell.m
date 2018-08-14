//
//  YYOrderMoneyLogCell.m
//  Yunejian
//
//  Created by Apple on 15/11/25.
//  Copyright © 2015年 yyj. All rights reserved.
//

#import "YYOrderMoneyLogCell.h"

// c文件 —> 系统文件（c文件在前）

// 控制器

// 自定义视图
#import "ASPopUpView.h"
#import "KAProgressLabel.h"

// 接口

// 分类
#import "UIView+UpdateAutoLayoutConstraints.h"

// 自定义类和三方类（ cocoapods类 > model > 工具类 > 其他）
#import "YYOrderInfoModel.h"
#import "YYPaymentNoteListModel.h"
#import "YYOrderTransStatusModel.h"

@interface YYOrderMoneyLogCell()

@property (weak, nonatomic) IBOutlet KAProgressLabel *pLabel;
@property (weak, nonatomic) IBOutlet UIButton *addLogBtn;
@property (weak, nonatomic) IBOutlet UILabel *hasMoneyLabel;
@property (weak, nonatomic) IBOutlet UIButton *hasMoneyTipBtn;

@property (strong, nonatomic) ASPopUpView *popUpView;

@end

@implementation YYOrderMoneyLogCell
#pragma mark - --------------生命周期--------------
- (void)awakeFromNib {
    [super awakeFromNib];
    [self SomePrepare];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}
-(void)dealloc{
    [self hidePopUpViewAnimated:NO];
}
#pragma mark - --------------SomePrepare--------------
- (void)SomePrepare
{
    [self PrepareData];
    [self PrepareUI];
}
- (void)PrepareData{}
- (void)PrepareUI{
    self.contentView.backgroundColor = [UIColor colorWithHex:kDefaultBGColor];

    self.addLogBtn.layer.cornerRadius = 2.5;
    self.addLogBtn.layer.masksToBounds = YES;
    setBorderCustom(self.addLogBtn, 1, [UIColor blackColor]);

}

#pragma mark - --------------UIConfig----------------------
-(void)UIConfig{
}

#pragma mark - --------------UpdateUI----------------------
-(void)updateUI{

    [self.pLabel setTrackWidth: 8.0];
    [self.pLabel setProgressWidth: 8];
    self.pLabel.fillColor = [[UIColor whiteColor] colorWithAlphaComponent:.3];
    self.pLabel.trackColor = [UIColor colorWithHex:kDefaultImageColor];
    self.pLabel.isStartDegreeUserInteractive = NO;
    self.pLabel.isEndDegreeUserInteractive = NO;


    NSInteger tranStatus = getOrderTransStatus(self.currentYYOrderTransStatusModel.designerTransStatus, self.currentYYOrderTransStatusModel.buyerTransStatus);

    if(tranStatus == YYOrderCode_CLOSE_REQ){
        self.pLabel.progressColor = [UIColor colorWithHex:kDefaultBorderColor];
    }else{
        if(tranStatus > 0){
            self.pLabel.progressColor = [UIColor colorWithHex:@"ed6498"];
        }else{
            self.pLabel.progressColor = [UIColor clearColor];
        }
    }

    float hasGiveRate =  [_paymentNoteList.hasGiveRate floatValue];

    [self.pLabel setProgress:hasGiveRate/100.f];
    NSInteger progressValue = hasGiveRate;
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

    if( tranStatus == 0 || progressValue == 100|| tranStatus == YYOrderCode_NEGOTIATION  || tranStatus == YYOrderCode_CANCELLED || tranStatus == YYOrderCode_CLOSED || tranStatus == YYOrderCode_CLOSE_REQ){
        self.addLogBtn.hidden = YES;
    }else{
        self.addLogBtn.hidden = NO;
    }
}

#pragma mark - --------------系统代理----------------------

#pragma mark - --------------自定义响应----------------------
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

#pragma mark - --------------自定义方法----------------------
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

+(float)cellHeight:(NSArray *)payNoteList{

    return 107;
}

#pragma mark - --------------other----------------------

@end

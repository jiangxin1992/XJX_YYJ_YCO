//
//  YYOrderMessageViewCell.m
//  Yunejian
//
//  Created by Apple on 15/10/27.
//  Copyright © 2015年 yyj. All rights reserved.
//

#import "YYOrderMessageViewCell.h"

// c文件 —> 系统文件（c文件在前）

// 控制器

// 自定义视图
#import "SCGIFImageView.h"

// 接口
#import "YYOrderApi.h"

// 分类
#import "UIImage+YYImage.h"
#import "UIView+UpdateAutoLayoutConstraints.h"

// 自定义类和三方类（ cocoapods类 > model > 工具类 > 其他）
#import "YYOrderMessageInfoModel.h"

@interface YYOrderMessageViewCell()

@property (weak, nonatomic) IBOutlet SCGIFImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UIImageView *bottomView;
@property (weak, nonatomic) IBOutlet UILabel *messageTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageTimerLabel;

@property (weak, nonatomic) IBOutlet UILabel *orderCodeLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderCreateLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderPriceLabel;
@property (weak, nonatomic) IBOutlet UIButton *orderCloseTimerLabel;//

@property (weak, nonatomic) IBOutlet UIButton *agreeBtn;
@property (weak, nonatomic) IBOutlet UIButton *refuseBtn;

@end

@implementation YYOrderMessageViewCell
#pragma mark - --------------生命周期--------------
- (void)awakeFromNib {
    [super awakeFromNib];
    [self SomePrepare];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

#pragma mark - --------------SomePrepare--------------
- (void)SomePrepare
{
    [self PrepareData];
    [self PrepareUI];
}
- (void)PrepareData{}
- (void)PrepareUI{
    _bottomView.layer.borderColor = [UIColor whiteColor].CGColor;
    _bottomView.layer.borderWidth = 2;
    _bottomView.layer.cornerRadius = CGRectGetWidth(_bottomView.frame)/2;
    _bottomView.layer.masksToBounds = YES;

    self.refuseBtn.layer.borderColor = [UIColor colorWithHex:@"efefef"].CGColor;
    self.refuseBtn.layer.borderWidth = 1;
    self.refuseBtn.layer.cornerRadius = 2.5;
    self.refuseBtn.layer.masksToBounds = YES;
    self.agreeBtn.layer.cornerRadius = 2.5;
    self.agreeBtn.layer.masksToBounds = YES;
}

#pragma mark - --------------UpdateUI----------------------
-(void)updateUI{

    _messageTitleLabel.attributedText = [self getTextAttributedString:_msgInfoModel.msgTitle replaceStrs:@[NSLocalizedString(@"同意",nil),NSLocalizedString(@"移除",nil),NSLocalizedString(@"拒绝",nil),NSLocalizedString(@"解除",nil),NSLocalizedString(@"已取消",nil),NSLocalizedString(@"订单已取消",nil)] replaceColors:@[@"58c776",@"ef4e31",@"ef4e31",@"ef4e31",@"ef4e31",@"ef4e31"]];

    CGSize messageTitleLabelSize = [_messageTitleLabel.text sizeWithAttributes:@{NSFontAttributeName:_messageTitleLabel.font}];
    [_messageTitleLabel setConstraintConstant:(messageTitleLabelSize.width+1) forAttribute:NSLayoutAttributeWidth];

    _messageTimerLabel.text = getShowDateByFormatAndTimeInterval(@"yyyy/MM/dd HH:mm",[_msgInfoModel.sendTime stringValue]);

    if(_msgInfoModel && _msgInfoModel.msgContent){
        if(_msgInfoModel.msgContent.logo){
            sd_downloadWebImageWithRelativePath(NO, _msgInfoModel.msgContent.logo, self.logoImageView, kLogoCover, 0);
        }
        if(_msgInfoModel.msgContent.buyerLogo){
            sd_downloadWebImageWithRelativePath(NO, _msgInfoModel.msgContent.buyerLogo, _logoImageView, kLogoCover, 0);
        }
        _orderCodeLabel.text =  [NSString stringWithFormat:NSLocalizedString(@"订单号. %@%@",nil),_msgInfoModel.msgContent.orderCode ,([_msgInfoModel.isAppendOrder integerValue]?NSLocalizedString(@"（追单）",nil):@"")];

        CGSize orderCodeLabelSize = [_orderCodeLabel.text sizeWithAttributes:@{NSFontAttributeName:_orderCodeLabel.font}];
        [_orderCodeLabel setConstraintConstant:MAX(180,orderCodeLabelSize.width+1) forAttribute:NSLayoutAttributeWidth];
        _orderCreateLabel.text = [NSString stringWithFormat:NSLocalizedString(@"建单时间 %@",nil),getShowDateByFormatAndTimeInterval(@"yyyy/MM/dd HH:mm",[_msgInfoModel.msgContent.orderCreateTime stringValue])];
        NSInteger moneyType = (_msgInfoModel.msgContent.curType!=nil?[_msgInfoModel.msgContent.curType integerValue]:0);
        _orderPriceLabel.text = [NSString stringWithFormat:replaceMoneyFlag(NSLocalizedString(@"共计%@款%@件  总价：￥%@",nil),moneyType),_msgInfoModel.msgContent.styleNum,_msgInfoModel.msgContent.totalAmount,_msgInfoModel.msgContent.totalPrice];

    }else{
        sd_downloadWebImageWithRelativePath(NO, @"", self.logoImageView, kLogoCover, 0);
        _orderCodeLabel.text  = @"";
        _orderPriceLabel.text = @"";
        _orderCreateLabel.text = @"";
    }
    _bottomView.hidden = YES;
    if(_msgInfoModel.isRead == NO){
        _messageTitleLabel.font = [UIFont boldSystemFontOfSize:15];
        _bottomView.hidden = NO;
    }else{
        _messageTitleLabel.font = [UIFont systemFontOfSize:15];
        _bottomView.hidden = YES;
    }
    
    _orderCloseTimerLabel.hidden = YES;

    if(_msgInfoModel.msgContent && ![NSString isNilOrEmpty:_msgInfoModel.msgContent.op]){
        if([_msgInfoModel.msgContent.op isEqualToString:@"need_confirm"]){
            if([_msgInfoModel.dealStatus integerValue] == -1){
                if(_msgInfoModel.orderTransStatus && [_msgInfoModel.orderTransStatus integerValue] != 4){
                    //双方都已确认
                    _agreeBtn.hidden = YES;
                    _refuseBtn.hidden = YES;
                }else{
                    //我待确认(对方已确认)
                    _agreeBtn.hidden = NO;
                    _refuseBtn.hidden = NO;
                    [_agreeBtn setTitle:NSLocalizedString(@"确认",nil) forState:UIControlStateNormal];
                    [_refuseBtn setTitle:NSLocalizedString(@"拒绝",nil) forState:UIControlStateNormal];
                }
            }else if([_msgInfoModel.dealStatus integerValue] == 1){
                //我已确认
                _agreeBtn.hidden = YES;
                _refuseBtn.hidden = YES;
            }else if([_msgInfoModel.dealStatus integerValue] == 2){
                //我已拒绝
                _agreeBtn.hidden = YES;
                _refuseBtn.hidden = YES;
            }
        }else if([_msgInfoModel.msgContent.op isEqualToString:@"order_rejected"]){
            //对方已拒绝
            _agreeBtn.hidden = YES;
            _refuseBtn.hidden = YES;
            _orderCloseTimerLabel.hidden = NO;
            NSString *reason = [[NSString alloc] initWithFormat:NSLocalizedString(@"拒绝理由：%@",nil),_msgInfoModel.msgContent.reason];
            [_orderCloseTimerLabel setTitle:reason forState:UIControlStateNormal];
            [_orderCloseTimerLabel setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
        }
    }

    [self updateConstraintsIfNeeded];
}

#pragma mark - --------------请求数据----------------------
-(void)RequestData{}

#pragma mark - --------------自定义响应----------------------
- (IBAction)agreeHandler:(id)sender {
    if(_msgInfoModel.msgContent && ![NSString isNilOrEmpty:_msgInfoModel.msgContent.op]){
        if([_msgInfoModel.msgContent.op isEqualToString:@"need_confirm"]){
            if([_msgInfoModel.dealStatus integerValue] == -1){
                if(_msgInfoModel.orderTransStatus && [_msgInfoModel.orderTransStatus integerValue] != 4){
                    //双方都已确认
                }else{
                    //确认订单
                    [self confirmOrder];
                }
            }
        }
    }
}

- (IBAction)refuseHandler:(id)sender {
    if(_msgInfoModel.msgContent && ![NSString isNilOrEmpty:_msgInfoModel.msgContent.op]){
        if([_msgInfoModel.msgContent.op isEqualToString:@"need_confirm"]){
            if([_msgInfoModel.dealStatus integerValue] == -1){
                if(_msgInfoModel.orderTransStatus && [_msgInfoModel.orderTransStatus integerValue] != 4){
                    //双方都已确认
                }else{
                    //拒绝确认订单
                    [self refuseOrder];
                }
            }
        }
    }
}

- (IBAction)logoImageHandler:(id)sender {
    if(self.delegate){
        [self.delegate btnClick:_indexPath.row section:_indexPath.section andParmas:@[@"buyerInfo"]];
    }
}

- (IBAction)contentHandler:(id)sender {
    if(self.delegate){
        [self.delegate btnClick:_indexPath.row section:_indexPath.section andParmas:@[@"orderInfo"]];
    }
}

#pragma mark - --------------自定义方法----------------------
//确认订单
-(void)confirmOrder{
    CMAlertView *alertView = [[CMAlertView alloc] initWithTitle:NSLocalizedString(@"确认此订单？", nil) message:NSLocalizedString(@"确认后将无法修改订单，是否确认该订单？",nil) needwarn:NO delegate:nil cancelButtonTitle:NSLocalizedString(@"取消",nil) otherButtonTitles:@[NSLocalizedString(@"确认",nil)]];
    [alertView setAlertViewBlock:^(NSInteger selectedIndex){
        if (selectedIndex == 1) {
            [YYOrderApi confirmOrderByOrderCode:_msgInfoModel.msgContent.orderCode andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSError *error) {
                if(rspStatusAndMessage.status == YYReqStatusCode100){
                    _msgInfoModel.msgContent.op = @"need_confirm";
                    _msgInfoModel.dealStatus = @(1);
                    [YYToast showToastWithTitle:NSLocalizedString(@"订单已确认", nil) andDuration:kAlertToastDuration];
                    if(self.delegate){
                        [self.delegate btnClick:_indexPath.row section:_indexPath.section andParmas:@[@"reload"]];
                    }
                }else{
                    [YYToast showToastWithTitle:rspStatusAndMessage.message andDuration:kAlertToastDuration];
                }
            }];
        }
    }];
    [alertView show];
}
//拒绝确认订单
-(void)refuseOrder{
    CMAlertView *alertView = [[CMAlertView alloc] initRefuseOrderReasonWithTitle:NSLocalizedString(@"请填写拒绝原因", nil) message:nil otherButtonTitles:@[NSLocalizedString(@"提交",nil)]];
    [alertView setAlertViewSubmitBlock:^(NSString *reson) {
        NSLog(@"准备提交");
        [YYOrderApi refuseOrderByOrderCode:_msgInfoModel.msgContent.orderCode reason:reson andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSError *error) {
            if(rspStatusAndMessage.status == YYReqStatusCode100){
                _msgInfoModel.msgContent.op = @"need_confirm";
                _msgInfoModel.dealStatus = @(2);
                [YYToast showToastWithTitle:NSLocalizedString(@"已提交", nil) andDuration:kAlertToastDuration];
                if(self.delegate){
                    [self.delegate btnClick:_indexPath.row section:_indexPath.section andParmas:@[@"reload"]];
                }
            }else{
                [YYToast showToastWithTitle:rspStatusAndMessage.message andDuration:kAlertToastDuration];
            }
        }];
    }];
    [alertView show];
}
-(NSMutableAttributedString *)getTextAttributedString:(NSString *)targetStr replaceStrs:(NSArray *)replaceStrs replaceColors:(NSArray *)replaceColors{
    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString: targetStr];
    NSInteger index =0;
    for (NSString *replaceStr in replaceStrs) {
        NSRange range = [targetStr rangeOfString:replaceStr];
        if (range.location != NSNotFound) {
            [attributedStr addAttribute: NSForegroundColorAttributeName value: [UIColor colorWithHex:[replaceColors objectAtIndex:index]] range:range];
        }
        index++;
    }
    return attributedStr;
}

#pragma mark - --------------other----------------------


@end

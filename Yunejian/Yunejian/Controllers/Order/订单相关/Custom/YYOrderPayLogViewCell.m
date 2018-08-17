//
//  YYOrderPayLogViewCell.m
//  YunejianBuyer
//
//  Created by Apple on 16/7/20.
//  Copyright © 2016年 Apple. All rights reserved.
//

#import "YYOrderPayLogViewCell.h"

// c文件 —> 系统文件（c文件在前）

// 控制器

// 自定义视图

// 接口

// 分类
#import "UIImage+Tint.h"
#import "UIView+UpdateAutoLayoutConstraints.h"

// 自定义类和三方类（ cocoapods类 > model > 工具类 > 其他）
#import "YYPaymentNoteModel.h"

@interface YYOrderPayLogViewCell()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *timerLabel;
@property (weak, nonatomic) IBOutlet UIButton *statusLabel;
@property (weak, nonatomic) IBOutlet UIButton *statusBtn;
@property (weak, nonatomic) IBOutlet UIButton *payTypeLabel;
@property (weak, nonatomic) IBOutlet UIView *redDotView;
@property (weak, nonatomic) IBOutlet UIButton *makeSureBtn;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;
@property (weak, nonatomic) IBOutlet UIView *oprateView;
@property (weak, nonatomic) IBOutlet UILabel *detailTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailTitleLabel3;
@property (weak, nonatomic) IBOutlet UILabel *detailTitleLabel4;
@property (weak, nonatomic) IBOutlet UIView *detailView;
@property (weak, nonatomic) IBOutlet UILabel *outTradeNoLabel;
@property (weak, nonatomic) IBOutlet UILabel *payMethodLabel;
@property (weak, nonatomic) IBOutlet UILabel *payTimerLabel;
@property (weak, nonatomic) IBOutlet UILabel *getTimerLabel;

@property (nonatomic, strong) UIImage *statusImage;
@property (nonatomic, strong) NSString *statusTxt;

@end

@implementation YYOrderPayLogViewCell

#pragma mark - UI
-(void)updateUI{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    NSString *preTitleStr = nil;
    NSInteger statusValue = [_noteModel.payStatus integerValue];
    _statusLabel.userInteractionEnabled = NO;
    _statusBtn.userInteractionEnabled = NO;
    _payTypeLabel.userInteractionEnabled = NO;
    if( [_noteModel.payType integerValue] == 0){
        preTitleStr = NSLocalizedString(@"线下收款",nil);
        _statusImage = nil;//[UIImage imageNamed:@"pencil1"];
        [_payTypeLabel setTitle:preTitleStr forState:UIControlStateNormal];
        [_payTypeLabel setImage:nil forState:UIControlStateNormal];
        _detailTitleLabel.text = NSLocalizedString(@"交易单号",nil);
        
    }else{
        preTitleStr = @"";
        _statusImage = nil;
        [_payTypeLabel setTitle:preTitleStr forState:UIControlStateNormal];
        [_payTypeLabel setImage:[UIImage imageNamed:@"alipay_small_icon"] forState:UIControlStateNormal];
        _detailTitleLabel.text = NSLocalizedString(@"支付宝流水号",nil);

    }
    CGSize titleLabelSize = [_detailTitleLabel.text sizeWithAttributes:@{NSFontAttributeName:_detailTitleLabel.font}];
    [_detailTitleLabel setConstraintConstant:titleLabelSize.width+1 forAttribute:NSLayoutAttributeWidth];
    
    _redDotView.hidden = YES;
    [_redDotView setConstraintConstant:0 forAttribute:NSLayoutAttributeWidth];
    if( [_noteModel.payType integerValue] == 0){
        _detailTitleLabel3.text = NSLocalizedString(@"添加时间",nil);
        _detailTitleLabel4.text = NSLocalizedString(@"确认时间",nil);
        _outTradeNoLabel.text = _noteModel.outTradeNo;
        _payMethodLabel.text = NSLocalizedString(@"线下支付",nil);
        _payTimerLabel.text = getShowDateByFormatAndTimeInterval(@"yyyy-MM-dd HH:mm:ss",[_noteModel.createTime stringValue]);
        if(_noteModel.modifyTime == nil){
            _getTimerLabel.text = @"";
        }else{
            _getTimerLabel.text = getShowDateByFormatAndTimeInterval(@"yyyy-MM-dd HH:mm:ss",[_noteModel.modifyTime stringValue]);;
        }
        _getTimerLabel.textColor = [UIColor colorWithHex:@"919191"];
        
        _detailView.hidden = NO;
        
        _cancelBtn.layer.borderWidth = 1;
        _cancelBtn.layer.borderColor = [UIColor blackColor].CGColor;
        _makeSureBtn.hidden = YES;
        _makeSureBtn.enabled = YES;
        _makeSureBtn.backgroundColor = [UIColor blackColor];
        _cancelBtn.hidden = YES;
        _deleteBtn.hidden = YES;
        [_statusLabel setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        if(statusValue == 0){//支付状态(线下) 0:待确认 1：成功到账 2：已作废
            [_statusLabel setImage:nil forState:UIControlStateNormal];
            [_statusLabel setTitleColor:[UIColor colorWithHex:@"ef4e31"] forState:UIControlStateNormal];
            [_statusLabel setTitle:NSLocalizedString(@"待确认",nil) forState:UIControlStateNormal];
            CGSize size = [_statusLabel.currentTitle sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13]}];
            [_statusLabel setConstraintConstant:(size.width+8) forAttribute:NSLayoutAttributeWidth];
            _redDotView.layer.cornerRadius = 3;
            _redDotView.hidden = NO;
            [_redDotView setConstraintConstant:6 forAttribute:NSLayoutAttributeWidth];
            
            _oprateView.hidden = NO;
            _makeSureBtn.hidden = NO;
            if(([_noteModel.tmpPercent floatValue] + [_noteModel.realPercent floatValue]) >100){
                _makeSureBtn.enabled = NO;
                _makeSureBtn.backgroundColor = [UIColor colorWithHex:@"d3d3d3"];

            }
            _cancelBtn.hidden = NO;
        }else if(statusValue == 1){
            [_statusLabel setImage:nil forState:UIControlStateNormal];
            [_statusLabel setTitleColor:[UIColor colorWithHex:@"58c776"] forState:UIControlStateNormal];
            [_statusLabel setTitle:NSLocalizedString(@"成功到账",nil) forState:UIControlStateNormal];
            [_statusLabel setConstraintConstant:148 forAttribute:NSLayoutAttributeWidth];
            _oprateView.hidden = YES;
        }else if(statusValue == 2){

            [_statusLabel setImage:[[UIImage imageNamed:@"cancel"] imageWithTintColor:[UIColor colorWithHex:@"919191"]] forState:UIControlStateNormal];
            [_statusLabel setTitleColor:[UIColor colorWithHex:@"919191"] forState:UIControlStateNormal];
            [_statusLabel setTitle:NSLocalizedString(@"已作废",nil) forState:UIControlStateNormal];
            [_statusLabel setConstraintConstant:148 forAttribute:NSLayoutAttributeWidth];
            [_statusLabel setTitleEdgeInsets:UIEdgeInsetsMake(0, 7, 0, 0)];
            _oprateView.hidden = NO;
            _deleteBtn.hidden = NO;
            _detailTitleLabel4.text = NSLocalizedString(@"作废时间",nil);

        }
    }else{
        
        _detailTitleLabel3.text = NSLocalizedString(@"付款时间",nil);
        _detailTitleLabel4.text = NSLocalizedString(@"到账时间",nil);

        NSString *payTimer = @"";
        if(_noteModel.onlinePayDetail.payTime){
            payTimer = getShowDateByFormatAndTimeInterval(@"yyyy-MM-dd HH:mm:ss",_noteModel.onlinePayDetail.payTime);
        }
        NSString *getTimer = @"";
        if(_noteModel.onlinePayDetail.accountTime){
            getTimer = getShowDateByFormatAndTimeInterval(@"yyyy-MM-dd HH:mm:ss",_noteModel.onlinePayDetail.accountTime);
        }
        
        _outTradeNoLabel.text = _noteModel.onlinePayDetail.tradeNo;
        if(_noteModel.onlinePayDetail){
            if([_noteModel.onlinePayDetail.payChannel integerValue] == 0){
                _payMethodLabel.text = NSLocalizedString(@"支付宝pc端支付",nil);
            }else if ([_noteModel.onlinePayDetail.payChannel integerValue] == 1){
                _payMethodLabel.text = NSLocalizedString(@"支付宝移动支付",nil);
            }
        }else{
            _payMethodLabel.text = @"";
        }
        
        _payTimerLabel.text = payTimer;
        if([getTimer isEqualToString:@""]){
            _getTimerLabel.text = NSLocalizedString(@"请耐心等待2-3个工作日到账",nil);
            _getTimerLabel.textColor = [UIColor colorWithHex:@"58c776"];
        }else{
            _getTimerLabel.text = getTimer;
            _getTimerLabel.textColor = [UIColor colorWithHex:@"919191"];
        }
        _detailView.hidden = NO;
        _oprateView.hidden = YES;
        
        [_statusLabel setConstraintConstant:148 forAttribute:NSLayoutAttributeWidth];
        [_statusLabel setTitleColor:[UIColor colorWithHex:@"58c776"] forState:UIControlStateNormal];
        [_statusLabel setImage:nil forState:UIControlStateNormal];
        
        [_statusLabel setTitle:NSLocalizedString(@"已付款，货款审核中",nil) forState:UIControlStateNormal];
        if([_noteModel.payStatus integerValue] == 1 && _noteModel.onlinePayDetail && [_noteModel.onlinePayDetail.transStatus integerValue] == 2){
            if(_noteModel.onlinePayDetail.accountTime !=nil){
                [_statusLabel setTitle:NSLocalizedString(@"成功到账",nil) forState:UIControlStateNormal];
            }else{
                [_statusLabel setTitle:@"" forState:UIControlStateNormal];
            }
        }
        
    }
    if(_detailIndexPath == nil || _detailIndexPath.row != _indexPath.row){
        _detailView.hidden = YES;
        _oprateView.hidden = YES;
        _statusTxt = NSLocalizedString(@"详情",nil);
    }else{
        _statusTxt = NSLocalizedString(@"收起",nil);
    }
    [_statusBtn setImage:_statusImage forState:UIControlStateNormal];
    [_statusBtn setAttributedTitle:[[NSAttributedString alloc] initWithString: _statusTxt attributes: @{ NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle),NSForegroundColorAttributeName:[UIColor colorWithHex:@"47a3dc"]}] forState:UIControlStateNormal];

    preTitleStr = NSLocalizedString(@"收款",nil);
    NSString *percent = [NSString stringWithFormat:@"%.2lf%@",[_noteModel.realPercent floatValue],@"%"];//;
    NSString *titleStr = [NSString stringWithFormat:@"%@ %@ ￥%0.2f",preTitleStr,percent,[_noteModel.amount floatValue]];
    NSRange range = [titleStr rangeOfString:percent];
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:titleStr];
    if(range.location != NSNotFound){
        [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHex:@"ed6498"] range:range];
        [attrStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15] range:range];

    }
    range = [titleStr rangeOfString:preTitleStr];
    if(range.location != NSNotFound){
        [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHex:@"919191"] range:range];
    }
    
    _titleLabel.attributedText = attrStr;
    _timerLabel.text = getShowDateByFormatAndTimeInterval(@"yyyy-MM-dd HH:mm:ss",[_noteModel.createTime stringValue]);

}
#pragma mark - SomeAction
- (IBAction)makeSureBtnHandler:(id)sender {
    if(self.delegate){
        [self.delegate btnClick:_indexPath.row section:_indexPath.section andParmas:@[@"makesure"]];
    }
}

- (IBAction)cancelBtnHandler:(id)sender {
    if(self.delegate){
        [self.delegate btnClick:_indexPath.row section:_indexPath.section andParmas:@[@"cancel"]];
    }
}

- (IBAction)deleteBtnHandler:(id)sender {
    if(self.delegate){
        [self.delegate btnClick:_indexPath.row section:_indexPath.section andParmas:@[@"delete"]];
    }
}
#pragma mark - Other
- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}
@end

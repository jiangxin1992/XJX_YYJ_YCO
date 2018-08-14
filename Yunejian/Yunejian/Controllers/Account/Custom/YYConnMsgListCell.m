//
//  YYConnMsgListCell.m
//  Yunejian
//
//  Created by Apple on 15/12/2.
//  Copyright © 2015年 yyj. All rights reserved.
//

#import "YYConnMsgListCell.h"

// c文件 —> 系统文件（c文件在前）

// 控制器

// 自定义视图
#import "SCGIFImageView.h"

// 接口

// 分类

// 自定义类和三方类（ cocoapods类 > model > 工具类 > 其他）
#import "YYUser.h"
#import "YYOrderMessageInfoModel.h"

@interface YYConnMsgListCell()

@property (weak, nonatomic) IBOutlet SCGIFImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIButton *agreeBtn;
@property (weak, nonatomic) IBOutlet UIButton *refuseBtn;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@property (weak, nonatomic) IBOutlet UIImageView *bottomView;
@property (weak, nonatomic) IBOutlet UIView *readFlagView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelLayoutTopConstraint;

@end

@implementation YYConnMsgListCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (IBAction)agressBtnHandler:(id)sender {
    if(self.delegate){
        [self.delegate btnClick:_indexPath.row section:_indexPath.section andParmas:@[@(1)]];
    }
}

- (IBAction)refuseBtnHandler:(id)sender {
    if(self.delegate){
        [self.delegate btnClick:_indexPath.row section:_indexPath.section andParmas:@[@(2)]];
    }
}

-(void)updateUI{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.refuseBtn.layer.borderColor = [UIColor blackColor].CGColor;
    self.refuseBtn.layer.borderWidth = 1;
    
    self.userImageView.layer.borderColor = [UIColor colorWithHex:kDefaultImageColor].CGColor;
    self.userImageView.layer.borderWidth = 1;
    //info
    _readFlagView.layer.borderColor = [UIColor whiteColor].CGColor;
    _readFlagView.layer.borderWidth = 2;
    _readFlagView.layer.cornerRadius = CGRectGetWidth(_readFlagView.frame)/2;
    _readFlagView.layer.masksToBounds = YES;
    
    _timeLabel.text = getShowDateByFormatAndTimeInterval(@"yyyy/MM/dd HH:mm",[_msgInfoModel.sendTime stringValue]);
    
    if(_msgInfoModel && _msgInfoModel.msgContent){
        sd_downloadWebImageWithRelativePath(NO, _msgInfoModel.msgContent.buyerLogo, self.userImageView, kLogoCover, 0);
    }else{
        sd_downloadWebImageWithRelativePath(NO, @"", self.userImageView, kLogoCover, 0);
        
    }

    if(_msgInfoModel.isRead == NO){
        _titleLabel.font = [UIFont boldSystemFontOfSize:14];
        _titleLabel.textColor = [UIColor blackColor];
        _readFlagView.hidden = NO;
     }else{
        _titleLabel.font = [UIFont systemFontOfSize:14];
        _titleLabel.textColor = [UIColor colorWithHex:kDefaultTitleColor_pad];
        _readFlagView.hidden = YES;
    }

    _titleLabel.text = _msgInfoModel.msgTitle;
    _emailLabel.text = @"";
    if(_msgInfoModel.isPlainMsg == NO){
        if([_msgInfoModel.dealStatus integerValue] == -1){
            _agreeBtn.hidden = NO;
            _refuseBtn.hidden = NO;
            _tipLabel.hidden = YES;
            _titleLabelLayoutTopConstraint.constant = 20;
        }else{
            _agreeBtn.hidden = YES;
            _refuseBtn.hidden = YES;
            if([_msgInfoModel.msgType integerValue]== 0){//case 1: //合作分享消息
                _tipLabel.hidden = NO;
                if([_msgInfoModel.dealStatus integerValue]== 1){
                    _tipLabel.text = NSLocalizedString(@"已同意",nil);
                    _tipLabel.textColor = [UIColor colorWithHex:@"58c776"];
                }else if([_msgInfoModel.dealStatus integerValue]== 2){
                    _tipLabel.text = NSLocalizedString(@"已拒绝",nil);
                    _tipLabel.textColor = [UIColor colorWithHex:@"ef4e31"];
                }else if([_msgInfoModel.dealStatus integerValue]==4){
                    _tipLabel.text = NSLocalizedString(@"对方已撤销邀请",nil);
                    _tipLabel.textColor = [UIColor colorWithHex:@"ef4e31"];
                }
            }else{
                _tipLabel.hidden = YES;
            }
            _titleLabelLayoutTopConstraint.constant = 30;
        }
    }else{
        _agreeBtn.hidden = YES;
        _refuseBtn.hidden = YES;
        _tipLabel.hidden = YES;

        //同意 移除 拒绝
        NSArray *titleArr = [_msgInfoModel.msgTitle componentsSeparatedByString:@"，"];
        if([titleArr count] == 2){
            _titleLabel.attributedText = [self getTextAttributedString:[titleArr objectAtIndex:0] replaceStrs:@[NSLocalizedString(@"同意",nil)] replaceColors:@[@"58c776"]];//[NSString stringWithFormat:@"%@ 了您的合作邀请"];
            _emailLabel.text = [titleArr objectAtIndex:1];//@"可以在“合作买手店”中查看";
            _titleLabelLayoutTopConstraint.constant = 30;
        }else if([titleArr count] == 1){
            _titleLabel.attributedText = [self getTextAttributedString:[titleArr objectAtIndex:0] replaceStrs:@[
                                                                                                                [LanguageManager isEnglishLanguage]?@"accepted":NSLocalizedString(@"同意",nil)
                                                                                                                ,[LanguageManager isEnglishLanguage]?@"rejected":NSLocalizedString(@"拒绝",nil)
                                                                                                                ,[LanguageManager isEnglishLanguage]?@"disconnected":NSLocalizedString(@"解除",nil)
                                                                                                                ] replaceColors:@[@"58c776",@"ef4e31",@"ef4e31"]];
            _emailLabel.text = @"";
            _titleLabelLayoutTopConstraint.constant = 47;
        }else{
            _titleLabel.text = _msgInfoModel.msgTitle;
            _emailLabel.text = @"";
            _titleLabelLayoutTopConstraint.constant = 47;
        }

    }
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
@end

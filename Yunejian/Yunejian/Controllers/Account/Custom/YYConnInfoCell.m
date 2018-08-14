//
//  YYConnInfoCell.m
//  Yunejian
//
//  Created by Apple on 15/12/1.
//  Copyright © 2015年 yyj. All rights reserved.
//

#import "YYConnInfoCell.h"

@implementation YYConnInfoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)updateUIWithShowType:(ConnInfoCellShowType )showType{
    _keyLabel.text = @"";
    _valueLabel.text = @"";
    [self setTranslatesAutoresizingMaskIntoConstraints:YES];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    switch (showType) {
        case ConnInfoCellShowTypeNum:{
            _keyLabel.text = NSLocalizedString(@"我的买手店",nil);
            NSInteger num1 = [[_infoArr objectAtIndex:0] integerValue];
            NSInteger num2 = [[_infoArr objectAtIndex:1] integerValue];

            NSString *numStr1 = (num1>0?[NSString stringWithFormat:@" %ld",(long)num1]:@"");
            NSString *numStr2 = (num2>0?[NSString stringWithFormat:@" %ld",(long)num2]:@"");

            _valueLabel.text = [NSString stringWithFormat:NSLocalizedString(@"已合作的买手店%@   |   邀请中的买手店%@",nil),numStr1,numStr2];
            _valueView.hidden = YES;
            _valueLabel.hidden = NO;
        }
            break;
        case ConnInfoCellShowTypeMessage:{
            _keyLabel.text = NSLocalizedString(@"合作消息_pad",nil);
            _valueLabel.hidden = YES;
            UILabel *readLabel = [_valueView viewWithTag:10001];
            [readLabel setAdjustsFontSizeToFitWidth:YES];
            NSInteger num = [[_infoArr objectAtIndex:0] integerValue];
            if(num > 0){
                _valueView.hidden = NO;
                _msgNumLabel.text = [NSString stringWithFormat:@"%ld",(long)num];
            }else{
                _valueView.hidden = YES;
            }
        }
            break;
        default:
            break;
    }

}
@end

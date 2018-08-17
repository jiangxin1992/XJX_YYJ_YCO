//
//  YYOrderDetailSectionHead.m
//  Yunejian
//
//  Created by Apple on 15/8/17.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import "YYOrderDetailSectionHead.h"

@interface YYOrderDetailSectionHead ()

@property (weak, nonatomic) IBOutlet UILabel *seriesLabel;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@property (weak, nonatomic) IBOutlet UILabel *deliverGoodsLabel;//发货

@property (weak, nonatomic) IBOutlet UIView *selectDateView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *countLabelLayoutRightConstraint;

@end

@implementation YYOrderDetailSectionHead

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)updateUI{
    UILabel *titlelabel1 = [self.contentView viewWithTag:10001];
    [titlelabel1 setAdjustsFontSizeToFitWidth:YES];
    UILabel *titlelabel2 = [self.contentView viewWithTag:10002];
    [titlelabel2 setAdjustsFontSizeToFitWidth:YES];
    UILabel *titlelabel3 = [self.contentView viewWithTag:10003];
    [titlelabel3 setAdjustsFontSizeToFitWidth:YES];
    UILabel *titlelabel4 = [self.contentView viewWithTag:10004];
    [titlelabel4 setAdjustsFontSizeToFitWidth:YES];
    
    if(![_orderOneInfoModel isInStock]){
        NSString *rangeTimer = [NSString stringWithFormat:@"%@-%@",getShowDateByFormatAndTimeInterval(@"yyyy/MM/dd",[_orderOneInfoModel.dateRange.start stringValue]),getShowDateByFormatAndTimeInterval(@"yyyy/MM/dd",[_orderOneInfoModel.dateRange.end stringValue])];
        NSString *titleStr = [NSString stringWithFormat:@"%@：%@  %@", NSLocalizedString(@"发货波段",nil),_orderOneInfoModel.dateRange.name,rangeTimer];
        NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:titleStr];
        NSRange range = [titleStr rangeOfString:rangeTimer];
        if(range.location != NSNotFound){
            [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHex:@"919191"] range:range];
        }
        _seriesLabel.attributedText = attrStr;
        
        int styles = 0;
        int totals = 0;
        if (_orderOneInfoModel.styles) {
            styles = [_orderOneInfoModel.styles count];
            
            for (int i=0; i< [_orderOneInfoModel.styles count]; i++) {
                YYOrderStyleModel *orderStyleModel = [_orderOneInfoModel.styles objectAtIndex:i];
                int tempTotal = calculateTotalsForOneStyle(orderStyleModel);
                if (tempTotal > 0) {
                    totals += tempTotal;
                }
            }
            
        }
        _countLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%i款 %i件",nil),styles,totals];
    }else{
        NSString *note = self.orderSeriesModel.note;
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"发货方式：", nil) attributes:@{NSForegroundColorAttributeName : [UIColor lightGrayColor]}];
        [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"现货", nil)]];
        [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:@"  "]];
        [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"发货日期：", nil) attributes:@{NSForegroundColorAttributeName : [UIColor lightGrayColor]}]];
        [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString isNilOrEmpty:note] ? NSLocalizedString(@"马上发货", nil) : note]];
        self.seriesLabel.attributedText = attributedString;
        self.countLabel.text = nil;
    }
}



@end

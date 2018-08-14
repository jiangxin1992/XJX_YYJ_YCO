//
//  YYSeriesInfoViewCell.m
//  Yunejian
//
//  Created by Apple on 15/12/3.
//  Copyright © 2015年 yyj. All rights reserved.
//

#import "YYSeriesInfoViewCell.h"

@implementation YYSeriesInfoViewCell
- (IBAction)detailBtnHamdler:(id)sender {
    _detailBtn.selected = !_detailBtn.selected;
    if (self.delegate) {
        NSString *descStr = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@",_seriesDescription,_seriesDescription,_seriesDescription,_seriesDescription,_seriesDescription,_seriesDescription,_seriesDescription,_seriesDescription];//_seriesDescription;
        NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
        paraStyle.lineHeightMultiple = 1.2;
        NSDictionary *attrDict = @{ NSParagraphStyleAttributeName: paraStyle,
                                    NSFontAttributeName: [UIFont systemFontOfSize: 12] };
        CGSize textSize = [descStr sizeWithAttributes:attrDict];
        float textTotalWidth = textSize.width;
        NSInteger cellWidth = CGRectGetWidth(_descLabel.frame);
        NSInteger rowNum = ceilf(textTotalWidth/cellWidth);
        float textTotalHeight = rowNum * ceilf(textSize.height);
        //CGPoint point= CGPointMake(100, 100);
        UIViewController *parent = [UIApplication sharedApplication].keyWindow.rootViewController;
        CGPoint point = [_descLabel convertPoint:CGPointMake(0, 0) toView:parent.view];
        
        [self.delegate btnClick:_indexPath.row section:_indexPath.section andParmas:@[attrDict,descStr,@(cellWidth),@(textTotalHeight),@(point.x),@(point.y)]];
    }
}

-(void)updateUI{
    if (_seriesModel != nil) {
        _nameLabel.text = _seriesModel.name;
        _styleAmountLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@款",nil),[_seriesModel.styleAmount stringValue]];
        _seasonLabel.text = [NSString stringWithFormat:@"Season:%@",_seriesModel.season];
        
        _supplyTimeLabel.text = [NSString stringWithFormat:NSLocalizedString(@"发货日期：%@-%@",nil),getShowDateByFormatAndTimeInterval(@"yyyy-MM-dd HH:mm:ss",[_seriesModel.supplyStartTime stringValue]),getShowDateByFormatAndTimeInterval(@"yyyy-MM-dd HH:mm:ss",[_seriesModel.supplyEndTime stringValue])];
       
        _orderDueTimeLabel.text = [NSString stringWithFormat:NSLocalizedString(@"最晚下单：%@",nil),getShowDateByFormatAndTimeInterval(@"yyyy-MM-dd HH:mm:ss",_seriesModel.orderDueTime)];
        sd_downloadWebImageWithRelativePath(NO, _seriesModel.albumImg, _logoImageView, kStyleCover, 0);
        //_descLabel.text = _seriesDescription;
        NSString *descStr = _seriesDescription;//[NSString stringWithFormat:@"%@%@%@%@",_seriesDescription,_seriesDescription,_seriesDescription,_seriesDescription];//_seriesDescription;
        NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
        paraStyle.lineHeightMultiple = 1.2;
        NSDictionary *attrDict = @{ NSParagraphStyleAttributeName: paraStyle,
                                    NSFontAttributeName: [UIFont systemFontOfSize: 12] };
        CGSize textSize = [descStr sizeWithAttributes:attrDict];
        NSInteger cellWidth = CGRectGetWidth(_descLabel.frame);
        if(textSize.width > cellWidth*3){
            _detailBtn.hidden = NO;
        }else{
            _detailBtn.hidden = YES;
            if(textSize.width < cellWidth){
                descStr = [descStr stringByAppendingString:@"\n"];
            }
            if(textSize.width < cellWidth*2){
                descStr = [descStr stringByAppendingString:@"\n"];
            }
        }
        _descLabel.attributedText = [[NSAttributedString alloc] initWithString: descStr attributes: attrDict];

        
    }else{
        _nameLabel.text = @"";
        _styleAmountLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@款",nil),@"0"];
        _seasonLabel.text = [NSString stringWithFormat:@"Season:%@",@""];
        _supplyTimeLabel.text = [NSString stringWithFormat:NSLocalizedString(@"发货日期：%@-%@",nil),@"",@""];
        _orderDueTimeLabel.text = [NSString stringWithFormat:NSLocalizedString(@"最晚下单：%@",nil),@""];
        _descLabel.text = @"";
        sd_downloadWebImageWithRelativePath(NO, @"", _logoImageView, kStyleCover, 0);
        
 
    }
}
@end

//
//  YYSeriesListViewCell.m
//  Yunejian
//
//  Created by Apple on 15/12/4.
//  Copyright © 2015年 yyj. All rights reserved.
//

#import "YYSeriesListViewCell.h"

@implementation YYSeriesListViewCell
-(void)updateUI{
    if (_seriesModel != nil) {
        _nameLabel.text = _seriesModel.name;
        _styleAmountLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@款",nil),[_seriesModel.styleAmount stringValue]];
        _seasonLabel.text = [NSString stringWithFormat:@"Season:%@",_seriesModel.season];
        _supplyTimeLabel.text = [NSString stringWithFormat:NSLocalizedString(@"发货日期：%@-%@",nil),getShowDateByFormatAndTimeInterval(@"yyyy/MM/dd",[_seriesModel.supplyStartTime stringValue]),getShowDateByFormatAndTimeInterval(@"yyyy/MM/dd",[_seriesModel.supplyEndTime stringValue])];
        _orderDueTimeLabel.text = [NSString stringWithFormat:NSLocalizedString(@"最晚下单：%@",nil),getShowDateByFormatAndTimeInterval(@"yyyy/MM/dd",_seriesModel.orderDueTime)];
        sd_downloadWebImageWithRelativePath(NO, _seriesModel.albumImg, _coverImageView, kStyleCover, 0);
    }else{
        _nameLabel.text = @"";
        _styleAmountLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@款",nil),@"0"];
        _seasonLabel.text = [NSString stringWithFormat:@"Season:%@",@""];
        _supplyTimeLabel.text = [NSString stringWithFormat:NSLocalizedString(@"发货日期：%@-%@",nil),@"",@""];
        _orderDueTimeLabel.text = [NSString stringWithFormat:NSLocalizedString(@"最晚下单：%@",nil),@""];
        sd_downloadWebImageWithRelativePath(NO, @"", _coverImageView, kStyleCover, 0);
    }
}
@end

//
//  StyleSummary.m
//  
//
//  Created by yyj on 15/8/5.
//
//

#import "StyleSummary.h"
#import "Series.h"
#import "StyleColors.h"

#import "YYOpusStyleModel.h"

@implementation StyleSummary

@dynamic album_img;
@dynamic category;
@dynamic designer_id;
@dynamic materials;
@dynamic name;
@dynamic order_amount_min;
@dynamic region;
@dynamic retail_price;
@dynamic series_id;
@dynamic size_cat_name;
@dynamic style_code;
@dynamic style_description;
@dynamic style_id;
@dynamic trade_price;
@dynamic colors;
@dynamic series;
@dynamic cur_type;
-(YYOpusStyleModel *)toOpusStyleModel{
    YYOpusStyleModel *opusStyleModel = [[YYOpusStyleModel alloc] init];
    if(self){
        opusStyleModel.albumImg = self.album_img;
        opusStyleModel.name = self.name;
        opusStyleModel.styleCode = self.style_code;
        opusStyleModel.seriesId = self.series_id;
        opusStyleModel.curType = self.cur_type;
        opusStyleModel.tradePrice = self.trade_price;
        opusStyleModel.retailPrice = self.retail_price;

        if(self.colors){
            NSMutableArray *colorArray = [[NSMutableArray alloc] init];
            NSEnumerator * enumerator = [self.colors objectEnumerator];
            YYColorModel * value;
            while (value = [enumerator nextObject]) {
                [colorArray addObject:value];
            }
            opusStyleModel.color = (NSArray<Optional,YYColorModel, ConvertOnDemand> *)colorArray;
            NSLog(@"111");
        }

        opusStyleModel.curType = self.cur_type;
        opusStyleModel.tradePrice = self.trade_price;
        opusStyleModel.curType = self.cur_type;
        opusStyleModel.tradePrice = self.trade_price;

        opusStyleModel.dateRange = transferToYYDateRangeModel(self.date_range);
    }
    return opusStyleModel;
}
@end

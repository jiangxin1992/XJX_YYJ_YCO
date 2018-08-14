//
//  StyleSummary.h
//  
//
//  Created by yyj on 15/8/5.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Series,StyleColors,StyleDateRange,YYOpusStyleModel;

@interface StyleSummary : NSManagedObject

@property (nonatomic, retain) NSString * album_img;
@property (nonatomic, retain) NSString * category;
@property (nonatomic, retain) NSNumber * designer_id;
@property (nonatomic, retain) NSString * materials;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * order_amount_min;
@property (nonatomic, retain) NSString * region;
@property (nonatomic, retain) NSNumber * retail_price;
@property (nonatomic, retain) NSNumber * series_id;
@property (nonatomic, retain) NSString * size_cat_name;
@property (nonatomic, retain) NSString * style_code;
@property (nonatomic, retain) NSString * style_description;
@property (nonatomic, retain) NSNumber * style_id;
@property (nonatomic, retain) NSNumber * trade_price;
@property (nonatomic, retain) NSSet *colors;
@property (nonatomic, retain) Series *series;
@property (strong, nonatomic) NSNumber *cur_type;//货币类型
@property (strong, nonatomic) NSNumber *date_range_id;
@property (strong, nonatomic) StyleDateRange *date_range;

@end

@interface StyleSummary (CoreDataGeneratedAccessors)

- (YYOpusStyleModel *)toOpusStyleModel;

@end

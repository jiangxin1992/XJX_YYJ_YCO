//
//  StyleDetail.h
//  
//
//  Created by yyj on 15/9/2.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class StyleDeatilSizes, StyleDetailColors,StyleDateRange;

@interface StyleDetail : NSManagedObject

@property (nonatomic, retain) NSString * albumImg;
@property (nonatomic, retain) NSString * category;
@property (nonatomic, retain) NSNumber * designerId;
@property (nonatomic, retain) NSString * materials;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * orderAmountMin;
@property (nonatomic, retain) NSString * region;
@property (nonatomic, retain) NSNumber * retailPrice;
@property (nonatomic, retain) NSString * sizeCatName;
@property (nonatomic, retain) NSString * style_description;
@property (nonatomic, retain) NSNumber * style_id;
@property (nonatomic, retain) NSString * styleCode;
@property (nonatomic, retain) NSNumber * tradePrice;
@property (nonatomic, retain) NSNumber * modifyTime;
@property (nonatomic, retain) NSSet *colors;
@property (nonatomic, retain) NSSet *sizes;
@property (strong, nonatomic) NSNumber *cur_type;//货币类型
@property (strong, nonatomic) NSNumber *daterange_id;
@property (strong, nonatomic) StyleDateRange *date_range;
@property (strong, nonatomic) NSNumber *series_id;
@property (strong, nonatomic) NSNumber *series_status;
@property (nonatomic, retain) NSString *note;
@property (nonatomic, retain) NSNumber *stockEnabled;

@end

@interface StyleDetail (CoreDataGeneratedAccessors)

- (void)addColorsObject:(StyleDetailColors *)value;
- (void)removeColorsObject:(StyleDetailColors *)value;
- (void)addColors:(NSSet *)values;
- (void)removeColors:(NSSet *)values;

- (void)addSizesObject:(StyleDeatilSizes *)value;
- (void)removeSizesObject:(StyleDeatilSizes *)value;
- (void)addSizes:(NSSet *)values;
- (void)removeSizes:(NSSet *)values;

@end

//
//  Series+CoreDataProperties.h
//  Yunejian
//
//  Created by Apple on 16/5/17.
//  Copyright © 2016年 yyj. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Series.h"

NS_ASSUME_NONNULL_BEGIN

@interface Series (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *album_img;
@property (nullable, nonatomic, retain) NSNumber *auth_type;
@property (nullable, nonatomic, retain) NSNumber *designer_id;
@property (nullable, nonatomic, retain) NSNumber *lookBookId;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *note;
@property (nullable, nonatomic, retain) NSString *order_due_time;
@property (nullable, nonatomic, retain) NSString *season;
@property (nullable, nonatomic, retain) NSString *series_description;
@property (nullable, nonatomic, retain) NSNumber *series_id;
@property (nullable, nonatomic, retain) NSNumber *styleAmount;
@property (nullable, nonatomic, retain) NSString *supply_end_time;
@property (nullable, nonatomic, retain) NSString *supply_start_time;
@property (nullable, nonatomic, retain) NSNumber *supply_status;
@property (nullable, nonatomic, retain) NSNumber *status;
@property (nullable, nonatomic, retain) NSNumber *year;
@property (nullable, nonatomic, retain) NSSet<StyleSummary *> *style;
@property (nullable, nonatomic, retain) NSSet<StyleDateRange* > *daterangs;
@property (nullable, nonatomic, retain) NSNumber *date_range_amount;
@property (nullable, nonatomic, retain) NSNumber *order_amount_min;
@property (nullable, nonatomic, retain) NSString *region;
@property (nullable, nonatomic, retain) NSString *brand_id;
@property (nonatomic, assign) BOOL stock_enabled;
@end

@interface Series (CoreDataGeneratedAccessors)

- (void)addStyleObject:(StyleSummary *)value;
- (void)removeStyleObject:(StyleSummary *)value;
- (void)addStyle:(NSSet<StyleSummary *> *)values;
- (void)removeStyle:(NSSet<StyleSummary *> *)values;

- (void)addDaterangsObject:(StyleDateRange *)value;
- (void)removeDaterangsObject:(StyleDateRange *)value;
- (void)addDaterangs:(NSSet<StyleDateRange *> *)values;
- (void)removeDaterangs:(NSSet<StyleDateRange *> *)values;

@end

NS_ASSUME_NONNULL_END

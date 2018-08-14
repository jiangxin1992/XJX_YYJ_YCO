//
//  Series.h
//  
//
//  Created by yyj on 15/8/5.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
NS_ASSUME_NONNULL_BEGIN
@class StyleSummary;
@class StyleDateRange;
@interface Series : NSManagedObject

//@property (nonatomic, retain) NSString * album_img;
//@property (nonatomic, retain) NSNumber * auth_type;
//@property (nonatomic, retain) NSNumber * lookBookId;
//@property (nonatomic, retain) NSNumber * designer_id;
//@property (nonatomic, retain) NSString * name;
//@property (nonatomic, retain) NSString * note;
//@property (nonatomic, retain) NSString * order_due_time;
//@property (nonatomic, retain) NSString * season;
//@property (nonatomic, retain) NSString * series_description;
//@property (nonatomic, retain) NSNumber * series_id;
//@property (nonatomic, retain) NSNumber * styleAmount;
//@property (nonatomic, retain) NSString * supply_end_time;
//@property (nonatomic, retain) NSString * supply_start_time;
//@property (nonatomic, retain) NSNumber * supply_status;
//@property (nonatomic, retain) NSNumber * year;
//@property (nonatomic, retain) NSSet *style;
//@end
//
//@interface Series (CoreDataGeneratedAccessors)
//
//- (void)addStyleObject:(StyleSummary *)value;
//- (void)removeStyleObject:(StyleSummary *)value;
//- (void)addStyle:(NSSet *)values;
//- (void)removeStyle:(NSSet *)values;

@end
NS_ASSUME_NONNULL_END
#import "Series+CoreDataProperties.h"
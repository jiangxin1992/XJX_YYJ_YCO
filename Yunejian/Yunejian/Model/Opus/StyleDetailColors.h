//
//  StyleDetailColors.h
//  
//
//  Created by yyj on 15/8/5.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class StyleDetail, StyleDetailColorImages;

@interface StyleDetailColors : NSManagedObject

@property (nonatomic, retain) NSString * color_name;
@property (nonatomic, retain) NSString * color_value;
@property (nonatomic, retain) NSNumber * style_id;
@property (nonatomic, retain) NSNumber * color_id;
@property (nonatomic, retain) NSSet *images;
@property (nonatomic, retain) NSString *style_code;//编号
@property (nonatomic, retain) NSString *materials;//材质
@property (nonatomic, retain) NSNumber *trade_price;//批发价
@property (nonatomic, retain) NSNumber *retail_price;//零售价
@property (nonatomic, retain) NSNumber *stock;//库存数
@property (nonatomic, retain) id size_stocks;//各尺码库存数

@property (nonatomic, retain) StyleDetail *style;
@end

@interface Size_stocks : NSValueTransformer
@end

@interface StyleDetailColors (CoreDataGeneratedAccessors)

- (void)addImagesObject:(StyleDetailColorImages *)value;
- (void)removeImagesObject:(StyleDetailColorImages *)value;
- (void)addImages:(NSSet *)values;
- (void)removeImages:(NSSet *)values;

@end
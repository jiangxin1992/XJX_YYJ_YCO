//
//  StyleDeatilSizes.h
//  
//
//  Created by yyj on 15/8/5.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class StyleDetail;

@interface StyleDeatilSizes : NSManagedObject

@property (nonatomic, retain) NSString * size_value;
@property (nonatomic, retain) NSNumber * style_id;
@property (nonatomic, retain) NSNumber * size_id;
@property (nonatomic, retain) StyleDetail *style_size;
@end

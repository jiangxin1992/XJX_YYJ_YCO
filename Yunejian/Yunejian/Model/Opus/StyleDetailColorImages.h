//
//  StyleDetailColorImages.h
//  
//
//  Created by yyj on 15/8/5.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class StyleDetailColors;

@interface StyleDetailColorImages : NSManagedObject

@property (nonatomic, retain) NSString * color_name;
@property (nonatomic, retain) NSString * image_path;
@property (nonatomic, retain) NSNumber * style_id;
@property (nonatomic, retain) StyleDetailColors *color;

@end

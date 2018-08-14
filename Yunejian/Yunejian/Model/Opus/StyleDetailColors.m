//
//  StyleDetailColors.m
//  
//
//  Created by yyj on 15/8/5.
//
//

#import "StyleDetailColors.h"
#import "StyleDetail.h"
#import "StyleDetailColorImages.h"


@implementation StyleDetailColors

@dynamic color_name;
@dynamic color_value;
@dynamic style_id;
@dynamic color_id;
@dynamic images;
@dynamic style_code;
@dynamic materials;
@dynamic trade_price;
@dynamic retail_price;
@dynamic stock;
@dynamic size_stocks;
@dynamic style;

@end

@implementation Size_stocks

+ (Class)transformedValueClass {
    return [NSArray class];
}

+ (BOOL)allowsReverseTransformation {
    return YES;
}

- (id)transformedValue:(id)value {
    return [NSKeyedArchiver archivedDataWithRootObject:value];
}

- (id)reverseTransformedValue:(id)value {
    return [NSKeyedUnarchiver unarchiveObjectWithData:value];
}

@end

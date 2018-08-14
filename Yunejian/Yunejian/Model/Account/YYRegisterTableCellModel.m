//
//  YYRegisterTableCellModel.m
//  Yunejian
//
//  Created by Apple on 15/9/24.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import "YYRegisterTableCellModel.h"

@implementation YYRegisterTableCellModel
-(id)initWithParameters:(NSArray *)parameters{
    self.type = [[parameters objectAtIndex:0] integerValue];
    NSArray *data = [parameters objectAtIndex:1];

    self.info = data;
    
    return self;
}

@end

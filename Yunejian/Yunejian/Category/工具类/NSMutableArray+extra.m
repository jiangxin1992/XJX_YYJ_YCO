//
//  NSMutableArray+extra.m
//  yunejianDesigner
//
//  Created by yyj on 2017/10/13.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "NSMutableArray+extra.h"

@implementation NSMutableArray (extra)

- (BOOL )isNilOrEmpty{
    if (self)
    {
        if(self.count){
            return NO;
        }
    }
    return YES;
}

@end

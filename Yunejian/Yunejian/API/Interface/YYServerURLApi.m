//
//  YYServerURLApi.m
//  Yunejian
//
//  Created by Apple on 15/12/29.
//  Copyright © 2015年 yyj. All rights reserved.
//

#import "YYServerURLApi.h"
#import "YYRequestHelp.h"
@implementation YYServerURLApi
+(void)getAppServerURLWidth:(void (^)(NSString *serverURL,BOOL isNeedUpdate,NSError *error))block{
    // get URL
    NSString *requestURL = [kYYServerURL stringByAppendingString:@"/service/iosutil/hostUrl"];
    
    NSString *string = [NSString stringWithFormat:@"version=%@&type=tbPadDesignerApp",kYYCurrentVersion];
    NSData *body = [string dataUsingEncoding:NSUTF8StringEncoding];
    [YYRequestHelp executeRequest:requestURL requestCount:0 requestBody:body andBlock:^(id responseObject, NSError *error, id httpResponse) {
        if (responseObject) {
            BOOL isNeedUpdate = [[responseObject objectForKey:@"isNeedUpdate"] integerValue];
            block([responseObject objectForKey:@"host"],isNeedUpdate,error);
        }else{
            block(nil,NO,error);
        }
    }];
}
@end

//
//  YYRegisterTableCellInfoModel.m
//  Yunejian
//
//  Created by Apple on 15/9/24.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import "YYRegisterTableCellInfoModel.h"

#import "RegexKitLite.h"
#import "MJExtension.h"

@implementation YYRegisterTableCellInfoModel
-(id)initWithParameters:(NSArray *)parameters{
    if ([parameters count] == 1) {
        self.title = [parameters objectAtIndex:0];
    }else{
        self.propertyKey = [parameters objectAtIndex:0];
        self.ismust = [[parameters objectAtIndex:1] integerValue];
        self.title = [parameters objectAtIndex:2];
        self.tipStr = [parameters objectAtIndex:3];
        self.warnStr = [parameters objectAtIndex:4];
        
    }
    if([self.propertyKey isEqualToString:@"agreerule"]){
        self.value = @"checked";
    }else  if([self.propertyKey isEqualToString:@"brandFiles"]){
        self.value = @",";
    }else  if([self.propertyKey isEqualToString:@"storeImgs"]){
        self.value = @",,,,,,,";
    }else  if([self.propertyKey isEqualToString:@"pics"]){
        self.value = @",,";
    }else{
        self.value = @"";
    }
    return self;
}
-(id)initWithParameters:(NSArray *)parameters WithPhotoTitle:(NSString *)photoTitle{
    if ([parameters count] == 1) {
        self.title = [parameters objectAtIndex:0];
    }else{
        self.propertyKey = [parameters objectAtIndex:0];
        self.ismust = [[parameters objectAtIndex:1] integerValue];
        self.title = [parameters objectAtIndex:2];
        self.tipStr = [parameters objectAtIndex:3];
        self.warnStr = [parameters objectAtIndex:4];
        self.photoTitle = photoTitle;
    }
    if([self.propertyKey isEqualToString:@"agreerule"]){
        self.value = @"checked";
    }else  if([self.propertyKey isEqualToString:@"brandFiles"]){
        self.value = @",";
    }else  if([self.propertyKey isEqualToString:@"storeImgs"]){
        self.value = @",,,,,,,";
    }else  if([self.propertyKey isEqualToString:@"pics"]){
        self.value = @",,";
    }else{
        self.value = @"";
    }
    return self;
}
-(BOOL)checkWarn{
    if([self.propertyKey isEqualToString:@"userContactInfos"])
    {
        return !self.contactWarn;
//        if(self.contactInfosValue){
//            
//        }
//        for (int i=0; i<self.contactInfosValue.count; i++) {
//            
//        }
    }else if([self.propertyKey isEqualToString:@"userSocialInfos"])
    {
        return YES;
    }else
    {
        if(![NSString isNilOrEmpty:self.value])
        {
            if([self.propertyKey isEqualToString:@"password"]){
                if(self.passwordvalue != nil && ![self.passwordvalue isEqualToString:@""]){
                    if(![self.passwordvalue isEqualToString:self.value]){
                        return NO;
                    }
                }
            }else if([self.propertyKey isEqualToString:@"webUrl"]){
                return YES ;//[self.value isMatchedByRegex: @"[a-zA-z]+://[^\s]*"];
            }else if([self.propertyKey isEqualToString:@"phone"]){
                return YES;
            }else if([self.propertyKey isEqualToString:@"email"] || [self.propertyKey isEqualToString:@"contactEmail"]){
                return [self.value  isMatchedByRegex:@"\\b([a-zA-Z0-9%_.+\\-]+)@([a-zA-Z0-9.\\-]+?\\.[a-zA-Z]{2,6})\\b"];
                
            }else if([self.propertyKey isEqualToString:@"brandFiles"] ){
                NSArray *valueArr = [self.value componentsSeparatedByString:@","];
                if([valueArr count] >=2 && ![[valueArr objectAtIndex:0] isEqualToString:@""] && ![[valueArr objectAtIndex:1] isEqualToString:@""]){
                    return YES;
                }else{
                    return NO;
                }
            }else if([self.propertyKey isEqualToString:@"storeImgs"] ){
                NSArray *valueArr = [self.value componentsSeparatedByString:@","];
                if([valueArr count] >=3 && ![[valueArr objectAtIndex:0] isEqualToString:@""] && ![[valueArr objectAtIndex:1] isEqualToString:@""]&& ![[valueArr objectAtIndex:2] isEqualToString:@""]){
                    return YES;
                }else{
                    return NO;
                }
            }else if([self.propertyKey isEqualToString:@"copBrands"] ){
                NSArray *valueArr = toArrayOrNSDictionary(self.value);//[self.value componentsSeparatedByString:@","];
                if([valueArr count] >=2 && ![[valueArr objectAtIndex:0] isEqualToString:@""] ){
                    return YES;
                }else{
                    return NO;
                }
            }
        }
    }
    return YES;
}
-(NSString *)getParamStr{
    if([self.propertyKey isEqualToString:@"city"]){//province city
        NSArray *valueArr = [self.value componentsSeparatedByString:@","];
        return [NSString stringWithFormat:@"province=%@&city=%@",[valueArr objectAtIndex:0],[valueArr objectAtIndex:1]];
    }
    if([self.propertyKey isEqualToString:@"brandFiles"]){//province city
        NSArray *valueArr = [self.value componentsSeparatedByString:@","];
        return [NSString stringWithFormat:@"personalBrandCert:%@,personalIdCard:%@",[valueArr objectAtIndex:0],[valueArr objectAtIndex:1]];
    }

    if([self.propertyKey isEqualToString:@"approach"]){
        NSArray *valueArr = [self.value componentsSeparatedByString:@"|"];
        NSMutableArray *tmpParamArr = [[NSMutableArray alloc] initWithCapacity:4];
        for (NSString * infoStr in valueArr) {
            if(![infoStr isEqualToString:@","]){
            NSArray * infoArr = [infoStr componentsSeparatedByString:@","];
            [tmpParamArr addObject:@{@"approach":[infoArr objectAtIndex:0],@"approachDetail":[infoArr objectAtIndex:1]}];
            }
        }
        NSError *error;
        NSData * JSONData = [NSJSONSerialization dataWithJSONObject:tmpParamArr
                                                            options:kNilOptions
                                                              error:&error];
        NSString *jsonStr = [[NSString alloc] initWithData:JSONData encoding:NSUTF8StringEncoding];
        return [NSString stringWithFormat:@"%@=%@",self.propertyKey,jsonStr];
    }

    if([self.propertyKey isEqualToString:@"pics"]){//province city
        
        NSArray *valueArr = [self.value componentsSeparatedByString:@","];
        NSMutableArray *tmpvalueArr = [[NSMutableArray alloc] init];
        for (NSString *tmpUrl in valueArr) {
            if(![NSString isNilOrEmpty:tmpUrl]){
                [tmpvalueArr addObject:tmpUrl];
            }
        }
        return [tmpvalueArr componentsJoinedByString:@","];
    }
    //社交类型
    if([self.propertyKey isEqualToString:@"userSocialInfos"])
    {
        return [NSString stringWithFormat:@"%@=%@",self.propertyKey,[self.socialInfosValue mj_JSONString]];
    }
    if([self.propertyKey isEqualToString:@"userContactInfos"])
    {
        NSString *value=[NSString stringWithFormat:@"%@=%@",self.propertyKey,[self.contactInfosValue mj_JSONString]];
        return value;
    }
    
    return [NSString stringWithFormat:@"%@=%@",self.propertyKey,self.value];
}

-(id)getValue{
    
    if([self.propertyKey isEqualToString:@"pics"]){//province city
        
        NSArray *valueArr = [self.value componentsSeparatedByString:@","];
        NSMutableArray *tmpvalueArr = [[NSMutableArray alloc] init];
        for (NSString *tmpUrl in valueArr) {
            if(![NSString isNilOrEmpty:tmpUrl]){
                [tmpvalueArr addObject:tmpUrl];
            }
        }
        return [tmpvalueArr componentsJoinedByString:@","];
    }
    //社交类型
    if([self.propertyKey isEqualToString:@"userSocialInfos"])
    {
        return self.socialInfosValue;
    }
    if([self.propertyKey isEqualToString:@"userContactInfos"])
    {
        return self.contactInfosValue;
    }
    if([self.propertyKey isEqualToString:@"retailerName"])
    {
        return [self.value mj_JSONObject];
    }
    return self.value;
}
@end

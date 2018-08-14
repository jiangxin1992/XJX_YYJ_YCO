//
//  YYUser.m
//  Yunejian
//
//  Created by yyj on 15/7/10.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import "YYUser.h"
#import "UserDefaultsMacro.h"
#import "JpushHandler.h"
#define kYYUsernameKey @"kYYUsernameKey"
#define kYYUserEmailKey @"kYYUserEmailKey"
#define kYYPasswordKey @"kYYPasswordKey"
#define kYYUserTypeKey @"kYYUserTypeKey"
#define kYYUserBrandIDKey @"kYYUserBrandIDKey"
#define kYYUserIdKey @"kYYUserIdKey"
#define kYYUserLogoKey @"kYYUserLogoKey"
#define kYYUserStatusKey @"kYYUserStatusKey"//根据 code 保存
#define kYYUserNewStatusKey @"kYYUserNewStatusKey"//根据接口保存

@implementation YYUser
static YYUser *currentUser = nil;


+(id)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        currentUser = [super allocWithZone:zone];
    });
    return currentUser;
}
/**
 * 判断当前用户角色是否是brand角色（showroom———>品牌）
 * 判断本地的kTempUserLoginTokenKey对应的有没有值
 * 有值返回true
 * 没有值返回false
 */
+(BOOL)isShowroomToBrand{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if([userDefaults objectForKey:kTempUserLoginTokenKey])
    {
        return YES;
    }
    return NO;
}
/**
 * 获取当前用户token
 * 通过isShowroomToBrand方法，判断是否是brand角色（showroom———>品牌）
 * 如果是、通过kTempUserLoginTokenKey获取token，并返回
 * 如果不是、通过kUserLoginTokenKey获取token，并返回
 */
+(NSString *)getToken{
    NSString *tokenValue = @"";
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if([YYUser isShowroomToBrand])
    {
        tokenValue = [userDefaults objectForKey:kTempUserLoginTokenKey];
    }else
    {
        tokenValue = [userDefaults objectForKey:kUserLoginTokenKey];
    }
    return tokenValue;
}
/**
 * 获取BrandID
 * 通过isShowroomToBrand方法，判断是否是brand角色（showroom———>品牌）
 * 如果是、通过kTempBrandID获取BrandID，并返回
 * 如果不是、通过kYYUserBrandIDKey获取BrandID，并返回
 */
+(NSString *)getBrandID{
    NSString *brandIDValue = @"";
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if([YYUser isShowroomToBrand])
    {
        brandIDValue = [userDefaults objectForKey:kTempBrandID];
    }else
    {
        brandIDValue = [userDefaults objectForKey:kYYUserBrandIDKey];
    }
    return brandIDValue;
}
/**
 * 清空 kTempUserLoginTokenKey、kTempBrandID
 * 其实就是使brand角色（showroom———>品牌）登出
 */
+ (void )removeTempUser
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults setObject:nil forKey:kTempUserLoginTokenKey];
    [userDefaults setObject:nil forKey:kTempBrandID];
    
    [userDefaults synchronize];
}
+ (YYUser *)currentUser
{
    
    if (!currentUser) {
        currentUser = [[self alloc] init];
    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    currentUser.name = [userDefaults objectForKey:kYYUsernameKey];
    currentUser.email = [userDefaults objectForKey:kYYUserEmailKey];
    currentUser.password = [userDefaults objectForKey:kYYPasswordKey];
    currentUser.userType = [userDefaults integerForKey:kYYUserTypeKey];
    currentUser.brandId = [userDefaults objectForKey:kYYUserBrandIDKey];
    currentUser.userId = [userDefaults objectForKey:kYYUserIdKey];
    currentUser.logo = [userDefaults objectForKey:kYYUserLogoKey];
    currentUser.status = [userDefaults objectForKey:kYYUserStatusKey];
    currentUser.userStatus = [[userDefaults objectForKey:kYYUserNewStatusKey] integerValue];
    return currentUser;
}


- (void)saveUserWithEmail:(NSString *)email username:(NSString *)username password:(NSString *)password userType:(NSInteger)userType userId:(NSString*)userId logo:(NSString *)logo status:(NSString*)status brandId:(NSString *)brandId{
    currentUser.name = username;
    currentUser.email = email;
    currentUser.password = password;
    currentUser.userType = userType;
    currentUser.userId = userId;
    currentUser.logo = logo;
    currentUser.status = status;
    currentUser.brandId = brandId;
    [self saveUserData];
//    [JpushHandler sendUserIdToAlias];
    [JpushHandler sendTagsAndAlias];
}

- (void)saveUserData{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:_name forKey:kYYUsernameKey];
    [userDefaults setObject:_email forKey:kYYUserEmailKey];
    [userDefaults setObject:_password forKey:kYYPasswordKey];
    [userDefaults setInteger:_userType forKey:kYYUserTypeKey];
    [userDefaults setObject:_brandId forKey:kYYUserBrandIDKey];
    [userDefaults setObject:_userId forKey:kYYUserIdKey];
    [userDefaults setObject:_logo forKey:kYYUserLogoKey];
    [userDefaults setObject:_status forKey:kYYUserStatusKey];
    [userDefaults setInteger:_userStatus forKey:kYYUserNewStatusKey];
    [userDefaults synchronize];
}


- (void)loginOut{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:nil forKey:kYYUsernameKey];
    [userDefaults setObject:nil forKey:kYYUserEmailKey];
    [userDefaults setObject:nil forKey:kYYPasswordKey];
    [userDefaults setInteger:-1 forKey:kYYUserTypeKey];
    [userDefaults setObject:nil forKey:kYYUserBrandIDKey];
    [userDefaults setObject:nil forKey:kYYUserIdKey];
    [userDefaults setObject:nil forKey:kYYUserLogoKey];
    
    [userDefaults setObject:nil forKey:kUserLoginTokenKey];
    [userDefaults setObject:nil forKey:kScrtKey];
    [userDefaults setObject:nil forKey:kYYUserStatusKey];
    [userDefaults setInteger:-1 forKey:kYYUserNewStatusKey];

    [userDefaults synchronize];
    [JpushHandler sendEmptyAlias];
}

//清空sid：app打开的时候
+(void)initOrClearTempSeriesID{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:@[] forKey:@"seriesId"];
    [userDefault synchronize];
}

//增加sid：在网络请求发起的时候加入
+(void)addTempSeriesID:(NSInteger )seriesID{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSArray *seriesIdArr = [userDefault objectForKey:@"seriesId"];
    
    NSMutableArray *tempArr = [seriesIdArr mutableCopy];
    [tempArr addObject:@(seriesID)];
    
    [userDefault setObject:[tempArr copy] forKey:@"seriesId"];
    [userDefault synchronize];
}

//删除sid：在图片加载完成（updateProgressUI）的时候删除
+(void)deleteTempSeriesID:(NSInteger )seriesID{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSArray *seriesIdArr = [userDefault objectForKey:@"seriesId"];
    
    NSMutableArray *tempArr = [seriesIdArr mutableCopy];
    [tempArr removeObject:@(seriesID)];
    
    [userDefault setObject:[tempArr copy] forKey:@"seriesId"];
    [userDefault synchronize];
}

//判断是是否有该id
+(BOOL)haveTempSeriesID:(NSInteger )seriesID{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSArray *seriesIdArr = [userDefault objectForKey:@"seriesId"];
    BOOL _haveSeries = NO;
    
    for (NSNumber *tempSeriesID in seriesIdArr) {
        if([tempSeriesID integerValue] == seriesID){
            _haveSeries = YES;
        }
    }
    return _haveSeries;
}
@end

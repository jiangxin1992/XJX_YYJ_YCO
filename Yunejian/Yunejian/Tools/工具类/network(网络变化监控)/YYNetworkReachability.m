//
//  YYNetworkReachability.m
//  Yunejian
//
//  Created by yyj on 15/7/13.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import "YYNetworkReachability.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import <netdb.h>
#import <arpa/inet.h>
#import "Reachability.h"
#import "LocalConnection.h"

@implementation YYNetworkReachability


+ (BOOL) connectedToNetwork{
    if ([GLocalConnection currentLocalConnectionStatus] == LC_UnReachable){
        return NO;
    }else{
        return YES;
    }
    
    
    //    ReachabilityStatus status = [GLobalRealReachability currentReachabilityStatus];
    //    if (status == RealStatusNotReachable) {
    //        return NO;
    //    }
    //    return YES;
//    // Create zero addy
//    struct sockaddr_in zeroAddress;
//    bzero(&zeroAddress, sizeof(zeroAddress));
//    zeroAddress.sin_len = sizeof(zeroAddress);
//    zeroAddress.sin_family = AF_INET;
//    
//    // Recover reachability flags
//    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
//    SCNetworkReachabilityFlags flags;
//    
//    BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
//    CFRelease(defaultRouteReachability);
//    
//    if (!didRetrieveFlags)
//    {
//        printf("Error. Could not recover network reachability flags\n");
//        return NO;
//    }
//    
//    BOOL isReachable = ((flags & kSCNetworkFlagsReachable) != 0);
//    BOOL needsConnection = ((flags & kSCNetworkFlagsConnectionRequired) != 0);
//    return (isReachable && !needsConnection) ? YES : NO;
}


//// Direct from Apple. Thank you Apple
//+ (BOOL)addressFromString:(NSString *)IPAddress address:(struct sockaddr_in *)address
//{
//    if (!IPAddress || ![IPAddress length]) return NO;
//    
//    memset((char *) address, sizeof(struct sockaddr_in), 0);
//    address->sin_family = AF_INET;
//    address->sin_len = sizeof(struct sockaddr_in);
//    
//    int conversionResult = inet_aton([IPAddress UTF8String], &address->sin_addr);
//    if (conversionResult == 0) {
//        NSAssert1(conversionResult != 1, @"Failed to convert the IP address string into a sockaddr_in: %@", IPAddress);
//        return NO;
//    }
//    
//    return YES;
//}
//
//+ (NSString *) getIPAddressForHost: (NSString *) theHost
//{
//    theHost=[theHost substringFromIndex:7];
//    NSLog(@"%@",theHost);
//    struct hostent *host = gethostbyname([theHost UTF8String]);
//    if (!host) {herror("resolv"); return NULL; }
//    struct in_addr **list = (struct in_addr **)host->h_addr_list;
//    NSString *addressString = [NSString stringWithCString:inet_ntoa(*list[0]) encoding:NSUTF8StringEncoding];
//    return addressString;
//}
//
//
//+ (BOOL) hostAvailable: (NSString *) theHost
//{
//    
//    NSString *addressString = [self getIPAddressForHost:theHost];
//    if (!addressString)
//    {
//        printf("Error recovering IP address from host name\n");
//        return NO;
//    }
//    
//    struct sockaddr_in address;
//    BOOL gotAddress = [self addressFromString:addressString address:&address];
//    
//    if (!gotAddress)
//    {
//        printf("Error recovering sockaddr address from %s\n", [addressString UTF8String]);
//        return NO;
//    }
//    
//    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&address);
//    SCNetworkReachabilityFlags flags;
//    
//    BOOL didRetrieveFlags =SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
//    CFRelease(defaultRouteReachability);
//    
//    if (!didRetrieveFlags)
//    {
//        printf("Error. Could not recover network reachability flags\n");
//        return NO;
//    }
//    
//    BOOL isReachable = flags & kSCNetworkFlagsReachable;
//    return isReachable ? YES : NO;;
//}
//
//+(BOOL)isExistNetWork:(NSString *) theHost
//{
//    Reachability *reachability = [Reachability reachabilityWithHostName:theHost];
//    
//    if ([reachability currentReachabilityStatus] == NotReachable)
//    {
//        return NO;
//    }
//    
//    return YES;
//}

@end

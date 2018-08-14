//
//  YYRequestHelp.h
//  Yunejian
//
//  Created by yyj on 15/7/3.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>

#import "QiniuSDK.h"

@class AFURLConnectionOperation;
@class YYRspStatusAndMessage;
@class AFHTTPRequestOperation;

@interface YYRequestHelp : NSObject


+ (NSOperation *)executeRequest:(BOOL)isPost headers:(NSDictionary *)headers requestUrl:(NSString *)requestUrl requestCount:(int)requestCount requestBody:(NSData *)requestBody andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage, id responseObject, NSError* error, id httpResponse))block;

+ (NSOperation *)executeRequestIsDelete:(BOOL)isDelete headers:(NSDictionary *)headers requestUrl:(NSString *)requestUrl requestCount:(int)requestCount requestBody:(NSData *)requestBody andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage, id responseObject, NSError* error, id httpResponse))block;

+ (NSOperation *)executeRequest:(NSString *)requestUrl requestCount:(int)requestCount requestBody:(NSData *)requestBody andBlock:(void (^)(id responseObject, NSError* error, id httpResponse))block;

/**
 * 上传图片
 */
+ (AFHTTPRequestOperation *)uploadImageWithUrl:(NSString *)url
                                         image:(UIImage *)image
                                   maxFileSize:(NSInteger)size
                                      andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage, id responseObject, NSError* error, id httpResponse))block;
/**
 * 上传图片 By Qiniu
 */
+ (void)uploadQiniuImage:(UIImage *)image WithType:(NSString *)uploadType
             maxFileSize:(NSInteger)size
                andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage, NSString *imageUrl,NSString * imgKey, NSString *uploadImgPathType, NSError *error))block;
/**
 * 获取 Qiniu UploadToken
 */
+(AFHTTPRequestOperation *)getUploadTokenWithType:(NSString *)uploadType WithBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,NSString *UploadToken,NSString *key,NSString *pathType, NSError *error))block;
/**
 * 向服务端上传key
 */
+(AFHTTPRequestOperation *)UploadQiniuKey:(NSString *)key WithType:(NSString *)type WithBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,NSString *imageUrl,NSError *error))block;
/**
 * 删除Qiniu目录的图片
 */
+(AFHTTPRequestOperation *)DeleteQiniuImgWithKey:(NSString *)key WithPathType:(NSString *)PathType WithBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,NSString *imageUrl,NSError *error))block;

// 上传图片
+ (AFHTTPRequestOperation *)uploadImageWithUrl:(NSString *)url
                                         image:(UIImage *)image
                                          size:(CGFloat )size
                                      andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage, id responseObject, NSError* error, id httpResponse))block;
@end

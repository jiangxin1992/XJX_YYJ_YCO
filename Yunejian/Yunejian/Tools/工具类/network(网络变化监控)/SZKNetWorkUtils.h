//
//  SZKNetWorkUtils.h
//  Yunejian
//
//  Created by yyj on 2017/3/27.
//  Copyright © 2017年 yyj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void(^netStateBlock)(NSInteger netState);


@interface SZKNetWorkUtils : NSObject

/**
 *  网络监测
 *
 *  @param block 判断结果回调
 *
 *  @return 网络监测
 */
+(void)netWorkState:(netStateBlock)block;

@end

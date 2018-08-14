//
//  SZKNetWorkUtils.m
//  Yunejian
//
//  Created by yyj on 2017/3/27.
//  Copyright © 2017年 yyj. All rights reserved.
//

#import "SZKNetWorkUtils.h"

#import "AFNetworkReachabilityManager.h"

@implementation SZKNetWorkUtils
#pragma mark----网络检测
+(void)netWorkState:(netStateBlock)block;
{
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    // 提示：要监控网络连接状态，必须要先调用单例的startMonitoring方法
    [manager startMonitoring];
    //检测的结果
//    __block typeof(self) bself = self;
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (status==0||status==-1) {
            //弹出提示框
//            [bself showWarningView];
            //将netState值传入block中
            block(status);
        }else{
            //将netState值传入block中
            block(status);
        }
    }];
}
#pragma mark---网络断开时弹出提示框
+(void)showWarningView
{

    UIAlertView *alter=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"提示",nil) message:kNetworkIsOfflineTips delegate:self cancelButtonTitle:NSLocalizedString(@"取消", nil) otherButtonTitles:NSLocalizedString(@"去设置",nil), nil];
    [alter show];
}
#pragma mark---alertView点击事件
+(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==0) {
        NSLog(@"取消");
    }else{
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
}
@end

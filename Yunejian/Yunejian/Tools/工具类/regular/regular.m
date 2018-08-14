//
//  regular.m
//  yunejianDesigner
//
//  Created by yyj on 2017/2/21.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "regular.h"
#import "NSDate+Formatter.h"
@implementation regular
//图片压缩到指定大小
+ (NSData*)getImageForSize:(CGFloat)size WithImage:(UIImage *)image
{
    NSData *tempData = UIImageJPEGRepresentation(image, 1);
    NSLog(@"原图大小=%lu %lfM",(unsigned long)tempData.length,[regular getSizeMWithBytes:tempData.length]);
    if([regular getSizeMWithBytes:tempData.length]<size)
    {
        return tempData;
    }else
    {
        NSArray *tempArr = @[@(0.9),@(0.8),@(0.7),@(0.6),@(0.5),@(0.4),@(0.3),@(0.2),@(0.1)];
        for (int i=0; i<tempArr.count; i++) {
            NSData *tempData1 = UIImageJPEGRepresentation(image, [[tempArr objectAtIndex:i] floatValue]);
            NSLog(@"处理%d次后的大小%lu %lfM",i+1,(unsigned long)tempData1.length,[regular getSizeMWithBytes:tempData1.length]);
            if([regular getSizeMWithBytes:tempData1.length]<size)
            {
                return tempData1;
            }
        }
        return UIImageJPEGRepresentation(image, 0.1);
    }
}
+(CGFloat )getSizeMWithBytes:(long)bytes
{
    return (bytes/1024.0f)/1024.0f;
}
+(void)dismissKeyborad
{
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
}

+(UIAlertController *)getAlertWithFirstActionTitle:(NSString *)firstTitle FirstActionBlock:(void (^)())firstActionBlock SecondActionTwoTitle:(NSString *)secondTitle SecondActionBlock:(void (^)())secondActionBlock;
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle: UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"取消",nil) style:UIAlertActionStyleCancel handler:nil];
    
    UIAlertAction *copyAction = [UIAlertAction actionWithTitle:secondTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        secondActionBlock();
    }];
    
    UIAlertAction *openAction = [UIAlertAction actionWithTitle:firstTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        firstActionBlock();
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:openAction];
    [alertController addAction:copyAction];
    return alertController;
}

+(long)date
{
    return [[NSDate date] timeIntervalSince1970];
}
+(NSDate*)zoneChange:(long)time{
    return [NSDate dateWithTimeIntervalSince1970:time];
}

+(NSString *)getTimeStr:(long)time WithFormatter:(NSString *)_formatter
{
    
    
    NSDate*detaildate=[NSDate dateWithTimeIntervalSince1970:time];
    
    NSLog(@"date:%@",[detaildate description]);
    
    //实例化一个NSDateFormatter对象
    
    NSDateFormatter*dateFormatter = [[NSDateFormatter alloc]init];
    
    //设定时间格式,这里可以设置成自己需要的格式
    
    [dateFormatter setDateFormat:_formatter];
    
    NSString*currentDateStr = [dateFormatter stringFromDate:detaildate];
    
    return currentDateStr;
    
    //NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    //[formatter setDateFormat:_formatter];
    //NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:time];
    //NSString *nowtimeStr = [formatter stringFromDate:confromTimesp];//----------将nsdate按formatter格式转成nsstring
    //return nowtimeStr;
    
}
+(long )getTimeWithTimeStr:(NSString *)time WithFormatter:(NSString *)_formatter
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    @"yyyy-MM-dd HH:mm"
    [formatter setDateFormat:_formatter];
    NSDate* date = [formatter dateFromString:time];
    return [date timeIntervalSince1970];
}

@end

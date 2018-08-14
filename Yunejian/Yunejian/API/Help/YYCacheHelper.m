//
//  CommonHelper.m
//  CMNewspaper
//
//  Created by zhu on 13-12-30.
//  Copyright (c) 2013年 zhu. All rights reserved.
//

//判断当前系列有没有离线文件夹
BOOL judgeOfflineSeriesIsDownload(NSString *seriesFolderName){
    BOOL isDownload = NO;
    if (seriesFolderName
        && [seriesFolderName length] > 0) {
        NSString *path = [yyjOfflineSeriesDirectory() stringByAppendingPathComponent:seriesFolderName];

        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:path]) {
            isDownload = YES;
        }

    }
    return isDownload;
}

NSString *dealwithImageurl(NSString *relativePath){
    NSString *imageDir = nil;
    if (relativePath) {
        if ([relativePath hasPrefix:@"http"]) {
            NSURL *url = [NSURL URLWithString:relativePath];
            NSString *host = [url host];
            if (host) {
                NSRange range = [relativePath rangeOfString:host];
                NSString *tempString = [relativePath substringFromIndex:range.location+range.length];
                if (tempString) {
                    imageDir = [tempString stringByDeletingLastPathComponent];
                    //NSLog(@"imageDir: %@",imageDir);
                }

            }
        }
    }
    return imageDir;
}

//系列离线包图片地址
NSString *yyjOfflineSeriesImagePath(long seriesId,NSString *absolutePath,NSString *imageSuffix){
    NSString *path = nil;
    if (seriesId > 0
        && absolutePath
        && imageSuffix) {

        NSString *nowDir = dealwithImageurl(absolutePath);

        NSString *folderName = [NSString stringWithFormat:@"%li",seriesId];
        NSString *offlineFilePath = [yyjOfflineSeriesDirectory() stringByAppendingPathComponent:folderName];
        NSString *imageDir = [offlineFilePath stringByAppendingPathComponent:nowDir];
        path = [imageDir stringByAppendingPathComponent:imageSuffix];
    }
    return path;
}
//系列离线包zip临时存放目录
NSString *yyjOfflineSeriesZipDirectory(){
    NSArray *filePaths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [filePaths objectAtIndex: 0];
    docPath = [docPath stringByAppendingPathComponent:@"series_offline_zip"];


    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:docPath]) {
        [fileManager createDirectoryAtPath:docPath withIntermediateDirectories:YES attributes:nil error:nil];
    }

    //防止icloud备份
    addSkipBackupAttributeToItemAtURL([NSURL fileURLWithPath:docPath]);
    return docPath;
}
//系列离线包存放目录
NSString *yyjOfflineSeriesDirectory(){
    NSArray *filePaths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [filePaths objectAtIndex: 0];
    docPath = [docPath stringByAppendingPathComponent:@"series_offline"];


    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:docPath]) {
        [fileManager createDirectoryAtPath:docPath withIntermediateDirectories:YES attributes:nil error:nil];
    }

    //防止icloud备份
    addSkipBackupAttributeToItemAtURL([NSURL fileURLWithPath:docPath]);
    return docPath;
}


//
//  CommonHelper.h
//  CMNewspaper
//
//  Created by xuy on 13-12-30.
//  Copyright (c) 2013年 xuy. All rights reserved.
//

//判断当前系列有没有离线文件夹
BOOL judgeOfflineSeriesIsDownload(NSString *seriesFolderName);

//系列离线包图片地址
NSString *yyjOfflineSeriesImagePath(long seriesId,NSString *absolutePath,NSString *imageSuffix);

//系列离线包zip临时存放目录
NSString *yyjOfflineSeriesZipDirectory();

//存放系列离线包目录
NSString *yyjOfflineSeriesDirectory();


//
//  YYSeriesCollectionViewCell.h
//  Yunejian
//
//  Created by yyj on 15/9/4.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DownLoadOperation.h"

@protocol YYSeriesCollectionViewCellDelegate
-(void)downloadImages:(NSURL *)url andStorePath:(NSString *)storePath;
-(void)operateHandler:(NSInteger)section androw:(NSInteger)row type:(NSString*)type;
-(UIView *)getview;
@end
@interface YYSeriesCollectionViewCell : UICollectionViewCell

@property (nonatomic,strong) NSString *title;
@property (nonatomic,strong) NSString *imageRelativePath;
@property (nonatomic,strong) NSString *order;
@property (nonatomic,strong) NSString *produce;
@property (nonatomic,strong) NSString *styleAmount;
@property (nonatomic,assign) long series_id;
@property (nonatomic,weak)id<YYSeriesCollectionViewCellDelegate> delegate;
@property (nonatomic,strong) NSIndexPath *indexPath;
@property (nonatomic,assign) NSInteger totalImageCount;
@property (nonatomic,assign) NSInteger loadImageCount;
@property (nonatomic,assign) NSInteger authType;
@property (nonatomic,assign) NSInteger supplyStatus;
@property (nonatomic,assign) NSInteger status;
@property (nonatomic, assign) BOOL stockEnabled;

@property (nonatomic,assign) NSInteger dateRangeAmount;
@property (nonatomic,assign) NSComparisonResult compareResult1;
@property (nonatomic,assign) NSComparisonResult compareResult2;

@property (nonatomic,assign) BOOL haveLoadData;

-(id)checkOperation:(NSInteger)seriesID;
-(NSArray *)getDownLoadCount:(NSInteger)seriesID;
-(NSArray *)checkImagesDownloadAll;
-(void)addDownLoadCount:(NSArray *)value;

- (void)updateUI;

//@property (nonatomic,strong) ModifySuccess modifySuccess;

@end

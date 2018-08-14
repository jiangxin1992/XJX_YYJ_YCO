//
//  YYSeriesDetailInfoViewCell.h
//  Yunejian
//
//  Created by Apple on 15/12/22.
//  Copyright © 2015年 yyj. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YYSeriesInfoModel,YYSeriesInfoDetailModel;

@interface YYSeriesDetailInfoViewCell : UICollectionViewCell

@property (nonatomic, assign) BOOL isSelect;
@property (nonatomic, assign) NSInteger selectCount;

@property (nonatomic, strong) YYSeriesInfoDetailModel *seriesInfoDetailModel;

@property (nonatomic, strong) NSString *sortType;
@property (nonatomic, assign) NSInteger dateRangIndex;
@property (assign, nonatomic) NSInteger selectTaxType;

@property (nonatomic, strong) SelectButtonClicked  selectButtonClicked;
@property (nonatomic, strong) SelectedValue  selectedTagValue;
@property (nonatomic, strong) SelectedValue  selectedTaxTagValue;
@property (nonatomic, strong) SelectButtonClicked  showSeriesInfo;

@property (nonatomic,assign) NSComparisonResult orderDueCompareResult;

@property (weak, nonatomic) id<YYTableCellDelegate> delegate;
@property (nonatomic, strong) NSIndexPath *indexPath;

-(void)updateUI;

@end

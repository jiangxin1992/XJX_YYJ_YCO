//
//  YYShowroomMainCollectionView.h
//  Yunejian
//
//  Created by yyj on 2017/3/20.
//  Copyright © 2017年 yyj. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "YYShowroomBrandListModel.h"
@interface YYShowroomMainCollectionView : UICollectionView

-(instancetype)initWithFrame:(CGRect)frame;

-(void)reloadCollectionData;

@property (strong ,nonatomic) NSMutableArray *arrayData;//排序好的数据
@property (strong ,nonatomic) YYShowroomBrandListModel *listModel;
@property (assign ,nonatomic) BOOL haveHeadView;
@property (nonatomic,copy) void (^scrollViewDelegateBlock)(NSString *type,CGFloat contentOffsetY);
@property (nonatomic,copy) void (^collectionViewDelegateBlock)(NSString *type,NSIndexPath *indexPath);

@end

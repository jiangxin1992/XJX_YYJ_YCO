//
//  YYOpusStyleCell.h
//  Yunejian
//
//  Created by yyj on 2018/1/4.
//  Copyright © 2018年 yyj. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YYOpusStyleModel;

@interface YYOpusStyleCell : UICollectionViewCell

@property (nonatomic, assign) BOOL isSelect;

@property (nonatomic, assign) BOOL opusStyleIsSelect;

@property (nonatomic, strong) YYOpusStyleModel *opusStyleModel;
@property (assign, nonatomic) NSInteger selectTaxType;
@property (nonatomic, assign) BOOL isModifyOrder;
@property (weak, nonatomic) id<YYTableCellDelegate> delegate;
@property (nonatomic, strong) NSIndexPath *indexPath;

-(void)updateUI;

@end

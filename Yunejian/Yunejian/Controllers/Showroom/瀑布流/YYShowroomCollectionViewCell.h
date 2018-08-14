//
//  YYShowroomCollectionViewCell.h
//  Yunejian
//
//  Created by yyj on 2017/3/21.
//  Copyright © 2017年 yyj. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "YYShowroomBrandModel.h"

@interface YYShowroomCollectionViewCell : UICollectionViewCell

-(instancetype)initWithFrame:(CGRect)frame;

@property (nonatomic,strong) YYShowroomBrandModel *showroomModel;
@property (nonatomic,assign) BOOL isleft;
@end

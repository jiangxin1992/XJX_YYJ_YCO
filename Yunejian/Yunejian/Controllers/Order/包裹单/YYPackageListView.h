//
//  YYPackageListView.h
//  Yunejian
//
//  Created by yyj on 2018/7/31.
//  Copyright © 2018年 yyj. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YYPackageModel;

@interface YYPackageListView : UIView

-(instancetype)initWithPackageArray:(NSArray *)packageArray WithBlock:(void (^)(YYPackageModel *packageModel, NSIndexPath *indexPath))block;

@end

//
//  YYShowroomBrandHeadView.h
//  yunejianDesigner
//
//  Created by yyj on 2017/3/6.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YYShowroomBrandListModel;

@interface YYShowroomBrandHeadView : UICollectionReusableView

@property (nonatomic,copy) void (^block)(NSString *type);

@property (strong ,nonatomic) YYShowroomBrandListModel *ShowroomBrandListModel;

-(void)bottomIsHide:(BOOL )ishide;

@end

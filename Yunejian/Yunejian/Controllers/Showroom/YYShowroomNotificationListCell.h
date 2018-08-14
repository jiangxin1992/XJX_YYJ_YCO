//
//  YYShowroomNotificationListCell.h
//  Yunejian
//
//  Created by yyj on 2018/3/13.
//  Copyright © 2018年 yyj. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YYShowroomOrderingModel;

@interface YYShowroomNotificationListCell : UICollectionViewCell

@property (nonatomic, copy) void (^block)(NSString *type,NSNumber *orderingID,UIView *touchView);

@property (nonatomic, strong) YYShowroomOrderingModel *logisticsModel;

@end

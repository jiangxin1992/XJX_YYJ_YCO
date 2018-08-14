//
//  YYOrderStatusCell.h
//  Yunejian
//
//  Created by Apple on 15/11/25.
//  Copyright © 2015年 yyj. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 订单关联状态
 */
typedef NS_ENUM(NSInteger, YYOrderStatusType) {
    YYOrderStatusTypeOrder,        //订单相关
    YYOrderStatusTypePickingList   //修改装箱单
};

@class YYOrderInfoModel,YYOrderTransStatusModel,YYStylesAndTotalPriceModel;

@interface YYOrderStatusCell : UITableViewCell

@property (nonatomic, assign) YYOrderStatusType statusType;//类型

//---------- 仅在YYOrderStatusTypeOrder时传入 ----------
@property (nonatomic, strong) YYOrderInfoModel *currentYYOrderInfoModel;
@property (nonatomic, strong) YYOrderTransStatusModel *currentYYOrderTransStatusModel;
@property (nonatomic, strong) YYStylesAndTotalPriceModel *stylesAndTotalPriceModel;//总数
@property (nonatomic, assign) NSInteger currentOrderConnStatus;
@property (nonatomic, weak) id<YYTableCellDelegate> delegate;
@property (nonatomic, strong) NSIndexPath *indexPath;
//---------- 仅在YYOrderStatusTypeOrder时传入 ----------


//---------- 仅在YYOrderStatusTypePickingList时传入 ----------
@property (nonatomic, assign) NSInteger progress;//进度
@property (nonatomic, assign) BOOL hasException;//是否存在异常 bool
@property (nonatomic, copy) void (^errorClickBlock)(void);
//---------- 仅在YYOrderStatusTypePickingList时传入 ----------

-(void)updateUI;

@end

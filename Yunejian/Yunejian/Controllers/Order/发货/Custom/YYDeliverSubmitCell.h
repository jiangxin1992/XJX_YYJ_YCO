//
//  YYDeliverSubmitCell.h
//  Yunejian
//
//  Created by yyj on 2018/7/30.
//  Copyright © 2018年 yyj. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YYDeliverModel;

@interface YYDeliverSubmitCell : UITableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier WithBlock:(void(^)(NSString *type))block;

-(void)updateUI;

@property (nonatomic, strong) NSNumber *buyerStockEnabled;//此单的买手店库存是否已经开通 bool

@property (nonatomic ,strong) YYDeliverModel *deliverModel;

@end

//
//  YYOrderMoneyLogCell.h
//  Yunejian
//
//  Created by Apple on 15/11/25.
//  Copyright © 2015年 yyj. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "KAProgressLabel.h"
#import "YYPaymentNoteListModel.h"
#import "YYOrderInfoModel.h"
#import "YYOrderTransStatusModel.h"

@interface YYOrderMoneyLogCell : UITableViewCell

@property (weak, nonatomic) IBOutlet KAProgressLabel *pLabel;
@property (weak, nonatomic) IBOutlet UIButton *addLogBtn;
@property (weak, nonatomic) IBOutlet UILabel *hasMoneyLabel;
@property (weak, nonatomic) IBOutlet UIButton *hasMoneyTipBtn;
@property (nonatomic, strong) YYOrderInfoModel *currentYYOrderInfoModel;
@property (strong, nonatomic) YYOrderTransStatusModel *currentYYOrderTransStatusModel;
@property (nonatomic,strong) YYPaymentNoteListModel *paymentNoteList;
@property (weak,nonatomic) id<YYTableCellDelegate>  delegate;
@property (nonatomic,strong) NSIndexPath *indexPath;
@property (nonatomic,assign) NSInteger moneyType;
-(void)updateUI;
+(float)cellHeight:(NSArray *)payNoteList;
@end

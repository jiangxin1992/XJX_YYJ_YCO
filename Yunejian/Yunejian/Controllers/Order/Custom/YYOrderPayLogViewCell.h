//
//  YYOrderPayLogViewCell.h
//  YunejianBuyer
//
//  Created by Apple on 16/7/20.
//  Copyright © 2016年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYPaymentNoteModel.h"
@interface YYOrderPayLogViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *timerLabel;
@property (weak, nonatomic) IBOutlet UIButton *statusLabel;
@property (weak, nonatomic) IBOutlet UIButton *statusBtn;
@property (weak, nonatomic) IBOutlet UIButton *payTypeLabel;
@property (weak, nonatomic) IBOutlet UIView *redDotView;
@property (weak, nonatomic) IBOutlet UIButton *makeSureBtn;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;
@property (weak, nonatomic) IBOutlet UIView *oprateView;
@property (weak, nonatomic) IBOutlet UILabel *detailTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailTitleLabel3;
@property (weak, nonatomic) IBOutlet UILabel *detailTitleLabel4;



@property (strong,nonatomic) YYPaymentNoteModel *noteModel;
@property (weak,nonatomic) id<YYTableCellDelegate>  delegate;
@property (strong,nonatomic) NSIndexPath *indexPath;
@property (strong,nonatomic) NSIndexPath *detailIndexPath;
@property (weak, nonatomic) IBOutlet UIView *detailView;
@property (weak, nonatomic) IBOutlet UILabel *outTradeNoLabel;
@property (weak, nonatomic) IBOutlet UILabel *payMethodLabel;
@property (weak, nonatomic) IBOutlet UILabel *payTimerLabel;
@property (weak, nonatomic) IBOutlet UILabel *getTimerLabel;
-(void)updateUI;
@end

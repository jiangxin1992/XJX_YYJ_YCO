//
//  YYOrderPayLogViewCell.h
//  YunejianBuyer
//
//  Created by Apple on 16/7/20.
//  Copyright © 2016年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YYPaymentNoteModel;

@interface YYOrderPayLogViewCell : UITableViewCell

@property (nonatomic, strong) YYPaymentNoteModel *noteModel;
@property (nonatomic, weak) id<YYTableCellDelegate> delegate;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, strong) NSIndexPath *detailIndexPath;

-(void)updateUI;

@end

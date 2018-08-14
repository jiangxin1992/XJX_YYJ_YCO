//
//  YYForgetPasswordTableVerifyEmailCell.h
//  Yunejian
//
//  Created by Apple on 16/10/17.
//  Copyright © 2016年 yyj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JKCountDownButton.h"

@class TTTAttributedLabel;

@interface YYForgetPasswordTableVerifyEmailCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *subimtBtn;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *emialTipLabel;
@property (weak, nonatomic) IBOutlet JKCountDownButton *sendBtn;
@property (weak, nonatomic) IBOutlet UILabel *sendTimerLabel;
//@property (weak, nonatomic) IBOutlet UIButton *oprateResultTipBtn;

@property(nonatomic,weak)id<YYTableCellDelegate> delegate;
@property(nonatomic,copy)NSIndexPath * indexPath;

-(void)updateCellInfo:(NSArray*)info;
@end

//
//  YYOrderMessageViewCell.h
//  Yunejian
//
//  Created by Apple on 15/10/27.
//  Copyright © 2015年 yyj. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YYOrderMessageInfoModel;

@interface YYOrderMessageViewCell : UITableViewCell

@property (assign, nonatomic) YYOrderMessageInfoModel * msgInfoModel;

@property (weak,nonatomic) id<YYTableCellDelegate>  delegate;

@property (strong,nonatomic) NSIndexPath *indexPath;

-(void)updateUI;

@end

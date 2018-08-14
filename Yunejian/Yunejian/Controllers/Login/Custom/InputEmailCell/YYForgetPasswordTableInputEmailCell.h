//
//  YYForgetPasswordTableInputEmailCell.h
//  Yunejian
//
//  Created by Apple on 16/10/17.
//  Copyright © 2016年 yyj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YYForgetPasswordTableInputEmailCell : UITableViewCell
//@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextField *inputText;
@property (weak, nonatomic) IBOutlet UIButton *tipBtn;
@property(nonatomic,weak)id<YYTableCellDelegate> delegate;
@property(nonatomic,copy)NSIndexPath * indexPath;


-(void)updateCellInfo:(NSArray*)info;
@end

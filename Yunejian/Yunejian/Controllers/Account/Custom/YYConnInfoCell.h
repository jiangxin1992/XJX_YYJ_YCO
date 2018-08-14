//
//  YYConnInfoCell.h
//  Yunejian
//
//  Created by Apple on 15/12/1.
//  Copyright © 2015年 yyj. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, ConnInfoCellShowType) {
    ConnInfoCellShowTypeNum = 60000,
    ConnInfoCellShowTypeMessage = 60001,
};
@interface YYConnInfoCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *keyLabel;
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;
@property (weak, nonatomic) IBOutlet UIView *valueView;
@property (weak, nonatomic) IBOutlet UILabel *msgNumLabel;

@property (nonatomic,strong)NSArray *infoArr;
- (void)updateUIWithShowType:(ConnInfoCellShowType )showType;

@end

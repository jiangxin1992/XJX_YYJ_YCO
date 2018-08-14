//
//  YYPackageDetailInfoCell.h
//  Yunejian
//
//  Created by yyj on 2018/8/10.
//  Copyright © 2018年 yyj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YYPackageDetailInfoCell : UITableViewCell

@property (nonatomic, assign) BOOL isPackageError;

+(CGFloat)cellHeight;

-(void)updateUI;

@end

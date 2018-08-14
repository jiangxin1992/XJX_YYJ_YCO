//
//  YYUserLogoInfoCell.h
//  Yunejian
//
//  Created by Apple on 15/9/22.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCGIFButtonView.h"
@protocol YYUserLogoInfoCellDelegate
-(void)handlerBtnClick:(id)target;
@end

@interface YYUserLogoInfoCell : UITableViewCell

@property (weak, nonatomic) IBOutlet SCGIFButtonView *logoButton;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;

@property (weak, nonatomic) IBOutlet UIView *verifyBackView;
@property (weak, nonatomic) IBOutlet UIButton *verifyButton;
@property (nonatomic, strong) UILabel *warnLabel;
@property (nonatomic, strong) UILabel *tipLabel;

@property(nonatomic,weak)id<YYUserLogoInfoCellDelegate> delegate;

@property(nonatomic,copy) void (^block)(NSString *type);

- (IBAction)changeLogoHandler:(id)sender;
@end

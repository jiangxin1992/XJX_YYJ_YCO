//
//  YYSelectRoleViewController.m
//  Yunejian
//
//  Created by yyj on 15/7/12.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import "YYSelectRoleViewController.h"

@implementation YYSelectRoleViewController

- (void)viewDidLoad{
    [super viewDidLoad];

    NSString *imageStr = @"";
    if([LanguageManager isEnglishLanguage]){
        imageStr = @"designer_regist_en";
    }else{
        imageStr = @"designer_regist";
    }
    [_roleButton setImage:[UIImage imageNamed:imageStr] forState:UIControlStateNormal];

    UIView *tempView = [[UIView alloc] init];
    tempView.backgroundColor = [UIColor whiteColor];
    tempView.alpha = 0.6;

    [self.view insertSubview:tempView atIndex:0];
    __weak UIView *_weakView = self.view;
    [tempView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_weakView.mas_top);
        make.left.equalTo(_weakView.mas_left);
        make.bottom.equalTo(_weakView.mas_bottom);
        make.right.equalTo(_weakView.mas_right);
    }];

    UIGestureRecognizer *aGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tabPiece:)];
    [tempView addGestureRecognizer:aGesture];

}

- (void)tabPiece:(UIPanGestureRecognizer *)gestureRecognizer
{
    if (self.roleButtonClicked) {
        self.roleButtonClicked(RoleButtonTypeCancel);
    }
}

- (IBAction)buttonAction:(id)sender{
    UIButton *button = (UIButton *)sender;
    if (self.roleButtonClicked) {
        self.roleButtonClicked(button.tag);
    }

}

@end

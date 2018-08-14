//
//  YYSmallShoppingCarButton.m
//  Yunejian
//
//  Created by yyj on 15/7/24.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import "YYSmallShoppingCarButton.h"

#import "UIImage+YYImage.h"
#import "UIImage+Tint.h"

@interface YYSmallShoppingCarButton ()

@property(nonatomic,strong) UILabel *numberLabel;
@property(nonatomic,strong) UIImageView *imageIconView;
@end

@implementation YYSmallShoppingCarButton

- (void)initButton{
    
    UILabel *numberLabel = [[UILabel alloc] init];
    self.numberLabel = numberLabel;
    _numberLabel.backgroundColor = [UIColor clearColor];
    _numberLabel.textColor = [UIColor redColor];
    _numberLabel.font = [UIFont systemFontOfSize:12];
    _numberLabel.numberOfLines = 1;
    _numberLabel.textAlignment = NSTextAlignmentCenter;
    
    UIImage *image = [UIImage imageNamed:@"small_car"];
    [self setImage:image forState:UIControlStateNormal];
    
    
    [self setImage:[image imageByApplyingAlpha:0.6] forState:UIControlStateHighlighted];
    
    
    [self addSubview:numberLabel];
    __weak UIView *_weakView = self;
    [numberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_weakView.mas_top).with.offset(12);
        make.left.equalTo(_weakView.mas_left).with.offset(20);
        make.bottom.equalTo(_weakView.mas_bottom).with.offset(-26);
        make.right.equalTo(_weakView.mas_right).with.offset(-8);;
        
    }];
    
}

- (void)initFlagButton{
    UIImage *image = [UIImage imageNamed:@"small_car"];
    [self setImage:image forState:UIControlStateNormal];
    
    
    [self setImage:[image imageByApplyingAlpha:0.6] forState:UIControlStateHighlighted];
    
    
    UIImage *flagImage = [[UIImage imageNamed:@"inviteflag_icon"] imageWithTintColor:[UIColor colorWithHex:@"ef4e31"]];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:flagImage];
    self.imageIconView =imageView;
    [self addSubview:imageView];
    __weak UIView *_weakView = self;
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_weakView.mas_top).with.offset(12);
        make.left.equalTo(_weakView.mas_left).with.offset(25);
        make.width.equalTo(@(12));
        make.height.equalTo(@(9));
    }];
    
}

- (void)updateButtonNumber:(NSString *)nowNumber{
    if (nowNumber && _numberLabel) {

        _numberLabel.text = nowNumber;
        
    }
}



@end

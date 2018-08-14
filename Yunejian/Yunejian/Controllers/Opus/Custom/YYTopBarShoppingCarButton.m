//
//  YYTopBarShoppingCarButton.m
//  Yunejian
//
//  Created by yyj on 15/7/24.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import "YYTopBarShoppingCarButton.h"

#import "UIImage+YYImage.h"

@interface YYTopBarShoppingCarButton ()

@property(nonatomic,strong) UILabel *numberLabel;

@end

@implementation YYTopBarShoppingCarButton

- (void)initButton{
    
    UILabel *numberLabel = [[UILabel alloc] init];
    self.numberLabel = numberLabel;
    _numberLabel.backgroundColor = [UIColor clearColor];
    _numberLabel.textColor = [UIColor redColor];
    _numberLabel.font = [UIFont boldSystemFontOfSize:15];
    _numberLabel.numberOfLines = 1;
    _numberLabel.textAlignment = NSTextAlignmentLeft;
    
    UIImage *image = [UIImage imageNamed:@"top_car"];
    [self setImage:image forState:UIControlStateNormal];
    
    
    [self setImage:[image imageByApplyingAlpha:0.6] forState:UIControlStateHighlighted];
    
    
    [self addSubview:numberLabel];
    __weak UIView *_weakView = self;
    [numberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_weakView.mas_top).with.offset(10);
        make.left.equalTo(_weakView.mas_left).with.offset(32);
        make.bottom.equalTo(_weakView.mas_bottom).with.offset(-26);
        make.right.equalTo(_weakView.mas_right).with.offset(-1);;
        
    }];
    
}

- (void)updateButtonNumber:(NSString *)nowNumber{
    if (nowNumber) {
        if ([nowNumber length] == 1) {
            _numberLabel.text = [NSString stringWithFormat:@" %@",nowNumber];
        }else{
            _numberLabel.text = nowNumber;
        }
    }
}

@end

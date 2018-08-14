//
//  YYMessageButton.m
//  Yunejian
//
//  Created by Apple on 15/10/29.
//  Copyright © 2015年 yyj. All rights reserved.
//

#import "YYMessageButton.h"

@implementation YYMessageButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (void)initButton:(NSString *)title{
    __weak UIView *_weakView = self;
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.font = [UIFont systemFontOfSize:15];
    self.titleLabel.textColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
    self.titleLabel.text = title;
    self.titleLabel.textAlignment = NSTextAlignmentRight;
    [self addSubview:self.titleLabel];

    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_weakView.mas_top);
        make.left.equalTo(_weakView.mas_left);
        make.bottom.equalTo(_weakView.mas_bottom);
        make.right.equalTo(_weakView.mas_right).with.offset(-23);
    }];
    self.imageView = [[UIImageView alloc] init];
    self.imageView.image = [UIImage imageNamed:@"message_icon"];
    [self addSubview:self.imageView];
//    __weak UIView *_weakTitleView = self.titleLabel;

    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(22));
        make.height.equalTo(@(12));
        make.centerY.equalTo(@(0));
        make.right.equalTo(_weakView.mas_right).with.offset(-1);
    }];
    
    self.numberLabel = [[UILabel alloc] init];
    _numberLabel.backgroundColor = [UIColor clearColor];
    _numberLabel.textColor = [UIColor whiteColor];
    _numberLabel.font = [UIFont boldSystemFontOfSize:12];
    _numberLabel.numberOfLines = 1;
    _numberLabel.textAlignment = NSTextAlignmentLeft;
    __weak UIView *_weakImageView = self.imageView;

    [self addSubview:_numberLabel];
    [_numberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_weakImageView.mas_top).with.offset(0);
        make.left.equalTo(_weakImageView.mas_left).with.offset(5);
        make.bottom.equalTo(_weakImageView.mas_bottom).with.offset(0);
        make.right.equalTo(_weakImageView.mas_right).with.offset(0);
        
    }];
    
}

- (void)updateButtonNumber:(NSString *)nowNumber{
    __weak UIView *_weakView = self;

    if (nowNumber && ![nowNumber isEqualToString:@""]) {
        if ([nowNumber length] == 1) {
            _numberLabel.text = [NSString stringWithFormat:@" %@",nowNumber];
        }else{
            _numberLabel.text = nowNumber;
        }
        _numberLabel.hidden = NO;
        self.imageView.hidden = NO;
        [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(_weakView.mas_right).with.offset(-23);
        }];
        self.titleLabel.textColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];

    }else{
        _numberLabel.hidden = YES;
        self.imageView.hidden = YES;
        [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(_weakView.mas_right).with.offset(0);
        }];
        self.titleLabel.textColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];

    }
}
@end

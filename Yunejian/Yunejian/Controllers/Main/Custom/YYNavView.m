//
//  YYNavView.m
//  YunejianBuyer
//
//  Created by yyj on 2017/6/2.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "YYNavView.h"

#define YY_ANIMATE_DURATION 0.2 //动画持续时间

@interface YYNavView ()

@property (nonatomic, assign) BOOL isAnimation;
@property (nonatomic,assign) BOOL haveStatusView;

@property (nonatomic,strong) UIView *superView;

@end

@implementation YYNavView
#pragma mark - INIT
-(instancetype)initWithTitle:(NSString *)title
{
    CGFloat width = 0;
    if(_isPad){
        width = 180;
    }else{
        if(IsPhone6_gt){
            width = 180;
        }else{
            width = 130;
        }
    }
    self = [super initWithFrame:CGRectMake(0, 0, width, 50)];
    if(self){
        
        _navTitle = title;
        
        _titleLabel = [UILabel getLabelWithAlignment:1 WithTitle:_navTitle WithFont:17.0f WithTextColor:nil WithSpacing:0];
        [self addSubview:_titleLabel];
        _titleLabel.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
        
    }
    return self;
}
#pragma mark - SomePrepare
-(void)SomePrepare
{
    [self PrepareData];
    [self PrepareUI];
}
-(void)PrepareData{
    _isAnimation = NO;
}
-(void)PrepareUI{}
#pragma mark - UIConfig
-(void)setAnimationHide:(BOOL )isHide{
    if(self){
        if(isHide){
            //消失
            if(!self.hidden && !_isAnimation){
                _isAnimation = YES;
                self.alpha = 1.0f;
                [UIView animateWithDuration:YY_ANIMATE_DURATION animations:^{
                    self.alpha = 0.0f;
                } completion:^(BOOL finished) {
                    _isAnimation = NO;
                    self.hidden = YES;
                }];
            }
        }else{
            //出现
            if(self.hidden && !_isAnimation){
                _isAnimation = YES;
                self.hidden = NO;
                self.alpha = 0.0f;
                [UIView animateWithDuration:YY_ANIMATE_DURATION animations:^{
                    self.alpha = 1.0f;
                } completion:^(BOOL finished) {
                    _isAnimation = NO;
                    self.hidden = NO;
                }];
            }
        }
    }
}
@end

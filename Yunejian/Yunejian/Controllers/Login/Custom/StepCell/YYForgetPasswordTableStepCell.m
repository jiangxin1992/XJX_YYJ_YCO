//
//  YYInventoryTableStepCell.m
//  YunejianBuyer
//
//  Created by Apple on 16/9/1.
//  Copyright © 2016年 Apple. All rights reserved.
//

#import "YYForgetPasswordTableStepCell.h"

#import "UIView+UpdateAutoLayoutConstraints.h"

@implementation YYForgetPasswordTableStepCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)updateCellInfo:(NSArray*)info{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    NSString *selectColor = @"ed6498";
    NSInteger itemWidth = (514 - (74)*2)/3;
    [_titleLabel1 setConstraintConstant:itemWidth forAttribute:NSLayoutAttributeWidth];
    NSArray *infoModel1 = [info objectAtIndex:0];
    NSArray *infoModel2 = [info objectAtIndex:1];
    NSArray *infoModel3 = [info objectAtIndex:2];
    _titleLabel1.text = [infoModel1 objectAtIndex:0];
    _titleLabel2.text = [infoModel2 objectAtIndex:0];
    _titleLabel3.text = [infoModel3 objectAtIndex:0];
    [_titleLabel1 setAdjustsFontSizeToFitWidth:YES];
    [_titleLabel2 setAdjustsFontSizeToFitWidth:YES];
    [_titleLabel3 setAdjustsFontSizeToFitWidth:YES];
    _stepNumLabel1.layer.cornerRadius = 11.5;
    _stepNumLabel2.layer.cornerRadius = 11.5;
    _stepNumLabel3.layer.cornerRadius = 11.5;
    _stepNumLabel1.layer.masksToBounds = YES;
    _stepNumLabel2.layer.masksToBounds = YES;
    _stepNumLabel3.layer.masksToBounds = YES;
    NSString *value1 = [infoModel1 objectAtIndex:1];
    NSString *value2 = [infoModel2 objectAtIndex:1];
    NSString *value3 = [infoModel3 objectAtIndex:1];
    
    _lineView3.hidden = NO;
    if([value1 isEqualToString:@"true"]){
        _titleLabel1.textColor = [UIColor colorWithHex:selectColor];
        _stepView1.backgroundColor = [UIColor whiteColor];
        _stepNumLabel1.layer.borderColor = [UIColor colorWithHex:selectColor].CGColor;
        _stepNumLabel1.layer.borderWidth = 4;
        _stepNumLabel1.backgroundColor = [UIColor colorWithHex:selectColor];
        _stepNumLabel1.textColor = [UIColor whiteColor];
        _lineView1.hidden = NO;
    }else{
        _titleLabel1.textColor = [UIColor colorWithHex:@"919191"];
        _stepView1.backgroundColor = [UIColor whiteColor];
        _stepNumLabel1.layer.borderColor = [UIColor colorWithHex:@"919191"].CGColor;
        _stepNumLabel1.layer.borderWidth = 1;
        _stepNumLabel1.backgroundColor = [UIColor whiteColor];
        _stepNumLabel1.textColor = [UIColor colorWithHex:@"919191"];
        _lineView1.hidden = YES;
    }
    
    if([value2 isEqualToString:@"true"]){
        _titleLabel2.textColor = [UIColor colorWithHex:selectColor];
        _stepView2.backgroundColor = [UIColor whiteColor];
        _stepNumLabel2.layer.borderColor = [UIColor colorWithHex:selectColor].CGColor;
        _stepNumLabel2.layer.borderWidth = 4;
        _stepNumLabel2.backgroundColor = [UIColor colorWithHex:selectColor];
        _stepNumLabel2.textColor = [UIColor whiteColor];
        _lineView1.hidden = YES;
        _lineView2.hidden = NO;
    }else{
        _titleLabel2.textColor = [UIColor colorWithHex:@"919191"];
        _stepView2.backgroundColor = [UIColor whiteColor];
        _stepNumLabel2.layer.borderColor = [UIColor colorWithHex:@"919191"].CGColor;
        _stepNumLabel2.layer.borderWidth = 1;
        _stepNumLabel2.backgroundColor = [UIColor whiteColor];
        _stepNumLabel2.textColor = [UIColor colorWithHex:@"919191"];
        _lineView2.hidden = YES;
    }
    if([value3 isEqualToString:@"true"]){
        _titleLabel3.textColor = [UIColor colorWithHex:selectColor];
        _stepView3.backgroundColor = [UIColor whiteColor];
        _stepNumLabel3.layer.borderColor = [UIColor colorWithHex:selectColor].CGColor;
        _stepNumLabel3.layer.borderWidth = 4;
        _stepNumLabel3.backgroundColor = [UIColor colorWithHex:selectColor];
        _stepNumLabel3.textColor = [UIColor whiteColor];
        _lineView1.hidden = YES;
        _lineView2.hidden = YES;
        _lineView3.backgroundColor = [UIColor colorWithHex:selectColor];
    }else{
        _titleLabel3.textColor = [UIColor colorWithHex:@"919391"];
        _stepView3.backgroundColor = [UIColor whiteColor];
        _stepNumLabel3.layer.borderColor = [UIColor colorWithHex:@"919191"].CGColor;
        _stepNumLabel3.layer.borderWidth = 1;
        _stepNumLabel3.backgroundColor = [UIColor whiteColor];
        _stepNumLabel3.textColor = [UIColor colorWithHex:@"919191"];
        _lineView3.backgroundColor = [UIColor colorWithHex:@"919191"];
    }
}
@end

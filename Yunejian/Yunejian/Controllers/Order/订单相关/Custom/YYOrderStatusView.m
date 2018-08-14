//
//  YYOrderStatusView.m
//  Yunejian
//
//  Created by Apple on 15/11/25.
//  Copyright © 2015年 yyj. All rights reserved.
//

#import "YYOrderStatusView.h"

@implementation YYOrderStatusView
NSInteger progressBarHeight = 6;
NSInteger progressDotBgHeight = 21;
NSInteger progressDotHeight = 15;
NSInteger leftRightSpace = 60;//24
NSInteger itemWidth = 95;
NSInteger itemSpace = 0;
NSInteger itemMaxNum = 6;
NSInteger curItemNum = 1;
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(UILabel *)getTitleLabel:(NSInteger)key{
    if(key == 1){
        return  _titleLabel1;
    }else if(key == 2){
        return  _titleLabel2;
    }else if(key == 3){
        return  _titleLabel3;
    }else if(key == 4){
        return  _titleLabel4;
    }else if(key == 5){
        return  _titleLabel5;
    }else{
        return  _titleLabel6;
    }
}

-(void)updateUI{
    curItemNum = [_titleArray count];
    for (int i=1; i<=itemMaxNum; i++) {
        UILabel *titleLabel = [self valueForKey:[NSString stringWithFormat:@"titleLabel%d",i]];
        
        if(i <= curItemNum){
            titleLabel.adjustsFontSizeToFitWidth = YES;
            titleLabel.text = [_titleArray objectAtIndex:(i-1)];
        }else{
            titleLabel.text = @"";
        }
    }
    _progressLayoutLeftConstraint.constant = leftRightSpace+itemWidth/2+(itemMaxNum-curItemNum)*(itemWidth+itemSpace);
    _progressView.layer.cornerRadius = (progressBarHeight)/2;
    _progressView.layer.masksToBounds = YES;
    _progressDotBgView.layer.cornerRadius = progressDotBgHeight/2;
    _progressDotView.layer.cornerRadius = progressDotHeight/2;
    _progressDotBgView.layer.masksToBounds = YES;
    _progressDotView.layer.masksToBounds = YES;
    
    _progressView.layer.borderWidth = 2;
    _progressView.layer.borderColor = [[[UIColor colorWithHex:kDefaultImageColor] colorWithAlphaComponent:1] CGColor];
    _progressView.progressTintColor = [UIColor colorWithHex:_progressTintColor];//@"ed6498"
    _progressView.trackTintColor = [UIColor lightGrayColor];
    _progressDotBgView.backgroundColor = [[UIColor colorWithHex:kDefaultImageColor]  colorWithAlphaComponent:1];
    _progressDotView.backgroundColor = [UIColor colorWithHex:_progressTintColor];
   
    [self setProgressValue:1];
    
    //遮罩
//    _showIndex = 0;
//    _showNum = 2;
    
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    CGRect maskRect = CGRectMake([self getClipX:_showIndex], 0,[self getClipX:_showNum], 100);
    // Create a path and add the rectangle in it.
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, nil, maskRect);
    // Set the path to the mask layer.
    [maskLayer setPath:path];
     self.layer.mask = maskLayer;
}

-(void)setProgressValue:(float) value{
    _progressView.progress = [self getProgressValue:value];
    NSInteger centerX = [self getCenterXValue:value];
    _dotBgLayoutCenterXConstraint.constant = centerX;
    _dotLayoutCenterXConstaint.constant = centerX;
    _timerLabelLayoutCenterXConstaint.constant = centerX;
}

-(NSInteger)getCenterXValue:(float) value{
    return (itemWidth+itemSpace)*(value) - (itemWidth+itemSpace)*(itemMaxNum-1)/2;
}
-(float)getProgressValue:(float) value{
    return (float)(value+0.5) / (curItemNum-1);
}
-(NSInteger)getClipX:(NSInteger)value{
    if(value > 0){
        return leftRightSpace+value*(itemWidth+itemSpace)-itemSpace/2;
    }
    return 0;
}
@end

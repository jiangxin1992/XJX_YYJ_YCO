//
//  YYSeriesTagsView.m
//  Yunejian
//
//  Created by Apple on 16/5/16.
//  Copyright © 2016年 yyj. All rights reserved.
//

#import "YYSeriesTagsView.h"

static NSInteger tageVSpace = 35;//水平间距
static NSInteger tageHSpace = 23;//垂直间距
static NSInteger boxSpace = 10;//边缘间距
static NSInteger tageHeight = 25;

@implementation YYSeriesTagsView{
    UIButton *selectedButton;
    NSArray *titleArr;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)createTags:(NSArray*)data selectedIndex:(NSInteger)index{
//    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        [obj removeFromSuperview];
//    }];
    for (UIButton *button in self.subviews) {
        if ([button isKindOfClass:[UIButton class]]) {
            [button removeTarget:self action:@selector(handleButton:) forControlEvents:UIControlEventTouchUpInside];
        }
        [button removeFromSuperview];
    }
    //self.frame =CGRectMake(0, 150, [UIScreen mainScreen].bounds.size.width, 25);
    self.backgroundColor = [UIColor whiteColor];
    int width = 0;
    int height = 0;
    int number = 0;
    int han = 0;
    int viewHeight = 0;//data;//
    titleArr = data;//@[@"医德高尚",@"非常耐心",@"回复非常及时、满意",@"意见很有帮助",@"非常认真敬业",@"非常清楚",@"回复非常及时、满意",@"由衷的感谢您老师",@"非常专业",@"德医双好"];
    //创建button
    for (int i = 0; i < titleArr.count; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = 0;
        //[button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        
        CGSize titleSize = [titleArr[i] boundingRectWithSize:CGSizeMake(999, 25) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13]} context:nil].size;
        titleSize.width += (5 + tageHeight);
        
        //自动的折行
        han = han +titleSize.width+(han==0?boxSpace:tageVSpace);;
        float maxWidth = SCREEN_WIDTH-250-60-80;//CGRectGetWidth(self.frame);
        if (han > maxWidth) {
            han = 0;
            han = han + titleSize.width;
            height++;
            width = 0;
            width = width+titleSize.width;
            number = 0;
            button.frame = CGRectMake(boxSpace, boxSpace +(tageHSpace+tageHeight)*height, titleSize.width, tageHeight);
        }else{
            button.frame = CGRectMake(width+boxSpace+(number*tageVSpace), boxSpace +(tageHSpace+tageHeight)*height, titleSize.width, tageHeight);
            width = width+titleSize.width;
        }
        number++;
       // button.layer.masksToBounds = YES;
        button.layer.cornerRadius = tageHeight/2;
        button.layer.borderColor = [UIColor colorWithHex:@"efefef"].CGColor;
        button.layer.borderWidth = 1;
        button.backgroundColor = [UIColor whiteColor];
        button.titleLabel.font = [UIFont systemFontOfSize:13];
        button.contentEdgeInsets = UIEdgeInsetsMake(0, 14, 0, 0);
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        NSArray *btnTitleInfo = [titleArr[i] componentsSeparatedByString:@":"];
        if([btnTitleInfo count] > 1){
            NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString: [NSString stringWithFormat:@"%@ %@",[btnTitleInfo objectAtIndex:0],[btnTitleInfo objectAtIndex:1]]];
            [attributedStr addAttribute: NSForegroundColorAttributeName value: [UIColor colorWithHex:@"919191"] range: NSMakeRange(0, ((NSString *)[btnTitleInfo objectAtIndex:1]).length+((NSString *)[btnTitleInfo objectAtIndex:0]).length+1)];
            [button setAttributedTitle:attributedStr forState:UIControlStateNormal];
        }else{
            [button setTitle:titleArr[i] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor colorWithHex:@"919191"] forState:UIControlStateNormal];

        }

        [self addSubview:button];
        [button addTarget:self action:@selector(handleButton:) forControlEvents:UIControlEventTouchUpInside];
        [button setEnlargeEdgeWithTop:_btnEdgeInsets.top right:_btnEdgeInsets.right bottom:_btnEdgeInsets.bottom left:_btnEdgeInsets.left];
        button.tag = i;
        if(index == i){
            [self handleButton:button];
        }
        button.tag = 300 + i;//防回调
        viewHeight = CGRectGetMaxY(button.frame);
    }
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width,boxSpace + viewHeight);
}

/**
 *  btn的相应事件，改变颜色并且添加一个imageView
 *
 */
- (void)handleButton:(UIButton *)button{
    button.selected = !button.selected;
    NSInteger btnTage = ((button.tag >= 300)?(button.tag-300):button.tag);
    if(selectedButton != nil){
        //selectedButton.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        button.frame = CGRectMake(CGRectGetMinX(button.frame), CGRectGetMinY(button.frame), CGRectGetWidth(button.frame)-8, CGRectGetHeight(button.frame));
        button.layer.borderColor = [UIColor colorWithHex:@"efefef"].CGColor;

        NSArray *btnTitleInfo = [titleArr[btnTage] componentsSeparatedByString:@":"];
        if([btnTitleInfo count] > 1){
            NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString: [NSString stringWithFormat:@"%@ %@",[btnTitleInfo objectAtIndex:0],[btnTitleInfo objectAtIndex:1]]];
            [attributedStr addAttribute: NSForegroundColorAttributeName value: [UIColor colorWithHex:@"919191"] range: NSMakeRange(0, ((NSString *)[btnTitleInfo objectAtIndex:1]).length+((NSString *)[btnTitleInfo objectAtIndex:0]).length+1)];
            [button setAttributedTitle:attributedStr forState:UIControlStateNormal];
        }else{
            [button setTitle:titleArr[btnTage] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor colorWithHex:@"919191"] forState:UIControlStateNormal];
        }

        button.backgroundColor = [UIColor whiteColor];
        selectedButton.backgroundColor = [UIColor whiteColor];
        UIImageView *imageView=(UIImageView *)[selectedButton viewWithTag:10];
        [imageView removeFromSuperview];
    }
    
    if (button.selected) {
        NSLog(@"%f,%ld",button.frame.size.width,(long)button.tag);
        float bWidth = tageHeight;
        button.frame = CGRectMake(CGRectGetMinX(button.frame), CGRectGetMinY(button.frame), CGRectGetWidth(button.frame)+8, CGRectGetHeight(button.frame));
        //button.backgroundColor = [UIColor colorWithHex:@"efefef"];
        button.layer.borderColor = [UIColor colorWithHex:@"000000"].CGColor;

        float a= CGRectGetMaxX(button.frame) -bWidth/2;
        
        if(_needCancelImg){
        UIImageView *imageView=[[UIImageView alloc]initWithFrame:CGRectMake(a, CGRectGetMinY(button.frame), bWidth, bWidth)];
        //imageView.backgroundColor=[UIColor blackColor];
        imageView.image = [UIImage imageNamed:@"daterangecancel_icon"];
        imageView.tag=10;
        [self addSubview:imageView];
        }
//        imageView.layer.cornerRadius = bWidth/2;
//        imageView.layer.borderColor = [UIColor whiteColor].CGColor;
//        imageView.layer.borderWidth = 2;
//        imageView.layer.masksToBounds = YES;
        NSArray *btnTitleInfo = [titleArr[btnTage] componentsSeparatedByString:@":"];
        if([btnTitleInfo count] > 1){
            NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString: [NSString stringWithFormat:@"%@ %@",[btnTitleInfo objectAtIndex:0],[btnTitleInfo objectAtIndex:1]]];
            [button setAttributedTitle:attributedStr forState:UIControlStateNormal];
        }else{
            [button setTitle:titleArr[btnTage] forState:UIControlStateNormal];
        }
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];

        selectedButton = button;
    }else{
       // button.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        NSArray *btnTitleInfo = [titleArr[btnTage] componentsSeparatedByString:@":"];
        if([btnTitleInfo count] > 1){
            NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString: [NSString stringWithFormat:@"%@ %@",[btnTitleInfo objectAtIndex:0],[btnTitleInfo objectAtIndex:1]]];
            [attributedStr addAttribute: NSForegroundColorAttributeName value: [UIColor colorWithHex:@"919191"] range: NSMakeRange(0, ((NSString *)[btnTitleInfo objectAtIndex:1]).length+((NSString *)[btnTitleInfo objectAtIndex:0]).length+1)];
            [button setAttributedTitle:attributedStr forState:UIControlStateNormal];
        }else{
            [button setTitle:titleArr[btnTage] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor colorWithHex:@"919191"] forState:UIControlStateNormal];

        }

        button.backgroundColor = [UIColor whiteColor];
        if(_needCancelImg){
        UIImageView *imageView=(UIImageView *)[button viewWithTag:10];
        [imageView removeFromSuperview];
        }
        selectedButton = nil;
    }
    if(self.selectedValue && button.tag >= 300){
        NSString *value = [NSString stringWithFormat:@"%ld|%hhd",button.tag-300,button.selected];
        self.selectedValue(value);
    }
}

+(float)viewHeight:(NSArray*)data viewWidth:(float)maxWidth{
    int width = 0;
    int height = 0;
    int number = 0;
    int han = 0;
    int viewHeight = 0;
    CGRect btnFrame;//data;//
    NSArray *titleArr = data;//@[@"医德高尚",@"非常耐心",@"回复非常及时、满意",@"意见很有帮助",@"非常认真敬业",@"非常清楚",@"回复非常及时、满意",@"由衷的感谢您老师",@"非常专业",@"德医双好"];
    for (int i = 0; i < titleArr.count; i++) {
        CGSize titleSize = [titleArr[i] boundingRectWithSize:CGSizeMake(999, 25) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]} context:nil].size;
        titleSize.width += (5 + tageHeight);
        
        //自动的折行
        han = han +titleSize.width+(han==0?boxSpace:tageVSpace);
        if (han > maxWidth) {
            han = 0;
            han = han + titleSize.width;
            height++;
            width = 0;
            width = width+titleSize.width;
            number = 0;
            btnFrame= CGRectMake(boxSpace, boxSpace +(tageHSpace+tageHeight)*height, titleSize.width, tageHeight);
        }else{
            btnFrame = CGRectMake(width+boxSpace+(number*tageVSpace), boxSpace +(tageHSpace+tageHeight)*height, titleSize.width, tageHeight);
            width = width+titleSize.width;
        }

        
        viewHeight = CGRectGetMaxY(btnFrame)+boxSpace;
    }
    return viewHeight +((height >1)?48:37)-boxSpace;
}

@end


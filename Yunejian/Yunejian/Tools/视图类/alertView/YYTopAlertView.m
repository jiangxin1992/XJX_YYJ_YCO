//
//  YYTopAlertView.m
//  Yunejian
//
//  Created by Apple on 16/1/29.
//  Copyright © 2016年 yyj. All rights reserved.
//

#import "YYTopAlertView.h"

#import "UIView+Draw.h"

#define MOZ_TEXTSIZE(text, font) [text length] > 0 ? [text \
sizeWithAttributes:@{NSFontAttributeName:font}] : CGSizeZero;

//#define hsb(h,s,b) [UIColor colorWithHue:h/360.0f saturation:s/100.0f brightness:b/100.0f alpha:0.9]
//
//#define FlatSkyBlue hsb(204, 76, 86)
//#define FlatGreen hsb(145, 77, 80)
//#define FlatOrange hsb(28, 85, 90)
//#define FlatRed hsb(6, 74, 91)
//#define FlatSkyBlueDark hsb(204, 78, 73)
//#define FlatGreenDark hsb(145, 78, 68)
//#define FlatOrangeDark hsb(24, 100, 83)
//#define FlatRedDark hsb(6, 78, 75)

#define LogoView_Margin_Top  9
#define LogoView_Margin_Lefe  12
#define LogoView_Margin_Right  12
#define AlertView_MAX_Width  470
#define AlertView_MIN_Width  185
#define AlertView_Height  39
#define AlertView_Move_Value  135
@interface YYTopAlertView (){
    UIView *leftIcon;
}

@property (nonatomic, copy) dispatch_block_t nextTopAlertBlock;
@property(nonatomic, assign)NSInteger type;
@property(nonatomic, assign)NSInteger parentViewWidth;

@end
@implementation YYTopAlertView
- (UIImage *)createImageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (BOOL)hasViewWithParentView:(UIView*)parentView{
    if ([self viewWithParentView:parentView]) {
        return YES;
    }
    return NO;
}

+ (YYTopAlertView*)viewWithParentView:(UIView*)parentView{
    NSArray *array = [parentView subviews];
    for (UIView *view in array) {
        if ([view isKindOfClass:[YYTopAlertView class]]) {
            return (YYTopAlertView *)view;
        }
    }
    return nil;
}

+ (YYTopAlertView*)viewWithParentView:(UIView*)parentView cur:(UIView*)cur{
    NSArray *array = [parentView subviews];
    for (UIView *view in array) {
        if ([view isKindOfClass:[YYTopAlertView class]] && view!=cur) {
            return (YYTopAlertView *)view;
        }
    }
    return nil;
}

+ (void)hideViewWithParentView:(UIView*)parentView{
    NSArray *array = [parentView subviews];
    for (UIView *view in array) {
        if ([view isKindOfClass:[YYTopAlertView class]]) {
            YYTopAlertView *alert = (YYTopAlertView *)view;
            [alert hide];
        }
    }
}

+ (YYTopAlertView*)showWithType:(YYTopAlertType)type text:(NSString*)text parentView:(UIView*)parentView{
    if(parentView == nil){
        parentView = [[UIApplication sharedApplication] delegate].window.rootViewController.view;
    }
    YYTopAlertView *alertView = [[YYTopAlertView alloc]initWithType:type text:text doText:nil parentView:parentView];
    [parentView addSubview:alertView];
    [alertView show];
    return alertView;
}

+ (YYTopAlertView*)showWithType:(YYTopAlertType)type text:(NSString*)text doText:(NSString*)doText doBlock:(dispatch_block_t)doBlock parentView:(UIView*)parentView{
    if(parentView == nil){
        parentView = [[UIApplication sharedApplication] delegate].window.rootViewController.view;
    }
    YYTopAlertView *alertView = [[YYTopAlertView alloc]initWithType:type text:text doText:doText parentView:parentView];
    alertView.doBlock = doBlock;
    [parentView addSubview:alertView];
    [alertView show];
    return alertView;
}

- (instancetype)initWithType:(YYTopAlertType)type text:(NSString*)text doText:(NSString*)doText parentView:(UIView*)parentView
{
    self = [super init];
    if (self) {
        NSArray *textInfo = [text componentsSeparatedByString:@"|"];
        NSString *textMsg = [textInfo objectAtIndex:0];
        NSInteger posOffsetX = 0;
        if ([textInfo count] > 1) {
            posOffsetX = [[textInfo objectAtIndex:1] integerValue];
        }
        [self setType:type text:textMsg doText:doText parentViewWidth:CGRectGetWidth(parentView.frame)-posOffsetX];
    }
    return self;
}

- (void)setType:(YYTopAlertType)type text:(NSString*)text parentViewWidth:(NSInteger)parentViewWidth{
    [self setType:type text:text doText:nil parentViewWidth:parentViewWidth];
}

- (void)setType:(YYTopAlertType)type text:(NSString*)text doText:(NSString*)doText parentViewWidth:(NSInteger)parentViewWidth{
    _autoHide = YES;
    _duration = 2;
    _type = type;
    _parentViewWidth = parentViewWidth;
    CGFloat width = AlertView_MAX_Width;
    [self setFrame:CGRectMake((_parentViewWidth - width)*0.5, -AlertView_Height, width, AlertView_Height)];
    
    leftIcon = [[UIView alloc]initWithFrame:CGRectMake(LogoView_Margin_Lefe, LogoView_Margin_Top, CGRectGetHeight(self.frame), CGRectGetHeight(self.frame))];
    leftIcon.backgroundColor = [UIColor clearColor];
    [self addSubview:leftIcon];
    
    //UIView *leftLine = [[UIView alloc]initWithFrame:CGRectMake(3, 0, 3, CGRectGetHeight(self.frame))];
    //leftLine.backgroundColor = [UIColor whiteColor];
    //[self addSubview:leftLine];
    
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = CGRectGetHeight(self.frame)/2;
    UIColor *doBtnColor = [UIColor colorWithHex:@"47a3dcee"];
    switch (type) {
        case YYTopAlertTypeInfo:{
            self.backgroundColor = [UIColor colorWithHex:@"47a3dcee"];
            //leftIcon.hidden = YES;
            doBtnColor = [UIColor colorWithHex:@"47a3dcee"];
        }
            break;
        case YYTopAlertTypeSuccess:
            self.backgroundColor = [UIColor colorWithHex:@"58c776ee"];
            //leftIcon.text = [NSString fontAwesomeIconStringForEnum:FACheckCircle];
            //[leftIcon hh_drawCheckmark];
            doBtnColor = [UIColor colorWithHex:@"58c776ee"];
            width -= CGRectGetWidth(leftIcon.frame);
            break;
        case YYTopAlertTypeWarning:
            self.backgroundColor = [UIColor colorWithHex:@"ffe000ee"];
            //leftIcon.text = [NSString fontAwesomeIconStringForEnum:FAExclamationCircle];
            //[leftIcon hh_drawCheckWarning];
            doBtnColor = [UIColor colorWithHex:@"ffe000ee"];
            width -= CGRectGetWidth(leftIcon.frame);
            break;
        case YYTopAlertTypeError:
            self.backgroundColor = [UIColor colorWithHex:@"ef4e31ee"];
            //[leftIcon hh_drawCheckError];
            width -= CGRectGetWidth(leftIcon.frame);
            //leftIcon.text = [NSString fontAwesomeIconStringForEnum:FATimesCircle];
            doBtnColor = [UIColor colorWithHex:@"ef4e31ee"];
            break;
        default:
            break;
    }
    //计算剩余宽度
    width -= (40+LogoView_Margin_Right);
    CGSize doBtnSize = CGSizeMake(0, 0);
    if(doText){
        doBtnSize = MOZ_TEXTSIZE(doText,[UIFont boldSystemFontOfSize:15]);
        doBtnSize.width += LogoView_Margin_Right;
    }
    width -= doBtnSize.width;
    //设置文本宽度 重置frame
    CGSize messageTxtSize = MOZ_TEXTSIZE(text,[UIFont boldSystemFontOfSize:16]);
    CGFloat lastWidth = width - messageTxtSize.width;
    CGFloat textLabelWidth =MIN(width, messageTxtSize.width);
    width = AlertView_MAX_Width - MAX(lastWidth, 0);
    width = MAX(width, AlertView_MIN_Width);
    [self setFrame:CGRectMake((_parentViewWidth - width)*0.5, -AlertView_Height, width, AlertView_Height)];
    
    UILabel *textLabel = [[UILabel alloc]initWithFrame:CGRectMake(width - textLabelWidth-doBtnSize.width-LogoView_Margin_Right, 0, textLabelWidth, CGRectGetHeight(self.frame))];
    textLabel.backgroundColor = [UIColor clearColor];
    [textLabel setTextColor:[UIColor whiteColor]];
    textLabel.textAlignment = NSTextAlignmentLeft;//NSTextAlignmentCenter;
    textLabel.font = [UIFont systemFontOfSize:16];
    textLabel.text = text;
    [self addSubview:textLabel];
    
    if (doText) {
        _duration = 4;
        UIButton * rightBtn = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.frame) - 50, 0, 50, CGRectGetHeight(self.frame))];
        
        [rightBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
        
        NSMutableAttributedString *content = [[NSMutableAttributedString alloc]initWithString:doText];
        NSRange contentRange = {0,[content length]};
        [content addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:contentRange];
        [content addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:contentRange];
        [rightBtn setAttributedTitle:content forState:UIControlStateNormal];
        
        [rightBtn setBackgroundImage:[self createImageWithColor:self.backgroundColor] forState:UIControlStateNormal];
        [rightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        CGSize size = MOZ_TEXTSIZE(doText, rightBtn.titleLabel.font);
        
        CGFloat rightBtnWidth = size.width + LogoView_Margin_Right;
        rightBtn.frame = CGRectMake(CGRectGetWidth(self.frame) - rightBtnWidth, 0, rightBtnWidth, CGRectGetHeight(self.frame));
        
        //textLabel.frame = CGRectMake((width - textLabelWidth)*0.5, 0, textLabelWidth + 30 - rightBtnWidth, CGRectGetHeight(self.frame));
        
        [rightBtn addTarget:self action:@selector(rightBtnAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:rightBtn];
        UIView *rightLine = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.frame) - rightBtnWidth - 3, 0, 3, CGRectGetHeight(self.frame))];
        rightLine.backgroundColor = [UIColor whiteColor];
        [self addSubview:rightLine];
    }
    
    leftIcon.layer.opacity = 0;
    
    //    [self show];
}

- (void)rightBtnAction{
    if (_doBlock) {
        _doBlock();
        _doBlock = nil;
    }
}

- (void)show{
    dispatch_block_t showBlock = ^{
        [UIView animateWithDuration:0.8 delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:1 options:UIViewAnimationOptionCurveLinear animations:^{
            self.layer.position = CGPointMake(self.layer.position.x, self.layer.position.y + AlertView_Move_Value);
        } completion:^(BOOL finished) {
            leftIcon.layer.opacity = 1;
            //            leftIcon.transform = CGAffineTransformMakeScale(0, 0);
            //
            //            [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:1 options:UIViewAnimationOptionCurveLinear animations:^{
            //                leftIcon.transform = CGAffineTransformMakeScale(1, 1);
            //            } completion:^(BOOL finished) {
            //            }];
            //
            NSInteger iconSize = CGRectGetHeight(self.frame)-LogoView_Margin_Top*2;
            switch (_type) {
                case YYTopAlertTypeInfo:
                    break;
                case YYTopAlertTypeSuccess:
                    [leftIcon hh_drawCheckmark:iconSize];
                    break;
                case YYTopAlertTypeWarning:
                    [leftIcon hh_drawCheckWarning:iconSize];
                    break;
                case YYTopAlertTypeError:
                    [leftIcon hh_drawCheckError:iconSize];
                    break;
                default:
                    break;
            }
        }];
        
        [self performSelector:@selector(hide) withObject:nil afterDelay:_duration];
    };
    
    YYTopAlertView *lastAlert = [YYTopAlertView viewWithParentView:self.superview cur:self];
    if (lastAlert) {
        lastAlert.nextTopAlertBlock = ^{
            showBlock();
        };
        [lastAlert hide];
    }else{
        showBlock();
    }
}

- (void)hide{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hide) object:nil];
    [UIView animateWithDuration:0.2 animations:^{
        self.layer.position = CGPointMake(self.layer.position.x, self.layer.position.y - AlertView_Move_Value);
    } completion:^(BOOL finished) {
        if (_nextTopAlertBlock) {
            _nextTopAlertBlock();
            _nextTopAlertBlock = nil;
        }
        self.hidden = YES;
        [self removeFromSuperview];
    }];
    
    if (_dismissBlock) {
        _dismissBlock();
        _dismissBlock = nil;
    }
}

-(void)setDuration:(NSInteger)duration{
    _duration = duration;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hide) object:nil];
    [self performSelector:@selector(hide) withObject:nil afterDelay:_duration];
}

-(void)setAutoHide:(BOOL)autoHide{
    if (autoHide && !_autoHide) {
        [self performSelector:@selector(hide) withObject:nil afterDelay:_duration];
    }else{
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hide) object:nil];
    }
    _autoHide = autoHide;
}

-(void)dealloc{
    _doBlock = nil;
    _dismissBlock = nil;
    _nextTopAlertBlock = nil;
}



@end

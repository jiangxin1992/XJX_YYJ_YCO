//
//  MXPullDownMenu000.m
//  MXPullDownMenu
//
//  Created by 
//  Copyright (c) 2014年 Mx. All rights reserved.
//

// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com

#import "MXPullDownMenu.h"

@implementation MXPullDownMenu
{
    
    UIColor *_menuColor;
    UIColor *_selectColor;

    UIView *_backGroundView;
    UITableView *_tableView;
    

    NSMutableArray *_titleLabel;//存储文字
    NSMutableArray *_indicators;
    
    
    NSInteger _currentSelectedMenudIndex;
    bool _show;
    
    NSInteger _numOfMenu;
    
    NSArray *_array;
    

}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
    
    }
    return self;
}

- (MXPullDownMenu *)initWithArray:(NSArray *)array selectedColor:(UIColor *)color menuSize:(CGSize)size
{
    self = [super init];
    if (self) {
        
        self.frame = CGRectMake(0, 0, size.width, size.height);
        _tableViewRowHeight = 36;
        _cellFontSize = 18;
        _menuColor = [UIColor redColor];
        _selectColor = color;
        _array = array;
        _numOfMenu = _array.count;
        
        CGFloat textLayerInterval = self.frame.size.width / ( _numOfMenu * 2);
        CGFloat separatorLineInterval = self.frame.size.width / _numOfMenu;
        
        _indicators = [[NSMutableArray alloc] initWithCapacity:_numOfMenu];
        _titleLabel = [[NSMutableArray alloc] initWithCapacity:_numOfMenu];
        
        for (int i = 0; i < _numOfMenu; i++) {
            
            CGPoint position = CGPointMake( (i * 2/* + 1*/) * textLayerInterval , 0);

            UILabel *label = [self creatTextLayerWithNSString:_array[i][0] withColor:_menuColor andPosition:position];
            [self addSubview:label];
            [_titleLabel addObject:label];

            
            
            CAShapeLayer *indicator = [self creatIndicatorWithColor:_menuColor andPosition:CGPointMake(position.x + label.bounds.size.width , self.frame.size.height / 2)];
            [self.layer addSublayer:indicator];
            [_indicators addObject:indicator];
            
            if (i != _numOfMenu - 1) {
                CGPoint separatorPosition = CGPointMake((i + 1) * separatorLineInterval, self.frame.size.height / 2);
                CAShapeLayer *separator = [self creatSeparatorLineWithColor:[UIColor colorWithRed:239.0/255.0 green:239.0/255.0 blue:243.0/255.0 alpha:1.0] andPosition:separatorPosition];
                [self.layer addSublayer:separator];
            }
            
        }
        _tableView = [self creatTableViewAtPosition:CGPointMake(0, self.frame.origin.y + self.frame.size.height)];
       // _tableView.tintColor = color;
        _tableView.dataSource = self;
        _tableView.delegate = self;
        
        //修复分割线左边空15格像素
        if ([_tableView respondsToSelector:@selector(setSeparatorInset:)])
        {
            //7.0
            [_tableView setSeparatorInset:UIEdgeInsetsZero];
        }
        
        if ([_tableView respondsToSelector:@selector(setLayoutMargins:)])
        {
            //在8.0系统下
            [_tableView setLayoutMargins:UIEdgeInsetsZero];
        }
        
        // 设置menu, 并添加手势
        self.backgroundColor = [UIColor clearColor];
        self.layer.borderColor = [UIColor blackColor].CGColor;
        self.layer.borderWidth = 2;
        UIGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapMenu:)];
        [self addGestureRecognizer:tapGesture];
        
        // 创建背景
        _backGroundView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _backGroundView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.4];
        _backGroundView.opaque = NO;
        UIGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBackGround:)];
        [_backGroundView addGestureRecognizer:gesture];
         
        _currentSelectedMenudIndex = -1;
        _show = NO;
    }
    return self;
}



#pragma mark - tapEvent



// 处理菜单点击事件.
- (void)tapMenu:(UITapGestureRecognizer *)paramSender
{
    CGPoint touchPoint = [paramSender locationInView:self];
    
    // 得到tapIndex
    
    NSInteger tapIndex = touchPoint.x / (self.frame.size.width / _numOfMenu);
    

    
    for (int i = 0; i < _numOfMenu; i++) {
        if (i != tapIndex) {
            [self animateIndicator:_indicators[i] Forward:NO complete:^{
                [self animateTitle:_titleLabel[i] show:NO complete:^{
                }];
            }];
        }
    }
    
    
    if (tapIndex == _currentSelectedMenudIndex && _show) {
        
        [self animateIdicator:_indicators[_currentSelectedMenudIndex] background:_backGroundView tableView:_tableView title:_titleLabel[_currentSelectedMenudIndex] forward:NO complecte:^{
            _currentSelectedMenudIndex = tapIndex;
            _show = NO;
            
        }];
        
    } else {
        
        _currentSelectedMenudIndex = tapIndex;
        [_tableView reloadData];
        [self animateIdicator:_indicators[tapIndex] background:_backGroundView tableView:_tableView title:_titleLabel[tapIndex] forward:YES complecte:^{
            _show = YES;
        }];
        
    }

 

}

- (void)tapBackGround:(UITapGestureRecognizer *)paramSender
{
    [self animateIdicator:_indicators[_currentSelectedMenudIndex] background:_backGroundView tableView:_tableView title:_titleLabel[_currentSelectedMenudIndex] forward:NO complecte:^{
        _show = NO;
    }];

}


#pragma mark - tableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  
    [self confiMenuWithSelectRow:indexPath.row];
    [self.delegate PullDownMenu:self didSelectRowAtColumn:_currentSelectedMenudIndex row:indexPath.row];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 1;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (0 == section) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 1.0)];//这时候最小是1
        UIView *view2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 1.0 / [UIScreen mainScreen].scale)];
        view2.backgroundColor = [UIColor colorWithHex:@"0x9e9e9e"];//[[Tool ColorWithString:@"9e9e9e"] colorWithAlphaComponent:0.6];
        [view addSubview:view2];
        return view;
    }
    return nil;
}

#pragma mark tableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_array[_currentSelectedMenudIndex] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        //cell.textLabel.font = [UIFont systemFontOfSize:13.0];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    [cell.textLabel setTextColor:[UIColor grayColor]];
    [cell setAccessoryType:UITableViewCellAccessoryNone];
    
    NSString *showStr = _array[_currentSelectedMenudIndex][indexPath.row];
    cell.textLabel.text = showStr;
    cell.textLabel.font = [UIFont systemFontOfSize:19];
    cell.textLabel.textColor = [UIColor colorWithHex:@"0x505050"];

//    NSRange termRange = [showStr rangeOfString:@"期"];
//    if (termRange.length > 0) {
//        NSMutableAttributedString *attribute = [[NSMutableAttributedString alloc] initWithString:showStr];
//        [attribute addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:termRange];
//        cell.textLabel.attributedText = attribute;
//    }
    
    if ([cell.textLabel.text isEqualToString:((UILabel *)[_titleLabel objectAtIndex:_currentSelectedMenudIndex]).text]) {
        //当文字相同时 是否需要特殊提示
        //[cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        [cell.textLabel setTextColor:_selectColor];
    }
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return _tableViewRowHeight;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)])
    {
        //在7.0系统下
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)])
    {
        //在8.0系统下
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

#pragma mark - animation

- (void)animateIndicator:(CAShapeLayer *)indicator Forward:(BOOL)forward complete:(void(^)())complete
{
    [CATransaction begin];
    [CATransaction setAnimationDuration:0.25];
    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithControlPoints:0.4 :0.0 :0.2 :1.0]];
    
    CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation"];
    anim.values = forward ? @[ @0, @(M_PI) ] : @[ @(M_PI), @0 ];
    
    if (!anim.removedOnCompletion) {
        [indicator addAnimation:anim forKey:anim.keyPath];
    } else {
        [indicator addAnimation:anim andValue:anim.values.lastObject forKeyPath:anim.keyPath];
    }
    
    [CATransaction commit];
    
    indicator.fillColor = forward ? _selectColor.CGColor : _menuColor.CGColor;
    
    complete();
}





- (void)animateBackGroundView:(UIView *)view show:(BOOL)show complete:(void(^)())complete
{
    
    if (show) {
        [self.superview addSubview:view];
        [view.superview addSubview:self];

        [UIView animateWithDuration:0.2 animations:^{
            view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.3];
        }];
    
    } else {
        [UIView animateWithDuration:0.2 animations:^{
            view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];
        } completion:^(BOOL finished) {
            [view removeFromSuperview];
        }];
        
    }
    complete();
    
}

- (void)animateTableView:(UITableView *)tableView show:(BOOL)show complete:(void(^)())complete
{
    if(_showDirection == TableViewShowDirectionUp){
        if (show) {
            tableView.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y , self.frame.size.width, 0);
            [self.superview addSubview:tableView];
            
            CGFloat tableViewHeight = ([tableView numberOfRowsInSection:0] > 5) ? (5 * tableView.rowHeight) : ([tableView numberOfRowsInSection:0] * tableView.rowHeight);
            [UIView animateWithDuration:0.2 animations:^{
            _tableView.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y-tableViewHeight , self.frame.size.width, tableViewHeight);
            }];
        } else {
            [UIView animateWithDuration:0.2 animations:^{
                _tableView.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y , self.frame.size.width, 0);
            } completion:^(BOOL finished) {
            [tableView removeFromSuperview];
            }];
        }
    }else if(_showDirection == TableViewShowDirectionDown){
        if (show) {
            tableView.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y + self.frame.size.height, self.frame.size.width, 0);
            [self.superview addSubview:tableView];
            
            CGFloat tableViewHeight = ([tableView numberOfRowsInSection:0] > 5) ? (5 * tableView.rowHeight) : ([tableView numberOfRowsInSection:0] * tableView.rowHeight);
            [UIView animateWithDuration:0.2 animations:^{
                _tableView.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y + self.frame.size.height, self.frame.size.width, tableViewHeight);
            }];
            
        } else {
            [UIView animateWithDuration:0.2 animations:^{
                _tableView.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y + self.frame.size.height, self.frame.size.width, 0);
            } completion:^(BOOL finished) {
                [tableView removeFromSuperview];
            }];
        }
    }
    complete();
}

- (void)animateTitle:(UILabel *)title show:(BOOL)show complete:(void(^)())complete
{
    if (show) {
        title.textColor = _selectColor;
    } else {
        title.textColor = _menuColor;
    }
    
    
    CGSize size = [self calculateTitleSizeWithString:title.text];
    CGFloat sizeWidth = (size.width < (self.frame.size.width / _numOfMenu) - 28) ? size.width : self.frame.size.width / _numOfMenu - 25;
    title.bounds = CGRectMake(0, 0, sizeWidth, size.height);
    
    
    complete();
}

- (void)animateIdicator:(CAShapeLayer *)indicator background:(UIView *)background tableView:(UITableView *)tableView title:(UILabel *)title forward:(BOOL)forward complecte:(void(^)())complete{
    
    [self animateIndicator:indicator Forward:forward complete:^{
        [self animateTitle:title show:forward complete:^{
            [self animateBackGroundView:background show:forward complete:^{
                [self animateTableView:tableView show:forward complete:^{
                }];
            }];
        }];
    }];
    
    complete();
}


#pragma mark - drawing


- (CAShapeLayer *)creatIndicatorWithColor:(UIColor *)color andPosition:(CGPoint)point
{
    CAShapeLayer *layer = [CAShapeLayer new];
    
    UIBezierPath *path = [UIBezierPath new];
    [path moveToPoint:CGPointMake(0, 0)];
    [path addLineToPoint:CGPointMake(12, 0)];
    [path addLineToPoint:CGPointMake(6, 7)];
    [path closePath];
    
    layer.path = path.CGPath;
    layer.lineWidth = 1.0;
    layer.fillColor = color.CGColor;
    
    CGPathRef bound = CGPathCreateCopyByStrokingPath(layer.path, nil, layer.lineWidth, kCGLineCapButt, kCGLineJoinMiter, layer.miterLimit);
    layer.bounds = CGPathGetBoundingBox(bound);
    //新增CFRelease(bound) 用于释放bound
    CFRelease(bound);
    
    layer.position = point;
    
   // layer.contents = [UIImage imageNamed:@"OderDown.png"].CGImage;
    
    return layer;
}

- (CAShapeLayer *)creatSeparatorLineWithColor:(UIColor *)color andPosition:(CGPoint)point
{
    CAShapeLayer *layer = [CAShapeLayer new];
    
    UIBezierPath *path = [UIBezierPath new];
    [path moveToPoint:CGPointMake(160,0)];
    [path addLineToPoint:CGPointMake(160, 20)];
    
    layer.path = path.CGPath;
    layer.lineWidth = 1.0;
    layer.strokeColor = color.CGColor;
    
    CGPathRef bound = CGPathCreateCopyByStrokingPath(layer.path, nil, layer.lineWidth, kCGLineCapButt, kCGLineJoinMiter, layer.miterLimit);
    layer.bounds = CGPathGetBoundingBox(bound);
    //新增CFRelease(bound) 用于释放bound
    CFRelease(bound);
    
    layer.position = point;
    
    return layer;
}

- (UILabel *)creatTextLayerWithNSString:(NSString *)string withColor:(UIColor *)color andPosition:(CGPoint)point
{
    CGSize size = [self calculateTitleSizeWithString:string];
    CGFloat sizeWidth = (size.width < (self.frame.size.width / _numOfMenu) - 28) ? size.width : self.frame.size.width / _numOfMenu - 25;

    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(point.x, point.y, sizeWidth, size.height);
    label.text = string;
    label.font = [UIFont systemFontOfSize:_cellFontSize];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = color;
    return label;
}


- (UITableView *)creatTableViewAtPosition:(CGPoint)point
{
    UITableView *tableView = [UITableView new];
    
    tableView.frame = CGRectMake(point.x, point.y, self.frame.size.width, 0);
    tableView.rowHeight = _tableViewRowHeight;
    
    return tableView;
}


#pragma mark - otherMethods


- (CGSize)calculateTitleSizeWithString:(NSString *)string
{
    CGFloat fontSize = _cellFontSize;
    NSDictionary *dic = @{NSFontAttributeName: [UIFont systemFontOfSize:fontSize]};
    CGSize size = [string boundingRectWithSize:CGSizeMake(280, 0) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:dic context:nil].size;
    return CGSizeMake(size.width+7, size.height);
}

- (void)confiMenuWithSelectRow:(NSInteger)row
{
    
    UILabel *label = (UILabel *)_titleLabel[_currentSelectedMenudIndex];
    NSString *showStr = [[_array objectAtIndex:_currentSelectedMenudIndex] objectAtIndex:row];
    label.text = showStr;

    [self animateIdicator:_indicators[_currentSelectedMenudIndex] background:_backGroundView tableView:_tableView title:_titleLabel[_currentSelectedMenudIndex] forward:NO complecte:^{
        _show = NO;
        
    }];
    
    CAShapeLayer *indicator = (CAShapeLayer *)_indicators[_currentSelectedMenudIndex];
    indicator.position = CGPointMake(label.frame.origin.x + label.frame.size.width, indicator.position.y);
}


@end

#pragma mark - CALayer Category

@implementation CALayer (MXAddAnimationAndValue)

- (void)addAnimation:(CAAnimation *)anim andValue:(NSValue *)value forKeyPath:(NSString *)keyPath
{
    [self addAnimation:anim forKey:keyPath];
    [self setValue:value forKeyPath:keyPath];
}
@end

//
//  MXPullDownMenu000.h
//  MXPullDownMenu
//
//  Created 
//  Copyright (c) 2014年 Mx. All rights reserved.
//

// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com

#import <UIKit/UIKit.h>

@class MXPullDownMenu;

typedef enum
{
    IndicatorStateShow = 0,
    IndicatorStateHide
}
IndicatorStatus;

typedef enum
{
    BackGroundViewStatusShow = 0,
    BackGroundViewStatusHide
}
BackGroundViewStatus;

typedef enum
{
    TableViewShowDirectionUp = 0,
    TableViewShowDirectionDown
}
TableViewShowDirection;

@protocol MXPullDownMenuDelegate <NSObject>

- (void)PullDownMenu:(MXPullDownMenu *)pullDownMenu didSelectRowAtColumn:(NSInteger)column row:(NSInteger)row;

@end

@interface MXPullDownMenu : UIView<UITableViewDelegate, UITableViewDataSource>

- (MXPullDownMenu *)initWithArray:(NSArray *)array selectedColor:(UIColor *)color menuSize:(CGSize)size;

@property (nonatomic,weak) id<MXPullDownMenuDelegate> delegate;
@property (nonatomic,assign) TableViewShowDirection showDirection;
@property (nonatomic,assign) NSInteger tableViewRowHeight;
@property (nonatomic,assign) CGFloat cellFontSize;
@end
// CALayerCategory
@interface CALayer (MXAddAnimationAndValue)

- (void)addAnimation:(CAAnimation *)anim andValue:(NSValue *)value forKeyPath:(NSString *)keyPath;

@end

//
//  YYSeriesTagsView.h
//  Yunejian
//
//  Created by Apple on 16/5/16.
//  Copyright © 2016年 yyj. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface YYSeriesTagsView : UIView
@property (nonatomic,strong) SelectedValue selectedValue;
@property (nonatomic,assign) BOOL needCancelImg;
@property (nonatomic,assign) UIEdgeInsets btnEdgeInsets;
-(void)createTags:(NSArray*)data selectedIndex:(NSInteger)index;
+(float)viewHeight:(NSArray*)data viewWidth:(float)maxWidth;
@end

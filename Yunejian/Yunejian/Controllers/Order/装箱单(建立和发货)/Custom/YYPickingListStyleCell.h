//
//  YYPickingListStyleCell.h
//  yunejianDesigner
//
//  Created by yyj on 2018/6/17.
//  Copyright © 2018年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YYPackingListStyleModel;

typedef NS_ENUM(NSInteger, YYPickingListStyleType) {
    YYPickingListStyleTypeNormal,
    YYPickingListStyleTypePackageError
};

@interface YYPickingListStyleCell : UITableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier styleType:(YYPickingListStyleType)styleType;

@property (nonatomic, strong) YYPackingListStyleModel *packingListStyleModel;
@property (nonatomic, assign) BOOL isLastCell;

-(void)updateUI;

@end

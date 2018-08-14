//
//  YYDesignRegisterSubmitTableViewCell.h
//  Yunejian
//
//  Created by chuanjun sun on 2017/8/25.
//  Copyright © 2017年 yyj. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^submitQuestion)(NSInteger agree);

@interface YYDesignRegisterSubmitTableViewCell : UITableViewCell

/** 点击同意按钮 */
@property (nonatomic, copy) submitQuestion submitQuestion;

@end

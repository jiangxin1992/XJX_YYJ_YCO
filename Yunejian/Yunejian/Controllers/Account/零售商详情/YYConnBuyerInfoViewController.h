//
//  YYConnBuyerInfoViewController.h
//  Yunejian
//
//  Created by Apple on 15/12/11.
//  Copyright © 2015年 yyj. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface YYConnBuyerInfoViewController : UIViewController
@property (nonatomic,assign) NSInteger buyerId;
@property (nonatomic,strong) NSString *previousTitle;
@property (nonatomic,strong) ModifySuccess modifySuccess1;
@property (nonatomic,strong) ModifySuccess modifySuccess2;

@property (nonatomic,strong) CancelButtonClicked cancelButtonClicked;
@end

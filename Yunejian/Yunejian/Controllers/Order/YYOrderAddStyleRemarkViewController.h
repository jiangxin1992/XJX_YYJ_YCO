//
//  YYOrderAddStyleRemarkViewController.h
//  Yunejian
//
//  Created by Apple on 16/8/8.
//  Copyright © 2016年 yyj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYOrderStyleModel.h"
@interface YYOrderAddStyleRemarkViewController : UIViewController
@property(nonatomic,strong)ModifySuccess modifySuccess;
@property(nonatomic,strong)CancelButtonClicked cancelButtonClicked;
@property(nonatomic,strong)YYOrderStyleModel *orderStyleModel;
@end

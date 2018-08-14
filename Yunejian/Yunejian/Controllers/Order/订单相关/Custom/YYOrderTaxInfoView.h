//
//  YYOrderTaxInfoView.h
//  Yunejian
//
//  Created by Apple on 16/7/21.
//  Copyright © 2016年 yyj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYStylesAndTotalPriceModel.h"
#import "YYOrderInfoModel.h"
@interface YYOrderTaxInfoView : UIView
@property (weak,nonatomic) id<YYTableCellDelegate>  delegate;
@property (nonatomic,strong) NSIndexPath *indexPath;
@property (weak, nonatomic) IBOutlet UILabel *finalPriceLabel;
@property (weak, nonatomic) IBOutlet UIView *discountView;
@property (weak, nonatomic) IBOutlet UIView *taxView;
@property (weak, nonatomic) IBOutlet UILabel *originalPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalStyleLabel;
@property (weak, nonatomic) IBOutlet UIButton *helpBtn;
@property (weak, nonatomic) IBOutlet UIControl *taxTypeUI;
@property (weak, nonatomic) IBOutlet UILabel *taxTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *taxPriceLabel;
@property (weak, nonatomic) IBOutlet UIImageView *taxTypeUIDownImg;
@property (weak, nonatomic) IBOutlet UILabel *discountNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *discountPriceLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *discountViewLayoutTopConstraint;
@property (weak, nonatomic) IBOutlet UIView *topSpaceView;
@property (weak, nonatomic) IBOutlet UIView *bottomSpaceView;
@property (weak, nonatomic) IBOutlet UILabel *priceTitle;

@property (strong,nonatomic) NSMutableArray *menuData;

@property (nonatomic,assign) NSInteger selectIndex;

@property(nonatomic,copy) void (^taxChooseBlock)();

@property (nonatomic,assign) NSInteger spaceViewType;//o top 1 bottom
@property (nonatomic,assign) NSInteger moneyType;
@property (nonatomic,assign) NSInteger selectTaxType;
@property (nonatomic,assign) NSInteger viewType;//1创建订单  2修改订单 3订单详情 4追单
@property(nonatomic,strong) YYStylesAndTotalPriceModel *stylesAndTotalPriceModel;//总数
@property (strong, nonatomic) YYOrderInfoModel *currentYYOrderInfoModel;
@property (weak, nonatomic) UIViewController *parentController;
@property (nonatomic,assign) NSInteger isSimpleView;//0 修改页 1详情页
-(void)updateUI;
-(float)CellHeight;
@end

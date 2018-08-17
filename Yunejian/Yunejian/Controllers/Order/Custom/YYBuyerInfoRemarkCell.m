//
//  YYBuyerInfoRemarkCell.m
//  Yunejian
//
//  Created by Apple on 15/10/26.
//  Copyright © 2015年 yyj. All rights reserved.
//

#import "YYBuyerInfoRemarkCell.h"

#import "UIImage+YYImage.h"
#import "YYOrderTaxInfoView.h"
#import "YYStylesAndTotalPriceModel.h"

@interface YYBuyerInfoRemarkCell ()<UITextViewDelegate,YYTableCellDelegate>
@property (strong, nonatomic)YYOrderTaxInfoView *orderTaxInfoView;

@end
@implementation YYBuyerInfoRemarkCell
-(void)updateUI:(NSString*)info{
    self.txtView.text = info;
    //self.txtView.backgroundColor = [UIColor colorWithHex:kDefaultImageColor];
    if(_currentYYOrderInfoModel){
        [self updateTaxInfoUI];
    }
}

-(void)updateTaxInfoUI{
    
    if(_orderTaxInfoView == nil){
        NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"YYOrderSimpleTaxInfoView" owner:nil options:nil];
        Class targetClass = NSClassFromString(@"YYOrderTaxInfoView");
        for (UIView *view in views) {
            if ([view isMemberOfClass:targetClass]) {
                _orderTaxInfoView =  (YYOrderTaxInfoView *)view;
                break;
            }
        }
        [_taxInfoContainerView addSubview:_orderTaxInfoView];
        __weak UIView *weakView = _taxInfoContainerView;
        [_orderTaxInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(weakView.mas_top);
            make.left.mas_equalTo(weakView.mas_left);
            //make.bottom.mas_equalTo(weakView.mas_bottom);
            make.right.mas_equalTo(weakView.mas_right);
            make.height.mas_equalTo(150);
        }];
    }
    _orderTaxInfoView.menuData = _menuData;
    _orderTaxInfoView.delegate = self;
    _orderTaxInfoView.selectTaxType = getPayTaxTypeFormServiceNew(_menuData,[self.currentYYOrderInfoModel.taxRate integerValue]);
    _orderTaxInfoView.stylesAndTotalPriceModel = _stylesAndTotalPriceModel;
    _orderTaxInfoView.currentYYOrderInfoModel = _currentYYOrderInfoModel;
    _orderTaxInfoView.moneyType = [_currentYYOrderInfoModel.curType integerValue];
    _orderTaxInfoView.viewType = 3;
    _orderTaxInfoView.isSimpleView = 1;
    _orderTaxInfoView.parentController = _parentController;
    [_orderTaxInfoView updateUI];
    float viewHeight = [_orderTaxInfoView CellHeight];
    [_orderTaxInfoView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(viewHeight);
    }];
    
}

#pragma YYTableCellDelegate
-(void)btnClick:(NSInteger)row section:(NSInteger)section andParmas:(NSArray *)parmas{
//    NSString *type = [parmas objectAtIndex:0];
//    if([type isEqualToString:@"taxType"]){
//        _selectTaxType = [[parmas objectAtIndex:1] integerValue];
//        if(self.taxTypeButtonClicked){
//            self.taxTypeButtonClicked(_selectTaxType);
//        }
//    }else if([type isEqualToString:@"discount"]){
//        if(self.discountButtonClicked){
//            self.discountButtonClicked();
//        }
//    }
}
@end

//
//  YYOrderTaxInfoView.m
//  Yunejian
//
//  Created by Apple on 16/7/21.
//  Copyright © 2016年 yyj. All rights reserved.
//

#import "YYOrderTaxInfoView.h"

#import "UIView+UpdateAutoLayoutConstraints.h"
#import "YYNormalnfoItemCell.h"
#import "YYPopoverBackgroundView.h"
#import "YYHelpPanelViewController.h"
#import "YYPopoverArrowBackgroundView.h"
#import "YYTopAlertView.h"
#import "YYOrderModifyViewController.h"

@interface YYOrderTaxInfoView()

@property (nonatomic,strong) UIPopoverController *popController;

@end
@implementation YYOrderTaxInfoView

#pragma mark - UI
-(void)updateUI{
    if(_spaceViewType == 0){
        [_topSpaceView hideByHeight:NO];
        [_bottomSpaceView hideByHeight:YES];
    }else{
        [_topSpaceView hideByHeight:YES];
        [_bottomSpaceView hideByHeight:NO];
    }
    
    NSString *targetStr = [NSString stringWithFormat:NSLocalizedString(@"%i款 %i件",nil),_stylesAndTotalPriceModel.totalStyles,_stylesAndTotalPriceModel.totalCount];
    NSString *totalStylesStr = [NSString stringWithFormat:@"%i",_stylesAndTotalPriceModel.totalStyles];
    NSString *totalCountStr = [NSString stringWithFormat:@"%i",_stylesAndTotalPriceModel.totalCount];
    _totalStyleLabel.attributedText = [self getTextAttributedString:targetStr replaceStrs:@[totalStylesStr,totalCountStr]];//
   
    _originalPriceLabel.text =  replaceMoneyFlag([NSString stringWithFormat:@"￥%0.2f",[_stylesAndTotalPriceModel.originalTotalPrice floatValue]],_moneyType);
    
    double taxRate = 0;
    _discountNumLabel.textColor = [UIColor colorWithHex:@"47a3dc"];
    _taxTypeLabel.textColor = [UIColor blackColor];
    _taxTypeUIDownImg.hidden = YES;
    if(needPayTaxView(_moneyType)){
        
        _priceTitle.text = NSLocalizedString(@"税前总价",nil);
        if(_viewType != 3 ){//不是订单修复页 + 追单
            if(_viewType != 4){
                _taxTypeUIDownImg.hidden = NO;
                _taxTypeLabel.textColor = [UIColor colorWithHex:@"47a3dc"];
            }
            _taxTypeLabel.text = [NSString stringWithFormat:@"%@",getPayTaxValue(_menuData,_selectTaxType,YES)];//;

        }else{
            _discountNumLabel.textColor = [UIColor blackColor];
            _taxTypeLabel.text = [NSString stringWithFormat:@"%@",getPayTaxValue(_menuData,_selectTaxType,YES)];//;
        }
        taxRate = [getPayTaxValue(_menuData,_selectTaxType,NO) doubleValue];
        _taxPriceLabel.text = replaceMoneyFlag([NSString stringWithFormat:@"+￥%0.2f",[_stylesAndTotalPriceModel.originalTotalPrice doubleValue]*taxRate],_moneyType);
        if(taxRate > 0){
            _taxPriceLabel.textColor = [UIColor blackColor];
        }else{
            _taxPriceLabel.textColor = [UIColor colorWithHex:@"919191"];
        }
        _taxView.hidden = NO;
        if(_isSimpleView){
            _discountViewLayoutTopConstraint.constant = 55;
        }else{
            _discountViewLayoutTopConstraint.constant = 90;
        }
    }else{
        _priceTitle.text = NSLocalizedString(@"总价",nil);
        _taxView.hidden = YES;
        if(_isSimpleView){
            _discountViewLayoutTopConstraint.constant = 20;
        }else{
            _discountViewLayoutTopConstraint.constant = 35;
        }
    }
    double discountRate = 0;
    double finalPrice = 0;
    if(false && _viewType == 1){
        _discountView.hidden = YES;
        finalPrice = [_stylesAndTotalPriceModel.finalTotalPrice doubleValue];
        
    }else{
        _discountView.hidden = NO;
        if(_currentYYOrderInfoModel != nil && [_currentYYOrderInfoModel.discount integerValue]>0 && [_currentYYOrderInfoModel.discount integerValue]<100){
            if([LanguageManager isEnglishLanguage]){
                //英文
                discountRate = [_currentYYOrderInfoModel.discount doubleValue]/100;
                _discountNumLabel.text = [NSString stringWithFormat:@"%ld%% %@",[_currentYYOrderInfoModel.discount integerValue],NSLocalizedString(@"折_OFF",nil)];//3.5折
            }else{
                //中文
                discountRate = 1-[_currentYYOrderInfoModel.discount doubleValue]/100;
                double discountNum =[_currentYYOrderInfoModel.discount doubleValue]/10;
                _discountNumLabel.text = [NSString stringWithFormat:@"%0.1f %@",discountNum,NSLocalizedString(@"折_OFF",nil)];
            }
            double discountPrice = [_stylesAndTotalPriceModel.originalTotalPrice doubleValue]*(1+taxRate)*(discountRate);
            _discountPriceLabel.text = replaceMoneyFlag([NSString stringWithFormat:@"-￥%0.2f",discountPrice],_moneyType);
            _discountPriceLabel.textColor = [UIColor colorWithHex:@"ef4e31"];

        }else{
            _discountNumLabel.text = NSLocalizedString(@"无折扣",nil);
            _discountPriceLabel.text = replaceMoneyFlag([NSString stringWithFormat:@"-￥%0.2f",0.00],_moneyType);
            _discountPriceLabel.textColor = [UIColor colorWithHex:@"919191"];

        }
        finalPrice = [_stylesAndTotalPriceModel.finalTotalPrice doubleValue];
    }
    
    _finalPriceLabel.text = replaceMoneyFlag([NSString stringWithFormat:@"￥%0.2f",finalPrice],_moneyType);
}
#pragma mark - SomeAction
- (IBAction)helpBtnHandler:(id)sender {
    NSInteger helpPanelType = 1;
    CGSize uiSize = [YYHelpPanelViewController getViewSize:helpPanelType];
    NSInteger menuUIWidth = uiSize.width;
    NSInteger menuUIHeight = uiSize.height;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    YYHelpPanelViewController *helpPanelController = [storyboard instantiateViewControllerWithIdentifier:@"YYHelpPanelViewController"];
    helpPanelController.helpPanelType = helpPanelType;
    UIViewController *controller = [[UIViewController alloc] init];
    controller.view.frame = CGRectMake(0, 0, menuUIWidth, menuUIHeight);
    controller.view.backgroundColor = [UIColor whiteColor];
    UIView *showView = helpPanelController.view;
    [controller.view addSubview:showView];
    __weak UIView *weakSuperView = controller.view;
    [showView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSuperView.mas_top);
        //make.left.equalTo(weakSuperView.mas_left);
        //make.bottom.equalTo(weakSuperView.mas_bottom);
        make.right.equalTo(weakSuperView.mas_right);
        make.width.mas_equalTo(menuUIWidth);
        make.height.mas_equalTo(menuUIHeight);
    }];
    UIPopoverController *popController = [[UIPopoverController alloc] initWithContentViewController:controller];
    self.popController = popController;
    UIViewController *parent = _parentController;
    CGPoint p = [_helpBtn convertPoint:CGPointMake(22, 0) toView:parent.view];
    CGRect rc = CGRectMake(p.x, p.y-menuUIHeight, 0, 0);
    popController.popoverContentSize = CGSizeMake(menuUIWidth,menuUIHeight);
    popController.popoverBackgroundViewClass = [YYPopoverBackgroundView class];
    [popController presentPopoverFromRect:rc inView:parent.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

-(float)CellHeight{
    float height = 280;
    if(!needPayTaxView(_moneyType) ){
        height = height - 17-35;
    }
    return height;
}

- (IBAction)selectTaxTypeHandler:(id)sender {
    if(_viewType == 3 || _viewType == 4){
        return;
    }
    //跳转税率选择界面
    if(_taxChooseBlock){
        _taxChooseBlock();
    }
}

- (IBAction)discountBtnHandler:(id)sender {
    if(_viewType == 3){
        return;
    }
    if(_delegate){
        [_delegate btnClick:0 section:0 andParmas:@[@"discount"]];
    }
}

-(NSMutableAttributedString *)getTextAttributedString:(NSString *)targetStr replaceStrs:(NSArray *)replaceStrs {
    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString: targetStr];
    NSInteger index =0;
    for (NSString *replaceStr in replaceStrs) {
        NSRange range = [targetStr rangeOfString:replaceStr];
        if (range.location != NSNotFound) {
            [attributedStr addAttribute: NSFontAttributeName value: [UIFont boldSystemFontOfSize:15] range:range];
        }
        index++;
    }
    return attributedStr;
}

@end

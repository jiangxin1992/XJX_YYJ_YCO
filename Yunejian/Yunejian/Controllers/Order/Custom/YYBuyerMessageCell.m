//
//  YYBuyerMessageCell.m
//  Yunejian
//
//  Created by yyj on 15/8/21.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import "YYBuyerMessageCell.h"

// c文件 —> 系统文件（c文件在前）

// 控制器

// 自定义视图

// 接口

// 分类
#import "UIImage+YYImage.h"

// 自定义类和三方类（ cocoapods类 > model > 工具类 > 其他）
#import "YYOrderInfoModel.h"
#import "YYBuyerModel.h"

#import "UserDefaultsMacro.h"

@interface YYBuyerMessageCell ()<UITextFieldDelegate>{
    BOOL hasInitBuyerNameLabel;
}
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *retailerWidthLayout;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addressWidthLayout;
@property (weak, nonatomic) IBOutlet UIView *view1;
@property (weak, nonatomic) IBOutlet UIView *view3;


@property (weak, nonatomic) IBOutlet UIButton *buyerCardButton;

@property (weak, nonatomic) IBOutlet UITextField *buyerNameTextField;
@property (weak, nonatomic) IBOutlet UIButton *buyerNameButton;

@property (weak, nonatomic) IBOutlet UIButton *cardImageBtn;
@property (weak, nonatomic) IBOutlet UIImageView *cardImageView;
@property (weak, nonatomic) IBOutlet UIImageView *addressImg;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addressLayoutTopConstraints;

@property (weak, nonatomic) IBOutlet UIButton *deliverMethodButton;

@property (weak, nonatomic) IBOutlet UIButton *addAddressButton;

@property (weak, nonatomic) IBOutlet UILabel *addressTitleLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buyerNamelLayoutWidthConstraints;//185
@property (weak, nonatomic) IBOutlet UIImageView *buyerNameRightTipImg;
@property (nonatomic ,strong) UIImageView *underLineView;

@end

@implementation YYBuyerMessageCell

#pragma mark - --------------生命周期--------------
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier WithBlock:(void(^)(NSString *type))block{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        [self SomePrepare];
    }
    return self;
}

#pragma mark - --------------SomePrepare--------------
- (void)SomePrepare
{
    [self PrepareData];
    [self PrepareUI];
}
- (void)PrepareData{}
- (void)PrepareUI{
    if([LanguageManager isEnglishLanguage]){
        _retailerWidthLayout.constant = 150;
        _addressWidthLayout.constant = 150;
    }else{
        _retailerWidthLayout.constant = 130;
        _addressWidthLayout.constant = 130;
    }
    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    self.buyerNameTextField.enabled = NO;

    _view1.hidden = NO;
    _view3.hidden = NO;
    _addressTitleLabel.hidden = NO;
    _addressLayoutTopConstraints.constant = 235;// 125
    _cardImageBtn.hidden = NO;
    _cardImageView.hidden = NO;
    [_cardImageBtn setTintColor:[UIColor blackColor]];

    [_deliverMethodButton.titleLabel setAdjustsFontSizeToFitWidth:YES];
}

#pragma mark - --------------UpdateUI----------------------
- (void)updateUI{
    if(_underLineView == nil){
        NSInteger cap = 4;
        _underLineView = [[UIImageView alloc] init];
        _underLineView.image = [[UIImage imageNamed:@"textunderline"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, cap, 0,0)];
        _underLineView.alpha = 0.5;
        [self.buyerNameTextField.superview addSubview:_underLineView];
        _underLineView.hidden = YES;
    }

    if (_currentYYOrderInfoModel) {
        if (_currentYYOrderInfoModel.deliveryChoose
            && [_currentYYOrderInfoModel.deliveryChoose length] > 0) {
            [_deliverMethodButton setTitle:_currentYYOrderInfoModel.deliveryChoose forState:UIControlStateNormal];
        }else{
            [_deliverMethodButton setTitle:NSLocalizedString(@"选择发货方式",nil) forState:UIControlStateNormal];
        }
        if(self.orderCreateBuyerNameButtonClicked){
            _buyerNameRightTipImg.hidden = NO;
            _buyerNameButton.hidden = NO;
            _buyerNameTextField.hidden = YES;
        }else{
            _buyerNameRightTipImg.hidden = YES;
            _buyerNameButton.hidden = YES;
            _buyerNameTextField.backgroundColor = [UIColor clearColor];
            _buyerNameTextField.hidden = NO;
        }
        if(_currentYYOrderInfoModel != nil && !hasInitBuyerNameLabel ){
            if (_currentYYOrderInfoModel.buyerName && [_currentYYOrderInfoModel.buyerName length] >0) {
                if(self.orderCreateBuyerNameButtonClicked){
                    NSString *undefineTip = NSLocalizedString(@"未入驻",nil);//
                    NSString *originStr = [NSString stringWithFormat:@"%@ %@",_currentYYOrderInfoModel.buyerName,undefineTip];

                    if(_buyerModel != nil && [_buyerModel.buyerId integerValue]>0){
                        NSString *_nation = [LanguageManager isEnglishLanguage]?_buyerModel.nationEn:_buyerModel.nation;
                        NSString *_province = [LanguageManager isEnglishLanguage]?_buyerModel.provinceEn:_buyerModel.province;
                        NSString *_city = [LanguageManager isEnglishLanguage]?_buyerModel.cityEn:_buyerModel.city;
                        originStr = [NSString stringWithFormat:@"%@ %@ %@ %@ %@",_buyerModel.name,_buyerModel.contactEmail ,_nation,_province,_city];
                        [_buyerNameButton setTitle:originStr forState:UIControlStateNormal];
                    }else{
                        originStr = [NSString stringWithFormat:@"%@ %@",_currentYYOrderInfoModel.buyerName,undefineTip];
                        NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString: originStr];
                        [attributedStr addAttribute: NSForegroundColorAttributeName value: [UIColor colorWithHex:@"ef4e31"] range: NSMakeRange(originStr.length-undefineTip.length, undefineTip.length)];
                        [_buyerNameButton setAttributedTitle:attributedStr forState:UIControlStateNormal];
                    }

                    CGSize buyerStrSize = [originStr sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]}];
                    _buyerNamelLayoutWidthConstraints.constant = MAX(341, buyerStrSize.width+30);
                    _buyerNameRightTipImg.hidden = NO;

                }else{
                    NSString *orderConnStutas = @"";
                    NSString * nameInfoStr = _currentYYOrderInfoModel.buyerName;
                    if([_currentYYOrderInfoModel.realBuyerId integerValue] >0){
                        nameInfoStr = [NSString stringWithFormat:@"%@ %@",nameInfoStr,_currentYYOrderInfoModel.buyerEmail];
                    }
                    if([_currentYYOrderInfoModel.buyerAddressId integerValue] > 0){
                        NSString *_nation = [LanguageManager isEnglishLanguage]?_currentYYOrderInfoModel.buyerAddress.nationEn:_currentYYOrderInfoModel.buyerAddress.nation;
                        NSString *_province = [LanguageManager isEnglishLanguage]?_currentYYOrderInfoModel.buyerAddress.provinceEn:_currentYYOrderInfoModel.buyerAddress.province;
                        NSString *_city = [LanguageManager isEnglishLanguage]?_currentYYOrderInfoModel.buyerAddress.cityEn:_currentYYOrderInfoModel.buyerAddress.city;
                        nameInfoStr = [NSString stringWithFormat:@"%@ %@ %@ %@",nameInfoStr,_nation,_province,_city];
                    }
                    NSMutableAttributedString *nameAttrStr = [[NSMutableAttributedString alloc] init];
                    CGSize nameTxtsize= [nameInfoStr sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]}];
                    NSInteger _currentOrderConnStatus= [_currentYYOrderInfoModel.orderConnStatus integerValue];
                    if(_currentOrderConnStatus == kOrderStatus){
                        [nameAttrStr appendAttributedString:[[NSAttributedString alloc] initWithString:nameInfoStr  attributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5]}]];
                        _underLineView.hidden = NO;
                        _underLineView.frame = CGRectMake(CGRectGetMinX(self.buyerNameTextField.frame)+10,CGRectGetMaxY(self.buyerNameTextField.frame)-10, nameTxtsize.width, 1);
                        orderConnStutas = getOrderConnStatusName_pad(_currentOrderConnStatus);//@"【未入驻】";
                        [nameAttrStr appendAttributedString:[[NSAttributedString alloc] initWithString:orderConnStutas attributes:@{NSForegroundColorAttributeName:[UIColor redColor],NSFontAttributeName:[UIFont systemFontOfSize:14]}]];

                    }else  if(_currentOrderConnStatus == kOrderStatus0){
                        [nameAttrStr appendAttributedString:[[NSAttributedString alloc] initWithString:nameInfoStr  attributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5]}]];
                        _underLineView.hidden = NO;
                        _underLineView.frame = CGRectMake(CGRectGetMinX(self.buyerNameTextField.frame)+10,CGRectGetMaxY(self.buyerNameTextField.frame)-10, nameTxtsize.width, 1);
                        orderConnStutas = getOrderConnStatusName_pad(_currentOrderConnStatus);//@"【未确认】";
                        [nameAttrStr appendAttributedString:[[NSAttributedString alloc] initWithString:orderConnStutas attributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5],NSFontAttributeName:[UIFont systemFontOfSize:14]}]];
                    }else if(_currentOrderConnStatus == kOrderStatus1){
                        [nameAttrStr appendAttributedString:[[NSAttributedString alloc] initWithString:nameInfoStr  attributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:0 green:0 blue:0 alpha:1]}]];
                        _underLineView.hidden = YES;
                        orderConnStutas = getOrderConnStatusName_pad(_currentOrderConnStatus);//@"【关联中】";
                        [nameAttrStr appendAttributedString:[[NSAttributedString alloc] initWithString:orderConnStutas attributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:0 green:0 blue:0 alpha:1],NSFontAttributeName:[UIFont systemFontOfSize:14]}]];

                    }else{
                        [nameAttrStr appendAttributedString:[[NSAttributedString alloc] initWithString:nameInfoStr  attributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5]}]];
                        _underLineView.hidden = YES;
                        orderConnStutas = getOrderConnStatusName_pad(_currentOrderConnStatus);//@"【关联失败】";
                        [nameAttrStr appendAttributedString:[[NSAttributedString alloc] initWithString:orderConnStutas attributes:@{NSForegroundColorAttributeName:[UIColor redColor],NSFontAttributeName:[UIFont systemFontOfSize:14]}]];
                    }
                    self.buyerNameTextField.attributedText = nameAttrStr;
                    nameTxtsize= [[NSString stringWithFormat:@"%@%@",nameInfoStr,orderConnStutas] sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]}];

                    _buyerNamelLayoutWidthConstraints.constant = MAX(341,nameTxtsize.width+30);
                }
            }else{
                _buyerNamelLayoutWidthConstraints.constant = 341;
                if(self.orderCreateBuyerNameButtonClicked){
                    _buyerNameRightTipImg.hidden = NO;
                    [_buyerNameButton setTitle:NSLocalizedString(@"选择买手店",nil) forState:UIControlStateNormal];
                }else{
                    _buyerNameTextField.text = @"";
                }
            }
        }
        [_cardImageBtn setImage:[UIImage imageNamed:@"addcard"] forState:UIControlStateNormal];
        [_cardImageBtn setImageEdgeInsets:UIEdgeInsetsMake(-60, 40, 0, -60)];
        [_cardImageBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, -40, 0,0)];
        [_cardImageBtn setContentEdgeInsets:UIEdgeInsetsMake(30, 0, 0, 0)];
        _cardImageView.contentMode = UIViewContentModeScaleAspectFit;
        if (_currentYYOrderInfoModel.businessCard
            && [_currentYYOrderInfoModel.businessCard length] > 0) {
            [_cardImageBtn setImage:nil forState:UIControlStateNormal];
            _cardImageBtn.backgroundColor = [UIColor clearColor];
            [_cardImageBtn setTitle:@"" forState:UIControlStateNormal];


            NSString *imageRelativePath = _currentYYOrderInfoModel.businessCard;
            sd_downloadWebImageWithRelativePath(NO, imageRelativePath, _cardImageView, kBuyerCardImage, 0);

        }else{
            //这里判断一下，是否有离线创建订单时选择好的图片
            _cardImageBtn.backgroundColor = [UIColor colorWithHex:@"F8f8f8"];
            [_cardImageBtn setTitle:NSLocalizedString(@"为买手店添加名片",nil) forState:UIControlStateNormal];
        }
        [_buyerCardButton.titleLabel setAdjustsFontSizeToFitWidth:YES];

        if (_currentYYOrderInfoModel.payApp
            && [_currentYYOrderInfoModel.payApp length] > 0) {
            [_buyerCardButton setTitle:_currentYYOrderInfoModel.payApp forState:UIControlStateNormal];
        }else{
            [_buyerCardButton setTitle:NSLocalizedString(@"选择结账方式",nil)  forState:UIControlStateNormal];
        }
    }

    [_addAddressButton setTitle:NSLocalizedString(@"添加买手店地址",nil) forState:UIControlStateNormal];

}

#pragma mark - --------------系统代理----------------------
#pragma mark -UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{

    NSString *str = [textField.text stringByReplacingCharactersInRange:range withString:string];
    self.currentYYOrderInfoModel.buyerName = str;
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    if (textField.text
        && [textField.text length] > 0) {
        self.currentYYOrderInfoModel.buyerName = textField.text;
    }
}

#pragma mark - --------------自定义响应----------------------
- (IBAction)buyMessageButtonClicked:(id)sender{
    if (self.orderCreateBuyerMessageButtonClicked) {
        if ([YYNetworkReachability connectedToNetwork]) {
            self.orderCreateBuyerMessageButtonClicked(sender);
        }else{
            [YYToast showToastWithTitle:kNetworkIsOfflineTips andDuration:kAlertToastDuration];
        }
    }
}

- (IBAction)buyAddressButtonClicked:(id)sender{

    if (self.orderCreateBuyerAddressButtonClicked) {
        self.orderCreateBuyerAddressButtonClicked();
    }
}

- (IBAction)deliverMethodButtonClicked:(id)sender{
    if (self.orderDeliverMethodButtonClicked) {
        self.orderDeliverMethodButtonClicked(sender);
    }
}
- (IBAction)buyerNameButtonClicked:(id)sender {
    if(self.orderCreateBuyerNameButtonClicked){
        self.orderCreateBuyerNameButtonClicked();
    }
}

- (IBAction)thirdButtonClicked:(id)sender{
    if (self.accountsMethodButtonClicked) {
        self.accountsMethodButtonClicked(sender);
    }
}

#pragma mark - --------------自定义方法----------------------


#pragma mark - --------------other----------------------
- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}


@end

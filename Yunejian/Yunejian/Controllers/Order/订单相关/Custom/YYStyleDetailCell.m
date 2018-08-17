//
//  YYStyleDetailCell.m
//  Yunejian
//
//  Created by yyj on 15/8/6.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import "YYStyleDetailCell.h"

// c文件 —> 系统文件（c文件在前）

// 控制器

// 自定义视图
#import "YYDiscountView.h"
#import "SCGIFImageView.h"

// 接口

// 分类
#import "UIView+UpdateAutoLayoutConstraints.h"

// 自定义类和三方类（ cocoapods类 > model > 工具类 > 其他）
#import "SDWebImageManager.h"

#import "YYOrderStyleModel.h"
#import "YYOrderOneInfoModel.h"

#define kSizeIdKeyPrefix @"sizeIdKey_"
#define kMaxSizeShow 10

@interface YYStyleDetailCell ()

@property (weak, nonatomic) IBOutlet UILabel *styleNameLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *styleNamelabelLayoutLeftConstraint;
@property (weak, nonatomic) IBOutlet UILabel *styleCodeLabel;

@property (weak, nonatomic) IBOutlet UIView *sizeView;
@property (weak, nonatomic) IBOutlet UIButton *coverButton;

@property (weak, nonatomic) IBOutlet UIView *lineBgView;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;

@property (weak, nonatomic) IBOutlet UIButton *checkButton;
@property (weak, nonatomic) IBOutlet UIButton *addRemarkButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addRemarkBtnLayoutRigntConstraint;
@property (weak, nonatomic) IBOutlet UILabel *bottomLabelView;
@property (weak, nonatomic) IBOutlet UIView *bottomLabelLine;

@property (weak, nonatomic) IBOutlet UILabel *isStyleModifyTipLabel;
@property(nonatomic,strong) NSMutableDictionary *oneColorSizeCountDic;
@property(nonatomic,assign) BOOL  needCountTotal;

@property (weak, nonatomic) IBOutlet UILabel *totalPriceTitle;
@property (weak, nonatomic) IBOutlet UILabel *totalPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceTitle;

@property (weak, nonatomic) IBOutlet UIButton *unAppendStyleTip;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *unAppendStyleTipWidthLayout;

@property (nonatomic, strong) NSArray *showSizeArray;

@property (nonatomic, strong) UIView *noCountTipView;
@property (weak, nonatomic) IBOutlet UILabel *middleLine;

@end

@implementation YYStyleDetailCell
#pragma mark - --------------生命周期--------------
- (void)awakeFromNib {
    [super awakeFromNib];
    [self SomePrepare];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

#pragma mark - --------------SomePrepare--------------
- (void)SomePrepare
{
    [self PrepareData];
    [self PrepareUI];
}
- (void)PrepareData{}
- (void)PrepareUI{
    _unAppendStyleTipWidthLayout.constant = getWidthWithHeight(20, NSLocalizedString(@"此款式不支持补货",nil), [UIFont systemFontOfSize:13.0])+20;

    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    _coverButton.imageView.contentMode =UIViewContentModeScaleAspectFit;
    _coverButton.layer.borderColor = [UIColor blackColor].CGColor;
    _coverButton.layer.borderWidth = 1;
}

#pragma mark - --------------UpdateUI----------------------
- (void)updateUI{

    _addRemarkButton.hidden = YES;
    _deleteButton.hidden = YES;
    _addRemarkBtnLayoutRigntConstraint.constant = 40;
    if (_showRemarkButton) {
        _addRemarkButton.hidden = NO;
        if(![NSString isNilOrEmpty:_orderStyleModel.remark]){
            [_addRemarkButton setImage:[UIImage imageNamed:@"hasremark_icon"] forState:UIControlStateNormal];
        }else{
            [_addRemarkButton setImage:[UIImage imageNamed:@"remark_icon"] forState:UIControlStateNormal];
        }
    }
    _checkButton.hidden = YES;
    if(_isModifyNow){
        _deleteButton.hidden = NO;
        if(_addRemarkButton.hidden == NO){
            _addRemarkBtnLayoutRigntConstraint.constant = 80;
            if(![NSString isNilOrEmpty:_orderStyleModel.remark]){
                [_addRemarkButton setTitle:@"" forState: UIControlStateNormal];
            }else{

                [_addRemarkButton setTitle:NSLocalizedString(@"添加备注",nil) forState: UIControlStateNormal];
            }
        }
        if(_isShowCheckNow){
            _checkButton.hidden = NO;
            _deleteButton.hidden = YES;
            _styleNamelabelLayoutLeftConstraint.constant = 63;
            [self updateCheckButtonStauts];
        }
    }else{
        if(_addRemarkButton.hidden == NO){
            [_addRemarkButton setTitle:@"" forState: UIControlStateNormal];
            if(![NSString isNilOrEmpty:_orderStyleModel.remark]){
                _addRemarkButton.hidden = NO;
            }else{
                if(!_isCreatOrder){
                    _addRemarkButton.hidden = YES;
                }
            }
        }
        _styleNamelabelLayoutLeftConstraint.constant = 40;
    }

    if (_orderStyleModel) {

        if (_orderStyleModel.name) {
            _styleNameLabel.text = _orderStyleModel.name;
            CGSize nameTxtSize = [_orderStyleModel.name sizeWithAttributes:@{NSFontAttributeName:_styleNameLabel.font}];
            [_styleNameLabel setConstraintConstant:nameTxtSize.width+1 forAttribute:NSLayoutAttributeWidth];
        }

        if(_isAppendOrder && [_orderStyleModel.supportAdd integerValue] ==0){
            _unAppendStyleTip.hidden = NO;
        }else{
            _unAppendStyleTip.hidden = YES;
        }

        NSString *styleCode = @"";
        if (_orderStyleModel.styleCode) {
            styleCode = [styleCode stringByAppendingString:_orderStyleModel.styleCode];
        }

        if (_orderStyleModel.orderAmountMin) {
            styleCode = [styleCode stringByAppendingString:[NSString stringWithFormat:@"   %@",NSLocalizedString(@"每款起订量",nil)]];
            styleCode = [styleCode stringByAppendingString:[_orderStyleModel.orderAmountMin stringValue]];
        }

        _styleCodeLabel.text = styleCode;

        if(_orderStyleModel.albumImg){
            NSString *imageRelativePath = _orderStyleModel.albumImg;
            WeakSelf(ws);
            NSURL *imageUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",imageRelativePath,kStyleCover]];
            __weak UIButton *weakCoverButton = _coverButton;
            SDWebImageManager *manager = [SDWebImageManager sharedManager];
            [manager downloadImageWithURL:imageUrl options:SDWebImageRetryFailed|SDWebImageLowPriority progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                if (image) {
                    [weakCoverButton setImage:image forState:UIControlStateNormal];
                    if (!ws.clickCoverShowDetail) {
                        [ws.coverButton setImage:image forState:UIControlStateHighlighted];
                    }
                }
            }];
        }else{
            [_coverButton setImage:nil forState:UIControlStateNormal];
            if (!_clickCoverShowDetail) {
                [_coverButton setImage:nil forState:UIControlStateHighlighted];
            }
        }


        NSArray *subviews = [_sizeView subviews];
        if (subviews) {
            for (UIView *view in subviews) {
                [view removeFromSuperview];
            }
        }
        if (_orderStyleModel.sizeNameList && [_orderStyleModel.sizeNameList count] > 0) {
            self.showSizeArray = [self filtrateSize:self.orderStyleModel.sizeNameList];
            [self addSizeNameView:self.showSizeArray];
        }

        if (_showTotal && [_orderStyleModel.colors count] > 1) {
            self.oneColorSizeCountDic = [[NSMutableDictionary alloc] initWithCapacity:0];
            self.needCountTotal = YES;
        }

        float taxRate = 0 ;
        if( needPayTaxView([_orderStyleModel.curType integerValue]) ){
            _totalPriceTitle.text = NSLocalizedString(@"税前总价",nil);
            if(_selectTaxType){
                taxRate =[getPayTaxValue(_menuData,_selectTaxType,NO) doubleValue];
            }else{

            }
        }else{

            _totalPriceTitle.text = NSLocalizedString(@"总价",nil);
        }

        subviews = [_lineBgView subviews];
        if (subviews) {
            for (UIView *view in subviews) {
                [view removeFromSuperview];
            }
        }

        int styleBuyedCount = 0;
        int j = 0;
        if (_orderStyleModel.colors && [_orderStyleModel.colors count] > 0) {

            BOOL isAllSelectColor = YES;
            for (YYOrderOneColorModel *orderOneColorModel in _orderStyleModel.colors) {
                if(![orderOneColorModel.isColorSelect boolValue]){
                    isAllSelectColor = NO;
                    break;
                }
            }

            if(isAllSelectColor){
                _priceTitle.text = @"";
                _totalPriceLabel.text = [[NSString alloc] initWithFormat:NSLocalizedString(@"共计 %@件",nil),@"--"];
            }else{
                CGFloat costMeoney = [self.orderStyleModel getTotalOriginalPrice];
                if(taxRate == 0.0f){
                    NSString *originalPrice = [[NSString alloc] initWithFormat:@"%@%@",NSLocalizedString(@"批发价（税前）", nil), replaceMoneyFlag([NSString stringWithFormat:@"￥%.2f", costMeoney],[_orderStyleModel.curType integerValue])];
                    NSString *titleStr = originalPrice;

                    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString: titleStr];
                    _priceTitle.attributedText = attributedStr;
                }else{
                    NSString *originalPrice = [[NSString alloc] initWithFormat:@"%@%@",NSLocalizedString(@"批发价：",nil),replaceMoneyFlag([NSString stringWithFormat:@"￥%.2f",costMeoney],[_orderStyleModel.curType integerValue])];
                    NSString *afterTaxPrice = [[NSString alloc] initWithFormat:@"%@%@",NSLocalizedString(@"税后价：",nil),replaceMoneyFlag([NSString stringWithFormat:@"￥%.2f",costMeoney*(1+taxRate)],[_orderStyleModel.curType integerValue])];
                    NSString *titleStr = [[NSString alloc] initWithFormat:@"%@   %@",originalPrice,afterTaxPrice];

                    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString: titleStr];
                    NSRange range = NSMakeRange(titleStr.length - afterTaxPrice.length, afterTaxPrice.length);
                    [attributedStr addAttribute: NSForegroundColorAttributeName value: [UIColor colorWithHex:@"919191"] range:range];
                    _priceTitle.attributedText = attributedStr;
                }

                NSInteger unitsCount = [_orderStyleModel getUnitsCount];

                NSString *countStr = [[NSString alloc] initWithFormat:NSLocalizedString(@"共计 %ld件",nil),unitsCount];
                NSString *totalPriceStr = replaceMoneyFlag([NSString stringWithFormat:@"￥%.2f", costMeoney*(1+taxRate)], [_orderStyleModel.curType integerValue]);
                NSString *titleStr = [[NSString alloc] initWithFormat:@"%@   %@",countStr,totalPriceStr];

                NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString: titleStr];
                NSRange range = NSMakeRange(titleStr.length - totalPriceStr.length, totalPriceStr.length);
                [attributedStr addAttribute: NSForegroundColorAttributeName value: [UIColor colorWithHex:@"ED6498"] range:range];
                _totalPriceLabel.attributedText = attributedStr;
            }


            for (int i=0; i<[_orderStyleModel.colors count]; i++) {
                YYOrderOneColorModel *orderOneColorModel = [_orderStyleModel.colors objectAtIndex:i];
                if(checkOrderOneColorHasAmount(orderOneColorModel) || [orderOneColorModel.isColorSelect boolValue]){
                    int aColorCount = (int)[self addAlineView:orderOneColorModel andLineIndex:j originalPrice:[orderOneColorModel.originalPrice floatValue] finalPrice:[orderOneColorModel.originalPrice floatValue]*(1+taxRate)];
                    styleBuyedCount += aColorCount;
                    j++;
                }
            }
        }
        if(!_noCountTipView){
            //创建提示view
            _noCountTipView = [UIView getCustomViewWithColor:_define_white_color];
            [_lineBgView addSubview:_noCountTipView];
            [_noCountTipView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.bottom.mas_equalTo(self.lineBgView);
                make.top.mas_equalTo(self.middleLine.mas_bottom).with.offset(20);
            }];

            UILabel *tipLabel = [UILabel getLabelWithAlignment:1 WithTitle:NSLocalizedString(@"请重新编辑您要采购的商品", nil) WithFont:14.f WithTextColor:[UIColor colorWithHex:@"919191"] WithSpacing:0];
            [_noCountTipView addSubview:tipLabel];
            [tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.mas_equalTo(self.noCountTipView);
            }];
            tipLabel.numberOfLines = 2;
            _noCountTipView.hidden = YES;
        }
        
        if(!styleBuyedCount && _isModifyNow){
            if(_isAppendOrder){
                _noCountTipView.hidden = YES;
            }else{
                _noCountTipView.hidden = NO;
            }
        }else{
            _noCountTipView.hidden = YES;
        }

        if (styleBuyedCount < [_orderStyleModel.orderAmountMin intValue] && _showHaveNotAchieveOrderAmountMin) {

            NSString *limitTipStr = [NSString stringWithFormat:@"   %@",NSLocalizedString(@"未达每款起订量",nil)];
            NSString *originStr = [_styleCodeLabel.text stringByAppendingString:limitTipStr];
            NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString: originStr];

            [attributedStr addAttribute: NSForegroundColorAttributeName value:[UIColor redColor] range: NSMakeRange(originStr.length-limitTipStr.length,limitTipStr.length)];

            _styleCodeLabel.attributedText = attributedStr;

        }
    }
}


#pragma mark - --------------Setter----------------------
- (void)setBottomView:(BOOL)hidden{
    _bottomLabelView.hidden = hidden;
    _bottomLabelLine.hidden = hidden;
}

#pragma mark - --------------自定义响应----------------------
- (IBAction)deleteButtonClicked:(id)sender {
    if (self.deleteStyleButtonClicked) {
        self.deleteStyleButtonClicked(_orderStyleModel,_seriesId);
    }
}

- (IBAction)remarkButtonClicked:(id)sender{
    if (self.discountStyleButtonClicked) {
        self.discountStyleButtonClicked(_orderStyleModel,_seriesId);
    }
}

- (IBAction)selectButtonClicked:(id)sender{
    _checkButtonIsChecked = !_checkButtonIsChecked;

    [self updateCheckButtonStauts];

    NSLog(@"selectButtonClicked....");
    if (self.selectCellButtonClicked) {
        self.selectCellButtonClicked(_checkButtonIsChecked,_orderStyleModel);
    }
}

- (IBAction)coverButtonClicked:(id)sender{
    if (_clickCoverShowDetail) {
        if (self.coverButtonClicked) {
            self.coverButtonClicked(self.orderOneInfoModel,self.orderStyleModel);
        }
    }
}

#pragma mark - --------------自定义方法----------------------
- (void)updateCheckButtonStauts{
    NSString *imageName = nil;
    if (_checkButtonIsChecked) {
        imageName = @"checked";
    }else{
        imageName = @"noChecked";
    }

    [_checkButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
}


- (void)addSizeNameView:(NSArray *)sizeArray{
    int item_with = 50;
    int margin = 1;
    __weak UIView *lastView = nil;
    for (int i = (int)[sizeArray count]-1; i >=0 ; i--) {

        if (i < kMaxSizeShow) {
            YYSizeModel *orderSizeDetailModel = [sizeArray objectAtIndex:i];

            UILabel *lable = [[UILabel alloc] init];
            lable.textAlignment = NSTextAlignmentCenter;
            lable.backgroundColor = [UIColor clearColor];
            lable.font = [UIFont systemFontOfSize:15];
            lable.text = [orderSizeDetailModel getSizeShortStr];

            [_sizeView addSubview:lable];
            __weak UIView *weakContainer = _sizeView;

            [lable mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.and.bottom.equalTo(weakContainer);
                make.width.mas_equalTo(item_with);

                if (lastView)
                {
                    make.right.mas_equalTo(lastView.mas_left).with.offset(-margin);
                }
                else
                {
                    make.right.mas_equalTo(weakContainer.mas_right);
                }

            }];
            lastView = lable;
        }
    }
}
- (NSInteger )addAlineView:(YYOrderOneColorModel *)orderOneColorModel andLineIndex:(int)lineIndex originalPrice:(float)originalPrice finalPrice:(float)finalPrice{
    int item_width = 30;
    int item_height = 30;
    float normal_font_size = 12;

    int top_magin = 20+lineIndex*(item_height+15);

    //最左边颜色部份
    NSString *colorValue = orderOneColorModel.value;
    __weak UIView *tempWeakView = _lineBgView;

    if (colorValue) {
        UIView *tempView = nil;
        if ([colorValue hasPrefix:@"#"]
            && [colorValue length] == 7) {
            //16进制的色值
            UIColor *color = [UIColor colorWithHex:[colorValue substringFromIndex:1]];
            UIView *colorLabel = [UIView getCustomViewWithColor:color];
            colorLabel.layer.borderWidth = 1;
            colorLabel.layer.borderColor = [UIColor blackColor].CGColor;

            [_lineBgView addSubview:colorLabel];

            [colorLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(tempWeakView.mas_top).with.offset(top_magin);
                make.left.mas_equalTo(tempWeakView.mas_left);
                make.width.mas_equalTo(item_width);
                make.height.mas_equalTo(item_height);
            }];
            tempView = colorLabel;
        }else{
            SCGIFImageView *imageView = [[SCGIFImageView alloc] init];
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            imageView.layer.borderColor = [UIColor blackColor].CGColor;
            imageView.layer.borderWidth = 1;

            [_lineBgView addSubview:imageView];

            [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(tempWeakView.mas_top).with.offset(top_magin);
                make.left.mas_equalTo(tempWeakView.mas_left);
                make.width.mas_equalTo(item_width);
                make.height.mas_equalTo(item_height);
            }];

            NSString *imageRelativePath = colorValue;

            NSString *imageName = [[imageRelativePath lastPathComponent] stringByAppendingString:kStyleColorImageCover];
            NSString *storePath = yyjOfflineSeriesImagePath(self.seriesId,imageRelativePath,imageName);

            UIImage *image = [UIImage imageWithContentsOfFile:storePath];
            if (image) {
                imageView.image = image;
            }else{
                sd_downloadWebImageWithRelativePath(NO, imageRelativePath, imageView, kStyleColorImageCover, 0);
            }
            tempView = imageView;
        }

        if(tempView){

            UILabel *colorNameLabel = [UILabel getLabelWithAlignment:0 WithTitle:orderOneColorModel.name WithFont:13.0f WithTextColor:[UIColor colorWithHex:@"919191"] WithSpacing:0];
            [_lineBgView addSubview:colorNameLabel];
            [colorNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(tempView.mas_right).with.offset(6);
                make.centerY.mas_equalTo(tempView);
            }];
        }


    }else{
        //合计
        UILabel *colorLabel = [[UILabel alloc] init];
        colorLabel.backgroundColor = [UIColor clearColor];
        colorLabel.textAlignment = NSTextAlignmentCenter;
        colorLabel.text = @"合计";
        colorLabel.font = [UIFont boldSystemFontOfSize:15];
        colorLabel.adjustsFontSizeToFitWidth = YES;

        [_lineBgView addSubview:colorLabel];

        [colorLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(tempWeakView.mas_top).with.offset(top_magin);
            make.left.mas_equalTo(tempWeakView.mas_left);
            make.width.mas_equalTo(item_width);
            make.height.mas_equalTo(item_height);
        }];
    }

    int margin = 1;

    int totalPriceAndPriceLabelWith = 97;

    __weak UIView *rightView = nil;

    //总价部份

    YYDiscountView *totalPriceDiscountView = [[YYDiscountView alloc] init];
    totalPriceDiscountView.backgroundColor = [UIColor clearColor];
    totalPriceDiscountView.showDiscountValue = NO;

    [_lineBgView addSubview:totalPriceDiscountView];

    [totalPriceDiscountView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(tempWeakView.mas_top).with.offset(top_magin);
        make.right.mas_equalTo(tempWeakView.mas_right);
        make.width.mas_equalTo(totalPriceAndPriceLabelWith);
        make.height.mas_equalTo(item_height);
    }];

    rightView = totalPriceDiscountView;

    int countLabelWith = 67;

    //共计部份
    UILabel *countLabel = [[UILabel alloc] init];
    countLabel.backgroundColor = [UIColor clearColor];
    countLabel.textAlignment = NSTextAlignmentCenter;
    countLabel.font = [UIFont systemFontOfSize:normal_font_size];

    if (!colorValue) {
        countLabel.font = [UIFont boldSystemFontOfSize:normal_font_size];
    }

    [_lineBgView addSubview:countLabel];


    [countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(tempWeakView.mas_top).with.offset(top_magin);
        make.right.mas_equalTo(rightView.mas_left).with.offset(-margin);
        make.width.mas_equalTo(countLabelWith);
        make.height.mas_equalTo(item_height);
    }];

    rightView = countLabel;

    //尺码数量部份

    NSMutableArray *sizeSequence = [[NSMutableArray alloc] initWithCapacity:0];
    for (int i=0; i<[self.showSizeArray count]; i++) {
        YYSizeModel *orderSizeDetailModel = [self.showSizeArray objectAtIndex:i];
        for (YYOrderSizeModel *orderSizeModel in orderOneColorModel.sizes) {
            if ([orderSizeDetailModel.id intValue] == [orderSizeModel.sizeId intValue]) {
                [sizeSequence addObject:orderSizeModel];
                break;
            }
        }
    }

    NSInteger aColorAllSizeCount = 0;

    BOOL isColorSelect = [orderOneColorModel.isColorSelect boolValue];

    int size_label_with = 50;
    if ([sizeSequence count] == [self.showSizeArray count]) {
        for (int i = ((int)[sizeSequence count]-1); i >=0 ; i--) {
            if (i < kMaxSizeShow) {
                YYOrderSizeModel *orderSizeModel = [sizeSequence objectAtIndex:i];
                UILabel *lablel = [[UILabel alloc] init];
                lablel.textAlignment = NSTextAlignmentCenter;
                lablel.backgroundColor = [UIColor clearColor];
                int curAmount = 0;
                if(!isColorSelect){
                    curAmount = MAX(0,[orderSizeModel.amount intValue]);
                }

                lablel.text = curAmount == 0 ? @"--" : [NSString stringWithFormat:@"%i",curAmount];
                lablel.textColor = curAmount == 0 ? [UIColor colorWithHex:@"ef4e31"] : _define_black_color;
                lablel.font = [UIFont systemFontOfSize:normal_font_size];

                if (!colorValue) {
                    lablel.font = [UIFont boldSystemFontOfSize:normal_font_size];
                }

                aColorAllSizeCount += curAmount;

                //统计各尺寸的合计
                if (_needCountTotal) {
                    NSString *sizeIdKey = [NSString stringWithFormat:@"%@%i",kSizeIdKeyPrefix,[orderSizeModel.sizeId intValue]];
                    NSObject *obj = [_oneColorSizeCountDic objectForKey:sizeIdKey];
                    if (!obj) {
                        [_oneColorSizeCountDic setObject:[NSNumber numberWithInt:curAmount] forKey:sizeIdKey];
                    }else{
                        NSNumber *hadNumber = (NSNumber *)obj;
                        [_oneColorSizeCountDic setObject:[NSNumber numberWithInt:curAmount + [hadNumber intValue]] forKey:sizeIdKey];
                    }
                }

                [_lineBgView addSubview:lablel];

                [lablel mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.mas_equalTo(tempWeakView.mas_top).with.offset(top_magin);
                    make.width.mas_equalTo(size_label_with);
                    make.height.mas_equalTo(item_height);
                    make.right.mas_equalTo(rightView.mas_left).with.offset(-margin);

                }];
                rightView = lablel;
            }
        }
    }

    countLabel.text = isColorSelect ? @"--" : [NSString stringWithFormat:@"%li",(long)aColorAllSizeCount];//一个颜色共计多少件
    countLabel.textColor = isColorSelect?[UIColor colorWithHex:@"ef4e31"]:_define_black_color;
    NSString * finalTotalPriceValue =  decimalNumberMutiplyWithString([NSString stringWithFormat:@"%ld",(long)aColorAllSizeCount],[NSString stringWithFormat:@"%0.2f",originalPrice]) ;
    NSString * finalTotalPrice =  replaceMoneyFlag([NSString stringWithFormat:@"￥%@",finalTotalPriceValue],[_orderStyleModel.curType integerValue]);

    [totalPriceDiscountView updateUIWithOriginPrice:finalTotalPrice
                                         fianlPrice: finalTotalPrice
                                         originFont:[UIFont boldSystemFontOfSize:12]
                                          finalFont:[UIFont boldSystemFontOfSize:12]
                                      isColorSelect:isColorSelect];

    return aColorAllSizeCount;
}

- (void)setIsStyleModifyView:(BOOL)isStyleModify{
    for (UIView *ui in [self.contentView subviews]) {
        if(ui != _coverButton && ui != _isStyleModifyTipLabel){
            if(isStyleModify){
                ui.alpha = 0.4;
            }else{
                ui.alpha = 1;
            }
        }
    }
    _isStyleModifyTipLabel.hidden = !isStyleModify;
}

- (NSArray *)filtrateSize:(NSArray *)sizeArray {
    NSMutableArray *array = [NSMutableArray array];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [sizeArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        YYSizeModel *sizeModel = [sizeArray objectAtIndex:idx];
        [dict setObject:@(0) forKey:sizeModel.id];
    }];
    [self.orderStyleModel.colors enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        YYOrderOneColorModel *colorModel = [self.orderStyleModel.colors objectAtIndex:idx];
        if (checkOrderOneColorHasAmount(colorModel)) {
            [colorModel.sizes enumerateObjectsUsingBlock:^(YYOrderSizeModel *orderSizeModel, NSUInteger idx, BOOL *stop) {
                [dict setObject:@([[dict objectForKey:orderSizeModel.sizeId] integerValue] + ([orderSizeModel.amount integerValue] < 0 ? 0 : [orderSizeModel.amount integerValue])) forKey:orderSizeModel.sizeId];
            }];
        }
    }];
    [sizeArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        YYSizeModel *sizeModel = [sizeArray objectAtIndex:idx];
        if ([[dict objectForKey:sizeModel.id] integerValue] > 0) {
            [array addObject:sizeModel];
        }
    }];
    return array;
}

#pragma mark - --------------other----------------------


@end

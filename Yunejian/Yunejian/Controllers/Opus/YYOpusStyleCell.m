//
//  YYOpusStyleCell.m
//  Yunejian
//
//  Created by yyj on 2018/1/4.
//  Copyright © 2018年 yyj. All rights reserved.
//

#import "YYOpusStyleCell.h"

// c文件 —> 系统文件（c文件在前）

// 控制器

// 自定义视图
#import "SCGIFImageView.h"
#import "YYSmallShoppingCarButton.h"

// 接口

// 分类
#import "UIView+UpdateAutoLayoutConstraints.h"

// 自定义类和三方类（ cocoapods类 > model > 工具类 > 其他）
#import "YYOpusStyleModel.h"
#import "YYOrderOneInfoModel.h"
#import "YYOrderInfoModel.h"
#import "StyleColors.h"

#import "AppDelegate.h"

@interface YYOpusStyleCell()

@property (weak, nonatomic) IBOutlet SCGIFImageView *styleImg;//80000
@property (weak, nonatomic) IBOutlet UILabel *styleLabel;//80002
@property (weak, nonatomic) IBOutlet UILabel *tradePriceLabel;//80003
@property (weak, nonatomic) IBOutlet UILabel *retailPriceLabel;//80004
@property (weak, nonatomic) IBOutlet UIButton *addButton;//80006
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;//80001
@property (weak, nonatomic) IBOutlet YYSmallShoppingCarButton *smallShoppingCarButton;//80005

@property (weak, nonatomic) IBOutlet UIButton *selectButton;

@end

@implementation YYOpusStyleCell
#pragma mark - --------------生命周期--------------


#pragma mark - --------------SomePrepare--------------
- (void)SomePrepare
{
    [self PrepareData];
    [self PrepareUI];
}
- (void)PrepareData{}
- (void)PrepareUI{
    
    [_smallShoppingCarButton initFlagButton];

    _styleImg.contentMode = UIViewContentModeScaleAspectFit;

}

#pragma mark - --------------UpdateUI----------------------
-(void)updateUI{

    [self SomePrepare];

    if(!_isModifyOrder){
        if(_isSelect){
            _selectButton.hidden = NO;
            if(_opusStyleIsSelect){
                _selectButton.selected = YES;
                _selectButton.backgroundColor = [_define_black_color colorWithAlphaComponent:0.3];
            }else{
                _selectButton.selected = NO;
                _selectButton.backgroundColor = [UIColor clearColor];
            }
        }else{
            _selectButton.hidden = YES;
        }
    }else{
        _selectButton.hidden = YES;
    }

    _smallShoppingCarButton.hidden = YES;

    if (!_isModifyOrder) {
        _addButton.hidden = YES;

    }else{
        _smallShoppingCarButton.hidden = YES;
    }

    id colorModel = self.opusStyleModel.color[0];
    NSString *styleCode = nil;
    NSString *imageRelativePath = _opusStyleModel.albumImg;
    NSString *name = _opusStyleModel.name;
    if ([colorModel isKindOfClass:[YYColorModel class]]) {
        styleCode = ((YYColorModel *)colorModel).styleCode;
    } else if ([colorModel isKindOfClass:[StyleColors class]]) {
        styleCode = ((StyleColors *)colorModel).style_code;
    }
    NSString *tradePrice = [NSString stringWithFormat:replaceMoneyFlag(NSLocalizedString(@"批发￥%0.2f",nil),[_opusStyleModel.curType integerValue]),[_opusStyleModel.tradePrice floatValue]];
    NSString *retailPrice = [NSString stringWithFormat:replaceMoneyFlag(NSLocalizedString(@"零售￥%0.2f",nil),[_opusStyleModel.curType integerValue]),[_opusStyleModel.retailPrice floatValue]];
    NSInteger styleID = [_opusStyleModel.id integerValue];
    NSInteger curType = [_opusStyleModel.curType integerValue];
    double tmpTradePrice = [_opusStyleModel.tradePrice floatValue];

    NSArray *colorArray = nil;
    if (_opusStyleModel.color
        && [_opusStyleModel.color count] > 0) {
        colorArray = _opusStyleModel.color;
    }

    if (!_isModifyOrder) {
        AppDelegate *_appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        for (YYOrderOneInfoModel *oneInfoModel in _appdelegate.cartModel.groups) {
            for (YYOrderStyleModel * orderInfoMode in oneInfoModel.styles) {
                if(styleID == [orderInfoMode.styleId integerValue]){
                    _smallShoppingCarButton.hidden = NO;
                    break;
                }
            }
            if(_smallShoppingCarButton.hidden == NO){
                break;
            }
        }
    }
    NSString *imageName = [[imageRelativePath lastPathComponent] stringByAppendingString:kStyleCover];
    NSString *storePath = yyjOfflineSeriesImagePath([_opusStyleModel.seriesId integerValue],imageRelativePath,imageName);

    UIImage *image = [UIImage imageWithContentsOfFile:storePath];
    _styleImg.backgroundColor = [UIColor colorWithHex:kDefaultImageColor];
    if (image) {
        _styleImg.image = image;
    }else{
        sd_downloadWebImageWithRelativePath(YES, imageRelativePath, _styleImg, kStyleCover, UIViewContentModeScaleAspectFit);
    }

    //更新约束
    CGSize nameLabelSize = [name sizeWithAttributes:@{NSFontAttributeName:_nameLabel.font}];
    float needHeight = nameLabelSize.height;
    if(nameLabelSize.width > 200){
        needHeight = nameLabelSize.height*2;
    }else{
        needHeight = nameLabelSize.height;
    }
    _nameLabel.text = name;
    [_nameLabel setConstraintConstant:needHeight forAttribute:NSLayoutAttributeHeight];

    _styleLabel.text = [NSString stringWithFormat:@"%@",styleCode];//styleCode;
    _tradePriceLabel.text = tradePrice;
    if(_isModifyOrder == NO && needPayTaxView(curType) && _selectTaxType){
        float taxRate = [getPayTaxType(_selectTaxType,NO) doubleValue];
        NSString *taxPrice = replaceMoneyFlag([NSString stringWithFormat:@"%@￥%0.2f",NSLocalizedString(@"税后",nil),tmpTradePrice*(1+taxRate)],curType);
        _retailPriceLabel.text = [NSString stringWithFormat:@"%@  %@",taxPrice,retailPrice];//retailPrice;
    }else{
        _retailPriceLabel.text = retailPrice;
    }

    if (colorArray && [colorArray count] > 0) {
        NSArray *array = [_styleImg subviews];
        for (UIView *view in array) {
            [view removeFromSuperview];
        }

        [self addColorViewToCover:_styleImg colors:colorArray];
    }
}
- (void)addColorViewToCover:(UIImageView *)coverImageView colors:(NSArray *)colorArray{

    UIView *lastView = nil;
    UIView *tempContainer = [[UIView alloc] init];
    tempContainer.backgroundColor = [UIColor clearColor];

    __weak UIImageView *weakCoverImageView = coverImageView;

    [coverImageView addSubview:tempContainer];
    [tempContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(20);
        make.left.equalTo(weakCoverImageView.mas_left);
        make.bottom.equalTo(weakCoverImageView.mas_bottom);
    }];

    __weak UIView *weakContainer = tempContainer;
    for (int i= 0; i < [colorArray count]; i++) {
        NSObject *obj = [colorArray objectAtIndex:i];
        NSString *colorValue = @"";
        if ([obj isKindOfClass:[YYColorModel class]]) {
            YYColorModel *colorModel = (YYColorModel *)obj;
            colorValue = colorModel.value;
        }else if ([obj isKindOfClass:[StyleColors class]]){
            StyleColors *styleColors = (StyleColors *)obj;
            colorValue = styleColors.color_value;
        }

        if (colorValue) {
            if ([colorValue hasPrefix:@"#"]
                && [colorValue length] == 7) {
                //16进制的色值
                UIColor *color = [UIColor colorWithHex:[colorValue substringFromIndex:1]];
                UILabel *label = [[UILabel alloc] init];
                label.backgroundColor = color;
                label.layer.borderWidth = 1;
                label.layer.borderColor = kBorderColor.CGColor;
                [tempContainer addSubview:label];


                [label mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.and.bottom.equalTo(weakContainer);
                    make.width.mas_equalTo(20);

                    if ( lastView )
                    {
                        make.left.mas_equalTo(lastView.mas_right).with.offset(5);
                    }
                    else
                    {
                        make.left.mas_equalTo(weakContainer.mas_left);
                    }

                }];
                lastView = label;


            }else{
                //是图片的地址

                SCGIFImageView *imageView = [[SCGIFImageView alloc] init];
                [tempContainer addSubview:imageView];

                imageView.layer.borderWidth = 1;
                imageView.layer.borderColor = kBorderColor.CGColor;

                [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.and.bottom.equalTo(weakContainer);
                    make.width.mas_equalTo(20);

                    if ( lastView )
                    {
                        make.left.mas_equalTo(lastView.mas_right).with.offset(5);
                    }
                    else
                    {
                        make.left.mas_equalTo(weakContainer.mas_left);
                    }

                }];
                lastView = imageView;


                NSString *imageRelativePath = colorValue;

                NSString *imageName = [[imageRelativePath lastPathComponent] stringByAppendingString:kStyleColorImageCover];
                NSString *storePath = yyjOfflineSeriesImagePath([_opusStyleModel.seriesId integerValue],imageRelativePath,imageName);

                UIImage *image = [UIImage imageWithContentsOfFile:storePath];
                if (image) {
                    imageView.image = image;
                }else{
                    sd_downloadWebImageWithRelativePath(NO, imageRelativePath, imageView, kStyleColorImageCover, 0);

                }

            }
        }
    }

    if (lastView) {
        [tempContainer mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(lastView.mas_right);
        }];
    }
}
#pragma mark - --------------自定义响应----------------------
- (IBAction)selectAction:(id)sender {
    if (self.delegate) {
        [self.delegate btnClick:_indexPath.row section:_indexPath.section andParmas:@[@"selectStyle",_opusStyleModel]];
    }
}
#pragma mark -添加按钮进入订单弹窗
- (IBAction)addOrderAction:(id)sender forEvent:(UIEvent *)event {
    if (self.delegate) {
        [self.delegate btnClick:_indexPath.row section:_indexPath.section andParmas:@[@"addOrder",event]];
    }
}
#pragma mark - --------------自定义方法----------------------

@end

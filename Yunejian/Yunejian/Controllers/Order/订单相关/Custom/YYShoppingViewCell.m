//
//  YYShoppingViewCell.m
//  Yunejian
//
//  Created by Apple on 15/8/3.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import "YYShoppingViewCell.h"

// c文件 —> 系统文件（c文件在前）

// 控制器

// 自定义视图
#import "YYShoppingStyleSizeInputView.h"

// 接口

// 分类

// 自定义类和三方类（ cocoapods类 > model > 工具类 > 其他）
#import "YYOrderSizeModel.h"
#import "YYStyleInfoModel.h"
#import "SCGIFImageView.h"

@interface YYShoppingViewCell ()<YYTableCellDelegate>

@property (weak, nonatomic) IBOutlet SCGIFImageView *clothColorImage;

@property (weak, nonatomic) IBOutlet YYShoppingStyleSizeInputView *sizeInput1;
@property (weak, nonatomic) IBOutlet YYShoppingStyleSizeInputView *sizeInput2;
@property (weak, nonatomic) IBOutlet YYShoppingStyleSizeInputView *sizeInput3;
@property (weak, nonatomic) IBOutlet YYShoppingStyleSizeInputView *sizeInput4;
@property (weak, nonatomic) IBOutlet YYShoppingStyleSizeInputView *sizeInput5;
@property (weak, nonatomic) IBOutlet YYShoppingStyleSizeInputView *sizeInput6;
@property (weak, nonatomic) IBOutlet YYShoppingStyleSizeInputView *sizeInput7;
@property (weak, nonatomic) IBOutlet YYShoppingStyleSizeInputView *sizeInput8;
@property (weak, nonatomic) IBOutlet YYShoppingStyleSizeInputView *sizeInput9;
@property (weak, nonatomic) IBOutlet YYShoppingStyleSizeInputView *sizeInput10;

@property (weak, nonatomic) IBOutlet UILabel *sizeColorNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *tradePriceLabel;
@property (weak, nonatomic) IBOutlet UIButton *selectColorButton;

@property (weak, nonatomic) IBOutlet UILabel *bottomLine;

@property (nonatomic, strong) YYColorModel *colorModel;

@end

@implementation YYShoppingViewCell
#pragma mark - --------------生命周期--------------
- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}
#pragma mark - --------------SomePrepare--------------
-(void)SomePrepare
{
    [self PrepareData];
    [self PrepareUI];
}
-(void)PrepareData{}
-(void)PrepareUI{
    self.clothColorImage.backgroundColor = [UIColor whiteColor];
    self.clothColorImage.layer.borderWidth = 1;
    self.clothColorImage.layer.borderColor = [UIColor colorWithHex:@"d3d3d3"].CGColor;

    _bottomLine.backgroundColor = [UIColor colorWithHex:@"EFEFEF"];
}

//#pragma mark - --------------UIConfig----------------------
//-(void)UIConfig{}
#pragma mark - --------------UpdateUI----------------------
-(void)updateUI{

    self.bottomLine.hidden = _bottomLineIsHide;

    NSInteger cellRow = _indexPath.row/2 ;
    _colorModel = [_styleInfoModel.colorImages objectAtIndex:cellRow];
    
    //设置颜色或者图片
    YYColorModel  *colorModel = _colorModel;
    _sizeColorNameLabel.text = colorModel.name;
    self.tradePriceLabel.text = replaceMoneyFlag([NSString stringWithFormat:@"￥%.2f", [colorModel.tradePrice floatValue]],[_styleInfoModel.style.curType integerValue]);
    if ([colorModel.value hasPrefix:@"#"] && [colorModel.value  length] == 7) {
        //16进制的色值
        UIColor *color = [UIColor colorWithHex:[colorModel.value  substringFromIndex:1]];
        UILabel *colorLab = [[UILabel alloc] init];
        colorLab.font = [UIFont systemFontOfSize:12];
        colorLab.backgroundColor = color;
        [self.clothColorImage addSubview:colorLab];
        [colorLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.clothColorImage.mas_top);
            make.left.mas_equalTo(self.clothColorImage.mas_left);
            make.width.mas_equalTo(self.clothColorImage.frame.size.width);
            make.height.mas_equalTo(self.clothColorImage.frame.size.height);
        }];
    }else{
        //图片
        NSString *imageRelativePath = colorModel.value;
        sd_downloadWebImageWithRelativePath(NO, imageRelativePath, self.clothColorImage, kStyleColorImageCover, 0);
    }

    _selectColorButton.hidden = !_isOnlyColor;
    if(_isOnlyColor){

        _selectColorButton.selected = [_colorModel.isSelect boolValue];

        YYShoppingStyleSizeInputView *sizeInput;
        NSInteger i = 0;
        for (; i < 10; i++) {
            sizeInput = [self valueForKey:[NSString stringWithFormat:@"sizeInput%ld",(i+1)]];
            sizeInput.hidden = YES;
        }

    }else{

        NSInteger maxSizeCount = kMaxSizeCount;
        if ([_styleInfoModel.size count] < kMaxSizeCount) {
            maxSizeCount = [_styleInfoModel.size count];
        }
        YYSizeModel *sizeModel = nil;
        NSInteger sizeStock = LONG_MAX;
        YYOrderSizeModel *amountsizeModel = nil;
        YYShoppingStyleSizeInputView *sizeInput;
        NSInteger i = 0;
        for (; i<maxSizeCount; i++) {
            sizeModel = [_styleInfoModel.size objectAtIndex:i];
            if ([self useStockControl] && self.colorModel.sizeStocks.count == self.styleInfoModel.size.count) {
                sizeStock = [[self.colorModel.sizeStocks objectAtIndex:i] integerValue];
            }
            sizeInput = [self valueForKey:[NSString stringWithFormat:@"sizeInput%ld",(i+1)]];
            sizeInput.hidden = NO;
            sizeInput.sizeNameLabel.text = [sizeModel getSizeShortStr];
            sizeInput.minCount = 0;
            sizeInput.maxCount = sizeStock;
            if(_amountsizeArr && [_amountsizeArr count] > i){
                amountsizeModel = [_amountsizeArr objectAtIndex:i];
                sizeInput.value = (amountsizeModel && [amountsizeModel.amount integerValue] > 0) ? [amountsizeModel.amount integerValue] : 0;
            }else{
                sizeInput.value = 0;
            }
            sizeInput.index = i;
            sizeInput.delegate = self;
            [sizeInput setTextFieldDidEndEditingBlock:^(YYShoppingStyleSizeInputView *inputView) {
                if (inputView.value > sizeStock) {
                    [YYToast showToastWithTitle:[NSString stringWithFormat:NSLocalizedString(@"目前该尺码最大库存数为%ld，请重新输入", nil), sizeStock] andDuration:kAlertToastDuration];
                    inputView.value = sizeStock;
                }
            }];
        }

        for(;i<kMaxSizeCount;i++){
            sizeInput = [self valueForKey:[NSString stringWithFormat:@"sizeInput%ld",(i+1)]];
            sizeInput.hidden = YES;
            sizeInput.delegate = nil;
        }
    }
}

#pragma mark - --------------自定义响应----------------------
-(void)btnClick:(NSInteger)row section:(NSInteger)section andParmas:(NSArray *)parmas{
    if(self.delegate){
        [self.delegate btnClick:_indexPath.row section:_indexPath.section andParmas:@[@"styleNumChange",@(row),[parmas objectAtIndex:0]]];
    }
}
- (IBAction)selectColorAction:(id)sender {
    if(self.delegate){
        if([_colorModel.isSelect boolValue]){
            _colorModel.isSelect = @(NO);
        }else{
            _colorModel.isSelect = @(YES);
        }
        [self.delegate btnClick:_indexPath.row section:_indexPath.section andParmas:@[@"selectColor",_colorModel.isSelect]];
    }
}
#pragma mark - --------------自定义方法----------------------
- (BOOL)useStockControl {
    if ([self.styleInfoModel.stockEnabled boolValue] && (!self.styleInfoModel.dateRange || !self.styleInfoModel.dateRange.start)) {
        return YES;
    }
    return NO;
}

#pragma mark - --------------other----------------------



@end

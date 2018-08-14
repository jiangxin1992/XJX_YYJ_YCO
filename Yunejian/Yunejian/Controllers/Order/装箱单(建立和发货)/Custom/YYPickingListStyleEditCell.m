//
//  YYPickingListStyleEditCell.m
//  yunejianDesigner
//
//  Created by yyj on 2018/6/15.
//  Copyright © 2018年 Apple. All rights reserved.
//

#import "YYPickingListStyleEditCell.h"

// c文件 —> 系统文件（c文件在前）
#import <objc/runtime.h>

// 控制器

// 自定义视图
#import "SCGIFImageView.h"

// 接口

// 分类
#import "UIImage+YYImage.h"

// 自定义类和三方类（ cocoapods类 > model > 工具类 > 其他）
#import "YYPackingListStyleModel.h"

#import "YYVerifyTool.h"

@interface YYPickingListStyleEditCell()<UITextFieldDelegate>

@property (nonatomic, strong) SCGIFImageView *styleColorImage;
@property (nonatomic, strong) UILabel *styleNameLabel;
@property (nonatomic, strong) UILabel *styleColorCodeLabel;

@property (nonatomic, strong) SCGIFImageView *sizeColorImage;
@property (nonatomic, strong) UILabel *sizeColorNameLabel;

@property (nonatomic, strong) UIView *downLine;

@property (nonatomic, strong) NSMutableArray *sizeInfoArray;
@property (nonatomic, strong) NSMutableArray *sizeInfoTextFieldArray;

@property(nonatomic,copy) void (^pickingListStyleCellBlock)(NSString *type);

@end

static void *EOCTextFieldKey = "EOCTextFieldKey";

@implementation YYPickingListStyleEditCell

#pragma mark - --------------生命周期--------------
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier WithBlock:(void(^)(NSString *type))block{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        _pickingListStyleCellBlock = block;
        [self SomePrepare];
        [self UIConfig];
    }
    return self;
}
- (void)awakeFromNib {
    [super awakeFromNib];
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
- (void)PrepareData{
    _sizeInfoArray = [[NSMutableArray alloc] init];
    _sizeInfoTextFieldArray = [[NSMutableArray alloc] init];
}
- (void)PrepareUI{
    self.contentView.backgroundColor = _define_white_color;
}

#pragma mark - --------------UIConfig----------------------
-(void)UIConfig{
    WeakSelf(ws);

    _styleColorImage = [[SCGIFImageView alloc] init];
    [self.contentView addSubview:_styleColorImage];
    [_styleColorImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(50);
        make.height.width.mas_equalTo(46.5f);
        make.top.mas_equalTo(12);
    }];
    _styleColorImage.contentMode = 1;
    setBorderCustom(_styleColorImage, 1, [UIColor colorWithHex:@"EFEFEF"]);

    _styleNameLabel = [UILabel getLabelWithAlignment:0 WithTitle:nil WithFont:13.f WithTextColor:_define_black_color WithSpacing:0];
    [self.contentView addSubview:_styleNameLabel];
    [_styleNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.styleColorImage.mas_right).with.offset(18.5f);
        make.top.mas_equalTo(16);
        make.width.mas_equalTo(200);
    }];

    _styleColorCodeLabel = [UILabel getLabelWithAlignment:0 WithTitle:nil WithFont:12.f WithTextColor:[UIColor colorWithHex:@"919191"] WithSpacing:0];
    [self.contentView addSubview:_styleColorCodeLabel];
    [_styleColorCodeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.styleColorImage.mas_right).with.offset(18.5f);
        make.top.mas_equalTo(ws.styleNameLabel.mas_bottom).with.offset(3);
        make.width.mas_equalTo(200);
    }];

    _sizeColorImage = [[SCGIFImageView alloc] init];
    [self.contentView addSubview:_sizeColorImage];
    [_sizeColorImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(23.5);
        make.left.mas_equalTo(309.5);
        make.height.with.mas_equalTo(23);
    }];
    setBorderCustom(_sizeColorImage, 1, [UIColor colorWithHex:@"EFEFEF"]);
    _sizeColorImage.contentMode = UIViewContentModeScaleAspectFit;

    _sizeColorNameLabel = [UILabel getLabelWithAlignment:0 WithTitle:nil WithFont:13.f WithTextColor:[UIColor colorWithHex:@"919191"] WithSpacing:0];
    [self.contentView addSubview:_sizeColorNameLabel];
    [_sizeColorNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(ws.sizeColorImage);
        make.width.mas_equalTo(150);
        make.left.mas_equalTo(ws.sizeColorImage.mas_right).with.offset(9);
    }];
    _sizeColorNameLabel.numberOfLines = 2;

    _downLine = [UIView getCustomViewWithColor:[UIColor colorWithHex:@"D3D3D3"]];
    [self.contentView addSubview:_downLine];
    [_downLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(1);
        make.bottom.mas_equalTo(0);
        make.left.mas_equalTo(40);
        make.right.mas_equalTo(-40);
    }];
}
#pragma mark - --------------UpdateUI----------------------
-(void)updateUI{

    if(_packingListStyleModel){

        if(_isLastCell){
            [_downLine mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(-48);
            }];
        }else{
            [_downLine mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(0);
            }];
        }
        
        if(![NSString isNilOrEmpty:_packingListStyleModel.color.styleImg]){
            sd_downloadWebImageWithRelativePath(NO, _packingListStyleModel.color.styleImg, _styleColorImage, kNewsCover, 0);
        }else{
            sd_downloadWebImageWithRelativePath(NO, @"", _styleColorImage, kNewsCover, 0);
        }

        _styleNameLabel.text = _packingListStyleModel.styleName;

        _styleColorCodeLabel.text = [[NSString alloc] initWithFormat:@"%@%@",NSLocalizedString(@"款号：", nil),_packingListStyleModel.color.styleCode];

        //最左边颜色部份
        NSString *colorValue = _packingListStyleModel.color.colorValue;
        if (colorValue) {
            if ([colorValue hasPrefix:@"#"]
                && [colorValue length] == 7) {
                //16进制的色值
                UIColor *color = [UIColor colorWithHex:[colorValue substringFromIndex:1]];
                UIImage *colorImage = [UIImage imageWithColor:color size:CGSizeMake(25, 25)];
                _sizeColorImage.image = colorImage;
            }else{
                sd_downloadWebImageWithRelativePath(NO, colorValue, _sizeColorImage, kStyleColorImageCover, 0);
            }
        }else{
            UIColor *color = [UIColor clearColor];
            UIImage *colorImage = [UIImage imageWithColor:color size:CGSizeMake(25, 25)];
            _sizeColorImage.image = colorImage;
        }

        _sizeColorNameLabel.text = _packingListStyleModel.color.colorName;

        for (UIView *obj in _sizeInfoArray) {
            [obj removeFromSuperview];
        }
        [_sizeInfoArray removeAllObjects];

        //移除textfield的关联对象
        for (UITextField *sentAmountTextField in _sizeInfoTextFieldArray) {
            objc_removeAssociatedObjects(sentAmountTextField);
        }
        [_sizeInfoTextFieldArray removeAllObjects];

        UIView *lastView = nil;
        for (YYPackingListSizeModel *packingListSizeModel in _packingListStyleModel.color.sizes) {

            UIView *sizeView = [UIView getCustomViewWithColor:nil];
            [self.contentView addSubview:sizeView];
            [sizeView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(50);
                make.right.mas_equalTo(0);
                make.width.mas_equalTo(542);
                if(lastView){
                    make.top.mas_equalTo(lastView.mas_bottom).with.offset(0);
                }else{
                    make.top.mas_equalTo(10);
                }
            }];

            UILabel *sizeNameLabel = [UILabel getLabelWithAlignment:1 WithTitle:packingListSizeModel.sizeName WithFont:12.f WithTextColor:nil WithSpacing:0];
            [sizeView addSubview:sizeNameLabel];
            [sizeNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(0);
                make.width.mas_equalTo(65);
                make.centerY.mas_equalTo(sizeView);
            }];

            UILabel *orderAmountLabel = [UILabel getLabelWithAlignment:1 WithTitle:[packingListSizeModel.orderAmount stringValue] WithFont:12.f WithTextColor:nil WithSpacing:0];
            [sizeView addSubview:orderAmountLabel];
            [orderAmountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(-354.5);
                make.width.mas_equalTo(65);
                make.centerY.mas_equalTo(sizeView);
            }];

            UILabel *remainingAmountLabel = [UILabel getLabelWithAlignment:1 WithTitle:[packingListSizeModel.remainingAmount stringValue] WithFont:13.f WithTextColor:[UIColor colorWithHex:@"ED6499"] WithSpacing:0];
            [sizeView addSubview:remainingAmountLabel];
            [remainingAmountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(-234.5);
                make.width.mas_equalTo(48);
                make.centerY.mas_equalTo(sizeView);
            }];

            UITextField *sentAmountTextField = [UITextField getTextFieldWithPlaceHolder:nil WithAlignment:1 WithFont:13.f WithTextColor:nil WithLeftWidth:0 WithRightWidth:0 WithSecureTextEntry:NO HaveBorder:YES WithBorderColor:[UIColor colorWithHex:@"D3D3D3"]];
            [sizeView addSubview:sentAmountTextField];
            [sentAmountTextField mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(-87);
                make.centerY.mas_equalTo(sizeView);
                make.width.mas_equalTo(60);
                make.height.mas_equalTo(30);
            }];
            sentAmountTextField.delegate = self;
            sentAmountTextField.layer.cornerRadius = 3.f;
            sentAmountTextField.keyboardType = UIKeyboardTypeNumberPad;
            sentAmountTextField.text = [packingListSizeModel.sentAmount stringValue];
            objc_setAssociatedObject(sentAmountTextField, EOCTextFieldKey, packingListSizeModel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

            [_sizeInfoArray addObject:sizeView];
            [_sizeInfoTextFieldArray addObject:sentAmountTextField];
            lastView = sizeView;
        }
    }
}

#pragma mark - --------------系统代理----------------------
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{

    YYPackingListSizeModel *packingListSizeModel = objc_getAssociatedObject(textField, EOCTextFieldKey);
    BOOL returnValue = NO;

    NSString *message = [[NSString alloc] initWithFormat:NSLocalizedString(@"目前该尺码最多可输入%ld",nil),[packingListSizeModel.remainingAmount integerValue]];
    NSString *str = [textField.text stringByReplacingCharactersInRange:range withString:string];

    if (![NSString isNilOrEmpty:str]) {
        if([YYVerifyTool numberVerift:str]){
            BOOL isCutout = NO;
            if([str hasPrefix:@"0"]){
                str = [str substringFromIndex:1];
                isCutout = YES;
            }

            if([str integerValue] > 0 && [str integerValue] <= [packingListSizeModel.remainingAmount integerValue]){
                if(isCutout){
                    message = nil;
                    textField.text = str;
                }else{
                    returnValue = YES;
                }
            }
        }
    }else{
        message = nil;
        textField.text = @"0";

    }
    if (![NSString isNilOrEmpty:message] && !returnValue) {
        [YYToast showToastWithView:self title:message  andDuration:kAlertToastDuration];
    }
    return returnValue;
}
- (void)textFieldDidEndEditing:(UITextField *)textField{

    YYPackingListSizeModel *packingListSizeModel = objc_getAssociatedObject(textField, EOCTextFieldKey);
    packingListSizeModel.sentAmount = @([textField.text integerValue]);

    //去更新submit按钮的状态
    if(_pickingListStyleCellBlock){
        _pickingListStyleCellBlock(@"update_submit_status");
    }
}
#pragma mark - --------------自定义响应----------------------

#pragma mark - --------------自定义方法----------------------


#pragma mark - --------------other----------------------


@end

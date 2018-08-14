//
//  YYPickingListStyleCell.m
//  yunejianDesigner
//
//  Created by yyj on 2018/6/15.
//  Copyright © 2018年 Apple. All rights reserved.
//

#import "YYPickingListStyleCell.h"

// c文件 —> 系统文件（c文件在前）

// 控制器

// 自定义视图
#import "SCGIFImageView.h"

// 接口

// 分类
#import "UIImage+YYImage.h"

// 自定义类和三方类（ cocoapods类 > model > 工具类 > 其他）
#import "YYPackingListStyleModel.h"

@interface YYPickingListStyleCell()

@property (nonatomic, strong) SCGIFImageView *styleColorImage;
@property (nonatomic, strong) UILabel *styleNameLabel;
@property (nonatomic, strong) UILabel *styleColorCodeLabel;

@property (nonatomic, strong) SCGIFImageView *sizeColorImage;
@property (nonatomic, strong) UILabel *sizeColorNameLabel;

@property (nonatomic, strong) UIView *downLine;

@property (nonatomic, strong) NSMutableArray *sizeInfoArray;

@property (nonatomic, assign) YYPickingListStyleType styleType;

@end

@implementation YYPickingListStyleCell

#pragma mark - --------------生命周期--------------
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier styleType:(YYPickingListStyleType)styleType{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        _styleType = styleType;
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
        if(ws.styleType == YYPickingListStyleTypePackageError){
            make.left.mas_equalTo(309.5);
        }else{
            make.left.mas_equalTo(349.5);
        }
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

    WeakSelf(ws);

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

        UIView *lastView = nil;
        for (YYPackingListSizeModel *packingListSizeModel in _packingListStyleModel.color.sizes) {

            UIView *sizeView = [UIView getCustomViewWithColor:nil];
            [self.contentView addSubview:sizeView];
            [sizeView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(50);
                make.right.mas_equalTo(0);
                if(ws.styleType == YYPickingListStyleTypePackageError){
                    make.width.mas_equalTo(542);
                }else{
                    make.width.mas_equalTo(452);
                }
                if(lastView){
                    make.top.mas_equalTo(lastView.mas_bottom).with.offset(0);
                }else{
                    make.top.mas_equalTo(10);
                }
            }];

            UILabel *sizeNameLabel = [UILabel getLabelWithAlignment:1 WithTitle:packingListSizeModel.sizeName WithFont:13.f WithTextColor:nil WithSpacing:0];
            [sizeView addSubview:sizeNameLabel];
            [sizeNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(0);
                make.width.mas_equalTo(65);
                make.centerY.mas_equalTo(sizeView);
            }];

            if(ws.styleType == YYPickingListStyleTypePackageError){
                //订单数
                UILabel *orderAmountLabel = [UILabel getLabelWithAlignment:1 WithTitle:[packingListSizeModel.orderAmount stringValue] WithFont:13.f WithTextColor:nil WithSpacing:0];
                [sizeView addSubview:orderAmountLabel];
                [orderAmountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.right.mas_equalTo(-374.5);
                    make.width.mas_equalTo(65);
                    make.centerY.mas_equalTo(sizeView);
                }];

                //确认收货
                UILabel *receivedAmountLabel = [UILabel getLabelWithAlignment:1 WithTitle:[packingListSizeModel.receivedAmount stringValue] WithFont:13.f WithTextColor:nil WithSpacing:0];
                [sizeView addSubview:receivedAmountLabel];
                [receivedAmountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.right.mas_equalTo(-274.5);
                    make.width.mas_equalTo(65);
                    make.centerY.mas_equalTo(sizeView);
                }];

                //异常
                UILabel *abnormalAmountLabel = [UILabel getLabelWithAlignment:1 WithTitle:[packingListSizeModel.abnormalAmount stringValue] WithFont:13.f WithTextColor:nil WithSpacing:0];
                [sizeView addSubview:abnormalAmountLabel];
                [abnormalAmountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.right.mas_equalTo(-195);
                    make.width.mas_equalTo(48);
                    make.centerY.mas_equalTo(sizeView);
                }];
                if([packingListSizeModel.abnormalAmount integerValue]){
                    abnormalAmountLabel.textColor = [UIColor colorWithHex:@"EF4E31"];
                }

                //本次发货
                UILabel *sentAmountLabel = [UILabel getLabelWithAlignment:1 WithTitle:[packingListSizeModel.sentAmount stringValue] WithFont:13.f WithTextColor:nil WithSpacing:0];
                [sizeView addSubview:sentAmountLabel];
                [sentAmountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.right.mas_equalTo(-72);
                    make.width.mas_equalTo(90);
                    make.centerY.mas_equalTo(sizeView);
                }];
            }else{
                //本次发货
                UILabel *sentAmountLabel = [UILabel getLabelWithAlignment:1 WithTitle:[packingListSizeModel.sentAmount stringValue] WithFont:13.f WithTextColor:nil WithSpacing:0];
                [sizeView addSubview:sentAmountLabel];
                [sentAmountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.right.mas_equalTo(-137);
                    make.width.mas_equalTo(90);
                    make.centerY.mas_equalTo(sizeView);
                }];
                sentAmountLabel.font = getSemiboldFont(13.f);
            }
            [_sizeInfoArray addObject:sizeView];
            lastView = sizeView;
        }
    }
}

#pragma mark - --------------系统代理----------------------

#pragma mark - --------------自定义响应----------------------

#pragma mark - --------------自定义方法----------------------


#pragma mark - --------------other----------------------


@end

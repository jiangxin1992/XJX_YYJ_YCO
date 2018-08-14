//
//  YYPackageLogisticsInfoCell.m
//  yunejianDesigner
//
//  Created by yyj on 2018/6/29.
//  Copyright © 2018年 Apple. All rights reserved.
//

#import "YYPackageLogisticsInfoCell.h"

// c文件 —> 系统文件（c文件在前）

// 控制器

// 自定义视图

// 接口

// 分类
#import "UIImage+Tint.h"

// 自定义类和三方类（ cocoapods类 > model > 工具类 > 其他）
#import "YYPackingListDetailModel.h"

@interface YYPackageLogisticsInfoCell()

@property (nonatomic, strong) UIButton *checkLogisticsInfoButton;
@property (nonatomic, strong) UILabel *logisticsInfoItemLabel;
@property (nonatomic, strong) UILabel *logisticsInfoCreateTimeLabel;

@property (nonatomic, strong) UILabel *logisticsNoInfoItemLabel;

@property (nonatomic,copy) void (^packageLogisticsInfoCellBlock)(NSString *type);

@end

@implementation YYPackageLogisticsInfoCell

#pragma mark - --------------生命周期--------------
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier WithBlock:(void(^)(NSString *type))block{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        _packageLogisticsInfoCellBlock = block;
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
- (void)PrepareData{}
- (void)PrepareUI{
    self.contentView.backgroundColor = _define_white_color;
}

#pragma mark - --------------UIConfig----------------------
-(void)UIConfig{
    [self createBottomLine];
    [self createLogisticsInfoView];
    [self createLogisticsNoInfoView];
}
-(void)createBottomLine{
    UIView *bottomLine = [UIView getCustomViewWithColor:[UIColor colorWithHex:@"EFEFEF"]];
    [self.contentView addSubview:bottomLine];
    [bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(0);
        make.height.mas_equalTo(1);
        make.left.mas_equalTo(40);
        make.right.mas_equalTo(-40);
    }];
}
-(void)createLogisticsInfoView{

    WeakSelf(ws);

    _checkLogisticsInfoButton = [UIButton getCustomBtn];
    [self.contentView addSubview:_checkLogisticsInfoButton];
    [_checkLogisticsInfoButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(0);
        make.bottom.mas_equalTo(-1);
    }];

    _checkLogisticsInfoButton.backgroundColor = _define_white_color;
    [_checkLogisticsInfoButton addTarget:self action:@selector(checkLogisticsInfoAction:) forControlEvents:UIControlEventTouchUpInside];


    UIImageView *rightArrow = [[UIImageView alloc] init];
    [_checkLogisticsInfoButton addSubview:rightArrow];
    [rightArrow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-44);
        make.centerY.mas_equalTo(ws.checkLogisticsInfoButton.mas_centerY).with.offset(-0.5);
        make.width.mas_equalTo(10);
        make.height.mas_equalTo(18);
    }];
    rightArrow.image = [UIImage imageNamed:@"right"];
    rightArrow.contentMode = UIViewContentModeScaleAspectFit;

    _logisticsInfoItemLabel = [UILabel getLabelWithAlignment:0 WithTitle:nil WithFont:13.f WithTextColor:nil WithSpacing:0];
    [_checkLogisticsInfoButton addSubview:_logisticsInfoItemLabel];
    [_logisticsInfoItemLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(40);
        make.right.mas_equalTo(-35.5f);
        make.top.mas_equalTo(10);
    }];
    _logisticsInfoItemLabel.numberOfLines = 0;

    _logisticsInfoCreateTimeLabel = [UILabel getLabelWithAlignment:0 WithTitle:nil WithFont:12.f WithTextColor:[UIColor colorWithHex:@"919191"] WithSpacing:0];
    [_checkLogisticsInfoButton addSubview:_logisticsInfoCreateTimeLabel];
    [_logisticsInfoCreateTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(40);
        make.right.mas_equalTo(-40);
        make.top.mas_equalTo(ws.logisticsInfoItemLabel.mas_bottom).with.offset(5);
        make.bottom.mas_equalTo(-10);
    }];
}

-(void)createLogisticsNoInfoView{

    _logisticsNoInfoItemLabel = [UILabel getLabelWithAlignment:0 WithTitle:NSLocalizedString(@"暂未查询到物流信息，请耐心等待。",nil) WithFont:12.f WithTextColor:nil WithSpacing:0];
    [self.contentView addSubview:_logisticsNoInfoItemLabel];
    [_logisticsNoInfoItemLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(-1);
        make.left.mas_equalTo(40);
        make.right.mas_equalTo(-40);
        make.top.mas_equalTo(0);
    }];
    _logisticsNoInfoItemLabel.numberOfLines = 2;

}

#pragma mark - --------------UpdateUI----------------------
-(void)updateUI{

    if(_packingListDetailModel){

        if([_packingListDetailModel.express.message isEqualToString:@"ok"] && ![NSArray isNilOrEmpty:_packingListDetailModel.express.data]){
            //有物流信息
            _checkLogisticsInfoButton.hidden = NO;
            _logisticsNoInfoItemLabel.hidden = YES;

            YYExpressItemModel *expressItemModel = _packingListDetailModel.express.data[0];
            _logisticsInfoItemLabel.text = expressItemModel.context;

            if(![NSString isNilOrEmpty:expressItemModel.time]){

                NSString *transferTime = [expressItemModel transferTime];
                _logisticsInfoCreateTimeLabel.text = transferTime;

            }else{
                _logisticsInfoCreateTimeLabel.text = @"";
            }

        }else{
            //无物流信息
            _checkLogisticsInfoButton.hidden = YES;
            _logisticsNoInfoItemLabel.hidden = NO;
        }
    }
}

#pragma mark - --------------系统代理----------------------

#pragma mark - --------------自定义响应----------------------

-(void)checkLogisticsInfoAction:(UIButton *)sender{
    if(_packageLogisticsInfoCellBlock){
        _packageLogisticsInfoCellBlock(@"checkLogisticsInfo");
    }
}
#pragma mark - --------------自定义方法----------------------


#pragma mark - --------------other----------------------


@end

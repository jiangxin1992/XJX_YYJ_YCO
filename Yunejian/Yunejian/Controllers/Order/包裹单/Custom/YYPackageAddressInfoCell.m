//
//  YYPackageAddressInfoCell.m
//  yunejianDesigner
//
//  Created by yyj on 2018/6/29.
//  Copyright © 2018年 Apple. All rights reserved.
//

#import "YYPackageAddressInfoCell.h"

// c文件 —> 系统文件（c文件在前）

// 控制器

// 自定义视图

// 接口

// 分类

// 自定义类和三方类（ cocoapods类 > model > 工具类 > 其他）
#import "YYPackingListDetailModel.h"

@interface YYPackageAddressInfoCell()

@property (nonatomic, strong) UILabel *buyerNameLabel;

@property (nonatomic, strong) UILabel *orderCodeLabel;
@property (nonatomic, strong) UILabel *orderCreateTimeLabel;

@property (nonatomic, strong) UILabel *expressLabel;

@property (nonatomic, strong) UILabel *receiverLabel;
@property (nonatomic, strong) UILabel *receiverPhoneLabel;
@property (nonatomic, strong) UILabel *receiverAddressLabel;

@end

@implementation YYPackageAddressInfoCell

#pragma mark - --------------生命周期--------------
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
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
    WeakSelf(ws);

    _buyerNameLabel = [UILabel getLabelWithAlignment:0 WithTitle:nil WithFont:13.f WithTextColor:nil WithSpacing:0];
    [self.contentView addSubview:_buyerNameLabel];
    [_buyerNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(40);
        make.right.mas_equalTo(-40);
        make.top.mas_equalTo(10);
    }];
    _buyerNameLabel.font = getSemiboldFont(13.f);

    _orderCodeLabel = [UILabel getLabelWithAlignment:0 WithTitle:nil WithFont:12.f WithTextColor:[UIColor colorWithHex:@"919191"] WithSpacing:0];
    [self.contentView addSubview:_orderCodeLabel];
    [_orderCodeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(40);
        make.top.mas_equalTo(ws.buyerNameLabel.mas_bottom).with.offset(10);
    }];

    _orderCreateTimeLabel = [UILabel getLabelWithAlignment:0 WithTitle:nil WithFont:12.f WithTextColor:[UIColor colorWithHex:@"919191"] WithSpacing:0];
    [self.contentView addSubview:_orderCreateTimeLabel];
    [_orderCreateTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.orderCodeLabel.mas_right).with.offset(15);
        make.centerY.mas_equalTo(ws.orderCodeLabel);
    }];

    _expressLabel = [UILabel getLabelWithAlignment:0 WithTitle:nil WithFont:12.f WithTextColor:_define_black_color WithSpacing:0];
    [self.contentView addSubview:_expressLabel];
    [_expressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(40);
        make.right.mas_equalTo(-40);
        make.top.mas_equalTo(ws.orderCodeLabel.mas_bottom).with.offset(10);
    }];

    _receiverLabel = [UILabel getLabelWithAlignment:0 WithTitle:nil WithFont:12.f WithTextColor:_define_black_color WithSpacing:0];
    [self.contentView addSubview:_receiverLabel];
    [_receiverLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(40);
        make.top.mas_equalTo(ws.expressLabel.mas_bottom).with.offset(10);
        make.bottom.mas_equalTo(-10);
    }];

    _receiverPhoneLabel = [UILabel getLabelWithAlignment:0 WithTitle:nil WithFont:12.f WithTextColor:_define_black_color WithSpacing:0];
    [self.contentView addSubview:_receiverPhoneLabel];
    [_receiverPhoneLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.receiverLabel.mas_right).with.offset(15);
        make.centerY.mas_equalTo(ws.receiverLabel);
    }];

    _receiverAddressLabel = [UILabel getLabelWithAlignment:0 WithTitle:nil WithFont:12.f WithTextColor:_define_black_color WithSpacing:0];
    [self.contentView addSubview:_receiverAddressLabel];
    [_receiverAddressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.receiverPhoneLabel.mas_right).with.offset(15);
        make.centerY.mas_equalTo(ws.receiverLabel);
    }];


    UIView *bottomLine = [UIView getCustomViewWithColor:[UIColor colorWithHex:@"EFEFEF"]];
    [self.contentView addSubview:bottomLine];
    [bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(0);
        make.height.mas_equalTo(1);
        make.left.mas_equalTo(40);
        make.right.mas_equalTo(-40);
    }];

}

#pragma mark - --------------UpdateUI----------------------
-(void)updateUI{
    if(_packingListDetailModel){
        _buyerNameLabel.text = _packingListDetailModel.buyerName;
        _orderCodeLabel.text = [[NSString alloc] initWithFormat:@"%@%@",NSLocalizedString(@"订单号：",nil),_packingListDetailModel.orderCode];
        _orderCreateTimeLabel.text = [[NSString alloc] initWithFormat:@"%@%@",NSLocalizedString(@"建单时间：",nil),getShowDateByFormatAndTimeInterval(@"yyyy/MM/dd HH:mm:ss",[_packingListDetailModel.orderCreateTime stringValue])];
        _expressLabel.text = [[NSString alloc] initWithFormat:@"%@%@%@",_packingListDetailModel.logisticsName,NSLocalizedString(@"：",nil),_packingListDetailModel.logisticsCode];
        _receiverLabel.text = [[NSString alloc] initWithFormat:NSLocalizedString(@"收件人：%@",nil),_packingListDetailModel.receiver];
        _receiverPhoneLabel.text = [[NSString alloc] initWithFormat:NSLocalizedString(@"电话：%@",nil),_packingListDetailModel.receiverPhone];
        _receiverAddressLabel.text = [[NSString alloc] initWithFormat:NSLocalizedString(@"收件地址：%@",nil),_packingListDetailModel.receiverAddress];
    }
}

#pragma mark - --------------系统代理----------------------

#pragma mark - --------------自定义响应----------------------


#pragma mark - --------------自定义方法----------------------


#pragma mark - --------------other----------------------


@end

//
//  YYPickingListInfoCell.m
//  yunejianDesigner
//
//  Created by yyj on 2018/6/15.
//  Copyright © 2018年 Apple. All rights reserved.
//

#import "YYPickingListInfoCell.h"

// c文件 —> 系统文件（c文件在前）

// 控制器

// 自定义视图

// 接口

// 分类

// 自定义类和三方类（ cocoapods类 > model > 工具类 > 其他）

#import "YYPackingListDetailModel.h"

@interface YYPickingListInfoCell()

@property (nonatomic, strong) UIView *infoView;
@property (nonatomic, strong) UILabel *buyerNameLabel;
@property (nonatomic, strong) UILabel *orderCodeLabel;
@property (nonatomic, strong) UILabel *orderCreateTimeLabel;

@property (nonatomic, strong) UIView *styleTitleView;

@property (nonatomic, strong) NSMutableArray *sizeTitleArray;

@end

@implementation YYPickingListInfoCell

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
- (void)PrepareData{
    _sizeTitleArray = [[NSMutableArray alloc] init];
}
- (void)PrepareUI{
    self.contentView.backgroundColor = _define_white_color;
}

#pragma mark - --------------UIConfig----------------------
-(void)UIConfig{
    [self createInfoView];
    [self createStyleTitleView];
}
-(void)createInfoView{
    WeakSelf(ws);

    _infoView = [UIView getCustomViewWithColor:_define_white_color];
    [self.contentView addSubview:_infoView];
    [_infoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(0);
        make.height.mas_equalTo(49);
    }];

    UIView *downLine = [UIView getCustomViewWithColor:[UIColor colorWithHex:@"D3D3D3"]];
    [_infoView addSubview:downLine];
    [downLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(1);
        make.bottom.mas_equalTo(0);
        make.left.mas_equalTo(40);
        make.right.mas_equalTo(-40);
    }];

    _buyerNameLabel = [UILabel getLabelWithAlignment:0 WithTitle:nil WithFont:15.f WithTextColor:_define_black_color WithSpacing:0];
    [_infoView addSubview:_buyerNameLabel];
    [_buyerNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(40);
        make.top.mas_equalTo(0);
        make.bottom.mas_equalTo(downLine.mas_top).with.offset(0);
        make.width.mas_equalTo(380);
    }];
    _buyerNameLabel.font = [UIFont boldSystemFontOfSize:15.f];

    _orderCodeLabel = [UILabel getLabelWithAlignment:0 WithTitle:nil WithFont:13.f WithTextColor:[UIColor colorWithHex:@"919191"] WithSpacing:0];
    [_infoView addSubview:_orderCodeLabel];
    [_orderCodeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.buyerNameLabel.mas_right).with.offset(20);
        make.top.mas_equalTo(0);
        make.bottom.mas_equalTo(downLine.mas_top).with.offset(0);
    }];

    _orderCreateTimeLabel = [UILabel getLabelWithAlignment:0 WithTitle:nil WithFont:13.f WithTextColor:[UIColor colorWithHex:@"919191"] WithSpacing:0];
    [_infoView addSubview:_orderCreateTimeLabel];
    [_orderCreateTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.orderCodeLabel.mas_right).with.offset(20);
        make.top.mas_equalTo(0);
        make.bottom.mas_equalTo(downLine.mas_top).with.offset(0);
    }];
}
-(void)createStyleTitleView{
    WeakSelf(ws);

    _styleTitleView = [UIView getCustomViewWithColor:_define_white_color];
    [self.contentView addSubview:_styleTitleView];
    [_styleTitleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        make.top.mas_equalTo(ws.infoView.mas_bottom).with.offset(0);
    }];

    UIView *downLine = [UIView getCustomViewWithColor:[UIColor colorWithHex:@"D3D3D3"]];
    [_styleTitleView addSubview:downLine];
    [downLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(1);
        make.bottom.mas_equalTo(0);
        make.left.mas_equalTo(40);
        make.right.mas_equalTo(-40);
    }];
}
#pragma mark - --------------UpdateUI----------------------
-(void)updateUI{
    [self updateInfoView];
    [self updateStyleTitleView];
}
-(void)updateInfoView{
    if(_packingListDetailModel){
        _buyerNameLabel.text = _packingListDetailModel.buyerName;
        CGFloat buyerNameWidth = getWidthWithHeight(30, _packingListDetailModel.buyerName, [UIFont boldSystemFontOfSize:15.f]) + 1;
        if(buyerNameWidth > 380.f){
            [_buyerNameLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo(380.f);
            }];
        }else{
            [_buyerNameLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo(buyerNameWidth);
            }];
        }
        _orderCodeLabel.text = [[NSString alloc] initWithFormat:@"%@%@",NSLocalizedString(@"订单号：", nil),_packingListDetailModel.orderCode];
        _orderCreateTimeLabel.text = [NSString stringWithFormat:@"%@%@",NSLocalizedString(@"建单时间：",nil),getShowDateByFormatAndTimeInterval(@"yyyy/MM/dd HH:mm:ss",[_packingListDetailModel.orderCreateTime stringValue])];
    }
}
-(void)updateStyleTitleView{

    for (UIView *obj in _sizeTitleArray) {
        [obj removeFromSuperview];
    }
    [_sizeTitleArray removeAllObjects];

    NSArray *noteTitleArr = nil;
    if(_isStyleEdit){
        noteTitleArr = @[@{@"title":NSLocalizedString(@"款式", nil),@"isright":@(NO),@"length":@(50),@"isbold":@(NO),@"width":@(0)}
                         ,@{@"title":NSLocalizedString(@"颜色", nil),@"isright":@(NO),@"length":@(309.5),@"isbold":@(NO),@"width":@(0)}
                         ,@{@"title":NSLocalizedString(@"尺码", nil),@"isright":@(YES),@"length":@(477),@"isbold":@(NO),@"width":@(65)}
                         ,@{@"title":NSLocalizedString(@"订单数", nil),@"isright":@(YES),@"length":@(354.5),@"isbold":@(NO),@"width":@(65)}
                         ,@{@"title":NSLocalizedString(@"待发货", nil),@"isright":@(YES),@"length":@(234.5),@"isbold":@(NO),@"width":@(48)}
                         ,@{@"title":NSLocalizedString(@"本次发货数", nil),@"isright":@(YES),@"length":@(72),@"isbold":@(YES),@"width":@(90)}
                         ];
    }else{
        noteTitleArr = @[@{@"title":NSLocalizedString(@"款式", nil),@"isright":@(NO),@"length":@(50),@"isbold":@(NO),@"width":@(0)}
                         ,@{@"title":NSLocalizedString(@"颜色", nil),@"isright":@(NO),@"length":@(349.5),@"isbold":@(NO),@"width":@(0)}
                         ,@{@"title":NSLocalizedString(@"尺码", nil),@"isright":@(YES),@"length":@(387),@"isbold":@(NO),@"width":@(65)}
                         ,@{@"title":NSLocalizedString(@"本次发货数", nil),@"isright":@(YES),@"length":@(137),@"isbold":@(YES),@"width":@(90)}];
    }
    for (NSDictionary *titleDict in noteTitleArr) {
        UILabel *label = [UILabel getLabelWithAlignment:1 WithTitle:titleDict[@"title"] WithFont:14.f WithTextColor:_define_black_color WithSpacing:0];
        [_styleTitleView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            if([titleDict[@"width"] floatValue]){
                make.width.mas_equalTo(@([titleDict[@"width"] floatValue]));
            }
            make.top.mas_equalTo(0);
            make.bottom.mas_equalTo(-1);
            if([titleDict[@"isright"] boolValue]){
                make.right.mas_equalTo(-[titleDict[@"length"] integerValue]);
            }else{
                make.left.mas_equalTo([titleDict[@"length"] integerValue]);
            }
        }];
        label.font = [titleDict[@"isbold"] boolValue]?getSemiboldFont(14.f):getFont(14.f);
        [_sizeTitleArray addObject:label];
    }
}
#pragma mark - --------------系统代理----------------------

#pragma mark - --------------自定义响应----------------------

#pragma mark - --------------自定义方法----------------------
+(CGFloat)cellHeight{
    return 90.f;
}

#pragma mark - --------------other----------------------


@end

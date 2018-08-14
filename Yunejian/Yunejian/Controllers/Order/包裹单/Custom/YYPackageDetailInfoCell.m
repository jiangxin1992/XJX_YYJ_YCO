//
//  YYPackageDetailInfoCell.m
//  Yunejian
//
//  Created by yyj on 2018/8/10.
//  Copyright © 2018年 yyj. All rights reserved.
//

#import "YYPackageDetailInfoCell.h"

@interface YYPackageDetailInfoCell()

@property (nonatomic, strong) NSMutableArray *sizeTitleArray;

@end

@implementation YYPackageDetailInfoCell

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
    [self createStyleTitleView];
}
-(void)createStyleTitleView{
    UIView *downLine = [UIView getCustomViewWithColor:[UIColor colorWithHex:@"D3D3D3"]];
    [self.contentView addSubview:downLine];
    [downLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(1);
        make.bottom.mas_equalTo(0);
        make.left.mas_equalTo(40);
        make.right.mas_equalTo(-40);
    }];
}
#pragma mark - --------------UpdateUI----------------------
-(void)updateUI{
    [self updateStyleTitleView];
}
-(void)updateStyleTitleView{

    for (UIView *obj in _sizeTitleArray) {
        [obj removeFromSuperview];
    }
    [_sizeTitleArray removeAllObjects];

    NSArray *noteTitleArr = nil;
    if(_isPackageError){
        noteTitleArr = @[@{@"title":NSLocalizedString(@"款式", nil),@"isright":@(NO),@"length":@(50),@"isbold":@(NO),@"width":@(0)}
                         ,@{@"title":NSLocalizedString(@"颜色", nil),@"isright":@(NO),@"length":@(309.5),@"isbold":@(NO),@"width":@(0)}
                         ,@{@"title":NSLocalizedString(@"尺码", nil),@"isright":@(YES),@"length":@(487),@"isbold":@(NO),@"width":@(65)}
                         ,@{@"title":NSLocalizedString(@"订单数", nil),@"isright":@(YES),@"length":@(374.5),@"isbold":@(NO),@"width":@(65)}
                         ,@{@"title":NSLocalizedString(@"确认收货", nil),@"isright":@(YES),@"length":@(274.5),@"isbold":@(NO),@"width":@(65)}
                         ,@{@"title":NSLocalizedString(@"异常", nil),@"isright":@(YES),@"length":@(195),@"isbold":@(YES),@"width":@(48)}
                         ,@{@"title":NSLocalizedString(@"本次发货数", nil),@"isright":@(YES),@"length":@(72),@"isbold":@(NO),@"width":@(90)}
                         ];
    }else{
        noteTitleArr = @[@{@"title":NSLocalizedString(@"款式", nil),@"isright":@(NO),@"length":@(50),@"isbold":@(NO),@"width":@(0)}
                         ,@{@"title":NSLocalizedString(@"颜色", nil),@"isright":@(NO),@"length":@(349.5),@"isbold":@(NO),@"width":@(0)}
                         ,@{@"title":NSLocalizedString(@"尺码", nil),@"isright":@(YES),@"length":@(387),@"isbold":@(NO),@"width":@(65)}
                         ,@{@"title":NSLocalizedString(@"本次发货数", nil),@"isright":@(YES),@"length":@(137),@"isbold":@(YES),@"width":@(90)}];
    }
    for (NSDictionary *titleDict in noteTitleArr) {
        UILabel *label = [UILabel getLabelWithAlignment:1 WithTitle:titleDict[@"title"] WithFont:14.f WithTextColor:_define_black_color WithSpacing:0];
        [self.contentView addSubview:label];
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
    return 41;
}

#pragma mark - --------------other----------------------


@end

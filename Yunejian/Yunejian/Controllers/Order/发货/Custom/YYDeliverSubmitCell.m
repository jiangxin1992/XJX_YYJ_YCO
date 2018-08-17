//
//  YYDeliverSubmitCell.m
//  Yunejian
//
//  Created by yyj on 2018/7/30.
//  Copyright © 2018年 yyj. All rights reserved.
//

#import "YYDeliverSubmitCell.h"

// c文件 —> 系统文件（c文件在前）

// 控制器

// 自定义视图

// 接口

// 分类

// 自定义类和三方类（ cocoapods类 > model > 工具类 > 其他）
#import "YYDeliverModel.h"

@interface YYDeliverSubmitCell()

@property (nonatomic, strong) UIButton *submitBtn;

@property(nonatomic,copy) void (^deliverSubmitCellBlock)(NSString *type);

@end

@implementation YYDeliverSubmitCell

#pragma mark - --------------生命周期--------------
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier WithBlock:(void(^)(NSString *type))block{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        _deliverSubmitCellBlock = block;
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
    if(!_submitBtn){
        _submitBtn = [UIButton getCustomTitleBtnWithAlignment:0 WithFont:15.f WithSpacing:0 WithNormalTitle:NSLocalizedString(@"确认发货",nil) WithNormalColor:_define_white_color WithSelectedTitle:NSLocalizedString(@"确认发货",nil) WithSelectedColor:_define_white_color];
        [self.contentView addSubview:_submitBtn];
        [_submitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(174);
            make.bottom.mas_equalTo(0);
            make.height.mas_equalTo(40);
            make.width.mas_equalTo(130);
        }];
        [_submitBtn addTarget:self action:@selector(submitAction:) forControlEvents:UIControlEventTouchUpInside];
        _submitBtn.selected = YES;
        _submitBtn.backgroundColor = [UIColor colorWithHex:@"d3d3d3"];
    }
}

#pragma mark - --------------UpdateUI----------------------
-(void)updateUI{
    if([_deliverModel canDeliverWithBuyerStockEnabled:[_buyerStockEnabled boolValue]]){
        _submitBtn.selected = NO;
        _submitBtn.backgroundColor = _define_black_color;
    }else{
        _submitBtn.selected = YES;
        _submitBtn.backgroundColor = [UIColor colorWithHex:@"d3d3d3"];
    }
}

#pragma mark - --------------系统代理----------------------

#pragma mark - --------------自定义响应----------------------
-(void)submitAction:(UIButton *)sender{
    if(!sender.selected){
        if(_deliverSubmitCellBlock){
            _deliverSubmitCellBlock(@"submit");
        }
    }
}

#pragma mark - --------------自定义方法----------------------


#pragma mark - --------------other----------------------


@end

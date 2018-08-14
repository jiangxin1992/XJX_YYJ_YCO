//
//  YYShowroomCollectionViewCell.m
//  Yunejian
//
//  Created by yyj on 2017/3/21.
//  Copyright © 2017年 yyj. All rights reserved.
//

#import "YYShowroomCollectionViewCell.h"

#import "SCGIFImageView.h"

@interface YYShowroomCollectionViewCell()
@property (nonatomic,strong) UIView *underline;
@property (nonatomic,strong) SCGIFImageView *userHead;
@property (nonatomic,strong) UILabel *brandnameLabel;
@property (nonatomic,strong) UILabel *usernameLabel;
@end

@implementation YYShowroomCollectionViewCell

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        [self SomePrepare];
        [self UIConfig];
    }
    return self;
}
#pragma mark - SomePrepare
-(void)SomePrepare
{
    [self PrepareData];
    [self PrepareUI];
}

-(void)PrepareData{}
-(void)PrepareUI{}
#pragma mark - UIConfig
-(void)UIConfig{
    _underline = [UIView getCustomViewWithColor:[UIColor colorWithHex:@"efefef"]];
    [self.contentView addSubview:_underline];
    [_underline mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(42);
        make.right.mas_equalTo(0);
        make.height.mas_equalTo(1);
        make.bottom.mas_equalTo(0);
    }];
    
    _userHead = [[SCGIFImageView alloc] init];
    [self.contentView addSubview:_userHead];
    _userHead.contentMode = UIViewContentModeScaleAspectFit;
    _userHead.layer.masksToBounds=YES;
    _userHead.layer.borderColor=[[UIColor colorWithHex:@"efefef"] CGColor];
    _userHead.layer.borderWidth=1;
    _userHead.layer.cornerRadius=35;
    [_userHead mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_underline.mas_left).with.offset(15);
        make.width.height.mas_equalTo(70);
        make.centerY.mas_equalTo(self.contentView);
    }];
    
    
    _brandnameLabel = [UILabel getLabelWithAlignment:0 WithTitle:nil WithFont:16.0f WithTextColor:_define_black_color WithSpacing:0];
    [self.contentView addSubview:_brandnameLabel];
    [_brandnameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_userHead.mas_right).with.offset(16);
        make.right.mas_equalTo(underline);
        make.bottom.mas_equalTo(_userHead.mas_centerY).with.offset(0);
    }];
    
    _usernameLabel = [UILabel getLabelWithAlignment:0 WithTitle:nil WithFont:16.0f WithTextColor:[UIColor colorWithHex:@"919191"] WithSpacing:0];
    [self.contentView addSubview:_usernameLabel];
    [_usernameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_userHead.mas_right).with.offset(16);
        make.right.mas_equalTo(underline);
        make.top.mas_equalTo(_userHead.mas_centerY).with.offset(0);
    }];

}
-(void)setShowroomModel:(YYShowroomBrandModel *)showroomModel{
    _showroomModel = showroomModel;
    
    sd_downloadWebImageWithRelativePath(NO, _showroomModel.brandLogo, _userHead, kBuyerCardImage, 0);
    
    if(![NSString isNilOrEmpty:_showroomModel.brandName]){
        _brandnameLabel.text = _showroomModel.brandName;
    }else{
        _brandnameLabel.text = @"";
    }
    
    if(![NSString isNilOrEmpty:_showroomModel.designerName]){
        _usernameLabel.text = _showroomModel.designerName;
    }else{
        _usernameLabel.text = @"";
    }
}
-(void)setIsleft:(BOOL)isleft{
    _isleft = isleft;
    if(_isleft){
        [_underline mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(42);
            make.right.mas_equalTo(0);
        }];
    }else{
        [_underline mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.right.mas_equalTo(-42);
        }];
    }
}
@end

//
//  YYShowroomBrandHeadView.m
//  yunejianDesigner
//
//  Created by yyj on 2017/3/6.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "YYShowroomBrandHeadView.h"

#import "SCGIFImageView.h"
#import "SCGIFButtonView.h"

#import "YYShowroomBrandListModel.h"

@interface YYShowroomBrandHeadView()

@property (strong ,nonatomic) SCGIFImageView *adBackImg;
@property (strong ,nonatomic) SCGIFImageView *userHeadButton;
@property (strong ,nonatomic) UILabel *userNameLabel;
@property (strong ,nonatomic) UIView *leftLine;
@property (strong ,nonatomic) UIView *rightLine;
@property (strong ,nonatomic) UIView *bottomLine;
@end

@implementation YYShowroomBrandHeadView
#pragma mark - init
-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self)
    {
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
-(void)PrepareUI
{
    self.backgroundColor = _define_white_color;
    _leftLine = [UIView getCustomViewWithColor:[UIColor colorWithHex:@"efefef"]];
    _rightLine = [UIView getCustomViewWithColor:[UIColor colorWithHex:@"efefef"]];
}
#pragma mark - UIConfig
-(void)UIConfig
{
    _adBackImg = [[SCGIFImageView alloc] init];
    [self addSubview:_adBackImg];
    _adBackImg.contentMode = UIViewContentModeScaleAspectFill;
    _adBackImg.clipsToBounds = YES;
    _adBackImg.backgroundColor = [UIColor colorWithHex:@"f8f8f8"];
    [_adBackImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(-20);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(floor((240.0f/2048.0f)*SCREEN_WIDTH));
    }];
    
    _userHeadButton = [[SCGIFImageView alloc] init];
    [self addSubview:_userHeadButton];
    _userHeadButton.backgroundColor = _define_white_color;
    _userHeadButton.contentMode = UIViewContentModeScaleAspectFit;
    setBorderCustom(_userHeadButton, 3, nil);
    _userHeadButton.userInteractionEnabled=YES;
    [_userHeadButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headClick)]];
    [_userHeadButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(_adBackImg.mas_bottom).with.offset(21);
        make.width.height.mas_equalTo(100);
        make.centerX.mas_equalTo(_userHeadButton.superview);
    }];
    
    _userNameLabel = [UILabel getLabelWithAlignment:1 WithTitle:@"" WithFont:16.0f WithTextColor:nil WithSpacing:0];
    [self addSubview:_userNameLabel];
    [_userNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(17);
        make.right.mas_equalTo(-17);
        make.top.mas_equalTo(_userHeadButton.mas_bottom).with.offset(12);
    }];
    
    UIView *lastView = nil;
    for (int i=0; i<2; i++) {
        UIView *bottomLine = i?_rightLine:_leftLine;
        [self addSubview:bottomLine];
        bottomLine.hidden = YES;
        [bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
            if(!i){
                make.left.mas_equalTo(42);
            }else{
                make.left.mas_equalTo(lastView.mas_right).with.offset(40);
                make.right.mas_equalTo(-42);
                make.width.mas_equalTo(lastView);
            }
            make.height.mas_equalTo(1);
            make.top.mas_equalTo(_adBackImg.mas_bottom).with.offset(99);
        }];
        lastView = bottomLine;
    }
    
    _bottomLine = [UIView getCustomViewWithColor:[UIColor colorWithHex:@"efefef"]];
    [self addSubview:_bottomLine];
    _bottomLine.hidden = YES;
    [_bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(42);
        make.right.mas_equalTo(-42);
        make.height.mas_equalTo(1);
        make.top.mas_equalTo(_adBackImg.mas_bottom).with.offset(99);
    }];
}
#pragma mark - Setter
-(void)setShowroomBrandListModel:(YYShowroomBrandListModel *)ShowroomBrandListModel
{
    _ShowroomBrandListModel = ShowroomBrandListModel;
    
    if(_ShowroomBrandListModel && ![NSString isNilOrEmpty:_ShowroomBrandListModel.pic]){
        sd_downloadWebImageWithRelativePath(NO, _ShowroomBrandListModel.pic, _adBackImg, kLookBookImage, 0);
    }else{
        sd_downloadWebImageWithRelativePath(NO, @"", _adBackImg, kLookBookImage, 0);
    }
    
    if(_ShowroomBrandListModel && ![NSString isNilOrEmpty:_ShowroomBrandListModel.logo]){
        sd_downloadWebImageWithRelativePath(NO, _ShowroomBrandListModel.logo, _userHeadButton, kBuyerCardImage, 0);
    }else{
        
        sd_downloadWebImageWithRelativePath(NO, @"", _userHeadButton, kBuyerCardImage, 0);
    }
    
    _userNameLabel.text = _ShowroomBrandListModel.name;
    if(_ShowroomBrandListModel.brandList.count){
        _bottomLine.hidden = YES;
        _rightLine.hidden = NO;
        _leftLine.hidden = NO;
    }else{
        _bottomLine.hidden = NO;
        _rightLine.hidden = YES;
        _leftLine.hidden = YES;
    }
}
#pragma mark - SomeAction
-(void)bottomIsHide:(BOOL )ishide
{
    if(_bottomLine)
    {
        _bottomLine.hidden = ishide;
    }
}

-(void)headClick{
    if(_block)
    {
        _block(@"headclick");
    }
}

@end

//
//  YYUserLogoInfoCell.m
//  Yunejian
//
//  Created by Apple on 15/9/22.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import "YYUserLogoInfoCell.h"

@implementation YYUserLogoInfoCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    _verifyButton.layer.masksToBounds=YES;
    _verifyButton.layer.borderColor=[[UIColor colorWithHex:@"919191"] CGColor];
    _verifyButton.layer.borderWidth=1;
    _verifyButton.layer.cornerRadius=2.0f;
}
//dequeueReusableCellWithIdentifier

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    if(!_warnLabel)
    {
        _warnLabel=[UILabel getLabelWithAlignment:0 WithTitle:@"" WithFont:15.0f WithTextColor:[UIColor colorWithRed:237.0f/255.0f green:100.0f/255.0f blue:152.0f/255.0f alpha:1] WithSpacing:0];
        [_verifyBackView addSubview:_warnLabel];
        [_warnLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(20);
            make.centerY.mas_equalTo(_verifyBackView);
        }];
    }
    
    if(!_tipLabel)
    {
        _tipLabel=[UILabel getLabelWithAlignment:0 WithTitle:@"" WithFont:14.0f WithTextColor:[UIColor colorWithHex:kDefaultTitleColor_pad] WithSpacing:0];
        [_verifyBackView addSubview:_tipLabel];
        [_tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(_warnLabel.mas_right).with.offset(12);
            make.centerY.mas_equalTo(_verifyBackView);
        }];
    }
}
- (IBAction)verifyAction:(id)sender {
    if(_block){
        _block(@"verify");
    }
}

- (IBAction)changeLogoHandler:(id)sender {
    if(self.delegate != nil ){
        [self.delegate handlerBtnClick:sender];
    }
}




@end

//
//  YYBrandViewCell.m
//  Yunejian
//
//  Created by Apple on 15/12/2.
//  Copyright © 2015年 yyj. All rights reserved.
//

#import "YYBrandViewCell.h"

@implementation YYBrandViewCell

-(void)updateUI{
    if(_brandInfoModel && _brandInfoModel.logoPath != nil){
        sd_downloadWebImageWithRelativePath(NO, _brandInfoModel.logoPath, _logoImageView, kSeriesCover, 0);
    }else{
        sd_downloadWebImageWithRelativePath(NO, @"", _logoImageView, kSeriesCover, 0);
    }
    _brandInfoBtn.layer.borderColor = [UIColor blackColor].CGColor;
    _brandInfoBtn.layer.borderWidth = 1;
    
    _brandNameLabel.text = _brandInfoModel.brandName;
    _emailLabel.text = _brandInfoModel.email;
}
- (IBAction)infoBtnHandler:(id)sender {
    if(self.delegate){
        [self.delegate btnClick:_indexPath.row section:_indexPath.section andParmas:nil];
    }
}
- (IBAction)cancelBtnHandler:(id)sender {
    if(self.delegate){
        [self.delegate btnClick:_indexPath.row section:_indexPath.section andParmas:@[]];
    }
}
@end

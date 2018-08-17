//
//  YYOrderModifyListCell.m
//  Yunejian
//
//  Created by Apple on 15/10/29.
//  Copyright © 2015年 yyj. All rights reserved.
//

#import "YYOrderModifyListCell.h"

#import "UIImage+YYImage.h"

@implementation YYOrderModifyListCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)updateUI{
    
//    [self downloadLogoImageWithRelativePath:_currentOrderLogo andImageView:self.logoImageView];
    sd_downloadWebImageWithRelativePath(NO, _currentOrderLogo, self.logoImageView, kLogoCover, 0);

}
//- (void)downloadLogoImageWithRelativePath:(NSString *)imageRelativePath andImageView:(SCGIFImageView *)imageView{
//
//    sd_downloadWebImageWithRelativePath(NO, imageRelativePath, imageView, kLogoCover, 0);
//}

@end

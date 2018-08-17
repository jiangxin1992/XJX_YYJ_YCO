//
//  YYBuyerInfoViewCell.m
//  Yunejian
//
//  Created by Apple on 15/12/14.
//  Copyright © 2015年 yyj. All rights reserved.
//

#import "YYBuyerInfoViewCell.h"

@implementation YYBuyerInfoViewCell
- (IBAction)addBtnHandler:(id)sender {
    if(self.delegate){
        [self.delegate btnClick:_indexPath.row section:_indexPath.section andParmas:@[]];
    }
}

- (IBAction)detaiBtnHandler:(id)sender {
    if(self.delegate){
        [self.delegate btnClick:_indexPath.row section:_indexPath.section andParmas:nil];
    }
}

-(void)updateUI{
    if(_buyerModel != nil){
        _nameLabel.text = _buyerModel.name;
        NSString *_nation = [LanguageManager isEnglishLanguage]?_buyerModel.nationEn:_buyerModel.nation;
        NSString *_province = [LanguageManager isEnglishLanguage]?_buyerModel.provinceEn:_buyerModel.province;
        NSString *_city = [LanguageManager isEnglishLanguage]?_buyerModel.cityEn:_buyerModel.city;
        
        _cityLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ %@%@",nil),_nation,_province,_city];

        _priceLabel.text = replaceMoneyFlag([NSString stringWithFormat:NSLocalizedString(@"经营款式零售价格范围：￥%@ -￥%@",nil),_buyerModel.priceMin,_buyerModel.priceMax],0);
        
        _connBrandLabel.text = [NSString stringWithFormat:NSLocalizedString(@"合作过的品牌：%@",nil),[_buyerModel.businessBrands componentsJoinedByString:@" "]];
        
        if(_buyerModel.logoPath && ![_buyerModel.logoPath isEqualToString:@""]){
            sd_downloadWebImageWithRelativePath(NO, _buyerModel.logoPath, _logoImageView, kLogoCover, 0);
        }else{
            _logoImageView.image = [UIImage imageNamed:@"default_icon"];
        }
        for (int i=0; i<1; i++) {
//            SCGIFImageView *lookbookImage = [self valueForKey:[NSString stringWithFormat:@"introImage%d",(i+1)]];
            NSString *imageRelativePath = @"";
            if(i < [_buyerModel.storeImgs count]){
                imageRelativePath = [_buyerModel.storeImgs objectAtIndex:i];
            }
//            sd_downloadWebImageWithRelativePath(NO, imageRelativePath, lookbookImage, kLookBookCover, 0);
            _introImage1.contentMode = UIViewContentModeScaleAspectFit;
            sd_downloadWebImageWithRelativePath(YES, imageRelativePath, _introImage1, kLookBookCover, UIViewContentModeScaleAspectFit);
            
        }
        
        //add
        _addBtn.hidden = YES;
        //[_addBtn setImage:[UIImage imageNamed:@"down"] forState:UIControlStateNormal];
        //[_addBtn setImage:[UIImage imageNamed:@"up"] forState:UIControlStateSelected];
        _connStatusLabel.hidden = YES;
        if([_buyerModel.connectStatus integerValue] == -1){
            _addBtn.hidden = NO;
        }else if([_buyerModel.connectStatus integerValue] == 0){
            _connStatusLabel.hidden = NO;
        }else if([_buyerModel.connectStatus integerValue] == 2){
            _connStatusLabel.hidden = NO;
        }
        
        //desc
        NSString *descStr = _buyerModel.introduction;
        if([descStr isEqualToString:@""]){
            
            descStr = NSLocalizedString(@"无买手店简介",nil);
        }
        NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
        paraStyle.lineHeightMultiple = 1.2;
        NSDictionary *attrDict = @{ NSParagraphStyleAttributeName: paraStyle,
                                    NSFontAttributeName: [UIFont systemFontOfSize: 12] };
        CGSize textSize = [descStr sizeWithAttributes:attrDict];
        //float cellWidth = CGRectGetWidth(_buyerDescLabel.frame);
        float cellHeight = CGRectGetHeight(_buyerDescLabel.frame);
        NSInteger desrow = ceilf(cellHeight / textSize.height);
        for (int i =0 ; i<desrow; i++) {
            descStr = [descStr stringByAppendingString:@"\n"];
        }
        _buyerDescLabel.attributedText = [[NSAttributedString alloc] initWithString: descStr attributes: attrDict];
        
    }else{
        sd_downloadWebImageWithRelativePath(NO, @"", _logoImageView, kLogoCover, 0);
        _introImage1.contentMode = UIViewContentModeScaleAspectFit;
        sd_downloadWebImageWithRelativePath(YES, @"", _introImage1, kLookBookCover, UIViewContentModeScaleAspectFit);
        
//        sd_downloadWebImageWithRelativePath(NO, @"", _introImage1, kLookBookCover, 0);
        _nameLabel.text = NSLocalizedString(@"买手店名称",nil);
        _cityLabel.text =  @"";
        _priceLabel.text = NSLocalizedString(@"经营款式零售价格范围",nil);
        _connBrandLabel.text = NSLocalizedString(@"合作过的买手店：",nil);
        _buyerDescLabel.text = [[NSString alloc] initWithFormat:@"%@\n\n\n\n",NSLocalizedString(@"无品牌简介",nil)];
        _detailBtn.hidden = YES;
        _addBtn.hidden = YES;
         _connStatusLabel.hidden = YES;
    }
}

@end

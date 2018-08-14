//
//  YYBrandInfoViewCell.m
//  Yunejian
//
//  Created by Apple on 15/12/3.
//  Copyright © 2015年 yyj. All rights reserved.
//

#import "YYBrandInfoViewCell.h"

static NSInteger cellWidth = 435;
static NSInteger cellHeight = 335;
static NSInteger descTxtMinHeight = 38;
@implementation YYBrandInfoViewCell
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
    if(_designerModel != nil){
        _nameLabel.text = _designerModel.brandName;
        _emailLabel.text =  _designerModel.email;
        NSString *retailerNameStr =[_designerModel.retailerNameList componentsJoinedByString:@" "];
    
        _connBuyersLabel.text =[NSString stringWithFormat:NSLocalizedString(@"合作过的买手店：%@",nil),retailerNameStr] ;
        
        sd_downloadWebImageWithRelativePath(NO, _designerModel.logo, _logoImageView, kLogoCover, 0);
        for (int i=0; i<3; i++) {
            SCGIFImageView *lookbookImage = [self valueForKey:[NSString stringWithFormat:@"lookbookImage%d",(i+1)]];
            NSString *imageRelativePath = @"";
            if(i < [_designerModel.lookBookPicList count]){
                imageRelativePath = [_designerModel.lookBookPicList objectAtIndex:i];
            }
            sd_downloadWebImageWithRelativePath(NO, imageRelativePath, lookbookImage, kLookBookCover, 0);

        }
        
        //add
        _addBtn.hidden = YES;
        //[_addBtn setImage:[UIImage imageNamed:@"down"] forState:UIControlStateNormal];
        //[_addBtn setImage:[UIImage imageNamed:@"up"] forState:UIControlStateSelected];
        _connStatusLabel.hidden = YES;
        if([_designerModel.connectStatus integerValue] == -1){
            _addBtn.hidden = NO;
        }else if([_designerModel.connectStatus integerValue] == 0){
            _connStatusLabel.hidden = NO;
        }else if([_designerModel.connectStatus integerValue] == 2){
            _connStatusLabel.hidden = NO;
        }
        
        //desc
        NSString *descStr = _designerModel.brandDescription;
        if([descStr isEqualToString:@""]){
            
            descStr = NSLocalizedString(@"无品牌简介",nil);
        }
        NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
        paraStyle.lineHeightMultiple = 1.3;
        NSDictionary *attrDict = @{ NSParagraphStyleAttributeName: paraStyle,
                                    NSFontAttributeName: [UIFont systemFontOfSize: 12] };
        CGSize textSize = [descStr sizeWithAttributes:attrDict];
        if(textSize.width > cellWidth*2){
            _detailBtn.hidden = NO;
            if(_curShowDetailRow == _indexPath.row){
                _detailBtn.selected = YES;
            }else{
                _detailBtn.selected = NO;
            }
            //[descStr s];
        }else{
            if(textSize.width < cellWidth){
                descStr = [descStr stringByAppendingString:@"\n"];
            }
            _detailBtn.hidden = YES;
        }
        _brandDescLabel.attributedText = [[NSAttributedString alloc] initWithString: descStr attributes: attrDict];
        
    }else{
        sd_downloadWebImageWithRelativePath(NO, @"", _logoImageView, kLogoCover, 0);
        _lookbookImage1.contentMode = UIViewContentModeScaleAspectFit;
        sd_downloadWebImageWithRelativePath(YES, @"", _lookbookImage1, kLookBookCover, UIViewContentModeScaleAspectFit);
//        sd_downloadWebImageWithRelativePath(NO, @"", _lookbookImage1, kLookBookCover, 0);
        sd_downloadWebImageWithRelativePath(NO, @"", _lookbookImage2, kLookBookCover, 0);
        sd_downloadWebImageWithRelativePath(NO, @"", _lookbookImage3, kLookBookCover, 0);
        _nameLabel.text = NSLocalizedString(@"品牌名称", nil);
        _emailLabel.text = NSLocalizedString(@"Email", nil);
        _connBuyersLabel.text = NSLocalizedString(@"合作过的买手店：",nil);
        _brandDescLabel.text = NSLocalizedString(@"无品牌简介",nil);
        _detailBtn.hidden = YES;
        _addBtn.hidden = YES;
         _connStatusLabel.hidden = YES;
    }
}

+(float)HeightForCell:(NSString *)desc{
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.lineHeightMultiple = 1.3;
    NSDictionary *attrDict = @{ NSParagraphStyleAttributeName: paraStyle,
                                NSFontAttributeName: [UIFont systemFontOfSize: 12] };
//    CGSize textSize = [desc sizeWithAttributes:attrDict];
//    float textTotalWidth = textSize.width;
//    NSInteger rowNum = ceilf(textTotalWidth/cellWidth);
//    float textTotalHeight = rowNum * ceilf(textSize.height);
    float textTotalHeight = getTxtHeight(cellWidth, desc, attrDict);
    textTotalHeight = MAX(textTotalHeight, descTxtMinHeight);
    return (cellHeight + textTotalHeight - descTxtMinHeight);
}
@end

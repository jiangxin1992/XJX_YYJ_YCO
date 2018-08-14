//
//  YYBuyerInfoViewCell.h
//  Yunejian
//
//  Created by Apple on 15/12/14.
//  Copyright © 2015年 yyj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYBuyerModel.h"
#import "SCGIFImageView.h"

@interface YYBuyerInfoViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet SCGIFImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *cityLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UIButton *addBtn;
@property (weak, nonatomic) IBOutlet SCGIFImageView *introImage1;

@property (weak, nonatomic) IBOutlet UILabel *connBrandLabel;
@property (weak, nonatomic) IBOutlet UILabel *buyerDescLabel;
@property (weak, nonatomic) IBOutlet UIButton *detailBtn;
//@property (weak, nonatomic) IBOutlet UILabel *connStatusLabel;
@property (weak, nonatomic) IBOutlet UIButton *connStatusLabel;
@property (weak,nonatomic) id<YYTableCellDelegate>  delegate;
@property (nonatomic,strong) NSIndexPath *indexPath;
@property (nonatomic,copy) YYBuyerModel *buyerModel;
- (IBAction)addBtnHandler:(id)sender;

-(void)updateUI;
@end

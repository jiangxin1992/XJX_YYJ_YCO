//
//  YYSeriesInfoViewCell.h
//  Yunejian
//
//  Created by Apple on 15/12/3.
//  Copyright © 2015年 yyj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYOpusSeriesModel.h"
#import "SCGIFImageView.h"
@interface YYSeriesInfoViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet SCGIFImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *styleAmountLabel;
@property (weak, nonatomic) IBOutlet UILabel *seasonLabel;
@property (weak, nonatomic) IBOutlet UILabel *supplyTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderDueTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@property (weak, nonatomic) IBOutlet UIButton *detailBtn;
@property (nonatomic,copy)YYOpusSeriesModel *seriesModel;
@property (nonatomic,copy)NSString *seriesDescription;
- (IBAction)detailBtnHamdler:(id)sender;

@property (weak,nonatomic) id<YYTableCellDelegate>  delegate;
@property (nonatomic,strong) NSIndexPath *indexPath;
-(void)updateUI;
@end

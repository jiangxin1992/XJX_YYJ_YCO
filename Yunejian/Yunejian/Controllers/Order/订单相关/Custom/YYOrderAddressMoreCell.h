//
//  YYOrderAddressMoreCell.h
//  Yunejian
//
//  Created by Apple on 15/10/28.
//  Copyright © 2015年 yyj. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol YYOrderAddressMoreCellCellDelegate
-(void)moreAddressHandler;
@end
@interface YYOrderAddressMoreCell : UITableViewCell
//@property (strong , nonatomic) AddressButtonClicked moreButtonClicked;
- (IBAction)moreBtnHandler:(id)sender;
@property(nonatomic,weak)id<YYOrderAddressMoreCellCellDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIButton *moreBtn;
@end

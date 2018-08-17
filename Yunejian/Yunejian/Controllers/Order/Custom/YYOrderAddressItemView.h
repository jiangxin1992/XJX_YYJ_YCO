//
//  YYOrderAddressItemView.h
//  Yunejian
//
//  Created by Apple on 15/10/27.
//  Copyright © 2015年 yyj. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "YYOrderBuyerAddress.h"
#import "YYOrderInfoModel.h"

typedef void (^AddressButtonClicked)(NSInteger type, id info);
@interface YYOrderAddressItemView : UITableViewCell
@property (weak, nonatomic) IBOutlet UITextView *txtView;
@property (strong , nonatomic) AddressButtonClicked addressButtonClicked;
- (IBAction)clickHandler:(id)sender;
- (IBAction)updareHandler:(id)sender;
- (IBAction)deleteHandler:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;
@property (weak, nonatomic) IBOutlet UIButton *updateBtn;
@property (weak, nonatomic) IBOutlet UIButton *selectBtn;
@property (weak, nonatomic) IBOutlet UIView *selectView;
@property (weak, nonatomic) IBOutlet UILabel *noModfiyLabel;
@property ( nonatomic)  BOOL needBtn;
-(void)updateUI:(YYOrderBuyerAddress*)info;
@property (strong, nonatomic) YYOrderInfoModel *currentYYOrderInfoModel;
@property (strong, nonatomic) YYOrderBuyerAddress *currentinfo;
+(NSInteger) getCellHeight:(NSString *)desc;
@end

//
//  YYAddressCell.m
//  Yunejian
//
//  Created by yyj on 15/7/16.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import "YYAddressCell.h"

@interface YYAddressCell ()

@property (weak, nonatomic) IBOutlet UIButton *modifyButton;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *receiveLabel;

@end

@implementation YYAddressCell

- (IBAction)buttonClicked:(id)sender{
    if (_modifyAddressButtonClicked
        && _address) {
        _modifyAddressButtonClicked(_address);
    }
}

- (void)updateUI{
    [_modifyButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _modifyButton.titleLabel.textAlignment = NSTextAlignmentRight;
    _modifyButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    _modifyButton.contentEdgeInsets = UIEdgeInsetsMake(0,0, 0, 10);
    [self setTranslatesAutoresizingMaskIntoConstraints:YES];
    if (_address) {
        
        NSString *showAddress = @"";
        if (_address.defaultShipping){
            showAddress = [showAddress stringByAppendingString:NSLocalizedString(@"【默认】",nil)];
        }
        
        if (_address.defaultBilling) {
            showAddress = [showAddress stringByAppendingString:NSLocalizedString(@"【发票收件地】",nil)];
        }
        
        showAddress = [showAddress stringByAppendingString:[NSString stringWithFormat:@"  %@",_address.detailAddress]];
        _addressLabel.text = showAddress;
        
        _receiveLabel.text = [NSString stringWithFormat:NSLocalizedString(@"  收件人 %@ %@",nil),_address.receiverName,_address.receiverPhone];
        [_modifyButton setTitle:NSLocalizedString(@"修改",nil) forState:UIControlStateNormal];
    }
    
}

@end

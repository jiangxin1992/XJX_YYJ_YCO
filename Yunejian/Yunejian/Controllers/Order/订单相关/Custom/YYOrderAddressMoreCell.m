//
//  YYOrderAddressMoreCell.m
//  Yunejian
//
//  Created by Apple on 15/10/28.
//  Copyright © 2015年 yyj. All rights reserved.
//

#import "YYOrderAddressMoreCell.h"

@implementation YYOrderAddressMoreCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)moreBtnHandler:(id)sender {
    if(self.delegate){
        [self.delegate moreAddressHandler];
    }
}
@end

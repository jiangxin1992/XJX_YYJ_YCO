//
//  YYForgetPasswordTableInputEmailCell.m
//  Yunejian
//
//  Created by Apple on 16/10/17.
//  Copyright © 2016年 yyj. All rights reserved.
//

#import "YYForgetPasswordTableInputEmailCell.h"

@implementation YYForgetPasswordTableInputEmailCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}
-(void)dealloc{
    _indexPath = nil;
}



-(void)textFiledEditChanged:(NSNotification *)obj{
    [self.delegate btnClick:_indexPath.row section:_indexPath.section andParmas:@[_inputText.text,@(0)]];
}

-(void)updateCellInfo:(NSArray*)info{
    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
   [_tipBtn setHidden:YES];

    _inputText.secureTextEntry = NO;
    _inputText.keyboardType = UIKeyboardTypeEmailAddress;
}


- (IBAction)nextBtnHandler:(id)sender {
    if(![NSString isNilOrEmpty:_inputText.text]){
        [self.delegate btnClick:_indexPath.row section:_indexPath.section andParmas:@[_inputText.text,@(-1)]];
    }

}
@end

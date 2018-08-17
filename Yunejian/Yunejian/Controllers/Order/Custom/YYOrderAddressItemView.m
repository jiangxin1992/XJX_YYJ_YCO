//
//  YYOrderAddressItemView.m
//  Yunejian
//
//  Created by Apple on 15/10/27.
//  Copyright © 2015年 yyj. All rights reserved.
//

#import "YYOrderAddressItemView.h"

@implementation YYOrderAddressItemView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
static NSInteger txtWidth;
- (IBAction)clickHandler:(id)sender {
    if(_addressButtonClicked && _currentinfo){
        _addressButtonClicked(1,_currentinfo);
    }
}

- (IBAction)updareHandler:(id)sender {
    if(_addressButtonClicked && _currentinfo){
        _addressButtonClicked(2,_currentinfo);
    }
}

- (IBAction)deleteHandler:(id)sender {
    if(_addressButtonClicked && _currentinfo){
        _addressButtonClicked(3,_currentinfo);
    }
}

-(void)updateUI:(YYOrderBuyerAddress*)info{
    //_addressLabel.text = info.detailAddress;
    //            _receiverLabel.text = [NSString stringWithFormat:@"收件人 %@ 电话 %@",_currentYYOrderInfoModel.buyerAddress.receiverName,_currentYYOrderInfoModel.buyerAddress.receiverPhone];
    //
    _currentinfo = info;
    _noModfiyLabel.hidden = YES;
    if(_needBtn){
        if(_currentYYOrderInfoModel.addressModifAvailable){
            self.deleteBtn.hidden = NO;
            self.updateBtn.hidden = NO;
        }else{
            self.deleteBtn.hidden = YES;
            self.updateBtn.hidden = YES;
            _noModfiyLabel.hidden = NO;
        }
    }else{
        self.deleteBtn.hidden = YES;
        self.updateBtn.hidden = YES;
    }
    //[info getAddressStr];//
    _txtView.text = getBuyerAddressStr_pad(info);//[NSString stringWithFormat:@"%@ 收件人 %@ 电话 %@",info.detailAddress,info.receiverName,info.receiverPhone];
    txtWidth = CGRectGetWidth(_txtView.frame);
    [self.selectBtn setImage:[UIImage imageNamed:@"selectCircle"] forState:UIControlStateNormal];
      [self.selectBtn setImage:[UIImage imageNamed:@"selectedCircle"] forState:UIControlStateSelected];
    if(_currentYYOrderInfoModel && _currentYYOrderInfoModel.buyerAddress){
        if(_currentYYOrderInfoModel.buyerAddress.addressId == info.addressId){
            self.selectBtn.selected = YES;
            self.selectView.hidden = NO;
            //[_txtView setFont:[UIFont boldSystemFontOfSize:15]];
            [_txtView setFont:[UIFont systemFontOfSize:15]];
            return;
        }
    }
    [_txtView setFont:[UIFont systemFontOfSize:15]];
    self.selectView.hidden = YES;
    self.selectBtn.selected = NO;
}

+(NSInteger) getCellHeight:(NSString *)desc{
    txtWidth = SCREEN_WIDTH - 340;
    CGSize txtSize = [desc sizeWithAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:15]}];
    if(txtSize.width > (txtWidth)){
        return 60;
    }else{
        return 44;
    }
}
@end

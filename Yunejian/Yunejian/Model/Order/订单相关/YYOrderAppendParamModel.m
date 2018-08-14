//
//  YYOrderAppendParamModel.m
//  Yunejian
//
//  Created by Apple on 16/8/9.
//  Copyright © 2016年 yyj. All rights reserved.
//

#import "YYOrderAppendParamModel.h"

@implementation YYOrderAppendParamModel

-(NSString *)toDescription{
    NSMutableString * discription = [NSMutableString string];
    if (self.styleIds && [self.styleIds count] > 0) {
        [discription appendFormat:@"styleIds=%@", [self.styleIds componentsJoinedByString:@","]];
    }
    
    if (self.originOrderCode) {
        [discription appendFormat:@"&originOrderCode=%@", self.originOrderCode];
    }
    if (self.designerId) {
        [discription appendFormat:@"&out_trade_no=%@", self.designerId];
    }
    if (self.orderCreateTime) {
        [discription appendFormat:@"&orderCreateTime=%@", self.orderCreateTime];
    }
    
    if (self.buyerName) {
        [discription appendFormat:@"&buyerName=%@", self.buyerName];
    }
    if (self.businessCard) {
        [discription appendFormat:@"&businessCard=%@", self.businessCard];
    }
    if (self.realBuyerId) {
        [discription appendFormat:@"&realBuyerId=%@", self.realBuyerId];
    }
    
    if (self.buyerAddressId) {
        [discription appendFormat:@"&buyerAddressId=%@",self.buyerAddressId];//mobile.securitypay.pay
    }
    if (self.finalTotalPrice) {
        [discription appendFormat:@"&finalTotalPrice=%@",self.finalTotalPrice];//1
    }
    
    if (self.totalPrice) {
        [discription appendFormat:@"&totalPrice=%@",self.totalPrice];//utf-8
    }
    if (self.taxRate) {
        [discription appendFormat:@"&taxRate=%@",self.taxRate];//30m
    }
    if (self.payApp) {
        [discription appendFormat:@"&payApp=%@",self.payApp];//m.alipay.com
    }
    if (self.deliveryChoose) {
        [discription appendFormat:@"&deliveryChoose=%@",self.deliveryChoose];
    }
    if (self.billCreatePersonId) {
        [discription appendFormat:@"&billCreatePersonId=%@",self.billCreatePersonId];
    }
    if (self.orderDescription) {
        [discription appendFormat:@"&orderDescription=%@",self.orderDescription];
    }
    return discription;
    
}
@end

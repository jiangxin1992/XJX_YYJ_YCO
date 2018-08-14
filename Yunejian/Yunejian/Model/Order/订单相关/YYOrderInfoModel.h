//
//  YYOrderInfoModel.h
//  Yunejian
//
//  Created by yyj on 15/8/6.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import "JSONModel.h"

#import "YYOrderBuyerAddress.h"
#import "YYOrderOneInfoModel.h"
#import "YYOrderSeriesModel.h"
#import "YYOrderPackageStatModel.h"

@class YYStylesAndTotalPriceModel;

@interface YYOrderInfoModel : JSONModel

@property (nonatomic, strong) NSString <Optional>*orderCode;//订单号
@property (nonatomic, strong) NSNumber <Optional>*totalPrice;//原始总价
@property (nonatomic, strong) NSNumber <Optional>*finalTotalPrice;//最后价格
@property (strong, nonatomic) NSNumber <Optional>*prevTotalPrice;//原单的总价
@property (strong, nonatomic) NSNumber <Optional>*prevFinalTotalPrice;//原单的折后总价
@property (nonatomic, strong) NSNumber <Optional>*curType;//货币类型
@property (nonatomic, strong) NSNumber <Optional>*taxRate;//税率: 6 / 16 / null
@property (nonatomic, strong) NSNumber <Optional>*discount;//折扣: 0到100之间的整数
@property (nonatomic, strong) NSNumber <Optional>*stockEnabled;//是否使用库存管理
//购买的系列列表
@property (nonatomic, strong) NSMutableArray<YYOrderOneInfoModel, Optional,ConvertOnDemand> *groups;
@property (nonatomic, strong) NSMutableDictionary<YYOrderSeriesModel, Optional,ConvertOnDemand> *seriesMap;
@property (nonatomic, strong) NSNumber <Optional>*designerOrderStatus;//已下单 已确认 签合同 生成中  已发货 已收货
@property (nonatomic, strong) NSNumber <Optional>*buyerOrderStatus;//已下单 已确认 签合同 生成中  已发货 已收货
@property (nonatomic, strong) NSNumber <Optional>*autoReceivedHoursRemains;
@property (nonatomic, strong) NSNumber <Optional>*closeReqStatus;//-1 对方0 1自己
@property (nonatomic, assign) BOOL addressModifAvailable;//可否修改地址
@property (nonatomic, strong) NSString <Optional>*buyerName;//购买者名称
@property (nonatomic, strong) NSString <Optional>*buyerEmail;//购买者邮箱
@property (strong, nonatomic) NSString <Optional>*buyerLogo;
@property (nonatomic, strong) NSString <Optional>*deliveryChoose;//送货方式
@property (nonatomic, strong) NSNumber <Optional>*buyerAddressId;//购买者的地址ID
@property (nonatomic, strong) YYOrderBuyerAddress <Optional>*buyerAddress;//购买人的地址信息
@property (nonatomic, strong) NSString <Optional>*occasion;//下单场合
@property (nonatomic, strong) NSString <Optional>*orderDescription;//订单描述
@property (nonatomic, strong) NSString <Optional>*payApp;//付款方式
@property (nonatomic, strong) NSNumber <Optional>*orderCreateTime;//订单创建时间
@property (nonatomic, strong) NSString <Optional>*brandLogo;//logo
@property (nonatomic, strong) NSString <Optional>*brandName;//logo
@property (nonatomic, strong) NSString <Optional>*businessCard;//客户名片图片地址
@property (strong, nonatomic) NSNumber <Optional>*packageId;//未发货的包裹单id. 只对发货中的订单有效
@property (strong, nonatomic) NSNumber <Optional>*buyerStockEnabled;//此单的买手店库存是否已经开通 bool
@property (strong, nonatomic) NSNumber <Optional>*isForcedDelivery;//true表示是提前发货的订单；否则不是 bool

@property (nonatomic, strong) NSNumber <Optional>* orderConnStatus;//互联状态
//追单
@property (nonatomic, strong) NSNumber <Optional>* isAppend;//是否为追单
@property (nonatomic, strong) NSNumber <Optional>* hasAppend;//是否含有追单
@property (nonatomic, strong) NSString <Optional>* originalOrderCode;//原单订单号
@property (nonatomic, strong) NSString <Optional>* appendOrderCode;//追单订单号

//可能要移除的
@property (nonatomic, strong) NSNumber <Optional>*billCreatePersonId;//创建订单者的ID
@property (nonatomic, strong) NSString <Optional>*billCreatePersonName;//创建订单者的name
@property (nonatomic, strong) NSNumber <Optional>*billCreatePersonType;//创建订单者的type
@property (nonatomic, strong) NSNumber <Optional>*realBuyerId;//购买者名称
@property (nonatomic, strong) NSNumber <Optional>*designerId;//设计师的ID

@property (strong, nonatomic) NSString <Optional>*type;//订单类型

@property (strong, nonatomic) YYOrderPackageStatModel <Optional>*packageStat;

-(BOOL )isDesignerConfrim;

-(BOOL )isBuyerConfrim;

//中间临时使用的变量，只是本地用用
@property (strong, nonatomic) NSString <Optional>*shareCode;//临时订单号，离线创建订单时使用

@property (strong, nonatomic) NSString <Optional>*brandID;//创建订单者的name

+(NSInteger)getOrderSizeTotalAmountWidthDictionary:(NSDictionary*)dict;

+(NSInteger)getOrderStyleTotalNumWidthDictionary:(NSDictionary*)dict;

//计算一个订单的总款数，总件数和总价
-(YYStylesAndTotalPriceModel *)getTotalValueByOrderInfo:(BOOL )isEdit;

//计算一个提前完成发货订单的总款数，总件数和总价
-(YYStylesAndTotalPriceModel *)getNowTotalValueByOrderInfo;

//获得提前发货完成的款式
-(NSArray *)getUndeliveredStylesInDelivering;

//获得提前发货完成的款式(发货后的状态)
-(NSArray *)getUndeliveredStylesAfterDelivering;

//pre数据写入非pre
-(void)toPreData;

@end



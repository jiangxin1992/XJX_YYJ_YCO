//
//  YYShowroomInfoModel.h
//  yunejianDesigner
//
//  Created by yyj on 2017/3/8.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <JSONModel/JSONModel.h>

#import "YYShowRoomSubModel.h"

@interface YYShowroomInfoModel : JSONModel

@property (strong, nonatomic) NSArray<YYShowroomSubModel, Optional, ConvertOnDemand>* subList;//Showroom下的合作品牌
@property (strong, nonatomic) YYShowroomSubModel<Optional>* showroomInfo;//Showroom信息

@end

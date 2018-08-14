//
//  YYUserInfoCell.h
//  Yunejian
//
//  Created by yyj on 15/7/16.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYUserInfo.h"
#import "YYSeller.h"
#import "YYShowroomSubModel.h"
#import "YYShowRoomInfoModel.h"
#import "YYShowroomInfoByDesignerModel.h"

typedef NS_ENUM(NSInteger, ShowType) {
    ShowTypeEmail = 60000,
    ShowTypeUsername = 60001,
    ShowTypePhone = 60002,
    ShowTypeBrand = 60003,
    ShowTypeSeller = 60005,
    ShowTypeSubShowroom = 60006,
    ShowTypeContractTime = 6007,
    ShowTypeShowroomName = 6008,
    ShowTypeShowroomSub = 6009,
    ShowTypeShowroomStatus = 6010
};


typedef void (^ModifyButtonClicked)(YYUserInfo *userInfo, ShowType currentShowType);
typedef void (^SwitchClicked)(NSNumber *salesmanId,BOOL isOn);

// 修改权限
typedef void (^updatePowerWithId)(NSNumber *userId);
// 删除未激活的子账号
typedef void (^deleteNotActiveWithId)(NSNumber *userId);

@interface YYUserInfoCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *modifyButton;
@property (weak, nonatomic) IBOutlet UISwitch *statusSwitch;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@property (weak, nonatomic) IBOutlet UILabel *tipActiveLabel;

@property (weak, nonatomic) IBOutlet UIButton *updatePower;
@property (weak, nonatomic) IBOutlet UIButton *deleteNotActive;


@property(nonatomic,strong)YYUserInfo *userInfo;
@property(nonatomic,strong)YYSeller *seller;
@property(nonatomic,strong)YYShowroomSubModel *subModel;
@property (strong, nonatomic) YYShowroomInfoModel *ShowroomModel;
@property(strong, nonatomic) YYShowroomInfoByDesignerModel *showroomInfoByDesignerModel;

// 修改权限
@property(nonatomic,strong)updatePowerWithId updatePowerWithId;
// 删除未激活的子账号
@property(nonatomic,strong)deleteNotActiveWithId deleteNotActiveWithId;

@property(nonatomic,strong)ModifyButtonClicked modifyButtonClicked;
@property(nonatomic,strong)SwitchClicked switchClicked;
@property (nonatomic,copy) void (^block)(NSString *type);

- (void)updateUIWithShowType:(ShowType )showType;
- (void)setLabelStatus:(float)alpha;
@end

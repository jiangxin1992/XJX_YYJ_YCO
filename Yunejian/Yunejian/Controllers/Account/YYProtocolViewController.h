//
//  YYProtocolViewController.h
//  yunejianDesigner
//
//  Created by Apple on 16/11/15.
//  Copyright © 2016年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
@class YYShowroomAgentModel;
@interface YYProtocolViewController : UIViewController
@property(nonatomic,strong)CancelButtonClicked cancelButtonClicked;
@property(nonatomic,strong)NSString *protocolType;
@property(nonatomic,strong)NSString *nowTitle;
@property (nonatomic,strong)YYShowroomAgentModel *agentModel;
@end

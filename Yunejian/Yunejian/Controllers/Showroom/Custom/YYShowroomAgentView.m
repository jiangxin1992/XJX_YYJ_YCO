//
//  YYShowroomAgentView.m
//  Yunejian
//
//  Created by yyj on 2017/3/23.
//  Copyright © 2017年 yyj. All rights reserved.
//

#import "YYShowroomAgentView.h"

@implementation YYShowroomAgentView

-(instancetype)init{
    self = [super init];
    if(self){
        [self SomePrepare];
        [self UIConfig];
    }
    return self;
}
#pragma mark - SomePrepare
-(void)SomePrepare
{
    [self PrepareData];
    [self PrepareUI];
}

-(void)PrepareData{}
-(void)PrepareUI{}
#pragma mark - UIConfig
-(void)UIConfig{
    
}
-(void)setAgentModel:(YYShowroomAgentModel *)agentModel{
    _agentModel = agentModel;
    
}
@end

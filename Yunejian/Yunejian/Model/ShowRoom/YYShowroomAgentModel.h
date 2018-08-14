//
//  YYShowroomAgentModel.h
//  Yunejian
//
//  Created by yyj on 2017/3/23.
//  Copyright © 2017年 yyj. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface YYShowroomAgentModel : JSONModel

@property (strong, nonatomic) NSString<Optional> *contactEndTime;
@property (strong, nonatomic) NSString<Optional> *brandName;
@property (strong, nonatomic) NSString<Optional> *showroomName;
@property (strong, nonatomic) NSString<Optional> *contactStartTime;
@property (strong, nonatomic) NSString<Optional> *content;
@property (strong, nonatomic) NSString<Optional> *contentEn;
@property (strong, nonatomic) NSString<Optional> *designerName;

@end

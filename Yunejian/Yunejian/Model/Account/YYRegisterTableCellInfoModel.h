//
//  YYRegisterTableCellInfoModel.h
//  Yunejian
//
//  Created by Apple on 15/9/24.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol YYRegisterTableCellDelegate
-(void)selectClick:(NSInteger)type AndSection:(NSInteger)section andParmas:(NSArray *)parmas;
-(NSInteger)getTableCellMinY:(NSInteger)row AndSection:(NSInteger)section;
-(NSInteger)getTableHeight;
-(void)showTopView:(BOOL)show;
-(id)getDelegateView;
-(void)upLoadPhotoImage:(NSInteger )type pointX:(NSInteger)px pointY:(NSInteger)py isSingle:(BOOL )isSingle;
-(void)updateFrame:(NSInteger)offset andSection:(NSInteger )section;
@end

@interface YYRegisterTableCellInfoModel : NSObject

/** API参数*/
@property (nonatomic,copy) NSString *propertyKey;
/** 是否是必传参数 2(重复输入密码，为了防止参数传入)*/
@property  NSInteger ismust;
/** 标题*/
@property (nonatomic,copy) NSString *title;
/** 提示*/
@property (nonatomic,copy) NSString *tipStr;
/** 警告内容*/
@property (nonatomic,copy) NSString *warnStr;
/** 照片样式cell（YYRegisterTableBuyerPhotosCell） 标题*/
@property (nonatomic,copy) NSString *photoTitle;

/** value*/
@property (nonatomic,copy) NSString *value;

@property (nonatomic,copy) NSString *passwordvalue;//tmp

@property(nonatomic,strong) NSMutableArray *socialInfosValue;
//联系方式
@property(nonatomic,strong) NSMutableArray *contactInfosValue;
@property(nonatomic,strong) NSString *countryName;
@property(nonatomic,strong) NSString *phoneCode;
@property(nonatomic,strong) NSString *telecountryName;
@property(nonatomic,strong) NSString *telephoneCode;
@property(nonatomic,assign) BOOL contactWarn;

@property (nonatomic,assign) NSInteger brandRegisterType;//tmp

-(id)initWithParameters:(NSArray *)parameters;
-(id)initWithParameters:(NSArray *)parameters WithPhotoTitle:(NSString *)photoTitle;
////格式错误
-(BOOL)checkWarn;
-(NSString *)getParamStr;
//获取vaule
-(id)getValue;
@end

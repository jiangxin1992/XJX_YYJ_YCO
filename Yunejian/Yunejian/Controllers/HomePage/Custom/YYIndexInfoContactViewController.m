//
//  YYIndexInfoContactViewController.m
//  Yunejian
//
//  Created by yyj on 2016/12/29.
//  Copyright © 2016年 yyj. All rights reserved.
//

#import "YYIndexInfoContactViewController.h"

#import "YYTypeTextView.h"
#import "YYTypeButton.h"
#import "YYNoDataView.h"

#import "YYUserHomePageModel.h"

@interface YYIndexInfoContactViewController ()

@property (nonatomic,strong) NSMutableArray *contactArr;
@property (nonatomic,strong) NSMutableArray *socialArr;

@property (nonatomic,strong) UILabel *contactTitleLabel;
@property (nonatomic,strong) UILabel *socialTitleLabel;

@property (nonatomic,strong) UIView *noIntroductionDataView;

@end

@implementation YYIndexInfoContactViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}
#pragma mark - init
-(instancetype)initWithHomePageModel:(YYUserHomePageModel *)homePageModel WithBlock:(void(^)(NSString *type ,YYTypeButton *typeButton))block
{
    self=[super init];
    if(self)
    {
        _homePageModel=homePageModel;
        _block=block;
        [self SomePrepare];
        [self UIConfig];
        [self CreateNoDataView];
    }
    return self;
}
-(void)CreateNoDataView
{
    if(_noIntroductionDataView)
    {
        [_noIntroductionDataView removeFromSuperview];
        _noIntroductionDataView = nil;
    }
    
    _noIntroductionDataView = (YYNoDataView *)addNoDataView_pad(self.view,[NSString stringWithFormat:@"%@|icon:notxt_icon",NSLocalizedString(@"还没有添加品牌联系信息，点击右上角编辑",nil)],kDefaultBorderColor,@"noinfo_icon");
    [self.view addSubview:_noIntroductionDataView];
    [_noIntroductionDataView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.left.mas_equalTo(0);
        make.height.mas_equalTo(360);
        make.right.mas_equalTo(-35);
        
    }];
    _noIntroductionDataView.hidden=YES;
    
    NSMutableArray *_contactTempArr=[[NSMutableArray alloc] init];
    NSMutableArray *_socialTempArr=[[NSMutableArray alloc] init];
    
    [_homePageModel.userContactInfos enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if(![self isNilOrEmptyWithContactValue:[obj objectForKey:@"contactValue"] WithContactType:[obj objectForKey:@"contactType"]])
        {
            [_contactTempArr addObject:obj];
        }
    }];
    
    [_homePageModel.userSocialInfos enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if(![NSString isNilOrEmpty:[obj objectForKey:@"socialName"]])
        {
            [_socialTempArr addObject:obj];
        }
    }];
    
    if(!_contactTempArr.count&&!_socialTempArr.count)
    {
        _noIntroductionDataView.hidden=NO;
    }else
    {
        _noIntroductionDataView.hidden=YES;
    }
}
#pragma mark - SomePrepare
-(void)SomePrepare
{
    [self PrepareData];
    [self PrepareUI];
}

//数据解析  排序/视图创建
-(void)PrepareData
{
    
    NSMutableArray *_contactTempArr=[[NSMutableArray alloc] init];
    NSMutableArray *_socialTempArr=[[NSMutableArray alloc] init];
    
    [_homePageModel.userContactInfos enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if(![self isNilOrEmptyWithContactValue:[obj objectForKey:@"contactValue"] WithContactType:[obj objectForKey:@"contactType"]])
        {
            [_contactTempArr addObject:obj];
        }
        
    }];
    
    [_homePageModel.userSocialInfos enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if(![NSString isNilOrEmpty:[obj objectForKey:@"socialName"]])
        {
            [_socialTempArr addObject:obj];
        }
    }];
    
    if(_contactArr)
    {
        [_contactArr removeAllObjects];
    }else
    {
        _contactArr=[[NSMutableArray alloc] init];
    }
    
    if(_socialArr)
    {
        [_socialArr removeAllObjects];
    }else
    {
        _socialArr=[[NSMutableArray alloc] init];
    }
    //排序
    if(_contactTempArr.count)
    {
        //先排个序
        for (int i = 0; i < _contactTempArr.count - 1; i++) {
            //比较的躺数
            for (int j = 0; j < _contactTempArr.count - 1 - i; j++) {
                
                NSDictionary *obj = [_contactTempArr objectAtIndex:j];
                
                NSInteger contactType = [[obj objectForKey:@"contactType"] integerValue];
                //三目 条件以外的nextsocialTypeType表示新加字段 显示在最后
                //0 邮箱, 4 固定电话 1 电话, 2 QQ, 3 微信号,
                NSInteger idx=contactType==0?0:contactType==1?2:contactType==2?3:contactType==3?4:contactType==4?1:-1;
                
                NSDictionary *nextobj = [_contactTempArr objectAtIndex:j+1];
                
                NSInteger nextcontactType = [[nextobj objectForKey:@"contactType"] integerValue];
                
                
                NSInteger nextidx=nextcontactType==0?0:nextcontactType==1?2:nextcontactType==2?3:nextcontactType==3?4:nextcontactType==4?1:-1;
                
                //比较的次数
                if (idx > nextidx) {
                    //这里为升序排序
                    NSDictionary *temp = obj;
                    _contactTempArr[j] = _contactTempArr[j + 1];
                    //OC中的数组只能存储对象，所以这里转换成string对象
                    _contactTempArr[j + 1] = temp;
                }
            }
        }

        
        //0 邮箱，1 电话，2 QQ，3 微信号', 4 固定电话
        //0 邮箱, 4 固定电话 3 微信号, 1 电话, 2 QQ
        //0 邮箱, 4 固定电话 1 电话, 2 QQ, 3 微信号,
        //        _contactArr = @[@"email_icon1",@"telephone_icon",@"weixin_icon",@"phone_icon",@"qq_icon"];
        
        [_contactTempArr enumerateObjectsUsingBlock:^(NSDictionary  *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            NSMutableDictionary *tempDict=[obj mutableCopy];
            
            NSInteger contactType = [[obj objectForKey:@"contactType"] integerValue];
            
            NSString *type = contactType==0?@"email":contactType==1?@"phone":contactType==2?@"qq":contactType==3?@"weixin":contactType==4?@"telephone":@"";
            
            YYTypeTextView *contactTextView = [YYTypeTextView getCustomTextViewWithStr:@"" WithFont:13.0f WithTextColor:[UIColor colorWithHex:kDefaultTitleColor_pad]];
            contactTextView.editable=NO;
            contactTextView.scrollEnabled=NO;
            contactTextView.type = type;
            contactTextView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
            
            if(![NSString isNilOrEmpty:[obj objectForKey:@"contactValue"]])
            {
                contactTextView.text = [self getValueForObj:obj];
//                [obj objectForKey:@"contactValue"];
            }
            
            [tempDict setObject:contactTextView forKey:@"view"];
            
            [_contactArr addObject:tempDict];
        }];
    }
    
    if(_socialTempArr.count)
    {
        //先排个序
        for (int i = 0; i < _socialTempArr.count - 1; i++) {
            //比较的躺数
            for (int j = 0; j < _socialTempArr.count - 1 - i; j++) {
                
                NSDictionary *obj = [_socialTempArr objectAtIndex:j];
                
                NSInteger socialType = [[obj objectForKey:@"socialType"] integerValue];
                
                NSInteger idx=socialType==0?0:socialType==1?2:socialType==2?1:socialType==3?3:-1;
                
                NSDictionary *nextobj = [_socialTempArr objectAtIndex:j+1];
                
                NSInteger nextsocialTypeType = [[nextobj objectForKey:@"socialType"] integerValue];
                
                //三目 条件以外的nextsocialTypeType表示新加字段 显示在最后
                NSInteger nextidx=nextsocialTypeType==0?0:nextsocialTypeType==1?2:nextsocialTypeType==2?1:nextsocialTypeType==3?3:-1;
                
                //比较的次数
                if (idx > nextidx) {
                    //这里为升序排序
                    NSDictionary *temp = obj;
                    _socialTempArr[j] = _socialTempArr[j + 1];
                    //OC中的数组只能存储对象，所以这里转换成string对象
                    _socialTempArr[j + 1] = temp;
                }
            }
        }
        
        //0 新浪微博，1 微信公众号，2 Facebook，3 Ins'
        //0 新浪微博，2 Facebook，1 微信公众号，3 Ins'
        //    _socialArr = @[@"sina_icon",@"facebook_icon",@"weixin_icon",@"instagram_icon"];
        
        [_socialTempArr enumerateObjectsUsingBlock:^(NSDictionary  *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            NSMutableDictionary *tempDict=[obj mutableCopy];
            
            NSInteger socialType = [[obj objectForKey:@"socialType"] integerValue];
            
            NSString *type = socialType==0?@"sina":socialType==1?@"weixin":socialType==2?@"facebook":socialType==3?@"instagram":@"";
            
            BOOL isTextViewType=NO;
            if(socialType==1)
            {
                if([NSString isNilOrEmpty:[obj objectForKey:@"image"]])
                {
                    //空 uitextview
                    isTextViewType=YES;
                }else
                {
                    //非空 uilabel
                    isTextViewType=NO;
                }
            }else
            {
                if([NSString isNilOrEmpty:[obj objectForKey:@"url"]])
                {
                    //空 uitextview
                    isTextViewType=YES;
                }else
                {
                    //非空 uilabel
                    isTextViewType=NO;
                }
            }
            
            NSString *socialName = [obj objectForKey:@"socialName"];
            if(isTextViewType)
            {
                YYTypeTextView *socialTextView = [YYTypeTextView getCustomTextViewWithStr:@"" WithFont:13.0f WithTextColor:[UIColor colorWithHex:kDefaultTitleColor_pad]];
                socialTextView.text = socialType==1?[[NSString alloc] initWithFormat:NSLocalizedString(@"%@（公众号）",nil),socialName]:socialName;
                socialTextView.editable=NO;
                socialTextView.type = type;
                socialTextView.value = obj;
                socialTextView.scrollEnabled=NO;
                socialTextView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
                [tempDict setObject:socialTextView forKey:@"view"];
            }else
            {
                YYTypeButton *socialButton = [YYTypeButton getCustomTitleBtnWithAlignment:1 WithFont:13.0f WithSpacing:0 WithNormalTitle:nil WithNormalColor:[UIColor colorWithHex:kDefaultTitleColor_pad] WithSelectedTitle:nil WithSelectedColor:nil];
                socialButton.type = type;
                socialButton.value = obj;
                [socialButton addTarget:self action:@selector(socialAction:) forControlEvents:UIControlEventTouchUpInside];
                
                NSMutableAttributedString *content = nil;
                
                if(socialType==1)
                {
                    NSString *titleStr = [[NSString alloc] initWithFormat:NSLocalizedString(@"%@（公众号）",nil),socialName];
                    //微信
                    content = [[NSMutableAttributedString alloc]initWithString:titleStr];
                    
                    NSString *title = NSLocalizedString(@"（公众号）",nil);
                    
                    NSRange contentRange = {0,[content length]-[title length]};
                    
                    [content addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:contentRange];
                    
                    NSRange allContentRange = {0,[content length]};
                    
                    [content addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHex:kDefaultTitleColor_pad] range:allContentRange];
                    
                    [socialButton setAttributedTitle:content forState:UIControlStateNormal];
                    
                }else
                {
                    //非微信
                    content = [[NSMutableAttributedString alloc]initWithString:socialName];
                    
                    NSRange contentRange = {0,[content length]};
                    
                    [content addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:contentRange];
                    
                    [content addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHex:kDefaultTitleColor_pad] range:contentRange];
                    
                    [socialButton setAttributedTitle:content forState:UIControlStateNormal];
                    
                }
                
                [tempDict setObject:socialButton forKey:@"view"];
            }
            
            [_socialArr addObject:tempDict];
            
        }];
    }
}
//移除视图
-(void)PrepareUI
{
    [self.view.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
}
#pragma mark - UIConfig
-(void)UIConfig
{
    //0 邮箱, 4 固定电话 3 微信号, 1 电话, 2 QQ
    //0 新浪微博，2 Facebook，1 微信公众号，3 Ins'
//    NSLog(@"%@ %@",_contactArr,_socialArr);

    __block UIView *lastContactView=nil;
    if(_contactArr.count)
    {
        if(!_contactTitleLabel)
        {
            _contactTitleLabel=[UILabel getLabelWithAlignment:0 WithTitle:NSLocalizedString(@"商务联系方式",nil) WithFont:14.0f WithTextColor:nil WithSpacing:0];
            _contactTitleLabel.font=getSemiboldFont(14.0f);
        }
        [self.view addSubview:_contactTitleLabel];
        [_contactTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(26);
            make.left.right.mas_equalTo(0);
        }];
        //0 邮箱, 4 固定电话 3 微信号, 1 电话, 2 QQ
        [_contactArr enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            UIView *backView = [UIView getCustomViewWithColor:nil];
            [self.view addSubview:backView];
            [backView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.mas_equalTo(0);
                if(lastContactView)
                {
                    make.top.mas_equalTo(lastContactView.mas_bottom).with.offset(0);
                }else
                {
                    make.top.mas_equalTo(_contactTitleLabel.mas_bottom).with.offset(15);
                }
            }];
            
            NSInteger contactType = [[obj objectForKey:@"contactType"] integerValue];
            NSString *type = contactType==0?@"email":contactType==1?@"phone":contactType==2?@"qq":contactType==3?@"weixin":contactType==4?@"telephone":@"";
            UIView *rightView = [self getTextFieldRightView:type];
            [backView addSubview:rightView];
            [rightView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(0);
                make.top.bottom.mas_equalTo(backView);
                make.width.mas_equalTo(30);
            }];
            
            YYTypeTextView *textview = [obj objectForKey:@"view"];
            [backView addSubview:textview];

            [textview mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(rightView.mas_right).with.offset(0);
                make.right.top.bottom.mas_equalTo(0);
            }];
            lastContactView=backView;
        }];
    }
    
    __block UIView *lastSocialView=nil;
    if(_socialArr.count)
    {
        if(!_socialTitleLabel)
        {
            _socialTitleLabel=[UILabel getLabelWithAlignment:0 WithTitle:NSLocalizedString(@"社交账户",nil) WithFont:14.0f WithTextColor:nil WithSpacing:0];
            _socialTitleLabel.font=getSemiboldFont(14.0f);
        }
        [self.view addSubview:_socialTitleLabel];
        [_socialTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            if(lastContactView)
            {
                make.top.mas_equalTo(lastContactView.mas_bottom).with.offset(80);
            }else
            {
                make.top.mas_equalTo(26);
            }
            make.left.right.mas_equalTo(0);
        }];
        
        [_socialArr enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            UIView *backView = [UIView getCustomViewWithColor:nil];
            [self.view addSubview:backView];
            [backView mas_makeConstraints:^(MASConstraintMaker *make) {
                if(idx%2)
                {
                    make.left.mas_equalTo(lastSocialView.mas_right).with.offset(0);
                    make.right.mas_equalTo(-35);
                    make.top.mas_equalTo(lastSocialView);
                    make.width.mas_equalTo(lastSocialView);
                }else
                {
                    make.left.mas_equalTo(0);
                    if(lastSocialView)
                    {
                        make.top.mas_equalTo(lastSocialView.mas_bottom).with.offset(0);
                    }else
                    {
                        make.top.mas_equalTo(_socialTitleLabel.mas_bottom).with.offset(15);
                    }
                }
            }];
            
            NSInteger socialType = [[obj objectForKey:@"socialType"] integerValue];
            NSString *type = socialType==0?@"sina":socialType==1?@"weixin":socialType==2?@"facebook":socialType==3?@"instagram":@"";
            UIView *rightView = [self getTextFieldRightView:type];
            [backView addSubview:rightView];
            [rightView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(0);
                make.top.bottom.mas_equalTo(backView);
                make.width.mas_equalTo(30);
            }];
            
            if([[obj objectForKey:@"view"] isKindOfClass:[YYTypeTextView class]])
            {
                YYTypeTextView *textview = [obj objectForKey:@"view"];
                [backView addSubview:textview];
                
                [textview mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.mas_equalTo(rightView.mas_right).with.offset(0);
                    make.right.top.bottom.mas_equalTo(0);
                }];
                
            }else if([[obj objectForKey:@"view"] isKindOfClass:[YYTypeButton class]])
            {
                YYTypeButton *textview = [obj objectForKey:@"view"];
                [backView addSubview:textview];

                [textview mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.mas_equalTo(rightView.mas_right).with.offset(5);
                    make.right.top.bottom.mas_equalTo(0);
                }];
            }
            
            lastSocialView=backView;
        }];
    }

}
#pragma mark - SomeAction
-(NSString *)getValueForObj:(id )obj
{
    if([obj isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *tempObj = (NSDictionary *)obj;
        if([[tempObj objectForKey:@"contactType"] integerValue] == 4)
        {
            NSString *contactValue = [tempObj objectForKey:@"contactValue"];
            if(![NSString isNilOrEmpty:contactValue])
            {
                NSArray *tempArr = [contactValue componentsSeparatedByString:@" "];
                if(tempArr.count>1)
                {
                    NSArray *phoneTempArr = [tempArr[1] componentsSeparatedByString:@"-"];
                    if(phoneTempArr.count>2)
                    {
                        if([NSString isNilOrEmpty:phoneTempArr[2]])
                        {
                            //为空
                            return [[NSString alloc] initWithFormat:@"%@ %@-%@",tempArr[0],phoneTempArr[0],phoneTempArr[1]];
                        }
                        return contactValue;
                    }
                    return contactValue;
                }
                return contactValue;
            }else
            {
                return @"";
            }
        }
        return [tempObj objectForKey:@"contactValue"];
    }
    return @"";
}
-(BOOL)isNilOrEmptyWithContactValue:(NSString *)contactValue WithContactType:(NSNumber *)contactType
{
    if([NSString isNilOrEmpty:contactValue])
    {
        return YES;
    }else
    {
        if([contactType integerValue] == 1)
        {
            //移动电话
            NSArray *teleArr = [contactValue componentsSeparatedByString:@" "];
            if(teleArr.count>1)
            {
                if(![NSString isNilOrEmpty:teleArr[1]])
                {
                    return NO;
                }else
                {
                    return YES;
                }
            }
            return YES;
        }else if([contactType integerValue] == 4)
        {
            //固定电话
            NSArray *tempphoneArr = [contactValue componentsSeparatedByString:@" "];
            if(tempphoneArr.count>1)
            {
                if(![NSString isNilOrEmpty:tempphoneArr[1]])
                {
                    NSArray *phoneArr = [tempphoneArr[1] componentsSeparatedByString:@"-"];
                    NSString *vauleStr = [phoneArr componentsJoinedByString:@""];
                    if(![NSString isNilOrEmpty:vauleStr])
                    {
                        return NO;
                    }
                    return YES;
                }else
                {
                    return YES;
                }
            }
            return YES;
        }
        return NO;
    }
}
-(void)socialAction:(YYTypeButton *)btn
{
    if(_block){
        _block(@"social",btn);
    }
}
-(UIView *)getTextFieldRightView:(NSString *)type
{
    NSString *imageStr = [type isEqualToString:@"email"]?@"email_icon2":[type isEqualToString:@"phone"]?@"mobile_icon":[type isEqualToString:@"qq"]?@"qq_icon1":[type isEqualToString:@"weixin"]?@"weixin_icon1":[type isEqualToString:@"telephone"]?@"phone_icon1":[type isEqualToString:@"sina"]?@"sina_icon":[type isEqualToString:@"facebook"]?@"facebook_icon":[type isEqualToString:@"instagram"]?@"instagram_icon":@"";
    
    UIView *rightView = [UIView getCustomViewWithColor:_define_white_color];
    
    UIImageView *imageview = [[UIImageView alloc] init];
    [rightView addSubview:imageview];
    imageview.contentMode=UIViewContentModeCenter;
    if(![NSString isNilOrEmpty:imageStr])
    {
        imageview.image=[UIImage imageNamed:imageStr];
    }
    [imageview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.centerY.mas_equalTo(rightView);
        make.width.height.mas_equalTo(20);
    }];
    return rightView;
}
#pragma mark - SetData
-(void)SetData
{
    [self SomePrepare];
    [self UIConfig];
    [self CreateNoDataView];
}
#pragma mark - Other
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

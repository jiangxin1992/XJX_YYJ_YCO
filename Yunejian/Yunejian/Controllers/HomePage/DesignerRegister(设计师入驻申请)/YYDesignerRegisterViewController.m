//
//  YYDesignerRegisterViewController.m
//  Yunejian
//
//  Created by chuanjun sun on 2017/8/24.
//  Copyright © 2017年 yyj. All rights reserved.
//

#import "YYDesignerRegisterViewController.h"

// c文件 —> 系统文件（c文件在前）

// 控制器
#import "YYNavigationBarViewController.h"
#import "YYRegisterResultViewController.h"

// 通用的cell
#import "YYEditMyPageCurrencyCell.h"
// 第一个cell特殊，照片上传等
#import "YYEditMyPageOneCell.h"
#import "YYPhoneTableViewCell.h"
#import "YYDesignRegisterSubmitTableViewCell.h"

// 接口
#import "YYUserApi.h"

// 分类
#import "UIImage+Tint.h"

// 自定义类和三方类（cocoapods类、model、工具类等） cocoapods类 —> model —> 其他
#import <MBProgressHUD/MBProgressHUD.h>

#import "YYUserHomePageModel.h"
#import "YYVerifyTool.h"

#import "MLInputDodger.h"

// cell的重用标志
static NSString *currencyCellId = @"YYEditMyPageViewControllerCell";
static NSString *phoneCellId = @"YYEditMyPageViewControllerPhoneCell";
static NSString *submitCellId = @"YYEditMyPageViewControllerSubmitCell";


@interface YYDesignerRegisterViewController ()<UITableViewDelegate, UITableViewDataSource>


/** tableview */
@property (nonatomic, strong) UITableView *tableView;
/** tableView Header */
@property (nonatomic, strong) NSArray *tableViewHeaders;

/** 品牌名称 */
@property (nonatomic, copy) NSString *brandName;
/** 设计师 */
@property (nonatomic, copy) NSString *designer;
/** 合作买手店名称 */
@property (nonatomic, strong) NSMutableDictionary *retailerName;
/** 管网地址 */
@property (nonatomic, copy) NSString *webUrl;
/** 品牌主要联系人 */
@property (nonatomic, copy) NSString *contactName;
/** 手机号 */
@property (nonatomic, copy) NSString *phone;

/** 登录的Email */
@property (nonatomic, copy) NSString *Email;
/** 登录密码 */
@property (nonatomic, copy) NSString *password;
/** 第二次密码 */
@property (nonatomic, copy) NSString *secondPassword;
/** 是否同意协议 */
@property (nonatomic, assign) BOOL agree;


@property(nonatomic, strong)YYRegisterResultViewController * resultView;


@end

@implementation YYDesignerRegisterViewController

#pragma mark - --------------生命周期--------------
- (void)viewDidLoad {
    [super viewDidLoad];
    [self SomePrepare];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.tableView.shiftHeightAsDodgeViewForMLInputDodger = 92.0f;
    [self.tableView registerAsDodgeViewForMLInputDodger];
}
#pragma mark - --------------SomePrepare--------------
- (void)SomePrepare
{
    [self PrepareData];
    [self PrepareUI];
}
- (void)PrepareData{
    self.tableViewHeaders = @[@[NSLocalizedString(@"设计师品牌信息（必须）", nil), NSLocalizedString(@"", @"")],
                              @[NSLocalizedString(@"联系人信息", nil), NSLocalizedString(@"", @"")],
                              ];

    // 初始化，避免越界, 凡是非必填项都要有初始化值
    self.retailerName = [NSMutableDictionary dictionaryWithDictionary:@{@"0":@"", @"1":@"", @"2":@""}];
    self.webUrl = @"";
}

#pragma mark - --------------UI----------------------
// 创建子控件
- (void)PrepareUI{
    self.view.backgroundColor = [UIColor whiteColor];

    // 头部导航栏
    UIView *navView = [[UIView alloc] init];
    [self.view addSubview:navView];
    [navView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(20);
        make.right.mas_equalTo(0);
        make.height.mas_equalTo(50);
    }];

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    YYNavigationBarViewController *navigationBarViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYNavigationBarViewController"];
    navigationBarViewController.previousTitle = NSLocalizedString(@"登录",nil);
    navigationBarViewController.nowTitle = NSLocalizedString(@"设计师入驻申请",nil);
    [self addChildViewController:navigationBarViewController];
    [navView addSubview:navigationBarViewController.view];

    WeakSelf(ws);
    // 退出登录回调
    [navigationBarViewController setNavigationButtonClicked:^(NavigationButtonType buttonType){
        StrongSelf(ws);
        [strongSelf.navigationController popViewControllerAnimated:YES];
    }];

    [navigationBarViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(navView.mas_top);
        make.left.equalTo(navView.mas_left);
        make.right.equalTo(navView.mas_right);
        make.bottom.equalTo(navView.mas_bottom);
    }];

    // logo
    UIImageView *logoImage = [UIImageView getImgWithImageStr:@"logo_main"];
    [self.view addSubview:logoImage];
    [logoImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(70);
        make.height.mas_equalTo(70);
        make.left.mas_equalTo(40);
        make.top.equalTo(navView.mas_bottom).mas_offset(28);
    }];

    // tableview
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.backgroundColor = [UIColor whiteColor];
    tableView.tableFooterView = [[UIView alloc] init];
    self.tableView = tableView;

    [self.view addSubview:tableView];

    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).mas_offset(150);
        make.top.equalTo(navView.mas_bottom);
        make.right.mas_equalTo(self.view.mas_right).mas_offset(-40);
        make.bottom.mas_equalTo(0);
    }];
}

#pragma mark - --------------系统代理----------------------
#pragma mark - tableView dataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 8;
    }else{
        return 4;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 90;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0 && (indexPath.row == 3 || indexPath.row == 4)) {
        return 66;
    }else if (indexPath.section == 1 && indexPath.row == 3){
        return 265;
    }
    return 92;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    WeakSelf(ws);
    if (indexPath.section == 0 && indexPath.row == 7) {// 第二个特殊cell，包含手机号和电话
        YYPhoneTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:phoneCellId];

        if (!cell) {
            cell = [[YYPhoneTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:phoneCellId];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.phone = @"";
            cell.title = [NSString stringWithFormat:@"*%@", NSLocalizedString(@"主要联系人手机", nil)];
            cell.subtitle = NSLocalizedString(@"请填写常用手机号码，品牌审核时该手机号将作为重要联系路径", nil);
            // 隐藏选择权限的按钮
            [cell hiddenPicker];
        }

        // cell回调
        cell.phoneContent = ^(NSString *content) {
            self.phone = content;
        };

        return cell;

    }else if (indexPath.section == 1 && indexPath.row == 3) {// 第三个特殊cell，就是尾部条款和确认按钮
        YYDesignRegisterSubmitTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:submitCellId];
        if (!cell) {
            cell = [[YYDesignRegisterSubmitTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:submitCellId];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }

        cell.submitQuestion = ^(NSInteger agree) {

            [self saveAction:agree];
        };

        return cell;

    }else{
        YYEditMyPageCurrencyCell *cell = [tableView dequeueReusableCellWithIdentifier:currencyCellId];
        if (!cell) {
            cell = [[YYEditMyPageCurrencyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:currencyCellId];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }

        // 默认不检查、不显示picker、不显示placeholder、明文, 副标题为空、隐藏提示
        cell.isShowPicker = NO;
        cell.indexPath = indexPath;
        cell.inputPlaceholder = @"";
        cell.checkType = kYYCheckTypeWithNo;
        cell.isSecureTextEntry = NO;
        cell.subTitle = @"";
        cell.warnContent = @"";

        if (indexPath.section == 0 && indexPath.row == 0) {
            cell.title = [NSString stringWithFormat:@"*%@", NSLocalizedString(@"品牌名称", nil)];
            cell.subTitle = NSLocalizedString(@"名称请与商标注册证上的品牌名称保持一致", nil);
            cell.inputContent = self.brandName;

        }else if (indexPath.section == 0 && indexPath.row == 1) {
            cell.title = [NSString stringWithFormat:@"*%@", NSLocalizedString(@"设计师", nil)];
            cell.inputContent = self.designer;
            
        }else if (indexPath.section == 0 && indexPath.row == 2) {
            cell.title = NSLocalizedString(@"请列举3个合作买手店名称",nil);
            cell.inputPlaceholder = NSLocalizedString(@"合作买手店1", nil);
            cell.inputContent = self.retailerName[@"0"];

        }else if (indexPath.section == 0 && indexPath.row == 3) {
            cell.title = @"";
            cell.inputPlaceholder = NSLocalizedString(@"合作买手店2", nil);
            cell.inputContent = self.retailerName[@"1"];

        }else if (indexPath.section == 0 && indexPath.row == 4) {
            cell.title = @"";
            cell.inputPlaceholder = NSLocalizedString(@"合作买手店3", nil);
            cell.inputContent = self.retailerName[@"2"];

        }else if (indexPath.section == 0 && indexPath.row == 5) {
            cell.title = NSLocalizedString(@"品牌官网", nil);
            cell.inputContent = self.webUrl;

        }else if (indexPath.section == 0 && indexPath.row == 6) {
            cell.title = [NSString stringWithFormat:@"*%@", NSLocalizedString(@"品牌主要联系人", nil)];
            cell.subTitle = NSLocalizedString(@"品牌账号所有人，建议填写品牌设计师本人", nil);
            cell.inputContent = self.contactName;

        }else if (indexPath.section == 1 && indexPath.row == 0) {
            cell.title = [NSString stringWithFormat:@"*%@", NSLocalizedString(@"登录Email", nil)];
            cell.subTitle = NSLocalizedString(@"激活链接、审核结果、订单及合作消息将发至此Email", nil);
            cell.checkType = kYYCheckTypeWithEmail;
            cell.inputContent = self.Email;

        }else if (indexPath.section == 1 && indexPath.row == 1) {
            cell.title = [NSString stringWithFormat:@"*%@", NSLocalizedString(@"登录密码", nil)];
            cell.isSecureTextEntry = YES;
            cell.inputContent = self.password;

        }else if(indexPath.section == 1 && indexPath.row == 2){
            cell.title = [NSString stringWithFormat:@"*%@", NSLocalizedString(@"再输入一次登录密码", nil)];
            cell.isSecureTextEntry = YES;
            cell.inputContent = self.secondPassword;
        }

        cell.transmitTextField = ^(NSString *content, NSIndexPath *indexPath, YYEditMyPageCurrencyCell *cell) {
            StrongSelf(ws);
            if (indexPath.section == 0 && indexPath.row == 0) {
                strongSelf.brandName = content;

            }else if (indexPath.section == 0 && indexPath.row == 1) {
                strongSelf.designer = content;

            }else if (indexPath.section == 0 && indexPath.row == 2) {
                strongSelf.retailerName[@"0"] = content;

            }else if (indexPath.section == 0 && indexPath.row == 3) {
                strongSelf.retailerName[@"1"] = content;

            }else if (indexPath.section == 0 && indexPath.row == 4) {
                strongSelf.retailerName[@"2"] = content;

            }else if (indexPath.section == 0 && indexPath.row == 5) {
                strongSelf.webUrl = content;
            }else if (indexPath.section == 0 && indexPath.row == 6) {
                strongSelf.contactName = content;

            }else if (indexPath.section == 1 && indexPath.row == 0) {
                strongSelf.Email = content;
                if(![NSString isNilOrEmpty:self.Email]){
                    if(![YYVerifyTool emailVerify:self.Email]){
                        cell.warnContent = NSLocalizedString(@"Email格式错误",nil);
                    }else{
                        cell.warnContent = @"";
                    }
                }else{
                    cell.warnContent = @"";
                }

            }else if(indexPath.section == 1 && indexPath.row == 1){
                strongSelf.password = content;

            }else if(indexPath.section == 1 && indexPath.row == 2){
                strongSelf.secondPassword = content;
                if (strongSelf.password && content) {
                    if (![strongSelf.password isEqualToString:content]) {
                        // 显示
                        cell.warnContent = NSLocalizedString(@"两次密码输入不一致",nil);
                    }else{
                        // 隐藏
                        cell.warnContent = @"";
                    }
                }
            }
        };

        return cell;
    }
}

#pragma mark - tableView delegate
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{

    UIView *header = [[UIView alloc] init];
    header.backgroundColor = [UIColor whiteColor];

    // header
    UIView *bgView = [[UIView alloc] init];
    bgView.backgroundColor = [UIColor colorWithHex:@"EFEFEF"];
    [header addSubview:bgView];

    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
        make.top.mas_equalTo(45);
    }];

    // 显示title
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = self.tableViewHeaders[section][0];
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [bgView addSubview:titleLabel];

    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(17);
        make.centerY.mas_equalTo(0);
    }];

    // 显示desc
    UILabel *descLabel = [[UILabel alloc] init];
    descLabel.text = self.tableViewHeaders[section][1];
    descLabel.textColor = [UIColor colorWithHex:kDefaultTitleColor_pad];
    descLabel.font = [UIFont boldSystemFontOfSize:13];
    [bgView addSubview:descLabel];

    [descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(titleLabel.mas_right).mas_offset(15);
        make.centerY.mas_equalTo(0);
    }];

    return header;
}

#pragma mark - --------------自定义代理/block----------------------

#pragma mark - --------------自定义响应----------------------
#pragma mark - 退出界面
- (void)goback:(NavigationButtonType)buttonType{

    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 保存
- (void)saveAction:(NSInteger)agree{

    // 合法性判断
    BOOL isCheck = [self CheckLegal];

    if (!isCheck) {
        return;
    }

//    <__NSArrayM 0x17025bde0>(
//                             brandName=品牌名称,
//                             nickName=设计师,
//                             retailerName=["买手店1","买手店2","买手店3"],
//                             webUrl=品牌官网,
//                             userName=品牌主要联系人,
//                             phone=+86 18367145757,
//                             email=gjffnbdnvk@qq.com,
//                             password=mima
//                             )

    NSMutableArray *retailerName = [NSMutableArray array];
    [retailerName addObject:self.retailerName[@"0"]];
    [retailerName addObject:self.retailerName[@"1"]];
    [retailerName addObject:self.retailerName[@"2"]];

    // 取出两端空格
    NSString *brandName = [self.brandName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *nickName = [self.designer stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *webUrl = [self.webUrl stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *userName = [self.contactName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *phone = [self.phone stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *email = [self.Email stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *password = [self.password stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    NSMutableArray *param = [NSMutableArray array];
    [param addObject:[NSString stringWithFormat:@"brandName=%@", brandName]];
    [param addObject:[NSString stringWithFormat:@"nickName=%@", nickName]];
    [param addObject:[NSString stringWithFormat:@"retailerName=%@", retailerName]];
    [param addObject:[NSString stringWithFormat:@"webUrl=%@", webUrl]];
    [param addObject:[NSString stringWithFormat:@"userName=%@", userName]];
    [param addObject:[NSString stringWithFormat:@"phone=%@", phone]];
    [param addObject:[NSString stringWithFormat:@"email=%@", email]];
    [param addObject:[NSString stringWithFormat:@"password=%@", password]];

    WeakSelf(ws);
    [MBProgressHUD showHUDAddedTo:self.view animated:NO];
    [YYUserApi registerDesignerWithData:param andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSError *error) {
        StrongSelf(ws);
        [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
        if( rspStatusAndMessage.status == YYReqStatusCode100){
            //直接请求登录接口？
            [YYToast showToastWithTitle:NSLocalizedString(@"注册成功！",nil) andDuration:kAlertToastDuration];
            dispatch_async(dispatch_get_main_queue(), ^{
                if(strongSelf.resultView == nil){
                    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
                    strongSelf.resultView= [storyboard instantiateViewControllerWithIdentifier:@"YYRegisterResultViewController"];
                }
                strongSelf.resultView.registerType = YYUserTypeDesigner;
                strongSelf.resultView.status = 0;
                strongSelf.resultView.email = email;
                [strongSelf.navigationController pushViewController:strongSelf.resultView animated:YES];
                return;
            });
        }else{
            [YYToast showToastWithTitle:rspStatusAndMessage.message andDuration:kAlertToastDuration];
        }
    }];

}

#pragma mark - --------------自定义方法----------------------

#pragma mark - 安全检查

/**
 安全检查
 @return yes是符合规则，no是不符合规则
 */
- (BOOL)CheckLegal{

    //  品牌名称
    if ([NSString isNilOrEmpty:self.brandName]) {
        [YYToast showToastWithTitle:[NSString stringWithFormat:NSLocalizedString(@"完善%@信息",nil), NSLocalizedString(@"品牌名称", nil)] andDuration:kAlertToastDuration];
        return NO;
    }

    //  设计师
    if ([NSString isNilOrEmpty:self.designer]) {
        [YYToast showToastWithTitle:[NSString stringWithFormat:NSLocalizedString(@"完善%@信息",nil), NSLocalizedString(@"设计师", nil)] andDuration:kAlertToastDuration];
        return NO;
    }

    //  品牌主要联系人
    if ([NSString isNilOrEmpty:self.contactName]) {
        [YYToast showToastWithTitle:[NSString stringWithFormat:NSLocalizedString(@"完善%@信息",nil), NSLocalizedString(@"品牌主要联系人", nil)] andDuration:kAlertToastDuration];
        return NO;
    }

    //  手机号码
    if ([NSString isNilOrEmpty:self.phone]) {
        [YYToast showToastWithTitle:[NSString stringWithFormat:NSLocalizedString(@"完善%@信息",nil), NSLocalizedString(@"主要联系人手机", nil)] andDuration:kAlertToastDuration];
        return NO;
    }

    //  登录Email
    if ([NSString isNilOrEmpty:self.Email] || ![YYVerifyTool emailVerify:self.Email]) {
        [YYToast showToastWithTitle:[NSString stringWithFormat:NSLocalizedString(@"完善%@信息",nil), NSLocalizedString(@"登录Email", nil)] andDuration:kAlertToastDuration];
        return NO;
    }

    //  品牌名称
    if ([NSString isNilOrEmpty:self.password]) {
        [YYToast showToastWithTitle:[NSString stringWithFormat:NSLocalizedString(@"完善%@信息",nil), NSLocalizedString(@"登录密码", nil)] andDuration:kAlertToastDuration];
        return NO;
    }

    //  品牌名称
    if ([NSString isNilOrEmpty:self.secondPassword]) {
        [YYToast showToastWithTitle:[NSString stringWithFormat:NSLocalizedString(@"完善%@信息",nil), NSLocalizedString(@"再输入一次登录密码", nil)] andDuration:kAlertToastDuration];
        return NO;
    }

    if (![self.password isEqualToString:self.secondPassword]) {
        // 显示
        [YYToast showToastWithTitle:NSLocalizedString(@"两次密码输入不一致",nil) andDuration:kAlertToastDuration];
        return NO;
    }

    //邮箱
    if(![NSString isNilOrEmpty:self.Email]){
        if(![YYVerifyTool emailVerify:self.Email]){
            [YYToast showToastWithTitle:NSLocalizedString(@"Email格式错误",nil) andDuration:kAlertToastDuration];
            return NO;
        }
    }



    // 初始值
    NSArray *arrayPhone = [self.phone componentsSeparatedByString:@" "];
    NSString *phoneCode = [[arrayPhone[0] componentsSeparatedByString:@"+"] lastObject];
    NSString *phone = arrayPhone[1];

    //电话

        
        if([YYVerifyTool numberVerift:phone]){
            if([phoneCode isEqualToString:@"86"]){
                //中国时，号码验证
                if(![YYVerifyTool phoneVerify:phone]){
                    [YYToast showToastWithTitle:[NSString stringWithFormat:NSLocalizedString(@"完善%@信息",nil), NSLocalizedString(@"主要联系人手机", nil)] andDuration:kAlertToastDuration];
                    return NO;
                }
            }else{
                //非中国时，长度验证（6-20位）
                if(!(phone.length <= 20 && phone.length>=6)){
                    [YYToast showToastWithTitle:[NSString stringWithFormat:NSLocalizedString(@"完善%@信息",nil), NSLocalizedString(@"主要联系人手机", nil)] andDuration:kAlertToastDuration];
                    return NO;
                }
            }
        }else{
            [YYToast showToastWithTitle:[NSString stringWithFormat:NSLocalizedString(@"完善%@信息",nil), NSLocalizedString(@"主要联系人手机", nil)] andDuration:kAlertToastDuration];
            return NO;
        }
    
    return YES;
}


#pragma mark - --------------other----------------------

@end

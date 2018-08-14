//
//  YYEditMyPageViewController.m
//  Yunejian
//
//  Created by chuanjun sun on 2017/8/17.
//  Copyright © 2017年 yyj. All rights reserved.
//

#import "YYEditMyPageViewController.h"

// c文件 —> 系统文件（c文件在前）

// 控制器
#import "YYNavigationBarViewController.h"

// 通用的cell
#import "YYEditMyPageCurrencyCell.h"
// 第一个cell特殊，照片上传等 
#import "YYEditMyPageOneCell.h"
#import "YYTelephoneTableViewCell.h"
#import "YYPhoneTableViewCell.h"

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
static NSString *oneCellId = @"YYEditMyPageViewControllerOneCell";
static NSString *phoneCellId = @"YYEditMyPageViewControllerPhoneCell";
static NSString *telephoneCellId = @"YYEditMyPageViewControllertelePhoneCell";
static NSString *blankCellId = @"YYEditMyPageViewControllerblankCell";

@interface YYEditMyPageViewController ()<UITableViewDelegate, UITableViewDataSource>

/** tableview */
@property (nonatomic, strong) UITableView *tableView;
/** tableView Header */
@property (nonatomic, strong) NSArray *tableViewHeaders;

/** logoUrl */
@property (nonatomic, copy) NSString *logoUrl;
/** 品牌简介 */
@property (nonatomic, copy) NSString *brandIntroduction;
/** 品牌海报 */
@property (nonatomic, strong) NSMutableArray *indexPics;
/** 合作买手店名称 */
@property (nonatomic, strong) NSMutableDictionary *retailerName;
/** 管网地址 */
@property (nonatomic, copy) NSString *webUrl;
/** 商务联系方式 */
@property (nonatomic, strong) NSMutableDictionary *userContactInfos;
/** 社交方式 */
@property (nonatomic, strong) NSMutableDictionary *userSocialInfos;

/** 网络请求准备提交的数据 */
@property (nonatomic, strong) NSMutableDictionary *param;


@end

@implementation YYEditMyPageViewController

#pragma mark - --------------生命周期--------------
- (void)viewDidLoad {
    [super viewDidLoad];
    [self SomePrepare];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.tableView.shiftHeightAsDodgeViewForMLInputDodger = 44.0f+5.0f;
    [self.tableView registerAsDodgeViewForMLInputDodger];
}
#pragma mark - --------------SomePrepare--------------
- (void)SomePrepare
{
    [self PrepareData];
    [self PrepareUI];
}
- (void)PrepareData{
    self.tableViewHeaders = @[@[NSLocalizedString(@"品牌信息", nil), NSLocalizedString(@"", @"")],
                              @[NSLocalizedString(@"商务联系方式", nil), NSLocalizedString(@"公开尽量多的联系方式，方便寻求合作的买手店联系到品牌", @"")],
                              @[NSLocalizedString(@"社交账户", nil), NSLocalizedString(@"", @"")]
                              ];
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
    navigationBarViewController.previousTitle = NSLocalizedString(@"返回",nil);
    navigationBarViewController.nowTitle = NSLocalizedString(@"编辑我的主页信息",nil);
    [self addChildViewController:navigationBarViewController];
    [navView addSubview:navigationBarViewController.view];

    WeakSelf(weakSelf);
    // 退出登录回调
    [navigationBarViewController setNavigationButtonClicked:^(NavigationButtonType buttonType){
        StrongSelf(weakSelf);
        [[[UIApplication sharedApplication] keyWindow] endEditing:YES];

        CMAlertView *alertView = [[CMAlertView alloc] initWithTitle:NSLocalizedString(@"确认返回？",nil) message:NSLocalizedString(@"您修改的信息还未保存，返回后将不被保存",nil) needwarn:NO delegate:nil cancelButtonTitle:NSLocalizedString(@"暂不返回_no",nil) otherButtonTitles:@[[NSString stringWithFormat:@"%@|000000",NSLocalizedString(@"返回_yes",nil)]]];
        alertView.specialParentView = self.view;
        [alertView setAlertViewBlock:^(NSInteger selectedIndex){
            if (selectedIndex == 1) {
                [strongSelf.navigationController popViewControllerAnimated:YES];
            }
        }];

        [alertView show];
    }];

    [navigationBarViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(navView.mas_top);
        make.left.equalTo(navView.mas_left);
        make.right.equalTo(navView.mas_right);
        make.bottom.equalTo(navView.mas_bottom);
    }];

    UIButton *saveButton = [UIButton getCustomTitleBtnWithAlignment:0 WithFont:16.0f WithSpacing:0 WithNormalTitle:NSLocalizedString(@"保存",nil) WithNormalColor:nil WithSelectedTitle:nil WithSelectedColor:nil];
    [navView addSubview:saveButton];
    [saveButton addTarget:self action:@selector(saveAction) forControlEvents:UIControlEventTouchUpInside];
    [saveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.right.mas_equalTo(0);
        make.width.mas_equalTo(110);
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
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 5;
    }else if(section == 1){
        return 5;
    }else{
        return 5;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 90;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0 && indexPath.row == 0) {
        return 530;
    }else if (indexPath.section == 0 && (indexPath.row == 2 || indexPath.row == 3)) {
        return 66;
    }
//    else if (indexPath.section == 1 && indexPath.row == 1) {
//        return 184;
//    }
    return 92;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    WeakSelf(ws);
    if (indexPath.section == 0 && indexPath.row == 0) {// 第一个特殊cell，包含上传品牌logo，品牌简介，品牌海报
        YYEditMyPageOneCell *cell = [tableView dequeueReusableCellWithIdentifier:oneCellId];
        if (!cell) {
            cell = [[YYEditMyPageOneCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:oneCellId];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.logoUrl = self.logoUrl;
        cell.brandIntroduction = self.brandIntroduction;
        cell.indexPics = self.indexPics;

        // 回调
        cell.transmitLogo = ^(NSString *logo) {
            StrongSelf(ws);
            strongSelf.logoUrl = logo;
        };

        cell.transmitIntroduce = ^(NSString *introduce) {
            StrongSelf(ws);
            strongSelf.brandIntroduction = introduce;
        };

        cell.transmitPics = ^(NSArray *pics) {
            StrongSelf(ws);
            strongSelf.indexPics = [NSMutableArray arrayWithArray:pics];
        };

        return cell;

    }else if (indexPath.section == 1 && indexPath.row == 1) {// 第二个特殊cell，包含手机号和电话
        YYTelephoneTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:telephoneCellId];

        if (!cell) {
            cell = [[YYTelephoneTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:telephoneCellId];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.telePhonePickerData = @[self.userContactInfos[@"telephone_power"], @[NSLocalizedString(@"公开", nil), NSLocalizedString(@"仅合作买手店可见", nil)]];
            cell.telePhone = self.userContactInfos[@"telephone"];
        }

        // cell回调
        cell.telephoneContent = ^(NSString *content){
            StrongSelf(ws);
            strongSelf.userContactInfos[@"telephone"] = content;

        };

        cell.telephonePowerContent = ^(NSInteger index) {
            StrongSelf(ws);
            strongSelf.userContactInfos[@"telephone_power"] = [NSNumber numberWithInteger:index];

        };
        return cell;

    }else if (indexPath.section == 1 && indexPath.row == 2) {// 第三个特殊cell，包含手机号和电话
        YYPhoneTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:phoneCellId];

        if (!cell) {
            cell = [[YYPhoneTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:phoneCellId];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.phonePickerData = @[self.userContactInfos[@"phone_power"], @[NSLocalizedString(@"公开", nil), NSLocalizedString(@"仅合作买手店可见", nil)]];
            cell.phone = self.userContactInfos[@"phone"];
        }

        // cell回调
        cell.phoneContent = ^(NSString *content) {
            StrongSelf(ws);
            strongSelf.userContactInfos[@"phone"] = content;

        };

        cell.phonePowerContent = ^(NSInteger index) {
            StrongSelf(ws);
            strongSelf.userContactInfos[@"phone_power"] = [NSNumber numberWithInteger:index];
            
        };
        
        return cell;
        
    }else if (indexPath.section == 2 && indexPath.row == 4) {// 第四个特殊cell，就是尾部空白
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:blankCellId];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:blankCellId];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        return cell;

    }else{
        YYEditMyPageCurrencyCell *cell = [tableView dequeueReusableCellWithIdentifier:currencyCellId];
        if (!cell) {
            cell = [[YYEditMyPageCurrencyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:currencyCellId];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }

        // 默认不检查
        cell.checkType = kYYCheckTypeWithNo;
        cell.indexPath = indexPath;
        cell.isShowPicker = NO;
        cell.warnContent = @"";

        if (indexPath.section == 0 && indexPath.row == 1) {
            cell.title = NSLocalizedString(@"请列举3个合作买手店名称",nil);
            cell.inputPlaceholder = NSLocalizedString(@"合作买手店1", nil);
            cell.inputContent = self.retailerName[@"0"];

        }else if (indexPath.section == 0 && indexPath.row == 2) {
            cell.title = @"";
            cell.inputPlaceholder = NSLocalizedString(@"合作买手店2", nil);
            cell.inputContent = self.retailerName[@"1"];

        }else if (indexPath.section == 0 && indexPath.row == 3) {
            cell.title = @"";
            cell.inputPlaceholder = NSLocalizedString(@"合作买手店3", nil);
            cell.inputContent = self.retailerName[@"2"];

        }else if (indexPath.section == 0 && indexPath.row == 4) {
            cell.title = NSLocalizedString(@"品牌官网", nil);
            cell.inputPlaceholder = @"";
            cell.inputContent = self.webUrl;

        }else if (indexPath.section == 1 && indexPath.row == 0) {
            cell.title = @"Email";
            cell.inputPlaceholder = NSLocalizedString(@"商务联系邮箱", nil);
            cell.inputContent = self.userContactInfos[@"email"];
            // 第一个传默认值的序号, 第二个传数据
            cell.pickerData = @[self.userContactInfos[@"email_power"], @[NSLocalizedString(@"公开", nil), NSLocalizedString(@"仅合作买手店可见", nil)]];
            cell.isShowPicker = YES;
            // 邮箱检查合法性
            cell.checkType = kYYCheckTypeWithEmail;

        }else if (indexPath.section == 1 && indexPath.row == 3) {
            cell.title = @"QQ";
            cell.inputPlaceholder = NSLocalizedString(@"商务联系QQ号", nil);
            cell.inputContent = self.userContactInfos[@"qq"];
            // 第一个传默认值的序号, 第二个传数据
            cell.pickerData = @[self.userContactInfos[@"qq_power"], @[NSLocalizedString(@"公开", nil), NSLocalizedString(@"仅合作买手店可见", nil)]];
            cell.isShowPicker = YES;

        }else if (indexPath.section == 1 && indexPath.row == 4) {
            cell.title = NSLocalizedString(@"微信号", nil);
            cell.inputPlaceholder = NSLocalizedString(@"商务合作个人微信号", nil);
            cell.inputContent = self.userContactInfos[@"wechat"];
            // 第一个传默认值的序号, 第二个传数据
            cell.pickerData = @[self.userContactInfos[@"wechat_power"], @[NSLocalizedString(@"公开", nil), NSLocalizedString(@"仅合作买手店可见", nil)]];
            cell.isShowPicker = YES;

        }else if (indexPath.section == 2 && indexPath.row == 0) {
            cell.title = NSLocalizedString(@"新浪微博", nil);
            cell.inputPlaceholder = NSLocalizedString(@"用户名", nil);
            cell.inputContent = self.userSocialInfos[@"weibo"];

        }else if(indexPath.section == 2 && indexPath.row == 1){
            cell.title = NSLocalizedString(@"微信公众号", nil);
            cell.inputPlaceholder = NSLocalizedString(@"公众号", nil);
            cell.inputContent = self.userSocialInfos[@"weMedia"];

        }else if(indexPath.section == 2 && indexPath.row == 2){
            cell.title = @"Facebook";
            cell.inputPlaceholder = NSLocalizedString(@"用户名", nil);
            cell.inputContent = self.userSocialInfos[@"facebook"];

        }else if(indexPath.section == 2 && indexPath.row == 3){
            cell.title = @"Instagram";
            cell.inputPlaceholder = NSLocalizedString(@"用户名", nil);
            cell.inputContent = self.userSocialInfos[@"ins"];

        }

        cell.transmitTextField = ^(NSString *content, NSIndexPath *indexPath, YYEditMyPageCurrencyCell *cell) {
            StrongSelf(ws);
            if (indexPath.section == 0 && indexPath.row == 1) {
                strongSelf.retailerName[@"0"] = content;

            }else if (indexPath.section == 0 && indexPath.row == 2) {
                strongSelf.retailerName[@"1"] = content;

            }else if (indexPath.section == 0 && indexPath.row == 3) {
                strongSelf.retailerName[@"2"] = content;

            }else if (indexPath.section == 0 && indexPath.row == 4) {
                strongSelf.webUrl = content;

            }else if (indexPath.section == 1 && indexPath.row == 0) {
                strongSelf.userContactInfos[@"email"] = content;
                if(![NSString isNilOrEmpty:content]){
                    if(![YYVerifyTool emailVerify:content]){
                        cell.warnContent = NSLocalizedString(@"Email格式错误",nil);
                    }else{
                        cell.warnContent = @"";
                    }
                }else{
                    cell.warnContent = @"";
                }

            }else if (indexPath.section == 1 && indexPath.row == 3) {
                strongSelf.userContactInfos[@"qq"] = content;

            }else if (indexPath.section == 1 && indexPath.row == 4) {
                strongSelf.userContactInfos[@"wechat"] = content;

            }else if (indexPath.section == 2 && indexPath.row == 0) {
                strongSelf.userSocialInfos[@"weibo"] = content;

            }else if(indexPath.section == 2 && indexPath.row == 1){
                strongSelf.userSocialInfos[@"weMedia"] = content;

            }else if(indexPath.section == 2 && indexPath.row == 2){
                strongSelf.userSocialInfos[@"facebook"] = content;

            }else if(indexPath.section == 2 && indexPath.row == 3){
                strongSelf.userSocialInfos[@"ins"] = content;

            }
        };

        cell.transmitPicker = ^(NSInteger index, NSIndexPath *indexPath) {
            StrongSelf(ws);
            if (indexPath.section == 1 && indexPath.row == 0) {
                strongSelf.userContactInfos[@"email_power"] = [NSNumber numberWithInteger:index];

            }else if (indexPath.section == 1 && indexPath.row == 3) {
                strongSelf.userContactInfos[@"qq_power"] = [NSNumber numberWithInteger:index];

            }else if (indexPath.section == 1 && indexPath.row == 4) {
                strongSelf.userContactInfos[@"wechat_power"] = [NSNumber numberWithInteger:index];

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
- (void)saveAction{

    [self.view endEditing:YES];

    // 保存用来验证的数据
    NSString *Email;
    NSString *Telephone;
    NSString *Phone;

    [self.param setObject:self.logoUrl forKey:@"logoPath"];
    [self.param setObject:self.brandIntroduction forKey:@"brandIntroduction"];
    [self.param setObject:self.indexPics forKey:@"pics"];

    NSMutableArray *retailerName = [NSMutableArray array];
    [retailerName addObject:self.retailerName[@"0"]];
    [retailerName addObject:self.retailerName[@"1"]];
    [retailerName addObject:self.retailerName[@"2"]];

    [self.param setObject:retailerName forKey:@"retailerName"];
    [self.param setObject:self.webUrl forKey:@"webUrl"];

    // 更新联系方式
    NSMutableArray *userContactInfos = [NSMutableArray array];

    for (int x = 0; x < 5; x++) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setObject:[NSNumber numberWithInt:x] forKey:@"contactType"];
        if (x == 0) {
            [dict setObject:self.userContactInfos[@"email"] forKey:@"contactValue"];
            Email = self.userContactInfos[@"email"];

            if ([self.userContactInfos[@"email_power"] integerValue] == 0) {// 0代表第一个picker，是公开， 公开传递到后台应该传递2
                [dict setObject:@2 forKey:@"auth"];
            }else if ([self.userContactInfos[@"email_power"] integerValue] == 1){// 1代表第二个picker，是仅合作买手店可见，传递到后台应该传递0
                [dict setObject:@0 forKey:@"auth"];
            }

        }else if (x == 1){
            [dict setObject:self.userContactInfos[@"phone"] forKey:@"contactValue"];
            Phone = self.userContactInfos[@"phone"];
            if ([self.userContactInfos[@"phone_power"] integerValue] == 0) {// 0代表第一个picker，是公开， 公开传递到后台应该传递2
                [dict setObject:@2 forKey:@"auth"];
            }else if ([self.userContactInfos[@"phone_power"] integerValue] == 1){// 1代表第二个picker，是仅合作买手店可见，传递到后台应该传递0
                [dict setObject:@0 forKey:@"auth"];
            }

        }else if (x == 2){
            [dict setObject:self.userContactInfos[@"qq"] forKey:@"contactValue"];

            if ([self.userContactInfos[@"qq_power"] integerValue] == 0) {// 0代表第一个picker，是公开， 公开传递到后台应该传递2
                [dict setObject:@2 forKey:@"auth"];
            }else if ([self.userContactInfos[@"qq_power"] integerValue] == 1){// 1代表第二个picker，是仅合作买手店可见，传递到后台应该传递0
                [dict setObject:@0 forKey:@"auth"];
            }

        }else if (x == 3){
            [dict setObject:self.userContactInfos[@"wechat"] forKey:@"contactValue"];

            if ([self.userContactInfos[@"wechat_power"] integerValue] == 0) {// 0代表第一个picker，是公开， 公开传递到后台应该传递2
                [dict setObject:@2 forKey:@"auth"];
            }else if ([self.userContactInfos[@"wechat_power"] integerValue] == 1){// 1代表第二个picker，是仅合作买手店可见，传递到后台应该传递0
                [dict setObject:@0 forKey:@"auth"];
            }
        }else if (x == 4){
            [dict setObject:self.userContactInfos[@"telephone"] forKey:@"contactValue"];
            Telephone = self.userContactInfos[@"telephone"];
            if ([self.userContactInfos[@"telephone_power"] integerValue] == 0) {// 0代表第一个picker，是公开， 公开传递到后台应该传递2
                [dict setObject:@2 forKey:@"auth"];
            }else if ([self.userContactInfos[@"telephone_power"] integerValue] == 1){// 1代表第二个picker，是仅合作买手店可见，传递到后台应该传递0
                [dict setObject:@0 forKey:@"auth"];
            }
        }

        [userContactInfos addObject:dict];
    }

    if (userContactInfos > 0) {
        [self.param setObject:userContactInfos forKey:@"userContactInfos"];
    }

    // 更新社交账号方式

    NSMutableArray *userSocialInfos = [NSMutableArray array];
    for (int x = 0; x < 4; x++) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setObject:[NSNumber numberWithInt:x] forKey:@"socialType"];

        if (x == 0) {
            [dict setObject:self.userSocialInfos[@"weibo"] forKey:@"socialName"];
            [dict setObject:self.userSocialInfos[@"weibo_url"] forKey:@"url"];
            [dict setObject:self.userSocialInfos[@"weibo_image"] forKey:@"image"];

        }else if (x == 1){
            [dict setObject:self.userSocialInfos[@"weMedia"] forKey:@"socialName"];
            [dict setObject:self.userSocialInfos[@"weMedia_url"] forKey:@"url"];
            [dict setObject:self.userSocialInfos[@"weMedia_image"] forKey:@"image"];

        }else if (x == 2){
            [dict setObject:self.userSocialInfos[@"facebook"] forKey:@"socialName"];
            [dict setObject:self.userSocialInfos[@"facebook_url"] forKey:@"url"];
            [dict setObject:self.userSocialInfos[@"facebook_image"] forKey:@"image"];

        }else if (x == 3){
            [dict setObject:self.userSocialInfos[@"ins"] forKey:@"socialName"];
            [dict setObject:self.userSocialInfos[@"ins_url"] forKey:@"url"];
            [dict setObject:self.userSocialInfos[@"ins_image"] forKey:@"image"];
        }

        [userSocialInfos addObject:dict];
    }

    if (userSocialInfos.count > 0) {
        [self.param setObject:userSocialInfos forKey:@"userSocialInfos"];
    }


    BOOL isCheck = [self CheckLegalEmail:Email telePhone:Telephone Phone:Phone];

    if (!isCheck) {

        return;
    }

    [MBProgressHUD showHUDAddedTo:self.view animated:NO];
    [YYUserApi updateBrandWithData:self.param andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSError *error) {
        if( rspStatusAndMessage.status == YYReqStatusCode100){
            [MBProgressHUD hideAllHUDsForView:self.view animated:NO];

            if([self.param objectForKey:@"userContactInfos"]){
                if(_blockSaveSuccess){
                    _blockSaveSuccess([[self.param objectForKey:@"userContactInfos"] copy]);
                }
            }
            [self showDelayAlert:NSLocalizedString(@"成功修改品牌信息！",nil) msg: @""];
        }else{
            [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
            [YYToast showToastWithTitle:rspStatusAndMessage.message andDuration:kAlertToastDuration];
            //                    _isExeNext = false;
        }
    }];

}

#pragma mark - --------------自定义方法----------------------
#pragma mark - get/set
- (void)setHomePageMode:(YYUserHomePageModel *)homePageMode{
    _homePageMode = homePageMode;

//    (@"品牌logo地址 - %@", homePageMode.logoPath);
//    (@"品牌简介 - %@", homePageMode.brandIntroduction);
//    (@"品牌海报 array %@", homePageMode.indexPics);
//    (@"合作买手店名称 array %@", homePageMode.retailerName);
//    (@"品牌官网 %@", homePageMode.webUrl);
//    (@"商务联系方式 %@", homePageMode.userContactInfos);
//    (@"社交账号 %@", homePageMode.userSocialInfos);
//                          |
//                          |
//                          ↓
    NSDictionary *homePage = [homePageMode toDictionary];

    // 初始化待传递的参数
    self.param = [NSMutableDictionary dictionaryWithDictionary:homePage];
    [self.param removeObjectForKey:@"brandId"];
    [self.param removeObjectForKey:@"percent"];
    [self.param setObject:homePage[@"indexPics"] forKey:@"pics"];
    [self.param removeObjectForKey:@"indexPics"];

    // 初始化
    self.logoUrl = [NSString isNilOrEmpty:homePageMode.logoPath]? @"": homePageMode.logoPath;
    self.brandIntroduction = [NSString isNilOrEmpty: homePageMode.brandIntroduction]? @"": homePageMode.brandIntroduction;
    self.webUrl = [NSString isNilOrEmpty: homePageMode.webUrl]? @"": homePageMode.webUrl;

    self.indexPics = [NSMutableArray arrayWithArray:homePageMode.indexPics];
    // 取出合作买手店名称, 默认为空
    self.retailerName = [NSMutableDictionary dictionaryWithDictionary:@{@"0":@"",
                                                                        @"1":@"",
                                                                        @"2":@""}];
    for (int x = 0; x < homePageMode.retailerName.count; x++) {
        [self.retailerName setObject:homePageMode.retailerName[x] forKey:[NSString stringWithFormat:@"%i", x]];
    }

    // 取出联系方式, 默认值设置，防止为空。 email、手机号、qq、微信、固定电话, power代表选择的权限的 cell.row
    self.userContactInfos = [NSMutableDictionary dictionaryWithDictionary:@{@"email": @"",
                                                                            @"email_power": @0,

                                                                            @"phone": @"",
                                                                            @"phone_power": @1,

                                                                            @"qq": @"",
                                                                            @"qq_power": @1,

                                                                            @"wechat": @"",
                                                                            @"wechat_power": @1,

                                                                            @"telephone": @"",
                                                                            @"telephone_power": @0,
                                                                            }];
    for (NSDictionary *dict in homePageMode.userContactInfos) {
        switch ([dict[@"contactType"] integerValue]) {
            case 0:
                [self.userContactInfos setObject:dict[@"contactValue"] forKey:@"email"];
                
                // @"0", @"1"代表picker的第几个（row）
                if ([dict[@"auth"] integerValue] == 0) {
                    [self.userContactInfos setObject:@1 forKey:@"email_power"];
                }else{
                    [self.userContactInfos setObject:@0 forKey:@"email_power"];
                }

                break;
            case 1:
                [self.userContactInfos setObject:dict[@"contactValue"] forKey:@"phone"];

                if ([dict[@"auth"] integerValue] == 0) {
                    [self.userContactInfos setObject:@1 forKey:@"phone_power"];
                }else{
                    [self.userContactInfos setObject:@0 forKey:@"phone_power"];
                }

                break;
            case 2:
                [self.userContactInfos setObject:dict[@"contactValue"] forKey:@"qq"];

                if ([dict[@"auth"] integerValue] == 0) {
                    [self.userContactInfos setObject:@1 forKey:@"qq_power"];
                }else{
                    [self.userContactInfos setObject:@0 forKey:@"qq_power"];
                }

                break;
            case 3:
                [self.userContactInfos setObject:dict[@"contactValue"] forKey:@"wechat"];

                if ([dict[@"auth"] integerValue] == 0) {
                    [self.userContactInfos setObject:@1 forKey:@"wechat_power"];
                }else{
                    [self.userContactInfos setObject:@0 forKey:@"wechat_power"];
                }

                break;
            case 4:
                [self.userContactInfos setObject:dict[@"contactValue"] forKey:@"telephone"];

                if ([dict[@"auth"] integerValue] == 0) {
                    [self.userContactInfos setObject:@1 forKey:@"telephone_power"];
                }else{
                    [self.userContactInfos setObject:@0 forKey:@"telephone_power"];
                }

                break;

            default:
                break;
        }
    }

    // 取出社交账号， 设置默认值，防止为空, 微博、微信、脸书、ins
    self.userSocialInfos = [NSMutableDictionary dictionaryWithDictionary:@{@"weibo": @"",
                                                                           @"weibo_url": @"",
                                                                           @"weibo_image": @"",

                                                                           @"weMedia": @"",
                                                                           @"weMedia_url": @"",
                                                                           @"weMedia_image": @"",

                                                                           @"facebook": @"",
                                                                           @"facebook_url": @"",
                                                                           @"facebook_image": @"",

                                                                           @"ins": @"",
                                                                           @"ins_url": @"",
                                                                           @"ins_image": @""
                                                                           }];

    for (NSDictionary *dict in homePageMode.userSocialInfos) {
        switch ([dict[@"socialType"] integerValue]) {
            case 0:
                [self.userSocialInfos setObject:dict[@"socialName"] forKey:@"weibo"];
                [self.userSocialInfos setObject:dict[@"url"] forKey:@"weibo_url"];
                [self.userSocialInfos setObject:dict[@"image"] forKey:@"weibo_image"];

                break;
            case 1:
                [self.userSocialInfos setObject:dict[@"socialName"] forKey:@"weMedia"];
                [self.userSocialInfos setObject:dict[@"url"] forKey:@"weMedia_url"];
                [self.userSocialInfos setObject:dict[@"image"] forKey:@"weMedia_image"];

                break;
            case 2:
                [self.userSocialInfos setObject:dict[@"socialName"] forKey:@"facebook"];
                [self.userSocialInfos setObject:dict[@"url"] forKey:@"facebook_url"];
                [self.userSocialInfos setObject:dict[@"image"] forKey:@"facebook_image"];

                break;
            case 3:
                [self.userSocialInfos setObject:dict[@"socialName"] forKey:@"ins"];
                [self.userSocialInfos setObject:dict[@"url"] forKey:@"ins_url"];
                [self.userSocialInfos setObject:dict[@"image"] forKey:@"ins_image"];

                break;

            default:
                break;
        }
    }
}


#pragma mark - 安全检查

/**
 安全检查

 @param email email
 @param phoneCode phoneCode
 @param telephoneCode telephoneCode
 @param block 区号
 @param telephone 固定电话
 @param extension 分机号
 @param phone 手机号
 @return yes是符合规则，no是不符合规则
 */
- (BOOL)CheckLegalEmail:(NSString *)email telePhone:(NSString *)telePhone Phone:(NSString *)Phone{
    //邮箱
    if(![NSString isNilOrEmpty:email]){
        if(![YYVerifyTool emailVerify:email]){
            [YYToast showToastWithTitle:NSLocalizedString(@"完善商务联系方式信息",nil) andDuration:kAlertToastDuration];
            return NO;
        }
    }


    if(![NSString isNilOrEmpty:telePhone]){
        // 初始值
        NSArray *arrayTelephone = [telePhone componentsSeparatedByString:@" "];
        NSString *telephoneCode = [[arrayTelephone[0] componentsSeparatedByString:@"+"] lastObject];

        NSArray *text = @[];
        if (arrayTelephone.count > 1) {
           text = [arrayTelephone[1] componentsSeparatedByString:@"-"];
        }

        NSString *block = @"";
        NSString *telephone = @"";
        NSString *extension = @"";

        for (int x = 0; x < text.count; x++) {
            if (x == 0) {
                block = text[0];
            }else if (x == 1){
                telephone = text[1];
            }else if (x == 2){
                extension = text[2];
            }
        }

        //固定电话
        __block BOOL _uncorrectFormat=NO;

        NSArray *textfieldViewArr = @[block, telephone, extension];



        [textfieldViewArr enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if(![NSString isNilOrEmpty:obj]){
                if([YYVerifyTool numberVerift:obj]){
                    if([telephoneCode isEqualToString:@"86"]){
                        //中国
                        if(idx == 0){
                            if([YYVerifyTool telephoneAreaCode:obj]){
                                _uncorrectFormat = NO;
                            }else{
                                _uncorrectFormat = YES;
                                *stop = YES;
                            }
                        }else if(idx == 1){
                            if(obj.length <=10 && obj.length >= 5){
                                _uncorrectFormat = NO;
                            }else{
                                _uncorrectFormat = YES;
                                *stop = YES;
                            }
                        }
                    }else{
                        if(idx == 0){
                            if(obj.length <= 6&&obj.length >= 3){
                                _uncorrectFormat = NO;
                            }else{
                                _uncorrectFormat = YES;
                                *stop = YES;
                            }
                        }else if(idx == 1){
                            if(obj.length<=10&&obj.length>=5){
                                _uncorrectFormat = NO;
                            }else{
                                _uncorrectFormat = YES;
                                *stop = YES;
                            }
                        }
                    }
                }else{
                    _uncorrectFormat = YES;
                    *stop = YES;
                }
            }
        }];
        
        if(_uncorrectFormat){
            [YYToast showToastWithTitle:NSLocalizedString(@"完善商务联系方式信息",nil) andDuration:kAlertToastDuration];
            return NO;
        }
    }

    //电话
    if(![NSString isNilOrEmpty:Phone]){
        // 初始值
        NSArray *arrayPhone = [Phone componentsSeparatedByString:@" "];
        NSString *phoneCode = [[arrayPhone[0] componentsSeparatedByString:@"+"] lastObject];
        NSString *phone = arrayPhone[1];

        if([YYVerifyTool numberVerift:phone]){
            if([phoneCode isEqualToString:@"86"]){
                //中国时，号码验证
                if(![YYVerifyTool phoneVerify:phone]){
                    [YYToast showToastWithTitle:NSLocalizedString(@"完善商务联系方式信息",nil) andDuration:kAlertToastDuration];
                    return NO;
                }
            }else{
                //非中国时，长度验证（6-20位）
                if(!(phone.length <= 20 && phone.length>=6)){
                    [YYToast showToastWithTitle:NSLocalizedString(@"完善商务联系方式信息",nil) andDuration:kAlertToastDuration];
                    return NO;
                }
            }
        }else{
            [YYToast showToastWithTitle:NSLocalizedString(@"完善商务联系方式信息",nil) andDuration:kAlertToastDuration];
            return NO;
        }
    }

    return YES;
}


#pragma mark - --------------other----------------------
#pragma mark - 提示框
-(void)showDelayAlert:(NSString*)title msg:(NSString*)msg{
    WeakSelf(weakSelf);
    [YYToast showToastWithTitle:title andDuration:kAlertToastDuration];
    // 延迟调用
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf.navigationController popViewControllerAnimated:YES];
    });
}



@end

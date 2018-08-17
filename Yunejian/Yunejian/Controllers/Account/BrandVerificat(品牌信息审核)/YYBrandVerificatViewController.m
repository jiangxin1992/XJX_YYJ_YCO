//
//  YYBrandVerificatViewController.m
//  Yunejian
//
//  Created by chuanjun sun on 2017/8/14.
//  Copyright © 2017年 yyj. All rights reserved.
//

// 当前类
#import "YYBrandVerificatViewController.h"

// c文件 —> 系统文件（c文件在前）

// 控制器
#import "YYNavigationBarViewController.h"

// 自定义视图
#import "YYPopoverBackgroundView.h"
#import "YYPhotoSelectView.h"

// 接口
#import "YYOrderApi.h"
#import "YYUserApi.h"

// 分类
#import "UIImage+Tint.h"

// 自定义类和三方类（cocoapods类、model、工具类等） cocoapods类 —> model —> 其他
#import <MBProgressHUD/MBProgressHUD.h>

#import "YYUser.h"

#import "YYYellowPanelManage.h"


@interface YYBrandVerificatViewController ()<YYPhotoImageDelegate>

/** 选择商标注册类型按钮 */
@property (nonatomic, strong) UIButton *showTrademarkForm;
/** 选择商标注册类型按钮弹出列表 */
@property(nonatomic,strong) UIPopoverController *showTrademarkFormPopController;
/** 第一个上传文件的说明 */
@property (nonatomic, strong) UILabel *help1TitleLabel;
/** 第二个上传文件的说明 */
@property (nonatomic, strong) UILabel *help2TitleLabel;
/** 第二个上传文件的详细说明 */
@property (nonatomic, strong) UILabel *help2DetailLabel;

/** 第二个帮助按钮 */
@property (nonatomic, strong) UIButton *help2Button;
/** 帮助的弹出 */
@property (nonatomic, strong) UIPopoverController *helpPopController;

/** 上传文件1按钮 */
@property (nonatomic, strong) UIButton *upFile1Button;
/** 上传文件2按钮 */
@property (nonatomic, strong) UIButton *upFile2Button;

/** 注册形式 */
@property (nonatomic, copy) NSString *trademark;
/** 上传文件地址1 */
@property (nonatomic, copy) NSString *fileUrl1;
/** 上传文件地址2 */
@property (nonatomic, copy) NSString *fileUrl2;

/** 记录上传的是哪个按钮 */
@property (nonatomic, assign) NSInteger filePhotoButtonTag;
@end

@implementation YYBrandVerificatViewController

#pragma mark - --------------生命周期--------------
- (void)viewDidLoad {
    [super viewDidLoad];
    [self SomePrepare];
}

#pragma mark - --------------SomePrepare--------------
- (void)SomePrepare
{
    [self PrepareData];
    [self PrepareUI];
}
- (void)PrepareData{
    
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
    navigationBarViewController.nowTitle = NSLocalizedString(@"品牌信息审核",nil);
    [self addChildViewController:navigationBarViewController];
    [navView addSubview:navigationBarViewController.view];
    WeakSelf(weakSelf);
    // 退出登录回调
    [navigationBarViewController setNavigationButtonClicked:^(NavigationButtonType buttonType){
        [weakSelf goback:buttonType];
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

    // scrollview
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    [self.view addSubview:scrollView];
    [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).mas_offset(150);
        make.top.equalTo(navView.mas_bottom);
        make.right.mas_equalTo(self.view.mas_right).mas_offset(-40);
        make.bottom.mas_equalTo(0);
    }];

    // 标题
    UIView *topTipsView = [UIView getCustomViewWithColor:[UIColor colorWithHex:@"EFEFEF"]];
    [scrollView addSubview:topTipsView];
    [topTipsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view.mas_left).mas_offset(150);
        make.right.mas_equalTo(self.view.mas_right).mas_offset(-95);
        make.height.mas_equalTo(45);
        make.top.mas_equalTo(30);
    }];

    // 验证品牌信息
    UILabel *topTipsLabel = [UILabel getLabelWithAlignment:NSTextAlignmentLeft WithTitle:NSLocalizedString(@"验证品牌信息",nil) WithFont:16 WithTextColor:[UIColor colorWithHex:@"000000"] WithSpacing:0];
    topTipsLabel.font = [UIFont boldSystemFontOfSize:16];

    [topTipsView addSubview:topTipsLabel];
    [topTipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(17);
        make.centerY.mas_equalTo(0);
    }];

    // 说明文字
    UILabel *showTipsLabel = [[UILabel alloc] init];
    showTipsLabel.text = NSLocalizedString(@"为确保您品牌在YCO System的唯一性，我们需要对品牌商标进行验证。我们将在2-3个工作日完成验证。", nil);
    showTipsLabel.font = [UIFont systemFontOfSize:14];
    showTipsLabel.textColor = [UIColor colorWithHex:@"000000" alpha:0.6];

    [scrollView addSubview:showTipsLabel];
    [showTipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(topTipsView.mas_bottom).mas_offset(15);
    }];

    // 弹出框文字说明1
    UILabel *showFrame1Label = [[UILabel alloc] init];
    showFrame1Label.text = NSLocalizedString(@"Step 1.选择品牌商标的注册形式", nil);
    showFrame1Label.font = [UIFont systemFontOfSize:16];
    showFrame1Label.textColor = [UIColor colorWithHex:@"000000"];

    [scrollView addSubview:showFrame1Label];
    [showFrame1Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.top.mas_equalTo(showTipsLabel.mas_bottom).mas_offset(15);
    }];

    // 选择商标注册类型按钮
    UIButton *showTrademarkForm = [[UIButton alloc] init];
    showTrademarkForm.backgroundColor = [UIColor colorWithHex:@"EFEFEF"];
    [showTrademarkForm setTitle:NSLocalizedString(@"选择商标注册类型", nil) forState:UIControlStateNormal];
    [showTrademarkForm setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    showTrademarkForm.titleLabel.font = [UIFont systemFontOfSize:14];
    showTrademarkForm.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    showTrademarkForm.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    [showTrademarkForm addTarget:self action:@selector(showTrademarkFormClick:) forControlEvents:UIControlEventTouchUpInside];
    self.showTrademarkForm = showTrademarkForm;

    // 修改图片和文字的顺序
//    [showTrademarkForm setTitleEdgeInsets:UIEdgeInsetsMake(0, -155, 0, 0)];
//    [showTrademarkForm setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, -380)];// = 125 + 255 = 125 + (280 - 270 + 15)

    [scrollView addSubview:showTrademarkForm];
    [showTrademarkForm mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(showFrame1Label.mas_bottom).mas_offset(15);
        make.left.mas_equalTo(15);
        make.width.mas_equalTo(280);
        make.height.mas_equalTo(45);
    }];

    //  右箭头
    UIImageView *rightImage = [UIImageView getImgWithImageStr:@"right"];
    [showTrademarkForm addSubview:rightImage];

    [rightImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(260);
        make.centerY.mas_equalTo(0);
        make.width.mas_equalTo(8);
        make.height.mas_equalTo(13);
    }];

    // 文字头说明
    UILabel *showFrame2Label = [[UILabel alloc] init];
    showFrame2Label.text = NSLocalizedString(@"Step 2.上传文件", nil);
    showFrame2Label.font = [UIFont systemFontOfSize:16];
    showFrame2Label.textColor = [UIColor colorWithHex:@"000000"];

    [scrollView addSubview:showFrame2Label];
    [showFrame2Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.top.mas_equalTo(showTrademarkForm.mas_bottom).mas_offset(15);
    }];

    // 上传按钮1
    UIButton *upFile1Button = [[UIButton alloc] init];
    upFile1Button.backgroundColor = [UIColor colorWithHex:@"EFEFEF"];
    [upFile1Button setImage:[UIImage imageNamed:@"photo"] forState:UIControlStateNormal];
    [upFile1Button addTarget:self action:@selector(upFileButton:) forControlEvents:UIControlEventTouchUpInside];
    upFile1Button.tag = 1;
    self.upFile1Button = upFile1Button;
    [scrollView addSubview:upFile1Button];

    [upFile1Button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.top.mas_equalTo(showFrame2Label.mas_bottom).mas_offset(15);
        make.width.mas_equalTo(247);
        make.height.mas_equalTo(185);
    }];

    // 1上传文件的说明
    UILabel *help1TitleLabel = [[UILabel alloc] init];
    help1TitleLabel.font = [UIFont systemFontOfSize:13];
    help1TitleLabel.textColor = [UIColor colorWithHex:@"000000" alpha:0.6];
    self.help1TitleLabel = help1TitleLabel;
    [upFile1Button addSubview:help1TitleLabel];

    [help1TitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(40);
        make.top.mas_equalTo(upFile1Button.mas_centerY).offset(7.5);
        make.centerX.mas_equalTo(upFile1Button.mas_centerX);
    }];

    // 提示按钮1
    UIButton *help1Button = [[UIButton alloc] init];
    [help1Button setImage:[UIImage imageNamed:@"help"] forState:UIControlStateNormal];
    help1Button.titleLabel.font = [UIFont systemFontOfSize:14];
    help1Button.imageEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
    [help1Button addTarget:self action:@selector(help1:) forControlEvents:UIControlEventTouchUpInside];

    [scrollView addSubview:help1Button];
    // 添加下划线
    NSAttributedString *underline = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"帮助",nil) attributes:@{NSUnderlineStyleAttributeName:@(NSUnderlineStyleSingle)}];
    [help1Button setAttributedTitle:underline forState:UIControlStateNormal];

    [help1Button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(upFile1Button.mas_right);
        make.bottom.mas_equalTo(upFile1Button.mas_bottom);
        make.width.mas_equalTo(64);
        make.height.mas_equalTo(22);
    }];

    // 上传按钮2
    UIButton *upFile2Button = [[UIButton alloc] init];
    upFile2Button.backgroundColor = [UIColor colorWithHex:@"EFEFEF"];
    [upFile2Button setImage:[UIImage imageNamed:@"photo"] forState:UIControlStateNormal];
    [upFile1Button addTarget:self action:@selector(upFileButton:) forControlEvents:UIControlEventTouchUpInside];
    upFile2Button.tag = 2;
    self.upFile2Button = upFile2Button;
    [scrollView addSubview:upFile2Button];

    [upFile2Button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.top.mas_equalTo(upFile1Button.mas_bottom).mas_offset(15);
        make.width.mas_equalTo(247);
        make.height.mas_equalTo(185);
    }];

    // 2 上传文件的说明
    UILabel *help2TitleLabel = [[UILabel alloc] init];
    help2TitleLabel.font = [UIFont systemFontOfSize:13];
    help2TitleLabel.textColor = [UIColor colorWithHex:@"000000" alpha:0.6];
    self.help2TitleLabel = help2TitleLabel;
    [upFile2Button addSubview:help2TitleLabel];

    [help2TitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(40);
        make.top.mas_equalTo(upFile2Button.mas_centerY).offset(7.5);
        make.centerX.mas_equalTo(upFile2Button.mas_centerX);
    }];

    // 2 上传文件的详细说明
    UILabel *help2DetailLabel = [[UILabel alloc] init];
    help2DetailLabel.font = [UIFont systemFontOfSize:11];
    help2DetailLabel.textColor = [UIColor colorWithHex:@"000000" alpha:0.6];
    self.help2DetailLabel = help2DetailLabel;
    self.help2DetailLabel.numberOfLines = 0;
    self.help2DetailLabel.textAlignment = NSTextAlignmentCenter;
    [upFile2Button addTarget:self action:@selector(upFileButton:) forControlEvents:UIControlEventTouchUpInside];
    [upFile2Button addSubview:help2DetailLabel];

    [help2DetailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(40);
        make.top.mas_equalTo(help2TitleLabel.mas_bottom);
        make.centerX.mas_equalTo(upFile2Button.mas_centerX);
        make.width.mas_equalTo(upFile2Button.mas_width);
    }];

    // 提示按钮2
    UIButton *help2Button = [[UIButton alloc] init];
    [help2Button setImage:[UIImage imageNamed:@"help"] forState:UIControlStateNormal];
    help2Button.titleLabel.font = [UIFont systemFontOfSize:14];
    help2Button.imageEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
    self.help2Button = help2Button;
    [help2Button addTarget:self action:@selector(help2:) forControlEvents:UIControlEventTouchUpInside];

    [scrollView addSubview:help2Button];
    // 添加下划线
    [help2Button setAttributedTitle:underline forState:UIControlStateNormal];

    [help2Button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(upFile2Button.mas_right);
        make.bottom.mas_equalTo(upFile2Button.mas_bottom);
        make.width.mas_equalTo(64);
        make.height.mas_equalTo(22);
    }];

    // 提交
    UIButton *submitButton = [[UIButton alloc] init];
    submitButton.backgroundColor = [UIColor blackColor];
    submitButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [submitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [submitButton setTitle:NSLocalizedString(@"提交",nil) forState:UIControlStateNormal];
    [submitButton addTarget:self action:@selector(submitButton:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:submitButton];

    [submitButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.top.mas_equalTo(upFile2Button.mas_bottom).offset(25);
        make.width.mas_equalTo(130);
        make.height.mas_equalTo(45);
    }];

    [self.view layoutIfNeeded];

    // 所有UI加载完成后，设置scrollview的滚动范围。
    scrollView.contentSize = CGSizeMake(0, CGRectGetMaxY(submitButton.frame) + 155);

}

#pragma mark - --------------系统代理----------------------


#pragma mark - --------------自定义代理/block----------------------
#pragma mark - 照片回调
- (void)YYPhotoInfo:(NSDictionary *)info{

    UIImage *image = nil;

    if (info[@"UIImagePickerControllerEditedImage"]) {
        image = [UIImage fixOrientation:info[UIImagePickerControllerEditedImage]];
    }else{
        image = [UIImage fixOrientation:info[UIImagePickerControllerOriginalImage]];
    }

    if (image) {
        if (![YYNetworkReachability connectedToNetwork]) {
            [YYToast showToastWithTitle:kNetworkIsOfflineTips andDuration:kAlertToastDuration];//判断网络状态
        }else{
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [YYOrderApi uploadImage:image size:3.0f andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSString *imageUrl, NSError *error) {
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                if (imageUrl && [imageUrl length] > 0) {
                    
                    if (self.filePhotoButtonTag == 1) {
                        self.fileUrl1 = imageUrl;
                        // 修改显示
                        self.help1TitleLabel.hidden = YES;
                        [self.upFile1Button setImage:image forState:UIControlStateNormal];
                        self.upFile1Button.imageView.contentMode = UIViewContentModeScaleAspectFit;
                    }else if (self.filePhotoButtonTag == 2){
                        self.fileUrl2 = imageUrl;
                        // 修改显示
                        self.help2TitleLabel.hidden = YES;
                        self.help2DetailLabel.hidden = YES;
                        [self.upFile2Button setImage:image forState:UIControlStateNormal];
                        self.upFile2Button.imageView.contentMode = UIViewContentModeScaleAspectFit;
                    }
                }
            }];
        }
    }
}

#pragma mark - --------------自定义响应----------------------
#pragma mark - 退出界面
- (void)goback:(NavigationButtonType)buttonType{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 弹出商标注册类型 start
// 弹出商标注册类型
- (void)showTrademarkFormClick:(UIButton *)button{
    NSInteger menuUIWidth = 250;
    NSInteger menuUIHeight = 126+63;
    UIViewController *controller = [[UIViewController alloc] init];
    controller.view.frame = CGRectMake(0, 0, menuUIWidth, menuUIHeight);
    // 装饰
    setMenuUI_pad(self, controller.view, @[@[@"",NSLocalizedString(@"个人注册商标",nil)],@[@"",NSLocalizedString(@"公司注册商标",nil)],@[@"",NSLocalizedString(@"授权商标",nil)]]);
    UIPopoverController *popController = [[UIPopoverController alloc] initWithContentViewController:controller];
    self.showTrademarkFormPopController = popController;

    CGPoint point = [button convertPoint:button.center toView:self.view];
    CGRect frame = CGRectMake(point.x + menuUIWidth, point.y - CGRectGetMaxY(button.frame), 0, 0);
    popController.popoverContentSize = CGSizeMake(menuUIWidth, menuUIHeight);
    popController.popoverBackgroundViewClass = [YYPopoverBackgroundView class];
    [popController presentPopoverFromRect:frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

// 类型点击响应
-(void)menuBtnHandler:(UIButton *)sender{
    NSInteger type = sender.tag;
    // 1, 2, 3代表选择的第几个按钮
    [self.showTrademarkFormPopController dismissPopoverAnimated:NO];
    if(type == 1){
        [self.showTrademarkForm setTitle:NSLocalizedString(@"个人注册商标",nil) forState:UIControlStateNormal];
        self.showTrademarkForm.tag = 1;
        self.help1TitleLabel.text = NSLocalizedString(@"上传个人商标注册证",nil);
        self.help2TitleLabel.text = NSLocalizedString(@"上传注册人身份证（正面）",nil);
        self.help2DetailLabel.text = NSLocalizedString(@"身份证为商标注册证上的注册人",nil);
    }else if(type == 2){
        [self.showTrademarkForm setTitle:NSLocalizedString(@"公司注册商标",nil) forState:UIControlStateNormal];
        self.showTrademarkForm.tag = 2;
        self.help1TitleLabel.text = NSLocalizedString(@"上传公司商标注册证",nil);
        self.help2TitleLabel.text = NSLocalizedString(@"上传注册公司营业执照",nil);
        self.help2DetailLabel.text = NSLocalizedString(@"公司须与商标注册证上的公司保持一致",nil);
    }else if(type == 3){
        [self.showTrademarkForm setTitle:NSLocalizedString(@"授权商标",nil) forState:UIControlStateNormal];
        self.showTrademarkForm.tag = 3;
        self.help1TitleLabel.text = NSLocalizedString(@"上传商标授权书",nil);
        self.help2TitleLabel.text = NSLocalizedString(@"上传被授权公司营业执照",nil);
        self.help2DetailLabel.text = NSLocalizedString(@"公司须与商标授权书上的被授权公司保持一致",nil);
    }
}

#pragma mark - 帮助
- (void)help1:(UIButton *)button{
    [self showHelpUI:1 helpButton:self.help2Button];
}

- (void)help2:(UIButton *)button{
    [self showHelpUI:2 helpButton:self.help2Button];
}

// 帮助
-(void)showHelpUI:(NSInteger)photoType helpButton:(UIButton*)button{

    if(self.showTrademarkForm.tag == 0){
        [YYToast showToastWithTitle:NSLocalizedString(@"选择商标注册类型",nil) andDuration:kAlertToastDuration];
        return;
    }
    NSInteger photoUIWidth = 124;
    NSInteger photoUIHeight = 172;

    if(photoType == 2){
        photoUIWidth = 256;
    }

    photoUIWidth   = photoUIWidth * 2.1;
    photoUIHeight = photoUIHeight * 2.1;

    UIViewController *controller = [[UIViewController alloc] init];
    controller.view.frame = CGRectMake(0, 0, photoUIWidth, photoUIHeight);

    NSString *imageName = [NSString stringWithFormat:@"%@brand-help/brandhelpImg%ld_%ld",kYYServerResURL,(long)self.showTrademarkForm.tag, (long)photoType];//
    NSString *imageUrlName = nil;
    if( [UIScreen mainScreen].scale > 1){
        imageUrlName = [NSString stringWithFormat:@"%@@2x.jpg",imageName];
    }else{
        imageUrlName = [NSString stringWithFormat:@"%@.jpg",imageName];
    }
    NSURL *url = [NSURL URLWithString:imageUrlName];
    UIImage *imgFromUrl = [[UIImage alloc]initWithData:[NSData dataWithContentsOfURL:url]];
    controller.view.layer.contentsScale = [UIScreen mainScreen].scale;
    controller.view.layer.contents = (__bridge id _Nullable)(imgFromUrl.CGImage);

    UIPopoverController *popController = [[UIPopoverController alloc] initWithContentViewController:controller];

    CGPoint point = [button convertPoint:button.center toView:self.view];
    CGRect frame = CGRectMake(CGRectGetMaxX(button.frame) + 150, point.y - button.frame.origin.y - photoUIHeight/2, 0, 0);
    popController.popoverContentSize = CGSizeMake(photoUIWidth, photoUIHeight);
    popController.popoverBackgroundViewClass = [YYPopoverBackgroundView class];
    [popController presentPopoverFromRect:frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];

}

#pragma mark - 拍照按钮
- (void)upFileButton:(UIButton *)button{

    if(self.showTrademarkForm.tag == 0){
        [YYToast showToastWithTitle:NSLocalizedString(@"选择商标注册类型",nil) andDuration:kAlertToastDuration];
        return;
    }

    CMAlertView *alertView = [[CMAlertView alloc] initWithTitle:NSLocalizedString(@"请选择",nil) message:nil needwarn:NO delegate:nil cancelButtonTitle:NSLocalizedString(@"相册",nil) otherButtonTitles:@[[NSString stringWithFormat:@"%@|000000",NSLocalizedString(@"拍照",nil)]]];
    alertView.specialParentView = self.view;
    WeakSelf(weakSelf);

    self.filePhotoButtonTag = button.tag;
    [alertView setAlertViewBlock:^(NSInteger selectedIndex){
        StrongSelf(weakSelf);
        YYPhotoSelectView *photoSelect = [YYPhotoSelectView sharePhotoSelect];
        photoSelect.YYPhotoImageDelegate = strongSelf;
        if (selectedIndex == 0) {
            // 相册
            [photoSelect showPhotoWithController:strongSelf PhotoType:kYYPhotoTypeAlbum view:button arrow:UIPopoverArrowDirectionLeft];
        }else if (selectedIndex == 1){
            // 相机
            [photoSelect showPhotoWithController:strongSelf PhotoType:kYYPhotoTypeCamera view:button arrow:UIPopoverArrowDirectionLeft];
        }
    }];

    [alertView show];
}

#pragma mark - 提交
- (void)submitButton:(UIButton *)buton{

    if (self.showTrademarkForm.tag == 0 || !self.fileUrl1 || !self.fileUrl2) {
        [YYToast showToastWithTitle:NSLocalizedString(@"完善信息",nil) andDuration:kAlertToastDuration];
        return;
    }

    NSString *body;
    switch (self.showTrademarkForm.tag) {
        case 1: // 个人注册商标
        {
            body = [NSString stringWithFormat:@"personalBrandCert:%@,personalIdCard:%@", self.fileUrl1, self.fileUrl2];
        }
            break;
        case 2: // 公司注册商标
        {
            body = [NSString stringWithFormat:@"companyBrandCert:%@,companyBusinessLicense:%@", self.fileUrl1, self.fileUrl2];
        }
            break;
        case 3: // 授权商标
        {
            body = [NSString stringWithFormat:@"brandAuthCert:%@,authedCompanyBusinessLicense:%@", self.fileUrl1, self.fileUrl2];
        }
            break;

        default:
            break;
    }
    [YYUserApi uploadBrandFiles:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSInteger errorCode, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:NO];

        if( rspStatusAndMessage.status == YYReqStatusCode100 && errorCode == YYReqStatusCode100){

            [self showYellowAlert:NSLocalizedString(@"成功提交品牌验证信息",nil) msg:NSLocalizedString(@"感谢您提交了品牌验证信息，我们将在2-3个工作日完成验证",nil)];
        }else{
            [YYToast showToastWithTitle:rspStatusAndMessage.message andDuration:kAlertToastDuration];
        }
    }];
}

#pragma mark - --------------自定义方法----------------------
#pragma mark - 提交后的提示框
-(void)showYellowAlert:(NSString*)title msg:(NSString*)msg{
    [[YYYellowPanelManage instance] showYellowUserCheckAlertPanel:@"Main" andIdentifier:@"YYUserCheckAlertViewController" title:title msg:msg iconStr:@"identity_pass_icon"  btnStr:NSLocalizedString(@"开启 YCO SYSTEM",nil) align:NSTextAlignmentLeft closeBtn:YES funArray:@[NSLocalizedString(@"1. 请在您的登录邮箱中查看验证结果邮件",nil),NSLocalizedString(@"2. 发邮件至info@ycosystem.com咨询或添加yunejianhelper微信号咨询",nil)] andCallBack:^(NSArray *value) {
        if (self.cancelButtonClicked) {
            self.cancelButtonClicked();
        }
        [self.navigationController popViewControllerAnimated:YES];
    }];

    YYUser *user = [YYUser currentUser];
    user.status = [NSString stringWithFormat:@"%d",YYReqStatusCode300];
    [user saveUserData];
}

#pragma mark - --------------other----------------------
@end

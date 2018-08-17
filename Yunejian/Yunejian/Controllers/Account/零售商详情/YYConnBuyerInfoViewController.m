//
//  YYConnBuyerInfoViewController.m
//  Yunejian
//
//  Created by Apple on 15/12/11.
//  Copyright © 2015年 yyj. All rights reserved.
//

#import "YYConnBuyerInfoViewController.h"

#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreLocation/CoreLocation.h>

#import "YYNavigationBarViewController.h"
#import "YYConnBuyerInfoAboutViewController.h"
#import "YYConnBuyerInfoContactViewController.h"

#import "YYTopAlertView.h"
#import "SCLoopScrollView.h"
#import "MBProgressHUD.h"
#import "YYTypeButton.h"
#import "SCGIFImageView.h"

#import "YYUserApi.h"
#import "YYConnApi.h"

@interface YYConnBuyerInfoViewController ()
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet SCGIFImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *cityLabel;
@property (weak, nonatomic) IBOutlet SCLoopScrollView *loopView;

@property (nonatomic,strong) UIImageView *mengban;
@property (nonatomic,strong) SCGIFImageView *zbar;//二维码

@property (weak, nonatomic) IBOutlet UIView *infoBackView;

@property (nonatomic,strong) UIView *blackLine;

@property (nonatomic,strong) UIPageViewController *infoPageVc;
@property (nonatomic,strong) YYConnBuyerInfoAboutViewController *ctnAbout;
@property (nonatomic,strong) YYConnBuyerInfoContactViewController *ctnContact;
@property (nonatomic,strong) UIView *lineLeft;
@property (nonatomic,strong) UIView *lineRight;
@property (nonatomic,assign) NSInteger currentPage;

//@property (weak, nonatomic) IBOutlet UILabel *webLabel;
//@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
//@property (weak, nonatomic) IBOutlet UILabel *connLabel;
//@property (weak, nonatomic) IBOutlet UILabel *introLabel;
//@property (weak, nonatomic) IBOutlet UILabel *weixinLabel;
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *introLayoutHeightConstraint;
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *connLayoutHeightConstraint;
@property (weak, nonatomic) IBOutlet UIButton *oprateBtn;

//@property (strong,nonatomic) SCLoopScrollView *imageScrollView;
@property (nonatomic,strong) YYBuyerDetailModel *buyerModel;
@property (nonatomic,strong) UIPageControl *pageControl;


@end

@implementation YYConnBuyerInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self SomePrepare];
    [self UIConfig];
    [self loadInfoData];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    // 进入埋点
    [MobClick beginLogPageView:kYYPageConnBuyerInfo];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    // 退出埋点
    [MobClick endLogPageView:kYYPageConnBuyerInfo];
}

#pragma mark - SomePrepare
-(void)SomePrepare
{
    [self PrepareData];
    [self PrepareUI];
}
-(void)PrepareData{}
-(void)PrepareUI
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    YYNavigationBarViewController *navigationBarViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYNavigationBarViewController"];
    navigationBarViewController.previousTitle = _previousTitle;
    
    NSString *title = @"";
    navigationBarViewController.nowTitle = title;
    
    [_containerView addSubview:navigationBarViewController.view];
    __weak UIView *_weakContainerView = _containerView;
    [navigationBarViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_weakContainerView.mas_top);
        make.left.equalTo(_weakContainerView.mas_left);
        make.bottom.equalTo(_weakContainerView.mas_bottom);
        make.right.equalTo(_weakContainerView.mas_right);
        
    }];
    
    WeakSelf(ws);
    
    __block YYNavigationBarViewController *blockVc = navigationBarViewController;
    
    [navigationBarViewController setNavigationButtonClicked:^(NavigationButtonType buttonType){
        if (buttonType == NavigationButtonTypeGoBack) {
            if(ws.cancelButtonClicked){
                ws.cancelButtonClicked();
            }else{
                [ws.navigationController popViewControllerAnimated:YES];
            }
            blockVc = nil;
        }
    }];
    
    self.pageControl = [[UIPageControl alloc] init];
    __weak SCLoopScrollView *weakScrollView = _loopView;
    __weak UIView *weakView = self.view;
    
    _pageControl.hidesForSinglePage = YES;
    _pageControl.pageIndicatorTintColor = [UIColor grayColor];
    _pageControl.currentPageIndicatorTintColor = [UIColor blackColor];
    
    [weakView addSubview:_pageControl];
    [_pageControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(weakScrollView.mas_bottom).with.offset(-15);
        make.size.mas_equalTo(CGSizeMake(300, 20));
        make.centerX.equalTo(weakScrollView.mas_centerX);
    }];
    _pageControl.hidden = YES;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}
#pragma mark - UIConfig
-(void)UIConfig
{
    [self CreateUserInfoPageBar];
    [self CreateUserInfoPageView];
}
-(void)CreateUserInfoPageBar
{
    NSArray *titleArr=@[NSLocalizedString(@"关于买手店",nil),NSLocalizedString(@"联系买手店",nil)];
    __block UIView *lastView=nil;
    [titleArr enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIButton *SwitchBtn=[UIButton getCustomTitleBtnWithAlignment:0 WithFont:14.0f WithSpacing:0 WithNormalTitle:obj WithNormalColor:_define_black_color WithSelectedTitle:obj WithSelectedColor:_define_black_color];
        
        [_infoBackView addSubview:SwitchBtn];
        SwitchBtn.tag=100+idx;
        [SwitchBtn addTarget:self action:@selector(SwitchAction:) forControlEvents:UIControlEventTouchUpInside];
        [SwitchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            if(lastView)
            {
                make.left.mas_equalTo(lastView.mas_right).with.offset(0);
                make.width.mas_equalTo(lastView);
                make.right.mas_equalTo(-35);
            }else
            {
                make.left.mas_equalTo(_loopView.mas_right).with.offset(34);
            }
            make.top.mas_equalTo(_logoImageView.mas_bottom).with.offset(25);
            
            make.height.mas_equalTo(40);
        }];
        if(!idx)
        {
            SwitchBtn.selected=YES;
            if(!_lineLeft)
            {
                _lineLeft=[UIView getCustomViewWithColor:_define_black_color];
                [SwitchBtn addSubview:_lineLeft];
                [_lineLeft mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.bottom.mas_equalTo(0);
                    make.centerX.mas_equalTo(SwitchBtn);
                    make.height.mas_equalTo(3);
                    make.width.mas_equalTo(100);
                }];
            }
            _lineLeft.hidden=NO;
        }else
        {
            SwitchBtn.selected=NO;
            if(!_lineRight)
            {
                _lineRight=[UIView getCustomViewWithColor:_define_black_color];
                [SwitchBtn addSubview:_lineRight];
                [_lineRight mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.bottom.mas_equalTo(0);
                    make.centerX.mas_equalTo(SwitchBtn);
                    make.height.mas_equalTo(3);
                    make.width.mas_equalTo(100);
                }];
            }
            _lineRight.hidden=YES;
        }
        lastView=SwitchBtn;
    }];
    if(lastView)
    {
        _blackLine=[UIView getCustomViewWithColor:[UIColor colorWithRed:239.0f/255.0f green:239.0f/255.0f blue:239.0f/255.0f alpha:1]];
        [_infoBackView addSubview:_blackLine];
        [_blackLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(_loopView.mas_right).with.offset(34);
            make.right.mas_equalTo(-35);
            make.top.mas_equalTo(lastView.mas_bottom).with.offset(0);
            make.height.mas_equalTo(1);
        }];
    }
}
-(void)CreateUserInfoPageView
{
    _infoPageVc = [[UIPageViewController alloc]initWithTransitionStyle:1 navigationOrientation:0 options:nil];
    [_infoBackView addSubview:_infoPageVc.view];
    //    _infoPageVc.automaticallyAdjustsScrollViewInsets = NO;
    [_infoPageVc.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_loopView.mas_right).with.offset(34);
        make.right.bottom.mas_equalTo(0);
        make.top.mas_equalTo(_blackLine.mas_bottom).with.offset(0);
    }];
    if(_ctnAbout==nil)
    {
        _ctnAbout=[[YYConnBuyerInfoAboutViewController alloc] initWithBuyerDetailModel:_buyerModel WithBlock:^(NSString *type,UIView *obj) {
            if([type isEqualToString:@"openPancrase"])
            {
                clickWebUrl_pad(_buyerModel.webUrl, obj);
            }
        }];
    }
    [_infoPageVc setViewControllers:@[_ctnAbout] direction:1 animated:YES completion:nil];
    _currentPage=0;
}
-(void)SwitchAction:(UIButton *)btn
{
    NSInteger selectIdx=btn.tag-100;
    NSArray *SwitchBtnArr = @[[_infoBackView viewWithTag:100],[_infoBackView viewWithTag:101]];
    
    if(selectIdx==0)
    {
        if(_currentPage>0)
        {
            if(!_ctnAbout)
            {
                _ctnAbout=[[YYConnBuyerInfoAboutViewController alloc] initWithBuyerDetailModel:_buyerModel WithBlock:^(NSString *type,UIView *obj) {
                    if([type isEqualToString:@"openPancrase"])
                    {
                        clickWebUrl_pad(_buyerModel.webUrl, obj);
                    }
                }];
            }
            [_infoPageVc setViewControllers:@[_ctnAbout] direction:1 animated:YES completion:nil];
        }
    }else if(selectIdx==1)
    {
        if(!_ctnContact)
        {
            WeakSelf(ws);
            _ctnContact =[[YYConnBuyerInfoContactViewController alloc] initWithBuyerDetailModel:_buyerModel WithBlock:^(NSString *type,YYTypeButton *typeButton) {
                if([type isEqualToString:@"social"])
                {
                    [ws socialAction:typeButton];
                }
            }];
        }
        if(_currentPage<1)
        {
            [_infoPageVc setViewControllers:@[_ctnContact] direction:0 animated:YES completion:nil];
        }
    }
    
    [SwitchBtnArr enumerateObjectsUsingBlock:^(UIButton *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if(selectIdx==idx)
        {
            obj.selected=YES;
            _currentPage=selectIdx;
            if(!idx)
            {
                if(!_lineLeft)
                {
                    _lineLeft=[UIView getCustomViewWithColor:_define_black_color];
                    [obj addSubview:_lineLeft];
                    [_lineLeft mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.bottom.mas_equalTo(0);
                        make.centerX.mas_equalTo(obj);
                        make.height.mas_equalTo(3);
                        make.width.mas_equalTo(100);
                    }];
                }
                _lineLeft.hidden=NO;
            }else
            {
                if(!_lineRight)
                {
                    _lineRight=[UIView getCustomViewWithColor:_define_black_color];
                    [obj addSubview:_lineRight];
                    [_lineRight mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.bottom.mas_equalTo(0);
                        make.centerX.mas_equalTo(obj);
                        make.height.mas_equalTo(3);
                        make.width.mas_equalTo(100);
                    }];
                }
                _lineRight.hidden=NO;
            }
        }else
        {
            obj.selected=NO;
            if(!idx)
            {
                if(!_lineLeft)
                {
                    _lineLeft=[UIView getCustomViewWithColor:_define_black_color];
                    [obj addSubview:_lineLeft];
                    [_lineLeft mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.bottom.mas_equalTo(0);
                        make.centerX.mas_equalTo(obj);
                        make.height.mas_equalTo(3);
                        make.width.mas_equalTo(100);
                    }];
                }
                _lineLeft.hidden=YES;
            }else
            {
                if(!_lineRight)
                {
                    _lineRight=[UIView getCustomViewWithColor:_define_black_color];
                    [obj addSubview:_lineRight];
                    [_lineRight mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.bottom.mas_equalTo(0);
                        make.centerX.mas_equalTo(obj);
                        make.height.mas_equalTo(3);
                        make.width.mas_equalTo(100);
                    }];
                }
                _lineRight.hidden=YES;
            }
        }
    }];
}
#pragma mark - loadInfoData

- (void)loadInfoData{
    WeakSelf(ws);
    [YYUserApi getBuyerDetailInfoWithID:_buyerId andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYBuyerDetailModel *buyerModel, NSError *error) {
        if(rspStatusAndMessage.status == kCode100){
            ws.buyerModel = buyerModel;
            dispatch_async(dispatch_get_main_queue(), ^{
                [ws updateUI];
            });
        }
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }];
}

#pragma mark - SomeAction
-(void)copyWeixinName:(YYTypeButton *)btn
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    
    NSDictionary *value=btn.value;
    
    pasteboard.string = [value objectForKey:@"socialName"];
    
    [YYToast showToastWithTitle:NSLocalizedString(@"成功复制微信号",nil) andDuration:kAlertToastDuration];
    [_mengban removeFromSuperview];
}
-(void)saveWeixinPic:(YYTypeButton *)btn
{
    if(_zbar.image)
    {
        ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
        
        if (author == kCLAuthorizationStatusRestricted || author ==kCLAuthorizationStatusDenied){
            [self presentViewController:alertTitleCancel_Simple(NSLocalizedString(@"请在设备的“设置-隐私-照片”中允许访问照片",nil), ^{
                if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]])
                {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                }
            }) animated:YES completion:nil];
        }else
        {
            UIImageWriteToSavedPhotosAlbum(_zbar.image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
            [_mengban removeFromSuperview];
        }
    }
}
// 指定回调方法

- (void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo
{
    if(error != NULL){
        
        [YYToast showToastWithTitle:NSLocalizedString(@"保存图片失败",nil) andDuration:kAlertToastDuration];
    }else{
        
        [YYToast showToastWithTitle:NSLocalizedString(@"保存图片成功",nil) andDuration:kAlertToastDuration];
    }
}

-(void)closeAction
{
    [_mengban removeFromSuperview];
}
-(void)NULLACTION{}
-(void)socialAction:(YYTypeButton *)btn
{
    if([btn.type isEqualToString:@"weixin"])
    {
        //显示二维码
        _mengban=[UIImageView getImgWithImageStr:@"System_Transparent_Mask"];
        _mengban.contentMode=UIViewContentModeScaleToFill;
        [self.view.window addSubview:_mengban];
        _mengban.frame=CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        [_mengban addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeAction)]];
        
        UIView *bottomView=[UIView getCustomViewWithColor:[UIColor colorWithRed:255.0f/255.0f green:241.0f/255.0f blue:0 alpha:1]];
        [_mengban addSubview:bottomView];
        bottomView.userInteractionEnabled = YES;
        [bottomView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(NULLACTION)]];
        [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(_mengban);
            make.width.mas_equalTo(450);
            make.height.mas_equalTo(350);
        }];
        
        UIView *backView=[UIView getCustomViewWithColor:_define_white_color];
        [bottomView addSubview:backView];
        [backView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(bottomView);
            make.width.mas_equalTo(432);
            make.height.mas_equalTo(332);
        }];
        
        UIButton *closeBtn=[UIButton getCustomImgBtnWithImageStr:@"top_close_icon" WithSelectedImageStr:nil];
        [backView addSubview:closeBtn];
        [closeBtn addTarget:self action:@selector(closeAction) forControlEvents:UIControlEventTouchUpInside];
        [closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(10);
            make.right.mas_equalTo(-10);
            make.width.height.mas_equalTo(20);
        }];
        
        _zbar=[[SCGIFImageView alloc] init];
        [backView addSubview:_zbar];
        _zbar.contentMode = UIViewContentModeScaleAspectFit;
        [_zbar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(55);
            make.centerX.mas_equalTo(backView);
            make.height.width.mas_equalTo(140);
        }];
        NSString *imageUrl = [btn.value objectForKey:@"image"];
        if(![NSString isNilOrEmpty:imageUrl])
        {
            sd_downloadWebImageWithRelativePath(NO, imageUrl, _zbar, kLookBookCover, 0);
            //            sd_downloadWebImageWithRelativePath(NO, @"https://scdn.ycosystem.com/ufile/20161228/632dd9fdcd944df78c3a9d9b16b2b4b3", _zbar, kLookBookCover, 0);
        }
        
        UILabel *namelabel=[UILabel getLabelWithAlignment:1 WithTitle:[[NSString alloc] initWithFormat:NSLocalizedString(@"微信号：%@",nil),[btn.value objectForKey:@"socialName"]] WithFont:14.0f WithTextColor:[UIColor colorWithHex:kDefaultTitleColor_pad] WithSpacing:0];
        [backView addSubview:namelabel];
        [namelabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(_zbar.mas_bottom).with.offset(4);
            make.centerX.mas_equalTo(backView);
        }];
        
        __block UIView *lastView=nil;
        NSArray *titleArr=@[NSLocalizedString(@"复制微信号",nil),NSLocalizedString(@"保存二维码",nil)];
        [titleArr enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            YYTypeButton *actionbtn=[YYTypeButton getCustomTitleBtnWithAlignment:0 WithFont:13.0f WithSpacing:0 WithNormalTitle:obj WithNormalColor:idx==0?_define_black_color:_define_white_color WithSelectedTitle:nil WithSelectedColor:nil];
            [backView addSubview:actionbtn];
            actionbtn.value=btn.value;
            actionbtn.type=btn.type;
            actionbtn.backgroundColor=idx==0?_define_white_color:_define_black_color;
            setBorder(actionbtn);
            if(!idx){
                //复制微信号
                [actionbtn addTarget:self action:@selector(copyWeixinName:) forControlEvents:UIControlEventTouchUpInside];
            }else
            {
                //保存二维码
                [actionbtn addTarget:self action:@selector(saveWeixinPic:) forControlEvents:UIControlEventTouchUpInside];
            }
            [actionbtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(-35);
                make.width.mas_equalTo(143);
                make.height.mas_equalTo(39);
                if(!idx)
                {
                    make.left.mas_equalTo(backView.mas_centerX).with.offset(20);
                }else
                {
                    make.right.mas_equalTo(backView.mas_centerX).with.offset(-20);
                }
            }];
            
            lastView=actionbtn;
        }];
    }else
    {
        //跳转网页
        clickWebUrl_pad([btn.value objectForKey:@"url"], btn);
    }
}
-(void)updateUI{
    if(_ctnAbout)
    {
        _ctnAbout.buyerDetailModel=_buyerModel;
        [_ctnAbout SetData];
    }
    if(_ctnContact)
    {
        _ctnContact.buyerDetailModel=_buyerModel;
        [_ctnContact SetData];
    }
    
    if(_buyerModel && ![NSString isNilOrEmpty:_buyerModel.logoPath]){
        sd_downloadWebImageWithRelativePath(NO, _buyerModel.logoPath, _logoImageView, kLogoCover, 0);
    }else{
       // sd_downloadWebImageWithRelativePath(NO, @"", _logoImageView, kLogoCover, 0);
        [_logoImageView setImage:[UIImage imageNamed:@"default_icon"]];

    }
    _nameLabel.text = _buyerModel.name;
    NSString *_nation = [LanguageManager isEnglishLanguage]?_buyerModel.nationEn:_buyerModel.nation;
    NSString *_province = [LanguageManager isEnglishLanguage]?_buyerModel.provinceEn:_buyerModel.province;
    NSString *_city = [LanguageManager isEnglishLanguage]?_buyerModel.cityEn:_buyerModel.city;
    NSString *tempstr = [[NSString alloc] initWithFormat:NSLocalizedString(@"%@ %@%@",nil),_nation,_province,_city];
    _cityLabel.text = [NSString stringWithFormat:@"%@ %@",tempstr,_buyerModel.addressDetail];
    
    NSInteger imageCount = [_buyerModel.storeImgs count];
    NSMutableArray *tmpIamgeArr = [[NSMutableArray alloc] initWithCapacity:imageCount];
    if(imageCount > 0){
        for(int i = 0 ; i < imageCount; i++){
            NSString *imageName =[NSString stringWithFormat:@"%@",[_buyerModel.storeImgs objectAtIndex:i]];
            if([imageName isEqualToString:@""]){
                break;
            }
            NSString *_imageRelativePath = imageName;
            NSString *imgInfo = [NSString stringWithFormat:@"%@%@|%@",_imageRelativePath,kLookBookImage,@""];
            [tmpIamgeArr addObject:imgInfo];
        }
        _pageControl.numberOfPages = imageCount;
        _pageControl.currentPage = 0;
        _pageControl.hidden = NO;
        
    }
    
    _loopView.images = tmpIamgeArr;
    [_loopView show:^(NSInteger index) {
    } finished:^(NSInteger index) {
        _pageControl.currentPage = index;
    }];
    
    if([_buyerModel.connectStatus integerValue] == kConnStatus){
        _oprateBtn.backgroundColor =[UIColor blackColor];
        _oprateBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        [_oprateBtn setImage:[UIImage imageNamed:@"conn_invite_icon"] forState:UIControlStateNormal];
        [_oprateBtn setTitle:NSLocalizedString(@"建立合作",nil) forState:UIControlStateNormal];
        [_oprateBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }else if([_buyerModel.connectStatus integerValue] == kConnStatus0){
        _oprateBtn.backgroundColor =[UIColor clearColor];
        _oprateBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [_oprateBtn setImage:[UIImage imageNamed:@"conn_refuse_icon"] forState:UIControlStateNormal];
        [_oprateBtn setTitle:NSLocalizedString(@"取消邀请",nil) forState:UIControlStateNormal];
        [_oprateBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }else if([_buyerModel.connectStatus integerValue] == kConnStatus1){
        _oprateBtn.backgroundColor =[UIColor clearColor];
        _oprateBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [_oprateBtn setImage:[UIImage imageNamed:@"conn_cancel_icon"] forState:UIControlStateNormal];
        [_oprateBtn setTitle:NSLocalizedString(@"解除合作",nil) forState:UIControlStateNormal];
        [_oprateBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }else if([_buyerModel.connectStatus integerValue] == kConnStatus2){
        _oprateBtn.backgroundColor =[UIColor clearColor];
        _oprateBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [_oprateBtn setImage:[UIImage imageNamed:@"conn_refuse_icon"] forState:UIControlStateNormal];
        [_oprateBtn setTitle:NSLocalizedString(@"拒绝邀请",nil) forState:UIControlStateNormal];
        [_oprateBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    
}
/**
 * 解除合作
 */
- (IBAction)oprateBtnHandler:(id)sender {
    WeakSelf(ws);
    if(_buyerModel == nil){
        return;
    }
    if([_buyerModel.connectStatus integerValue] == kConnStatus1){
        CMAlertView *alertView = [[CMAlertView alloc] initWithTitle:NSLocalizedString(@"解除合作吗？",nil) message:NSLocalizedString(@"解除合作后，买手店将不能浏览本品牌作品。确认解除合作吗？",nil) needwarn:NO delegate:nil cancelButtonTitle:NSLocalizedString(@"继续合作_no",nil) otherButtonTitles:@[NSLocalizedString(@"解除合作_yes",nil)]];
        alertView.specialParentView = self.view;
        [alertView setAlertViewBlock:^(NSInteger selectedIndex){
            if (selectedIndex == 1) {
                [ws oprateConnWithBuyer:[_buyerModel.buyerId integerValue] status:3];
            }
        }];
        
        [alertView show];
    }else if([_buyerModel.connectStatus integerValue] == kConnStatus0){
        CMAlertView *alertView = [[CMAlertView alloc] initWithTitle:NSLocalizedString(@"取消邀请吗？",nil) message:nil needwarn:NO delegate:nil cancelButtonTitle:NSLocalizedString(@"继续邀请_no",nil) otherButtonTitles:@[NSLocalizedString(@"取消邀请_yes",nil)]];
        alertView.specialParentView = self.view;
        [alertView setAlertViewBlock:^(NSInteger selectedIndex){
            if (selectedIndex == 1) {
                [ws oprateConnWithBuyer:[_buyerModel.buyerId integerValue] status:4];
            }
        }];
        
        [alertView show];
    }else if([_buyerModel.connectStatus integerValue] == kConnStatus2){
        CMAlertView *alertView = [[CMAlertView alloc] initWithTitle:NSLocalizedString(@"确定拒绝邀请吗？",nil) message:nil needwarn:NO delegate:nil cancelButtonTitle:NSLocalizedString(@"继续邀请",nil) otherButtonTitles:@[NSLocalizedString(@"拒绝邀请",nil)]];
        alertView.specialParentView = self.view;
        [alertView setAlertViewBlock:^(NSInteger selectedIndex){
            if (selectedIndex == 1) {
                [ws oprateConnWithBuyer:[_buyerModel.buyerId integerValue] status:2];
            }
        }];
        
        [alertView show];
    }else if([_buyerModel.connectStatus integerValue] == kConnStatus){//
        CMAlertView *alertView = [[CMAlertView alloc] initWithTitle:NSLocalizedString(@"确定邀请吗？",nil) message:nil needwarn:NO delegate:nil cancelButtonTitle:NSLocalizedString(@"取消邀请",nil) otherButtonTitles:@[[NSString stringWithFormat:@"%@|000000",NSLocalizedString(@"继续邀请",nil)]]];
        alertView.specialParentView = self.view;
        __block YYBuyerDetailModel *blockBuyerModel = _buyerModel;

        [alertView setAlertViewBlock:^(NSInteger selectedIndex){
            if (selectedIndex == 1) {
                [YYConnApi invite:[blockBuyerModel.buyerId integerValue] andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSError *error) {
                    if(rspStatusAndMessage.status == kCode100){
                        blockBuyerModel.connectStatus = 0;
                        [YYTopAlertView showWithType:YYTopAlertTypeSuccess text:NSLocalizedString(@"邀请买手店成功", nil) parentView:nil];
                        //[ws updateUI];
                        if(ws.modifySuccess1){
                            ws.modifySuccess1();
                        }
                        if(ws.cancelButtonClicked){
                            ws.cancelButtonClicked();
                        }else{
                            [ws.navigationController popViewControllerAnimated:YES];
                        }

                    }
                }];
            }
        }];
        
        [alertView show];
    }
}

// 1->同意邀请	2->拒绝邀请	3->移除合作 4取消邀请
- (void)oprateConnWithBuyer:(NSInteger)buyerId status:(NSInteger)status{
    WeakSelf(ws);
    [YYConnApi OprateConnWithBuyer:buyerId status:status andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSError *error) {
        if(rspStatusAndMessage.status == kCode100){
            [YYTopAlertView showWithType:YYTopAlertTypeSuccess text:NSLocalizedString(@"操作成功！", nil) parentView:nil];
            if(ws.modifySuccess2){
                ws.modifySuccess2();
            }
            if(ws.cancelButtonClicked){
                ws.cancelButtonClicked();
            }else{
            [ws.navigationController popViewControllerAnimated:YES];
            }
        }
    }];
}

#pragma mark - Other

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
@end

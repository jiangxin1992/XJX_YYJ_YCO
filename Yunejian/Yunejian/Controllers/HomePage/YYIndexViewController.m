//
//  YYIndexViewController.m
//  Yunejian
//
//  Created by yyj on 15/7/8.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import "YYIndexViewController.h"

#import "YYEditMyPageViewController.h"

#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreLocation/CoreLocation.h>

#import "YYCustomCellTableViewController.h"
#import "YYIndexInfoAboutViewController.h"
#import "YYIndexInfoContactViewController.h"
#import "YYConnMsgListController.h"

#import <MJRefresh.h>

#import "YYShowroomApi.h"
#import "YYPopoverBackgroundView.h"
#import "SCLoopScrollView.h"
#import "YYNoDataView.h"
#import "YYStyleDetailCell.h"
#import "YYTypeButton.h"
#import "SCGIFImageView.h"

#import "YYUserApi.h"
#import "MBProgressHUD.h"
#import "YYShowroomInfoByDesignerModel.h"
#import "YYUser.h"
#import "YYUserHomePageModel.h"
#import "UIImage+YYImage.h"
#import "AppDelegate.h"

NSString *const MJTableViewCellIdentifier = @"Cell";

@interface YYIndexViewController ()

@property (weak, nonatomic) IBOutlet SCGIFImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UIView *infoBackView;
@property (weak, nonatomic) IBOutlet UILabel *brandLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (nonatomic,strong) UIView *blackLine;
@property (nonatomic,strong) UIPageViewController *infoPageVc;

@property (nonatomic,strong) UIImageView *mengban;
@property (nonatomic,strong) SCGIFImageView *zbar;//二维码

@property (nonatomic,strong) YYIndexInfoAboutViewController *ctnAbout;
@property (nonatomic,strong) YYIndexInfoContactViewController *ctnContact;
@property (nonatomic,assign) NSInteger currentPage;

@property (weak, nonatomic) IBOutlet UIButton *conMsgBtn;
@property (weak, nonatomic) IBOutlet UIButton *editBtn;
@property (weak, nonatomic) IBOutlet UIButton *coverImageBtn;
@property (strong, nonatomic) YYUserHomePageModel *homePageMode;
@property (weak, nonatomic) IBOutlet SCLoopScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UIView *noInfoViewContainer1;

@property (nonatomic,strong) YYNoDataView *noIntroductionDataView;
@property (nonatomic,strong) YYNoDataView *noPicsDataView;

@property (weak, nonatomic) IBOutlet UIView *noHomePageLine;
@property (weak, nonatomic) IBOutlet SCGIFImageView *homePageImg;

@property(nonatomic,strong) UIPopoverController *popController;

@property(nonatomic,strong)YYConnMsgListController *messageViewController;

@end
@implementation YYIndexViewController{
    UILabel *msgNumLabel;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    [self SomePrepare];
    [self UIConfig];
    [self getHomePageBrandInfo];
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
    if([YYUser isShowroomToBrand]){
        _conMsgBtn.hidden = NO;

        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate checkNoticeCount];

        UILabel *titleLabel = [UILabel getLabelWithAlignment:1 WithTitle:NSLocalizedString(@"合作消息_pad",nil) WithFont:13.0f WithTextColor:nil WithSpacing:0];
        [_conMsgBtn addSubview:titleLabel];
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(_conMsgBtn);
        }];

        msgNumLabel = [UILabel getLabelWithAlignment:1 WithTitle:nil WithFont:13.0f WithTextColor:_define_white_color WithSpacing:0];
        [_conMsgBtn addSubview:msgNumLabel];
        [msgNumLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(titleLabel.mas_right).with.offset(0);
            make.height.width.mas_equalTo(20);
            make.bottom.mas_equalTo(titleLabel.mas_top).with.offset(10);
        }];
        msgNumLabel.backgroundColor = [UIColor colorWithHex:@"EF4E31"];
        msgNumLabel.layer.masksToBounds = YES;
        msgNumLabel.layer.cornerRadius = 10.0f;

        [self messageCountChanged:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageCountChanged:) name:UnreadConnNotifyMsgAmount object:nil];

    }else{
        _conMsgBtn.hidden = YES;
    }
    [self haveAdImg:NO];
    
//    self.automaticallyAdjustsScrollViewInsets = NO;
    _logoImageView.layer.masksToBounds = YES;
    _logoImageView.layer.cornerRadius = CGRectGetHeight(_logoImageView.frame)/2;
    _logoImageView.layer.borderWidth = 2.5f;
    _logoImageView.layer.borderColor = [[UIColor colorWithHex:kDefaultImageColor] CGColor];
    _coverImageBtn.imageView.contentMode = UIViewContentModeScaleAspectFill;
    
    _pageControl.hidesForSinglePage = YES;
    _pageControl.pageIndicatorTintColor = [UIColor grayColor];
    _pageControl.currentPageIndicatorTintColor = [UIColor blackColor];
    _pageControl.currentPage = 0;
    
    
    self.noPicsDataView = (YYNoDataView *)addNoDataView_pad(self.noInfoViewContainer1,[NSString stringWithFormat:@"%@|icon:noimage_icon",NSLocalizedString(@"还没有添加品牌海报，点击右上角编辑",nil)],nil,nil);
    self.noPicsDataView.titleLabel.textColor = [UIColor colorWithHex:@"919191"];
    self.noPicsDataView.hidden = YES;
}
#pragma mark - UIConfig
-(void)UIConfig
{
    [self CreateUserInfoPageBar];
    [self CreateUserInfoPageView];
}
-(void)CreateUserInfoPageBar
{
    
    NSArray *titleArr=@[NSLocalizedString(@"关于品牌",nil),NSLocalizedString(@"联系品牌",nil)];
    __block UIView *lastView=nil;
    [titleArr enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIButton *SwitchBtn=[UIButton getCustomTitleBtnWithAlignment:0 WithFont:14.0f WithSpacing:0 WithNormalTitle:obj WithNormalColor:_define_black_color WithSelectedTitle:obj WithSelectedColor:_define_white_color];
        
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
                make.left.mas_equalTo(0);
            }
            make.top.mas_equalTo(_logoImageView.mas_bottom).with.offset(25);
            
            make.height.mas_equalTo(40);
        }];
        if(!idx)
        {
            SwitchBtn.selected=YES;
            SwitchBtn.backgroundColor=_define_black_color;
        }else
        {
            SwitchBtn.selected=NO;
            SwitchBtn.backgroundColor=_define_white_color;
        }
        lastView=SwitchBtn;
    }];
    if(lastView)
    {
        _blackLine=[UIView getCustomViewWithColor:_define_black_color];
        [_infoBackView addSubview:_blackLine];
        [_blackLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.right.mas_equalTo(-35);
            make.top.mas_equalTo(lastView.mas_bottom).with.offset(0);
            make.height.mas_equalTo(3);
        }];
    }
}
-(void)CreateUserInfoPageView
{
    _infoPageVc = [[UIPageViewController alloc] initWithTransitionStyle:1 navigationOrientation:0 options:nil];
    [_infoBackView addSubview:_infoPageVc.view];
//    _infoPageVc.automaticallyAdjustsScrollViewInsets = NO;
    [_infoPageVc.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        make.top.mas_equalTo(_blackLine.mas_bottom).with.offset(0);
    }];
    if(_ctnAbout==nil)
    {
        _ctnAbout=[[YYIndexInfoAboutViewController alloc] initWithHomePageModel:_homePageMode WithBlock:^(NSString *type,UIView *obj) {
            if([type isEqualToString:@"openPancrase"])
            {
                clickWebUrl_pad(_homePageMode.webUrl, obj);
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
                _ctnAbout=[[YYIndexInfoAboutViewController alloc] initWithHomePageModel:_homePageMode WithBlock:^(NSString *type,UIView *obj) {
                    if([type isEqualToString:@"openPancrase"])
                    {
                        clickWebUrl_pad(_homePageMode.webUrl, obj);
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
            _ctnContact =[[YYIndexInfoContactViewController alloc] initWithHomePageModel:_homePageMode WithBlock:^(NSString *type ,YYTypeButton *typeButton) {
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
            obj.backgroundColor=_define_black_color;
            _currentPage=selectIdx;
        }else
        {
            obj.selected=NO;
            obj.backgroundColor=_define_white_color;
        }
    }];
}
-(void)NULLACTION{}
#pragma mark - RequestData
- (void)getShowroomInfoByDesigner{
    WeakSelf(ws);
    [YYShowroomApi getShowroomInfoByDesigner:^(YYRspStatusAndMessage *rspStatusAndMessage,YYShowroomInfoByDesignerModel *showroomInfoByDesignerModel,NSError *error) {
        if(showroomInfoByDesignerModel)
        {
            if(![NSString isNilOrEmpty:showroomInfoByDesignerModel.pic]){
                [ws haveAdImg:YES];
                sd_downloadWebImageWithRelativePath(NO, showroomInfoByDesignerModel.pic, _homePageImg, kStyleDetailCover, 0);
            }else{
                [ws haveAdImg:NO];
            }
        }
    }];
}
-(void)getHomePageBrandInfo{
    WeakSelf(ws);
    [YYUserApi getHomePageBrandInfoWithBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYUserHomePageModel *homePageModel, NSError *error) {
        if(rspStatusAndMessage.status == YYReqStatusCode100){
            ws.homePageMode = homePageModel;
            //            [ws getHomePagePics];
            if(ws.homePageMode.indexPics == nil){
                ws.noPicsDataView.hidden = NO;
            }
            [ws updateUI];
        }
        //UIView *superView = [UIApplication sharedApplication].keyWindow.rootViewController.view;
        //[MBProgressHUD hideAllHUDsForView:superView animated:YES];
    }];
}
#pragma mark - SomeAction
- (void)messageCountChanged:(NSNotification *)notification{
    if([YYUser isShowroomToBrand])
    {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        NSInteger msgAmount = appDelegate.unreadConnNotifyMsgAmount;
        if(msgAmount > 99){
            msgNumLabel.text = @"···";
            msgNumLabel.hidden = NO;
            msgNumLabel.font = getFont(10.0f);
        }else if(msgAmount > 0){
            msgNumLabel.text = [NSString stringWithFormat:@"%ld",msgAmount];
            msgNumLabel.hidden = NO;
            msgNumLabel.font = getFont(13.0f);
        }else{
            msgNumLabel.text = @"";
            msgNumLabel.hidden = YES;
        }
    }
}
- (IBAction)conMsgClicked:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Account" bundle:[NSBundle mainBundle]];
    YYConnMsgListController *messageViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYConnMsgListController"];

    WeakSelf(ws);
    UIView *_rightMaskView = [[UIView alloc] init];
    _rightMaskView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    UIButton *bgView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [_rightMaskView addSubview:bgView];
    __weak UIView *weakMaskView =_rightMaskView;

    [messageViewController setMarkAsReadHandler:^(void){
        [YYConnMsgListController markAsRead];
        [ws.messageViewController.view removeFromSuperview];
        [weakMaskView removeFromSuperview];
    }];

    //[self.navigationController pushViewController:messageViewController animated:YES];

    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    __weak  UIView *_weakContainerView = appDelegate.mainViewController.view;//self.view;

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(OnTapBg:)];
    [bgView addGestureRecognizer:tap];
    [ appDelegate.mainViewController.view addSubview:_rightMaskView];
    self.messageViewController = messageViewController;
    [_rightMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_weakContainerView.mas_top);
        make.left.equalTo(_weakContainerView.mas_left);
        make.bottom.equalTo(_weakContainerView.mas_bottom);
        make.right.equalTo(_weakContainerView.mas_right);
    }];

    [_rightMaskView addSubview:messageViewController.view];
    [messageViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_rightMaskView.mas_top);
        make.bottom.equalTo(_rightMaskView.mas_bottom);
        make.right.equalTo(_rightMaskView.mas_right).offset(653);
        make.width.equalTo(@(653));
    }];
    [messageViewController.view.superview layoutIfNeeded];
    [UIView animateWithDuration:0.5 animations:^{
        [self.messageViewController.view mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(_weakContainerView.mas_right).offset(0);
        }];
        //        //必须调用此方法，才能出动画效果
        [self.messageViewController.view.superview layoutIfNeeded];
        [_rightMaskView setNeedsUpdateConstraints];

        // update constraints now so we can animate the change
        [_rightMaskView.superview updateConstraintsIfNeeded];
        [_rightMaskView updateConstraints];

    }
                     completion:^(BOOL finished) {

                     }];
}
-(void)OnTapBg:(UITapGestureRecognizer *)sender{
    if (_messageViewController && _messageViewController.markAsReadHandler) {
        CGPoint point = [sender locationInView:_messageViewController.view];
        if([_messageViewController.view pointInside:point withEvent:nil]){
            return;
        }
        _messageViewController.markAsReadHandler();
    }
}
-(void)haveAdImg:(BOOL)isexist {
//    _noHomePageLine.hidden = isexist;
//    _homePageImg.hidden = !isexist;
    _noHomePageLine.hidden = NO;
    _homePageImg.hidden = YES;
}
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
-(void)closeAction
{
    [_mengban removeFromSuperview];
}
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

-(void)updateUI{
    if(_ctnAbout)
    {
        _ctnAbout.homePageModel=_homePageMode;
        [_ctnAbout SetData];
    }
    if(_ctnContact)
    {
        _ctnContact.homePageModel=_homePageMode;
        [_ctnContact SetData];
    }
    
    if(_homePageMode && ![NSString isNilOrEmpty:_homePageMode.logoPath]){
        sd_downloadWebImageWithRelativePath(NO, _homePageMode.logoPath, _logoImageView, kLogoCover, 0);
    }else{
//        sd_downloadWebImageWithRelativePath(NO, @"", _logoImageView, kLogoCover, 0);
        [_logoImageView setImage:[UIImage imageNamed:@"default_icon"]];
    }
    
    YYUser *user = [YYUser currentUser];
    
    _nameLabel.text= user.name;
    
    //联系方式
    
    if(!_homePageMode || [NSString isNilOrEmpty:_homePageMode.brandName]){
        _brandLabel.text = @"";//;
    }else{
        _brandLabel.text = _homePageMode.brandName;
    }

    if(_homePageMode.indexPics && [_homePageMode.indexPics count] > 0){
        self.noPicsDataView.hidden = YES;
        [self updateScrollView];
    }else{
        _pageControl.hidden = YES;
        [self updateScrollView];
    }
}
- (IBAction)showPicsScrollView:(id)sender {
    if([_homePageMode.indexPics count] == 0){
        return;
    }
    NSInteger count = [_homePageMode.indexPics count];
    NSMutableArray *tmpArr = [[NSMutableArray alloc] initWithCapacity:count];
    if(count > 0){
        for(int i = 0 ; i < count; i++){
            NSString *imageName =[NSString stringWithFormat:@"%@",[_homePageMode.indexPics objectAtIndex:i]];
            NSString *_imageRelativePath = imageName;
            NSString *imgInfo = [NSString stringWithFormat:@"%@%@|%@",_imageRelativePath,kLookBookImage,@""];
            [tmpArr addObject:imgInfo];
        }
        
    }
    SCLoopScrollView *scrollView = [[SCLoopScrollView alloc] initWithFrame:CGRectMake(0, 0, 600, 600)];
    scrollView.backgroundColor = [UIColor clearColor];
    //scrollView.defaultImage = [UIImage imageWithColor:[UIColor clearColor] size:CGSizeMake(600, 600)];
    scrollView.images = tmpArr;
    UILabel *pageLabel = [[UILabel alloc] initWithFrame:CGRectMake((CGRectGetWidth(scrollView.frame)-100)/2, (CGRectGetHeight(scrollView.frame) -28-15), 100, 28)];
    pageLabel.textColor = [UIColor whiteColor];//[UIColor colorWithHex:@"0xafafafaf99"];
    pageLabel.font = [UIFont systemFontOfSize:15];
    pageLabel.textAlignment = NSTextAlignmentCenter;
    pageLabel.text = [NSString stringWithFormat:@"%d / %lu",1,(unsigned long)[tmpArr count]];
//    pageLabel.layer.borderColor = [UIColor blackColor].CGColor;
//    pageLabel.layer.borderWidth = 1;
    __block UILabel *weakpageLabel = pageLabel;
    __block NSInteger blockPagecount = [tmpArr count];
    [scrollView show:^(NSInteger index) {

    } finished:^(NSInteger index) {
        if(blockPagecount == 0){
            [weakpageLabel setText:@""];
        }else{
            [weakpageLabel setText:[NSString stringWithFormat:@"%ld / %ld",index+1,(long)blockPagecount]];
        }
    }];
    CMAlertView *alert = [[CMAlertView alloc] initWithViews:@[scrollView,pageLabel] imageFrame:CGRectMake(0, 0, 600, 600) bgClose:NO];
    [alert show];
    //    NSInteger menuUIWidth = SCREEN_WIDTH;
//    NSInteger menuUIHeight = SCREEN_HEIGHT;
//    UIViewController *controller = [[UIViewController alloc] init];
//    controller.view.frame = CGRectMake(0, 0, menuUIWidth, menuUIHeight);
//    controller.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
//    
//    UIPopoverController *popController = [[UIPopoverController alloc] initWithContentViewController:controller];
//    _popController = popController;
//    
//    UIViewController *parent = [UIApplication sharedApplication].keyWindow.rootViewController;
//    CGRect rc = CGRectMake(0, 0, 0, 0);
//    //popController.popoverBackgroundViewClass = [YYPopoverBackgroundView class];
//    popController.popoverContentSize = CGSizeMake(menuUIWidth,menuUIHeight);
//    [popController presentPopoverFromRect:rc inView:parent.view permittedArrowDirections:UIPopoverArrowDirectionUnknown animated:YES];
}

-(void)updateScrollView{
    
    if([_homePageMode.indexPics count] == 0){
        _pageControl.hidden = YES;
        _scrollView.hidden = YES;
        return;
    }
    _scrollView.hidden = NO;
    _pageControl.currentPage = 0;
    

    NSInteger count = [_homePageMode.indexPics count];
    NSMutableArray *tmpArr = [[NSMutableArray alloc] initWithCapacity:count];
    
    if(count > 0){
        for(int i = 0 ; i < count; i++){
            NSString *imageName =[NSString stringWithFormat:@"%@",[_homePageMode.indexPics objectAtIndex:i]];
            NSString *_imageRelativePath = imageName;
            NSString *imgInfo = [NSString stringWithFormat:@"%@%@|%@",_imageRelativePath,kLookBookImage,@""];
            [tmpArr addObject:imgInfo];
        }
        
    }

   // _scrollView.defaultImage = [UIImage imageWithColor:[UIColor clearColor] size:CGSizeMake(CGRectGetWidth(_scrollView.frame), CGRectGetHeight(_scrollView.frame))];
    _scrollView.images = tmpArr;
    __block UIPageControl *weakpageControl = _pageControl;
    //__block NSInteger blockPagecount = [tmpArr count];
    _pageControl.numberOfPages = [tmpArr count];
    [_scrollView show:^(NSInteger index) {
        
    } finished:^(NSInteger index) {
        weakpageControl.hidden = NO;
        _pageControl.currentPage = index;
        
    }];
}

- (IBAction)editHandler:(id)sender {

    YYEditMyPageViewController *editMyPage = [[YYEditMyPageViewController alloc] init];
    editMyPage.homePageMode = _homePageMode;
    [self.navigationController pushViewController:editMyPage animated:YES];

}


#pragma mark - Other
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self getShowroomInfoByDesigner];
    [self getHomePageBrandInfo];

    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate checkNoticeCount];

    // 进入埋点
    [MobClick beginLogPageView:kYYPageIndex];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    // 退出埋点
    [MobClick endLogPageView:kYYPageIndex];
}

//-(void)getHomePagePics{
//    if(_homePageMode == nil || _homePageMode.brandIntroduction == nil || [_homePageMode.brandId integerValue] <= 0){
//        self.picsModel = nil;
//        self.noPicsDataView.hidden = NO;
//        return;
//    }
//    WeakSelf(weakSelf);
//    [YYUserApi getHomePagePics:[_homePageMode.brandIntroduction.designerId integerValue] andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYIndexPicsModel *picsModel, NSError *error) {
//        if(rspStatusAndMessage.status == YYReqStatusCode100){
//            weakSelf.picsModel = picsModel;
//            if(picsModel == nil){
//                weakSelf.noPicsDataView.hidden = NO;
//            }
//            [weakSelf updateUI];
//        }
//    }];
//}
@end

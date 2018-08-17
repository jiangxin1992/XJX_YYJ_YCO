//
//  YYProtocolViewController.m
//  yunejianDesigner
//
//  Created by Apple on 16/11/15.
//  Copyright © 2016年 Apple. All rights reserved.
//

#import "YYProtocolViewController.h"
#import "YYNavigationBarViewController.h"
#import "regular.h"
#import "YYBaseWebView.h"
#import "YYShowroomAgentModel.h"

@interface YYProtocolViewController ()
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet YYBaseWebView *webView;
@property (nonatomic,strong) UIView *tempContainerView;
@property (nonatomic,strong) UIScrollView *scrollView;
@end

@implementation YYProtocolViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self SomePrepare];
    [self UIConfig];
    
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    // 退出埋点
    if([_protocolType isEqualToString:@"showroomAgent"]){
        [MobClick endLogPageView:kYYPageProtocolAgent];
    }else{
        [MobClick endLogPageView:kYYPageProtocolAgreement];
    }
}

#pragma mark - SomePrepare
-(void)SomePrepare
{
    [self PrepareData];
    [self PrepareUI];
}

-(void)PrepareData{}
-(void)PrepareUI{
    self.view.backgroundColor = _define_white_color;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    YYNavigationBarViewController *navigationBarViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYNavigationBarViewController"];
    navigationBarViewController.previousTitle = @"";
    if([_protocolType isEqualToString:@"showroomAgent"]){
        
        navigationBarViewController.nowTitle = NSLocalizedString(@"代理协议",nil);
    }else{
        navigationBarViewController.nowTitle = _nowTitle;
    }
    [_containerView insertSubview:navigationBarViewController.view atIndex:0];
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
            [ws cancelClicked:nil];
            blockVc = nil;
        }
    }];
    _webView.backgroundColor = _define_white_color;
}
-(void)UIConfig{
    if([_protocolType isEqualToString:@"showroomAgent"]){
        // 进入埋点
        [MobClick beginLogPageView:kYYPageProtocolAgent];
        [self agentConfig];
    }else{
        [self protocolConfig];
        // 进入埋点
        [MobClick beginLogPageView:kYYPageProtocolAgreement];
    }
}
-(void)agentConfig{
    _webView.hidden = YES;
    _scrollView=[[UIScrollView alloc] init];
    [self.view addSubview:_scrollView];
    _tempContainerView = [UIView new];
    [_scrollView addSubview:_tempContainerView];
    _scrollView.layer.masksToBounds = YES;
    _scrollView.layer.borderColor = [[UIColor colorWithHex:@"efefef"] CGColor];
    _scrollView.layer.borderWidth = 1;
    [_tempContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_scrollView);
        make.width.equalTo(_scrollView);
    }];
    
    UILabel *mainTitleLabel = [UILabel getLabelWithAlignment:1 WithTitle:[[NSString alloc] initWithFormat:NSLocalizedString(@"《 %@ × %@ 代理协议》",nil),_agentModel.showroomName,_agentModel.brandName] WithFont:16.0f WithTextColor:nil WithSpacing:0];
    [_tempContainerView addSubview:mainTitleLabel];
    mainTitleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    [mainTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(17);
        make.centerX.mas_equalTo(_tempContainerView);
    }];
    
    long contactStartTime = [regular getTimeWithTimeStr:_agentModel.contactStartTime WithFormatter:@"yyyy-MM-dd"];
    long contactEndTime = [regular getTimeWithTimeStr:_agentModel.contactEndTime WithFormatter:@"yyyy-MM-dd"];
    NSString *contactStartTimeStr = [regular getTimeStr:contactStartTime WithFormatter:@"yyyy/MM/dd"];
    NSString *contactEndTimeStr = [regular getTimeStr:contactEndTime WithFormatter:@"yyyy/MM/dd"];
    NSString *contactTimeStr = [[NSString alloc] initWithFormat:NSLocalizedString(@"%@至%@",nil),contactStartTimeStr,contactEndTimeStr];
    UIView *lastView = nil;
    for (int i=0; i<3; i++) {
        
        NSString *title =i==0?NSLocalizedString(@"代理时间：",nil):i==1?NSLocalizedString(@"代理方：",nil):NSLocalizedString(@"被代理方：",nil);
        UILabel *titleLabel = [UILabel getLabelWithAlignment:0 WithTitle:title WithFont:13.0f WithTextColor:nil WithSpacing:0];
        [_tempContainerView addSubview:titleLabel];
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(26);
            if(lastView){
                make.top.mas_equalTo(lastView.mas_bottom).with.offset(10);
            }else{
                make.top.mas_equalTo(mainTitleLabel.mas_bottom).with.offset(32);
            }
        }];
        
        NSString *contentStr =i==0?contactTimeStr:i==1?_agentModel.showroomName:_agentModel.brandName;
        UILabel *contentLabel = [UILabel getLabelWithAlignment:0 WithTitle:contentStr WithFont:13.0f WithTextColor:i==0?nil:[UIColor colorWithHex:@"ed6498"] WithSpacing:0];
        [_tempContainerView addSubview:contentLabel];
        [contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(titleLabel.mas_right).with.offset(0);
            make.centerY.mas_equalTo(titleLabel);
        }];
        lastView = titleLabel;
    }
    
    UILabel *contentTitleLabel = [UILabel getLabelWithAlignment:0 WithTitle:NSLocalizedString(@"代理内容：",nil) WithFont:13.0f WithTextColor:nil WithSpacing:0];
    [_tempContainerView addSubview:contentTitleLabel];
    [contentTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(lastView.mas_bottom).with.offset(16);
        make.left.mas_equalTo(26);
    }];
    
    UILabel *contentLabel = [UILabel getLabelWithAlignment:0 WithTitle:_agentModel.agentContent WithFont:13.0f WithTextColor:nil WithSpacing:0];
    [_tempContainerView addSubview:contentLabel];
    contentLabel.numberOfLines = 0;
    [contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(contentTitleLabel.mas_bottom).with.offset(10);
        make.left.mas_equalTo(26);
        make.right.mas_equalTo(-26);
    }];
    
    if([NSString isNilOrEmpty:_agentModel.agentContent])
    {
        contentTitleLabel.text = @"";
    }else
    {
        contentTitleLabel.text = NSLocalizedString(@"代理内容：",nil);
    }
    [_scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_containerView.mas_bottom).with.offset(50);
        make.height.mas_equalTo(424);
        make.width.mas_equalTo(800);
        make.centerX.mas_equalTo(self.view);
        // 让scrollview的contentSize随着内容的增多而变化
        make.bottom.mas_equalTo(contentLabel.mas_bottom).with.offset(40);
    }];
}
-(void)protocolConfig{
    //    隐私权保护声明 secrecyAgreement/ 服务协议 serviceAgreement
    NSString *url = nil;
    if([_protocolType isEqualToString:@"secrecyAgreement"])
    {
        if([LanguageManager isEnglishLanguage]){
            url = @"http://cdn2.ycosystem.com/yej-tb/static/secrecyAgreement_ipad_en.html";
        }else{
            url = @"http://cdn2.ycosystem.com/yej-tb/static/secrecyAgreement_ipad.html";
        }
        
    }else if([_protocolType isEqualToString:@"serviceAgreement"])
    {
        if([LanguageManager isEnglishLanguage]){
            url = @"http://cdn2.ycosystem.com/yej-tb/static/serviceAgreement_ipad_en.html";
        }else{
            url = @"http://cdn2.ycosystem.com/yej-tb/static/serviceAgreement_ipad.html";
        }
    }
    if(![NSString isNilOrEmpty:url])
    {
        _webView.urlString = url;
    }
}
#pragma Other
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (UIStatusBarStyle)preferredStatusBarStyle
{
    if(_cancelButtonClicked)
    {
        UIView *statusBarView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 20)];
        statusBarView.backgroundColor=[UIColor whiteColor];
        [self.view addSubview:statusBarView];
        
        return UIStatusBarStyleDefault;
        
    }
    return UIStatusBarStyleDefault;
}
- (IBAction)cancelClicked:(id)sender{
    if (_cancelButtonClicked) {
        _cancelButtonClicked();
    }
}
@end

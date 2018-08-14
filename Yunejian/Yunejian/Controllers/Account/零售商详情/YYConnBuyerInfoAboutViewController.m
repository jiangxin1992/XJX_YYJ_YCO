//
//  YYConnBuyerInfoAboutViewController.m
//  Yunejian
//
//  Created by yyj on 2017/1/3.
//  Copyright © 2017年 yyj. All rights reserved.
//

#import "YYConnBuyerInfoAboutViewController.h"

#import <WebKit/WebKit.h>

#import "YYNoDataView.h"

#import "YYBuyerDetailModel.h"

@interface YYConnBuyerInfoAboutViewController ()<WKNavigationDelegate>

@property (nonatomic,strong) UIScrollView *infoAboutScrollView;
@property (nonatomic,strong) UIView *container;

@property (nonatomic,strong) WKWebView *infoAboutWebview;
@property (nonatomic,strong) UILabel *pancraseLabel;
@property (nonatomic,strong) UILabel *retailerNameLabel;
@property (nonatomic,strong) UILabel *businessScopeLabel;

@property (nonatomic,strong) UIView *noIntroductionDataView;

@end

@implementation YYConnBuyerInfoAboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self SomePrepare];
    [self UIConfig];
}
#pragma mark - init
-(instancetype)initWithBuyerDetailModel:(YYBuyerDetailModel *)buyerDetailModel WithBlock:(void(^)(NSString *type,UIView *obj))block
{
    self=[super init];
    if(self)
    {
        _buyerDetailModel=buyerDetailModel;
        _block=block;
        [self SetData];
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
-(void)UIConfig
{
    [self CreateScrollView];
    
    [self CreateAboutWebview];
    
    [self CreateOtherView];
    
    [_infoAboutScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.top.mas_equalTo(0);
        // 让scrollview的contentSize随着内容的增多而变化
        make.bottom.mas_equalTo(_retailerNameLabel.mas_bottom).with.offset(40);
    }];
    
    [self CreateNoDataView];
}
-(void)CreateOtherView
{
    _pancraseLabel = [UILabel getLabelWithAlignment:0 WithTitle:@"" WithFont:13.0f WithTextColor:[UIColor colorWithHex:kDefaultTitleColor_pad] WithSpacing:0];
    [_container addSubview:_pancraseLabel];
    _pancraseLabel.userInteractionEnabled=YES;
    [_pancraseLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openPancrase)]];
    [_pancraseLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(_infoAboutWebview.mas_bottom).with.offset(24);
    }];
    
    _businessScopeLabel = [UILabel getLabelWithAlignment:0 WithTitle:@"" WithFont:13.0f WithTextColor:[UIColor colorWithHex:kDefaultTitleColor_pad] WithSpacing:0];
    [_container addSubview:_businessScopeLabel];
    [_businessScopeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(_pancraseLabel.mas_bottom).with.offset(24);
    }];
    
    _retailerNameLabel = [UILabel getLabelWithAlignment:0 WithTitle:@"" WithFont:13.0f WithTextColor:[UIColor colorWithHex:kDefaultTitleColor_pad] WithSpacing:0];
    [_container addSubview:_retailerNameLabel];
    _retailerNameLabel.numberOfLines=0;
    [_retailerNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(_businessScopeLabel.mas_bottom).with.offset(24);
    }];
    
}
-(void)CreateAboutWebview
{
    _infoAboutWebview=[[WKWebView alloc] init];
    [_container addSubview:_infoAboutWebview];
    _infoAboutWebview.userInteractionEnabled=NO;
    _infoAboutWebview.navigationDelegate = self;
    [_infoAboutWebview sizeToFit];
    [_infoAboutWebview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(-35);
        make.top.mas_equalTo(27);
        make.height.mas_equalTo(0);
    }];
}
-(void)CreateScrollView
{
    _infoAboutScrollView=[[UIScrollView alloc] init];
    [self.view addSubview:_infoAboutScrollView];
    _infoAboutScrollView.showsVerticalScrollIndicator=NO;
    _container = [UIView new];
    [_infoAboutScrollView addSubview:_container];
    [_container mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_infoAboutScrollView);
        make.width.equalTo(_infoAboutScrollView);
    }];
}
-(void)CreateNoDataView
{
    if(!_noIntroductionDataView)
    {
        _noIntroductionDataView = (YYNoDataView *)addNoDataView_pad(self.view,[NSString stringWithFormat:@"%@|icon:notxt_icon",NSLocalizedString(@"还没有添加买手店信息，点击右上角编辑",nil)],kDefaultBorderColor,@"noinfo_icon");
        [self.view addSubview:_noIntroductionDataView];
        [_noIntroductionDataView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.left.mas_equalTo(0);
            make.height.mas_equalTo(360);
            make.right.mas_equalTo(-35);
        }];
        _noIntroductionDataView.hidden=YES;
    }
    
    
    
}
#pragma mark - SetData
-(void)SetData
{
    BOOL _haveData=NO;
    
    if(![NSString isNilOrEmpty:_buyerDetailModel.introduction])
    {
        NSString *htmlStr=getHTMLStringWithContent_pad(_buyerDetailModel.introduction, @"13px/22px", @"#646464");
        [_infoAboutWebview loadHTMLString:htmlStr baseURL:nil];
        _haveData=YES;
    }else
    {
        [_infoAboutWebview loadHTMLString:@"" baseURL:nil];
    }
    
//    kDefaultBlueColor
    if(![NSString isNilOrEmpty:_buyerDetailModel.webUrl])
    {
        NSString *contentStr = [NSString stringWithFormat:NSLocalizedString(@"网址：%@",nil),_buyerDetailModel.webUrl];
        NSMutableAttributedString *content = [[NSMutableAttributedString alloc]initWithString:contentStr];
        NSRange contentRange = [contentStr rangeOfString:_buyerDetailModel.webUrl];
//        [content addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:contentRange];
        [content addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHex:kDefaultBlueColor] range:contentRange];
        _pancraseLabel.attributedText = content;
        _haveData=YES;
    }else
    {
        _pancraseLabel.text=@"";
    }
    
    
    if([_buyerDetailModel.priceMin integerValue]>=0&&[_buyerDetailModel.priceMax integerValue]>=0)
    {
        if([_buyerDetailModel.priceMin integerValue]==0&&[_buyerDetailModel.priceMax integerValue]==0)
        {
        }else
        {
            _businessScopeLabel.text=[[NSString alloc] initWithFormat:NSLocalizedString(@"经营款式零售价格范围：￥%ld - ￥%ld",nil),(long)[_buyerDetailModel.priceMin integerValue],(long)[_buyerDetailModel.priceMax integerValue]];
        }
    }
    
    if(_buyerDetailModel.copBrands)
    {
        if(_buyerDetailModel.copBrands.count)
        {
            __block BOOL _allNULL = YES;
            [_buyerDetailModel.copBrands enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if(![NSString isNilOrEmpty:obj])
                {
                    _allNULL = NO;
                    *stop = YES;
                }
            }];
            if(_allNULL)
            {
                _retailerNameLabel.text=@"";
            }else
            {
                _retailerNameLabel.text=[[NSString alloc] initWithFormat:NSLocalizedString(@"合作过的品牌：%@",nil),[_buyerDetailModel.copBrands componentsJoinedByString:@"，"]];
                _haveData=YES;
            }
        }else
        {
            _retailerNameLabel.text=@"";
        }
    }else
    {
        _retailerNameLabel.text=@"";
    }
    
    if(!_haveData)
    {
        _noIntroductionDataView.hidden=NO;
    }else
    {
        _noIntroductionDataView.hidden=YES;
    }
}
#pragma mark - WKNavigationDelegate

//加载完成时调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [webView evaluateJavaScript:@"document.body.offsetHeight" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        CGFloat height = 0;
        
        if(![NSString isNilOrEmpty:_buyerDetailModel.introduction])
        {
            height = floor([result doubleValue])+2;
        }else
        {
            height = 0;
        }
        [webView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(height);
        }];
    }];
}
#pragma mark - SomeAction
-(void)openPancrase
{
    if(_block){
        _block(@"openPancrase",_pancraseLabel);
    }
}

#pragma mark - Other
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end

//
//  YYBuyerInfoCell.m
//  Yunejian
//
//  Created by lixuezhi on 15/8/17.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import "YYBuyerInfoCell1.h"

// c文件 —> 系统文件（c文件在前）

// 控制器

// 自定义视图
#import "YYYellowPanelManage.h"
#import "YYTopAlertView.h"
#import "MBProgressHUD.h"
#import "YYPopoverArrowBackgroundView.h"

// 接口
#import "YYOrderApi.h"

// 分类
#import "UIImage+YYImage.h"

// 自定义类和三方类（ cocoapods类 > model > 工具类 > 其他）
#import "YYUser.h"
#import "YYBuyerModel.h"
#import "YYOrderInfoModel.h"
#import "YYOrderBuyerAddress.h"

#import "SDWebImageManager.h"
#import "UserDefaultsMacro.h"

@interface YYBuyerInfoCell1 ()<UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *nameLab;
@property (weak, nonatomic) IBOutlet UIButton *buyerImageButton;
@property (weak, nonatomic) IBOutlet UILabel *timeLab;
@property (weak, nonatomic) IBOutlet UILabel *locationLab;
@property (weak, nonatomic) IBOutlet UILabel *payMethodLab;
@property (weak, nonatomic) IBOutlet UILabel *giveMethodLab;
@property (weak, nonatomic) IBOutlet UILabel *addressLab1;
@property (weak, nonatomic) IBOutlet UILabel *orderTypeLab;

@property (weak, nonatomic) IBOutlet UIButton *connStatusBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabelLayoutWidthConstraint;

@property (weak, nonatomic) IBOutlet UIButton *connStatusHelpBtn;
@property (nonatomic ,strong) UIPopoverController *popController;
@property (nonatomic ,strong) UITextView *linkTxtView;
@end

@implementation YYBuyerInfoCell1

#pragma mark - --------------生命周期--------------
- (void)awakeFromNib {
    [super awakeFromNib];
    [self SomePrepare];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}
#pragma mark - --------------SomePrepare--------------
- (void)SomePrepare
{
    [self PrepareData];
    [self PrepareUI];
}
- (void)PrepareData{}
- (void)PrepareUI{
    _buyerImageButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
}

#pragma mark - --------------UpdataUI----------------------
- (void)updataUI{  //记得清空假数据
    YYUser *user = [YYUser currentUser];
    _connStatusBtn.hidden = YES;
    _connStatusHelpBtn.hidden = YES;
    if(false && user.userType == YYUserTypeRetailer){

        self.locationLab.text = @"";
        _buyerImageButton.hidden = YES;
        self.nameLab.text = @"";
    }else{

        if(true && _currentYYOrderInfoModel && _currentOrderConnStatus >=-1){
            NSString *orderConnStutas = @"";
            NSString * nameInfoStr = _currentYYOrderInfoModel.buyerName;
            if([_currentYYOrderInfoModel.buyerAddressId integerValue] > 0){
                NSString *_nation = [LanguageManager isEnglishLanguage]?_currentYYOrderInfoModel.buyerAddress.nationEn:_currentYYOrderInfoModel.buyerAddress.nation;
                NSString *_province = [LanguageManager isEnglishLanguage]?_currentYYOrderInfoModel.buyerAddress.provinceEn:_currentYYOrderInfoModel.buyerAddress.province;
                NSString *_city = [LanguageManager isEnglishLanguage]?_currentYYOrderInfoModel.buyerAddress.cityEn:_currentYYOrderInfoModel.buyerAddress.city;
                nameInfoStr = [NSString stringWithFormat:@"%@ %@ %@ %@",nameInfoStr,_nation,_province,_city];
            }
            NSMutableAttributedString *nameAttrStr = [[NSMutableAttributedString alloc] init];
            CGSize nameTxtsize= [nameInfoStr sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]}];
            if(_currentOrderConnStatus == YYOrderConnStatusNotFound){
                [nameAttrStr appendAttributedString:[[NSAttributedString alloc] initWithString:nameInfoStr  attributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5]}]];
                orderConnStutas = getOrderConnStatusName_pad(_currentOrderConnStatus);//@"【未入驻】";
                [nameAttrStr appendAttributedString:[[NSAttributedString alloc] initWithString:orderConnStutas attributes:@{NSForegroundColorAttributeName:[UIColor redColor],NSFontAttributeName:[UIFont systemFontOfSize:14]}]];

            }else  if(_currentOrderConnStatus == YYOrderConnStatusUnconfirmed){
                [nameAttrStr appendAttributedString:[[NSAttributedString alloc] initWithString:nameInfoStr  attributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:0 green:0 blue:0 alpha:1],NSFontAttributeName:[UIFont boldSystemFontOfSize:15]}]];
                orderConnStutas = getOrderConnStatusName_pad(_currentOrderConnStatus);//@"【未确认】";
                [nameAttrStr appendAttributedString:[[NSAttributedString alloc] initWithString:orderConnStutas attributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:0 green:0 blue:0 alpha:1],NSFontAttributeName:[UIFont systemFontOfSize:14]}]];

            }else if(_currentOrderConnStatus == YYOrderConnStatusLinked){
                [nameAttrStr appendAttributedString:[[NSAttributedString alloc] initWithString:nameInfoStr  attributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:0 green:0 blue:0 alpha:1],NSFontAttributeName:[UIFont boldSystemFontOfSize:15]}]];
                orderConnStutas = getOrderConnStatusName_pad(_currentOrderConnStatus);//@"【关联中】";
                [nameAttrStr appendAttributedString:[[NSAttributedString alloc] initWithString:orderConnStutas attributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:0 green:0 blue:0 alpha:1],NSFontAttributeName:[UIFont systemFontOfSize:14]}]];

            }else{
                [nameAttrStr appendAttributedString:[[NSAttributedString alloc] initWithString:nameInfoStr  attributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:0 green:0 blue:0 alpha:1],NSFontAttributeName:[UIFont boldSystemFontOfSize:15]}]];
                orderConnStutas = getOrderConnStatusName_pad(_currentOrderConnStatus);//@"【关联失败】";
                [nameAttrStr appendAttributedString:[[NSAttributedString alloc] initWithString:orderConnStutas attributes:@{NSForegroundColorAttributeName:[UIColor redColor],NSFontAttributeName:[UIFont systemFontOfSize:14]}]];

            }
            self.nameLab.attributedText = nameAttrStr;
            _nameLabelLayoutWidthConstraint.constant = nameTxtsize.width + [orderConnStutas length]*15;
            NSInteger orderStatus = getOrderTransStatus(_currentYYOrderInfoModel.designerOrderStatus, _currentYYOrderInfoModel.buyerOrderStatus);
            if((_currentOrderConnStatus != YYOrderConnStatusLinked)&&(orderStatus == YYOrderCode_NEGOTIATION)){
                _connStatusBtn.hidden = NO;
                if([_currentYYOrderInfoModel.isAppend integerValue] == 1){
                    _connStatusHelpBtn.hidden = NO;
                    _connStatusBtn.userInteractionEnabled = NO;
                }else{
                    _connStatusHelpBtn.hidden = YES;
                    _connStatusBtn.userInteractionEnabled = YES;
                }
            }
        }else{
            _nameLabelLayoutWidthConstraint.constant = 380;
            self.nameLab.text = _currentYYOrderInfoModel.buyerName;
        }
        _buyerImageButton.hidden = NO;

        if (_currentYYOrderInfoModel.businessCard
            && [_currentYYOrderInfoModel.businessCard length] > 0) {
            NSString *imageRelativePath = _currentYYOrderInfoModel.businessCard;

            _buyerImageButton.enabled = NO;

            NSURL *imageUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",imageRelativePath,kBuyerCardImage]];
            __weak UIButton *weakButton = _buyerImageButton;
            SDWebImageManager *manager = [SDWebImageManager sharedManager];
            [manager downloadImageWithURL:imageUrl options:SDWebImageRetryFailed|SDWebImageLowPriority progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                if (image) {
                    [weakButton setImage:image forState:UIControlStateNormal];
                    weakButton.enabled = YES;
                }
            }];
        }else{
            //这里判断一下，是否有离线创建订单时选择好的图片
            _buyerImageButton.enabled = NO;
        }

        self.locationLab.text = @"";
    }

    if([NSString isNilOrEmpty:_currentYYOrderInfoModel.type]){
        _orderTypeLab.text = NSLocalizedString(@"订单类型未设置",nil);
    }else{
        if([_currentYYOrderInfoModel.type isEqualToString:@"BUYOUT"]){
            _orderTypeLab.text = NSLocalizedString(@"买断",nil);
        }else if([_currentYYOrderInfoModel.type isEqualToString:@"CONSIGNMENT"]){
            _orderTypeLab.text = NSLocalizedString(@"寄售",nil);
        }else{
            _orderTypeLab.text = NSLocalizedString(@"订单类型未设置",nil);
        }
    }

    if(_currentYYOrderInfoModel.payApp == nil || [_currentYYOrderInfoModel.payApp  isEqualToString:@""]){
        self.payMethodLab.text = NSLocalizedString(@"结算方式未录入",nil);
    }else{
        self.payMethodLab.text = _currentYYOrderInfoModel.payApp;
    }
    if(_currentYYOrderInfoModel.deliveryChoose == nil || [_currentYYOrderInfoModel.deliveryChoose  isEqualToString:@""]){
        self.giveMethodLab.text = NSLocalizedString(@"发货方式未录入",nil);
    }else{
        self.giveMethodLab.text = _currentYYOrderInfoModel.deliveryChoose;
    }
    //设置时间
    self.timeLab.text = @"";
    NSString *tmpOrderCode = @"0";
    if(_currentYYOrderInfoModel.orderCode){
        tmpOrderCode = _currentYYOrderInfoModel.orderCode;
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
    double temp = [_currentYYOrderInfoModel.orderCreateTime doubleValue];

    NSDate *date = [NSDate dateWithTimeIntervalSince1970: temp/ 1000];
    self.timeLab.text = [NSString stringWithFormat:NSLocalizedString(@"订单编号：%@     建单时间：%@     ",nil),tmpOrderCode,[formatter stringFromDate:date]];

    if(_currentYYOrderInfoModel.occasion != nil && ![_currentYYOrderInfoModel.occasion  isEqualToString:@""]){
        self.timeLab.text = [NSString stringWithFormat:NSLocalizedString(@"%@ 建立场合：%@",nil),self.timeLab.text,_currentYYOrderInfoModel.occasion];
    }
    if(_currentYYOrderInfoModel.billCreatePersonName != nil && ![_currentYYOrderInfoModel.billCreatePersonName isEqualToString:@""]){
        self.timeLab.text = [NSString stringWithFormat:NSLocalizedString(@"%@ 销售：%@",nil),self.timeLab.text,_currentYYOrderInfoModel.billCreatePersonName];
    }

    //设置地址
    YYOrderBuyerAddress *buyerAddress = _currentYYOrderInfoModel.buyerAddress;
    if (buyerAddress) {
        self.addressLab1.text = getBuyerAddressStr_pad(buyerAddress);
    }else{
        self.addressLab1.text = @"";
    }
}

//#pragma mark - --------------请求数据----------------------
//-(void)RequestData{}
#pragma mark - --------------系统代理----------------------
#pragma mark -UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    if ([[URL scheme] isEqualToString:@"type"]) {
        if(self.popController){
            [self.popController dismissPopoverAnimated:YES];
        }
        if([_parentController respondsToSelector:@selector(jumpOrderDetailHandler)]){//
            [_parentController performSelector:@selector(jumpOrderDetailHandler)];
        }
        return NO;
    }
    return YES; // let the system open this URL
}

#pragma mark - --------------自定义响应----------------------
- (IBAction)buyerImageButtonClicked:(id)sender{
    UIButton *button = (UIButton *)sender;
    UIImage *image = [button imageForState:UIControlStateNormal];
    if (self.buyerCardButtonClicked
        && image) {
        self.buyerCardButtonClicked(image);
    }
}
- (IBAction)reConnStatusHandler:(id)sender {
    if(self.currentYYOrderInfoModel.orderCode ==nil || self.currentYYOrderInfoModel.orderCode.length ==0){
        return;
    }

    UIView *parentView = [UIApplication sharedApplication].keyWindow.rootViewController.view;
    __block UIView *blockParentView = parentView;
    WeakSelf(ws);
    [[YYYellowPanelManage instance] showOrderBuyerAddressListPanel:@"Order" andIdentifier:@"YYOrderAddressListController"  needUnDefineBuyer:1 parentView:parentView andCallBack:^(NSArray *value) {
        YYBuyerModel *_buyerModel = nil;
        [MBProgressHUD showHUDAddedTo:blockParentView animated:YES];

        if([value count] >= 2){
            _buyerModel = [value objectAtIndex:1];
            ws.currentYYOrderInfoModel.buyerName = _buyerModel.name;
            ws.currentYYOrderInfoModel.buyerEmail = _buyerModel.contactEmail;
        }else{
            NSString* name = [value objectAtIndex:0];
            ws.currentYYOrderInfoModel.buyerName = name;
            ws.currentYYOrderInfoModel.buyerEmail = @"";
        }
        NSData *jsonData = [ws.currentYYOrderInfoModel toJSONData];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData
                                                     encoding:NSUTF8StringEncoding];
        NSLog(@"jsonString: %@",jsonString);
        NSString *actionRefer = @"rebuild";
        NSInteger realBuyerId = [_buyerModel.buyerId integerValue];
        if(_buyerModel != nil){
            ws.currentYYOrderInfoModel.realBuyerId = _buyerModel.buyerId;
        }else{
            ws.currentYYOrderInfoModel.realBuyerId = [[NSNumber alloc ] initWithInt:0];
        }
        [YYOrderApi createOrModifyOrderByJsonString:jsonString actionRefer:actionRefer realBuyerId:realBuyerId andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSString *orderCode, NSError *error) {
            [MBProgressHUD hideAllHUDsForView:blockParentView animated:YES];
            if (rspStatusAndMessage.status == YYReqStatusCode100) {
                [YYTopAlertView showWithType:YYTopAlertTypeSuccess text:NSLocalizedString(@"操作成功",nil) parentView:nil];
                if(ws.reConnStatusButtonClicked){
                    ws.reConnStatusButtonClicked(@[ws.currentYYOrderInfoModel.buyerName,ws.currentYYOrderInfoModel.buyerEmail, ws.currentYYOrderInfoModel.realBuyerId]);
                }
            }else{
                [YYToast showToastWithView:blockParentView title:rspStatusAndMessage.message  andDuration:kAlertToastDuration];
            }
        }];

    }];
}


- (IBAction)showBuyerInfoView:(id)sender {
    if(self.buyerInfoButtonClicked){
        self.buyerInfoButtonClicked();
    }
}

- (IBAction)connStatusHelpBtnHandler:(id)sender {
    NSInteger menuUIWidth = 245;
    NSInteger menuUIHeight = 80;

    UIViewController *controller = [[UIViewController alloc] init];
    controller.view.frame = CGRectMake(0, 0, menuUIWidth, menuUIHeight);
    controller.view.backgroundColor = [UIColor whiteColor];
    controller.view.layer.borderColor = [UIColor blackColor].CGColor;
    controller.view.layer.borderWidth = 4;
    if(_linkTxtView == nil){
        float space = 17;
        _linkTxtView = [[UITextView alloc] initWithFrame:CGRectMake(space, space-2, menuUIWidth-space*2, menuUIHeight-space*2)];
        NSMutableParagraphStyle *paraStyle01 = [[NSMutableParagraphStyle alloc] init];
        paraStyle01.lineSpacing = 4;
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"买手店暂未同意订单关联\n可至原始订单中，重新关联买手店",nil) attributes:@{NSParagraphStyleAttributeName:paraStyle01}];
        [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:13] range:[[attributedString string] rangeOfString:[attributedString string]]];
        [attributedString addAttribute:NSLinkAttributeName
                                 value:@"type://serviceAgreement"
                                 range:[[attributedString string] rangeOfString:NSLocalizedString(@"原始订单",nil)]];

        [attributedString addAttribute:NSUnderlineStyleAttributeName
                                 value: @(NSUnderlineStyleSingle)
                                 range:[[attributedString string] rangeOfString:NSLocalizedString(@"原始订单",nil)]];

        NSDictionary *linkAttributes = @{NSForegroundColorAttributeName: [UIColor blackColor],
                                         NSUnderlineColorAttributeName: [UIColor blackColor],
                                         NSUnderlineStyleAttributeName: @(NSUnderlinePatternSolid)};

        _linkTxtView.linkTextAttributes = linkAttributes; // customizes the appearance of links
        _linkTxtView.attributedText = attributedString;
        _linkTxtView.delegate = self;
        _linkTxtView.textColor = [UIColor colorWithHex:@"919191"];
        _linkTxtView.editable = NO;
        _linkTxtView.font = [UIFont systemFontOfSize:13];
    }
    [controller.view addSubview:_linkTxtView];

    UIPopoverController *popController = [[UIPopoverController alloc] initWithContentViewController:controller];
    UIViewController *parent = _parentController;
    self.popController = popController;
    CGPoint p = [_connStatusHelpBtn convertPoint:CGPointMake(44, 22) toView:parent.view];
    CGRect rc = CGRectMake(p.x-10, p.y+0, 0, 0);
    popController.popoverContentSize = CGSizeMake(menuUIWidth,menuUIHeight);
    popController.popoverBackgroundViewClass = [YYPopoverArrowBackgroundView class];
    [popController presentPopoverFromRect:rc inView:parent.view permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
}

#pragma mark - --------------自定义方法----------------------

+(NSInteger) getCellHeight:(NSString *)desc{
    NSInteger txtWidth = SCREEN_WIDTH - 580;
    NSInteger textHeight = 0;
    if([desc isEqualToString:@""]){
        textHeight = 0;
    }else{
        textHeight = getTxtHeight(txtWidth, desc, @{NSFontAttributeName:[UIFont systemFontOfSize:15]});
    }
    return 305 + textHeight - 34 + 63;
}

#pragma mark - --------------other----------------------


@end

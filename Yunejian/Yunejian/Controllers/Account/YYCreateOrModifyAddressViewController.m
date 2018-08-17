//
//  YYCreateOrModifyAddressViewController.m
//  Yunejian
//
//  Created by yyj on 15/7/20.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import "YYCreateOrModifyAddressViewController.h"

// c文件 —> 系统文件（c文件在前）

// 控制器

// 自定义视图
#import "MBProgressHUD.h"
#import "YYCountryPickView.h"

// 接口
#import "YYUserApi.h"
#import "YYOrderApi.h"

// 分类

// 自定义类和三方类（ cocoapods类 > model > 工具类 > 其他）
#import "UserDefaultsMacro.h"
#import "YYRspStatusAndMessage.h"

#import "YYAddress.h"
#import "YYOrderInfoModel.h"
#import "YYCountryListModel.h"
#import "YYBuyerAddressModel.h"

#import "regular.h"
#import "YYVerifyTool.h"

@interface YYCreateOrModifyAddressViewController ()<UITextFieldDelegate,YYCountryPickViewDelegate,UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *phoneField;
@property (weak, nonatomic) IBOutlet UIButton *cityButton;//不赋值 拉过来为了加个边框
@property (weak, nonatomic) IBOutlet UILabel *cityLabel;
@property (weak, nonatomic) IBOutlet UIButton *countryButton;//不赋值 拉过来为了加个边框
@property (weak, nonatomic) IBOutlet UILabel *countryLabel;
@property (weak, nonatomic) IBOutlet UITextField *postCodeField;

@property (weak, nonatomic) IBOutlet UITextView *detailAddressField;

@property (weak, nonatomic) IBOutlet UILabel *receiverAddressLabel;

@property (weak, nonatomic) IBOutlet UILabel *billAddressLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *receiverNameTopLayoutConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *yellowViewHeightLayoutConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *yellowViewTopLayoutConstraint;
@property (weak, nonatomic) IBOutlet UIView *yellowView;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UIView *whiteView;

@property (weak, nonatomic) IBOutlet UIButton *defaultReceiveButton;//默认收件地址
@property (weak, nonatomic) IBOutlet UIButton *defaultBillingButton;//默认发票地址

@property (nonatomic, assign) BOOL isDefaultReceive;
@property (nonatomic, assign) BOOL isDefaultBilling;

@property (nonatomic, strong) YYCountryListModel *countryInfo;
@property (nonatomic, strong) YYCountryListModel *provinceInfo;
@property (nonatomic, strong) YYCountryPickView *countryPickerView;
@property (nonatomic, strong) YYCountryPickView *provincePickerView;
@property (nonatomic, assign) NSUInteger currentProvinceIndex;
@property (nonatomic, strong) NSString *currentNation;
@property (nonatomic, strong) NSNumber *currentNationID;
@property (nonatomic, strong) NSString *currentProvinece;
@property (nonatomic, strong) NSNumber *currentProvineceID;
@property (nonatomic, strong) NSString *currentCity;
@property (nonatomic, strong) NSNumber *currentCityID;

@property (nonatomic, assign) BOOL provinceIsChanged;

@end

@implementation YYCreateOrModifyAddressViewController
#pragma mark - --------------生命周期--------------
- (void)viewDidLoad {
    [super viewDidLoad];
    [self SomePrepare];
    [self updateUI];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
#pragma mark - --------------SomePrepare--------------
-(void)SomePrepare
{
    [self PrepareData];
    [self PrepareUI];
}
-(void)PrepareData{}
-(void)PrepareUI{
    _provinceIsChanged = NO;

    _nameField.layer.borderWidth = 1;
    _nameField.layer.borderColor = [[UIColor colorWithHex:@"EFEFEF"] CGColor];
    _nameField.layer.cornerRadius = 3.0f;

    _phoneField.layer.borderWidth = 1;
    _phoneField.layer.borderColor = [[UIColor colorWithHex:@"EFEFEF"] CGColor];
    _phoneField.layer.cornerRadius = 3.0f;

    _cityButton.layer.borderWidth = 1;
    _cityButton.layer.borderColor = [[UIColor colorWithHex:@"EFEFEF"] CGColor];
    _cityButton.layer.cornerRadius = 3.0f;

    _countryButton.layer.borderWidth = 1;
    _countryButton.layer.borderColor = [[UIColor colorWithHex:@"EFEFEF"] CGColor];
    _countryButton.layer.cornerRadius = 3.0f;

    _detailAddressField.layer.borderWidth = 1;
    _detailAddressField.layer.borderColor = [[UIColor colorWithHex:@"EFEFEF"] CGColor];
    _detailAddressField.layer.cornerRadius = 3.0f;

    _postCodeField.layer.borderWidth = 1;
    _postCodeField.layer.borderColor = [[UIColor colorWithHex:@"EFEFEF"] CGColor];
    _postCodeField.layer.cornerRadius = 3.0f;

    _postCodeField.keyboardType = UIKeyboardTypeNumberPad;
    _phoneField.keyboardType = UIKeyboardTypeNumberPad;

    _nameField.delegate = self;
    _phoneField.delegate = self;
    _postCodeField.delegate = self;
    _detailAddressField.delegate = self;

    popWindowAddBgView(self.view);
}

//#pragma mark - --------------UIConfig----------------------
//- (void)UIConfig {
//
//}
//
//#pragma mark - --------------请求数据----------------------
//- (void)RequestData {
//
//}
//
//#pragma mark - --------------系统代理----------------------


#pragma mark - --------------自定义代理/block----------------------
#pragma mark YYpickViewDelegate

-(void)toobarDonBtnHaveCountryClick:(YYCountryPickView *)pickView resultString:(NSString *)resultString{
    if(pickView == _countryPickerView){
        //        选择了国家 判断是不是切换了国家  切换了重置省 城市
        NSArray *countryArr = [resultString componentsSeparatedByString:@"/"];
        if(countryArr.count > 1){
            if([self.currentNationID integerValue] != [countryArr[1] integerValue]){
                //切换了初始化
                [self initProvinceCityData];
                //更新国家信息
                self.currentNation = countryArr[0];
                self.currentNationID = @([countryArr[1] integerValue]);
                NSLog(@"111");
            }
        }else{
            //切换了初始化
            [self initCountryData];
            [self initProvinceCityData];
        }
        NSLog(@"\ncurrentNation = %@ currentNationID = %ld \n currentProvinece = %@ currentProvineceID = %ld \n currentCity = %@ currentCityID = %ld \n",_currentNation,[_currentNationID integerValue],_currentProvinece,[_currentProvineceID integerValue],_currentCity,[_currentCityID integerValue]);
        //打开城市选择器
        id obj;
        [self provinecesAndCityButtonClicked:obj];

    }else if(pickView == _provincePickerView){
        NSArray *provinceCityArr = [resultString componentsSeparatedByString:@","];
        if(provinceCityArr.count){
            NSArray * provinceArr = [provinceCityArr[0] componentsSeparatedByString:@"/"];
            if(provinceArr.count > 1){
                self.currentProvinece = provinceArr[0];
                self.currentProvineceID = @([provinceArr[1] integerValue]);
            }else{
                [self initProvinceData];
            }

            if(provinceCityArr.count > 1){

                NSArray * cityArr = [provinceCityArr[1] componentsSeparatedByString:@"/"];
                if(cityArr.count > 1){
                    self.currentCity = cityArr[0];
                    self.currentCityID = @([cityArr[1] integerValue]);
                }else{
                    [self initCityData];
                }
            }else{
                [self initCityData];
            }
        }
        [self updateCountryView];

    }
}

#pragma mark - --------------自定义响应----------------------
- (IBAction)countryButtonClicked:(id)sender {
    [_provincePickerView removeNoBlock];
    [regular dismissKeyborad];

    if(!_countryInfo){
        WeakSelf(ws);
        [YYUserApi getCountryInfoWithBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYCountryListModel *countryListModel, NSError *error) {
            if (rspStatusAndMessage.status == YYReqStatusCode100) {
                ws.countryInfo = countryListModel;

                if(ws.countryInfo.result.count){
                    ws.countryPickerView=[[YYCountryPickView alloc] initPickviewWithCountryArray:ws.countryInfo.result WithPlistType:CountryPickView isHaveNavControler:NO];
                    ws.countryPickerView.delegate = ws;
                    [ws.countryPickerView show:ws.view];
                }
            }
        }];
    }else{
        [_countryPickerView show:self.view];
    }
}
- (IBAction)provinecesAndCityButtonClicked:(id)sender{
    [_countryPickerView removeNoBlock];
    [regular dismissKeyborad];

    if(!_provinceInfo){
        WeakSelf(ws);
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [YYUserApi getSubCountryInfoWithCountryID:[_currentNationID integerValue] WithBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYCountryListModel *countryListModel, NSInteger impId,NSError *error) {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            if (rspStatusAndMessage.status == YYReqStatusCode100) {
                if(countryListModel.result.count){
                    ws.provinceInfo = countryListModel;
                }else{
                    YYCountryModel *TempModel = [[YYCountryModel alloc] init];
                    TempModel.impId = @(-1);
                    TempModel.name = @"-";
                    TempModel.nameEn = @"-";
                    countryListModel.result = [NSArray arrayWithObject:TempModel];
                    ws.provinceInfo = countryListModel;
                }

                if(ws.provinceInfo.result.count){
                    ws.provincePickerView=[[YYCountryPickView alloc] initPickviewWithCountryArray:ws.provinceInfo.result WithPlistType:SubCountryPickView isHaveNavControler:NO];
                    ws.provincePickerView.delegate = ws;
                    [ws.provincePickerView show:ws.view];
                }
            }
        }];
    }else{
        [_provincePickerView show:self.view];
    }
}

- (IBAction)defaultBillingClicked:(id)sender{
    _isDefaultBilling = !_isDefaultBilling;
    [self updateDefaultButton];
}

- (IBAction)defaultReceiveClicked:(id)sender{
    _isDefaultReceive = !_isDefaultReceive;
    [self updateDefaultButton];
}
- (IBAction)cancelClicked:(id)sender{
    if (_cancelButtonClicked) {
        _cancelButtonClicked();
    }
}
- (IBAction)saveClicked:(id)sender{

    NSString *receiveName = trimWhitespaceOfStr(_nameField.text);
    NSString *receivePhone = trimWhitespaceOfStr(_phoneField.text);
    NSString *postCode = trimWhitespaceOfStr(_postCodeField.text);

    NSString *detailAddress = trimWhitespaceOfStr(_detailAddressField.text);

    UIView *customView = nil;
    if (_currentOperationType == OperationTypeHelpCreate) {
        customView = self.view;
    }

    if (! receiveName || [receiveName length] == 0) {
        [YYToast showToastWithView:customView title:NSLocalizedString(@"请输入收件人姓名",nil) andDuration:kAlertToastDuration];
        return;
    }

    if (! postCode || [postCode length] == 0) {
        [YYToast showToastWithView:customView title:NSLocalizedString(@"请输入邮编",nil) andDuration:kAlertToastDuration];
        return;
    }

    if (! detailAddress || [detailAddress length] == 0) {
        [YYToast showToastWithView:customView title:NSLocalizedString(@"请输入详细地址",nil) andDuration:kAlertToastDuration];
        return;
    }

    if(![_currentNationID integerValue]){
        [YYToast showToastWithView:customView title:NSLocalizedString(@"请选择国家",nil) andDuration:kAlertToastDuration];
        return;
    }

    //如果手机号码没有满足正确格式
    //中国 11 位数效验正确性  其他国家 6-20（中国 11位纯数字 国外 6-20位纯数字）
    BOOL _isValidPhone = [YYVerifyTool internationalPhoneVerify:receivePhone WithCountryCode:[_currentNationID integerValue]];
    if(!_isValidPhone){
        [YYToast showToastWithView:customView title:NSLocalizedString(@"手机号码格式错误",nil) andDuration:kAlertToastDuration];
        return;
    }

    if(_currentOperationType != OperationTypeModify){
        if ((![_currentProvineceID integerValue]) && (![_currentCityID integerValue])) {
            [YYToast showToastWithView:customView title:NSLocalizedString(@"请选择省市",nil) andDuration:kAlertToastDuration];
            return;
        }
    }

    YYAddress *nowAddress = [[YYAddress alloc] init];
    if ([_address.addressId integerValue]) {
        nowAddress.addressId = _address.addressId;
    }

    nowAddress.receiverName = receiveName;
    nowAddress.receiverPhone = receivePhone;
    nowAddress.zipCode = postCode;
    nowAddress.detailAddress = detailAddress;//[NSString stringWithFormat:@"%@%@%@",_currentProvinece,_currentCity,detailAddress];

    nowAddress.nation = _currentNation;
    nowAddress.province = _currentProvinece;
    nowAddress.city = _currentCity;

    nowAddress.nationEn = _currentNation;
    nowAddress.provinceEn = _currentProvinece;
    nowAddress.cityEn = _currentCity;

    nowAddress.nationId = _currentNationID;
    nowAddress.provinceId = _currentProvineceID;
    nowAddress.cityId = _currentCityID;

    nowAddress.defaultBilling = _isDefaultBilling;
    nowAddress.defaultShipping = _isDefaultReceive;

    WeakSelf(ws);
    __block YYAddress *blockAddress = nowAddress;

    if (_currentOperationType == OperationTypeHelpCreate) {

        if (![YYNetworkReachability connectedToNetwork]) {
            if (self.currentYYOrderInfoModel.shareCode
                && !self.currentYYOrderInfoModel.orderCode) {
                //把创建地址，先保存到NSUserDefaults中
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                NSString *tempKey = [NSString stringWithFormat:@"%@%@",self.currentYYOrderInfoModel.shareCode,kOfflineOrderAddressSuffix];
                [userDefaults setObject:[NSKeyedArchiver archivedDataWithRootObject:nowAddress] forKey:tempKey];
                [userDefaults synchronize];
            }
            if (ws.addressForBuyerButtonClicked) {
                ws.addressForBuyerButtonClicked(blockAddress);
            }
            blockAddress = nil;
        }else{
            [YYOrderApi createOrModifyAddress:nowAddress andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYBuyerAddressModel *addressModel, NSError *error) {
                if (rspStatusAndMessage.status == YYReqStatusCode100
                    && addressModel
                    && addressModel.addressId){
                    if (ws.addressForBuyerButtonClicked) {
                        blockAddress.addressId = addressModel.addressId;
                        ws.addressForBuyerButtonClicked(blockAddress);
                    }
                }
                blockAddress = nil;
            }];
        }
    }else{
        [YYUserApi createOrModifyAddress:nowAddress andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSError *error) {
            if (rspStatusAndMessage.status == YYReqStatusCode100) {
                [YYToast showToastWithView:customView title:NSLocalizedString(@"操作成功！",nil) andDuration:kAlertToastDuration];
                if (ws.modifySuccess) {
                    ws.modifySuccess();
                }
            }else{
                [YYToast showToastWithTitle:rspStatusAndMessage.message andDuration:kAlertToastDuration];
            }
        }];
    }
}

#pragma mark - --------------自定义方法----------------------
#pragma mark updateUI
- (void)updateUI{
    if (_currentOperationType == OperationTypeModify) {
        _titleLabel.text = NSLocalizedString(@"修改收件地址",nil);
        [self setShowValue];
    }else if(_currentOperationType == OperationTypeCreate){
        _titleLabel.text = NSLocalizedString(@"新建收件地址",nil);
        [self setDefaultCountry];
    }else if(_currentOperationType == OperationTypeHelpCreate){
        _defaultBillingButton.hidden = YES;
        _defaultReceiveButton.hidden = YES;
        _receiverAddressLabel.hidden = YES;
        _billAddressLabel.hidden = YES;

        _receiverNameTopLayoutConstraint.constant = 32;

        if (![NSString isNilOrEmpty:_address.receiverName]) {
            _titleLabel.text = NSLocalizedString(@"修改买手店地址",nil);
            [self setShowValue];
        }else{
            _titleLabel.text = NSLocalizedString(@"添加买手店地址",nil);
            [self setDefaultCountry];
        }
    }
}

- (void)updateDefaultButton{
    NSString *normalImage = @"confirm_normal.png";
    NSString *selectedImage = @"confirm_selected.png";

    if (_isDefaultBilling) {
        [_defaultBillingButton setImage:[UIImage imageNamed:selectedImage] forState:UIControlStateNormal];
    }else{
        [_defaultBillingButton setImage:[UIImage imageNamed:normalImage] forState:UIControlStateNormal];
    }

    if (_isDefaultReceive) {
        [_defaultReceiveButton setImage:[UIImage imageNamed:selectedImage] forState:UIControlStateNormal];
    }else{
        [_defaultReceiveButton setImage:[UIImage imageNamed:normalImage] forState:UIControlStateNormal];
    }
}

-(void)updateCountryView{

    NSString *titleStr = @"";
    if(![NSString isNilOrEmpty:_currentNation]){
        titleStr = _currentNation;
    }
    _countryLabel.text = titleStr;

    NSString *temptitleStr = @"";
    if(![NSString isNilOrEmpty:_currentProvinece]){
        if(![NSString isNilOrEmpty:_currentCity]){
            temptitleStr = [[NSString alloc] initWithFormat:@"%@,%@",_currentProvinece,_currentCity];
        }else{
            temptitleStr = _currentProvinece;
        }
    }
    _cityLabel.text = temptitleStr;
}

#pragma mark Setter
-(void)setAddress:(YYAddress *)address{
    if(address){
        _address = address;
    }else{
        _address = [[YYAddress alloc] init];
        _address.nation = @"中国";
        _address.nationEn = @"China";
        _address.nationId = @(721);
    }
}
- (void)setShowValue{
    if (![NSString isNilOrEmpty:_address.receiverName]) {
        if (_address.receiverName) {
            _nameField.text = _address.receiverName;
        }

        if (_address.receiverPhone) {
            _phoneField.text = _address.receiverPhone;
        }

        if ([_address.nationId integerValue]) {

            self.currentNation = [LanguageManager isEnglishLanguage]?_address.nationEn:_address.nation;
            self.currentNationID = _address.nationId;
        }

        NSString *proviceAndCity = @"";
        if ([_address.provinceId integerValue]) {
            NSString *proviceStr = [LanguageManager isEnglishLanguage]?_address.provinceEn:_address.province;
            proviceAndCity = [proviceAndCity stringByAppendingString:proviceStr];
            self.currentProvinece = proviceStr;
            self.currentProvineceID = _address.provinceId;
        }
        if([_address.nationId integerValue]){
            if([NSString isNilOrEmpty:proviceAndCity]){
                proviceAndCity = @"-";
            }
        }

        if ([_address.cityId integerValue]) {
            NSString *cityStr = [LanguageManager isEnglishLanguage]?_address.cityEn:_address.city;
            if ([proviceAndCity length] > 0) {
                proviceAndCity = [proviceAndCity stringByAppendingString:@","];
            }
            proviceAndCity = [proviceAndCity stringByAppendingString:cityStr];
            self.currentCity = cityStr;
            self.currentCityID = _address.cityId;
        }

        _cityLabel.text = proviceAndCity;
        _countryLabel.text = self.currentNation;

        if (_address.zipCode) {
            _postCodeField.text = _address.zipCode;
        }

        if (_address.detailAddress) {
            _detailAddressField.text = _address.detailAddress;
        }

        self.isDefaultBilling = _address.defaultBilling;
        self.isDefaultReceive = _address.defaultShipping;

        [self updateDefaultButton];

    }
}
//确保只在符合的状态下进入该逻辑
-(void)setDefaultCountry{

    if (_currentOperationType == OperationTypeModify) {

    }else if(_currentOperationType == OperationTypeCreate){

        if ([_address.nationId integerValue]) {

            self.currentNation = [LanguageManager isEnglishLanguage]?_address.nationEn:_address.nation;
            self.currentNationID = _address.nationId;
        }
        _countryLabel.text = self.currentNation;

    }else if(_currentOperationType == OperationTypeHelpCreate){

        if (![NSString isNilOrEmpty:_address.receiverName]) {

        }else{

            if ([_address.nationId integerValue]) {

                self.currentNation = [LanguageManager isEnglishLanguage]?_address.nationEn:_address.nation;
                self.currentNationID = _address.nationId;
            }
            _countryLabel.text = self.currentNation;

        }
    }
}
#pragma mark Init
-(void)initProvinceCityData{
    _provinceInfo = nil;
    _currentProvinece = @"";
    _currentCity = @"";
    _currentProvineceID = @(0);
    _currentCityID = @(0);
}
-(void)initProvinceData{
    _currentProvinece = @"";
    _currentProvineceID = @(0);
}
-(void)initCityData{
    _currentCity = @"";
    _currentCityID = @(0);
}
-(void)initCountryData{
    _currentNation = @"";
    _currentNationID = @(0);
}
#pragma mark - --------------other----------------------

@end

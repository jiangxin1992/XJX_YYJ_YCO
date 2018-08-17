//
//  YYDeliverCustomCell.m
//  yunejianDesigner
//
//  Created by yyj on 2018/6/19.
//  Copyright © 2018年 Apple. All rights reserved.
//

#import "YYDeliverCustomCell.h"

// c文件 —> 系统文件（c文件在前）

// 控制器

// 自定义视图

// 接口

// 分类
#import "UIImage+Tint.h"

// 自定义类和三方类（ cocoapods类 > model > 工具类 > 其他）
#import "YYDeliverModel.h"

#import "YYVerifyTool.h"

@interface YYDeliverCustomCell()<UITextFieldDelegate>

@property (nonatomic, strong) UILabel *deliverTitleLabel;

@property (nonatomic, strong) UIButton *deliverBackView;

@property (nonatomic, strong) UITextField *deliverTextField;

@property (nonatomic, strong) UILabel *receiverLabel;
@property (nonatomic, strong) UILabel *receiverPhoneLabel;
@property (nonatomic, strong) UILabel *receiverAddressLabel;

@property (nonatomic, strong) UIButton *deliverRightButton;

@property(nonatomic,copy) void (^deliverCustomCellBlock)(NSString *type, NSString *value);

@end

@implementation YYDeliverCustomCell

#pragma mark - --------------生命周期--------------
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier WithBlock:(void(^)(NSString *type, NSString *value))block{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        _deliverCustomCellBlock = block;
        [self SomePrepare];
        [self UIConfig];
    }
    return self;
}
- (void)awakeFromNib {
    [super awakeFromNib];
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
    self.contentView.backgroundColor = _define_white_color;
}

#pragma mark - --------------UIConfig----------------------
-(void)UIConfig{

    WeakSelf(ws);

    _deliverTitleLabel = [UILabel getLabelWithAlignment:0 WithTitle:nil WithFont:14.f WithTextColor:_define_black_color WithSpacing:0];
    [self.contentView addSubview:_deliverTitleLabel];
    [_deliverTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(40);
        make.bottom.mas_equalTo(0);
        make.top.mas_equalTo(30);
    }];

    _deliverBackView = [UIButton getCustomBtn];
    [self.contentView addSubview:_deliverBackView];
    [_deliverBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(30);
        make.bottom.mas_equalTo(0);
        make.left.mas_equalTo(174);
        make.right.mas_equalTo(-254);
    }];
    _deliverBackView.backgroundColor = [UIColor colorWithHex:@"F8F8F8"];
    [_deliverBackView addTarget:self action:@selector(deliverAction:) forControlEvents:UIControlEventTouchUpInside];

    _deliverTextField = [UITextField getTextFieldWithPlaceHolder:nil WithAlignment:0 WithFont:14.f WithTextColor:_define_black_color WithLeftWidth:0 WithRightWidth:0 WithSecureTextEntry:NO HaveBorder:NO WithBorderColor:nil];
    [_deliverBackView addSubview:_deliverTextField];
    [_deliverTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-44);
        make.left.mas_equalTo(5);
        make.top.bottom.mas_equalTo(0);
    }];
    _deliverTextField.delegate = self;
    _deliverTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    _deliverTextField.returnKeyType = UIReturnKeyDone;

    _receiverLabel = [UILabel getLabelWithAlignment:0 WithTitle:nil WithFont:14.f WithTextColor:nil WithSpacing:0];
    [_deliverBackView addSubview:_receiverLabel];
    [_receiverLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-44);
        make.top.mas_equalTo(15);
    }];
    _receiverLabel.font = getSemiboldFont(14.f);

    _receiverPhoneLabel = [UILabel getLabelWithAlignment:0 WithTitle:nil WithFont:12.f WithTextColor:nil WithSpacing:0];
    [_deliverBackView addSubview:_receiverPhoneLabel];
    [_receiverPhoneLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-44);
        make.top.mas_equalTo(ws.receiverLabel.mas_bottom).with.offset(5);
    }];

    _receiverAddressLabel = [UILabel getLabelWithAlignment:0 WithTitle:nil WithFont:12.f WithTextColor:nil WithSpacing:0];
    [_deliverBackView addSubview:_receiverAddressLabel];
    [_receiverAddressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-44);
        make.top.mas_equalTo(ws.receiverPhoneLabel.mas_bottom).with.offset(5);
        make.bottom.mas_equalTo(-15);
    }];
    _receiverAddressLabel.numberOfLines = 0;

    _deliverRightButton = [UIButton getCustomImgBtnWithImageStr:nil WithSelectedImageStr:nil];
    [_deliverBackView addSubview:_deliverRightButton];
    [_deliverRightButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.top.bottom.mas_equalTo(0);
        make.left.mas_equalTo(ws.deliverTextField.mas_right).with.offset(0);
    }];
    [_deliverRightButton addTarget:self action:@selector(scanAction) forControlEvents:UIControlEventTouchUpInside];
    _deliverRightButton.userInteractionEnabled = NO;
}

#pragma mark - --------------UpdateUI----------------------
-(void)updateUI{
    if(_deliverCellType == YYDeliverCellTypeReceiverAddress){
        BOOL isValidAddress = [_deliverModel isValidAddressWithBuyerStockEnabled:[_buyerStockEnabled boolValue]];
        if(isValidAddress){
            _deliverTextField.hidden = YES;
            _receiverLabel.hidden = NO;
            _receiverPhoneLabel.hidden = NO;
            _receiverAddressLabel.hidden = NO;

            if([_buyerStockEnabled boolValue]){
                _receiverLabel.text = _deliverModel.warehouseName;
                _receiverPhoneLabel.text = [[NSString alloc] initWithFormat:@"%@ %@",_deliverModel.receiver,_deliverModel.receiverPhone];
            }else{
                _receiverLabel.text = _deliverModel.receiver;
                _receiverPhoneLabel.text = _deliverModel.receiverPhone;
            }
            _receiverAddressLabel.text = _deliverModel.receiverAddress;

            return;
        }
    }

    _deliverTextField.hidden = NO;
    _receiverLabel.hidden = YES;
    _receiverPhoneLabel.hidden = YES;
    _receiverAddressLabel.hidden = YES;
    NSString *deliverTitleStr = nil;
    NSString *deliverPlaceholderStr = nil;
    NSString *deliverFieldStr = nil;
    UIImage *deliverRightImg = nil;
    if(_deliverCellType == YYDeliverCellTypeReceiverAddress){
        //收件地址
        deliverTitleStr = NSLocalizedString(@"收件地址 *", nil);
        if([_buyerStockEnabled boolValue]){
            deliverPlaceholderStr = NSLocalizedString(@"请选择收件地址", nil);
        }else{
            deliverPlaceholderStr = NSLocalizedString(@"请编辑收件地址", nil);
        }
        deliverRightImg = [[UIImage imageNamed:@"right_arrow"] imageWithTintColor:_define_black_color];
        _deliverTextField.userInteractionEnabled = NO;
        _deliverRightButton.userInteractionEnabled = NO;
    }else if(_deliverCellType == YYDeliverCellTypeLogisticsName){
        //物流公司
        deliverTitleStr = NSLocalizedString(@"物流公司 *", nil);
        deliverPlaceholderStr = NSLocalizedString(@"请选择物流公司", nil);
        deliverRightImg = [[UIImage imageNamed:@"right_arrow"] imageWithTintColor:_define_black_color];
        deliverFieldStr = _deliverModel.logisticsName;
        _deliverTextField.userInteractionEnabled = NO;
        _deliverRightButton.userInteractionEnabled = NO;
    }else if(_deliverCellType == YYDeliverCellTypeLogisticsCode){
        //物流单号
        deliverTitleStr = NSLocalizedString(@"物流单号 *", nil);
        deliverPlaceholderStr = NSLocalizedString(@"请填写或扫描物流单号", nil);
        deliverRightImg = [UIImage imageNamed:@"scan_deliver_icon"];
        deliverFieldStr = _deliverModel.logisticsCode;
        _deliverTextField.userInteractionEnabled = YES;
        _deliverRightButton.userInteractionEnabled = YES;
    }

    CGFloat titleWidth = getWidthWithHeight(30, deliverTitleStr, getFont(14.f));
    [_deliverTitleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(titleWidth);
    }];
    _deliverTitleLabel.text = deliverTitleStr;
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:deliverPlaceholderStr attributes:
                                      @{NSForegroundColorAttributeName:_deliverCellType == YYDeliverCellTypeLogisticsCode?[UIColor colorWithHex:@"AFAFAF"]:_define_black_color,
                                        NSFontAttributeName:_deliverTitleLabel.font
                                        }];
    _deliverTextField.attributedPlaceholder = attrString;
    _deliverTextField.text = deliverFieldStr;
    [_deliverRightButton setImage:deliverRightImg forState:UIControlStateNormal];

}

#pragma mark - --------------系统代理----------------------
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if(_deliverCellType == YYDeliverCellTypeReceiverAddress){
        //收件地址
        return NO;
    }else if(_deliverCellType == YYDeliverCellTypeLogisticsName){
        //物流公司
        return NO;
    }else if(_deliverCellType == YYDeliverCellTypeLogisticsCode){
        //物流单号
        return YES;
    }
    return NO;
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [_deliverTextField resignFirstResponder];
    return YES;
}
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{

    BOOL returnValue = NO;
    NSString *message = NSLocalizedString(@"您输入的快递单号有误！",nil);
    NSString *str = [textField.text stringByReplacingCharactersInRange:range withString:string];

    if (![NSString isNilOrEmpty:str]) {
        if([YYVerifyTool inputShouldLetterOrNum:str]){
            return YES;
        }
    }else{
        message = nil;
        textField.text = nil;
    }
    if (![NSString isNilOrEmpty:message] && !returnValue) {
        [YYToast showToastWithView:self title:message andDuration:kAlertToastDuration];
    }
    return returnValue;
}
- (void)textFieldDidEndEditing:(UITextField *)textField{

    if(_deliverCustomCellBlock){
        _deliverCustomCellBlock(@"logisticsCode",textField.text);
    }

}
#pragma mark - --------------自定义响应----------------------
-(void)deliverAction:(UIButton *)sender{
    if(_deliverCellType == YYDeliverCellTypeReceiverAddress){
        //收件地址
        if(_deliverCustomCellBlock){
            _deliverCustomCellBlock(@"chooseReceiverAddress",nil);
        }
    }else if(_deliverCellType == YYDeliverCellTypeLogisticsName){
        //物流公司
        if(_deliverCustomCellBlock){
            _deliverCustomCellBlock(@"chooseLogistics",nil);
        }
    }
}
-(void)scanAction{
    if(_deliverCustomCellBlock){
        _deliverCustomCellBlock(@"scan",nil);
    }
}
#pragma mark - --------------自定义方法----------------------


#pragma mark - --------------other----------------------


@end

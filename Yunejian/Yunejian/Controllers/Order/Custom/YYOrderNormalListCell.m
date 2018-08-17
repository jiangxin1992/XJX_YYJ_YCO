//
//  YYOrderNormalListCell.m
//  Yunejian
//
//  Created by Apple on 15/8/17.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import "YYOrderNormalListCell.h"

// c文件 —> 系统文件（c文件在前）

// 控制器

// 自定义视图
#import "YYSupplyStatusView.h"
#import "YYTypeButton.h"

// 接口

// 分类
#import "UIImage+YYImage.h"

// 自定义类和三方类（ cocoapods类 > model > 工具类 > 其他）
#import "YYUser.h"
#import "YYOrderListItemModel.h"

@interface YYOrderNormalListCell ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelWidthLayout;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceTotalLabel;

@property (weak, nonatomic) IBOutlet UIView *statusView;
@property (weak, nonatomic) IBOutlet UIImageView *isAppendImg;

@property (weak, nonatomic) IBOutlet UILabel *orderStatusCloseTimeTipLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderStatusCloseTipLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentLayoutLeftConstraints;

@property (nonatomic ,strong) UIImageView *underLineView;

@property (weak, nonatomic) IBOutlet UILabel *hasGiveMoneyLabel;
@property (weak, nonatomic) IBOutlet YYTypeButton *moneyLogBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *moneyLogBtnLayoutTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *statusTipLabel;

@property (weak, nonatomic) IBOutlet YYTypeButton *orderStatusBtn;
@property (weak, nonatomic) IBOutlet UILabel *tranStatusLabel;
@property (weak, nonatomic) IBOutlet UIView *statusInfoLine;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tranStatusTagLeftLayoutConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomLineHeightLayoutConstraint;

@end

@implementation YYOrderNormalListCell

static NSInteger topConstraint = 15;
static NSInteger offsetConstraint = 40;
static NSInteger btnHeight = 30;

#pragma mark - --------------生命周期--------------
- (void)awakeFromNib {
    [super awakeFromNib];
    [self SomePrepare];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}
#pragma mark - SomePrepare
-(void)SomePrepare
{
    [self PrepareData];
    [self PrepareUI];
}
-(void)PrepareData{}
-(void)PrepareUI{
    _orderStatusBtn.layer.borderWidth = 1;
    _orderStatusBtn.layer.borderColor = _define_black_color.CGColor;
    _orderStatusBtn.layer.cornerRadius = 2.5;
    _orderStatusBtn.layer.masksToBounds = YES;

    _moneyLogBtn.layer.borderWidth = 1;
    _moneyLogBtn.layer.borderColor = _define_black_color.CGColor;
    _moneyLogBtn.layer.cornerRadius = 2.5;
    _moneyLogBtn.layer.masksToBounds = YES;

    _statusTipLabel.font = [UIFont systemFontOfSize:[LanguageManager isEnglishLanguage]?12.0f:13.0f];
}
#pragma mark - updateUI
- (void)updateUI{
    _isAppendImg.image = [UIImage imageNamed:[LanguageManager isEnglishLanguage]?@"isappend_img_en":@"isappend_img"];

    _tranStatusTagLeftLayoutConstraint.constant = 75;
    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    _bottomLineHeightLayoutConstraint.constant = 2/[[UIScreen mainScreen] scale];

    _moneyLogBtn.layer.borderWidth = 1;
    _moneyLogBtn.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6].CGColor;
    _moneyLogBtn.layer.contentsScale = 1/[UIScreen mainScreen].scale;

    if([_currentOrderListItemModel.isAppend integerValue]){
        _isAppendImg.hidden = NO;
    }else{
        _isAppendImg.hidden = YES;
    }

    BOOL _have_status = NO;
    if (_currentOrderListItemModel) {
        _priceTotalLabel.text = [NSString stringWithFormat:NSLocalizedString(@"订单号. %@  建单时间 %@",nil),_currentOrderListItemModel.orderCode,getShowDateByFormatAndTimeInterval(@"yyyy/MM/dd",[_currentOrderListItemModel.orderCreateTime stringValue])];
        if (_currentOrderListItemModel.styleAmount
            && _currentOrderListItemModel.itemAmount) {
            _countLabel.text = [NSString stringWithFormat:NSLocalizedString(@"总计%i款 %i件",nil),[_currentOrderListItemModel.styleAmount intValue],[_currentOrderListItemModel.itemAmount intValue]];
        }

        if (_currentOrderListItemModel.finalTotalPrice) {
            _countLabel.text = replaceMoneyFlag([NSString stringWithFormat:@"%@ ￥%.2f",_countLabel.text,[_currentOrderListItemModel.finalTotalPrice floatValue]],[_currentOrderListItemModel.curType integerValue]);
        }

        _statusInfoLine.hidden = YES;

        for (UIView *ui in [_statusView subviews]) {
            [ui removeFromSuperview];
        }

        NSInteger tranStatus = getOrderTransStatus(_currentOrderListItemModel.designerTransStatus, _currentOrderListItemModel.buyerTransStatus);

        if((tranStatus == kOrderCode_NEGOTIATION || tranStatus == kOrderCode_NEGOTIATION_DONE || tranStatus == kOrderCode_CONTRACT_DONE || tranStatus == kOrderCode_MANUFACTURE) && [_currentOrderListItemModel.closeReqStatus integerValue] != -1){
            if (_currentOrderListItemModel.supplyTime
                && [_currentOrderListItemModel.supplyTime count] > 0) {
                for (int i=0; i<[_currentOrderListItemModel.supplyTime count]; i++) {
                    _have_status = YES;
                    YYOrderSupplyTimeModel *orderSupplyTimeModel = [_currentOrderListItemModel.supplyTime objectAtIndex:i];
                    [self addAlineView:orderSupplyTimeModel andLineIndex:i];
                }
            }
        }

        _hasGiveMoneyLabel.hidden = NO;
        //状态
        _tranStatusLabel.text = getOrderStatusName_short(tranStatus);

        _statusTipLabel.hidden = YES;

        _orderStatusCloseTipLabel.hidden = YES;
        _orderStatusCloseTimeTipLabel.hidden = YES;

        _orderStatusBtn.layer.borderColor = _define_black_color.CGColor;
        _moneyLogBtn.layer.borderColor = _define_black_color.CGColor;
        _orderStatusBtn.type = nil;
        _moneyLogBtn.type = nil;

        if(tranStatus == kOrderCode_CLOSE_REQ || [_currentOrderListItemModel.closeReqStatus integerValue] == -1){
            //关闭请求

            if([_currentOrderListItemModel.closeReqStatus integerValue] == -1){
                _orderStatusCloseTipLabel.hidden = NO;
                _orderStatusCloseTipLabel.textColor = [UIColor redColor];
                _orderStatusCloseTipLabel.text = NSLocalizedString(@"对方申请了已取消，请及时处理",nil);
            }

            if([_currentOrderListItemModel.autoCloseHoursRemains integerValue]>0){

                NSInteger day = [_currentOrderListItemModel.autoCloseHoursRemains integerValue]/24;
                NSInteger hours = [_currentOrderListItemModel.autoCloseHoursRemains integerValue]%24;
                if(_orderStatusCloseTipLabel.hidden == NO){
                    _orderStatusCloseTimeTipLabel.hidden = NO;
                    _orderStatusCloseTimeTipLabel.text = [NSString stringWithFormat:NSLocalizedString(@"剩余%ld天%ld小时，交易将自动取消",nil),(long)day,(long)hours];
                }else{
                    _orderStatusCloseTipLabel.hidden = NO;
                    _orderStatusCloseTipLabel.textColor = [UIColor blackColor];
                    _orderStatusCloseTipLabel.text = [NSString stringWithFormat:NSLocalizedString(@"剩余%ld天%ld小时，交易将自动取消",nil),(long)day,(long)hours];
                }
            }

            _orderStatusBtn.hidden = YES;

            _moneyLogBtn.hidden = NO;
            _moneyLogBtn.backgroundColor = _define_white_color;
            [_moneyLogBtn setTitleColor:_define_black_color forState:UIControlStateNormal];
            _moneyLogBtn.layer.borderColor = [UIColor colorWithHex:@"d3d3d3"].CGColor;
            [_moneyLogBtn setTitle:NSLocalizedString(@"查看详情",nil) forState:UIControlStateNormal];
            _moneyLogBtn.type = @"orderInfo";
            _moneyLogBtnLayoutTopConstraint.constant = topConstraint;

        }else if(tranStatus == kOrderCode_NEGOTIATION){
            //已下单

            CGSize textSize = [_tranStatusLabel.text sizeWithAttributes:@{NSFontAttributeName:_tranStatusLabel.font}];
            _tranStatusTagLeftLayoutConstraint.constant = textSize.width +19;

            BOOL isDesignerConfrim = [_currentOrderListItemModel isDesignerConfrim];
            BOOL isBuyerConfrim = [_currentOrderListItemModel isBuyerConfrim];

            if(!isBuyerConfrim){
                if(!isDesignerConfrim){
                    //双方都未确认
                    _orderStatusBtn.hidden = NO;
                    NSInteger connectStatus = [_currentOrderListItemModel.connectStatus integerValue];
                    if(connectStatus == kOrderStatus1 || connectStatus == kOrderStatus || connectStatus == kOrderStatus3){
                        //关联成功 || 未入驻
                        _orderStatusBtn.backgroundColor = _define_black_color;
                        [_orderStatusBtn setTitleColor:_define_white_color forState:UIControlStateNormal];
                        [_orderStatusBtn setTitle:NSLocalizedString(@"确认订单", nil) forState:UIControlStateNormal];
                        _orderStatusBtn.type = @"confirmOrder";
                    }else{
                         //关联失败 || 关联中
                        _orderStatusBtn.backgroundColor = [UIColor colorWithHex:@"d3d3d3"];
                        _orderStatusBtn.layer.borderColor = [UIColor colorWithHex:@"d3d3d3"].CGColor;
                        [_orderStatusBtn setTitleColor:_define_white_color forState:UIControlStateNormal];
                        [_orderStatusBtn setTitle:NSLocalizedString(@"确认订单", nil) forState:UIControlStateNormal];
                        _orderStatusBtn.type = @"unconfirmOrder";
                    }

                    _moneyLogBtn.hidden = YES;
                }else{
                    //买手未确认
                    _orderStatusBtn.hidden = YES;

                    _moneyLogBtn.hidden = YES;

                    _statusTipLabel.hidden = NO;
                    _statusTipLabel.textColor = [UIColor colorWithHex:@"000000" alpha:0.6];
                    _statusTipLabel.text = NSLocalizedString(@"待买手确认", nil);
                }
            }else{
                if(!isDesignerConfrim){
                    //设计师未确认
                    _orderStatusBtn.hidden = NO;
                    NSInteger connectStatus = [_currentOrderListItemModel.connectStatus integerValue];
                    if(connectStatus == kOrderStatus1 || connectStatus == kOrderStatus || connectStatus == kOrderStatus3){
                        //关联成功 || 未入驻
                        _orderStatusBtn.backgroundColor = _define_black_color;
                        [_orderStatusBtn setTitleColor:_define_white_color forState:UIControlStateNormal];
                        [_orderStatusBtn setTitle:NSLocalizedString(@"确认订单", nil) forState:UIControlStateNormal];
                        _orderStatusBtn.type = @"confirmOrder";
                    }else{
                         //关联失败 || 关联中
                        _orderStatusBtn.backgroundColor = [UIColor colorWithHex:@"d3d3d3"];
                        _orderStatusBtn.layer.borderColor = [UIColor colorWithHex:@"d3d3d3"].CGColor;
                        [_orderStatusBtn setTitleColor:_define_white_color forState:UIControlStateNormal];
                        [_orderStatusBtn setTitle:NSLocalizedString(@"确认订单", nil) forState:UIControlStateNormal];
                        _orderStatusBtn.type = @"unconfirmOrder";
                    }

                    _moneyLogBtn.hidden = NO;
                    _moneyLogBtn.backgroundColor = _define_white_color;
                    [_moneyLogBtn setTitleColor:_define_black_color forState:UIControlStateNormal];
                    _moneyLogBtn.layer.borderColor = [UIColor colorWithHex:@"d3d3d3"].CGColor;
                    [_moneyLogBtn setTitle:NSLocalizedString(@"拒绝确认", nil) forState:UIControlStateNormal];
                    _moneyLogBtn.type = @"refuseOrder";
                }else{
                    //理论上不存在这种情况
                    _orderStatusBtn.hidden = YES;
                    _moneyLogBtn.hidden = YES;
                }
            }
        }else if(tranStatus == kOrderCode_NEGOTIATION_DONE || tranStatus == kOrderCode_CONTRACT_DONE){
            //已确认

            CGSize textSize = [_tranStatusLabel.text sizeWithAttributes:@{NSFontAttributeName:_tranStatusLabel.font}];
            _tranStatusTagLeftLayoutConstraint.constant = textSize.width +19;

            _orderStatusBtn.hidden = NO;
            _orderStatusBtn.backgroundColor = _define_black_color;
            [_orderStatusBtn setTitleColor:_define_white_color forState:UIControlStateNormal];
            [_orderStatusBtn setTitle:NSLocalizedString(@"已生产", nil) forState:UIControlStateNormal];
            _orderStatusBtn.type = @"status";

            _moneyLogBtn.hidden = YES;

        }else if(tranStatus == kOrderCode_MANUFACTURE){
            //已生产

            _orderStatusBtn.hidden = NO;
            _orderStatusBtn.backgroundColor = _define_black_color;
            [_orderStatusBtn setTitleColor:_define_white_color forState:UIControlStateNormal];
            [_orderStatusBtn setTitle:NSLocalizedString(@"已发货", nil) forState:UIControlStateNormal];
            _orderStatusBtn.type = @"status";

            _moneyLogBtn.hidden = YES;

        }else if(tranStatus == kOrderCode_DELIVERY){
            //已发货

            _statusTipLabel.hidden = NO;
            _statusTipLabel.textColor = [UIColor colorWithHex:@"000000" alpha:0.6];
            if([_currentOrderListItemModel.autoReceivedHoursRemains integerValue] > -1){
                NSInteger day = [_currentOrderListItemModel.autoReceivedHoursRemains integerValue]/24;
                NSInteger hours = [_currentOrderListItemModel.autoReceivedHoursRemains integerValue]%24;
                _statusTipLabel.text = [NSString stringWithFormat:NSLocalizedString(@"剩余%@将自动确认收货",nil),[NSString stringWithFormat:NSLocalizedString(@"%ld天%ld小时",nil),(long)day,(long)hours]];
            }else{
                _statusTipLabel.text = @"";
            }

            _orderStatusBtn.hidden = YES;

            _moneyLogBtn.hidden = YES;

        }else if(tranStatus == kOrderCode_RECEIVED){
            //已收货

            _orderStatusBtn.hidden = YES;

            _moneyLogBtn.hidden = YES;

            _statusTipLabel.hidden = NO;
            _statusTipLabel.textColor = [UIColor colorWithHex:@"000000" alpha:0.6];
            _statusTipLabel.text = NSLocalizedString(@"订单已完成",nil);

        }else if(tranStatus == kOrderCode_CANCELLED || tranStatus == kOrderCode_CLOSED){
            //已取消

            _hasGiveMoneyLabel.hidden = YES;

            _orderStatusBtn.hidden = NO;
            _orderStatusBtn.backgroundColor = _define_black_color;
            [_orderStatusBtn setTitleColor:_define_white_color forState:UIControlStateNormal];
            [_orderStatusBtn setTitle:NSLocalizedString(@"重新建立订单",nil) forState:UIControlStateNormal];
            _orderStatusBtn.type = @"reBuildOrder";

            _moneyLogBtn.hidden = NO;
            _moneyLogBtn.backgroundColor = _define_white_color;
            [_moneyLogBtn setTitleColor:_define_black_color forState:UIControlStateNormal];
            _moneyLogBtn.layer.borderColor = [UIColor colorWithHex:@"d3d3d3"].CGColor;
            [_moneyLogBtn setTitle:NSLocalizedString(@"删除",nil) forState:UIControlStateNormal];
            _moneyLogBtn.type = @"delete";
            _moneyLogBtnLayoutTopConstraint.constant = topConstraint+topConstraint+btnHeight;

        }

        //收款
        [self updateorderPayUI];

        //关联状态
        [self updateOrderConnStatusUI];

    }

    if(_have_status){
        _titleLabelWidthLayout.constant = SCREEN_WIDTH - 560 - 150 - 10 - 40;
    }else{
        _titleLabelWidthLayout.constant = 329;
    }
}


-(void)updateorderPayUI{
    _hasGiveMoneyLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%d%@货款已收",nil),[_currentOrderListItemModel.payNote integerValue],@"%"];
}

-(void)updateOrderConnStatusUI{
    if(_underLineView == nil){
        NSInteger cap = 4;
        _underLineView = [[UIImageView alloc] init];
        _underLineView.image = [[UIImage imageNamed:@"textunderline"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, cap, 0,0)];
        _underLineView.alpha = 0.5;
        [_titleLabel.superview addSubview:_underLineView];

    }
    _underLineView.hidden = YES;
    // 处理耗时操作的代码块...
    if (_currentOrderListItemModel) {
        NSMutableAttributedString *nameAttrStr = [[NSMutableAttributedString alloc] init];
        NSString * nameInfoStr = (_currentOrderListItemModel.buyerName?_currentOrderListItemModel.buyerName:@"");
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            //关联中 关联失效 未入住 status:0, 未确认，1，已确认，2，已拒绝, 3: 已解除合作
            NSInteger _currentOrderConnStatus = [_currentOrderListItemModel.connectStatus integerValue];
            NSString *orderConnStutas = @"";
            CGSize nameTxtsize= [nameInfoStr sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18]}];

            if(_currentOrderConnStatus == kOrderStatus){
                [nameAttrStr appendAttributedString:[[NSAttributedString alloc] initWithString:nameInfoStr  attributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5]}]];
                _underLineView.hidden = NO;
                _underLineView.frame = CGRectMake(CGRectGetMinX(_titleLabel.frame),CGRectGetMaxY(_titleLabel.frame)+1, nameTxtsize.width, 1);
                orderConnStutas = getOrderConnStatusName_pad(_currentOrderConnStatus);//@"【未入驻】";
                [nameAttrStr appendAttributedString:[[NSAttributedString alloc] initWithString:orderConnStutas attributes:@{NSForegroundColorAttributeName:[UIColor redColor],NSFontAttributeName:[UIFont systemFontOfSize:14]}]];

            }else  if(_currentOrderConnStatus == kOrderStatus0){
                [nameAttrStr appendAttributedString:[[NSAttributedString alloc] initWithString:nameInfoStr  attributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5]}]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    _underLineView.hidden = NO;
                    _underLineView.frame = CGRectMake(CGRectGetMinX(_titleLabel.frame),CGRectGetMaxY(_titleLabel.frame)+1, nameTxtsize.width, 1);
                });
                orderConnStutas = getOrderConnStatusName_pad(_currentOrderConnStatus);//@"【未确认】";
                [nameAttrStr appendAttributedString:[[NSAttributedString alloc] initWithString:orderConnStutas attributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5],NSFontAttributeName:[UIFont systemFontOfSize:14]}]];

            }else if(_currentOrderConnStatus == kOrderStatus1){
                [nameAttrStr appendAttributedString:[[NSAttributedString alloc] initWithString:nameInfoStr  attributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:0 green:0 blue:0 alpha:1]}]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    _underLineView.hidden = YES;
                    _underLineView.frame = CGRectMake(CGRectGetMinX(_titleLabel.frame),CGRectGetMaxY(_titleLabel.frame)+1, nameTxtsize.width, 1);
                });
                orderConnStutas = getOrderConnStatusName_pad(_currentOrderConnStatus);//@"【关联中】";
                [nameAttrStr appendAttributedString:[[NSAttributedString alloc] initWithString:orderConnStutas attributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:0 green:0 blue:0 alpha:1],NSFontAttributeName:[UIFont systemFontOfSize:14]}]];

            }else{
                [nameAttrStr appendAttributedString:[[NSAttributedString alloc] initWithString:nameInfoStr  attributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5]}]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    _underLineView.hidden = YES;
                });
                orderConnStutas = getOrderConnStatusName_pad(_currentOrderConnStatus);//@"【关联失败】";
                [nameAttrStr appendAttributedString:[[NSAttributedString alloc] initWithString:orderConnStutas attributes:@{NSForegroundColorAttributeName:[UIColor redColor],NSFontAttributeName:[UIFont systemFontOfSize:14]}]];
            }

            //通知主线程刷新
            dispatch_async(dispatch_get_main_queue(), ^{
                //回调或者说是通知主线程刷新，
                _titleLabel.attributedText = nameAttrStr;
            });

        });
    }
}
#pragma mark - --------------自定义响应----------------------
- (IBAction)oprateHandler:(YYTypeButton *)sender {
    [self twoButtonClickWithType:sender.type];
}
- (IBAction)showMoneyLogView:(YYTypeButton *)sender {
    [self twoButtonClickWithType:sender.type];
}
-(void)twoButtonClickWithType:(NSString *)Type{
    if(![NSString isNilOrEmpty:Type]){
        if([Type isEqualToString:@"unconfirmOrder"]){
            //关联失败 || 关联中
            [YYToast showToastWithTitle:NSLocalizedString(@"该订单未关联成功，无法确认",nil) andDuration:kAlertToastDuration];
        }else{
            if(self.delegate){
                [self.delegate btnClick:_indexPath.row section:_indexPath.section andParmas:@[Type]];
            }
        }
    }
}
#pragma mark - --------------自定义方法----------------------
- (void)addAlineView:(YYOrderSupplyTimeModel *)orderSupplyTimeModel andLineIndex:(int)lineIndex{
    int item_width = 380;
    int item_height = 50;

    int top_magin = lineIndex*(item_height+0);

    __weak UIView *tempWeakView = _statusView;

    YYSupplyStatusView *supplyStatusView = nil;
    supplyStatusView.backgroundColor = [UIColor yellowColor];

    NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"YYSupplyStatusView" owner:nil options:nil];
    Class   targetClass = NSClassFromString(@"YYSupplyStatusView");
    for (UIView *view in views) {
        if ([view isMemberOfClass:targetClass]) {
            supplyStatusView =  (YYSupplyStatusView *)view;
            break;
        }
    }

    supplyStatusView.orderSupplyTimeModel = orderSupplyTimeModel;
    if (lineIndex > 0) {
        supplyStatusView.hiddenEndSupplyTipsLabel = YES;
    }

    [_statusView addSubview:supplyStatusView];
    supplyStatusView.orderSupplyTimeModel = orderSupplyTimeModel;
    [supplyStatusView updateUI];

    [supplyStatusView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(tempWeakView.mas_top).with.offset(top_magin);
        make.left.mas_equalTo(tempWeakView.mas_left);
        make.width.mas_equalTo(item_width);
        make.height.mas_equalTo(item_height);
    }];

}


#pragma mark - --------------other----------------------

@end

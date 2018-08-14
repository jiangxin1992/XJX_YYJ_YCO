//
//  YYOrderStatusCell.m
//  Yunejian
//
//  Created by Apple on 15/11/25.
//  Copyright © 2015年 yyj. All rights reserved.
//

#import "YYOrderStatusCell.h"

// c文件 —> 系统文件（c文件在前）

// 控制器

// 自定义视图
#import "YYOrderStatusView.h"

// 接口
#import "YYOrderApi.h"

// 分类
#import "UIView+UpdateAutoLayoutConstraints.h"

// 自定义类和三方类（ cocoapods类 > model > 工具类 > 其他）
#import "YYUser.h"
#import "YYOrderInfoModel.h"
#import "YYOrderTransStatusModel.h"
#import "YYStylesAndTotalPriceModel.h"

@interface YYOrderStatusCell()

@property (weak, nonatomic) IBOutlet UIButton *oprateBtn;
@property (weak, nonatomic) IBOutlet UIButton *oprateBtn1;
@property (weak, nonatomic) IBOutlet UILabel *statusTipLabel;
@property (weak, nonatomic) IBOutlet UIView *statusViewContainer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerLayoutLeftConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tipLabelLayoutTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *caneltip;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *oprateBtnTopLayoutConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *statusTipLabelTopLayout;
@property (nonatomic, strong) YYOrderStatusView *statusView;

@end

@implementation YYOrderStatusCell

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

    self.contentView.backgroundColor = [UIColor colorWithHex:kDefaultBGColor];

    _statusViewContainer.backgroundColor = [UIColor clearColor];

    _oprateBtn.layer.cornerRadius = 2.5;
    _oprateBtn.layer.masksToBounds = YES;
    _oprateBtn.layer.borderWidth = 1;

    _oprateBtn1.layer.cornerRadius = 2.5;
    _oprateBtn1.layer.masksToBounds = YES;
    _oprateBtn1.layer.borderWidth = 1;

}
#pragma mark - UpdateUI
-(void)updateUI{
    if(_statusType == YYOrderStatusTypeOrder){
        [self updateUIByTypeOrder];
    }else if(_statusType == YYOrderStatusTypePickingList){
        [self updateUIByTypePickingList];
    }
}
-(void)updateUIByTypeOrder{
    if(_currentYYOrderInfoModel && _currentYYOrderTransStatusModel){
        _statusTipLabelTopLayout.constant = 43;
        if(_statusView == nil){
            NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"YYOrderStatusView" owner:nil options:nil];
            Class targetClass = NSClassFromString(@"YYOrderStatusView");
            for (UIView *view in views) {
                if ([view isMemberOfClass:targetClass]) {
                    _statusView =  (YYOrderStatusView *)view;
                    break;
                }
            }
        }
        NSInteger showIndex = 0;
        NSInteger showNum = 0;
        NSInteger tranStatus = getOrderTransStatus(self.currentYYOrderTransStatusModel.designerTransStatus, self.currentYYOrderTransStatusModel.buyerTransStatus);
        _statusView.hidden = NO;
        _caneltip.hidden = YES;
        NSInteger progress = 0;

        if(tranStatus == YYOrderCode_CLOSE_REQ ||  [_currentYYOrderInfoModel.closeReqStatus integerValue] == -1){
            //关闭请求
            if([_currentYYOrderInfoModel.closeReqStatus integerValue] == -1){//对方
                _statusView.titleArray = @[NSLocalizedString(@"对方取消订单",nil),NSLocalizedString(@"处理中",nil),NSLocalizedString(@"已取消",nil)];
            }else{
                _statusView.titleArray = @[NSLocalizedString(@"取消订单",nil),NSLocalizedString(@"对方处理中",nil),NSLocalizedString(@"已取消",nil)];
            }
            _statusView.progressTintColor = kDefaultBorderColor;
            showIndex = 0;
            showNum = 3;
            _containerLayoutLeftConstraint.constant = 110 - [_statusView getClipX:showIndex] - 45;//138
            progress = 1;

        }else if(tranStatus == YYOrderCode_NEGOTIATION || tranStatus == YYOrderCode_NEGOTIATION_DONE || tranStatus == YYOrderCode_CONTRACT_DONE){
            //已确认 已下单
            _statusView.titleArray = @[NSLocalizedString(@"已下单",nil),NSLocalizedString(@"已确认",nil),NSLocalizedString(@"已生产",nil),NSLocalizedString(@"发货中",nil),NSLocalizedString(@"已发货",nil),NSLocalizedString(@"已收货",nil)];
            _statusView.progressTintColor = @"ed6498";
            showIndex = 0;
            showNum = 6;
            if(tranStatus == YYOrderCode_NEGOTIATION){
                //已下单
                progress = 0;
            }else{
                //已确认
                progress = 1;
            }
            CGFloat containerLayoutLeft = 130 - [_statusView getClipX:showIndex] - 92;
            _containerLayoutLeftConstraint.constant = containerLayoutLeft;
        }else if(tranStatus == YYOrderCode_CANCELLED || tranStatus == YYOrderCode_CLOSED){
            //已取消
            _statusView.hidden = YES;
            _caneltip.hidden = NO;
        }else{
            //已生产 发货中 已发货  已收货
            if(_currentYYOrderInfoModel != nil){
                _statusView.titleArray = @[NSLocalizedString(@"已下单",nil),NSLocalizedString(@"已确认",nil),NSLocalizedString(@"已生产",nil),NSLocalizedString(@"发货中",nil),NSLocalizedString(@"已发货",nil),NSLocalizedString(@"已收货",nil)];
                _statusView.progressTintColor = @"ed6498";
                showIndex = 0;
                showNum = 6;
                progress = tranStatus - YYOrderCode_NEGOTIATION;
                CGFloat containerLayoutLeft = 130 - [_statusView getClipX:showIndex] - 92;
                _containerLayoutLeftConstraint.constant = containerLayoutLeft;//138
                if(tranStatus == YYOrderCode_MANUFACTURE){
                    //已生产
                    progress = 2;
                }else if(tranStatus == YYOrderCode_DELIVERING){
                    //发货中
                    progress = 3;
                }else if(tranStatus == YYOrderCode_DELIVERY){
                    //已发货
                    progress = 4;
                }else if(tranStatus == YYOrderCode_RECEIVED){
                    //已收货
                    progress = 5;
                }
            }else{
                _statusView.titleArray = @[@""];
                _statusView.progressTintColor = @"ed6498";
                showIndex = 0;
                showNum = 0;
                _containerLayoutLeftConstraint.constant = 130 - [_statusView getClipX:showIndex] - 92;//138
            }
        }

        if(_statusView != nil){
            _statusView.showIndex = showIndex;
            _statusView.showNum = showNum;
            [_statusView updateUI];
            [_statusView setProgressValue:progress];
            if(_currentYYOrderTransStatusModel.createTime != nil){
                _statusView.timerLabel.text = getShowDateByFormatAndTimeInterval(@"yyyy/MM/dd HH:mm",[_currentYYOrderTransStatusModel.createTime stringValue]);
            }else{
                _statusView.timerLabel.text = @"";
            }
            [_statusViewContainer addSubview:_statusView];
        }

        _statusTipLabel.hidden = NO;
        _statusTipLabel.textColor = [UIColor colorWithHex:@"919191"];
        _statusTipLabel.text = getOrderStatusDesignerTip_pad(tranStatus);

        _tipLabelLayoutTopConstraint.constant = 56;

        //按钮
        _oprateBtn.hidden = YES;
        _oprateBtn.backgroundColor = _define_black_color;
        _oprateBtn.layer.borderColor = _define_black_color.CGColor;
        [_oprateBtn setTitleColor:_define_white_color forState:UIControlStateNormal];
        _oprateBtnTopLayoutConstraint.constant = 8;

        _oprateBtn1.hidden = YES;
        _oprateBtn1.backgroundColor = _define_black_color;
        _oprateBtn1.layer.borderColor = _define_black_color.CGColor;
        [_oprateBtn1 setTitleColor:_define_white_color forState:UIControlStateNormal];

        if(tranStatus == YYOrderCode_CLOSE_REQ || [_currentYYOrderInfoModel.closeReqStatus integerValue] == -1){
            //关闭请求

            if([_currentYYOrderInfoModel.closeReqStatus integerValue] == -1){//对方
                _oprateBtn1.hidden = NO;
                [_oprateBtn1 setTitle:NSLocalizedString(@"同意取消",nil) forState:UIControlStateNormal];
                _oprateBtn.hidden = NO;
                [_oprateBtn setTitle:NSLocalizedString(@"拒绝申请",nil) forState:UIControlStateNormal];
                _statusTipLabel.text = NSLocalizedString(@"请尽快处理订单，以免对方久等",nil);
            }else if([_currentYYOrderInfoModel.closeReqStatus integerValue] == 1){//自己
                _oprateBtn.hidden = NO;
                [_oprateBtn setTitle:NSLocalizedString(@"撤销已取消申请",nil) forState:UIControlStateNormal];
                _statusTipLabel.text = NSLocalizedString(@"请耐心等待对方处理，如果改变主意可以进行撤销申请",nil);
            }else{
                _oprateBtn.hidden = YES;
                _statusTipLabel.textColor = [UIColor colorWithHex:@"000000"];
            }

        }else if(tranStatus == YYOrderCode_NEGOTIATION){
            //已下单

            BOOL isDesignerConfrim = [_currentYYOrderInfoModel isDesignerConfrim];
            BOOL isBuyerConfrim = [_currentYYOrderInfoModel isBuyerConfrim];

            if(!isBuyerConfrim){
                if(!isDesignerConfrim){
                    //双方都未确认
                    if(_currentOrderConnStatus == YYOrderConnStatusLinked || _currentOrderConnStatus == YYOrderConnStatusNotFound){
                        //关联成功 || 未入驻
                        _oprateBtn.hidden = NO;
                        [_oprateBtn setTitle:NSLocalizedString(@"确认订单",nil) forState:UIControlStateNormal];
                    }else{
                        //关联失败 || 关联中
                        _oprateBtn.hidden = NO;
                        _oprateBtn.backgroundColor = [UIColor colorWithHex:@"d3d3d3"];
                        _oprateBtn.layer.borderColor = [UIColor colorWithHex:@"d3d3d3"].CGColor;
                        [_oprateBtn setTitleColor:_define_white_color forState:UIControlStateNormal];
                        [_oprateBtn setTitle:NSLocalizedString(@"确认订单",nil) forState:UIControlStateNormal];
                    }

                }else{
                    //买手未确认
                    _oprateBtn.hidden = NO;
                    _oprateBtn.backgroundColor = [UIColor colorWithHex:@"d3d3d3"];
                    _oprateBtn.layer.borderColor = [UIColor colorWithHex:@"d3d3d3"].CGColor;
                    [_oprateBtn setTitleColor:_define_white_color forState:UIControlStateNormal];
                    [_oprateBtn setTitle:NSLocalizedString(@"待买手确认",nil) forState:UIControlStateNormal];
                }
            }else{
                if(!isDesignerConfrim){
                    //设计师未确认
                    if(_currentOrderConnStatus == YYOrderConnStatusLinked || _currentOrderConnStatus == YYOrderConnStatusNotFound){
                        //关联成功 || 未入驻
                        _oprateBtn.hidden = NO;
                        [_oprateBtn setTitle:NSLocalizedString(@"确认订单",nil) forState:UIControlStateNormal];
                    }else{
                        //关联失败 || 关联中
                        _oprateBtn.hidden = NO;
                        _oprateBtn.backgroundColor = [UIColor colorWithHex:@"d3d3d3"];
                        _oprateBtn.layer.borderColor = [UIColor colorWithHex:@"d3d3d3"].CGColor;
                        [_oprateBtn setTitleColor:_define_white_color forState:UIControlStateNormal];
                        [_oprateBtn setTitle:NSLocalizedString(@"确认订单",nil) forState:UIControlStateNormal];
                    }

                    _oprateBtn1.hidden = NO;
                    _oprateBtn1.backgroundColor = _define_white_color;
                    _oprateBtn1.layer.borderColor = _define_black_color.CGColor;
                    [_oprateBtn1 setTitleColor:_define_black_color forState:UIControlStateNormal];
                    [_oprateBtn1 setTitle:NSLocalizedString(@"拒绝确认",nil) forState:UIControlStateNormal];
                }else{
                    //理论上不存在这种情况
                }
            }
        }else if(tranStatus == YYOrderCode_NEGOTIATION_DONE || tranStatus == YYOrderCode_CONTRACT_DONE){
            //已确认

            _oprateBtn.hidden = NO;
            [_oprateBtn setTitle:NSLocalizedString(@"已生产",nil) forState:UIControlStateNormal];

        }else if(tranStatus == YYOrderCode_MANUFACTURE){
            //已生产

            _oprateBtn.hidden = NO;
            [_oprateBtn setTitle:NSLocalizedString(@"已发货",nil) forState:UIControlStateNormal];

        }else if(tranStatus == YYOrderCode_DELIVERING){
            //发货中

            _oprateBtn.hidden = NO;

            NSInteger awaitDeliveryAmount = _stylesAndTotalPriceModel.totalCount - [_currentYYOrderInfoModel.packageStat.sentAmount integerValue];//待发货数

            if(_stylesAndTotalPriceModel.totalCount == [_currentYYOrderInfoModel.packageStat.receivedAmount integerValue]){
                //完成发货
                [_oprateBtn setTitle:NSLocalizedString(@"完成发货",nil) forState:UIControlStateNormal];
            }else{
                if(awaitDeliveryAmount > 0){
                    //继续发货
                    [_oprateBtn setTitle:NSLocalizedString(@"继续发货",nil) forState:UIControlStateNormal];
                }else{
                    //继续发货
                    _oprateBtn.backgroundColor = [UIColor colorWithHex:@"d3d3d3"];
                    _oprateBtn.layer.borderColor = [UIColor colorWithHex:@"d3d3d3"].CGColor;
                    [_oprateBtn setTitleColor:_define_white_color forState:UIControlStateNormal];
                    [_oprateBtn setTitle:NSLocalizedString(@"继续发货",nil) forState:UIControlStateNormal];
                }
            }
        }else if(tranStatus == YYOrderCode_DELIVERY){
            //已发货

            _oprateBtn.hidden = NO;
            _oprateBtn.backgroundColor = [UIColor clearColor];
            _oprateBtn.layer.borderColor = [UIColor clearColor].CGColor;
            [_oprateBtn setTitleColor:[[UIColor blackColor] colorWithAlphaComponent:0.6] forState:UIControlStateNormal];
            [_oprateBtn setTitle:NSLocalizedString(@"等待对方确认收货",nil) forState:UIControlStateNormal];

        }else if(tranStatus == YYOrderCode_RECEIVED){
            //已收货
            _statusTipLabel.hidden = YES;
            _tipLabelLayoutTopConstraint.constant = 26;
            _statusTipLabel.textColor = [UIColor colorWithHex:@"000000"];

            _oprateBtn.hidden = NO;
            _oprateBtn.backgroundColor = [UIColor clearColor];
            _oprateBtn.layer.borderColor = [UIColor clearColor].CGColor;
            [_oprateBtn setTitleColor:[[UIColor blackColor] colorWithAlphaComponent:0.6] forState:UIControlStateNormal];
            [_oprateBtn setTitle:NSLocalizedString(@"订单已完成",nil) forState:UIControlStateNormal];

        }else if(tranStatus == YYOrderCode_CANCELLED || tranStatus == YYOrderCode_CLOSED){
            //已取消
            _oprateBtnTopLayoutConstraint.constant = 25;

            _oprateBtn.hidden = NO;
            [_oprateBtn setTitle:NSLocalizedString(@"重新建立订单",nil) forState:UIControlStateNormal];

        }

        //更新约束
        if(_oprateBtn.hidden == NO){
            NSString *btnTxt = _oprateBtn.currentTitle;
            CGSize txtSize = [btnTxt sizeWithAttributes:@{NSFontAttributeName:_oprateBtn.titleLabel.font}];
            NSInteger btnWidth = MAX(80, (txtSize.width+20));
            [_oprateBtn setConstraintConstant:btnWidth forAttribute:NSLayoutAttributeWidth];
        }
        if(_oprateBtn1.hidden == NO){
            NSString *btnTxt = _oprateBtn1.currentTitle;
            CGSize txtSize = [btnTxt sizeWithAttributes:@{NSFontAttributeName:_oprateBtn1.titleLabel.font}];
            NSInteger btnWidth = MAX(80, (txtSize.width+20));
            [_oprateBtn1 setConstraintConstant:btnWidth forAttribute:NSLayoutAttributeWidth];
        }
    }else{
        _oprateBtn.hidden = YES;
        _oprateBtn1.hidden = YES;
    }
}
-(void)updateUIByTypePickingList{

    _statusTipLabelTopLayout.constant = (96-21)/2.f;
    _oprateBtn1.hidden = YES;
    _statusTipLabel.hidden = YES;
    _caneltip.hidden = YES;

    if(_hasException){
        _oprateBtn.hidden = NO;
        _oprateBtn.backgroundColor = [UIColor colorWithHex:@"EF4E31"];
        _oprateBtn.layer.borderColor = [UIColor colorWithHex:@"EF4E31"].CGColor;
        [_oprateBtn setTitleColor:_define_white_color forState:UIControlStateNormal];
        [_oprateBtn setTitle:NSLocalizedString(@"查看异常反馈",nil) forState:UIControlStateNormal];
    }else{
        _oprateBtn.hidden = YES;
    }

    if(_oprateBtn.hidden == NO){
        NSString *btnTxt = _oprateBtn.currentTitle;
        CGSize txtSize = [btnTxt sizeWithAttributes:@{NSFontAttributeName:_oprateBtn.titleLabel.font}];
        NSInteger btnWidth = MAX(80, (txtSize.width+20));
        [_oprateBtn setConstraintConstant:btnWidth forAttribute:NSLayoutAttributeWidth];
    }

    if(_statusView == nil){
        NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"YYOrderStatusView" owner:nil options:nil];
        Class targetClass = NSClassFromString(@"YYOrderStatusView");
        for (UIView *view in views) {
            if ([view isMemberOfClass:targetClass]) {
                _statusView =  (YYOrderStatusView *)view;
                break;
            }
        }
    }
    _statusView.hidden = NO;
    NSArray *titleArray = @[NSLocalizedString(@"建立装箱单",nil),NSLocalizedString(@"待发货",nil),NSLocalizedString(@"在途中",nil),NSLocalizedString(@"已收货",nil)];
    _statusView.titleArray = titleArray;
    _statusView.progressTintColor = @"ed6498";
    _containerLayoutLeftConstraint.constant = 110 - [_statusView getClipX:0] - 45;//138

    if(_statusView != nil){
        _statusView.showIndex = 0;
        _statusView.showNum = titleArray.count;
        [_statusView updateUI];
        [_statusView setProgressValue:_progress];
        _statusView.timerLabel.text = @"";
        [_statusViewContainer addSubview:_statusView];
    }
}
#pragma mark - --------------自定义响应----------------------
- (IBAction)opreteBtnHandler:(id)sender {
    if(_statusType == YYOrderStatusTypeOrder){
        NSInteger tranStatus = getOrderTransStatus(self.currentYYOrderTransStatusModel.designerTransStatus, self.currentYYOrderTransStatusModel.buyerTransStatus);

        if(self.delegate){
            if(tranStatus == YYOrderCode_CLOSE_REQ || [_currentYYOrderInfoModel.closeReqStatus integerValue] == -1){
                //关闭请求
                if([_currentYYOrderInfoModel.closeReqStatus integerValue] == -1){//对方
                    [self.delegate btnClick:0 section:0 andParmas:@[@"refuseReqClose"]];
                }else if([_currentYYOrderInfoModel.closeReqStatus integerValue] == 1){
                    [self.delegate btnClick:0 section:0 andParmas:@[@"cancelReqClose"]];
                }
            }else if(tranStatus == YYOrderCode_NEGOTIATION){
                //已下单
                BOOL isDesignerConfrim = [_currentYYOrderInfoModel isDesignerConfrim];
                BOOL isBuyerConfrim = [_currentYYOrderInfoModel isBuyerConfrim];
                if(!isBuyerConfrim){
                    if(!isDesignerConfrim){
                        //双方都未确认
                        if(_currentOrderConnStatus == YYOrderConnStatusLinked || _currentOrderConnStatus == YYOrderConnStatusNotFound){
                            //关联成功 || 未入驻
                            [self.delegate btnClick:0 section:0 andParmas:@[@"confirmOrder"]];
                        }else{
                            //关联失败 || 关联中
                            [YYToast showToastWithTitle:NSLocalizedString(@"该订单未关联成功，无法确认",nil) andDuration:kAlertToastDuration];
                        }
                    }
                }else{
                    if(!isDesignerConfrim){
                        //设计师未确认
                        if(_currentOrderConnStatus == YYOrderConnStatusLinked || _currentOrderConnStatus == YYOrderConnStatusNotFound){
                            //关联成功 || 未入驻
                            [self.delegate btnClick:0 section:0 andParmas:@[@"confirmOrder"]];
                        }else{
                            //关联失败 || 关联中
                            [YYToast showToastWithTitle:NSLocalizedString(@"该订单未关联成功，无法确认",nil) andDuration:kAlertToastDuration];
                        }
                    }
                }
            }else if(tranStatus == YYOrderCode_NEGOTIATION_DONE || tranStatus == YYOrderCode_CONTRACT_DONE){
                //已确认
                [self.delegate btnClick:0 section:0 andParmas:@[@"status"]];
            }else if(tranStatus == YYOrderCode_MANUFACTURE){
                //已生产
                [self.delegate btnClick:0 section:0 andParmas:@[@"status"]];
            }else if(tranStatus == YYOrderCode_DELIVERING){
                //发货中
                NSInteger awaitDeliveryAmount = _stylesAndTotalPriceModel.totalCount - [_currentYYOrderInfoModel.packageStat.sentAmount integerValue];//待发货数

                if(_stylesAndTotalPriceModel.totalCount == [_currentYYOrderInfoModel.packageStat.receivedAmount integerValue]){
                    //完成发货 status
                    [self.delegate btnClick:0 section:0 andParmas:@[@"status"]];
                }else{
                    if(awaitDeliveryAmount > 0){
                        //继续发货 delivery
                        [self.delegate btnClick:0 section:0 andParmas:@[@"delivery"]];
                    }else{
                        //继续发货 delivery_tip
                        [self.delegate btnClick:0 section:0 andParmas:@[@"delivery_tip"]];
                    }
                }
            }else if(tranStatus == YYOrderCode_CANCELLED || tranStatus == YYOrderCode_CLOSED){
                //已取消
                [self.delegate btnClick:0 section:0 andParmas:@[@"reBuildOrder"]];
            }
        }
    }else if(_statusType == YYOrderStatusTypePickingList){
        if(_errorClickBlock){
            _errorClickBlock();
        }
    }
}

- (IBAction)opreteBtnHandler1:(id)sender {
    if(_statusType == YYOrderStatusTypeOrder){
        NSInteger tranStatus = getOrderTransStatus(self.currentYYOrderTransStatusModel.designerTransStatus, self.currentYYOrderTransStatusModel.buyerTransStatus);

        if(self.delegate){
            if(tranStatus == YYOrderCode_CLOSE_REQ || [_currentYYOrderInfoModel.closeReqStatus integerValue] == -1){
                //关闭请求
                [self.delegate btnClick:0 section:0 andParmas:@[@"agreeReqClose"]];
            }else if(tranStatus == YYOrderCode_NEGOTIATION){
                //已下单
                BOOL isDesignerConfrim = [_currentYYOrderInfoModel isDesignerConfrim];
                BOOL isBuyerConfrim = [_currentYYOrderInfoModel isBuyerConfrim];
                if(isBuyerConfrim){
                    if(!isDesignerConfrim){
                        //设计师未确认
                        [self.delegate btnClick:0 section:0 andParmas:@[@"refuseOrder"]];
                    }
                }
            }
        }
    }
}

#pragma mark - --------------自定义方法----------------------


#pragma mark - --------------other----------------------

@end

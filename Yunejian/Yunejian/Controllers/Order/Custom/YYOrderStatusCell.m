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

@interface YYOrderStatusCell()

@property (weak, nonatomic) IBOutlet UIButton *oprateBtn;
@property (weak, nonatomic) IBOutlet UIButton *oprateBtn1;
@property (weak, nonatomic) IBOutlet UILabel *statusTipLabel;
@property (weak, nonatomic) IBOutlet UIView *statusViewContainer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerLayoutLeftConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tipLabelLayoutTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *caneltip;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *oprateBtnTopLayoutConstraint;

@end

@implementation YYOrderStatusCell

#pragma mark - --------------生命周期--------------
- (void)awakeFromNib {
    // Initialization code
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

    if(_currentYYOrderInfoModel && _currentYYOrderTransStatusModel){
        if(statusView == nil){
            NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"YYOrderStatusView" owner:nil options:nil];
            Class   targetClass = NSClassFromString(@"YYOrderStatusView");
            for (UIView *view in views) {
                if ([view isMemberOfClass:targetClass]) {
                    statusView =  (YYOrderStatusView *)view;
                    break;
                }
            }
        }
        NSInteger showIndex = 0;
        NSInteger showNum = 0;
        NSInteger tranStatus = getOrderTransStatus(self.currentYYOrderTransStatusModel.designerTransStatus, self.currentYYOrderTransStatusModel.buyerTransStatus);
        statusView.hidden = NO;
        _caneltip.hidden = YES;

        if(tranStatus == kOrderCode_CLOSE_REQ ||  [_currentYYOrderInfoModel.closeReqStatus integerValue] == -1){
            //关闭请求
            if([_currentYYOrderInfoModel.closeReqStatus integerValue] == -1){//对方
                statusView.titleArray = @[NSLocalizedString(@"对方取消订单",nil),NSLocalizedString(@"处理中",nil),NSLocalizedString(@"已取消",nil)];
            }else{
                statusView.titleArray = @[NSLocalizedString(@"取消订单",nil),NSLocalizedString(@"对方处理中",nil),NSLocalizedString(@"已取消",nil)];
            }
            statusView.progressTintColor = kDefaultBorderColor;
            showIndex = 0;
            showNum = 3;
            _containerLayoutLeftConstraint.constant = 110 - [statusView getClipX:showIndex] - 45;//138
            progress = 1;

        }else if(tranStatus == kOrderCode_NEGOTIATION || tranStatus == kOrderCode_NEGOTIATION_DONE || tranStatus == kOrderCode_CONTRACT_DONE){
            //已确认 已下单
            statusView.titleArray = @[NSLocalizedString(@"已下单",nil),NSLocalizedString(@"已确认",nil),NSLocalizedString(@"已生产",nil),NSLocalizedString(@"已发货",nil),NSLocalizedString(@"已收货",nil)];
            statusView.progressTintColor = @"ed6498";
            showIndex = 0;
            showNum = 5;
            if(tranStatus == kOrderCode_NEGOTIATION_DONE || tranStatus == kOrderCode_CONTRACT_DONE){
                //已确认
                progress = 1;
            }else{
                //已下单
                progress = 0;
            }
            _containerLayoutLeftConstraint.constant = 130 - [statusView getClipX:showIndex] - 10;
        }else if(tranStatus == kOrderCode_CANCELLED || tranStatus == kOrderCode_CLOSED){
            //已取消
            statusView.hidden = YES;
            _caneltip.hidden = NO;
        }else{
            //已生产  已发货  已收货
            if(_currentYYOrderInfoModel !=nil){
                statusView.titleArray = @[NSLocalizedString(@"已下单",nil),NSLocalizedString(@"已确认",nil),NSLocalizedString(@"已生产",nil),NSLocalizedString(@"已发货",nil),NSLocalizedString(@"已收货",nil)];
                statusView.progressTintColor = @"ed6498";
                showIndex = 0;
                showNum = 5;
                progress = tranStatus - kOrderCode_NEGOTIATION;
                _containerLayoutLeftConstraint.constant = 130 - [statusView getClipX:showIndex] - 92;//138
            }else{
                statusView.titleArray = @[@""];
                statusView.progressTintColor = @"ed6498";
                showIndex = 0;
                showNum = 0;
                _containerLayoutLeftConstraint.constant = 130 - [statusView getClipX:showIndex] - 92;//138
            }
            if(tranStatus == kOrderCode_MANUFACTURE){
                //已生产
                progress = 2;
            }else if(tranStatus == kOrderCode_DELIVERY){
                //已发货
                progress = 3;
            }else if(tranStatus == kOrderCode_RECEIVED){
                //已收货
                progress = 4;
            }
        }

        if(statusView != nil){
            statusView.showIndex = showIndex;
            statusView.showNum = showNum;
            [statusView updateUI];
            [statusView setProgressValue:progress];
            if(_currentYYOrderTransStatusModel.createTime != nil){
                statusView.timerLabel.text = getShowDateByFormatAndTimeInterval(@"yyyy/MM/dd HH:mm",[_currentYYOrderTransStatusModel.createTime stringValue]);
            }else{
                statusView.timerLabel.text = @"";
            }
            [_statusViewContainer addSubview:statusView];
        }

        _statusTipLabel.textColor = [UIColor colorWithHex:@"919191"];
        _statusTipLabel.text = getOrderStatusDesignerTip_pad(tranStatus);

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

        if(tranStatus == kOrderCode_CLOSE_REQ || [_currentYYOrderInfoModel.closeReqStatus integerValue] == -1){
            //关闭请求
            if([_currentYYOrderInfoModel.closeReqStatus integerValue] == -1){//对方
                _oprateBtn1.hidden = NO;
                [_oprateBtn1 setTitle:NSLocalizedString(@"同意取消交易",nil) forState:UIControlStateNormal];
                _oprateBtn.hidden = NO;
                [_oprateBtn setTitle:NSLocalizedString(@"我方交易继续",nil) forState:UIControlStateNormal];
            }else if([_currentYYOrderInfoModel.closeReqStatus integerValue] == 1){//自己
                _oprateBtn.hidden = NO;
                [_oprateBtn setTitle:NSLocalizedString(@"撤销已取消申请",nil) forState:UIControlStateNormal];
            }else{
                _oprateBtn.hidden = YES;
                _statusTipLabel.textColor = [UIColor colorWithHex:@"000000"];
            }

            _tipLabelLayoutTopConstraint.constant = 56;
            _statusTipLabel.hidden = NO;
            if([_currentYYOrderInfoModel.autoCloseHoursRemains integerValue]>0){
                NSInteger day = [_currentYYOrderInfoModel.autoCloseHoursRemains integerValue]/24;
                NSInteger hours = [_currentYYOrderInfoModel.autoCloseHoursRemains integerValue]%24;
                _statusTipLabel.text = [NSString stringWithFormat:NSLocalizedString(@"剩余%ld天%ld小时，交易将自动取消",nil),(long)day,(long)hours];
            }else{
                _statusTipLabel.text = @"";
            }
        }else if(tranStatus == kOrderCode_NEGOTIATION){
            //已下单
            _tipLabelLayoutTopConstraint.constant = 56;
            _statusTipLabel.hidden = NO;
            BOOL isDesignerConfrim = [_currentYYOrderInfoModel isDesignerConfrim];
            BOOL isBuyerConfrim = [_currentYYOrderInfoModel isBuyerConfrim];

            if(!isBuyerConfrim){
                if(!isDesignerConfrim){
                    //双方都未确认
                    if(_currentOrderConnStatus == kOrderStatus1 || _currentOrderConnStatus == kOrderStatus || _currentOrderConnStatus == kOrderStatus3){
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
                    if(_currentOrderConnStatus == kOrderStatus1 || _currentOrderConnStatus == kOrderStatus || _currentOrderConnStatus == kOrderStatus3){
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
        }else if(tranStatus == kOrderCode_NEGOTIATION_DONE || tranStatus == kOrderCode_CONTRACT_DONE){
            //已确认
            _tipLabelLayoutTopConstraint.constant = 56;
            _statusTipLabel.hidden = NO;

            _oprateBtn.hidden = NO;
            [_oprateBtn setTitle:NSLocalizedString(@"已生产",nil) forState:UIControlStateNormal];

        }else if(tranStatus == kOrderCode_MANUFACTURE){
            //已生产
            _tipLabelLayoutTopConstraint.constant = 56;
            _statusTipLabel.hidden = NO;

            _oprateBtn.hidden = NO;
            [_oprateBtn setTitle:NSLocalizedString(@"已发货",nil) forState:UIControlStateNormal];

        }else if(tranStatus == kOrderCode_DELIVERY){
            //已发货
            _statusTipLabel.hidden = NO;
            _tipLabelLayoutTopConstraint.constant = 56;

            NSString *timerStr = nil;
            if([_currentYYOrderInfoModel.autoReceivedHoursRemains integerValue] > -1){
                NSInteger day = [_currentYYOrderInfoModel.autoReceivedHoursRemains integerValue]/24;
                NSInteger hours = [_currentYYOrderInfoModel.autoReceivedHoursRemains integerValue]%24;
                timerStr = [NSString stringWithFormat:NSLocalizedString(@"%ld天%ld小时",nil),(long)day,(long)hours];
            }
            if(timerStr){
                _statusTipLabel.text = [NSString stringWithFormat:getOrderStatusDesignerTip_phone(tranStatus),timerStr] ;
            }else{
                _statusTipLabel.text = @"";
            }

            _oprateBtn.hidden = NO;
            _oprateBtn.backgroundColor = [UIColor clearColor];
            _oprateBtn.layer.borderColor = [UIColor clearColor].CGColor;
            [_oprateBtn setTitleColor:[[UIColor blackColor] colorWithAlphaComponent:0.6] forState:UIControlStateNormal];
            [_oprateBtn setTitle:NSLocalizedString(@"等待对方确认收货",nil) forState:UIControlStateNormal];

        }else if(tranStatus == kOrderCode_RECEIVED){
            //已收货
            _statusTipLabel.hidden = YES;
            _tipLabelLayoutTopConstraint.constant = 26;
            _statusTipLabel.textColor = [UIColor colorWithHex:@"000000"];

            _oprateBtn.hidden = NO;
            _oprateBtn.backgroundColor = [UIColor clearColor];
            _oprateBtn.layer.borderColor = [UIColor clearColor].CGColor;
            [_oprateBtn setTitleColor:[[UIColor blackColor] colorWithAlphaComponent:0.6] forState:UIControlStateNormal];
            [_oprateBtn setTitle:NSLocalizedString(@"订单已完成",nil) forState:UIControlStateNormal];

        }else if(tranStatus == kOrderCode_CANCELLED || tranStatus == kOrderCode_CLOSED){
            //已取消
            _tipLabelLayoutTopConstraint.constant = 56;
            _statusTipLabel.hidden = NO;
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
#pragma mark - --------------自定义响应----------------------
- (IBAction)opreteBtnHandler:(id)sender {

    NSInteger tranStatus = getOrderTransStatus(self.currentYYOrderTransStatusModel.designerTransStatus, self.currentYYOrderTransStatusModel.buyerTransStatus);

    if(self.delegate){
        if(tranStatus == kOrderCode_CLOSE_REQ || [_currentYYOrderInfoModel.closeReqStatus integerValue] == -1){
            //关闭请求
            if([_currentYYOrderInfoModel.closeReqStatus integerValue] == -1){//对方
                [self.delegate btnClick:0 section:0 andParmas:@[@"refuseReqClose"]];
            }else if([_currentYYOrderInfoModel.closeReqStatus integerValue] == 1){
                [self.delegate btnClick:0 section:0 andParmas:@[@"cancelReqClose"]];
            }
        }else if(tranStatus == kOrderCode_NEGOTIATION){
            //已下单
            BOOL isDesignerConfrim = [_currentYYOrderInfoModel isDesignerConfrim];
            BOOL isBuyerConfrim = [_currentYYOrderInfoModel isBuyerConfrim];
            if(!isBuyerConfrim){
                if(!isDesignerConfrim){
                    //双方都未确认
                    if(_currentOrderConnStatus == kOrderStatus1 || _currentOrderConnStatus == kOrderStatus || _currentOrderConnStatus == kOrderStatus3){
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
                    if(_currentOrderConnStatus == kOrderStatus1 || _currentOrderConnStatus == kOrderStatus || _currentOrderConnStatus == kOrderStatus3){
                        //关联成功 || 未入驻
                        [self.delegate btnClick:0 section:0 andParmas:@[@"confirmOrder"]];
                    }else{
                        //关联失败 || 关联中
                        [YYToast showToastWithTitle:NSLocalizedString(@"该订单未关联成功，无法确认",nil) andDuration:kAlertToastDuration];
                    }
                }
            }
        }else if(tranStatus == kOrderCode_NEGOTIATION_DONE || tranStatus == kOrderCode_CONTRACT_DONE){
            //已确认
            [self.delegate btnClick:0 section:0 andParmas:@[@"status"]];
        }else if(tranStatus == kOrderCode_MANUFACTURE){
            //已生产
            [self.delegate btnClick:0 section:0 andParmas:@[@"status"]];
        }else if(tranStatus == kOrderCode_CANCELLED || tranStatus == kOrderCode_CLOSED){
            //已取消
            [self.delegate btnClick:0 section:0 andParmas:@[@"reBuildOrder"]];
        }
    }
}

- (IBAction)opreteBtnHandler1:(id)sender {
    NSInteger tranStatus = getOrderTransStatus(self.currentYYOrderTransStatusModel.designerTransStatus, self.currentYYOrderTransStatusModel.buyerTransStatus);

    if(self.delegate){
        if(tranStatus == kOrderCode_CLOSE_REQ || [_currentYYOrderInfoModel.closeReqStatus integerValue] == -1){
            //关闭请求
            [self.delegate btnClick:0 section:0 andParmas:@[@"agreeReqClose"]];
        }else if(tranStatus == kOrderCode_NEGOTIATION){
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

#pragma mark - --------------自定义方法----------------------


#pragma mark - --------------other----------------------

@end

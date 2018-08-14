//
//  YYDeliveringDoneConfirmViewController.m
//  Yunejian
//
//  Created by yyj on 2018/8/7.
//  Copyright © 2018年 yyj. All rights reserved.
//

#import "YYDeliveringDoneConfirmViewController.h"

// c文件 —> 系统文件（c文件在前）

// 控制器

// 自定义视图
#import "YYDeliverDoneTotalPriceCell.h"
#import "YYDeliverDoneConfirmStyleInfoCell.h"

// 接口
#import "YYOrderApi.h"

// 分类

// 自定义类和三方类（ cocoapods类 > model > 工具类 > 其他）
#import "YYOrderInfoModel.h"
#import "YYStylesAndTotalPriceModel.h"

@interface YYDeliveringDoneConfirmViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSArray *undeliveredStylesArray;//这里放的style数据

@end

@implementation YYDeliveringDoneConfirmViewController
#pragma mark - --------------生命周期--------------
- (void)viewDidLoad {
    [super viewDidLoad];
    [self SomePrepare];
    [self UIConfig];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    // 进入埋点
    [MobClick beginLogPageView:kYYPageDeliveringDoneConfirm];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    // 退出埋点
    [MobClick endLogPageView:kYYPageDeliveringDoneConfirm];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
#pragma mark - --------------SomePrepare--------------
- (void)SomePrepare {
    [self PrepareData];
    [self PrepareUI];
}
- (void)PrepareData {

}
- (void)PrepareUI {

    popWindowAddBgView(self.view);

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    [_tableView reloadData];
}

#pragma mark - --------------UIConfig----------------------
- (void)UIConfig {
}

#pragma mark - --------------系统代理----------------------
#pragma mark - TableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(!_currentYYOrderInfoModel){
        return 0;
    }

    if(indexPath.row == _undeliveredStylesArray.count){
        return UITableViewAutomaticDimension;
    }

    CGFloat confirmCellHeight = 105 + 46;
    NSInteger cellIndex = indexPath.row;
    YYOrderStyleModel *orderStyleModel = _undeliveredStylesArray[cellIndex];
    for (YYOrderOneColorModel *orderOneColorModel in orderStyleModel.colors) {
        NSInteger sizeCount = orderOneColorModel.sizes.count;
        confirmCellHeight += (sizeCount*50 + 20);
    }
    if(!cellIndex){
        confirmCellHeight += 46;
    }
    return confirmCellHeight;
}
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 10;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(!_currentYYOrderInfoModel){
        return 0;
    }
    return _undeliveredStylesArray.count + 1;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(!_currentYYOrderInfoModel){
        static NSString *cellid = @"cellid";
        UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:cellid];
        if(!cell){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        return cell;
    }

    if(indexPath.row == _undeliveredStylesArray.count){
        static NSString *cellid = @"YYDeliverDoneTotalPriceCell";
        YYDeliverDoneTotalPriceCell *cell = [_tableView dequeueReusableCellWithIdentifier:cellid];
        if(!cell){
            cell = [[YYDeliverDoneTotalPriceCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.stylesAndTotalPriceModel = _stylesAndTotalPriceModel;
        cell.nowStylesAndTotalPriceModel = _nowStylesAndTotalPriceModel;
        cell.curType = _currentYYOrderInfoModel.curType;
        [cell updateUI];
        return cell;
    }

    static NSString *cellid = @"YYDeliverDoneConfirmStyleInfoCell";
    YYDeliverDoneConfirmStyleInfoCell *cell = [_tableView dequeueReusableCellWithIdentifier:cellid];
    if(!cell){
        cell = [[YYDeliverDoneConfirmStyleInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    NSInteger cellIndex = indexPath.row;
    if(!cellIndex){
        cell.isFirstCell = YES;
    }else{
        cell.isFirstCell = NO;
    }
    cell.orderStyleModel = _undeliveredStylesArray[cellIndex];
    [cell updateUI];
    return cell;
}

#pragma mark - --------------自定义代理/block----------------------

#pragma mark - --------------自定义响应----------------------
- (IBAction)closeBtnHandler:(id)sender {
    if(self.cancelButtonClicked){
        self.cancelButtonClicked();
    }
}
- (IBAction)sureBtnHandler:(id)sender {
    WeakSelf(ws);

    CMAlertView *alertView = [[CMAlertView alloc] initWithTitle:NSLocalizedString(@"确定结束发货？",nil) message:NSLocalizedString(@"订单将会被修改，订单状态将会变成“已发货”",nil) needwarn:NO delegate:nil cancelButtonTitle:NSLocalizedString(@"取消",nil) otherButtonTitles:@[[NSString stringWithFormat:@"%@|000000",NSLocalizedString(@"结束发货",nil)]]];
    alertView.specialParentView = self.view;
    [alertView setAlertViewBlock:^(NSInteger selectedIndex){
        if (selectedIndex == 1) {
            [YYOrderApi updateTransStatus:ws.currentYYOrderInfoModel.orderCode statusCode:YYOrderCode_DELIVERY force:YES andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSError *error) {
                if(rspStatusAndMessage.status == YYReqStatusCode100){
                    [YYToast showToastWithTitle:NSLocalizedString(@"操作成功",nil) andDuration:kAlertToastDuration];
                    if(ws.modifySuccess){
                        ws.modifySuccess();
                    }
                }
            }];
        }
    }];

    [alertView show];
}

#pragma mark - --------------自定义方法----------------------
-(void)updateUI{
    _undeliveredStylesArray = [_currentYYOrderInfoModel getUndeliveredStylesInDelivering];
}
#pragma mark - --------------other----------------------

@end

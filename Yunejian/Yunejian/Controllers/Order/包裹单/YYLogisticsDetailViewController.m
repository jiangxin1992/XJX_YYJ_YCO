//
//  YYLogisticsDetailViewController.m
//  Yunejian
//
//  Created by yyj on 2018/8/9.
//  Copyright © 2018年 yyj. All rights reserved.
//

#import "YYLogisticsDetailViewController.h"

// c文件 —> 系统文件（c文件在前）

// 控制器

// 自定义视图
#import "YYLogisticsDetailCell.h"

// 接口

// 分类

// 自定义类和三方类（ cocoapods类 > model > 工具类 > 其他）
#import "YYPackingListDetailModel.h"

@interface YYLogisticsDetailViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation YYLogisticsDetailViewController

#pragma mark - --------------生命周期--------------
- (void)viewDidLoad {
    [super viewDidLoad];
    [self SomePrepare];
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

    _titleLabel.text = [[NSString alloc] initWithFormat:NSLocalizedString(@"%@%@%@", nil),_packingListDetailModel.logisticsName,NSLocalizedString(@"：",nil),_packingListDetailModel.logisticsCode];

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    [_tableView reloadData];
}

//#pragma mark - --------------UIConfig----------------------
//- (void)UIConfig {
//
//}

//#pragma mark - --------------请求数据----------------------
//- (void)RequestData {
//
//}
#pragma mark - --------------系统代理----------------------
#pragma mark - TableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(!_packingListDetailModel){
        //数据还未加载出来
        return 0;
    }
    return _packingListDetailModel.express.data.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(!_packingListDetailModel){
        static NSString *cellid = @"cellid";
        UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:cellid];
        if(!cell){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        return cell;
    }

    static NSString *cellid = @"YYLogisticsDetailCell";
    YYLogisticsDetailCell *cell = [_tableView dequeueReusableCellWithIdentifier:cellid];
    if(!cell){
        cell = [[YYLogisticsDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    YYExpressItemModel *expressItemModel = _packingListDetailModel.express.data[indexPath.row];
    cell.expressItemModel = expressItemModel;
    if(!indexPath.row){
        cell.newestExpress = YES;
    }else{
        cell.newestExpress = NO;
    }
    [cell updateUI];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 10;
}

#pragma mark - --------------自定义代理/block----------------------


#pragma mark - --------------自定义响应----------------------
- (IBAction)closeBtnHander:(id)sender {
    if(self.cancelButtonClicked){
        self.cancelButtonClicked();
    }
}

#pragma mark - --------------自定义方法----------------------


#pragma mark - --------------other----------------------

@end

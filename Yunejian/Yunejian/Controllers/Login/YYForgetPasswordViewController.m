//
//  YYForgetPasswordViewController.m
//  Yunejian
//
//  Created by Apple on 16/10/14.
//  Copyright © 2016年 yyj. All rights reserved.
//

#import "YYForgetPasswordViewController.h"

#import "YYNavigationBarViewController.h"
#import "YYForgetPasswordTableStepCell.h"
#import "YYForgetPasswordTableInputEmailCell.h"
#import "YYForgetPasswordTableVerifyEmailCell.h"
#import "MBProgressHUD.h"
#import "YYUserApi.h"

@interface YYForgetPasswordViewController ()<UITableViewDataSource,UITableViewDelegate,YYTableCellDelegate>
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@end

@implementation YYForgetPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_tableView registerNib:[UINib nibWithNibName:@"YYForgetPasswordTableStepCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"YYForgetPasswordTableStepCell"];
    _tableView.scrollEnabled = NO;

}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    // 进入埋点
    [MobClick beginLogPageView:kYYPageForgetPassword];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    // 退出埋点
    [MobClick endLogPageView:kYYPageForgetPassword];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section == 0){
        return 1;
    }else{
        return 1;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    if(indexPath.section == 0){
        static NSString *CellIdentifier = @"YYForgetPasswordTableStepCell";
        YYForgetPasswordTableStepCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        if(_viewType == kForgetPasswordType){
            [cell updateCellInfo:@[@[NSLocalizedString(@"输入邮箱",nil),@"true"],@[NSLocalizedString(@"安全验证",nil),@""],@[NSLocalizedString(@"重设密码",nil),@""]]];
        }else if(_viewType == kEmailPasswordType){
            [cell updateCellInfo:@[@[NSLocalizedString(@"输入邮箱",nil),@"true"],@[NSLocalizedString(@"安全验证",nil),@"true"],@[NSLocalizedString(@"重设密码",nil),@""]]];
        }
        return cell;
    }else{
        if(_viewType == kForgetPasswordType){
            static NSString *CellIdentifier = @"YYForgetPasswordTableInputEmailCell";
            YYForgetPasswordTableInputEmailCell *cell1 = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            cell1.indexPath = indexPath;
            cell1.delegate = self;
            [cell1 updateCellInfo:nil];
            return cell1;
        }else if (_viewType == kEmailPasswordType){
            static NSString *CellIdentifier = @"YYForgetPasswordTableVerifyEmailCell";
            YYForgetPasswordTableVerifyEmailCell *cell2 = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            cell2.indexPath = indexPath;
            cell2.delegate = self;
            [cell2 updateCellInfo:@[_userEmail]];
            return cell2;
        }
        return [[UITableViewCell alloc] init];

    }
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0){
        return 100;
    }else{
        if(_viewType == kForgetPasswordType){
            return 280;
        }else if (_viewType == kEmailPasswordType){
            return 280;
        }
        return 80;
    }
}

#pragma YYTableCellDelegate
-(void)btnClick:(NSInteger)row section:(NSInteger)section andParmas:(NSArray *)parmas{
    NSString *content = [parmas objectAtIndex:0];
    NSInteger index = [[parmas objectAtIndex:1] integerValue];
    //提交申请
    WeakSelf(ws);
    if(index == -1){
        [MBProgressHUD showHUDAddedTo:self.view animated:NO];

        if(self.viewType == kForgetPasswordType){
            //YYRegisterTableCellInfoModel *infoModel = [self getCellData:0 row:1 index:0 content:nil];
            __block NSString *blockEmailstr = content;
            [YYUserApi forgetPassword:[NSString stringWithFormat:@"email=%@",content] andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSError *error) {
                [MBProgressHUD hideAllHUDsForView:ws.view animated:NO];
                if( rspStatusAndMessage.status == YYReqStatusCode100){
                    //[YYToast showToastWithTitle:@"提交成功!" andDuration:kAlertToastDuration];
                    ws.viewType = kEmailPasswordType;
                    ws.userEmail = blockEmailstr;
                    [ws.tableView reloadData];
                }else{
                    [YYToast showToastWithTitle:rspStatusAndMessage.message andDuration:kAlertToastDuration];
                }
            }];
        }else if(self.viewType == kEmailPasswordType){
            [MBProgressHUD hideAllHUDsForView:ws.view animated:NO];
            [ws backHandler:nil];
        }}
    return;
}


- (IBAction)backHandler:(id)sender {
    if(self.cancelButtonClicked){
        self.cancelButtonClicked();
    }
}

@end

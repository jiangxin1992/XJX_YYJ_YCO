//
//  YYSubShowroomPowerViewContorller.h
//  Yunejian
//
//  Created by yyj on 17/9/13.
//  Copyright (c) 2017年 yyj. All rights reserved.
//

#import "YYSubShowroomPowerViewContorller.h"

#import "YYUserApi.h"
#import "YYShowroomApi.h"
#import "YYRspStatusAndMessage.h"
#import "YYUser.h"

#import "MLInputDodger.h"

#import "RegexKitLite.h"

@interface YYSubShowroomPowerViewContorller ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UILabel *titleLabel;

/** 选择的项目 */
@property (nonatomic, strong) NSMutableArray *selectRow;
/** 文案集合 */
@property (nonatomic, strong) NSArray *rowTitle;

/** tableview */
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation YYSubShowroomPowerViewContorller


#pragma mark - --------------生命周期--------------
- (instancetype)init{

    if (self = [super init]) {
        // 设置显示模态父层控制器
        self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        // 设置淡入淡出的模态方式
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    }

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self SomePrepare];
}


#pragma mark - --------------SomePrepare--------------

-(void)SomePrepare
{
    [self PrepareData];
    [self PrepareUI];
    
}

-(void)PrepareData{


    if (self.defaultPowerArray) {
        self.selectRow = [NSMutableArray arrayWithArray:self.defaultPowerArray];
    }else{
        self.selectRow = [NSMutableArray array];
    }

    self.rowTitle = @[NSLocalizedString(@"品牌操作权限",nil),
                      NSLocalizedString(@"品牌报表查看权限",nil),
                      NSLocalizedString(@"Showroom 报表查看权限",nil),
                      NSLocalizedString(@"所有订单查看权限",nil),
                      NSLocalizedString(@"订货会审核查看权限",nil)];
}

#pragma mark - --------------UI----------------------

// 创建子控件
-(void)PrepareUI{

    // 乳白色的背景
    self.view.backgroundColor = [UIColor clearColor];
    // bg
    UIView *blackView = [[UIView alloc] init];
    blackView.backgroundColor = [UIColor colorWithHex:@"ffffff" alpha:0.6];
    [self.view addSubview:blackView];

    [blackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.bottom.mas_equalTo(0);
    }];


    // 黄颜色的背景
    UIView *yellowBackground = [[UIView alloc] init];
    yellowBackground.backgroundColor = [UIColor colorWithHex:@"FFE000"];
    [blackView addSubview:yellowBackground];

    [yellowBackground mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.centerY.mas_equalTo(0);
        make.width.mas_equalTo(460);
        make.height.mas_equalTo(510);
    }];

    // 黄色背景上的白色背景
    UIView *whiteBg = [[UIView alloc] init];
    whiteBg.backgroundColor = _define_white_color;
    [yellowBackground addSubview:whiteBg];

    [whiteBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(20);
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.bottom.mas_equalTo(-20);
    }];

    // 标题
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = NSLocalizedString(@"子账号权限", nil);
    titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [whiteBg addSubview:titleLabel];
    self.titleLabel = titleLabel;
    [titleLabel sizeToFit];

    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(yellowBackground.mas_centerX);
        make.top.mas_equalTo(35);
    }];

    // 选中列表
    UITableView *tableView = [[UITableView alloc] init];
    self.tableView = tableView;
    tableView.backgroundColor = _define_white_color;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorColor = [UIColor colorWithHex:@"EFEFEF"];
    tableView.scrollEnabled = NO;

    [whiteBg addSubview:tableView];

    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(42.5);
        make.right.mas_equalTo(-42.5);
        make.top.mas_equalTo(titleLabel.mas_bottom).mas_offset(37);
        make.height.mas_equalTo(275);
    }];

    // 保存按钮
    UIButton *saveButton = [[UIButton alloc] init];
    saveButton.backgroundColor = _define_black_color;
    [saveButton setTitle:NSLocalizedString(@"保存", nil) forState:UIControlStateNormal];
    [saveButton addTarget:self action:@selector(saveClicked:) forControlEvents:UIControlEventTouchUpInside];
    [whiteBg addSubview:saveButton];

    [saveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(whiteBg.mas_centerX);
        make.top.mas_equalTo(tableView.mas_bottom).mas_offset(40);
        make.width.mas_equalTo(200);
        make.height.mas_equalTo(38);
    }];

    // x按钮
    UIButton *cancelButton = [[UIButton alloc] init];
    [cancelButton setImage:[UIImage imageNamed:@"close_small"] forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelClicked:) forControlEvents:UIControlEventTouchUpInside];
    [whiteBg addSubview:cancelButton];

    [cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-10);
        make.top.mas_equalTo(10);
        make.width.mas_equalTo(44);
        make.height.mas_equalTo(44);
    }];
}

#pragma mark - --------------系统代理----------------------
#pragma mark - uitableview
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _rowTitle.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 54;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.5;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *header = [[UIView alloc] init];
    header.backgroundColor = [UIColor colorWithHex:@"EFEFEF"];
    return header;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"YYSubShowroomPowerViewContorller"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"YYSubShowroomPowerViewContorller"];
        cell.preservesSuperviewLayoutMargins = NO;
        cell.separatorInset = UIEdgeInsetsZero;
        cell.layoutMargins = UIEdgeInsetsZero;
        cell.selectedBackgroundView = [[UIView alloc] init];
        cell.selectedBackgroundView.backgroundColor = [UIColor colorWithHex:@"F8F8F8"];
        cell.textLabel.font = [UIFont systemFontOfSize:13.8];
    }

    BOOL isSelect = [self.selectRow containsObject:[NSString stringWithFormat:@"%li", (indexPath.row + 1)]];

    if (isSelect) {
        cell.imageView.image = [UIImage imageNamed:@"opus_selected_green_icon"];
    }else{
        cell.imageView.image = [UIImage imageNamed:@"opus_unselected_icon"];
    }

    cell.textLabel.text = NSLocalizedString(self.rowTitle[indexPath.row], nil);

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    // 记录已经存在的位置。 初始化为一个很大的数字 999
    NSInteger selectRowIndex = 999;
    for (int i = 0; i < self.selectRow.count; i++) {
        if (indexPath.row + 1 == [self.selectRow[i] intValue]) {
            selectRowIndex = i;
            break;
        }
    }

    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (selectRowIndex == 999) {
        // 修改图案成选中
        cell.imageView.image = [UIImage imageNamed:@"opus_selected_green_icon"];
        // 添加到array中
        [self.selectRow addObject:[NSString stringWithFormat:@"%li", indexPath.row+1]];
    }else{
        // 修改成未选中
        cell.imageView.image = [UIImage imageNamed:@"opus_unselected_icon"];
        // 从array中删除
        [self.selectRow removeObjectAtIndex:selectRowIndex];
    }

}

#pragma mark - --------------自定义代理/block----------------------


#pragma mark - --------------自定义响应----------------------
- (void)cancelClicked:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
    if (_cancelButtonClicked) {
        _cancelButtonClicked();
    }
}

- (void)saveClicked:(UIButton *)sender{

    [YYShowroomApi subShowroomPowerUserId:self.userId authList:self.selectRow andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSError *error) {

        if (rspStatusAndMessage.status == YYReqStatusCode100) {
            [YYToast showToastWithTitle:NSLocalizedString(@"操作成功！",nil) andDuration:kAlertToastDuration];
            // 退出
            [self dismissViewControllerAnimated:YES completion:nil];
            if (_modifySuccess) {
                _modifySuccess();
            }

        }else{
            [YYToast showToastWithTitle:rspStatusAndMessage.message andDuration:kAlertToastDuration];
        }
    }];
}

#pragma mark - --------------自定义方法----------------------


#pragma mark - --------------other----------------------

- (void)dealloc{

}

@end

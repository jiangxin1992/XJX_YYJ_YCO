//
//  YYChooseWarehouseView.m
//  Yunejian
//
//  Created by yyj on 2018/7/31.
//  Copyright © 2018年 yyj. All rights reserved.
//

#import "YYChooseWarehouseView.h"

// c文件 —> 系统文件（c文件在前）

// 控制器

// 自定义视图
#import "MBProgressHUD.h"
#import "YYChooseWarehouseCell.h"

// 接口

// 分类

// 自定义类和三方类（ cocoapods类 > model > 工具类 > 其他）
#import "YYWarehouseModel.h"

#define BACKVIEW_WIDTH 500
#define YY_ANIMATE_DURATION 0.5 //动画持续时间

@interface YYChooseWarehouseView()<UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate>

@property(nonatomic,copy) void (^chooseWarehouseSelectBlock)(YYWarehouseModel *warehouseModel);

@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UIView *navView;

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *warehouseListArray;

@property (nonatomic, assign) CGRect showFrame;
@property (nonatomic, assign) CGRect hideFrame;

@property (nonatomic, assign) BOOL isAnimation;

@end

@implementation YYChooseWarehouseView

#pragma mark - --------------生命周期--------------
-(instancetype)initWithWarehouseArray:(NSArray *)warehouseArray WithBlock:(void (^)(YYWarehouseModel *warehouseModel))block{
    self = [super initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    if(self){
        _chooseWarehouseSelectBlock = block;
        _warehouseListArray = warehouseArray;
        [self SomePrepare];
        [self UIConfig];
        [self isShowBackView:YES];
    }
    return self;
}

#pragma mark - --------------SomePrepare--------------
- (void)SomePrepare {
    [self PrepareData];
    [self PrepareUI];
}
- (void)PrepareData {
    _isAnimation = NO;
    _showFrame = CGRectMake(SCREEN_WIDTH - BACKVIEW_WIDTH, 20, BACKVIEW_WIDTH, SCREEN_HEIGHT - 20);
    _hideFrame = CGRectMake(SCREEN_WIDTH, 20, BACKVIEW_WIDTH, SCREEN_HEIGHT - 20);
}
- (void)PrepareUI {
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];

    UITapGestureRecognizer *oneTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeAction)];
    oneTap.delegate = self;
    oneTap.numberOfTouchesRequired = 1;
    [self addGestureRecognizer:oneTap];
}

#pragma mark - --------------UIConfig----------------------
- (void)UIConfig {
    [self createBackView];
    [self createNavVew];
    [self CreateTableView];
}
-(void)createBackView{
    _backView = [UIView getCustomViewWithColor:_define_white_color];
    [self addSubview:_backView];
    _backView.frame = _hideFrame;
    _backView.hidden = YES;
}
-(void)createNavVew{
    WeakSelf(ws);
    _navView = [UIView getCustomViewWithColor:nil];
    [_backView addSubview:_navView];
    [_navView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(50);
        make.top.left.right.mas_equalTo(0);
    }];

    UIView *bottomview = [UIView getCustomViewWithColor:[UIColor colorWithHex:@"D3D3D3"]];
    [_navView addSubview:bottomview];
    [bottomview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        make.height.mas_equalTo(1);
    }];

    UIButton *closeBtn = [UIButton getCustomImgBtnWithImageStr:@"close_small" WithSelectedImageStr:nil];
    [_navView addSubview:closeBtn];
    [closeBtn addTarget:self action:@selector(closeAction) forControlEvents:UIControlEventTouchUpInside];
    [closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.bottom.mas_equalTo(bottomview.mas_top).with.offset(0);
        make.width.mas_equalTo(51);
    }];

    UILabel *titleLabel = [UILabel getLabelWithAlignment:1 WithTitle:nil WithFont:17.0f WithTextColor:nil WithSpacing:0];
    [_navView addSubview:titleLabel];
    titleLabel.text = NSLocalizedString(@"选择地址",nil);
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.bottom.mas_equalTo(bottomview.mas_top).with.offset(0);
        make.centerX.mas_equalTo(ws.navView);
        make.width.mas_equalTo(200);
    }];
}
-(void)CreateTableView
{
    WeakSelf(ws);
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    [_backView addSubview:_tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        make.top.mas_equalTo(ws.navView.mas_bottom).with.offset(0);
    }];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = _define_white_color;
}
//#pragma mark - --------------请求数据----------------------
//- (void)RequestData {
//
//}

#pragma mark - --------------系统代理----------------------
#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    // 输出点击的view的类名
    NSLog(@"%@", NSStringFromClass([touch.view class]));

    // 若为UITableViewCellContentView（即点击了tableViewCell），则不截获Touch事件
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {
        return NO;
    }
    return  YES;
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_warehouseListArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //    数据还未获取时候
    if(!_warehouseListArray.count)
    {
        static NSString *cellid = @"UITableViewCell";
        UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:cellid];
        if(!cell)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }

    static NSString *cellid = @"YYChooseWarehouseCell";
    YYChooseWarehouseCell *cell = [_tableView dequeueReusableCellWithIdentifier:cellid];
    if(!cell)
    {
        cell = [[YYChooseWarehouseCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
    }
    cell.warehouseModel = _warehouseListArray[indexPath.row];
    [cell updateUI];
    return cell;
}
//- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 10;
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(_chooseWarehouseSelectBlock){
        YYWarehouseModel *warehouseModel = _warehouseListArray[indexPath.row];
        _chooseWarehouseSelectBlock(warehouseModel);
    }
    [self isShowBackView:NO];
}

#pragma mark - --------------自定义代理/block----------------------


#pragma mark - --------------自定义响应----------------------
-(void)closeAction{
    [self isShowBackView:NO];
}

#pragma mark - --------------自定义方法----------------------
-(void)isShowBackView:(BOOL )isShow{
    WeakSelf(ws);
    if(!_isAnimation && _backView){
        _backView.hidden = NO;
        if(isShow){
            //显示
            _backView.frame = _hideFrame;
            _isAnimation = YES;
            [UIView animateWithDuration:YY_ANIMATE_DURATION animations:^{
                ws.backView.frame = ws.showFrame;
            } completion:^(BOOL finished) {
                ws.isAnimation = NO;
            }];
        }else{
            //隐藏
            _backView.frame = _showFrame;
            _isAnimation = YES;
            [UIView animateWithDuration:YY_ANIMATE_DURATION animations:^{
                ws.backView.frame = ws.hideFrame;
            } completion:^(BOOL finished) {
                ws.isAnimation = NO;
                [ws removeFromSuperview];
            }];
        }

    }
}

#pragma mark - --------------other----------------------

@end

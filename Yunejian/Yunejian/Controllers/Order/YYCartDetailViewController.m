//
//  YYCartDetailViewController.m
//  Yunejian
//
//  Created by lixuezhi on 15/8/17.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import "YYCartDetailViewController.h"

// c文件 —> 系统文件（c文件在前）

// 控制器
#import "YYCustomCellTableViewController.h"
#import "YYTaxChooseViewController.h"
#import "YYStyleDetailViewController.h"

// 自定义视图
#import "YYStyleDetailCell.h"
#import "YYTopAlertView.h"
#import "ASPopUpView.h"

// 接口
#import "YYOrderApi.h"
#import "YYUserApi.h"

// 分类
#import "UIView+UpdateAutoLayoutConstraints.h"
#import "UIImage+Tint.h"

// 自定义类和三方类（ cocoapods类 > model > 工具类 > 其他）
#import "YYUser.h"
#import "Series.h"
#import "YYOrderOneInfoModel.h"
#import "YYOrderStyleModel.h"
#import "YYOpusSeriesModel.h"
#import "YYOrderInfoModel.h"
#import "YYStylesAndTotalPriceModel.h"
#import "YYOpusStyleModel.h"

#import "AppDelegate.h"
#import "UserDefaultsMacro.h"

@interface YYCartDetailViewController ()<UITableViewDataSource, UITableViewDelegate,UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *titelLab;
@property (weak, nonatomic) IBOutlet UIButton *backBtn;
@property (nonatomic, strong) NSMutableArray *seriesArr;
@property (nonatomic, strong) AppDelegate *appdelegate;

@property (weak, nonatomic) IBOutlet UILabel *countLab;
@property (weak, nonatomic) IBOutlet UILabel *priceLab;
@property (weak, nonatomic) IBOutlet UILabel *taxPriceLab;
@property (weak, nonatomic) IBOutlet UIButton *buildOrderBtn;
@property (weak, nonatomic) IBOutlet UIButton *clearBtn;
@property (weak, nonatomic) IBOutlet UIButton *editBtn;
@property (weak, nonatomic) IBOutlet UIView *bottomView;

//约束线
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *totalPriceTrailing;
@property (assign, nonatomic) NSInteger totalPriceNeedWidth;

//编辑状态下的按钮
@property (weak, nonatomic) IBOutlet UIButton *selectAllBtn;
@property (weak, nonatomic) IBOutlet UIButton *delateBtn;
@property (weak, nonatomic) IBOutlet UIButton *finishEditBtn;

@property (assign, nonatomic) NSInteger selectTaxType;
@property (weak, nonatomic) IBOutlet UIButton *taxTypeBtn;
@property(nonatomic,strong) UIPopoverController *popController;

@property (nonatomic, assign) BOOL isOrderEdit;
@property (nonatomic, strong) NSMutableArray *selectedArray;

@property (nonatomic,strong) UIView *noDataView;

@property(nonatomic,strong) YYStylesAndTotalPriceModel *stylesAndTotalPriceModel;//总数

@property (nonatomic, strong)YYOrderStyleModifyReslutModel *styleModifyReslut;

@property (weak, nonatomic) IBOutlet UIButton *minOrderMoneyBtn1;
@property (strong, nonatomic) NSString *minOrderMoneyTip;
@property (strong, nonatomic) ASPopUpView *popUpView;

@property (nonatomic,strong) NSMutableArray *menuData;
@property(nonatomic,assign) UIView *parentView;
@end

@implementation YYCartDetailViewController

#pragma mark - --------------生命周期--------------
- (void)viewDidLoad {
    [super viewDidLoad];
    [self SomePrepare];
    [self UIConfig];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    [self loadShoppingCarData];
    // 进入埋点
    [MobClick beginLogPageView:kYYPageCartDetail];

}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    // 退出埋点
    [MobClick endLogPageView:kYYPageCartDetail];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
-(void)OnTapBg:(UITapGestureRecognizer *)sender{
    //if(self.popUpView){
    [self hidePopUpViewAnimated:NO];
    //}
}

- (void)showPopUpViewAnimated:(BOOL)animated
{
    if (self.popUpView.alpha == 1.0) return;
    [self.popUpView showAnimated:animated];
}

- (void)hidePopUpViewAnimated:(BOOL)animated
{
    if (self.popUpView.alpha == 0.0) return;
    //    WeakSelf(weakSelf);
    [self.popUpView hideAnimated:animated completionBlock:^{
        //weakSelf.popUpView = nil;
    }];
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    NSLog(@"%@",NSStringFromClass([touch.view class]));
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"] || [NSStringFromClass([touch.view class]) isEqualToString:@"UIControl"] ||
        [NSStringFromClass([touch.view class]) isEqualToString:@"UIButton"]) {//如果当前是tableView

        //做自己想做的事
        [self hidePopUpViewAnimated:NO];
        return NO;
    }
    return YES;
}
#pragma mark --设置状态栏的颜色
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
#pragma mark - --------------SomePrepare--------------
- (void)SomePrepare
{
    [self PrepareData];
    [self PrepareUI];
}
- (void)PrepareData{

    _menuData = getPayTaxInitData();
    _selectTaxType = 0;
    //获取appdelegate的存储信息
    _appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateShoppingCarNotification:) name:kUpdateShoppingCarNotification object:nil];

}
- (void)updateShoppingCarNotification:(NSNotification *)note{
    [self loadShoppingCarData];
    [self.tableView reloadData];
}

- (void)PrepareUI{

    self.buildOrderBtn.layer.borderWidth = 1;
    self.buildOrderBtn.layer.borderColor = [UIColor whiteColor].CGColor;

    self.tableView.dataSource = self;
    self.tableView.delegate = self;

    self.view.backgroundColor = [UIColor blackColor];

    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
    [self.selectAllBtn setImage:[UIImage imageNamed:@"circle"] forState:UIControlStateNormal];
    self.selectAllBtn.selected = NO;
    [self.selectAllBtn setImage:[UIImage imageNamed:@"circle"] forState:UIControlStateNormal];
    [self.selectAllBtn setImage:[UIImage imageNamed:@"checkmark"] forState:UIControlStateSelected];
    [self finishEditBtnAction:nil];
    [self updateTaxTypeUI];
    if (!self.seriesArr || [self.seriesArr count] <= 0) {
        self.noDataView = addNoDataView_pad(self.view,NSLocalizedString(@"暂无数据",nil),nil,nil);
    }

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(OnTapBg:)];
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
}

#pragma mark - --------------UIConfig----------------------
-(void)UIConfig{}

#pragma mark - --------------系统代理----------------------
#pragma mark -UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (self.seriesArr.count != 0) {
        return _seriesArr.count;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.seriesArr.count != 0) {
        YYOrderOneInfoModel *oneInfoModel = _seriesArr[section];
        return oneInfoModel.styles.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    YYOrderOneInfoModel *oneInfoModel = _seriesArr[indexPath.section];

    static NSString *CellIdentifier = @"YYStyleDetailCell";
    YYStyleDetailCell *cell =  [_tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(!cell){
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"OrderDetail" bundle:[NSBundle mainBundle]];
        YYCustomCellTableViewController *customCellTableViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYCustomCellTableViewController"];
        cell = [customCellTableViewController.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    }
    if (!cell) {
        cell = [[YYStyleDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"YYStyleDetailCell"];
    }

    WeakSelf(ws);
    cell.selectCellButtonClicked = ^(BOOL isSelectedNow,YYOrderStyleModel *orderStyleModel){
        YYOrderStyleModel *tmpOrderStyleModel =[self checkArrayContainMode:ws.selectedArray model:orderStyleModel];
        if (isSelectedNow) {

            if (tmpOrderStyleModel == nil) {
                [ws.selectedArray addObject:orderStyleModel];
            }
        }else{
            if (tmpOrderStyleModel != nil) {
                [ws.selectedArray removeObject:tmpOrderStyleModel];
            }
        }
        [self updateSelectBtnAndCellSelectStatus];
    };

    cell.coverButtonClicked = ^(YYOrderOneInfoModel *orderOneInfoModel,YYOrderStyleModel *orderStyleModel){
        [ws showOpusDetailViewWithOrderOneInfoModel:orderOneInfoModel orderStyleModel:orderStyleModel];
    };

    if (self.finishEditBtn.hidden) {
        cell.clickCoverShowDetail = YES;
    }else{
        cell.clickCoverShowDetail = NO;
    }

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.checkButtonIsChecked = NO;
    if ([_selectedArray count] > 0) {

        YYOrderStyleModel *tmpOrderStyleModel = oneInfoModel.styles[indexPath.row];
        if([self checkArrayContainMode:_selectedArray model:tmpOrderStyleModel]){
            cell.checkButtonIsChecked = YES;
        }
    }

    cell.menuData = _menuData;
    cell.orderStyleModel = oneInfoModel.styles[indexPath.row];
    cell.orderOneInfoModel = _seriesArr[indexPath.section];
    cell.seriesId = [cell.orderStyleModel.seriesId longValue];
    cell.isModifyNow = self.isOrderEdit;
    cell.isShowCheckNow = YES;
    cell.showTotal = YES;
    cell.showHaveNotAchieveOrderAmountMin = YES;
    cell.selectTaxType = _selectTaxType;
    if(_styleModifyReslut && [_styleModifyReslut.result containsObject:cell.orderStyleModel.styleId ]){
        [cell setIsStyleModifyView:YES];
    }else{
        [cell setIsStyleModifyView:NO];
    }
    [cell updateUI];

    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    YYOrderOneInfoModel *oneInfoModel = _seriesArr[indexPath.section];
    YYOrderStyleModel *styleModel = oneInfoModel.styles[indexPath.row];
    NSInteger totalamount = 0;
    for (int i=0; i<[styleModel.colors count]; i++) {
        YYOrderOneColorModel *orderOneColorModel = [styleModel.colors objectAtIndex:i];
        if(checkOrderOneColorHasAmount(orderOneColorModel) || [orderOneColorModel.isColorSelect boolValue]){
            totalamount ++;
        }
    }
    return 210 + totalamount * 50 - 30 - 30 + 45;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    YYOrderOneInfoModel *oneInfoModel = _seriesArr[indexPath.section];
    NSInteger row = indexPath.row;
    YYOrderStyleModel *orderStyleModel = oneInfoModel.styles[row];
    orderStyleModel.tmpDateRange = oneInfoModel.dateRange;
    YYOrderSeriesModel *orderseriesModel = [_appdelegate.cartModel.seriesMap objectForKey:[orderStyleModel.seriesId stringValue]];
    if(orderStyleModel == nil || orderseriesModel == nil){
        return;
    }

    UIView *superView = self.view;
    [appDelegate showShoppingViewNew:NO styleInfoModel:orderStyleModel seriesModel:orderseriesModel opusStyleModel:nil currentYYOrderInfoModel:nil parentView:superView fromBrandSeriesView:NO WithBlock:nil];
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{

    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{

}

#pragma mark - --------------自定义代理/block----------------------


#pragma mark - --------------自定义响应----------------------
//清除购物车
- (IBAction)clearBtnAction:(id)sender {
    WeakSelf(ws);
    CMAlertView *alertView = [[CMAlertView alloc] initWithTitle:NSLocalizedString(@"确认要清空购物车吗？",nil) message:nil needwarn:NO delegate:nil cancelButtonTitle:NSLocalizedString(@"取消",nil) otherButtonTitles:@[[NSString stringWithFormat:@"%@|000000",NSLocalizedString(@"确认",nil)]]];
    alertView.specialParentView = self.view;
    [alertView setAlertViewBlock:^(NSInteger selectedIndex){
        if (selectedIndex == 1) {
            [ws.seriesArr removeAllObjects];
            [ws.tableView reloadData];
            [_appdelegate clearBuyCar];

            if (ws.goBackButtonClicked) {
                ws.goBackButtonClicked();
            }
        }
    }];
    [alertView show];
}

//编辑按钮
- (IBAction)editBtnAction:(id)sender {
    //显示编辑状态下的按钮
    self.selectAllBtn.hidden = NO;
    self.selectAllBtn.selected = NO;
    self.delateBtn.hidden = NO;
    self.finishEditBtn.hidden = NO;
    //隐藏非编辑状态下的按钮
    self.buildOrderBtn.hidden = YES;
    self.clearBtn.hidden = YES;
    self.editBtn.hidden = YES;
    self.delateBtn.userInteractionEnabled = NO;
    self.delateBtn.alpha = 0.6;
    self.isOrderEdit = YES;
    self.backBtn.hidden = YES;
    self.titelLab.text = NSLocalizedString(@"编辑购物车",nil);
    //改变约束
    self.totalPriceTrailing.constant = 45+_totalPriceNeedWidth +(_totalPriceNeedWidth?35:0);//self.totalPriceTrailing.constant - 200;
    [self.tableView reloadData];
}
//全选按钮
- (IBAction)selectAllAction:(id)sender {
    self.selectAllBtn.selected = !self.selectAllBtn.selected;
    [self.selectedArray removeAllObjects];

    for (int i = 0; i < self.seriesArr.count; i++) {
        YYOrderOneInfoModel *oneInfoModel = _seriesArr[i];
        if (self.selectAllBtn.selected) {
            [self.selectedArray addObjectsFromArray:oneInfoModel.styles];
        }
    }
    [self updateSelectBtnAndCellSelectStatus];
}
//删除按钮
- (IBAction)delateBtnAction:(id)sender {
    NSMutableArray *seriesIds =  [[NSMutableArray alloc] init];
    if ([_selectedArray count] > 0) {
        NSInteger i = [self.seriesArr count]-1;
        for (; i>=0; i--) {
            YYOrderOneInfoModel *orderOneInfoModel = [self.seriesArr objectAtIndex:i];
            if (orderOneInfoModel) {
                if ([orderOneInfoModel.styles count] > 0) {
                    [orderOneInfoModel.styles removeObjectsInArray:_selectedArray];
                    if ([orderOneInfoModel.styles count] == 0) {
                        [self.seriesArr removeObject:orderOneInfoModel];
                    }else{
                        for (YYOrderStyleModel *orderStyleModel in orderOneInfoModel.styles) {
                            if(![seriesIds containsObject:[orderStyleModel.seriesId stringValue]]){
                                [seriesIds addObject:[orderStyleModel.seriesId stringValue]];
                            }
                        }
                    }

                }
            }
        }
        //删除系列队列seriesMap
        NSArray *allKeys = [_appdelegate.cartModel.seriesMap allKeys];
        for (NSString *seriesId in  allKeys) {
            if(![seriesIds containsObject:seriesId]){
                [_appdelegate.cartModel.seriesMap removeObjectForKey:seriesId];
            }
        }
    }

    [_selectedArray removeAllObjects];
    [self.tableView reloadData];
    [self updateSelectBtnAndCellSelectStatus];

    if ([self.seriesArr count] > 0) {
        [self setValue:self.seriesArr forKeyPath:@"appdelegate.cartModel.groups"];
        //储存对象的JSONString
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        NSString *jsonString = _appdelegate.cartModel.toJSONString;
        [userDefault setObject:jsonString forKey:KUserCartKey];
        [userDefault synchronize];
    }else{
        [_appdelegate clearBuyCar];

        if (self.goBackButtonClicked) {
            self.goBackButtonClicked();
        }
    }
}
//完成编辑按钮
- (IBAction)finishEditBtnAction:(id)sender {
    //隐藏编辑状态下的按钮
    self.selectAllBtn.hidden = YES;
    self.delateBtn.hidden = YES;
    self.finishEditBtn.hidden = YES;
    //显示非编辑状态下的按钮
    self.buildOrderBtn.hidden = NO;
    self.clearBtn.hidden = NO;
    self.editBtn.hidden = NO;
    self.isOrderEdit = NO;
    self.backBtn.hidden = NO;
    self.titelLab.text = NSLocalizedString(@"购物车",nil);

    //改变约束
    if(sender != nil){
        self.totalPriceTrailing.constant = 210+_totalPriceNeedWidth +(_totalPriceNeedWidth?35:0);
        [self.tableView reloadData];
    }
    [self loadShoppingCarData];
    self.selectedArray = [[NSMutableArray alloc] initWithCapacity:0];

}
- (IBAction)backBtnAction:(id)sender {
    [self hidePopUpViewAnimated:NO];
    if (self.goBackButtonClicked) {
        self.goBackButtonClicked();
    }
}
- (IBAction)showTaxTypeMenu:(id)sender {

    //跳转税率选择界面
    YYTaxChooseViewController *chooseTaxView = [[YYTaxChooseViewController alloc] init];
    chooseTaxView.selectIndex = _selectTaxType;
    chooseTaxView.selectData = _menuData;
    WeakSelf(ws);
    __block YYTaxChooseViewController *tempChooseTaxView = chooseTaxView;
    [chooseTaxView setCancelButtonClicked:^(){
        removeFromSuperviewUseUseAnimateAndDeallocViewController(tempChooseTaxView.view,tempChooseTaxView);
    }];
    [chooseTaxView setSelectBlock:^(NSInteger selectIndex){
        ws.selectTaxType = selectIndex;
        if(selectIndex != 2){
            ws.menuData = getPayTaxInitData();
        }
        removeFromSuperviewUseUseAnimateAndDeallocViewController(tempChooseTaxView.view,tempChooseTaxView);
        [ws.tableView reloadData];
        [ws updateTaxTypeUI];
        NSLog(@"111");
    }];
    [self addToWindow:chooseTaxView parentView:self.view];

}
#pragma mark -warnOrderMinMoney
- (IBAction)warnOrderMinMoney:(id)sender {
    [self hidePopUpViewAnimated:NO];
    if(self.popUpView == nil){
        self.popUpView = [[ASPopUpView alloc] initWithFrame:CGRectZero];
        self.popUpView.alpha = 0.0;
        [self.popUpView setFont:[UIFont systemFontOfSize:12]];
        [self.popUpView setTextColor:[UIColor colorWithHex:@"ef4e31"]];
        [self.popUpView setColor:[UIColor colorWithHex:@"ef4e31"]];
        [_bottomView addSubview:self.popUpView];
    }
    NSString *string =  _minOrderMoneyTip;
    CGSize size = [self.popUpView popUpSizeForString:string];
    float popUpViewOffsetX = -(size.width+10)/2+CGRectGetMidX(_minOrderMoneyBtn1.frame);
    popUpViewOffsetX = MIN(SCREEN_WIDTH-size.width-10, popUpViewOffsetX);
    CGRect popUpRect = CGRectMake(popUpViewOffsetX,5, size.width+10, size.height+20);
    [self.popUpView setFrame:popUpRect arrowOffset:0 text:string];
    [self showPopUpViewAnimated:YES];
}
#pragma mark -建立意向单
- (IBAction)buildOrderBtnAction:(id)sender {
    WeakSelf(ws);
    YYUser *user = [YYUser currentUser];
    if (![YYNetworkReachability connectedToNetwork]) {

        if(user.userStatus == kUserStatusOk){
            [ws checkStylesModify];
        }else{

            [YYToast showToastWithView:ws.view title:NSLocalizedString(@"您还没有通过品牌身份认证，不能建立订单",nil) andDuration:kAlertToastDuration];
        }
        return;
    }

    [YYUserApi getUserStatus:-1 andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSInteger status, NSError *error) {
        if(rspStatusAndMessage.status == kCode100){
            if(status == kUserStatusOk){
                [ws checkStylesModify];
            }else{
                [YYToast showToastWithView:ws.view title:NSLocalizedString(@"您还没有通过品牌身份认证，不能建立订单",nil) andDuration:kAlertToastDuration];
            }
        }else{
            [YYToast showToastWithView:ws.view title:rspStatusAndMessage.message andDuration:kAlertToastDuration];
        }
    }];
}
#pragma mark - --------------自定义方法----------------------

//加载购物车数据
- (void)loadShoppingCarData{
    _minOrderMoneyBtn1.hidden = YES;
    self.seriesArr = _appdelegate.cartModel.groups;
    self.stylesAndTotalPriceModel = [_appdelegate.cartModel getTotalValueByOrderInfo:NO];
    self.countLab.text = [NSString stringWithFormat:NSLocalizedString(@"共计%d款 %d件",nil), self.stylesAndTotalPriceModel.totalStyles, self.stylesAndTotalPriceModel.totalCount];
    if(needPayTaxView(_appdelegate.cartMoneyType)){
        _taxTypeBtn.enabled = YES;
        _taxTypeBtn.alpha = 1;
    }else{
        _taxTypeBtn.enabled = NO;
        _taxTypeBtn.alpha = 0.5;
    }
    if(_selectTaxType && needPayTaxView(_appdelegate.cartMoneyType) ){
        [self.taxPriceLab hideByHeight:NO];
        self.taxPriceLab.text = replaceMoneyFlag([NSString stringWithFormat:@"%@￥%.2f",NSLocalizedString(@"总价",nil),[self.stylesAndTotalPriceModel.finalTotalPrice doubleValue]],_appdelegate.cartMoneyType);
        self.taxPriceLab.font = [UIFont boldSystemFontOfSize:16];
        
        self.priceLab.text = replaceMoneyFlag([NSString stringWithFormat:@"%@￥%0.2f",NSLocalizedString(@"税前",nil),[self.stylesAndTotalPriceModel.originalTotalPrice doubleValue]],_appdelegate.cartMoneyType);
        self.priceLab.font = [UIFont systemFontOfSize:14];
    }else{
        self.priceLab.text = replaceMoneyFlag([NSString stringWithFormat:@"%@￥%0.2f",NSLocalizedString(@"总价",nil),[self.stylesAndTotalPriceModel.originalTotalPrice doubleValue]],_appdelegate.cartMoneyType);
        self.priceLab.font = [UIFont boldSystemFontOfSize:16];
        [self.taxPriceLab hideByHeight:YES];
    }
    CGSize priceTxtSize = [ self.priceLab.text sizeWithAttributes:@{NSFontAttributeName: self.priceLab.font}];
    [self.priceLab setConstraintConstant:priceTxtSize.width+1 forAttribute:NSLayoutAttributeWidth];
    _totalPriceNeedWidth = 0;
    if(!self.taxPriceLab.hidden){
        priceTxtSize = [ self.taxPriceLab.text sizeWithAttributes:@{NSFontAttributeName: self.taxPriceLab.font}];
        _totalPriceNeedWidth = priceTxtSize.width+1;
        [self.taxPriceLab setConstraintConstant:priceTxtSize.width+1 forAttribute:NSLayoutAttributeWidth];
    }

    if(self.isOrderEdit){
        _totalPriceTrailing.constant = 45+_totalPriceNeedWidth +(_totalPriceNeedWidth?35:0);
    }else{
        _totalPriceTrailing.constant = 210+_totalPriceNeedWidth +(_totalPriceNeedWidth?35:0);
    }
    
    __block double blockcostMeoney = [self.stylesAndTotalPriceModel.finalTotalPrice doubleValue];
    __block float blockcurType = _appdelegate.cartMoneyType;
    WeakSelf(ws);
    if(_appdelegate.cartMoneyType >= 0){
        [YYOrderApi getOrderUnitPrice:[_appdelegate.cartModel.designerId unsignedIntegerValue] moneyType:blockcurType andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSUInteger orderUnitPrice, NSError *error) {
            if(orderUnitPrice > blockcostMeoney){
                UIImage *icon = [[UIImage imageNamed:@"warn"] imageWithTintColor:[UIColor colorWithHex:@"ef4e31"]];
                [ws.minOrderMoneyBtn1 setImage:icon forState:UIControlStateNormal];
                ws.minOrderMoneyTip = replaceMoneyFlag([NSString stringWithFormat:NSLocalizedString(@"未达到每单起订额\n ￥%ld",nil),(unsigned long)orderUnitPrice],blockcurType);
                ws.minOrderMoneyBtn1.hidden = NO;
            }
        }];
    }
    [self.tableView reloadData];
}

-(YYOrderStyleModel *)checkArrayContainMode:(NSArray*)array model:(YYOrderStyleModel*)model{
    for (YYOrderStyleModel *selectOrderStyleModel in array) {
        if (model.styleId == selectOrderStyleModel.styleId) {
            return  selectOrderStyleModel;
        }
    }
    return nil;
}
- (void)showOpusDetailViewWithOrderOneInfoModel:(YYOrderOneInfoModel *)oneInfoModel orderStyleModel:(YYOrderStyleModel *)styleModel{
    if (self.finishEditBtn.hidden
        && oneInfoModel
        && styleModel) {
        YYOrderInfoModel *cartModel = _appdelegate.cartModel;

        YYOpusSeriesModel *opusSeriesModel = [[YYOpusSeriesModel alloc] init];
        opusSeriesModel.designerId = cartModel.designerId;
        opusSeriesModel.albumImg = styleModel.albumImg;
        YYOrderSeriesModel *seriesModel = [cartModel.seriesMap objectForKey:[styleModel.seriesId stringValue]];
        if(seriesModel != nil){
            opusSeriesModel.supplyStatus = seriesModel.supplyStatus;
            opusSeriesModel.orderAmountMin = seriesModel.orderAmountMin;
            opusSeriesModel.name = styleModel.name;
            opusSeriesModel.id = styleModel.seriesId;
        }
        
        YYOpusStyleModel *opusStyleModel = [[YYOpusStyleModel alloc] init];
        opusStyleModel.albumImg = styleModel.albumImg;
        opusStyleModel.modifyTime = [styleModel.styleModifyTime stringValue];
        opusStyleModel.name = styleModel.name;
        opusStyleModel.id = styleModel.styleId;
        opusStyleModel.seriesId = styleModel.seriesId;
        opusStyleModel.styleCode = styleModel.styleCode;
        opusStyleModel.tradePrice = styleModel.originalPrice;
        opusStyleModel.retailPrice = styleModel.retailPrice;
        opusStyleModel.dateRange = oneInfoModel.dateRange;
      
        NSMutableArray * onlineOpusStyleArray = [[NSMutableArray alloc] initWithCapacity:0];
        [onlineOpusStyleArray addObject:opusStyleModel];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Opus" bundle:[NSBundle mainBundle]];
        YYStyleDetailViewController *styleDetailViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYStyleDetailViewController"];
        styleDetailViewController.onlineOrOfflineOpusStyleArray = onlineOpusStyleArray;
        
        
        NSString *folderName = [NSString stringWithFormat:@"%li",[styleModel.seriesId longValue]];
        NSString *offlineFilePath = [yyjOfflineSeriesDirectory() stringByAppendingPathComponent:folderName];
        NSString *styleListJsonPath = [offlineFilePath stringByAppendingPathComponent:@"styleList.json"];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:styleListJsonPath]){
            styleDetailViewController.currentDataReadType = DataReadTypeOffline;
        }else{
            if ([YYNetworkReachability connectedToNetwork]) {
                styleDetailViewController.currentDataReadType = DataReadTypeOnline;
            }else{
                styleDetailViewController.currentDataReadType = DataReadTypeCached;
                styleDetailViewController.cachedOpusStyleArray = onlineOpusStyleArray;
            }
        }
        
        styleDetailViewController.opusSeriesModel = opusSeriesModel;
        styleDetailViewController.currentIndex = 0;
        styleDetailViewController.isModityCart = YES;
        styleDetailViewController.totalPages = 1;
        [self.navigationController pushViewController:styleDetailViewController animated:YES];
    }

}
-(void)checkStylesModify{
    WeakSelf(ws);
    YYOrderInfoModel *orderInfoModel = [[YYOrderInfoModel alloc] initWithDictionary:[_appdelegate.cartModel toDictionary] error:nil];


    //判断是否存在仅选颜色的款式
    BOOL haveSelectColorStyle = NO;
    for (YYOrderOneInfoModel *orderOneInfoModel in orderInfoModel.groups) {
        for (YYOrderStyleModel *orderStyleModel in orderOneInfoModel.styles) {
            for (YYOrderOneColorModel *orderOneColorModel in orderStyleModel.colors) {
                if([orderOneColorModel.isColorSelect boolValue]){
                    haveSelectColorStyle = YES;
                    break;
                }
            }
        }
    }

    if(haveSelectColorStyle){
        [YYToast showToastWithView:self.view title:NSLocalizedString(@"对不起，无法创建订单！\n请补全所选款式的尺码和数量",nil) andDuration:kAlertToastDuration];
        return;
    }


    NSMutableArray *styleInfo = [[NSMutableArray alloc] initWithCapacity:[orderInfoModel.groups count]];
    NSMutableDictionary *styleNameDic = [[NSMutableDictionary alloc] init];
    for(YYOrderOneInfoModel *oneInfoModel in orderInfoModel.groups) {
        for (YYOrderStyleModel *styleModel in oneInfoModel.styles) {
            [styleInfo addObject:[NSString stringWithFormat:@"%@:%@",[styleModel.styleId stringValue],[styleModel.styleModifyTime stringValue]]];
            [styleNameDic setValue:styleModel.name forKey:[styleModel.styleId stringValue]];
        }
    }
    __block NSMutableDictionary *blockStyleNameDic = styleNameDic;
    _styleModifyReslut = nil;
    NSString *styleInfoJsonString = [NSString stringWithFormat:@"{%@}",[styleInfo componentsJoinedByString:@","]];
    [YYOrderApi isStyleModify:styleInfoJsonString andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYOrderStyleModifyReslutModel *styleModifyReslut, NSError *error) {
        if (rspStatusAndMessage.status == kCode203) {
            NSMutableArray *styleNameArray = [[NSMutableArray alloc] init];
            for (NSString *styleId in styleModifyReslut.result) {
                NSString *styleName = [blockStyleNameDic objectForKey:[NSString stringWithFormat:@"%@",styleId]];
                [styleNameArray addObject:styleName];
            }
            
            ws.styleModifyReslut = styleModifyReslut;
            [ws.tableView reloadData];

            
            if([styleNameArray count] >0 && [styleNameArray count] == [blockStyleNameDic count]){//全部失效
                [YYToast showToastWithView:ws.view title:[NSString stringWithFormat:NSLocalizedString(@"%@ 已过期,处理后才能下单",nil),[styleNameArray componentsJoinedByString:@","]] andDuration:kAlertToastDuration];
            }else{
                
            CMAlertView *alertView = [[CMAlertView alloc] initWithTitle:NSLocalizedString(@"忽略失效款式，继续建立订单",nil) message:[NSString stringWithFormat:NSLocalizedString(@"有%d个款式已失效，继续建立订单此款式不会在订单中出现。",nil),[styleNameArray count]] needwarn:NO delegate:nil cancelButtonTitle:NSLocalizedString(@"返回购物车",nil) otherButtonTitles:@[NSLocalizedString(@"继续建立订单|000000",nil)]];
            alertView.specialParentView = ws.view;
            [alertView setAlertViewBlock:^(NSInteger selectedIndex){
                if (selectedIndex == 1) {
                    [ws showBuildOrderUI];
                }
            }];
            [alertView show];
            }
            return ;
        }
        [ws showBuildOrderUI];
    }];
}

-(void)showBuildOrderUI{
    WeakSelf(ws);
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    YYOrderInfoModel *orderInfoModel = [_appdelegate.cartModel copy];//[[YYOrderInfoModel alloc] initWithString:[_appdelegate.cartModel toJSONString]  error:nil];
    
    if(_selectTaxType && needPayTaxView([orderInfoModel.curType integerValue])){
        NSInteger taxRate = getPayTaxTypeToServiceNew(_menuData,_selectTaxType);
        orderInfoModel.taxRate = [NSNumber numberWithInteger:taxRate];
    }else{
        orderInfoModel.taxRate = nil;
    }
    orderInfoModel.addressModifAvailable = YES;
    YYUser *user = [YYUser currentUser];
    orderInfoModel.brandLogo = user.logo;
    orderInfoModel.orderConnStatus = kOrderStatus0;
    orderInfoModel.curType = [[NSNumber alloc] initWithInt:appDelegate.cartMoneyType];
    
    //过滤失效
    __block NSArray *blockStyleModifyResut = (_styleModifyReslut!=nil?_styleModifyReslut.result:nil);
    NSInteger groups = [orderInfoModel.groups count];
    NSInteger styles = 0;
    for (NSInteger i = groups-1; i>=0; i--) {
        YYOrderOneInfoModel *oneInfoModel = [orderInfoModel.groups objectAtIndex:i];
        styles = [oneInfoModel.styles count];
        for (NSInteger j=styles-1; j >=0; j--) {
            YYOrderStyleModel *styleModel = [oneInfoModel.styles objectAtIndex:j];
            NSInteger styleId = [styleModel.styleId integerValue];
            if(blockStyleModifyResut && [blockStyleModifyResut containsObject:@(styleId)]){
                [oneInfoModel.styles removeObject:styleModel];
            }
        }
        if([oneInfoModel.styles count] == 0){
            [orderInfoModel.groups removeObject:oneInfoModel];
        }
    }

    [appDelegate showBuildOrderViewController:orderInfoModel parent:self isCreatOrder:YES isReBuildOrder:NO isAppendOrder:NO modifySuccess:^(){
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        //清理购物车
        if(appDelegate.cartModel && ws.seriesArr ){
            if(blockStyleModifyResut !=nil){
                [ws.selectedArray removeAllObjects];
                for (int i = 0; i < ws.seriesArr.count; i++) {
                    YYOrderOneInfoModel *oneInfoModel = _seriesArr[i];
                    for (YYOrderStyleModel *styleModel in oneInfoModel.styles) {
                        NSInteger styleId = [styleModel.styleId integerValue];

                        if(![blockStyleModifyResut containsObject:@(styleId)]){
                            [self.selectedArray addObject:styleModel];
                        }
                    }
                }
                [ws delateBtnAction:nil];
            }else{
                [appDelegate clearBuyCar];
            }
        }
        if (ws.toOrderList) {
            ws.toOrderList();
        }
    }];
}

- (void)updateSelectBtnAndCellSelectStatus{
    NSInteger count = 0;
    if (self.seriesArr.count != 0) {
        for (int i = 0; i < self.seriesArr.count; i ++) {
            YYOrderOneInfoModel *oneInfoModel = _seriesArr[i];
            count = count + oneInfoModel.styles.count;
        }
    }
    
    if (self.selectedArray.count == count) {
        self.selectAllBtn.selected = YES;
    }else{
        self.selectAllBtn.selected = NO;
    }
    
    if (self.selectedArray.count == 0) {
        self.delateBtn.userInteractionEnabled = NO;
        self.delateBtn.alpha = 0.6;
    }else{
        self.delateBtn.userInteractionEnabled = YES;
        self.delateBtn.alpha = 1;
    }
    [self.tableView reloadData];
}

-(void)addToWindow:(UIViewController *)controller parentView:(UIView *)specialParentView {
    if(specialParentView !=nil){
        self.parentView = specialParentView;
    }else{
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        self.parentView = appDelegate.mainViewController.view;//[UIApplication sharedApplication].keyWindow.rootViewController.view;
    }
    __weak UIView *weakSuperView = self.parentView;
    UIView *showView = controller.view;
    
    [self.parentView addSubview:showView];
    if(SYSTEM_VERSION_LESS_THAN(@"8.0")){
        showView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    }else{
        [showView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(weakSuperView.mas_top);
            make.left.equalTo(weakSuperView.mas_left);
            make.bottom.equalTo(weakSuperView.mas_bottom);
            make.right.equalTo(weakSuperView.mas_right);
        }];
    }
    addAnimateWhenAddSubview(showView);
}

-(void)menuBtnHandler:(id)sender{
    UIButton *btn = (UIButton *)sender;
    NSInteger type = btn.tag;
    [_popController dismissPopoverAnimated:NO];
    if(self.selectTaxType != type){
        [YYTopAlertView showWithType:YYTopAlertTypeSuccess text:NSLocalizedString(@"成功切换税制",nil) parentView:self.view];
    }
    self.selectTaxType = type;
    [self.tableView reloadData];
    [self updateTaxTypeUI];
}
-(void)updateTaxTypeUI{
    NSString *taxTypeStr = nil;
    if(self.selectTaxType > 0){
        [_taxTypeBtn setTitleColor:[UIColor colorWithHex:@"ed6498"] forState:UIControlStateNormal];
        taxTypeStr = getPayTaxValue(_menuData, self.selectTaxType, YES);
    }else{
        [_taxTypeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        taxTypeStr = NSLocalizedString(@"税制",nil);
    }
    [_taxTypeBtn setTitle:taxTypeStr forState:UIControlStateNormal];
    if(_appdelegate.cartModel)
    _appdelegate.cartModel.taxRate = [NSNumber numberWithInteger:getPayTaxTypeToServiceNew(_menuData,_selectTaxType)];

    [self loadShoppingCarData];
}

#pragma mark - --------------other----------------------

@end

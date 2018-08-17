//
//  YYShoppingView.m
//  Yunejian
//
//  Created by yyj on 2017/7/25.
//  Copyright © 2017年 yyj. All rights reserved.
//

#import "YYShoppingView.h"

// c文件 —> 系统文件（c文件在前）

// 控制器

// 自定义视图
#import "MLInputDodger.h"
#import "YYTopAlertView.h"
#import "YYShoppingViewCell.h"
#import "YYShoppingStyleInfoCell.h"

// 接口
#import "YYOpusApi.h"

// 分类
#import "UIImage+YYImage.h"
#import "UIImageView+WebCache.h"

// 自定义类和三方类（ cocoapods类 > model > 工具类 > 其他）
#import "YYColorModel.h"
#import "YYOrderInfoModel.h"
#import "YYOpusStyleModel.h"
#import "YYBrandSeriesToCartTempModel.h"

#import "regular.h"
#import "AppDelegate.h"
#import "YYRequestHelp.h"
#import "UserDefaultsMacro.h"
#import "YYHttpHeaderManager.h"

#define BACKVIEW_WIDTH 500
#define YY_ANIMATE_DURATION 0.5 //动画持续时间

@interface YYShoppingView()<UITableViewDelegate,UITableViewDataSource,YYTableCellDelegate>{
    NSInteger thisStyleSumCount;//当前款式已加购的数量
    NSInteger thisStyleColorCount;//当前款式以选颜色的数量
}

//款式详情 两个只会出现一个。看当前数据有哪个
@property (nonatomic, strong) YYStyleInfoModel *styleInfoModel;
@property (nonatomic, strong) YYOpusStyleModel *opusStyleModel;
//系列信息
@property (nonatomic, strong) YYOpusSeriesModel *opusSeriesModel;
@property (nonatomic, strong) YYOrderInfoModel *currentYYOrderInfoModel;

@property (nonatomic, assign) BOOL isFromSeries;
@property (nonatomic,copy) void (^seriesChooseBlock)(YYBrandSeriesToCartTempModel *brandSeriesToCardTempModel);

@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UIView *navView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *shopView;
@property (nonatomic, strong) UIButton *shopBtn;
@property (nonatomic, strong) UILabel *priceCountLabel;

@property (nonatomic, assign) BOOL isModifyOrder;
@property (nonatomic, assign) BOOL isOnlyColor;//默认为NO

@property (nonatomic, assign) CGRect showFrame;
@property (nonatomic, assign) CGRect hideFrame;

@property (nonatomic, assign) BOOL isAnimation;

@property (nonatomic, strong) YYOrderInfoModel *tempOrderInfoModel;//当前要修改的购物车或订单对象
@property (nonatomic, strong) NSMutableArray *tempSeriesArray;//当前要修改的，临时使用的系列数组对象

@property (nonatomic, strong) NSArray *amountSizeArr;//当前颜色尺寸购买数量 YYOrderOneColorModel
@property (nonatomic, strong) NSArray *sizeNameArr;//当前款式所有的尺寸名 YYSizeModel

@property (nonatomic,strong) NSMutableArray *selectColorArr;//锁定的color存放
@property (nonatomic,strong) YYOrderStyleModel *oldOrderStyleModel;//老的数据  没有为nil

@end

@implementation YYShoppingView

#pragma mark - --------------生命周期--------------
-(instancetype)initWithStyleInfoModel:(YYStyleInfoModel *)styleInfoModel WithOpusSeriesModel:(YYOpusSeriesModel *)opusSeriesModel WithOpusStyleModel:(YYOpusStyleModel *)opusStyleModel WithIsModifyOrder:(BOOL )isModifyOrder WithCurrentYYOrderInfoModel:(YYOrderInfoModel *)currentYYOrderInfoModel fromBrandSeriesView:(BOOL )isFromSeries WithBlock:(void (^)(YYBrandSeriesToCartTempModel *brandSeriesToCardTempModel))block
{
    self = [super initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    if(self){

        _styleInfoModel = styleInfoModel;
        _opusSeriesModel = opusSeriesModel;
        _opusStyleModel = opusStyleModel;
        _isModifyOrder = isModifyOrder;
        _currentYYOrderInfoModel = currentYYOrderInfoModel;
        _isFromSeries = isFromSeries;
        _seriesChooseBlock = block;

        [self SomePrepare];
        [self UIConfig];

        [self isShowBackView:YES];

        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        if (self.isModifyOrder) {

            self.tempOrderInfoModel = appDelegate.orderModel;
            self.tempSeriesArray = appDelegate.orderSeriesArray;

            if (!self.styleInfoModel
                && [YYNetworkReachability connectedToNetwork]) {
                [self loadStyleInfoWithStyleId:[_opusStyleModel.id longValue]];
            }

        }else{
            self.tempOrderInfoModel = appDelegate.cartModel;
            self.tempSeriesArray = appDelegate.seriesArray;
        }

        [self updateThisStyleSumCount];
        [self updateStyleModel];
        [self updateTotalInfo:thisStyleSumCount];

    }
    return self;
}
-(void)updateStyleModel{
    if(_styleInfoModel){
        for (YYOrderOneInfoModel *oneInfoModel in self.tempOrderInfoModel.groups) {
            for (YYOrderStyleModel *styleModel in oneInfoModel.styles) {
                if ( [styleModel.styleId intValue] == [_styleInfoModel.style.id intValue]) {
                    for (YYColorModel *colorModel in _styleInfoModel.colorImages) {
                        for (YYOrderOneColorModel *orderOneColorModel in styleModel.colors) {
                            if([colorModel.id integerValue] == [orderOneColorModel.colorId integerValue]){
                                colorModel.isSelect = orderOneColorModel.isColorSelect;
                            }
                        }
                    }
                }
            }
        }
    }
    if(_opusStyleModel){
        for (YYOrderOneInfoModel *oneInfoModel in self.tempOrderInfoModel.groups) {
            for (YYOrderStyleModel *styleModel in oneInfoModel.styles) {
                if ( [styleModel.styleId intValue] == [_opusStyleModel.id intValue]) {
                    for (YYColorModel *colorModel in _opusStyleModel.color) {
                        for (YYOrderOneColorModel *orderOneColorModel in styleModel.colors) {
                            if([colorModel.id integerValue] == [orderOneColorModel.colorId integerValue]){
                                colorModel.isSelect = orderOneColorModel.isColorSelect;
                            }
                        }
                    }
                }
            }
        }
    }
}
#pragma mark - --------------SomePrepare--------------
-(void)SomePrepare
{
    [self PrepareData];
    [self PrepareUI];
}

-(void)PrepareData{
    _isAnimation = NO;
    _showFrame = CGRectMake(SCREEN_WIDTH - BACKVIEW_WIDTH, 20, BACKVIEW_WIDTH, SCREEN_HEIGHT - 20);
    _hideFrame = CGRectMake(SCREEN_WIDTH, 20, BACKVIEW_WIDTH, SCREEN_HEIGHT - 20);

    _selectColorArr = [[NSMutableArray alloc] init];

    BOOL isexist = NO;
    _oldOrderStyleModel = nil;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    for (YYOrderOneInfoModel *orderOneInfoModel in appDelegate.cartModel.groups) {
        for (YYOrderStyleModel *orderStyleModel in orderOneInfoModel.styles) {
            if ([orderStyleModel.styleId intValue] == [_styleInfoModel.style.id intValue]) {
                _oldOrderStyleModel = orderStyleModel;
                isexist = YES;
                for (YYOrderOneColorModel *orderOneColorModel in orderStyleModel.colors) {
                    for (YYColorModel *color in _styleInfoModel.colorImages) {
                        if([orderOneColorModel.colorId integerValue] == [color.id integerValue]){
                            if([orderOneColorModel.isColorSelect boolValue]){
                                color.isSelect = orderOneColorModel.isColorSelect;
                                [_selectColorArr addObject:@{@"colorIsSelect":color.isSelect,@"colorId":color.id}];
                            }
                        }
                    }
                }
            }
        }
    }
    if(!isexist){
        for (YYColorModel *color in _styleInfoModel.colorImages) {
            color.isSelect = @(NO);
        }
    }
    NSLog(@"1111");
}
-(void)PrepareUI{
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchAction)]];
}

#pragma mark - --------------UIConfig----------------------
-(void)UIConfig{
    [self CreateBackView];
    [self CreateNavVew];
    [self CreateShopView];
    [self CreateTableView];
}
-(void)CreateBackView{
    _backView = [UIView getCustomViewWithColor:_define_white_color];
    [self addSubview:_backView];
    _backView.frame = _hideFrame;
    _backView.hidden = YES;
    [_backView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(NULLACTION)]];
}
-(void)CreateNavVew{
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
        make.width.mas_equalTo(49);
    }];

    UILabel *titleLabel = [UILabel getLabelWithAlignment:1 WithTitle:nil WithFont:17.0f WithTextColor:nil WithSpacing:0];
    [_navView addSubview:titleLabel];
    if (self.isModifyOrder) {
        titleLabel.text = NSLocalizedString(@"修改款式数量",nil);
    }else{
        titleLabel.text = NSLocalizedString(@"加入购物车",nil);
    }
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.bottom.mas_equalTo(bottomview.mas_top).with.offset(0);
        make.centerX.mas_equalTo(_navView);
        make.width.mas_equalTo(200);
    }];
}
-(void)CreateShopView{
    _shopView = [UIView getCustomViewWithColor:nil];
    [_backView addSubview:_shopView];
    [_shopView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        make.height.mas_equalTo(70);
    }];

    UIView *bottomview = [UIView getCustomViewWithColor:[UIColor colorWithHex:@"D3D3D3"]];
    [_shopView addSubview:bottomview];
    [bottomview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(0);
        make.height.mas_equalTo(1);
    }];

    _shopBtn = [UIButton getCustomTitleBtnWithAlignment:0 WithFont:17.0f WithSpacing:0 WithNormalTitle:nil WithNormalColor:_define_white_color WithSelectedTitle:nil WithSelectedColor:nil];
    [_shopView addSubview:_shopBtn];
    if (self.isModifyOrder) {
        [_shopBtn setTitle:NSLocalizedString(@"保存修改",nil) forState:UIControlStateNormal];
    }else{
        [_shopBtn setTitle:NSLocalizedString(@"加入购物车",nil) forState:UIControlStateNormal];
    }
    _shopBtn.backgroundColor = _define_black_color;
    [_shopBtn addTarget:self action:@selector(shopAction) forControlEvents:UIControlEventTouchUpInside];
    [_shopBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.bottom.top.mas_equalTo(0);
        make.width.mas_equalTo(215);
    }];

    _priceCountLabel = [UILabel getLabelWithAlignment:2 WithTitle:nil WithFont:15.0f WithTextColor:nil WithSpacing:0];
    [_shopView addSubview:_priceCountLabel];
    [_priceCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(5);
        make.right.mas_equalTo(_shopBtn.mas_left).with.offset(-18);
        make.top.mas_equalTo(bottomview.mas_bottom).with.offset(0);
        make.bottom.mas_equalTo(0);
    }];
}
-(void)CreateTableView{
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    [_backView addSubview:_tableView];
    //    消除分割线
    _tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    _tableView.delegate=self;
    _tableView.dataSource=self;
    _tableView.backgroundColor = [UIColor colorWithHex:@"F8F8F8"];
    [_tableView registerNib:[UINib nibWithNibName:@"YYShoppingViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"YYShoppingViewCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"YYShoppingStyleInfoCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"YYShoppingStyleInfoCell"];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(_shopView.mas_top).with.offset(0);
        make.top.mas_equalTo(_navView.mas_bottom).with.offset(0);
    }];

    _tableView.shiftHeightAsDodgeViewForMLInputDodger = 44.0f+5.0f;
    [_tableView registerAsDodgeViewForMLInputDodger];

}

#pragma mark - --------------请求数据----------------------

#pragma mark - --------------系统代理----------------------
#pragma mark -UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _styleInfoModel.colorImages.count*2;

}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    YYShoppingStyleInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"YYShoppingStyleInfoCell" ];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.styleInfoModel = _styleInfoModel;
    cell.opusSeriesModel = _opusSeriesModel;
    cell.opusStyleModel = _opusStyleModel;
    cell.isOnlyColor = _isOnlyColor;
    cell.isModifyOrder = _isModifyOrder;
    [cell updateUI];
    if(!_isModifyOrder){
        [cell setChangeChooseStyle:^(){
            _isOnlyColor = !_isOnlyColor;
            [self reloadTableViewData];
        }];
    }
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(_isModifyOrder){
        return 112;
    }
    return 163;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row%2 == 0){
        return 10;
    }else{
        if(_isOnlyColor){
            return 70;
        }else{
            NSInteger maxSizeCount = kMaxSizeCount;
            if ([_styleInfoModel.size count] <= kMaxSizeCount) {
                maxSizeCount = [_styleInfoModel.size count];
            }
            return maxSizeCount*50 +20;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row%2 == 0){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"YYOrderNullCell"];
        if(cell == nil){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"YYOrderNullCell"];
            cell.contentView.backgroundColor = [UIColor colorWithHex:@"F8F8F8"];
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
        }
        return cell;
    }

    YYShoppingViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"YYShoppingViewCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.styleInfoModel = _styleInfoModel;

    NSInteger  cellRow = indexPath.row/2 ;
    YYColorModel *colorModel = [_styleInfoModel.colorImages objectAtIndex:cellRow];
    if(indexPath.row == _styleInfoModel.colorImages.count*2 - 1){
        cell.bottomLineIsHide = YES;
    }else{
        cell.bottomLineIsHide = NO;
    }
    cell.amountsizeArr = nil;
    if (_amountSizeArr.count != 0 ){
        for (YYOrderOneColorModel *oneColorModel in _amountSizeArr) {
            if([oneColorModel.colorId integerValue] == [colorModel.id integerValue]){
                cell.amountsizeArr = oneColorModel.sizes;
                break;
            }
        }
    }
    cell.isOnlyColor = _isOnlyColor;
    cell.indexPath = indexPath;
    cell.delegate = self;
    [cell updateUI];

    return cell;
}

#pragma mark - --------------自定义代理/block----------------------
#pragma mark -YYTableCellDelegate
-(void)btnClick:(NSInteger)row section:(NSInteger)section andParmas:(NSArray *)parmas{
    NSString *type = parmas[0];
    if([type isEqualToString:@"styleNumChange"]){
        //增加减少
        [self editStyleNumIsSeletColor:NO row:row section:section andParmas:parmas];
    }else if([type isEqualToString:@"selectColor"]){
        //选中颜色
        [self editStyleNumIsSeletColor:YES row:row section:section andParmas:parmas];
    }
}
-(void)editStyleNumIsSeletColor:(BOOL )isSeletColor row:(NSInteger)row section:(NSInteger)section andParmas:(NSArray *)parmas{
    if (_amountSizeArr == nil){
        NSMutableArray *oneColorArr = [NSMutableArray array];
        NSMutableArray *detailModelArr = [NSMutableArray array];
        for (int i = 0; i < _styleInfoModel.colorImages.count; i++) {
            NSMutableArray *sizeModelArr = [NSMutableArray array];
            YYOrderOneColorModel *oneColorModel = [[YYOrderOneColorModel alloc] init];
            YYColorModel *color = _styleInfoModel.colorImages[i];
            oneColorModel.colorId = color.id;
            oneColorModel.name = color.name;
            oneColorModel.value = color.value;
            oneColorModel.styleCode = color.styleCode;
            oneColorModel.imgs = color.imgs;
            oneColorModel.originalPrice = color.tradePrice;
            oneColorModel.finalPrice = color.tradePrice;
            oneColorModel.isColorSelect = @(isSeletColor);
            
            for (int j = 0; j < _styleInfoModel.size.count; j++) {
                YYOrderSizeModel *sizeModel = [[YYOrderSizeModel alloc] init];
                sizeModel.amount = [NSNumber numberWithInteger:0];
                sizeModel.sizeId = [NSNumber numberWithInteger:[[_styleInfoModel.size[j] valueForKey:@"id"] intValue]];
                if (color.sizeStocks.count == self.styleInfoModel.size.count) {
                    sizeModel.stock = color.sizeStocks[j];
                }
                [sizeModelArr addObject:sizeModel];
                if (i == 0) {
                    YYSizeModel *detailModel = [[YYSizeModel alloc] init];
                    detailModel.id = [NSNumber numberWithInteger:[[_styleInfoModel.size[j] valueForKey:@"id"] intValue]];
                    detailModel.value = [NSString stringWithFormat:@"%@", [_styleInfoModel.size[j] valueForKey:@"value"]];
                    [detailModelArr addObject:detailModel];
                }
            }
            oneColorModel.sizes = (NSArray<YYOrderSizeModel, ConvertOnDemand> *)sizeModelArr;
            [oneColorArr addObject:oneColorModel];
        }
        _amountSizeArr = oneColorArr;
        _sizeNameArr = detailModelArr;
    }

    NSInteger  cellRow = row/2;
    YYOrderOneColorModel *oneColorModel = [_amountSizeArr objectAtIndex:cellRow];
    if(!isSeletColor){
        NSInteger index = [[parmas objectAtIndex:1] integerValue];
        NSInteger value = [[parmas objectAtIndex:2] integerValue];
        YYOrderSizeModel *sizeModel =  [oneColorModel.sizes objectAtIndex:index];
        NSInteger amount = MAX(0, [sizeModel.amount integerValue]);
        thisStyleSumCount = thisStyleSumCount - amount + value;
        sizeModel.amount = [NSNumber numberWithInteger:value];
        [self updateTotalInfo:thisStyleSumCount];
    }else{
        BOOL isContain = NO;
        NSInteger selectIndex = 0;
        for (int i = 0; i<_selectColorArr.count; i++) {
            NSDictionary *tempDict = _selectColorArr[i];
            if([[tempDict objectForKey:@"colorId"] integerValue] == [oneColorModel.colorId integerValue]){
                isContain = YES;
                selectIndex = i;
            }
        }

        NSNumber *colorIsSelect = [parmas objectAtIndex:1];
        //当前数组中是否存在
        if(isContain){
            //存在 。。。
            [_selectColorArr removeObjectAtIndex:selectIndex];
        }
        [_selectColorArr addObject:@{@"colorIsSelect":colorIsSelect,@"colorId":oneColorModel.colorId}];
        [self reloadTableViewData];
    }
}
#pragma mark - --------------自定义响应----------------------


#pragma mark - --------------自定义方法----------------------
- (BOOL )haveSelectColorInIsOnlyColorStatus{
    BOOL haveSelectColor = NO;
    if(_isOnlyColor){
        for (NSDictionary *dict in _selectColorArr) {
            BOOL colorIsSelect = [[dict objectForKey:@"colorIsSelect"] boolValue];
            if(colorIsSelect){
                haveSelectColor = YES;
            }
        }
    }else{
        haveSelectColor = YES;
    }
    return haveSelectColor;
}
/**
 更新视图 根据当前类型
 */
-(void)reloadTableViewData{
    _priceCountLabel.hidden = _isOnlyColor;
    if(_isOnlyColor){
        _priceCountLabel.hidden = YES;
        [_shopBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(500);
        }];
        [_priceCountLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.right.mas_equalTo(_shopBtn.mas_left).with.offset(0);
        }];
    }else{
        _priceCountLabel.hidden = NO;
        [_shopBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(215);
        }];
        [_priceCountLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(5);
            make.right.mas_equalTo(_shopBtn.mas_left).with.offset(-18);
        }];
    }
    [_tableView reloadData];
}
/**
 获取款式详情
 isModifyOrder == YES 时候才会调用
 @param styleID
 */
- (void)loadStyleInfoWithStyleId:(NSInteger )styleID{
    WeakSelf(ws);
    [YYOpusApi getStyleInfoByStyleId:styleID orderCode:_currentYYOrderInfoModel.orderCode andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYStyleInfoModel *styleInfoModel, NSError *error) {
        if (rspStatusAndMessage.status == kCode100) {
            ws.styleInfoModel = styleInfoModel;
            [ws updateThisStyleSumCount];
            [ws updateTotalInfo:thisStyleSumCount];
            [ws reloadTableViewData];
        }
    }];
}
-(void)shopAction{
    NSInteger tempLimitNum = 0;
    BOOL haveSelectColor = [self haveSelectColorInIsOnlyColorStatus];
    if(_isOnlyColor){
        tempLimitNum = 1;//永远成立
    }else{
        tempLimitNum = thisStyleSumCount;
    }
    //_isOnlyColor下看是否有选中的color
    NSLog(@"thisStyleSumCount = %ld",thisStyleSumCount);
    if (tempLimitNum > 0 && haveSelectColor) {
        if(_isFromSeries){
            if(_seriesChooseBlock){
                YYBrandSeriesToCartTempModel *brandSeriesToCardTempModel = [[YYBrandSeriesToCartTempModel alloc] init];
                brandSeriesToCardTempModel.isModifyOrder = _isModifyOrder;
                brandSeriesToCardTempModel.styleInfoModel = _styleInfoModel;
                brandSeriesToCardTempModel.opusSeriesModel = _opusSeriesModel;
                brandSeriesToCardTempModel.tempOrderInfoModel = _tempOrderInfoModel;
                brandSeriesToCardTempModel.isOnlyColor = @(_isOnlyColor);
                brandSeriesToCardTempModel.selectColorArr = _selectColorArr;
                brandSeriesToCardTempModel.sizeNameArr = (NSArray<YYSizeModel> *)_sizeNameArr;
                brandSeriesToCardTempModel.amountSizeArr = (NSArray<YYOrderOneColorModel> *)_amountSizeArr;
                _seriesChooseBlock(brandSeriesToCardTempModel);
            }
        }else{
            [self addToLocalCart];
        }
        //移除view
        [self isShowBackView:NO];
    }else{
        if (_isModifyOrder) {
            //移除view
            [self isShowBackView:NO];
        }
    }
}
-(void)addToLocalCart{
    _shopBtn.enabled = NO;

    NSString *_remark = @"";
    YYDateRangeModel *_tmpDateRange = nil;
    NSString *_tmpRemark = @"";

    YYOrderOneInfoModel *orderOneInfoM = nil;
    if ([self.tempSeriesArray count] > 0) {
        //已经有系列创建
        //查询是否已经有该系列

        for (YYOrderOneInfoModel *orderOneInfoModel in self.tempSeriesArray) {
            if((_styleInfoModel.dateRange && [_styleInfoModel.dateRange.id integerValue] > 0 &&  [orderOneInfoModel.dateRange.id  integerValue] == [_styleInfoModel.dateRange.id integerValue]) || ((!_styleInfoModel.dateRange || [_styleInfoModel.dateRange.id integerValue] == 0) &&(orderOneInfoModel.dateRange == nil || [orderOneInfoModel.dateRange.id  integerValue] == 0))){
                orderOneInfoM = orderOneInfoModel;
                break;
            }
        }

        if (orderOneInfoM) {
            NSArray *arr = orderOneInfoM.styles; //当前系列所有款式
            for (YYOrderStyleModel *style in arr){
                if ([style.styleId intValue] == [_styleInfoModel.style.id intValue]) {
                    _remark = style.remark;
                    _tmpDateRange = style.tmpDateRange;
                    _tmpRemark = style.tmpRemark;
                    [orderOneInfoM.styles removeObject:style];
                    break;
                }
            }
        }
    }

    if (!orderOneInfoM) {
        orderOneInfoM = [[YYOrderOneInfoModel alloc] init];
        orderOneInfoM.dateRange = _styleInfoModel.dateRange;
        orderOneInfoM.styles = (NSMutableArray<YYOrderStyleModel>*)[[NSMutableArray alloc] init];
        [self.tempSeriesArray addObject:orderOneInfoM];
    }

    //增加系列队列
    if(_opusSeriesModel){
        if(!self.tempOrderInfoModel.seriesMap){
            self.tempOrderInfoModel = [[YYOrderInfoModel alloc] init];
            self.tempOrderInfoModel.seriesMap = (NSMutableDictionary<YYOrderSeriesModel, Optional,ConvertOnDemand> *)[[NSMutableDictionary alloc] init];
        }
        YYOrderSeriesModel *seriesModel = [[YYOrderSeriesModel alloc] init];
        seriesModel.seriesId = _opusSeriesModel.id;
        seriesModel.name = _opusSeriesModel.name;
        seriesModel.orderAmountMin = _opusSeriesModel.orderAmountMin;// style 有orderAmountMin
        seriesModel.supplyStatus = _opusSeriesModel.supplyStatus;
        [self.tempOrderInfoModel.seriesMap setObject:seriesModel forKey:[seriesModel.seriesId stringValue]];
    }


    YYOrderStyleModel *orderStyleModel = [[YYOrderStyleModel alloc] init];
    orderStyleModel.styleId = _styleInfoModel.style.id;
    orderStyleModel.albumImg = _styleInfoModel.style.albumImg;
    orderStyleModel.name = _styleInfoModel.style.name;
    orderStyleModel.finalPrice = (_styleInfoModel.style.finalPrice !=nil?_styleInfoModel.style.finalPrice: _styleInfoModel.style.tradePrice);
    orderStyleModel.originalPrice = _styleInfoModel.style.tradePrice;
    orderStyleModel.retailPrice = _styleInfoModel.style.retailPrice;
    orderStyleModel.orderAmountMin = _styleInfoModel.style.orderAmountMin;
    orderStyleModel.styleCode = _styleInfoModel.style.styleCode;
    orderStyleModel.styleModifyTime = _styleInfoModel.style.modifyTime;
    orderStyleModel.sizeNameList = (NSArray<YYSizeModel, ConvertOnDemand> *) _sizeNameArr;
    orderStyleModel.stockEnabled = self.styleInfoModel.stockEnabled;
    orderStyleModel.colors =(NSArray<YYOrderOneColorModel, ConvertOnDemand> *) _amountSizeArr;
    orderStyleModel.curType = _styleInfoModel.style.curType;
    orderStyleModel.seriesId = _opusSeriesModel.id;
    orderStyleModel.supportAdd = _styleInfoModel.style.supportAdd;
    orderStyleModel.remark = _remark;
    orderStyleModel.tmpDateRange = _tmpDateRange;
    orderStyleModel.tmpRemark = _remark;

    [orderOneInfoM.styles insertObject:orderStyleModel atIndex:0];

    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];


    if (self.isModifyOrder) {
        //修改订单
        appDelegate.orderModel.groups = (NSMutableArray<YYOrderOneInfoModel> *)self.tempSeriesArray;
        appDelegate.orderModel.seriesMap = self.tempOrderInfoModel.seriesMap;
        appDelegate.orderSeriesArray =(NSMutableArray<YYOrderOneInfoModel> *)self.tempSeriesArray;
    }else{
        //修改购物车
        appDelegate.cartMoneyType = [_styleInfoModel.style.curType integerValue];
        //修改购物车
        //组合最终的YYOrderInfoModel模型对象。
        if (appDelegate.cartModel.designerId) {
            appDelegate.cartModel.groups = (NSMutableArray<YYOrderOneInfoModel> *)self.tempSeriesArray;
            appDelegate.cartModel.seriesMap = self.tempOrderInfoModel.seriesMap;
            appDelegate.cartModel.stockEnabled = self.styleInfoModel.stockEnabled;
            appDelegate.seriesArray=(NSMutableArray<YYOrderOneInfoModel> *)self.tempSeriesArray;
        }else{
            YYOrderInfoModel *orderInfoModel = [[YYOrderInfoModel alloc] init];
            orderInfoModel.stockEnabled = self.styleInfoModel.stockEnabled;
            orderInfoModel.designerId = _opusSeriesModel.designerId;
            orderInfoModel.orderDescription = nil;
            orderInfoModel.groups = (NSMutableArray<YYOrderOneInfoModel> *)self.tempSeriesArray;
            orderInfoModel.seriesMap = self.tempOrderInfoModel.seriesMap;
            appDelegate.cartModel = orderInfoModel;
            appDelegate.seriesArray=(NSMutableArray<YYOrderOneInfoModel> *)self.tempSeriesArray;
        }

        //重设isColorSelect
        [self resetCartModel];

        //储存对象的JSONString
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        NSString *jsonString = appDelegate.cartModel.toJSONString;
        [userDefault setObject:jsonString forKey:KUserCartKey];
        [userDefault setObject:[NSString stringWithFormat:@"%ld",(long)appDelegate.cartMoneyType] forKey:KUserCartMoneyTypeKey];
        [userDefault synchronize];

    }
//isColorSelect
    //发出通知，更新购物车图标
    [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateShoppingCarNotification object:nil];
    [YYTopAlertView showWithType:YYTopAlertTypeSuccess text:NSLocalizedString(@"成功加入购物车",nil) parentView:nil];
}
- (void)resetCartModel{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    for (YYOrderOneInfoModel *orderOneInfoModel in appDelegate.cartModel.groups) {
        for (YYOrderStyleModel *orderStyleModel in orderOneInfoModel.styles) {
            if ([orderStyleModel.styleId intValue] == [_styleInfoModel.style.id intValue]) {
                for (YYOrderOneColorModel *orderOneColorModel in orderStyleModel.colors) {
                    if(_isOnlyColor){
                        //锁定的情况下清空amout
                        BOOL colorIsSelect = NO;//当前的颜色（临时）
                        for (NSDictionary *tempDict in _selectColorArr) {
                            if([[tempDict objectForKey:@"colorId"] integerValue] == [orderOneColorModel.colorId integerValue]){
                                colorIsSelect = [[tempDict objectForKey:@"colorIsSelect"] boolValue];
                            }
                        }
                        if(colorIsSelect){
                            orderOneColorModel.isColorSelect = @(YES);
                            for (YYOrderSizeModel *orderSizeModel in orderOneColorModel.sizes) {
                                orderSizeModel.amount = @(0);
                            }
                        }else{
                            orderOneColorModel.isColorSelect = @(NO);
                            for (YYOrderSizeModel *orderSizeModel in orderOneColorModel.sizes) {
                                //给他设原来的amout    colorId  sizeId
                                orderSizeModel.amount = [self getOldAmountWithColorId:[orderOneColorModel.colorId integerValue] WithSizeId:[orderSizeModel.sizeId integerValue]];
                            }
                        }
                    }else{

                        //如果有数量，则设置为NO，不然保持原样
                        BOOL haveAmount = NO;
                        for (YYOrderSizeModel *orderSizeModel in orderOneColorModel.sizes) {
                            if([orderSizeModel.amount integerValue]){
                                haveAmount = YES;
                            }
                        }

                        if(haveAmount){
                            orderOneColorModel.isColorSelect = @(NO);
                        }
                    }
                }
            }
        }
    }
}
- (NSNumber *)getOldAmountWithColorId:(NSInteger )colorId WithSizeId:(NSInteger )sizeId{
    NSInteger returnamount = 0;
    if(_oldOrderStyleModel){
        for (YYOrderOneColorModel *orderOneColorModel in _oldOrderStyleModel.colors) {
            if([orderOneColorModel.colorId integerValue] == colorId){
                for (YYOrderSizeModel *orderSizeModel in orderOneColorModel.sizes) {
                    if([orderSizeModel.sizeId integerValue] == sizeId){
                        returnamount = [orderSizeModel.amount integerValue];
                    }
                }
            }
        }
    }
    return @(returnamount);
}
/**
 更新界面下面的描述label

 @param sunCount 款式总计数量
 */
-(void)updateTotalInfo:(NSInteger)sunCount{
    __block float costMeoney = 0;
    [self.amountSizeArr enumerateObjectsUsingBlock:^(YYOrderOneColorModel *orderOneColorModel, NSUInteger idx, BOOL *stop) {
        NSInteger amount = [orderOneColorModel getTotalOriginalPrice];
        costMeoney += [orderOneColorModel.originalPrice floatValue] * amount;
    }];
    NSString *priceStr = replaceMoneyFlag([NSString stringWithFormat:@"￥%.2f",costMeoney],[_styleInfoModel.style.curType integerValue]);

    NSString *titleStr = [[NSString alloc] initWithFormat:@"%@ %@",[[NSString alloc] initWithFormat:NSLocalizedString(@"共%@款%@件",nil),[NSString stringWithFormat: @"%ld", (long)[self getStleNum]],[NSString stringWithFormat: @"%ld", (long)sunCount]],priceStr];

    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString: titleStr];
    NSRange range = NSMakeRange(titleStr.length - priceStr.length, priceStr.length);
    [attributedStr addAttribute: NSForegroundColorAttributeName value: [UIColor colorWithHex:@"ed6498"] range:range];
    [attributedStr addAttribute: NSFontAttributeName value: [UIFont boldSystemFontOfSize:17] range:range];
    self.priceCountLabel.attributedText = attributedStr;
    NSLog(@"111");
}
-(NSInteger )getStleNum{
    if(_amountSizeArr && _amountSizeArr.count){
        NSInteger num = 0;
        for (YYOrderOneColorModel *colorModel in _amountSizeArr) {
            BOOL hasAdd = NO;
            for (YYOrderSizeModel *sizeModel in colorModel.sizes) {
                if(!hasAdd && [sizeModel.amount integerValue] > 0){
                    num ++;
                    hasAdd = YES;
                }
            }
        }
        return num;
    }
    return 0;
}
/**
 获取款式已加购的数量，并初始化（amountSizeArr sizeNameArr）
 */
-(void)updateThisStyleSumCount{
    thisStyleSumCount = 0;
    thisStyleColorCount = 0;
    for (YYOrderOneInfoModel *oneInfoModel in self.tempOrderInfoModel.groups) {
        for (YYOrderStyleModel *styleModel in oneInfoModel.styles) {
            if ( [styleModel.styleId intValue] == [_styleInfoModel.style.id intValue]) {
                _amountSizeArr = styleModel.colors;
                _sizeNameArr = styleModel.sizeNameList;
                if (styleModel.colors && [styleModel.colors count] > 0) {
                    for (YYOrderOneColorModel *orderOneColorModel in styleModel.colors) {
                        if (orderOneColorModel.sizes && [orderOneColorModel.sizes count] > 0) {
                            for (YYOrderSizeModel *orderSizeModel in orderOneColorModel.sizes)
                            {
                                thisStyleSumCount += MAX(0,[orderSizeModel.amount intValue]);
                            }
                        }
                    }
                }
            }
        }
    }
}
-(void)isShowBackView:(BOOL )isShow{

    if(!_isAnimation && _backView){
        _backView.hidden = NO;
        if(isShow){
            //显示
            _backView.frame = _hideFrame;
            _isAnimation = YES;
            [UIView animateWithDuration:YY_ANIMATE_DURATION animations:^{
                _backView.frame = _showFrame;
            } completion:^(BOOL finished) {
                _isAnimation = NO;
            }];
        }else{
            //隐藏
            _backView.frame = _showFrame;
            _isAnimation = YES;
            [UIView animateWithDuration:YY_ANIMATE_DURATION animations:^{
                _backView.frame = _hideFrame;
            } completion:^(BOOL finished) {
                _isAnimation = NO;
                [self removeFromSuperview];
            }];
        }

    }
}
-(void)NULLACTION{}
-(void)touchAction{
    [self isShowBackView:NO];
}
-(void)closeAction{
    [self isShowBackView:NO];
}
#pragma mark - --------------other----------------------

@end

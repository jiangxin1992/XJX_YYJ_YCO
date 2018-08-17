//
//  YYBrandSeriesViewController.m
//  Yunejian
//
//  Created by Apple on 15/12/3.
//  Copyright © 2015年 yyj. All rights reserved.
//

#import "YYBrandSeriesViewController.h"

// c文件 —> 系统文件（c文件在前）

// 控制器
#import "YYNavigationBarViewController.h"
#import "YYBrandSeriesListViewController.h"

// 自定义视图
#import "YYSeriesInfoViewCell.h"
#import "YYSeriesStyleViewCell.h"
#import "YYSmallShoppingCarButton.h"
#import "YYTopBarShoppingCarButton.h"
#import "MBProgressHUD.h"
#import "YYPopoverBackgroundView.h"
#import "SCGIFImageView.h"

// 接口
#import "YYOpusApi.h"

// 分类

// 自定义类和三方类（ cocoapods类 > model > 工具类 > 其他）
#import <MJRefresh.h>

#import "StyleColors.h"
#import "YYOrderInfoModel.h"
#import "YYSeriesInfoModel.h"
#import "YYOrderOneInfoModel.h"
#import "YYOpusStyleListModel.h"
#import "YYOpusSeriesListModel.h"
#import "YYSeriesInfoDetailModel.h"

#import "AppDelegate.h"

static CGFloat animateDuration = 0.3;
static CGFloat searchFieldWidthDefaultConstraint = 45;
static CGFloat searchFieldWidthMaxConstraint = 200;

@interface YYBrandSeriesViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UIScrollViewDelegate,UITextFieldDelegate,YYTableCellDelegate>

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIView *smallTitleContainer;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) YYNavigationBarViewController *navigationBarViewController;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (weak, nonatomic) IBOutlet UITextField *searchField;
@property (weak, nonatomic) IBOutlet YYTopBarShoppingCarButton *topBarShoppingCarButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchFieldWidthConstraint;
@property (weak, nonatomic) IBOutlet UIButton *seriesAllBtn;

@property (nonatomic,strong)YYPageInfoModel *currentPageInfo;
@property (nonatomic,strong) UIView *noDataView;
@property (nonatomic,strong) NSMutableArray *stylesListArray;


@property (nonatomic, strong) NSMutableArray *seriesArray;
@property (nonatomic,assign) NSInteger seriesId;
@property(nonatomic,strong)YYOpusSeriesModel *seriesModel;
@property(nonatomic,strong)YYSeriesInfoDetailModel *seriesInfoDetailModel;

//查询结果
@property (nonatomic) BOOL searchFlag;
@property (nonatomic,strong) NSMutableArray *searchResultArray;
@property (nonatomic,strong) YYPageInfoModel *currentSearchPageInfo;

@property(nonatomic,strong) UIPopoverController *popController;

@property(nonatomic,strong) UIView *rightMaskView;
@property (nonatomic,strong) YYBrandSeriesListViewController *seriesListViewController;

@end

@implementation YYBrandSeriesViewController

static NSInteger infoViewHeight = 210;
static NSInteger headViewHeight = 44;
#pragma mark - --------------生命周期--------------
- (void)viewDidLoad {
    [super viewDidLoad];
    [self SomePrepare];
    [self RequestData];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
#pragma mark - --------------SomePrepare--------------
- (void)SomePrepare
{
    [self PrepareData];
    [self PrepareUI];
}
- (void)PrepareData{

    self.stylesListArray = [[NSMutableArray alloc] init];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}
- (void)keyboardWillHide:(NSNotification *)note{
    if (_searchField.text == nil || [_searchField.text length] == 0) {
        _searchFieldWidthConstraint.constant = searchFieldWidthDefaultConstraint;
        _searchField.placeholder = nil;

        [UIView animateWithDuration:animateDuration animations:^{
            [_searchField layoutIfNeeded];
        } completion:^(BOOL finished) {
            [_searchField resignFirstResponder];

            [UIView animateWithDuration:animateDuration animations:^{
                _searchField.alpha = 0.0;
                _searchField.transform = CGAffineTransformMakeScale(0.01f, 0.01f);
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:animateDuration animations:^{
                    _searchButton.alpha = 1.0;
                    _searchButton.transform = CGAffineTransformMakeScale(1.00f, 1.00f);
                }];
            }];
        }];
    }
}
- (void)PrepareUI{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    YYNavigationBarViewController *navigationBarViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYNavigationBarViewController"];
    navigationBarViewController.previousTitle = NSLocalizedString(@"品牌",nil);
    self.navigationBarViewController = navigationBarViewController;
    navigationBarViewController.nowTitle = NSLocalizedString(@"当前系列名称",nil);
    [_containerView insertSubview:navigationBarViewController.view atIndex:0];
    __weak UIView *_weakContainerView = _containerView;
    [navigationBarViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_weakContainerView.mas_top);
        make.left.equalTo(_weakContainerView.mas_left);
        make.bottom.equalTo(_weakContainerView.mas_bottom);
        make.right.equalTo(_weakContainerView.mas_right);
    }];

    WeakSelf(ws);

    __block YYNavigationBarViewController *blockVc = navigationBarViewController;

    [navigationBarViewController setNavigationButtonClicked:^(NavigationButtonType buttonType){
        if (buttonType == NavigationButtonTypeGoBack) {
            [ws.navigationController popViewControllerAnimated:YES];
            blockVc = nil;
        }
    }];
    _searchField.layer.borderColor = [UIColor blackColor].CGColor;
    _searchField.layer.borderWidth = 1;
    _searchField.layer.cornerRadius = 15;
    _searchField.clearButtonMode = UITextFieldViewModeAlways;
    _searchField.returnKeyType = UIReturnKeySearch;
    _searchField.enablesReturnKeyAutomatically = YES;
    _searchField.delegate = self;
    _searchField.alpha = 0.0;
    [self.topBarShoppingCarButton initButton];

    _smallTitleContainer.hidden = YES;

    [self addHeader];
    [self addFooter];

    self.collectionView.alwaysBounceVertical = YES;
    self.noDataView = addNoDataView_pad(self.view,nil,nil,nil);
    self.noDataView.hidden = YES;
}

#pragma mark - --------------UIConfig----------------------
-(void)UIConfig{}

#pragma mark - --------------请求数据----------------------
-(void)RequestData{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self loadAllSeries];
}
-(void)loadSeriesInfo{
    WeakSelf(ws);
    [YYOpusApi getConnSeriesInfoWithId:_designerId seriesId:_seriesId andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYSeriesInfoDetailModel *infoDetailModel, NSError *error) {
        if (rspStatusAndMessage.status == YYReqStatusCode100){
            ws.seriesInfoDetailModel = infoDetailModel;
            [ws updateMenuUI];
        }
        [MBProgressHUD hideAllHUDsForView:ws.view animated:YES];
        if (rspStatusAndMessage.status != YYReqStatusCode100) {
            [YYToast showToastWithTitle:rspStatusAndMessage.message  andDuration:kAlertToastDuration];
        }
        [ws reloadCollectionViewData];
    }];
}
//加载系列系列，
- (void)loadAllSeries{
    WeakSelf(ws);
    [YYOpusApi getConnSeriesListWithId:_designerId pageIndex:1 pageSize:20 andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYOpusSeriesListModel *opusSeriesListModel, NSError *error) {
        if (rspStatusAndMessage.status == YYReqStatusCode100
            && opusSeriesListModel.result
            && [opusSeriesListModel.result count] > 0) {
            ws.seriesArray = [[NSMutableArray alloc] init];
            [ws.seriesArray addObjectsFromArray:opusSeriesListModel.result];
            [ws changeSeries:0];
        }else{
            [MBProgressHUD hideAllHUDsForView:ws.view animated:YES];
        }
    }];
}
- (void)loadDataByPageIndex:(int)pageIndex queryStr:(NSString*)queryStr{
    WeakSelf(ws);
    [YYOpusApi getConnStyleListWithDesignerId:_designerId seriesId:_seriesId orderBy:nil queryStr:queryStr pageIndex:pageIndex pageSize:8 andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYOpusStyleListModel *opusStyleListModel, NSError *error) {
        if (rspStatusAndMessage.status == YYReqStatusCode100 && opusStyleListModel.result
            && [opusStyleListModel.result count] > 0) {
            if(ws.searchResultArray == nil){
                ws.currentPageInfo = opusStyleListModel.pageInfo;
                if (ws.currentPageInfo== nil || ws.currentPageInfo.isFirstPage) {
                    [ws.stylesListArray removeAllObjects];
                }
                [ws.stylesListArray addObjectsFromArray:opusStyleListModel.result];
            }else{
                ws.currentSearchPageInfo = opusStyleListModel.pageInfo;
                if (ws.currentSearchPageInfo == nil || ws.currentSearchPageInfo.isFirstPage) {
                    [ws.searchResultArray removeAllObjects];
                }
                [ws.searchResultArray addObjectsFromArray:opusStyleListModel.result];
            }
        }

        [MBProgressHUD hideAllHUDsForView:ws.view animated:YES];
        if (rspStatusAndMessage.status != YYReqStatusCode100) {
            [YYToast showToastWithTitle:rspStatusAndMessage.message  andDuration:kAlertToastDuration];
        }
        [ws reloadCollectionViewData];
    }];
}
#pragma mark - --------------系统代理----------------------
#pragma mark -UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    return YES ;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if ([textField isFirstResponder]) {
        _searchFlag = YES;
        [textField resignFirstResponder];
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{

    if(_searchFlag){
        _searchFlag = NO;
        self.searchResultArray = [[NSMutableArray alloc] init];
        _currentSearchPageInfo = nil;
        if(![textField.text isEqualToString:@""]){

            [self loadDataByPageIndex:1 queryStr:textField.text];
        }
    }else{
        if(![textField.text isEqualToString:@""]){
            textField.text = nil;
            [self keyboardWillHide:nil];
        }
        self.searchResultArray = nil;
    }
    [self reloadCollectionViewData];
}
#pragma mark -UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 2;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (section == 0) {
        return 1;
    }
    if(_searchResultArray != nil){
        return [_searchResultArray count];
    }
    return [self.stylesListArray count];
}

//定义每个Section 的 margin
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    if (section == 0) {
        return UIEdgeInsetsMake(0, 40, 0, 40);
    }
    return UIEdgeInsetsMake(30, 40, 0, 40);//分别为上、左、下、右
}
//每个section中不同的行之间的行间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 10;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0){
        return CGSizeMake(SCREEN_WIDTH-80, infoViewHeight);
    }
    return CGSizeMake(211, 333);
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0){
        static NSString* reuseIdentifier = @"YYSeriesInfoViewCell";
        YYSeriesInfoViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
        cell.seriesModel = _seriesModel;
        cell.seriesDescription =_seriesInfoDetailModel.brandDescription;
        cell.delegate = self;
        cell.indexPath = indexPath;
        [cell updateUI];
        return cell;
    }else if(indexPath.section == 1){
        static NSString* reuseIdentifier = @"YYSeriesStyleViewCell";
        YYSeriesStyleViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];

        YYSmallShoppingCarButton *smallShoppingCarButton = (YYSmallShoppingCarButton *)[cell viewWithTag:80005];
        [smallShoppingCarButton initButton];
        smallShoppingCarButton.hidden = YES;

        UIButton *addButton = (UIButton *)[cell viewWithTag:80006];
        addButton.hidden = YES;

        UIImageView *imageView = (UIImageView *)[cell viewWithTag:80000];
        imageView.contentMode = UIViewContentModeScaleAspectFit;

        NSString *imageRelativePath = @"";
        NSString *name = @"";
        NSString *styleCode = @"";
        NSString *tradePrice = @"";
        NSString *retailPrice = @"";
        NSArray *colorArray = nil;
        if(_searchResultArray != nil && ([_searchResultArray count] > indexPath.row)){
            YYOpusStyleModel *opusStyleModel =[_searchResultArray objectAtIndex:indexPath.row];
            imageRelativePath = opusStyleModel.albumImg;
            name = opusStyleModel.name;
            styleCode = opusStyleModel.styleCode;
            tradePrice = replaceMoneyFlag([NSString stringWithFormat:NSLocalizedString(@"批发￥%0.2f",nil),[opusStyleModel.tradePrice floatValue]],[opusStyleModel.curType integerValue]);
            retailPrice = replaceMoneyFlag([NSString stringWithFormat:NSLocalizedString(@"零售￥%0.2f",nil),[opusStyleModel.retailPrice floatValue]],[opusStyleModel.curType integerValue]);

            if (opusStyleModel.color
                && [opusStyleModel.color count] > 0) {
                colorArray = opusStyleModel.color;
            }

        }else if ([_stylesListArray count] > indexPath.row) {
            YYOpusStyleModel *opusStyleModel = [_stylesListArray objectAtIndex:indexPath.row];

            imageRelativePath = opusStyleModel.albumImg;
            name = opusStyleModel.name;
            styleCode = opusStyleModel.styleCode;
            tradePrice = replaceMoneyFlag([NSString stringWithFormat:NSLocalizedString(@"批发￥%0.2f",nil),[opusStyleModel.tradePrice floatValue]],[opusStyleModel.curType integerValue]);
            retailPrice = replaceMoneyFlag([NSString stringWithFormat:NSLocalizedString(@"零售￥%0.2f",nil),[opusStyleModel.retailPrice floatValue]],[opusStyleModel.curType integerValue]);

            if (opusStyleModel.color
                && [opusStyleModel.color count] > 0) {
                colorArray = opusStyleModel.color;
            }

        }
        if (true) {
            AppDelegate *_appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            for (YYOrderOneInfoModel *oneInfoModel in _appdelegate.cartModel.groups) {
                for (YYOrderStyleModel * orderInfoMode in oneInfoModel.styles) {
                    if([styleCode isEqualToString:orderInfoMode.styleCode]){
                        [smallShoppingCarButton updateButtonNumber:@"√"];
                        smallShoppingCarButton.hidden = NO;
                        break;
                    }
                }
                if(smallShoppingCarButton.hidden == NO){
                    break;
                }
            } //;
        }
        NSString *imageName = [[imageRelativePath lastPathComponent] stringByAppendingString:kStyleCover];
        NSString *storePath = yyjOfflineSeriesImagePath(self.seriesId,imageRelativePath,imageName);

        UIImage *image = [UIImage imageWithContentsOfFile:storePath];
        imageView.backgroundColor = [UIColor colorWithHex:kDefaultImageColor];
        if (image) {
            imageView.image = image;
        }else{
            sd_downloadWebImageWithRelativePath(NO, imageRelativePath, imageView, kStyleCover, 0);
        }


        UILabel *nameLabel = (UILabel *)[cell viewWithTag:80001];
        UILabel *styleLabel = (UILabel *)[cell viewWithTag:80002];
        UILabel *tradePriceLabel = (UILabel *)[cell viewWithTag:80003];
        UILabel *retailPriceLabel = (UILabel *)[cell viewWithTag:80004];

        //更新约束
        CGSize nameLabelSize = [name sizeWithAttributes:@{NSFontAttributeName:nameLabel.font}];
        float needHeight = nameLabelSize.height;
        if(nameLabelSize.width > 200){
            needHeight = nameLabelSize.height*2;
            nameLabel.text = name;
        }else{
            needHeight = nameLabelSize.height*2;
            nameLabel.text = [NSString stringWithFormat:@"%@\n",name];
        }
        for (NSLayoutConstraint * constrait in [nameLabel constraints]) {
            NSLayoutAttribute attr1= constrait.firstAttribute;
            if(attr1 == NSLayoutAttributeHeight){
                constrait.constant = needHeight;
                break;
            }
        }

        styleLabel.text = styleCode;
        tradePriceLabel.text = tradePrice;
        retailPriceLabel.text = retailPrice;

        if (colorArray
            && [colorArray count] > 0) {
            NSArray *array = [imageView subviews];
            for (UIView *view in array) {
                [view removeFromSuperview];
            }

            [self addColorViewToCover:imageView colors:colorArray];
        }

        return cell;
    }
    UICollectionViewCell *cell = [[UICollectionViewCell alloc] init];
    cell.backgroundColor = [UIColor lightGrayColor];
    return cell;
}
#pragma mark -scrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView; {
    if (scrollView.contentOffset.y > (infoViewHeight - headViewHeight) ) {
        _smallTitleContainer.hidden = NO;
    }else{
        _smallTitleContainer.hidden = YES;
    }
}
#pragma mark - --------------自定义代理/block----------------------
#pragma mark -YYTableCellDelegate
-(void)btnClick:(NSInteger)row section:(NSInteger)section andParmas:(NSArray *)parmas{
    NSDictionary *txtAttrDict = [parmas objectAtIndex:0];
    NSString *descStr = [parmas objectAtIndex:1];
    CGSize uiSize = CGSizeMake([[parmas objectAtIndex:2] integerValue], [[parmas objectAtIndex:3] integerValue]);//[[parmas objectAtIndex:0] CGSizeValue];

    CGPoint point = CGPointMake([[parmas objectAtIndex:4] integerValue], [[parmas objectAtIndex:5] integerValue]);//[[parmas objectAtIndex:3] CGPointValue];
    [self showDescUI:uiSize txtAttrDict:txtAttrDict descStr:descStr point:point];
}

#pragma mark - --------------自定义响应----------------------
- (IBAction)showSeriesMenu:(id)sender {
    if(_seriesArray == nil || [_seriesArray count] == 0){
        return;
    }
    NSMutableArray *tmpSeriesArray = [[NSMutableArray alloc] init];
    for (YYOpusSeriesModel *tmpSeriesModel in _seriesArray) {
        if([tmpSeriesModel.id integerValue] != self.seriesId){
            [tmpSeriesArray addObject:tmpSeriesModel];
        }
    }

    WeakSelf(ws);
    _rightMaskView = [[UIView alloc] init];
    _rightMaskView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    UIButton *bgView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [_rightMaskView addSubview:bgView];

    __weak UIView *weakMaskView =_rightMaskView;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(OnTapBg:)];
    [bgView addGestureRecognizer:tap];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Brand" bundle:[NSBundle mainBundle]];
    YYBrandSeriesListViewController *seriesListViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYBrandSeriesListViewController"];

    seriesListViewController.seriesArray = tmpSeriesArray;
    [seriesListViewController setSelectedValue:^(NSString *value){
        NSInteger index = [ws getSeriesIndex:[value integerValue]];
        if(index > -1)
            [ws changeSeries:index];
        [ws.seriesListViewController.view removeFromSuperview];
        [weakMaskView removeFromSuperview];
    }];
    _seriesListViewController =seriesListViewController;
    [self.view addSubview:_rightMaskView];

    __weak  UIView *_weakContainerView = self.view;
    [_rightMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_weakContainerView.mas_top);
        make.left.equalTo(_weakContainerView.mas_left);
        make.bottom.equalTo(_weakContainerView.mas_bottom);
        make.right.equalTo(_weakContainerView.mas_right);
    }];

    [_rightMaskView addSubview:seriesListViewController.view];
    [self.seriesListViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_rightMaskView.mas_top);
        make.bottom.equalTo(_rightMaskView.mas_bottom);
        make.right.equalTo(_rightMaskView.mas_right).offset(620);
        make.width.equalTo(@(620));
    }];
    [self.seriesListViewController.view layoutIfNeeded];
    [UIView animateWithDuration:0.5 animations:^{
        [self.seriesListViewController.view mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(_weakContainerView.mas_right).offset(0);
        }];
        //        //必须调用此方法，才能出动画效果
        [self.seriesListViewController.view layoutIfNeeded];
        [_rightMaskView setNeedsUpdateConstraints];
        [_rightMaskView updateConstraintsIfNeeded];
        [_rightMaskView updateConstraints];

    }
                     completion:^(BOOL finished) {

                     }];
}
- (IBAction)shoppingCarClicked:(id)sender{}

- (IBAction)searchButtonClicked:(id)sender{
    _searchField.text = nil;
    if (_searchField.alpha == 0.0) {
        _searchField.alpha = 1.0;
        _searchField.transform = CGAffineTransformMakeScale(1.00f, 1.00f);
        _searchButton.alpha = 0.0;
        _searchButton.transform = CGAffineTransformMakeScale(0.01f, 0.01f);
        _searchFieldWidthConstraint.constant = searchFieldWidthMaxConstraint;
        _searchField.placeholder = NSLocalizedString(@"输入款式名称/款号/颜色搜索",nil);

        [UIView animateWithDuration:animateDuration animations:^{
            [_searchField layoutIfNeeded];
        } completion:^(BOOL finished) {
            [_searchField becomeFirstResponder];
        }];
    }

}

#pragma mark - --------------自定义方法----------------------

-(void)updateMenuUI{
    NSString *title = @"";
    if(_seriesInfoDetailModel != nil){
        title = _seriesInfoDetailModel.brandName;
    }
    self.navigationBarViewController.nowTitle = title;
    [self.navigationBarViewController updateUI];
    
    NSString *supplyTimeStr  = [NSString stringWithFormat:NSLocalizedString(@"发货日期：%@-%@",nil),getShowDateByFormatAndTimeInterval(@"yyyy-MM-dd HH:mm:ss",[_seriesModel.supplyStartTime stringValue]),getShowDateByFormatAndTimeInterval(@"yyyy-MM-dd HH:mm:ss",[_seriesModel.supplyEndTime stringValue])];
    NSString *orderDueTimeStr = [NSString stringWithFormat:NSLocalizedString(@"最晚下单：%@",nil),getShowDateByFormatAndTimeInterval(@"yyyy-MM-dd HH:mm:ss",_seriesModel.orderDueTime)];
    _nameLabel.text = _seriesModel.name;
    _timeLabel.text = [NSString stringWithFormat:@"%@   %@",supplyTimeStr,orderDueTimeStr];
}


-(void)OnTapBg:(UITapGestureRecognizer *)sender{
    if (_seriesListViewController && _seriesListViewController.selectedValue) {
        CGPoint point = [sender locationInView:_seriesListViewController.view];
        if([_seriesListViewController.view pointInside:point withEvent:nil]){
            return;
        }
        if(_seriesListViewController.selectedValue){
            _seriesListViewController.selectedValue(@"-1");
        }
    }
}

- (void)addColorViewToCover:(UIImageView *)coverImageView colors:(NSArray *)colorArray{
    
    UIView *lastView = nil;
    UIView *tempContainer = [[UIView alloc] init];
    tempContainer.backgroundColor = [UIColor clearColor];
    __weak UIImageView *weakCoverImageView = coverImageView;
    
    [coverImageView addSubview:tempContainer];
    [tempContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(20);
        make.left.equalTo(weakCoverImageView.mas_left);
        make.bottom.equalTo(weakCoverImageView.mas_bottom);
    }];
    
    __weak UIView *weakContainer = tempContainer;
    for (int i= 0; i < [colorArray count]; i++) {
        NSObject *obj = [colorArray objectAtIndex:i];
        NSString *colorValue = @"";
        if ([obj isKindOfClass:[YYColorModel class]]) {
            YYColorModel *colorModel = (YYColorModel *)obj;
            colorValue = colorModel.value;
        }else if ([obj isKindOfClass:[StyleColors class]]){
            StyleColors *styleColors = (StyleColors *)obj;
            colorValue = styleColors.color_value;
        }
        
        if (colorValue) {
            if ([colorValue hasPrefix:@"#"]
                && [colorValue length] == 7) {
                //16进制的色值
                UIColor *color = [UIColor colorWithHex:[colorValue substringFromIndex:1]];
                UILabel *label = [[UILabel alloc] init];
                label.backgroundColor = color;
                label.layer.borderWidth = 1;
                label.layer.borderColor = kBorderColor.CGColor;
                [tempContainer addSubview:label];
                
                
                [label mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.and.bottom.equalTo(weakContainer);
                    make.width.mas_equalTo(20);
                    
                    if ( lastView )
                    {
                        make.left.mas_equalTo(lastView.mas_right).with.offset(5);
                    }
                    else
                    {
                        make.left.mas_equalTo(weakContainer.mas_left);
                    }
                    
                }];
                lastView = label;
                
                
            }else{
                //是图片的地址
                
                SCGIFImageView *imageView = [[SCGIFImageView alloc] init];
                [tempContainer addSubview:imageView];
                
                imageView.layer.borderWidth = 1;
                imageView.layer.borderColor = kBorderColor.CGColor;
                
                [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.and.bottom.equalTo(weakContainer);
                    make.width.mas_equalTo(20);
                    
                    if ( lastView )
                    {
                        make.left.mas_equalTo(lastView.mas_right).with.offset(5);
                    }
                    else
                    {
                        make.left.mas_equalTo(weakContainer.mas_left);
                    }
                    
                }];
                lastView = imageView;
                
                
                NSString *imageRelativePath = colorValue;
                
                NSString *imageName = [[imageRelativePath lastPathComponent] stringByAppendingString:kStyleColorImageCover];
                NSString *storePath = yyjOfflineSeriesImagePath(self.seriesId,imageRelativePath,imageName);
                
                UIImage *image = [UIImage imageWithContentsOfFile:storePath];
                if (image) {
                    imageView.image = image;
                }else{
                    sd_downloadWebImageWithRelativePath(NO, imageRelativePath, imageView, kStyleColorImageCover, 0);
                    
                }
                
            }
        }
    }
    
    if (lastView) {
        [tempContainer mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(lastView.mas_right);
        }];
    }
}
//刷新界面
- (void)reloadCollectionViewData{
    [self.collectionView.mj_header endRefreshing];
    [self.collectionView.mj_footer endRefreshing];
    [self.collectionView reloadData];
    
    if (!self.stylesListArray || [self.stylesListArray count ]==0) {
        self.noDataView.hidden = NO;
    }else{
        self.noDataView.hidden = YES;
    }
}
-(void)changeSeries:(NSInteger)index{
    self.seriesModel = [_seriesArray objectAtIndex:index];
    self.seriesId = [self.seriesModel.id longValue];
    [self updateMenuUI];
    [self loadDataByPageIndex:1 queryStr:@""];
    [self loadSeriesInfo];
}

-(NSInteger)getSeriesIndex:(NSInteger)seriesId{
    NSInteger index = 0;
    for (YYOpusSeriesModel *seriesModel in _seriesArray) {
        if([seriesModel.id integerValue] == seriesId){
            return index;
        }
        index ++;
    }
    return -1;
}

- (void)addHeader{
    WeakSelf(ws);
    // 添加下拉刷新头部控件
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        // 进入刷新状态就会回调这个Block
        if ([YYNetworkReachability connectedToNetwork]){
            if(ws.searchResultArray == nil){
                [ws loadDataByPageIndex:1 queryStr:@""];
            }else{
                if(![ws.searchField.text isEqualToString:@""]){
                    [ws loadDataByPageIndex:1 queryStr:ws.searchField.text];
                }
            }
        }else{
            [ws.collectionView.mj_header endRefreshing];
            [YYToast showToastWithTitle:kNetworkIsOfflineTips andDuration:kAlertToastDuration];
        }
    }];
    self.collectionView.mj_header = header;
    self.collectionView.mj_header.automaticallyChangeAlpha = YES;
    header.lastUpdatedTimeLabel.hidden = YES;
}

- (void)addFooter{
    WeakSelf(ws);
    // 添加上拉刷新尾部控件
    self.collectionView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        // 进入刷新状态就会回调这个Block
        if (![YYNetworkReachability connectedToNetwork]) {
            [YYToast showToastWithTitle:kNetworkIsOfflineTips andDuration:kAlertToastDuration];
            [ws.collectionView.mj_footer endRefreshing];
            return;
        }


        if(ws.searchResultArray == nil){
            if( [ws.stylesListArray count] > 0 && ws.currentPageInfo
               && !ws.currentPageInfo.isLastPage){
                [ws loadDataByPageIndex:[ws.currentPageInfo.pageIndex intValue]+1 queryStr:@""];
                return;
            }
        }else if(![ws.searchField.text isEqualToString:@""] && [ws.searchResultArray count] > 0 && ws.currentSearchPageInfo
                 && !ws.currentSearchPageInfo.isLastPage){
            [ws loadDataByPageIndex:[ws.currentSearchPageInfo.pageIndex intValue]+1 queryStr:ws.searchField.text];
            return;
        }

        [ws.collectionView.mj_footer endRefreshing];
    }];
}
-(void)showDescUI:(CGSize)uiSize txtAttrDict:(NSDictionary *)txtAttrDict descStr:(NSString*)descStr point:(CGPoint)point{
    NSInteger space = 13;
    NSInteger menuUIWidth = uiSize.width + space*2;
    NSInteger menuUIHeight = uiSize.height + space*2;
    
    UIViewController *controller = [[UIViewController alloc] init];
    controller.view.frame = CGRectMake(0, 0, menuUIWidth, menuUIHeight);
    controller.view.backgroundColor = [UIColor colorWithHex:kDefaultImageColor];
    UILabel *descLabel = [[UILabel alloc] initWithFrame:CGRectMake(space, space, menuUIWidth-space*2, menuUIHeight-space*2)];
    descLabel.numberOfLines =0;
    descLabel.textColor = [UIColor colorWithHex:@"919191"];
    descLabel.attributedText = [[NSAttributedString alloc] initWithString: descStr attributes: txtAttrDict];
    [controller.view addSubview:descLabel];
    UIPopoverController *popController = [[UIPopoverController alloc] initWithContentViewController:controller];
    _popController = popController;
    UIViewController *parent = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    CGPoint p = point;
    CGRect rc = CGRectMake(p.x-space+menuUIWidth/2, p.y-space*2+2, 0, 0);
    popController.popoverContentSize = CGSizeMake(menuUIWidth,menuUIHeight);
    popController.popoverBackgroundViewClass = [YYPopoverBackgroundView class];
    [popController presentPopoverFromRect:rc inView:parent.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

#pragma mark - --------------other----------------------
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

@end

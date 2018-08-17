//
//  YYBrandAddViewController.m
//  Yunejian
//
//  Created by Apple on 15/12/3.
//  Copyright © 2015年 yyj. All rights reserved.
//

#import "YYConnAddViewController.h"

// c文件 —> 系统文件（c文件在前）

// 控制器
#import "YYNavigationBarViewController.h"
#import "YYConnBuyerInfoViewController.h"

// 自定义视图
#import "YYBrandInfoViewCell.h"
#import "YYBuyerInfoViewCell.h"
#import "MBProgressHUD.h"
#import "YYTopAlertView.h"

// 接口
#import "YYConnApi.h"
#import "YYUserApi.h"

// 分类

// 自定义类和三方类（ cocoapods类 > model > 工具类 > 其他）
#import <MJRefresh.h>

#import "YYConnDesignerModel.h"

#import "RBCollectionViewBalancedColumnLayout.h"

static CGFloat animateDuration = 0.3;
static CGFloat searchFieldWidthDefaultConstraint = 45;
static CGFloat searchFieldWidthMaxConstraint = 200;
@interface YYConnAddViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UITextFieldDelegate,YYTableCellDelegate>
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (weak, nonatomic) IBOutlet UITextField *searchField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchFieldWidthConstraint;
@property (nonatomic,strong)YYNavigationBarViewController *navigationBarViewController;
@property (nonatomic,strong)YYPageInfoModel *currentPageInfo;
@property (nonatomic,strong) UIView *noDataView;
@property (nonatomic,strong) NSMutableArray *designerListArray;

//查询结果
@property (nonatomic) BOOL searchFlag;
@property (nonatomic,strong) NSMutableArray *searchResultArray;
@property (nonatomic,strong) YYPageInfoModel *currentSearchPageInfo;
//展开
@property (nonatomic,assign)NSInteger curShowDetailRow;

@end

@implementation YYConnAddViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    YYNavigationBarViewController *navigationBarViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYNavigationBarViewController"];
    if(!_isAddDesigner){
        navigationBarViewController.previousTitle = NSLocalizedString(@"品牌",nil);
        navigationBarViewController.nowTitle = NSLocalizedString(@"邀请合作品牌",nil);
    }else{
        navigationBarViewController.previousTitle = NSLocalizedString(@"账户",nil);
        navigationBarViewController.nowTitle = NSLocalizedString(@"邀请合作买手店",nil);
    }
    _navigationBarViewController = navigationBarViewController;
    [_containerView insertSubview:navigationBarViewController.view atIndex:0];
    __weak UIView *_weakContainerView = _containerView;
    [navigationBarViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_weakContainerView.mas_top);
        make.left.equalTo(_weakContainerView.mas_left);
        make.bottom.equalTo(_weakContainerView.mas_bottom);
        make.right.equalTo(_weakContainerView.mas_right);
        
    }];
    
    RBCollectionViewBalancedColumnLayout * layout = (id)self.collectionView.collectionViewLayout;
    layout.interItemSpacingY = 25;
    layout.stickyHeader = NO;
    
    _curShowDetailRow = -1;
    
    WeakSelf(ws);
    
    __block YYNavigationBarViewController *blockVc = navigationBarViewController;
    
    [navigationBarViewController setNavigationButtonClicked:^(NavigationButtonType buttonType){
        if (buttonType == NavigationButtonTypeGoBack) {
            if (ws.cancelButtonClicked) {
                ws.cancelButtonClicked();
            }
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

    [self addHeader];
    [self addFooter];

    self.collectionView.alwaysBounceVertical = YES;
    self.noDataView = addNoDataView_pad(self.view,nil,nil,nil);
    self.noDataView.hidden = YES;
    self.designerListArray = [[NSMutableArray alloc] init];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self loadDataByPageIndex:1 queryStr:@""];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    // 由于 brand功能没有了，所以isAddDesigner 只有yes一个值，所以只有邀请合作买手店的功能
    // 进入埋点
    [MobClick beginLogPageView:kYYPageConnAdd];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    // 退出埋点
    [MobClick endLogPageView:kYYPageConnAdd];
}



- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)searchBtnHandler:(id)sender {
    _searchField.text = nil;
    if (_searchField.alpha == 0.0) {
        _searchField.alpha = 1.0;
        _searchField.transform = CGAffineTransformMakeScale(1.00f, 1.00f);
        _searchButton.alpha = 0.0;
        _searchButton.transform = CGAffineTransformMakeScale(0.01f, 0.01f);
        _searchFieldWidthConstraint.constant = searchFieldWidthMaxConstraint;
        _searchField.placeholder = NSLocalizedString(@"输入名称",nil);

        [UIView animateWithDuration:animateDuration animations:^{
            [_searchField layoutIfNeeded];
        } completion:^(BOOL finished) {
            [_searchField becomeFirstResponder];
        }];
    }
}

#pragma mark -  UITextFieldDelegate

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
        //NSLog(@"textFieldDidEndEditing.....");
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

#pragma mark - 键盘隐藏
- (void)keyboardWillHide:(NSNotification *)note
{
    if (_searchField.text == nil
        || [_searchField.text length] == 0) {
        _searchFieldWidthConstraint.constant = searchFieldWidthDefaultConstraint;
        _searchField.placeholder = nil;
        
        [UIView animateWithDuration:animateDuration animations:^{
            [_searchField layoutIfNeeded];
        } completion:^(BOOL finished) {
            [_searchField resignFirstResponder];
            
            [UIView animateWithDuration:animateDuration animations:^{
                _searchField.alpha = 0.0;
                if(SYSTEM_VERSION_LESS_THAN(@"8.0")){
                   //_searchField.transform = CGAffineTransformMakeScale(0.5f, 1.00f);
                }else{
                    _searchField.transform = CGAffineTransformMakeScale(0.01f, 0.01f);
                }
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:animateDuration animations:^{
                    _searchButton.alpha = 1.0;
                    _searchButton.transform = CGAffineTransformMakeScale(1.00f, 1.00f);
                }];
            }];
            
            
        }];
    }
}

#pragma mark -  UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if(_searchResultArray != nil){
        return [_searchResultArray count];
    }
    return [_designerListArray count];
}

//定义每个Section 的 margin
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 20, 0, 20);//分别为上、左、下、右
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(!_isAddDesigner){
        YYConnDesignerModel *designerModel = nil;
        if(_searchResultArray != nil && ([_searchResultArray count] > indexPath.row)){
            designerModel =[_searchResultArray objectAtIndex:indexPath.row];
        }else if ([_designerListArray count] > indexPath.row) {
            designerModel = [_designerListArray objectAtIndex:indexPath.row];
        }
        static NSString* reuseIdentifier = @"YYBrandInfoViewCell";
        YYBrandInfoViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
        cell.indexPath = indexPath;
        cell.delegate = self;
        cell.designerModel = designerModel;
        cell.curShowDetailRow = _curShowDetailRow;
        [cell updateUI];
        return cell;
    }else{
        YYBuyerModel *buyerModel = nil;
        if(_searchResultArray != nil && ([_searchResultArray count] > indexPath.row)){
            buyerModel =[_searchResultArray objectAtIndex:indexPath.row];
        }else if ([_designerListArray count] > indexPath.row) {
            buyerModel = [_designerListArray objectAtIndex:indexPath.row];
        }
        static NSString* reuseIdentifier = @"YYBuyerInfoViewCell";
        YYBuyerInfoViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
        cell.indexPath = indexPath;
        cell.delegate = self;
        cell.buyerModel = buyerModel;
        [cell updateUI];
        return cell;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}
#pragma YYTableCellDelegate
-(void)btnClick:(NSInteger)row section:(NSInteger)section andParmas:(NSArray *)parmas{
    WeakSelf(ws);
    if(!_isAddDesigner){
        if(parmas == nil){
            if(_curShowDetailRow == row){
                _curShowDetailRow = -1;
            }else{
                _curShowDetailRow = row;
            }
            [self.collectionView reloadData];

        }else{
            YYConnDesignerModel *designerModel = nil;
            if(_searchResultArray != nil && ([_searchResultArray count] > row)){
                designerModel =[_searchResultArray objectAtIndex:row];
            }else if ([_designerListArray count] > row) {
                designerModel = [_designerListArray objectAtIndex:row];
            }
            if(designerModel && [designerModel.connectStatus integerValue] == -1){
                __block YYConnDesignerModel *blockDesignerModel = designerModel;
                
                CMAlertView *alertView = [[CMAlertView alloc] initWithTitle:NSLocalizedString(@"确定邀请吗？",nil) message:nil needwarn:NO delegate:nil cancelButtonTitle:NSLocalizedString(@"取消邀请",nil) otherButtonTitles:@[[[NSString alloc] initWithFormat:@"%@|000000",NSLocalizedString(@"继续邀请",nil)]]];
                alertView.specialParentView = self.view;
                
                [alertView setAlertViewBlock:^(NSInteger selectedIndex){
                    if (selectedIndex == 1) {
                        [YYConnApi invite:[blockDesignerModel.id integerValue] andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSError *error) {
                            if(rspStatusAndMessage.status == kCode100){
                                blockDesignerModel.connectStatus = 0;
                                //[YYToast showToastWithTitle:rspStatusAndMessage.message andDuration:kAlertToastDuration];
                                [YYTopAlertView showWithType:YYTopAlertTypeSuccess text:rspStatusAndMessage.message parentView:nil];

                                [ws.collectionView reloadData];
                            }
                        }];
                    }
                }];
                
                [alertView show];
            }else{
                [YYToast showToastWithTitle:NSLocalizedString(@"发送送邀请，未处理",nil) andDuration:kAlertToastDuration];
            }
        }
    
    }else{
        YYBuyerModel *buyerModel = nil;
        if(_searchResultArray != nil && ([_searchResultArray count] > row)){
            buyerModel =[_searchResultArray objectAtIndex:row];
        }else if ([_designerListArray count] > row) {
            buyerModel = [_designerListArray objectAtIndex:row];
        }
        if(parmas == nil){
            WeakSelf(ws);
            [YYUserApi getUserStatus:[buyerModel.buyerId integerValue] andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSInteger status, NSError *error) {
                if(rspStatusAndMessage.status == kCode100){
                    if(status != kUserStatusStop && status >-1){
                        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Account" bundle:[NSBundle mainBundle]];
                        YYConnBuyerInfoViewController *connInfoController = [storyboard instantiateViewControllerWithIdentifier:@"YYConnBuyerInfoViewController"];
                        connInfoController.buyerId = [buyerModel.buyerId integerValue];
                        connInfoController.previousTitle =  _navigationBarViewController.nowTitle;
                        __block YYBuyerModel *blockBuyerModel = buyerModel;
                        [connInfoController setModifySuccess2:^(){
                            blockBuyerModel.connectStatus = [[NSNumber alloc] initWithInt:kConnStatus];//;
                            [ws.collectionView reloadData];
                        }];
                        [connInfoController setModifySuccess1:^(){
                            blockBuyerModel.connectStatus = kConnStatus0;
                            [ws.collectionView reloadData];
                        }];
                        [ws.navigationController pushViewController:connInfoController animated:YES];
                    }else{
                        [YYToast showToastWithView:ws.view title:NSLocalizedString(@"此买手店账号已停用",nil) andDuration:kAlertToastDuration];
                    }
                }else{
                    [YYToast showToastWithView:ws.view title:rspStatusAndMessage.message andDuration:kAlertToastDuration];
                }
            }];

        }else{
            if(buyerModel && [buyerModel.connectStatus integerValue] == -1){
                __block YYBuyerModel *blockBuyerModel = buyerModel;


                    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                    [YYConnApi invite:[blockBuyerModel.buyerId integerValue] andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSError *error) {
                        if(rspStatusAndMessage.status == kCode100){
                            blockBuyerModel.connectStatus = 0;
                            [ws.collectionView reloadData];
                        }
                        [YYTopAlertView showWithType:YYTopAlertTypeSuccess text:NSLocalizedString(@"邀请买手店成功", nil) parentView:nil];

                        [MBProgressHUD hideAllHUDsForView:ws.view animated:YES];
                    }];

            }else{
                [YYToast showToastWithTitle:NSLocalizedString(@"发送送邀请，未处理",nil) andDuration:kAlertToastDuration];
            }
        }
    }

}
#pragma mark - RBCollectionViewBalancedColumnLayoutDelegate

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(RBCollectionViewBalancedColumnLayout*)collectionViewLayout heightForHeaderInSection:(NSInteger)section{
    return 0.1;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(RBCollectionViewBalancedColumnLayout*)collectionViewLayout heightForItemAtIndexPath:(NSIndexPath *)indexPath{
    if(!_isAddDesigner){
        if(indexPath.row==_curShowDetailRow){
            YYConnDesignerModel *designerModel = nil;
            if(_searchResultArray != nil && ([_searchResultArray count] > indexPath.row)){
                designerModel =[_searchResultArray objectAtIndex:indexPath.row];
            }else if ([_designerListArray count] > indexPath.row) {
                designerModel = [_designerListArray objectAtIndex:indexPath.row];
            }
            return [YYBrandInfoViewCell HeightForCell:designerModel.brandDescription];
        }
        return 335;
    }else{
        return 300;
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(RBCollectionViewBalancedColumnLayout*)collectionViewLayout heightForFooterInSection:(NSInteger)section{
    return 0.1;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(RBCollectionViewBalancedColumnLayout *)collectionViewLayout widthForCellsInSection:(NSInteger)section{
    return 435;
}

#pragma MJRefresh.h
//刷新界面
- (void)reloadCollectionViewData{
    [self.collectionView.mj_header endRefreshing];
    [self.collectionView.mj_footer endRefreshing];
    [self.collectionView reloadData];
    
    if (!self.designerListArray || [self.designerListArray count ]==0) {
        self.noDataView.hidden = NO;
    }else{
        self.noDataView.hidden = YES;
    }
}

//加载品牌，
- (void)loadDataByPageIndex:(int)pageIndex queryStr:(NSString*)queryStr{
    WeakSelf(ws);
    if(!_isAddDesigner){
        [YYConnApi queryDesignerWithQueryStr:queryStr pageIndex:pageIndex pageSize:4 andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYConnDesignerListModel *designerListModel, NSError *error) {
            if (rspStatusAndMessage.status == kCode100 && designerListModel.result
                    && [designerListModel.result count] > 0) {
                if(ws.searchResultArray == nil){
                    ws.currentPageInfo = designerListModel.pageInfo;
                    if (ws.currentPageInfo== nil || ws.currentPageInfo.isFirstPage) {
                        [ws.designerListArray removeAllObjects];
                    }
                    [ws.designerListArray addObjectsFromArray:designerListModel.result];
                }else{
                    ws.currentSearchPageInfo = designerListModel.pageInfo;
                    if (ws.currentSearchPageInfo == nil || ws.currentSearchPageInfo.isFirstPage) {
                        [ws.searchResultArray removeAllObjects];
                    }
                    [ws.searchResultArray addObjectsFromArray:designerListModel.result];
                }
            }
        
            [MBProgressHUD hideAllHUDsForView:ws.view animated:YES];
            if (rspStatusAndMessage.status != kCode100) {
                [YYToast showToastWithTitle:rspStatusAndMessage.message  andDuration:kAlertToastDuration];
            }
            [ws reloadCollectionViewData];
        }];
    }else{
        [YYConnApi queryConnBuyer:queryStr pageIndex:pageIndex pageSize:4 andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYBuyerListModel *buyerList, NSError *error) {
            if (rspStatusAndMessage.status == kCode100 && buyerList.result
                && [buyerList.result count] > 0) {
                if(ws.searchResultArray == nil){
                    ws.currentPageInfo = buyerList.pageInfo;
                    if (ws.currentPageInfo== nil || ws.currentPageInfo.isFirstPage) {
                        [ws.designerListArray removeAllObjects];
                    }
                    [ws.designerListArray addObjectsFromArray:buyerList.result];
                }else{
                    ws.currentSearchPageInfo = buyerList.pageInfo;
                    if (ws.currentSearchPageInfo == nil || ws.currentSearchPageInfo.isFirstPage) {
                        [ws.searchResultArray removeAllObjects];
                    }
                    [ws.searchResultArray addObjectsFromArray:buyerList.result];
                }
            }
            
            [MBProgressHUD hideAllHUDsForView:ws.view animated:YES];
            if (rspStatusAndMessage.status != kCode100) {
                [YYToast showToastWithTitle:rspStatusAndMessage.message  andDuration:kAlertToastDuration];
            }
            [ws reloadCollectionViewData];
        }];
    }
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
            if( [ws.designerListArray count] > 0 && ws.currentPageInfo
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

@end

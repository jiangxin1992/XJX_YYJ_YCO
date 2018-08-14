//
//  DD_CircleSearchView.m
//  YCO SPACE
//
//  Created by yyj on 16/8/15.
//  Copyright © 2016年 YYJ. All rights reserved.
//

#import "DD_CircleSearchView.h"

#import "YYShowroomMainNoDataView.h"
#import "YYShowroomMainCollectionView.h"

#import "YYShowroomBrandListModel.h"
#import "YYShowroomBrandModel.h"
#import "YYShowroomBrandTool.h"
#import "regular.h"

@interface DD_CircleSearchView()<UISearchBarDelegate>

@property (strong ,nonatomic) NSMutableArray *arrayData;//排序好的数据

@property (strong ,nonatomic) UISearchBar *searchBar;
@property (strong ,nonatomic) UIView *searchView;
@property (strong ,nonatomic) YYShowroomMainNoDataView *noDataView;
@property (strong, nonatomic) YYShowroomMainCollectionView *collectionView;

@end

@implementation DD_CircleSearchView

-(instancetype)initWithQueryStr:(NSString *)queryStr WithBlock:(void(^)(NSString *type,NSString *queryStr,YYShowroomBrandModel *ShowroomBrandModel))block;
{
    self=[super initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    if(self)
    {
        _block=block;
        _queryStr=queryStr;
        [self SomePrepare];
        [self UIConfig];
    }
    return self;
}
#pragma mark - SomePrepare
-(void)SomePrepare
{
    [self PrepareData];
    [self PrepareUI];
}

-(void)PrepareData{
    _arrayData = [[NSMutableArray alloc] init];
}
-(void)PrepareUI
{
    self.backgroundColor = _define_white_color;
}

#pragma mark - UIConfig
-(void)UIConfig
{
    [self CreateSearchBar];
    [self CreateOrUpdateCollectionView];
}
-(void)CreateSearchBar
{
    _searchView=[UIView getCustomViewWithColor:nil];
    [self addSubview:_searchView];
    [_searchView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(20);
        make.height.mas_equalTo(49);
    }];
    
    UIButton *cancelBtn=[UIButton getCustomTitleBtnWithAlignment:0 WithFont:15.0f WithSpacing:2 WithNormalTitle:NSLocalizedString(@"取消", nil) WithNormalColor:[UIColor colorWithHex:@"919191"] WithSelectedTitle:nil WithSelectedColor:nil];
    [_searchView addSubview:cancelBtn];
    [cancelBtn setEnlargeEdgeWithTop:0 right:0 bottom:0 left:15];
    [cancelBtn addTarget:self action:@selector(rightAction) forControlEvents:UIControlEventTouchUpInside];
    [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(0);
        make.width.mas_equalTo(79);
        make.centerY.mas_equalTo(_searchView);
        make.height.mas_equalTo(30);
    }];
    
    _searchBar = [[UISearchBar alloc] init];
    [_searchView addSubview:_searchBar];
    _searchBar.delegate=self;
    _searchBar.placeholder=NSLocalizedString(@"搜索品牌名称",nil);
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.frame=CGRectMake(0, 0, 200, 30);
    imageView.backgroundColor = [UIColor whiteColor];
    
    UIView *tempView = [UIView getCustomViewWithColor:nil];
    [imageView addSubview:tempView];
    [tempView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 1, 0, 1));
    }];
    tempView.layer.masksToBounds = YES;
    tempView.layer.cornerRadius = 15.0f;
    tempView.layer.borderColor = [_define_black_color CGColor];
    tempView.layer.borderWidth = 1;
    [_searchBar insertSubview:imageView atIndex:1];
    _searchBar.searchBarStyle=UISearchBarStyleDefault;
    _searchBar.text=_queryStr;
    [_searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(200);
        make.right.mas_equalTo(cancelBtn.mas_left).with.offset(0);
        make.centerY.mas_equalTo(_searchView);
        make.height.mas_equalTo(30);
    }];
    [_searchBar becomeFirstResponder];
    
    UITextField * searchField = [_searchBar valueForKey:@"_searchField"];
    searchField.backgroundColor=[UIColor clearColor];
    [searchField setValue:getFont(14.0f) forKeyPath:@"_placeholderLabel.font"];
    [searchField setValue:[UIColor colorWithHex:@"AFAFAF"] forKeyPath:@"_placeholderLabel.textColor"];
    searchField.textColor=_define_black_color;
    searchField.leftViewMode=UITextFieldViewModeNever;
    
    UIView *bottomView=[UIView getCustomViewWithColor:[UIColor colorWithHex:@"d3d3d3"]];
    [_searchView addSubview:bottomView];
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        make.height.mas_equalTo(1);
    }];
}

-(void)CreateOrUpdateCollectionView{
    if(!_collectionView){
        WeakSelf(ws);
        _collectionView = [[YYShowroomMainCollectionView alloc] initWithFrame:CGRectMake(0, 69, SCREEN_WIDTH, SCREEN_HEIGHT-69)];
        [self addSubview:_collectionView];
        [_collectionView setCollectionViewDelegateBlock:^(NSString *type, NSIndexPath *indexPath) {
            if([type isEqualToString:@"didselect"]){
                YYShowroomBrandModel *showroomModel = [ws.arrayData objectAtIndex:indexPath.row];
                ws.block(type,@"",showroomModel);
            }
        }];
    }
    _collectionView.arrayData = _arrayData;
    [_collectionView reloadCollectionData];
}

#pragma mark - someAction
-(void)searchAction
{
    [_arrayData removeAllObjects];
    if(![NSString isNilOrEmpty:_searchBar.text.uppercaseString]&&_ShowroomBrandListModel)
    {
        NSMutableDictionary *_dictPinyinAndChinese = [YYShowroomBrandTool getPinyinAndChinese];
        NSMutableArray *tempBrandList = [[NSMutableArray alloc] init];
        [_ShowroomBrandListModel.brandList enumerateObjectsUsingBlock:^(YYShowroomBrandModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([model.brandName.uppercaseString containsString:_searchBar.text.uppercaseString]) {
                [tempBrandList addObject:model];
            }
        }];
        
        for (YYShowroomBrandModel *model in tempBrandList) {
            
            NSString *pinyin = [model.brandName transformToPinyin];
            
            NSString *charFirst = [pinyin substringToIndex:1];
            //从字典中招关于G的键值对
            NSMutableArray *charArray  = [_dictPinyinAndChinese objectForKey:charFirst];
            //没有找到
            if (charArray) {
                [charArray addObject:model];
                
            }else
            {
                NSMutableArray *subArray = [_dictPinyinAndChinese objectForKey:@"#"];
                //“关羽”
                [subArray addObject:model];
            }
        }
        //获取最终的数据／排序好的数据数组
        NSArray *_arrayChar = [YYShowroomBrandTool getCharArr];//用于存放索引
        [_arrayChar enumerateObjectsUsingBlock:^(NSString *charstr, NSUInteger idx, BOOL * _Nonnull stop) {
            NSMutableArray *tempArr = [_dictPinyinAndChinese objectForKey:charstr];
            if(tempArr.count){
                [_arrayData addObjectsFromArray:tempArr];
            }
        }];
    }

    [self reload];
    
}

-(void)reload
{
    [_collectionView reloadData];
    
    if([NSString isNilOrEmpty:_searchBar.text.uppercaseString])
    {
        _noDataView.hidden=YES;
    }else
    {

        if(_arrayData.count)
        {
            _noDataView.hidden=YES;
        }else
        {
            _noDataView.hidden=NO;
        }
    }
}
-(void)rightAction
{
    if(_block){
        _block(@"back",@"",nil);
    }
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [regular dismissKeyborad];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [regular dismissKeyborad];
}

#pragma mark - UISearchBarDelegate
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [self searchAction];
    NSLog(@"ShouldBeginEditing");
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self searchAction];
    [self CreateOrMoveNoDataView];
}
-(void)CreateOrMoveNoDataView
{
    if(!_noDataView)
    {
        _noDataView = [[YYShowroomMainNoDataView alloc] initNoDataSearchWithSuperView:_collectionView];
    }
    if([NSString isNilOrEmpty:_searchBar.text])
    {
        _noDataView.hidden = YES;
    }else
    {
        if(_arrayData.count)
        {
            _noDataView.hidden = YES;
        }else{
            _noDataView.hidden = NO;
        }
    }
}
@end

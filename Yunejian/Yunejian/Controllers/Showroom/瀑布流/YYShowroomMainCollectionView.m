//
//  YYShowroomMainCollectionView.m
//  Yunejian
//
//  Created by yyj on 2017/3/20.
//  Copyright © 2017年 yyj. All rights reserved.
//

#import "YYShowroomMainCollectionView.h"

#import "YYShowroomBrandHeadView.h"
#import "YYShowroomCollectionViewCell.h"

@interface YYShowroomMainCollectionView()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic,strong) UICollectionViewFlowLayout * layout;

@end

@implementation YYShowroomMainCollectionView
#pragma mark - init
-(instancetype)initWithFrame:(CGRect)frame{
    [self initLayout];
    self = [super initWithFrame:frame collectionViewLayout:_layout];
    if(self){
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
-(void)PrepareData{}
-(void)PrepareUI{
    self.backgroundColor = _define_white_color;
}
-(void)initLayout{
    //创建一个layout布局类
    _layout = [[UICollectionViewFlowLayout alloc]init];
    _layout.minimumInteritemSpacing = 10;
    _layout.minimumLineSpacing = 0;
    _layout.footerReferenceSize = CGSizeMake(SCREEN_WIDTH, 100);
    //设置布局方向为垂直流布局
    _layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    //设置每个item的大小为100*100
    _layout.itemSize = CGSizeMake((SCREEN_WIDTH-40)/2.0f, 100);
}
#pragma mark - UIConfig
-(void)UIConfig{
    //代理设置
    self.delegate=self;
    self.dataSource=self;
    //注册item类型 这里使用系统的类型
    [self registerClass:[YYShowroomCollectionViewCell class] forCellWithReuseIdentifier:@"cellid"];
    [self registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"footview"];
}
#pragma mark - SomeAction
-(void)reloadCollectionData{
    [self reloadData];
}
-(void)setHaveHeadView:(BOOL)haveHeadView
{
    _haveHeadView = haveHeadView;
    if(_haveHeadView){
        [self registerClass:[YYShowroomBrandHeadView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"headview"];
        _layout.headerReferenceSize = CGSizeMake(SCREEN_WIDTH, floor((240.0f/2048.0f)*SCREEN_WIDTH)+80);
    }
    [self reloadData];
}
#pragma mark - UICollectionViewDelegate
//返回每个item
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(_arrayData.count){
        YYShowroomCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellid" forIndexPath:indexPath];
        cell.showroomModel = [_arrayData objectAtIndex:indexPath.row];
        cell.isleft = !(indexPath.row%2);
        return cell;
    }
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell_init" forIndexPath:indexPath];
    return cell;
}
//返回分区个数
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView* )collectionView{
    return 1;
}
//返回每个分区的item个数
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if(_arrayData){
        if(_arrayData.count){
            return _arrayData.count;
        }
    }
    return 0;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(_collectionViewDelegateBlock){
        _collectionViewDelegateBlock(@"didselect",indexPath);
    }
}
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (kind == UICollectionElementKindSectionHeader){
        if(_haveHeadView){
            YYShowroomBrandHeadView * headView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"headview" forIndexPath:indexPath];
            if(_listModel){
                headView.ShowroomBrandListModel = _listModel;
            }
            [headView setBlock:^(NSString *type) {
                if(_collectionViewDelegateBlock){
                    _collectionViewDelegateBlock(type,nil);
                }
            }];
            return headView;
        }
    }
    if(kind == UICollectionElementKindSectionFooter){
        UICollectionReusableView * footView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"footview" forIndexPath:indexPath];
        footView.backgroundColor = _define_white_color;
        return footView;
    }
    return nil;
}
#pragma mark - ScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
{
    if(_scrollViewDelegateBlock){
        _scrollViewDelegateBlock(@"scrollviewdidscroll",scrollView.contentOffset.y);
    }
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if(_scrollViewDelegateBlock){
        _scrollViewDelegateBlock(@"navviewdismiss",scrollView.contentOffset.y);
    }
}
/**
 *  滚动完毕就会调用（如果是人为拖拽scrollView导致滚动完毕，才会调用这个方法）
 */
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if(_scrollViewDelegateBlock){
        _scrollViewDelegateBlock(@"navviewdismiss",scrollView.contentOffset.y);
    }
}

@end

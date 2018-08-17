//
//  YYParcelExceptionDetailViewController.m
//  yunejianDesigner
//
//  Created by yyj on 2018/7/3.
//  Copyright © 2018年 Apple. All rights reserved.
//

#import "YYParcelExceptionDetailViewController.h"

// c文件 —> 系统文件（c文件在前）

// 控制器
#import "YYNavigationBarViewController.h"

// 自定义视图
#import "MBProgressHUD.h"
#import "SCLoopScrollView.h"
#import "YYParcelExceptionInfoCell.h"
#import "YYParcelExceptionStyleCell.h"

// 接口
#import "YYUserApi.h"
#import "YYOrderApi.h"

// 分类

// 自定义类和三方类（ cocoapods类 > model > 工具类 > 其他）
#import "YYParcelExceptionDetailModel.h"

#import "UserDefaultsMacro.h"

@interface YYParcelExceptionDetailViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) YYNavigationBarViewController *navigationBarViewController;
@property (nonatomic, strong) UIView *containerView;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) MBProgressHUD *hud;

@property (nonatomic, strong) YYParcelExceptionDetailModel *parcelExceptionDetailModel;

@end

@implementation YYParcelExceptionDetailViewController

#pragma mark - --------------生命周期--------------
- (void)viewDidLoad {
    [super viewDidLoad];
    [self SomePrepare];
    [self UIConfig];
    [self RequestData];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    // 进入埋点
    [MobClick beginLogPageView:kYYPageParcelExceptionDetail];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    // 退出埋点
    [MobClick endLogPageView:kYYPageParcelExceptionDetail];
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
    self.view.backgroundColor = _define_white_color;

    _containerView = [UIView getCustomViewWithColor:nil];
    [self.view addSubview:_containerView];
    [_containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(50);
        make.top.mas_equalTo(self.mas_topLayoutGuideBottom).with.offset(0);
    }];

    [self createOrUpdateNavView];
}
-(void)createOrUpdateNavView{
    if(!_navigationBarViewController){
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        YYNavigationBarViewController *navigationBarViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYNavigationBarViewController"];
        navigationBarViewController.previousTitle = @"";
        navigationBarViewController.nowTitle = NSLocalizedString(@"异常反馈",nil);
        _navigationBarViewController = navigationBarViewController;
        [_containerView addSubview:navigationBarViewController.view];
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
                if(ws.cancelButtonClicked){
                    ws.cancelButtonClicked();
                }
                [ws.navigationController popViewControllerAnimated:YES];

                blockVc = nil;
            }
        }];
    }

}
#pragma mark - --------------UIConfig----------------------
- (void)UIConfig {
    [self createTableView];
}
-(void)createTableView{
    WeakSelf(ws);
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    [self.view addSubview:_tableView];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(ws.containerView.mas_bottom).with.offset(0);
        make.left.right.bottom.mas_equalTo(0);
    }];

    UIView *footerView = [UIView getCustomViewWithColor:_define_white_color];
    footerView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 60);
    _tableView.tableFooterView = footerView;
}

#pragma mark - --------------请求数据----------------------
- (void)RequestData {
    [self getExceptionDetail];
}
-(void)getExceptionDetail{
    WeakSelf(ws);
    _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [YYOrderApi getExceptionDetailByPackageId:_packageId andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYParcelExceptionDetailModel *parcelExceptionDetailModel, NSError *error) {
        [ws.hud hideAnimated:YES];
        if(rspStatusAndMessage.status == YYReqStatusCode100){
            ws.parcelExceptionDetailModel = parcelExceptionDetailModel;
            [ws.tableView reloadData];
        }else{
            [YYToast showToastWithView:self.view title:rspStatusAndMessage.message andDuration:kAlertToastDuration];
        }
    }];
}
#pragma mark - --------------系统代理----------------------
#pragma mark - TableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 10;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(!_parcelExceptionDetailModel){
        return 0;
    }

    return UITableViewAutomaticDimension;

}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(!_parcelExceptionDetailModel){
        return 0;
    }
    return _parcelExceptionDetailModel.skus.count * 2;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WeakSelf(ws);
    if(!_parcelExceptionDetailModel){
        static NSString *cellid = @"cellid";
        UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:cellid];
        if(!cell){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        return cell;
    }

    if(indexPath.row % 2 == 0){
        static NSString *cellid = @"YYParcelExceptionStyleCell";
        YYParcelExceptionStyleCell *cell = [_tableView dequeueReusableCellWithIdentifier:cellid];
        if(!cell){
            cell = [[YYParcelExceptionStyleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        YYParcelExceptionModel *parcelExceptionModel = _parcelExceptionDetailModel.skus[indexPath.row/2];
        cell.parcelExceptionModel = parcelExceptionModel;
        [cell updateUI];
        return cell;
    }

    static NSString *cellid = @"YYParcelExceptionInfoCell";
    YYParcelExceptionInfoCell *cell = [_tableView dequeueReusableCellWithIdentifier:cellid];
    if(!cell){
        cell = [[YYParcelExceptionInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    YYParcelExceptionModel *parcelExceptionModel = _parcelExceptionDetailModel.skus[indexPath.row/2];
    cell.parcelExceptionModel = parcelExceptionModel;
    cell.indexPath = indexPath;
    [cell setParcelExceptionInfoCellBlock:^(NSString *type,NSIndexPath *indexPath,NSInteger selectIndex) {
        if([type isEqualToString:@"showpics"]){
            [ws showParcelExceptionPics:indexPath selectIndex:(int)selectIndex];
        }
    }];
    [cell updateUI];
    return cell;
}

#pragma mark - --------------自定义代理/block----------------------


#pragma mark - --------------自定义响应----------------------
-(void)showParcelExceptionPics:(NSIndexPath *)indexPath selectIndex:(int)selectIndex{

    YYParcelExceptionModel *parcelExceptionModel = _parcelExceptionDetailModel.skus[indexPath.row/2];

    if(![NSArray isNilOrEmpty:parcelExceptionModel.imgs]){

        NSMutableArray *imgsArr = [[NSMutableArray alloc] init];
        for (NSString *imageName in parcelExceptionModel.imgs) {
            NSString *imgInfo = [NSString stringWithFormat:@"%@%@|%@",imageName,kLookBookImage,@""];
            [imgsArr addObject:imgInfo];
        }

        NSMutableArray *tmpArr = [[NSMutableArray alloc] init];
        for (int i = selectIndex; i < imgsArr.count; i++) {
            NSString *imageName = imgsArr[i];
            [tmpArr addObject:imageName];
        }

        for (int i = 0; i < selectIndex; i++) {
            NSString *imageName = imgsArr[i];
            [tmpArr addObject:imageName];
        }


        SCLoopScrollView *scrollView = [[SCLoopScrollView alloc] initWithFrame:CGRectMake(0, 0, 600, 600)];
        scrollView.backgroundColor = [UIColor clearColor];

        if([tmpArr count] == 1){
            scrollView.images = @[[tmpArr objectAtIndex:0],[tmpArr objectAtIndex:0]];
        }else{
            scrollView.images = tmpArr;
        }
        UILabel *pageLabel = [[UILabel alloc] initWithFrame:CGRectMake((CGRectGetWidth(scrollView.frame) - 100)/2, (CGRectGetHeight(scrollView.frame) - 28 - 15), 100, 28)];
        pageLabel.textColor = [UIColor whiteColor];
        pageLabel.font = [UIFont systemFontOfSize:15];
        pageLabel.textAlignment = NSTextAlignmentCenter;
        pageLabel.text = [NSString stringWithFormat:@"%d / %ld",selectIndex+1,[tmpArr count]];
        __block UILabel *weakpageLabel = pageLabel;
        __block NSInteger blockPagecount = [tmpArr count];

        CMAlertView *alert = [[CMAlertView alloc] initWithViews:@[scrollView,pageLabel] imageFrame:CGRectMake(0, 0, 600, 600) bgClose:NO];
        __block CMAlertView *blockAlert = alert;
        __block NSInteger blockSelectIndex = selectIndex;
        __block NSInteger initialIndex = 1;
        [scrollView show:^(NSInteger index) {
            [blockAlert OnTapBg:nil];
        } finished:^(NSInteger index) {

            NSInteger lastIndex = 0;
            if(initialIndex == 1){
                lastIndex = blockPagecount;
            }else{
                lastIndex = initialIndex - 1;
            }

            NSInteger nextIndex = 0;
            if(initialIndex == blockPagecount){
                nextIndex = 1;
            }else{
                nextIndex = initialIndex + 1;
            }

//            NSLog(@"index = %ld",index);
//            NSLog(@"lastIndex = %ld  nextIndex = %ld",lastIndex,nextIndex);
            BOOL isAdd = NO;
            if(index + 1 == nextIndex){
                isAdd = YES;
            }

            if(isAdd){
                initialIndex = nextIndex;
                blockSelectIndex++;
            }else{
                initialIndex = lastIndex;
                blockSelectIndex--;
            }
            NSInteger nowIndex = blockSelectIndex + 1;
            if(nowIndex == 0){
                nowIndex = blockPagecount;
                blockSelectIndex = blockPagecount - 1;
            }else if(nowIndex > blockPagecount){
                nowIndex = 1;
                blockSelectIndex = 0;
            }

//            NSLog(@"initialIndex = %ld",initialIndex);
//            NSLog(@"nowIndex = %ld",nowIndex);

            [weakpageLabel setText:[NSString stringWithFormat:@"%ld / %ld",MIN(blockPagecount,nowIndex),blockPagecount]];
        }];
        [alert show];

    }
}
#pragma mark - --------------自定义方法----------------------


#pragma mark - --------------other----------------------

@end

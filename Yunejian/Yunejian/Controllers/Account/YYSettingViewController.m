//
//  YYSettingViewController.m
//  Yunejian
//
//  Created by yyj on 15/7/12.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import "YYSettingViewController.h"

#import "YYHelpViewController.h"
#import "YYFeedbackViewController.h"
#import "YYAboutUsViewController.h"
#import "UserDefaultsMacro.h"
#import "AppDelegate.h"
#import "mmDAO.h"
#import "JpushHandler.h"
#import "YYUser.h"
#import <SDImageCache.h>

@interface YYSettingViewController ()

@property(nonatomic,strong) YYFeedbackViewController *feedbackViewController;
@property(nonatomic,strong) YYHelpViewController *helpViewController;
@property(nonatomic,strong) YYAboutUsViewController *aboutUsViewController;

@property(nonatomic,strong) IBOutlet UITableView *tableView;

@property(nonatomic,assign) long cachedSize;

@end

@implementation YYSettingViewController

#pragma mark - 生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
    
    popWindowAddBgView(self.view);
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    // 进入埋点
    [MobClick beginLogPageView:kYYPageSetting];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    // 退出埋点
    [MobClick endLogPageView:kYYPageSetting];
}

#pragma mark - nib

- (IBAction)cancelClicked:(id)sender{
    if (_cancelButtonClicked) {
        _cancelButtonClicked();
    }
}

- (IBAction)testButtonAction:(id)sender{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Account" bundle:[NSBundle mainBundle]];
    YYHelpViewController *helpViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYHelpViewController"];
    [self.navigationController pushViewController:helpViewController animated:YES];
    
}

//计算缓存大小
- (float)calculateCacheSize{
    self.cachedSize = 0;
    NSString *cacheDir = yyjDocumentsDirectory();
    float nowSize = [self fileSizeForDir:cacheDir];
    NSUInteger bytesCache = [[SDImageCache sharedImageCache] getSize];
    float MBCache = bytesCache/1000/1000;
    NSLog(@"nowSize: %f",nowSize+MBCache);
    return nowSize+MBCache;
}

- (IBAction)logout:(id)sender{

    CMAlertView *alertView = [[CMAlertView alloc] initWithTitle:NSLocalizedString(@"退出登录此账户？",nil) message:nil needwarn:NO delegate:nil cancelButtonTitle:NSLocalizedString(@"再逛会儿",nil) otherButtonTitles:@[NSLocalizedString(@"退出登录",nil)]];
    [alertView setAlertViewBlock:^(NSInteger selectedIndex){
        if (selectedIndex == 1) {
            
            if(_block){
                _block();
            }

            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

            //jpush登出
            [JpushHandler sendEmptyAlias];

            //清除用户相关的离线数据
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSString *zipDir = yyjOfflineSeriesZipDirectory();
            [fileManager removeItemAtPath:zipDir error:nil];
            NSString *offlineDir = yyjOfflineSeriesDirectory();
            [fileManager removeItemAtPath:offlineDir error:nil];
             NSString *documents = yyjDocumentsDirectory();
            [fileManager removeItemAtPath:documents error:nil];
            
            //清除本地用户个人信息
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults removeObjectForKey:kUserInfoKey];
            [userDefaults synchronize];
            
            //清除购物车
            [appDelegate clearBuyCar];

            //清空delegate下的临时数据
            [appDelegate delegateTempDataClear];

            //初始化数据库文件
            [[mmDAO instance] setupEnvModel:@"yunejian" DbFile:@"yunejian.sqlite"];

            //重新登录通知
            [[NSNotificationCenter defaultCenter] postNotificationName:kNeedLoginNotification object:nil];
        }
        
    }];
    [alertView show];
}

//显示反馈界面
- (void)showFeedBack{
    
    WeakSelf(ws);

    UIView *superView = self.view;
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Account" bundle:[NSBundle mainBundle]];
    YYFeedbackViewController *feedbackViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYFeedbackViewController"];
    self.feedbackViewController = feedbackViewController;
    
    __weak UIView *weakSuperView = superView;
    UIView *showView = feedbackViewController.view;
    __weak UIView *weakShowView = showView;
    [feedbackViewController setCancelButtonClicked:^(){
        removeFromSuperviewUseUseAnimateAndDeallocViewController(weakShowView,ws.feedbackViewController);
    }];
    
    [feedbackViewController setModifySuccess:^(){
        removeFromSuperviewUseUseAnimateAndDeallocViewController(weakShowView,ws.feedbackViewController);
    }];
    
    
    [superView addSubview:showView];
    [showView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(weakSuperView.mas_top);
        make.left.equalTo(weakSuperView.mas_left);
        make.bottom.equalTo(weakSuperView.mas_bottom);
        make.right.equalTo(weakSuperView.mas_right);
        
    }];
    
    addAnimateWhenAddSubview(showView);
}


- (void)showHelpView{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Account" bundle:[NSBundle mainBundle]];
    YYHelpViewController *helpViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYHelpViewController"];
    self.helpViewController = helpViewController;
    
    UIView *superView = self.view;
    WeakSelf(ws);
    UIView *showView = helpViewController.view;
    __weak UIView *weakShowView = showView;
    [helpViewController setCancelButtonClicked:^(){
        removeFromSuperviewUseUseAnimateAndDeallocViewController(weakShowView,ws.helpViewController);
    }];
    
    [superView addSubview:showView];
    [showView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(SCREEN_HEIGHT);
        make.left.equalTo(superView.mas_left);
        make.bottom.mas_equalTo(SCREEN_HEIGHT);
        make.width.mas_equalTo(SCREEN_WIDTH);
    }];
    [showView.superview layoutIfNeeded];
    [UIView animateWithDuration:kAddSubviewAnimateDuration animations:^{
        [showView mas_updateConstraints:^(MASConstraintMaker *make) {
           make.bottom.mas_equalTo(20);
        }];
        //必须调用此方法，才能出动画效果
        [showView.superview layoutIfNeeded];
    }completion:^(BOOL finished) {
    }];
    
    //addAnimateWhenAddSubview(showView);
}

- (void)showAboutView{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Account" bundle:[NSBundle mainBundle]];
    YYAboutUsViewController *aboutUsViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYAboutUsViewController"];
    self.aboutUsViewController = aboutUsViewController;
    
    UIView *superView = self.view;
    
    WeakSelf(ws);
    __weak UIView *weakSuperView = superView;
    UIView *showView = aboutUsViewController.view;
    __weak UIView *weakShowView = showView;
    [aboutUsViewController setCancelButtonClicked:^(){
        removeFromSuperviewUseUseAnimateAndDeallocViewController(weakShowView,ws.aboutUsViewController);
    }];
    

    
    
    [superView addSubview:showView];
    [showView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(weakSuperView.mas_top);
        make.left.equalTo(weakSuperView.mas_left);
        make.bottom.equalTo(weakSuperView.mas_bottom);
        make.right.equalTo(weakSuperView.mas_right);
        
    }];
    
    addAnimateWhenAddSubview(showView);

    
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return 6;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSArray *cellIndexArr = @[@"5",@"3",@"1",@"0",@"2",@"4"];
    NSString *CellIdentifier = [NSString stringWithFormat:@"MyCell%@",[cellIndexArr objectAtIndex:indexPath.row]];

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (indexPath.row == 1) {
        UILabel *lable = (UILabel *)[cell viewWithTag:89990];
        if (lable) {
           float nowSize = [self calculateCacheSize];
            NSString *showValue = @"";
            if (nowSize < 1) {
                showValue = @"0M";
            }else{
                showValue = [NSString stringWithFormat:@"%iM",(int)nowSize];
            }
            
            lable.text = showValue;
        }
        
    }else  if(indexPath.row == 0) {
        UILabel *lable = (UILabel *)[cell viewWithTag:89990];
        if (lable) {
            if(LanguageManager.currentLanguageIndex == 0){
                lable.attributedText = [self getTextAttributedString:@"EN | 中文" replaceStrs:@[@"中文"] replaceColors:@[@"919191"]];
            }else if(LanguageManager.currentLanguageIndex == 1){
                lable.attributedText = [self getTextAttributedString:@"EN | 中文" replaceStrs:@[@"EN"] replaceColors:@[@"919191"]];
            }
        }
        
    }
    if (cell == nil){
        [NSException raise:@"DetailCell == nil.." format:@"No cells with matching CellIdentifier loaded from your storyboard"];
    }
    return cell;
}

-(NSMutableAttributedString *)getTextAttributedString:(NSString *)targetStr replaceStrs:(NSArray *)replaceStrs replaceColors:(NSArray *)replaceColors{
    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString: targetStr];
    NSInteger index =0;
    for (NSString *replaceStr in replaceStrs) {
        NSRange range = [targetStr rangeOfString:replaceStr];
        if (range.location != NSNotFound) {
            [attributedStr addAttribute: NSForegroundColorAttributeName value: [UIColor colorWithHex:[replaceColors objectAtIndex:index]] range:range];
        }
        index++;
    }
    return attributedStr;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row < 5) {
         return 56;
    }else{
         return 100;
    }
   
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        [self changeLaunguage];
    }else if (indexPath.row == 3) {
        [self showHelpView];
    }else if (indexPath.row == 2) {
        [self  showAboutView];
    }else if (indexPath.row == 4) {
        [self showFeedBack];
    }else if (indexPath.row == 1){
        CMAlertView *alertView = [[CMAlertView alloc] initWithTitle:NSLocalizedString(@"确定清理？",nil) message:nil needwarn:NO delegate:nil cancelButtonTitle:NSLocalizedString(@"否",nil)
 otherButtonTitles:@[[NSString stringWithFormat:@"%@",NSLocalizedString(@"是",nil)]]];
        [alertView setAlertViewBlock:^(NSInteger selectedIndex){
            if (selectedIndex == 1) {
                
                [YYUser initOrClearTempSeriesID];
                
                NSString *cacheDir = yyjDocumentsDirectory();
                NSString *usersListFile = getUsersStorePath();
                NSFileManager *fileManager = [NSFileManager defaultManager];
                [fileManager removeItemAtPath:cacheDir error:nil];
                [fileManager removeItemAtPath:usersListFile error:nil];

                [[SDImageCache sharedImageCache] clearDiskOnCompletion:nil];
                [[SDImageCache sharedImageCache] clearMemory];//可有可无
                
                //获取最新地址
                AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                [appDelegate loadServerInfo];
                
                [self.tableView reloadData];
                [[mmDAO instance] setupEnvModel:@"yunejian" DbFile:@"yunejian.sqlite"];
            }
            
        }];
        [alertView show];
    }
}

- (void)changeLaunguage
{
    NSInteger index = (LanguageManager.currentLanguageIndex?0:1);
    [LanguageManager saveLanguageByIndex:index];
    [self.tableView reloadData];
    [self reloadRootViewController];
    [LanguageManager setLanguageToServer];
}

- (void)reloadRootViewController
{

   AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
   [appDelegate reloadRootViewController:appDelegate.leftMenuIndex];
}

-(float)fileSizeForDir:(NSString*)path//计算文件夹下文件的总大小
{
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSArray* array = [fileManager contentsOfDirectoryAtPath:path error:nil];
    for(int i = 0; i<[array count]; i++)
    {
        NSString *fullPath = [path stringByAppendingPathComponent:[array objectAtIndex:i]];
        
        BOOL isDir;
        if ( !([fileManager fileExistsAtPath:fullPath isDirectory:&isDir] && isDir) )
        {
            NSDictionary *fileAttributeDic=[fileManager attributesOfItemAtPath:fullPath error:nil];
            _cachedSize += fileAttributeDic.fileSize;
        }
        else
        {
            [self fileSizeForDir:fullPath];
        }
    }
    return _cachedSize/(1024.0*1024.0);
    
}


@end

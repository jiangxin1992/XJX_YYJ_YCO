//
//  YYAboutUsViewController.m
//  Yunejian
//
//  Created by yyj on 15/9/17.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import "YYAboutUsViewController.h"

#import "YYProtocolViewController.h"
#import <StoreKit/StoreKit.h>

@interface YYAboutUsViewController ()<UITableViewDataSource,UITableViewDelegate, SKStoreProductViewControllerDelegate>{
    
}

@property(nonatomic,strong) IBOutlet UITableView *tableView;
@property (nonatomic,assign) BOOL ProtocolViewIsShow;

@end

@implementation YYAboutUsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self SomePrepare];
}
#pragma mark - SomePrepare
-(void)SomePrepare
{
    [self PrepareData];
    [self PrepareUI];
}
-(void)PrepareData{
    _ProtocolViewIsShow = NO;
}
-(void)PrepareUI{}
#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return 4;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *CellIdentifier = @"MyCell0";
    if(indexPath.row == 1){
        CellIdentifier = @"MyCell1";
    }else if(indexPath.row == 2){
        CellIdentifier = @"MyCell2";
    }else if(indexPath.row == 3){
        CellIdentifier = @"MyCell3";
    }else if(indexPath.row == 0){
        CellIdentifier = @"MyCellInfo";
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (indexPath.row == 0) {
        UILabel *lable = (UILabel *)[cell viewWithTag:89990];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (lable) {
//            NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
//            NSString *projectName =  [infoDictionary objectForKey:@"CFBundleName"];
            lable.text = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"版本号",nil),kYYCurrentVersion];
        }
        
    }
    
    if (cell == nil){
        [NSException raise:@"DetailCell == nil.." format:@"No cells with matching CellIdentifier loaded from your storyboard"];
    }
    return cell;
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row ==0){
        return 230;
    }else{
        return 55;
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 1) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:KYYYcoFoundationURL]];
    }else if (indexPath.row == 2) {

        [self showProtocolView:NSLocalizedString(@"隐私协议",nil) protocolType:@"secrecyAgreement"];
    }else if (indexPath.row == 3) {
        [self showProtocolView:NSLocalizedString(@"服务协议",nil) protocolType:@"serviceAgreement"];
    }else if (indexPath.row == 6){
        [self goToAppStore];
    }
}
#pragma mark - SomeAction
-(void)showProtocolView:(NSString *)nowTitle protocolType:(NSString*)protocolType{
    if(!_ProtocolViewIsShow){
        _ProtocolViewIsShow = YES;
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Account" bundle:[NSBundle mainBundle]];
        YYProtocolViewController *protocolViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYProtocolViewController"];
        protocolViewController.nowTitle = nowTitle;
        protocolViewController.protocolType = protocolType;
        //    self.protocolViewController = protocolViewController;
        //    [self.navigationController pushViewController:protocolViewController animated:YES];
        //    WeakSelf(weakSelf);
        //    [protocolViewController setCancelButtonClicked:^(){
        //        [weakSelf.navigationController popViewControllerAnimated:YES];
        //    }];
        
        UIView *superView = self.view;
        WeakSelf(ws);
        __weak UIView *weakSuperView = superView;
        UIView *showView = protocolViewController.view;
        __weak UIView *weakShowView = showView;
        __block YYProtocolViewController *tempCTN = protocolViewController;
        [protocolViewController setCancelButtonClicked:^(){
            removeFromSuperviewUseUseAnimateAndDeallocViewController(weakShowView,tempCTN);
            ws.ProtocolViewIsShow = NO;
        }];
        [superView addSubview:showView];
        [showView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(SCREEN_HEIGHT);
            make.left.equalTo(weakSuperView.mas_left);
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
    }
}
- (IBAction)cancelClicked:(id)sender{
    if (_cancelButtonClicked) {
        _cancelButtonClicked();
    }
}
-(void)goToAppStore
{
    //    NSString *str = [NSString stringWithFormat:
    //                     @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@",kYYAppID]; //appID 解释如下
    //    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
    
    SKStoreProductViewController *storeProductViewController = [[SKStoreProductViewController alloc] init];
    // Configure View Controller
    [storeProductViewController setDelegate:self];
    [storeProductViewController loadProductWithParameters:@{SKStoreProductParameterITunesItemIdentifier : kYYAppID}
                                          completionBlock:^(BOOL result, NSError *error) {
                                              if (error) {
                                                  NSLog(@"Error %@ with User Info %@.", error, [error userInfo]);
                                              } else {
                                                  // Present Store Product View Controller
                                                  [self presentViewController:storeProductViewController animated:YES completion:nil];
                                              }
                                          }];
    
}

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end

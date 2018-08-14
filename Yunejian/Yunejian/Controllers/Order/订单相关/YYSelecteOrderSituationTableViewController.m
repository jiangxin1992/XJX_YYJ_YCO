//
//  YYSelecteOrderSituationTableViewController.m
//  Yunejian
//
//  Created by yyj on 15/8/20.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import "YYSelecteOrderSituationTableViewController.h"

@interface YYSelecteOrderSituationTableViewController ()

@end

@implementation YYSelecteOrderSituationTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    //修复分割线左边空15格像素
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)])
    {
        //7.0
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)])
    {
        //在8.0系统下
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    self.tableView.separatorColor = [UIColor blackColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (_currentOrderSettingInfoModel
        && _currentOrderSettingInfoModel.occasionList) {
        return [_currentOrderSettingInfoModel.occasionList count];
    }
    
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellReuseIdentifier = @"reuseIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellReuseIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellReuseIdentifier];
    }
    
    
    NSString *showValue = [_currentOrderSettingInfoModel.occasionList objectAtIndex:indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.contentView.backgroundColor = [UIColor whiteColor];
    cell.textLabel.textColor = [UIColor blackColor];
    cell.textLabel.font = getFont(13.0f);
    if (showValue) {
        if ([showValue isEqualToString:_currentSituation]) {
            //cell.accessoryType = UITableViewCellAccessoryCheckmark;
            self.currentSituation = showValue;
            cell.contentView.backgroundColor = [UIColor blackColor];
            cell.textLabel.textColor = [UIColor whiteColor];

        }
        cell.textLabel.text = showValue;
        cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.textLabel.numberOfLines = 0;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *showValue = [_currentOrderSettingInfoModel.occasionList objectAtIndex:indexPath.row];
    
    self.currentSituation = showValue;
    
    [self.tableView reloadData];
    
    if (self.selectedValue) {
        self.selectedValue(showValue);
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)])
    {
        //在7.0系统下
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)])
    {
        //在8.0系统下
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

@end

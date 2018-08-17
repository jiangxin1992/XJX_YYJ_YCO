//
//  YYSelectPayMethodTableViewController.m
//  Yunejian
//
//  Created by yyj on 15/8/21.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import "YYSelectPayMethodTableViewController.h"

#import "YYOrderSettingInfoModel.h"

@interface YYSelectPayMethodTableViewController ()

@end

@implementation YYSelectPayMethodTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (_currentOrderSettingInfoModel
        && _currentOrderSettingInfoModel.payList) {
        return [_currentOrderSettingInfoModel.payList count];
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellReuseIdentifier = @"reuseIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellReuseIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellReuseIdentifier];
    }
    
    
    NSString *showValue = [_currentOrderSettingInfoModel.payList objectAtIndex:indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.contentView.backgroundColor = [UIColor whiteColor];
    cell.textLabel.textColor = [UIColor blackColor];
    if (showValue) {
        if ([showValue isEqualToString:_currentPayMethod]) {
            self.currentPayMethod = showValue;
            cell.contentView.backgroundColor = [UIColor blackColor];
            cell.textLabel.textColor = [UIColor whiteColor];

        }
        cell.textLabel.text = showValue;
        cell.textLabel.font = getFont(13.0f);
        cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.textLabel.numberOfLines = 1;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *showValue = [_currentOrderSettingInfoModel.payList objectAtIndex:indexPath.row];
    
    self.currentPayMethod = showValue;
    
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

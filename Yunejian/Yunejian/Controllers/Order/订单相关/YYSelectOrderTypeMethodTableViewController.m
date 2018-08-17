//
//  YYSelectOrderTypeMethodTableViewController.m
//  Yunejian
//
//  Created by yyj on 2018/8/2.
//  Copyright © 2018年 yyj. All rights reserved.
//

#import "YYSelectOrderTypeMethodTableViewController.h"

@interface YYSelectOrderTypeMethodTableViewController ()

@end

@implementation YYSelectOrderTypeMethodTableViewController

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
    if (_orderTypeArray) {
        return _orderTypeArray.count;
    }

    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellReuseIdentifier = @"reuseIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellReuseIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellReuseIdentifier];
    }

    NSString *showValue = nil;
    if(indexPath.row == 0){
        showValue = @"BUYOUT";
    }else if(indexPath.row == 1){
        showValue = @"CONSIGNMENT";
    }
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.contentView.backgroundColor = [UIColor whiteColor];
    cell.textLabel.textColor = [UIColor blackColor];
    cell.textLabel.font = getFont(13.0f);
    if (showValue) {
        if ([showValue isEqualToString:_currentMethod]) {
            cell.contentView.backgroundColor = [UIColor blackColor];
            cell.textLabel.textColor = [UIColor whiteColor];
        }
        cell.textLabel.text = _orderTypeArray[indexPath.row];
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *showValue = nil;
    if(indexPath.row == 0){
        showValue = @"BUYOUT";
    }else if(indexPath.row == 1){
        showValue = @"CONSIGNMENT";
    }

    if(![NSString isNilOrEmpty:showValue]){
        self.currentMethod = showValue;
        if (self.selectedValue) {
            self.selectedValue(showValue);
        }
    }

    [self.tableView reloadData];
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

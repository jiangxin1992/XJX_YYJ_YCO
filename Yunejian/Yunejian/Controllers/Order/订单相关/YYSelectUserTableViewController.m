//
//  YYSelectUserTableViewController.m
//  Yunejian
//
//  Created by yyj on 15/8/20.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import "YYSelectUserTableViewController.h"

#import "YYUserApi.h"
#import "YYRspStatusAndMessage.h"

static NSString *CellReuseIdentifier = @"reuseIdentifier";

@interface YYSelectUserTableViewController ()



@end

@implementation YYSelectUserTableViewController

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
    //[self getSellList];
}



- (void)getSellList{
    WeakSelf(ws);
    [YYUserApi getSalesManListWithBlockNew:^(YYRspStatusAndMessage *rspStatusAndMessage, YYSalesManListModel *salesManListModel, NSError *error) {
        if (rspStatusAndMessage.status == YYReqStatusCode100) {
            ws.salesManListModel = salesManListModel;
            dispatch_async(dispatch_get_main_queue(), ^{
                [ws.tableView reloadData];
            });
        }
    }];
    
}

#pragma mark - Table view data source



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if (_salesManListModel
        && _salesManListModel.result) {
        return [_salesManListModel.result count];
    }
    
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellReuseIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellReuseIdentifier];
    }
    
    
    YYSalesManModel *salesManModel = [_salesManListModel.result objectAtIndex:indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.contentView.backgroundColor = [UIColor whiteColor];
    cell.textLabel.textColor = [UIColor blackColor];
    cell.textLabel.font = getFont(13.0f);
    if (salesManModel) {
        if (([salesManModel.userId intValue] == _currentUserId)&&[salesManModel.username isEqualToString:_currentUserName]) {
            //cell.accessoryType = UITableViewCellAccessoryCheckmark;
            self.currentUserId = [salesManModel.userId intValue];
            self.currentUserName = salesManModel.username;
            cell.contentView.backgroundColor = [UIColor blackColor];
            cell.textLabel.textColor = [UIColor whiteColor];

        }
        
        if([salesManModel.userType integerValue] == YYUserTypeShowroom || [salesManModel.userType integerValue] == YYUserTypeShowroomSub)
        {
            if(![NSString isNilOrEmpty:salesManModel.showroomName])
            {
                cell.textLabel.text = [[NSString alloc] initWithFormat:@"%@（%@）",salesManModel.username,salesManModel.showroomName];
            }else
            {
                cell.textLabel.text = salesManModel.username;
            }
        }else
        {
            cell.textLabel.text = salesManModel.username;
        }
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
     YYSalesManModel *salesManModel = [_salesManListModel.result objectAtIndex:indexPath.row];
    self.currentUserId = [salesManModel.userId integerValue];
    self.currentUserName = salesManModel.username;
    [self.tableView reloadData];
    
    if (self.selectedTowValue) {
        self.selectedTowValue(self.currentUserId,self.currentUserName);
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
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end

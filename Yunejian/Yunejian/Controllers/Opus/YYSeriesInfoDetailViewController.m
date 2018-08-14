//
//  YYSeriesInfoDetailViewController.m
//  Yunejian
//
//  Created by Apple on 16/7/25.
//  Copyright © 2016年 yyj. All rights reserved.
//

#import "YYSeriesInfoDetailViewController.h"

// c文件 —> 系统文件（c文件在前）

// 控制器

// 自定义视图

// 接口

// 分类
#import "UIView+UpdateAutoLayoutConstraints.h"

// 自定义类和三方类（ cocoapods类 > model > 工具类 > 其他）
#import "YYSeriesInfoModel.h"
#import "YYSeriesInfoDetailModel.h"

@interface YYSeriesInfoDetailViewController ()
@property (weak, nonatomic) IBOutlet UIButton *authtypeBtn;
@property (weak, nonatomic) IBOutlet UILabel *seasonLabel;
@property (weak, nonatomic) IBOutlet UILabel *cityLabel;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@end

@implementation YYSeriesInfoDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    NSInteger seriesStatus = [_seriesInfoDetailModel.series.status integerValue];
    if(seriesStatus == YYOpusCheckAuthDraft){
        [_authtypeBtn setImage:nil forState:UIControlStateNormal];
        
        [_authtypeBtn setTitle:NSLocalizedString(@"系列为草稿，尚未发布",nil) forState:UIControlStateNormal];
        [_authtypeBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    }else{
    NSInteger _authType = [_seriesInfoDetailModel.series.authType integerValue];
    if(_authType == YYOpusAuthBuyer){
        [_authtypeBtn setImage:[UIImage imageNamed:@"menu_pub_status_buyer1"] forState:UIControlStateNormal];
        [_authtypeBtn setTitle:NSLocalizedString(@"合作买手店可见",nil) forState:UIControlStateNormal];
    }else if (_authType == YYOpusAuthMe){
        [_authtypeBtn setImage:[UIImage imageNamed:@"menu_pub_status_me1"] forState:UIControlStateNormal];
        [_authtypeBtn setTitle:NSLocalizedString(@"仅自己可见",nil) forState:UIControlStateNormal];
    }else if(_authType == YYOpusAuthAll){
        [_authtypeBtn setImage:[UIImage imageNamed:@"menu_pub_status_all1"] forState:UIControlStateNormal];
        [_authtypeBtn setTitle:NSLocalizedString(@"公开",nil) forState:UIControlStateNormal];
    }
        [_authtypeBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 9, 0, 0)];

    }
    if(_seriesInfoDetailModel.series.season){
        _seasonLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@年%@",nil),[_seriesInfoDetailModel.series.year stringValue],_seriesInfoDetailModel.series.season];
    }else{
        _seasonLabel.text = @"";
    }
    _cityLabel.text =[NSString stringWithFormat:@"%@",_seriesInfoDetailModel.series.region];
    NSString *brandDescription = ((_seriesInfoDetailModel.brandDescription && _seriesInfoDetailModel.brandDescription.length)?_seriesInfoDetailModel.brandDescription:NSLocalizedString(@"暂无描述",nil));
    _infoLabel.text = brandDescription;
    float txtHeight = getTxtHeight(CGRectGetWidth(_infoLabel.frame),brandDescription,@{NSFontAttributeName:_infoLabel.font});
    float viewHeight = 306 - 27 + txtHeight;
    [_contentView setConstraintConstant:viewHeight forAttribute:NSLayoutAttributeHeight];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)closeBtn:(id)sender {
    if(self.cancelButtonClicked){
        self.cancelButtonClicked();
    }
}

@end

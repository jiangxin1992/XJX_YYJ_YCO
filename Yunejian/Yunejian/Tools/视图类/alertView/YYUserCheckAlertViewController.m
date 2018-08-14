//
//  YYUserCheckAlertViewController.m
//  Yunejian
//
//  Created by Apple on 15/12/9.
//  Copyright © 2015年 yyj. All rights reserved.
//

#import "YYUserCheckAlertViewController.h"

// c文件 —> 系统文件（c文件在前）

// 控制器

// 自定义视图

// 接口

// 分类
#import "UIView+UpdateAutoLayoutConstraints.h"

// 自定义类和三方类（ cocoapods类 > model > 工具类 > 其他）

@interface YYUserCheckAlertViewController ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *tiplabel;
@property (weak, nonatomic) IBOutlet UIImageView *tipImageView;
@property (weak, nonatomic) IBOutlet UIButton *doBtn;
@property (weak, nonatomic) IBOutlet UIButton *closeBtn;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *yellowLayoutHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *yellowLayoutCenterYConstriant;
@property (weak, nonatomic) IBOutlet UIView *bottomLine;

@end

@implementation YYUserCheckAlertViewController
#pragma mark - --------------生命周期--------------
- (void)viewDidLoad {
    [super viewDidLoad];
    [self SomePrepare];
    [self UIConfig];
    [self RequestData];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - --------------SomePrepare--------------
- (void)SomePrepare
{
    [self PrepareData];
    [self PrepareUI];
}
- (void)PrepareData{}
- (void)PrepareUI{}

#pragma mark - --------------UIConfig----------------------
-(void)UIConfig{
    _closeBtn.hidden = !_needCloseBtn;
    _titleLabel.text = _titelStr;

    if([_iconStr isEqualToString:@""]){
        _tipImageView.hidden = YES;
    }else{
        _tipImageView.hidden = NO;
        _tipImageView.image = [UIImage imageNamed:_iconStr];
    }
    if([_btnStr isEqualToString:@""]){
        _doBtn.hidden = YES;
    }else{
        [_doBtn setTitle:_btnStr forState:UIControlStateNormal];
        _doBtn.hidden = NO;
    }
    NSArray *msgArr = [_msgStr componentsSeparatedByString:@"|"];
    NSString *targetStr = [msgArr objectAtIndex:0];
    NSString *replaceStr = ((msgArr != nil && [msgArr count]>1)?[msgArr objectAtIndex:1]:@"");
    _tiplabel.attributedText = [self getTextAttributedString:targetStr replaceStrs:@[replaceStr] replaceColors:@[@"ef4e31"]];

    if(_funArray != nil){
        NSString *infoMsg = [_funArray componentsJoinedByString:@"\n"];

        NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
        paraStyle.lineSpacing = 8;
        NSDictionary *attrDict = @{ NSParagraphStyleAttributeName: paraStyle,
                                    NSFontAttributeName: [UIFont systemFontOfSize: 12] };
        float needTxtHeight = getTxtHeight(SCREEN_WIDTH, infoMsg, attrDict) + 30;
        [_descLabel setConstraintConstant:needTxtHeight forAttribute:NSLayoutAttributeHeight];

        _descLabel.attributedText=[[NSAttributedString alloc] initWithString:infoMsg attributes: attrDict];
        _descLabel.textAlignment = _textAlignment;
        _yellowLayoutHeightConstraint.constant = 404+needTxtHeight+25;
    }else{
        _descLabel.text = @"";
        _yellowLayoutHeightConstraint.constant = 404;
    }
}

#pragma mark - --------------请求数据----------------------
-(void)RequestData{}

#pragma mark - --------------系统代理----------------------


#pragma mark - --------------自定义代理/block----------------------


#pragma mark - --------------自定义响应----------------------
- (IBAction)closeBtnHandler:(id)sender {
    if(self.select && self.noLongerRemindKey != nil){
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:@"true" forKey:self.noLongerRemindKey];
        [userDefaults synchronize];
    }
    if(self.cancelButtonClicked){
        self.cancelButtonClicked();
    }
}

- (IBAction)doBtnHandler:(id)sender {
    if(self.select && self.noLongerRemindKey != nil){
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:@"true" forKey:self.noLongerRemindKey];
        [userDefaults synchronize];
    }
    if(self.modifySuccess){
        self.modifySuccess();
    }
}

#pragma mark - --------------自定义方法----------------------
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

#pragma mark - --------------other----------------------

@end

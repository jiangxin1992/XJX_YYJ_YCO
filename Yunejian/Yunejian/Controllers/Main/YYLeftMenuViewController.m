//
//  YYLeftMenuViewController.m
//  Yunejian
//
//  Created by yyj on 15/7/8.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import "YYLeftMenuViewController.h"

// c文件 —> 系统文件（c文件在前）

// 控制器

// 自定义视图

// 接口

// 分类
#import "UIImage+YYImage.h"

// 自定义类和三方类（ cocoapods类 > model > 工具类 > 其他）
#import "YYUser.h"

#import "AppDelegate.h"

static const NSInteger buttonTagOffset = 50000;

#define kNormalImageByIndex @"leftMenuButtonIndex_%ld_normal.png"
#define kSelectedImageByIndex @"leftMenuButtonIndex_%ld_selected.png"


#define kBrandNormaolImageName @"leftMenuButtonBrand_normal.png"
#define kBrandSelectedImageName @"leftMenuButtonBrand_selected.png"

@interface YYLeftMenuViewController ()

// 首页
@property (weak, nonatomic) IBOutlet UIButton *leftMenuButton_0;
// 作品
@property (weak, nonatomic) IBOutlet UIButton *leftMenuButton_1;
// 订单
@property (weak, nonatomic) IBOutlet UIButton *leftMenuButton_2;
// 我的
@property (weak, nonatomic) IBOutlet UIButton *leftMenuButton_3;
// 设置
@property (weak, nonatomic) IBOutlet UIButton *leftMenuButton_5;

@property (weak, nonatomic) IBOutlet UIButton *showroomBackButton;
@property (weak, nonatomic) IBOutlet UIImageView *showroomImg;
@property (weak, nonatomic) IBOutlet UILabel *showroomTitle;

@property(nonatomic,strong) UIButton *currentSelectedButton;

@end

@implementation YYLeftMenuViewController
#pragma mark - --------------生命周期--------------
- (void)viewDidLoad {
    [super viewDidLoad];
    [self SomePrepare];
    self.currentSelectedButton = _leftMenuButton_0;
    [self updateSelectedButton:_currentSelectedButton];
}

#pragma mark - --------------SomePrepare--------------
- (void)SomePrepare
{
    [self PrepareData];
    [self PrepareUI];
}
- (void)PrepareData{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuUIChanged:) name:UserTypeChangeNotification object:nil];
}
- (void)menuUIChanged:(NSNotification *)notification{
    [self initAndHiddenSomeButton];
    [self updateSelectedButton:_leftMenuButton_0];
}
- (void)PrepareUI{
    [self initAndHiddenSomeButton];
}

#pragma mark - --------------UIConfig----------------------
- (void)initAndHiddenSomeButton{

    NSString *normal_image_name = [NSString stringWithFormat:kNormalImageByIndex,(NSInteger)5];
    UIImage *highlighted = [UIImage imageNamed:normal_image_name];

    [self.leftMenuButton_5 setImage:[highlighted imageByApplyingAlpha:0.6] forState:UIControlStateHighlighted];

    if([YYUser isShowroomToBrand]){
        [self hideShowroom:NO];
        self.leftMenuButton_0.tag = LeftMenuButtonTypeIndex_0;
        self.leftMenuButton_1.tag = LeftMenuButtonTypeIndex_1;
        self.leftMenuButton_2.tag = LeftMenuButtonTypeIndex_2;
        self.leftMenuButton_5.tag = LeftMenuButtonTypeIndex_5;

        self.leftMenuButton_0.hidden = NO;
        self.leftMenuButton_1.hidden = NO;
        self.leftMenuButton_2.hidden = NO;
        self.leftMenuButton_3.hidden = YES;
        self.leftMenuButton_5.hidden = YES;

    }else{
        [self hideShowroom:YES];
        self.leftMenuButton_0.tag = LeftMenuButtonTypeIndex_0;
        self.leftMenuButton_1.tag = LeftMenuButtonTypeIndex_1;
        self.leftMenuButton_2.tag = LeftMenuButtonTypeIndex_2;
        self.leftMenuButton_3.tag = LeftMenuButtonTypeIndex_3;
        self.leftMenuButton_5.tag = LeftMenuButtonTypeIndex_5;

        self.leftMenuButton_0.hidden = NO;
        self.leftMenuButton_1.hidden = NO;
        self.leftMenuButton_2.hidden = NO;
        self.leftMenuButton_3.hidden = NO;
        self.leftMenuButton_5.hidden = NO;
    }
}

//#pragma mark - --------------请求数据----------------------
//-(void)RequestData{}

#pragma mark - --------------系统代理----------------------


#pragma mark - --------------自定义代理/block----------------------


#pragma mark - --------------自定义响应----------------------
- (IBAction)showroomBackAction:(id)sender {
    if(_cancelButtonClicked)
    {
        _cancelButtonClicked();
    }
}

- (IBAction)buttonAction:(id)sender{
    UIButton *button = (UIButton *)sender;

    if (button == _leftMenuButton_5) {
        if (self.leftMenuButtonClicked) {
            self.leftMenuButtonClicked(button.tag);
        }
    }else{
        if (button != _currentSelectedButton) {
            [self updateSelectedButton:button];
        }
    }
}

#pragma mark - --------------自定义方法----------------------
-(void)hideShowroom:(BOOL)ishide{
    _showroomBackButton.hidden = ishide;
    _showroomImg.hidden = ishide;
    _showroomTitle.hidden = ishide;
}

- (void)setButtonSelectedByButtonIndex:(LeftMenuButtonIndex)leftMenuButtonIndex{
    UIButton *button = (UIButton *)[self.view viewWithTag:leftMenuButtonIndex];
    if (button) {
        [self updateSelectedButton:button];
    }

}

- (void)updateSelectedButton:(UIButton *)button{
    if (_currentSelectedButton != button) {
        UIButton *oldButton = _currentSelectedButton;
        if (oldButton) {

            NSString *normal_image_name = [NSString stringWithFormat:kNormalImageByIndex,_currentSelectedButton.tag-buttonTagOffset];
            NSString *selected_image_name = [NSString stringWithFormat:kSelectedImageByIndex,_currentSelectedButton.tag-buttonTagOffset];

            [oldButton setImage:[UIImage imageNamed:normal_image_name] forState:UIControlStateNormal];
            [oldButton setImage:[UIImage imageNamed:selected_image_name] forState:UIControlStateHighlighted];


        }

        UIButton *nowButton = button;
        if (nowButton) {

            NSString *selected_image_name = [NSString stringWithFormat:kSelectedImageByIndex,button.tag-buttonTagOffset];

            [nowButton setImage:[UIImage imageNamed:selected_image_name] forState:UIControlStateNormal];
            [nowButton setImage:[UIImage imageNamed:selected_image_name] forState:UIControlStateHighlighted];
        }

        _currentSelectedButton = button;

    }else{
        UIButton *nowButton = button;
        if (nowButton) {
            NSInteger index = button.tag-buttonTagOffset;
            NSString *selected_image_name = [NSString stringWithFormat:kSelectedImageByIndex,index];

            [nowButton setImage:[UIImage imageNamed:selected_image_name] forState:UIControlStateNormal];
            [nowButton setImage:[UIImage imageNamed:selected_image_name] forState:UIControlStateHighlighted];

        }

    }
    if (self.leftMenuButtonClicked) {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        appDelegate.leftMenuIndex = _currentSelectedButton.tag;
        self.leftMenuButtonClicked(_currentSelectedButton.tag);
    }
}

#pragma mark - --------------other----------------------

@end


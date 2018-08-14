//
//  YYEditMyPageOneCellView.m
//  Yunejian
//
//  Created by chuanjun sun on 2017/8/18.
//  Copyright © 2017年 yyj. All rights reserved.
//

#import "YYEditMyPageOneCell.h"

// c文件 —> 系统文件（c文件在前）

// 控制器


// 自定义视图
#import "SCGIFButtonView.h"
#import "XXTextView.h"
#import "YYPhotoSelectView.h"


// 接口
#import "YYOrderApi.h"

// 分类
#import "UIImage+Tint.h"

// 自定义类和三方类（cocoapods类、model、工具类等） cocoapods类 —> model —> 其他
#import <MBProgressHUD/MBProgressHUD.h>


#define equalTo(mas) mas_equalTo(mas)
#define offset(mas) mas_offset(mas)
#define MY_MAX 300

@interface YYEditMyPageOneCell()<YYPhotoImageDelegate, UITextViewDelegate>

/** logo */
@property (nonatomic, strong) SCGIFButtonView *logoButton;
/** logo提示 */
@property (nonatomic, strong) UILabel *help1TitleLabel;
/** 蒙版 */
@property (nonatomic, strong) UIImageView *maskImageView;

/** 品牌简介数据 */
@property (nonatomic, strong) XXTextView *introduceTextView;
/** 品牌简介文字提示 */
@property (nonatomic, strong) UILabel *introduceNumberDescLabel;

/** 品牌海报1 */
@property (nonatomic, strong) UIButton *posterIamge1;
/** 品牌海报2 */
@property (nonatomic, strong) UIButton *posterIamge2;
/** 品牌海报3 */
@property (nonatomic, strong) UIButton *posterIamge3;
/** 品牌海报提示1 */
@property (nonatomic, strong) UILabel *tips1Label;
/** 品牌海报提示2 */
@property (nonatomic, strong) UILabel *tips2Label;
/** 品牌海报提示3 */
@property (nonatomic, strong) UILabel *tips3Label;
/** 品牌海报删除按钮1 */
@property (nonatomic, strong) UIButton *delete1Button;
/** 品牌海报删除按钮2 */
@property (nonatomic, strong) UIButton *delete2Button;
/** 品牌海报删除按钮3 */
@property (nonatomic, strong) UIButton *delete3Button;

/** 当前上传的是哪一个控件 1->logo, 2->第一张海报, 3->第二张海报, 4->第三张海报 */
@property (nonatomic, assign) NSInteger buttonTag;

/** 所有的海报 */
@property (nonatomic, strong) NSMutableArray *allPics;

@end

@implementation YYEditMyPageOneCell


#pragma mark - --------------生命周期--------------
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{

    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        [self somePrepare];
    }

    return self;
}

#pragma mark - --------------SomePrepare--------------
- (void)somePrepare
{
    [self prepareData];
    [self prepareUI];
}
- (void)prepareData{

}

#pragma mark - --------------UI----------------------
// 创建子控件
- (void)prepareUI{
    // logoName
    UILabel *logoLabel = [[UILabel alloc] init];
    logoLabel.text = NSLocalizedString(@"品牌Logo", ni);
    logoLabel.textColor = [UIColor blackColor];
    logoLabel.font = [UIFont boldSystemFontOfSize:14];
    [self addSubview:logoLabel];

    [logoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(17);
        make.top.equalTo(25);
    }];

    // logo UpFile
    SCGIFButtonView *logoButton = [[SCGIFButtonView alloc] init];
    logoButton.backgroundColor = [UIColor colorWithHex:@"EFEFEF"];
    logoButton.tag = 1;
    [logoButton setImage:[UIImage imageNamed:@"photo"] forState:UIControlStateNormal];
    [logoButton addTarget:self action:@selector(upFileButton:) forControlEvents:UIControlEventTouchUpInside];
    self.logoButton = logoButton;

    [self addSubview:logoButton];

    [logoButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(17);
        make.top.mas_equalTo(logoLabel.mas_bottom).mas_offset(15);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(100);
    }];

    // logo说明
    UILabel *help1TitleLabel = [[UILabel alloc] init];
    help1TitleLabel.font = [UIFont systemFontOfSize:13];
    help1TitleLabel.textColor = [UIColor colorWithHex:@"000000" alpha:0.6];
    help1TitleLabel.text = NSLocalizedString(@"上传LOGO",nil);
    self.help1TitleLabel = help1TitleLabel;
    [logoButton addSubview:help1TitleLabel];

    [help1TitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(40);
        make.top.mas_equalTo(logoButton.mas_centerY).offset(7.5);
        make.centerX.mas_equalTo(logoButton.mas_centerX);
    }];

    // 品牌简介
    UILabel *introduceLabel = [[UILabel alloc] init];
    introduceLabel.text = NSLocalizedString(@"品牌简介", ni);
    introduceLabel.textColor = [UIColor blackColor];
    introduceLabel.font = [UIFont boldSystemFontOfSize:14];
    [self addSubview:introduceLabel];

    [introduceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(17);
        make.top.equalTo(logoButton.mas_bottom).mas_offset(25);
    }];

    // 品牌简介
    XXTextView *introduceTextView = [[XXTextView alloc] init];
    introduceTextView.xx_placeholderFont = [UIFont systemFontOfSize:14];
    introduceTextView.font = [UIFont systemFontOfSize:14];
    introduceTextView.textColor = [UIColor colorWithHex:kDefaultTitleColor_pad];
    introduceTextView.xx_placeholderColor = [UIColor colorWithHex:@"d3d3d3"];
    introduceTextView.xx_placeholder = NSLocalizedString(@"可填写品牌故事、风格理念、进店意向等",nil);
    introduceTextView.textContainerInset = UIEdgeInsetsMake(8.0f, 6.0f, 8.0f, 6.0f);
    introduceTextView.layer.borderWidth = 1;
    introduceTextView.layer.borderColor = [UIColor colorWithHex:kDefaultBorderColor].CGColor;
    introduceTextView.layer.masksToBounds = YES;
    introduceTextView.layer.cornerRadius = 2;
    introduceTextView.delegate = self;
    self.introduceTextView = introduceTextView;

    [self addSubview:introduceTextView];

    [introduceTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(17);
        make.top.equalTo(introduceLabel.mas_bottom).offset(15);
        make.width.equalTo(614);
        make.height.equalTo(140);
    }];

    // 品牌简介字数限制提示
    UILabel *introduceNumberDescLabel = [UILabel getLabelWithAlignment:1 WithTitle:@"" WithFont:12 WithTextColor:[UIColor colorWithHex:@"919191"] WithSpacing:0];

    introduceNumberDescLabel.text = [[NSString alloc] initWithFormat:NSLocalizedString(@"还可输入 %@ 字",nil), @MY_MAX];
    self.introduceNumberDescLabel = introduceNumberDescLabel;
    [self addSubview:introduceNumberDescLabel];

    [introduceNumberDescLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(introduceTextView.mas_right);
        make.top.mas_equalTo(introduceTextView.mas_bottom).mas_offset(4);
    }];

    // 品牌海报
    UILabel *posterLabel = [[UILabel alloc] init];
    posterLabel.text = NSLocalizedString(@"品牌海报", ni);
    posterLabel.textColor = [UIColor blackColor];
    posterLabel.font = [UIFont boldSystemFontOfSize:14];
    [self addSubview:posterLabel];

    [posterLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(17);
        make.top.equalTo(introduceTextView.mas_bottom).offset(25);
    }];

    // logo UpFile 1
    SCGIFButtonView *posterIamge1 = [[SCGIFButtonView alloc] init];
    posterIamge1.tag = 2;
    posterIamge1.backgroundColor = [UIColor colorWithHex:@"EFEFEF"];
    self.posterIamge1 = posterIamge1;
    [posterIamge1 setImage:[UIImage imageNamed:@"photo"] forState:UIControlStateNormal];
    [posterIamge1 addTarget:self action:@selector(upFileButton:) forControlEvents:UIControlEventTouchUpInside];

    [self addSubview:posterIamge1];

    [posterIamge1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(17);
        make.top.mas_equalTo(posterLabel.mas_bottom).mas_offset(15);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(100);
    }];

    // 2上传海报的说明
    UILabel *posterTitle1Label = [[UILabel alloc] init];
    posterTitle1Label.font = [UIFont systemFontOfSize:11];
    posterTitle1Label.textColor = [UIColor colorWithHex:@"000000" alpha:0.6];
    posterTitle1Label.text = [[NSString alloc] initWithFormat:NSLocalizedString(@"还可以上传%d张",nil), 3];// NSLocalizedString(@"还可以上传3张",nil);
    posterTitle1Label.numberOfLines = 0;
    self.tips1Label = posterTitle1Label;
    posterTitle1Label.textAlignment = NSTextAlignmentCenter;
    [posterIamge1 addSubview:posterTitle1Label];

    [posterTitle1Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(40);
        make.width.mas_equalTo(posterIamge1.mas_width);
        make.top.mas_equalTo(posterIamge1.mas_centerY).offset(4);
        make.centerX.mas_equalTo(posterIamge1.mas_centerX);
    }];

    // 删除按钮1
    UIButton *delete1Button = [[UIButton alloc] init];
    self.delete1Button = delete1Button;
    delete1Button.hidden = YES;
    delete1Button.tag = 0;
    [delete1Button addTarget:self action:@selector(deleteImage:) forControlEvents:UIControlEventTouchUpInside];
    [delete1Button setImage:[UIImage imageNamed:@"update_delete_icon"] forState:UIControlStateNormal];

    [self addSubview:delete1Button];
    [delete1Button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(posterIamge1.mas_top);
        make.right.equalTo(posterIamge1.mas_right);
        make.width.equalTo(22);
        make.height.equalTo(22);
    }];

    // logo UpFile 2
    SCGIFButtonView *posterIamge2 = [[SCGIFButtonView alloc] init];
    self.posterIamge2 = posterIamge2;
    posterIamge2.hidden = YES;
    posterIamge2.tag = 3;
    posterIamge2.backgroundColor = [UIColor colorWithHex:@"EFEFEF"];
    [posterIamge2 setImage:[UIImage imageNamed:@"photo"] forState:UIControlStateNormal];
    [posterIamge2 addTarget:self action:@selector(upFileButton:) forControlEvents:UIControlEventTouchUpInside];

    [self addSubview:posterIamge2];

    [posterIamge2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(posterIamge1.mas_right).offset(17);
        make.top.mas_equalTo(posterLabel.mas_bottom).mas_offset(15);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(100);
    }];

    // 上传海报的说明
    UILabel *posterTitle2Label = [[UILabel alloc] init];
    posterTitle2Label.font = [UIFont systemFontOfSize:11];
    posterTitle2Label.textColor = [UIColor colorWithHex:@"000000" alpha:0.6];
    posterTitle2Label.text = [[NSString alloc] initWithFormat:NSLocalizedString(@"还可以上传%d张",nil), 2];// NSLocalizedString(@"还可以上传2张",nil);
    posterTitle2Label.numberOfLines = 0;
    self.tips2Label = posterTitle2Label;
    posterTitle2Label.textAlignment = NSTextAlignmentCenter;
    [posterIamge2 addSubview:posterTitle2Label];

    [posterTitle2Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(40);
        make.width.mas_equalTo(posterIamge2.mas_width);
        make.top.mas_equalTo(posterIamge2.mas_centerY).offset(4);
        make.centerX.mas_equalTo(posterIamge2.mas_centerX);
    }];

    // 删除按钮2
    UIButton *delete2Button = [[UIButton alloc] init];
    self.delete2Button = delete2Button;
    delete2Button.hidden = YES;
    delete2Button.tag = 1;
    [delete2Button addTarget:self action:@selector(deleteImage:) forControlEvents:UIControlEventTouchUpInside];
    [delete2Button setImage:[UIImage imageNamed:@"update_delete_icon"] forState:UIControlStateNormal];

    [self addSubview:delete2Button];
    [delete2Button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(posterIamge2.mas_top);
        make.right.equalTo(posterIamge2.mas_right);
        make.width.equalTo(22);
        make.height.equalTo(22);
    }];

    // logo UpFile 3
    SCGIFButtonView *posterIamge3 = [[SCGIFButtonView alloc] init];
    self.posterIamge3 = posterIamge3;
    posterIamge3.tag = 4;
    posterIamge3.hidden = YES;
    posterIamge3.backgroundColor = [UIColor colorWithHex:@"EFEFEF"];
    [posterIamge3 setImage:[UIImage imageNamed:@"photo"] forState:UIControlStateNormal];
    [posterIamge3 addTarget:self action:@selector(upFileButton:) forControlEvents:UIControlEventTouchUpInside];

    [self addSubview:posterIamge3];

    [posterIamge3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(posterIamge2.mas_right).offset(17);
        make.top.mas_equalTo(posterLabel.mas_bottom).mas_offset(15);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(100);
    }];

    // 上传海报的说明
    UILabel *posterTitle3Label = [[UILabel alloc] init];
    posterTitle3Label.font = [UIFont systemFontOfSize:11];
    posterTitle3Label.textColor = [UIColor colorWithHex:@"000000" alpha:0.6];
    posterTitle3Label.text = [[NSString alloc] initWithFormat:NSLocalizedString(@"还可以上传%d张",nil), 1];// NSLocalizedString(@"还可以上传1张",nil);
    posterTitle3Label.numberOfLines = 0;
    self.tips3Label = posterTitle3Label;
    posterTitle3Label.textAlignment = NSTextAlignmentCenter;
    [posterIamge3 addSubview:posterTitle3Label];

    [posterTitle3Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(40);
        make.width.mas_equalTo(posterIamge3.mas_width);
        make.top.mas_equalTo(posterIamge3.mas_centerY).offset(4);
        make.centerX.mas_equalTo(posterIamge3.mas_centerX);
    }];

    // 删除按钮3
    UIButton *delete3Button = [[UIButton alloc] init];
    self.delete3Button = delete3Button;
    delete3Button.hidden = YES;
    delete3Button.tag = 2;
    [delete3Button addTarget:self action:@selector(deleteImage:) forControlEvents:UIControlEventTouchUpInside];
    [delete3Button setImage:[UIImage imageNamed:@"update_delete_icon"] forState:UIControlStateNormal];

    [self addSubview:delete3Button];
    [delete3Button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(posterIamge3.mas_top);
        make.right.equalTo(posterIamge3.mas_right);
        make.width.equalTo(22);
        make.height.equalTo(22);
    }];
}

#pragma mark - --------------系统代理----------------------
#pragma mark - uitextview
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{

    NSInteger number = MY_MAX - (textView.text.length - range.length + text.length);
    self.introduceNumberDescLabel.text = [[NSString alloc] initWithFormat:NSLocalizedString(@"还可输入 %@ 字",nil), [NSNumber numberWithInteger:number]];


    if ((textView.text.length - range.length + text.length) > MY_MAX)
    {
        NSString *substring = [text substringToIndex:MY_MAX - (textView.text.length - range.length)];
        NSMutableString *lastString = [textView.text mutableCopy];
        [lastString replaceCharactersInRange:range withString:substring];
        textView.text = [lastString copy];
        self.introduceNumberDescLabel.text = NSLocalizedString(@"还可输入 0 字",nil);
        return NO;

    }else{
        return YES;
    }
}

- (void)textViewDidChange:(UITextView *)textView{
    if (self.transmitIntroduce) {
        self.transmitIntroduce(self.introduceTextView.text);
    }
}

#pragma mark - --------------自定义代理/block----------------------
#pragma mark - 照片回调
- (void)YYPhotoInfo:(NSDictionary *)info{

    UIImage *image = nil;

    if (info[@"UIImagePickerControllerEditedImage"]) {
        image = [UIImage fixOrientation:info[UIImagePickerControllerEditedImage]];
    }else{
        image = [UIImage fixOrientation:info[UIImagePickerControllerOriginalImage]];
    }

    if (image) {
        if (![YYNetworkReachability connectedToNetwork]) {
            [YYToast showToastWithTitle:kNetworkIsOfflineTips andDuration:kAlertToastDuration];//判断网络状态

        }else{
            UIViewController *controller = [self getController:self];
            [MBProgressHUD showHUDAddedTo:controller.view animated:YES];
            [YYOrderApi uploadImage:image size:2.0f andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSString *imageUrl, NSError *error) {
                [MBProgressHUD hideAllHUDsForView:controller.view animated:YES];
                if (imageUrl && [imageUrl length] > 0) {

                    switch (self.buttonTag) {
                        case 1:// logo
                        {
                            self.logoUrl = imageUrl;
                            if (self.transmitLogo) {
                                self.transmitLogo(imageUrl);
                            }
                        }
                            break;
                        case 2:// 第一张海报
                        {
                            [self.allPics addObject:imageUrl];
                            // 利用重写的set方法
                            self.indexPics = self.allPics;
                        }
                            break;
                        case 3:// 第二张海报
                        {
                            [self.allPics addObject:imageUrl];
                            self.indexPics = self.allPics;
                        }
                            break;
                        case 4:// 第三张海报
                        {
                            [self.allPics addObject:imageUrl];
                            self.indexPics = self.allPics;
                        }
                            break;

                        default:
                            break;
                    }
                }
            }];
        }
    }
}

#pragma mark - --------------自定义响应----------------------
#pragma mark - 上传文件
- (void)upFileButton:(UIButton *)button{
    self.buttonTag = button.tag;
    CMAlertView *alertView = [[CMAlertView alloc] initWithTitle:NSLocalizedString(@"请选择",nil) message:nil needwarn:NO delegate:nil cancelButtonTitle:NSLocalizedString(@"相册",nil) otherButtonTitles:@[[NSString stringWithFormat:@"%@|000000",NSLocalizedString(@"拍照",nil)]]];
    UIViewController *controller = [self getController:self];
    alertView.specialParentView = controller.view;
    WeakSelf(weakSelf);

    [alertView setAlertViewBlock:^(NSInteger selectedIndex){
        StrongSelf(weakSelf);
        YYPhotoSelectView *photoSelect = [YYPhotoSelectView sharePhotoSelect];
        photoSelect.YYPhotoImageDelegate = strongSelf;
        if (selectedIndex == 0) {
            // 相册
            [photoSelect showPhotoWithController:controller PhotoType:kYYPhotoTypeAlbum view:button arrow:UIPopoverArrowDirectionLeft];
        }else if (selectedIndex == 1){
            // 相机
            [photoSelect showPhotoWithController:controller PhotoType:kYYPhotoTypeCamera view:button arrow:UIPopoverArrowDirectionLeft];
        }
    }];

    [alertView show];
}

#pragma mark - 删除图片
- (void)deleteImage:(UIButton *)button{

    [self.allPics removeObjectAtIndex:button.tag];
    self.indexPics = self.allPics;
}


#pragma mark - --------------自定义方法----------------------
#pragma mark - 可以获取到父容器的控制器的方法,就是这个黑科技.
- (UIViewController *)getController:(UIView *)view{
    UIResponder *responder = view;
    //循环获取下一个响应者,直到响应者是一个UIViewController类的一个对象为止,然后返回该对象.
    while ((responder = [responder nextResponder])) {
        if ([responder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)responder;
        }
    }
    return [UIApplication sharedApplication].keyWindow.rootViewController;
}

#pragma mark - get/set
- (void)setLogoUrl:(NSString *)logoUrl{
    _logoUrl = logoUrl;
    if (self.transmitLogo) {
        self.transmitLogo(logoUrl);
    }

    self.help1TitleLabel.hidden = YES;

    UIImageView *maskImageView = [[UIImageView alloc] init];
    [self.logoButton addSubview:maskImageView];
    maskImageView.image = [UIImage imageNamed:@"System_Transparent_Mask"];
    [maskImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.logoButton);
    }];

    UILabel *maskLabel=[[UILabel alloc] init];
    maskLabel.text=NSLocalizedString(@"点击修改",nil);
    maskLabel.textColor=[UIColor whiteColor];
    maskLabel.textAlignment=1;
    maskLabel.font=[UIFont systemFontOfSize:14.0f];
    maskLabel.hidden=NO;
    [maskImageView addSubview:maskLabel];
    [maskLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(maskImageView);
    }];

    if(![NSString isNilOrEmpty:logoUrl])
    {
        sd_downloadWebImageWithRelativePath(YES, logoUrl, self.logoButton, kLookBookImage, UIViewContentModeScaleAspectFit);
    }else{
        [self.logoButton setImage:[UIImage imageNamed:@"default_icon"] forState:UIControlStateNormal];
        maskImageView.hidden = YES;
    }
}

- (void)setBrandIntroduction:(NSString *)brandIntroduction{
    _brandIntroduction = brandIntroduction;
    self.introduceTextView.text = brandIntroduction;

    NSInteger number = MY_MAX - brandIntroduction.length;
    self.introduceNumberDescLabel.text = [[NSString alloc] initWithFormat:NSLocalizedString(@"还可输入 %@ 字",nil), [NSNumber numberWithInteger:number]];
    // 默认值
    if (self.transmitIntroduce) {
        self.transmitIntroduce(self.introduceTextView.text);
    }
}

// 设置品牌海报
- (void)setIndexPics:(NSArray *)indexPics{
    _indexPics = indexPics;
    self.allPics = [NSMutableArray arrayWithArray:indexPics];

    // 将改变后的结果传递出去
    if (self.transmitPics) {
        self.transmitPics(indexPics);
    }

    // 初始化三张图
    // 只显示第一张
    self.posterIamge1.hidden = NO;
    self.posterIamge2.hidden = YES;
    self.posterIamge3.hidden = YES;

    // 不显示删除按钮
    self.delete1Button.hidden = YES;
    self.delete2Button.hidden = YES;
    self.delete3Button.hidden = YES;

    // 只显示第一张图的文案
    self.tips1Label.hidden = NO;
    self.tips2Label.hidden = YES;
    self.tips3Label.hidden = YES;

    // 设置图片显示的方式
    self.posterIamge1.imageView.contentMode = UIViewContentModeCenter;
    self.posterIamge2.imageView.contentMode = UIViewContentModeCenter;
    self.posterIamge3.imageView.contentMode = UIViewContentModeCenter;

    self.posterIamge1.userInteractionEnabled = YES;
    self.posterIamge2.userInteractionEnabled = YES;
    self.posterIamge3.userInteractionEnabled = YES;

    [self.posterIamge1 setImage:[UIImage imageNamed:@"photo"] forState:UIControlStateNormal];

    for (int x = 0; x<indexPics.count; x++) {

        UIButton *button;
        if (x == 0) {
            button = self.posterIamge1;
            // 显示第二张图
            self.posterIamge1.hidden = NO;
            self.posterIamge2.hidden = NO;
            self.posterIamge3.hidden = YES;

            // 显示第一张图的删除按钮
            self.delete1Button.hidden = NO;
            self.delete2Button.hidden = YES;
            self.delete3Button.hidden = YES;

            // 隐藏第一张图的文案
            self.tips1Label.hidden = YES;
            self.tips2Label.hidden = NO;
            self.tips3Label.hidden = NO;

            self.posterIamge1.userInteractionEnabled = NO;
            self.posterIamge2.userInteractionEnabled = YES;
            self.posterIamge3.userInteractionEnabled = YES;

            [self.posterIamge2 setImage:[UIImage imageNamed:@"photo"] forState:UIControlStateNormal];
        }else if (x == 1){
            button = self.posterIamge2;
            // 显示第三章图
            self.posterIamge1.hidden = NO;
            self.posterIamge2.hidden = NO;
            self.posterIamge3.hidden = NO;

            // 显示第二张图的删除按钮
            self.delete1Button.hidden = NO;
            self.delete2Button.hidden = NO;
            self.delete3Button.hidden = YES;

            // 隐藏第二张图的文案
            self.tips1Label.hidden = YES;
            self.tips2Label.hidden = YES;
            self.tips3Label.hidden = NO;

            self.posterIamge1.userInteractionEnabled = NO;
            self.posterIamge2.userInteractionEnabled = NO;
            self.posterIamge3.userInteractionEnabled = YES;

            [self.posterIamge3 setImage:[UIImage imageNamed:@"photo"] forState:UIControlStateNormal];

        }else if (x == 2){
            button = self.posterIamge3;
            // 显示三张图
            self.posterIamge1.hidden = NO;
            self.posterIamge2.hidden = NO;
            self.posterIamge3.hidden = NO;

            // 显示三张图的删除按钮
            self.delete1Button.hidden = NO;
            self.delete2Button.hidden = NO;
            self.delete3Button.hidden = NO;

            // 隐藏三张图的文案
            self.tips1Label.hidden = YES;
            self.tips2Label.hidden = YES;
            self.tips3Label.hidden = YES;
            self.posterIamge1.userInteractionEnabled = NO;
            self.posterIamge2.userInteractionEnabled = NO;
            self.posterIamge3.userInteractionEnabled = NO;

        }

        sd_downloadWebImageWithRelativePath(YES, indexPics[x], button, kLookBookImage, UIViewContentModeScaleAspectFit);
    }
    
}

#pragma mark - --------------other----------------------
#pragma mark - 懒加载



@end

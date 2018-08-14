//
//  JRPhoneDelegate.m
//  parking
//
//  Created by chjsun on 2016/12/22.
//  Copyright © 2016年 chjsun. All rights reserved.
//

#import "YYPhotoSelectView.h"

#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>


static YYPhotoSelectView *photoSelect;

@interface YYPhotoSelectView()<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIAlertViewDelegate>

@property(nonatomic, assign) UIViewController *pushController;

@end

@implementation YYPhotoSelectView

- (void)showPhotoWithController:(UIViewController *)controller PhotoType:(photoType)photoType view:(UIView *)view arrow:(UIPopoverArrowDirection)arrow{
    self.pushController = controller;
    switch (photoType) {
        case kYYPhotoTypeCamera:
        {
            [self imagePickerControllerSourceTypeCamera];
        }
            break;

        default:
        {
            [self imagePickerControllerSourceTypePhotoLibraryWithView:view popoverArrow:arrow];
        }
            break;
    }
}

// 拍照
- (void)imagePickerControllerSourceTypeCamera{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;

    picker.allowsEditing = NO;

    //拍摄照片
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];

    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"提示", nil) message:NSLocalizedString(@"请在设备的“设置-隐私-相机”中允许访问相机", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"确定", nil) otherButtonTitles:nil] show];
        return;
    }else{
        [self.pushController presentViewController:picker animated:YES completion:nil];
    }
}

// 相册选取
- (void)imagePickerControllerSourceTypePhotoLibraryWithView:(UIView *)view popoverArrow:(UIPopoverArrowDirection)popoverArrow{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;

    picker.allowsEditing = YES;

    picker.videoQuality = UIImagePickerControllerQualityTypeLow;
    picker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;


    //从相册选取
    picker.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
    ALAuthorizationStatus authStatus = [ALAssetsLibrary authorizationStatus];
    if(authStatus == ALAuthorizationStatusRestricted || authStatus == ALAuthorizationStatusDenied){
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"提示", nil) message:NSLocalizedString(@"请在设备的“设置-隐私-照片”中允许访问照片", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"确定", nil) otherButtonTitles:nil] show];

        return;
    }else{
        picker.view.backgroundColor = [UIColor whiteColor];

        UIViewController *parent = [UIApplication sharedApplication].keyWindow.rootViewController;
        CGPoint point = [view convertPoint:CGPointMake(CGRectGetWidth(view.frame), CGRectGetHeight(view.frame)/2) toView:parent.view];

        UIPopoverController *popController = [[UIPopoverController alloc] initWithContentViewController:picker];
        popController.popoverContentSize = CGSizeMake(450, 400);
        CGRect rc = CGRectMake(point.x, point.y, 0, 0);

        [popController presentPopoverFromRect:rc inView:self.pushController.view permittedArrowDirections:popoverArrow animated:YES];
    }
}

#pragma mark - 当选择一张图片后进入这里
-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    //关闭相册界面
    WeakSelf(ws);
    [picker dismissViewControllerAnimated:YES completion:^{
        StrongSelf(ws);
        if ([[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:@"public.image"]) {//当选择的类型是图片
            if ([strongSelf.YYPhotoImageDelegate respondsToSelector:@selector(YYPhotoInfo:)]) {
                [strongSelf.YYPhotoImageDelegate YYPhotoInfo:info];
            }
        }
    }];
}

#pragma mark - alertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{

    // 跳转到设置, ios8
    NSURL *SettingURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if([[UIApplication sharedApplication] canOpenURL:SettingURL]) {
        [[UIApplication sharedApplication] openURL:SettingURL];
    }
}

#pragma mark - 单例设计模式
+ (id)sharePhotoSelect{

    if (photoSelect == nil){
        @synchronized(self){
            if (photoSelect == nil){
                photoSelect = [[self alloc] init];
            }
        }
    }
    return photoSelect;
}
//重写alloc方法，保证在使用alloc、new 去创建对象时，不产生新的对象
+ (id)allocWithZone:(NSZone *)zone{
    if (photoSelect == nil) {
        photoSelect = [[super allocWithZone:zone] init];
    }
    return photoSelect;
}

//重写copy方法，避免复制时，产生新对象
- (id)copyWithZone:(NSZone *)zone{
    return photoSelect;
}

//重写mutablecopy方法，避免深拷贝
- (id)mutableCopyWithZone:(NSZone *)zone{
    return photoSelect;
}

@end

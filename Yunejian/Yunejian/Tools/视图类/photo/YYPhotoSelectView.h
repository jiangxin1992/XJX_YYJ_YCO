//
//  JRPhoneDelegate.h
//  parking
//
//  Created by chjsun on 2016/12/22.
//  Copyright © 2016年 chjsun. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, photoType) {
    /** 相机 */
    kYYPhotoTypeCamera = 1,
    /** 相册 */
    kYYPhotoTypeAlbum = 1 << 1,
};

@class YYPhotoDelegate;
@protocol YYPhotoImageDelegate <NSObject>

@optional

/**
 回调

 @param info 返回的照片信息
 */
- (void)YYPhotoInfo:(NSDictionary *)info;

@end

@interface YYPhotoSelectView : NSObject<UIActionSheetDelegate>

/** 创建对象 */
+ (id)sharePhotoSelect;

/** 代理 */
@property(nonatomic, assign) id<YYPhotoImageDelegate> YYPhotoImageDelegate;

/**
 显示相机或者相册

 @param controller 相机在什么控制器上弹出，一般self
 @param photoType 选择相机还是相册
 @param view 相册的参照view
 @param arrow 相册的箭头方向
 */
- (void)showPhotoWithController:(UIViewController *)controller PhotoType:(photoType)photoType view:(UIView *)view arrow:(UIPopoverArrowDirection)arrow;

@end

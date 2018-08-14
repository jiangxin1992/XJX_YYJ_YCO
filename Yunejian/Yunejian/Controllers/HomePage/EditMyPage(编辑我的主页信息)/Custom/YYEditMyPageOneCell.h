//
//  YYEditMyPageOneCellView.h
//  Yunejian
//
//  Created by chuanjun sun on 2017/8/18.
//  Copyright © 2017年 yyj. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^changeLogo)(NSString *logo);
typedef void (^changeIntroduce)(NSString *introduce);
typedef void (^changePics)(NSArray *pics);

@interface YYEditMyPageOneCell : UITableViewCell
/** 品牌logo的地址 */
@property (nonatomic, copy) NSString *logoUrl;
/** 品牌简介 */
@property (nonatomic, copy) NSString *brandIntroduction;
/** 品牌海报 */
@property (nonatomic, copy) NSArray *indexPics;

/** 返回品牌logo的地址 */
@property (nonatomic, copy) changeLogo transmitLogo;
/** 返回品牌简介 */
@property (nonatomic, copy) changeIntroduce transmitIntroduce;
/** 返回品牌简介 */
@property (nonatomic, copy) changePics transmitPics;

@end

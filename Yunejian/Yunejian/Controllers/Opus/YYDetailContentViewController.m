//
//  YYDetailContentViewController.m
//  Yunejian
//
//  Created by yyj on 15/7/26.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import "YYDetailContentViewController.h"

#import "YYOpusApi.h"
#import "StyleDetail.h"
#import "UIView+UpdateAutoLayoutConstraints.h"
#import "NSManagedObject+helper.h"
#import "StyleDetailColors.h"
#import "StyleDeatilSizes.h"
#import "StyleDetailColorImages.h"
#import "YYSizeModel.h"
#import "UIImage+YYImage.h"

#import "AppDelegate.h"
#import "YYStyleDetailViewController.h"
#import "YYTopAlertView.h"
#import "SCLoopScrollView.h"
#import "StyleDateRange.h"
#import "SCGIFButtonView.h"
#import "YYShoppingView.h"
@interface YYDetailContentViewController ()<UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet SCLoopScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIScrollView *ContentScrollView;
@property (weak, nonatomic) IBOutlet UIView *contentVIew;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewHeightLayoutConstraint;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet UIView *colorBgView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *colorBgViewHeightConstraint;

@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *styleCodeLabel;
@property (weak, nonatomic) IBOutlet UILabel *styleCodeLabel1;
@property (weak, nonatomic) IBOutlet UILabel *materialsLabel;
@property (weak, nonatomic) IBOutlet UILabel *sizeDetailLabel;
@property (weak, nonatomic) IBOutlet UILabel *tradePriceDetailLabel;
@property (weak, nonatomic) IBOutlet UILabel *retailPriceDetailLabel;
@property (nonatomic, weak) IBOutlet UILabel *dateTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateRangeLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sizeDetailLabelHeightLayoutConstraint;
@property (weak, nonatomic) IBOutlet UIButton *addShoppingCarButton;

@property (weak, nonatomic) IBOutlet UILabel *descriptionTextView;

@property (weak, nonatomic) IBOutlet UIView *loadingView;

@property (weak, nonatomic) IBOutlet UILabel *noDataView;

@property (nonatomic,strong) YYStyleInfoModel *styleInfoModel;

@property (nonatomic,strong) StyleDetail *styleDetail;

@property(nonatomic,assign) NSInteger currentColorIndexToShow;
@property (nonatomic,strong) UIButton *lastSelectedButton;

@property (nonatomic,strong) UIPageControl *pageControl;

@property (nonatomic,strong)NSMutableArray *colorsArry;

@property (nonatomic,assign) NSComparisonResult orderDueCompareResult;

@property (nonatomic,strong) YYShoppingView *shoppingView;
@end

@implementation YYDetailContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (_currentOpusStyleModel) {
        self.nameLabel.text = _currentOpusStyleModel.name;
    }
    self.noDataView.hidden = YES;
    self.pageControl = [[UIPageControl alloc] init];
    
    self.loadingView.hidden = YES;
    
    _currentColorIndexToShow = 0;
    
    switch (_currentDataReadType) {
        case EDataReadTypeOffline:{
            [self loadOfflineStyleDetail];
        }
            break;
        case EDataReadTypeOnline:{
            [self loadStyleInfo];
        }
            break;
        case EDataReadTypeCached:{
            [self fetchEntitys];
        }
            break;
            
        default:
            break;
    }

    self.automaticallyAdjustsScrollViewInsets = NO;
    
    __weak SCLoopScrollView *weakScrollView = _scrollView;
    __weak UIView *weakView = self.view;
    
    _pageControl.hidesForSinglePage = YES;
    _pageControl.pageIndicatorTintColor = [UIColor grayColor];
    _pageControl.currentPageIndicatorTintColor = [UIColor blackColor];
    
    [weakView addSubview:_pageControl];
    [_pageControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(weakScrollView.mas_bottom).with.offset(-15);
        make.size.mas_equalTo(CGSizeMake(300, 20));
        make.centerX.equalTo(weakScrollView.mas_centerX);
    }];
}

-(void)laodData{
    switch (_currentDataReadType) {
        case EDataReadTypeOffline:{
            [self loadOfflineStyleDetail];
        }
            break;
        case EDataReadTypeOnline:{
            [self loadStyleInfo];
        }
            break;
        case EDataReadTypeCached:{
            [self fetchEntitys];
        }
            break;
            
        default:
            break;
    }
}

- (void)updateScrollViewContentView{
    NSArray *imageArray = nil;
    switch (_currentDataReadType) {
        case EDataReadTypeOffline:
        case EDataReadTypeOnline:{
            imageArray = _styleInfoModel.colorImages;
        }
            break;
        case EDataReadTypeCached:{
            imageArray = [_styleDetail.colors allObjects];
        }
            break;
            
        default:
            break;
    }
    
    _pageControl.hidden = YES;
    
    if (imageArray && _currentColorIndexToShow < [imageArray count]) {
       
        NSArray *detailImageArray = nil;
        
        NSObject *obj = [imageArray objectAtIndex:_currentColorIndexToShow];
        if ([obj isKindOfClass:[YYColorModel class]]) {
            YYColorModel  *colorModel = (YYColorModel  *)obj;
            detailImageArray = colorModel.imgs;
        }else if ([obj isKindOfClass:[StyleDetailColors class]]){
            StyleDetailColors *styleDetailColors = (StyleDetailColors *)obj;
            detailImageArray = [styleDetailColors.images allObjects];
        }
        
        if (!detailImageArray ||
            [detailImageArray count] == 0) {
            NSString *albumImg = nil;
            if(_currentOpusStyleModel
               && _currentOpusStyleModel.albumImg){
                albumImg = _currentOpusStyleModel.albumImg;
            }
            
            if(!albumImg
               && _currentStyleSummary
               && _currentStyleSummary.album_img){
                albumImg = _currentStyleSummary.album_img;
            }
            
            if(albumImg){
               NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:0];
                [tempArray addObject:albumImg];
                detailImageArray = [NSArray arrayWithArray:tempArray];
            }
        }
        
        
        if (detailImageArray
            && [detailImageArray count] > 0) {
            
            NSInteger count = [detailImageArray count];
            NSMutableArray * tempImageArray = [[NSMutableArray alloc]initWithCapacity:count];
            _pageControl.numberOfPages = count;
            _pageControl.currentPage = 0;
            _pageControl.hidden = NO;
            for ( int i = 0 ; i < count ; ++i )
            {
                NSString *imageRelativePath = nil;
                NSObject *tempObj = [detailImageArray objectAtIndex:i];
                if ([tempObj isKindOfClass:[NSString class]]) {
                    imageRelativePath = (NSString *)tempObj;
                }else if ([tempObj isKindOfClass:[StyleDetailColorImages class]]){
                    StyleDetailColorImages *styleDetailColorImages = (StyleDetailColorImages *)tempObj;
                    imageRelativePath = styleDetailColorImages.image_path;
                }

                long seriesId = 0;
                if (self.opusSeriesModel) {
                    seriesId = [self.opusSeriesModel.id longValue];
                }else if (self.series){
                    seriesId = [self.series.series_id longValue];
                }

                NSString *imageInfo = [NSString stringWithFormat:@"%@%@|%@",imageRelativePath,kStyleDetailCover,@""];
                [tempImageArray addObject:imageInfo];
            }
            WeakSelf(ws);
            _scrollView.images = tempImageArray;
            [_scrollView show:^(NSInteger index) {
            } finished:^(NSInteger index) {
                ws.pageControl.currentPage = index;
            }];
        }else{
            UIImage *defaultImage = [UIImage imageWithColor:[UIColor colorWithHex:kDefaultImageColor] size:CGSizeMake(600, 600)];
            _scrollView.images = @[defaultImage];
        }
    }
}


- (void)loadOfflineStyleDetail{
    //读取本地的离线数据
    NSString *folderName = [NSString stringWithFormat:@"%li",[_opusSeriesModel.id longValue]];
    NSString *offlineFilePath = [yyjOfflineSeriesDirectory() stringByAppendingPathComponent:folderName];
   
    NSString *styleDetailJsonName = [NSString stringWithFormat:@"%i.json",[_currentOpusStyleModel.id intValue]];
    
    NSString *jsonPath = [offlineFilePath stringByAppendingPathComponent:styleDetailJsonName];
    

    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:jsonPath]) {
        NSData *data = [NSData dataWithContentsOfFile:jsonPath];
        
        if (data) {
            
            NSError* error;
            NSDictionary* json = [NSJSONSerialization
                                  JSONObjectWithData:data
                                  options:NSJSONReadingAllowFragments
                                  error:&error];
            if (json) {
                YYStyleInfoModel *styleInfoModel = [[YYStyleInfoModel alloc] initWithDictionary:json error:nil];
                styleInfoModel.style.styleDescription = [json valueForKeyPath:@"style.description"];
                if (styleInfoModel) {
                    self.styleInfoModel = styleInfoModel;
                    [self updateUIAtColorIndex:0];
                }
            }
            
        }
        
    }

}

-(void)fetchEntitys{

    
    NSString *predicate = [NSString stringWithFormat:@"style_id=%i",[_currentStyleSummary.style_id intValue]];
    StyleDetail *styleDetail = [StyleDetail one:predicate];
    if (styleDetail) {
        self.styleDetail = styleDetail;
        [self updateUIAtColorIndex:0];
        self.noDataView.hidden = YES;
    }else{
        self.noDataView.hidden = NO;
    }
    
}


- (void)loadStyleInfo{
    WeakSelf(ws);
    self.loadingView.hidden = NO;
   [YYOpusApi getStyleInfoByStyleId:[_currentOpusStyleModel.id longValue]orderCode:nil andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYStyleInfoModel *styleInfoModel, NSError *error) {
       if (rspStatusAndMessage.status == YYReqStatusCode100) {
           ws.styleInfoModel = styleInfoModel;
           [ws updateUIAtColorIndex:0];
           [ws insertObjectToDb:styleInfoModel];
            ws.noDataView.hidden = YES;
       }else{
          ws.noDataView.hidden = NO;
       }
       ws.loadingView.hidden = YES;
      
   }];
}

- (void)insertObjectToDb:(YYStyleInfoModel *)styleInfoModel{
    NSString *predicate = [NSString stringWithFormat:@"style_id=%i",[styleInfoModel.style.id intValue]];
    StyleDetail *style = [StyleDetail one:predicate];
    
    if (!style) {
        style = [StyleDetail createNew];
        style.style_id = styleInfoModel.style.id;
        style.designerId = styleInfoModel.style.designerId;
    }
    
    if (styleInfoModel && styleInfoModel.style) {
    
        style.name = styleInfoModel.style.name;
        style.albumImg = styleInfoModel.style.albumImg;
        style.styleCode = styleInfoModel.style.styleCode;
        style.materials = styleInfoModel.style.materials;
        style.category = styleInfoModel.style.category;
        style.style_description = styleInfoModel.style.styleDescription;
        style.orderAmountMin = styleInfoModel.style.orderAmountMin;
        style.region = styleInfoModel.style.region;
        style.modifyTime = styleInfoModel.style.modifyTime;
        
        style.tradePrice = styleInfoModel.style.tradePrice;
        style.retailPrice = styleInfoModel.style.retailPrice;
        style.cur_type = styleInfoModel.style.curType;
        style.daterange_id = styleInfoModel.style.dateRangeId;
        if(styleInfoModel.dateRange){
            style.date_range = transferToStyleDateRange(styleInfoModel.dateRange);
        }
        style.series_id = styleInfoModel.style.seriesId;
        style.series_status= styleInfoModel.style.seriesStatus;
        style.note = styleInfoModel.style.note;
        style.stockEnabled = styleInfoModel.stockEnabled;
        //color
        NSArray *colorArray = styleInfoModel.colorImages;
        if (colorArray && [colorArray count] > 0) {
            NSMutableArray *tempColorArray = [[NSMutableArray alloc] initWithCapacity:0];
            for (YYColorModel *colorModel in colorArray) {
                NSString *color_predicate = [NSString stringWithFormat:@"color_id=%i and style_id=%i",[colorModel.id intValue],[styleInfoModel.style.id intValue]];
                
                StyleDetailColors *styleColor = [StyleDetailColors one:color_predicate];
                
                if (!styleColor) {
                    styleColor = [StyleDetailColors createNew];
                    styleColor.color_id = colorModel.id;
                }
                styleColor.style_id = styleInfoModel.style.id;
                styleColor.color_name = colorModel.name;
                styleColor.color_value = colorModel.value;
                styleColor.style_code = colorModel.styleCode;
                styleColor.materials = colorModel.materials;
                styleColor.trade_price = colorModel.tradePrice;
                styleColor.retail_price = colorModel.retailPrice;
                styleColor.stock = colorModel.stock;
                styleColor.size_stocks = colorModel.sizeStocks;
                
                NSArray *images = colorModel.imgs;
                if (images && [images count] > 0) {
                    NSMutableArray *tempImageArray = [[NSMutableArray alloc] initWithCapacity:0];
                    for (NSString *imagePath in images) {
                        NSString *image_predicate = [NSString stringWithFormat:@"image_path='%@' and style_id=%i",imagePath,[styleInfoModel.style.id intValue]];
                        
                        StyleDetailColorImages *styleDetailColorImages = [StyleDetailColorImages one:image_predicate];
                        if (!styleDetailColorImages) {
                            styleDetailColorImages = [StyleDetailColorImages createNew];
                            styleDetailColorImages.style_id = styleInfoModel.style.id;
                        }
                        styleDetailColorImages.image_path = imagePath;
                        [tempImageArray addObject:styleDetailColorImages];
                    }
                    styleColor.images = [[NSSet alloc] initWithArray:tempImageArray];
                }
                [tempColorArray addObject:styleColor];
            }
            style.colors = [[NSSet alloc] initWithArray:tempColorArray];
        }
        
        //size
        NSArray *sizeArray = styleInfoModel.size;
        if (sizeArray && [sizeArray count] > 0) {
            NSMutableArray *tempSizeArray = [[NSMutableArray alloc] initWithCapacity:0];
            for (YYSizeModel *sizeModel in sizeArray) {
                NSString *size_predicate = [NSString stringWithFormat:@"size_id=%i and style_id=%i",[sizeModel.id intValue],[styleInfoModel.style.id intValue]];
                
                StyleDeatilSizes *styleDeatilSizes = [StyleDeatilSizes one:size_predicate];
                if (!styleDeatilSizes) {
                    styleDeatilSizes = [StyleDeatilSizes createNew];
                    styleDeatilSizes.size_id = sizeModel.id;
                }
                    styleDeatilSizes.style_id = styleInfoModel.style.id;
                    styleDeatilSizes.size_value = sizeModel.value;
                    [tempSizeArray addObject:styleDeatilSizes];
                }
            style.sizes = [[NSSet alloc] initWithArray:tempSizeArray];
        }
        
        [StyleDetail save:^(NSError *error) {
            NSLog(@"保存成功........");
        }];
    }
    
}

- (void)changeImageByChangColorButton:(id)sender{
    UIButton *button = (UIButton *)sender;
    if (button.tag != _currentColorIndexToShow) {
        if (_lastSelectedButton) {
            _lastSelectedButton.layer.borderWidth = 1;
        }
        _currentColorIndexToShow = button.tag;
        [self updateScrollViewContentView];
        button.layer.borderWidth = 2;
        self.lastSelectedButton = button;
    }
}

-(void)handleSingleTap:(UITapGestureRecognizer *)sender

{
    for (UIButton *btn in _colorsArry) {
        CGPoint point = [sender locationInView:btn];
        if([btn pointInside:point withEvent:nil]){
            [self changeImageByChangColorButton:btn];
            [self updateUIAtColorIndex:btn.tag];
            return;
        }
    }
}


- (void)addColorButton:(UIView *)colorBgView colors:(NSArray *)colorArray{
    
    WeakSelf(ws);
    int arrayCount = (int)[colorArray count];
    int perLines = 5;
    NSInteger lines = 1;//arrayCount%perLines == 0 ? arrayCount/perLines:arrayCount/perLines+1;
    if(arrayCount < perLines){
        lines = 1;
    }else{
        lines = 2;
        perLines = ((arrayCount+1)/2);
    }
    
    int item_with = 44;
    int item_height = 44;
    int margin = 10;
    int marginV = 13;

    UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [self.view addGestureRecognizer:singleTap];
    float viewHeight = item_height*lines + (lines-1)*marginV;
    
    self.colorBgViewHeightConstraint.constant = viewHeight;
    [UIView animateWithDuration:0.3 animations:^{
        [colorBgView layoutIfNeeded];
    }];
    _colorsArry = [[NSMutableArray alloc] initWithCapacity:arrayCount];
    for (int line = 0; line < lines; line++) {

        UIView *lastView = nil;
        for (int i = line*perLines; i < (line+1)*perLines; i++) {
            if (i >= arrayCount) {
                break;
            }
            
            NSString *colorValue = nil;
            
            NSObject *obj = [colorArray objectAtIndex:i];
            if ([obj isKindOfClass:[YYColorModel class]]) {
                YYColorModel  *colorModel = (YYColorModel  *)obj;
                colorValue = colorModel.value;
            }else if ([obj isKindOfClass:[StyleDetailColors class]]){
                StyleDetailColors *styleDetailColors = (StyleDetailColors *)obj;
                colorValue = styleDetailColors.color_value;
            }
            
            if (colorValue) {
                if ([colorValue hasPrefix:@"#"] && [colorValue length] == 7) {
                    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                    button.layer.borderWidth = 1;
                    button.layer.borderColor = kBorderColor.CGColor;
                    //[button addTarget:self action:@selector(changeImageByChangColorButton:) forControlEvents:UIControlEventTouchUpInside];
                    [button setUserInteractionEnabled:NO];
                    button.tag = i;
                    [colorBgView addSubview:button];
                    [_colorsArry addObject:button];
                    if (i == _currentColorIndexToShow) {
                        button.layer.borderWidth = 2;
                        ws.lastSelectedButton = button;
                        [ws updateScrollViewContentView];
                    }
                    
                    //16进制的色值
                    UIColor *color = [UIColor colorWithHex:[colorValue substringFromIndex:1]];
                    [button setBackgroundImage:[UIColor createImageWithColor:color] forState:UIControlStateNormal];
       
                    __weak UIView *weakContainer = colorBgView;

                    
                    [button mas_makeConstraints:^(MASConstraintMaker *make) {
                        //make.top.and.bottom.equalTo(weakContainer);
                        make.width.mas_equalTo(item_with);
                        make.height.mas_equalTo(item_height);

                        if ( lastView )
                        {
                            make.left.mas_equalTo(lastView.mas_right).with.offset(margin);
                        }
                        else
                        {
                            make.left.mas_equalTo(weakContainer.mas_left);
                        }
                        make.top.equalTo(weakContainer.mas_top).with.offset(line*(item_height+marginV));
                        
                    }];
                    lastView = button;
                }else{
                    //图片
                    
                    SCGIFButtonView *button = [SCGIFButtonView buttonWithType:UIButtonTypeCustom];
                    button.layer.borderWidth = 1;
                    button.layer.borderColor = [UIColor colorWithHex:@"efefef"].CGColor;//kBorderColor.CGColor;
                    //[button addTarget:self action:@selector(changeImageByChangColorButton:) forControlEvents:UIControlEventTouchUpInside];
                    [button setUserInteractionEnabled:NO];

                    button.tag = i;
                    [colorBgView addSubview:button];
                    [_colorsArry addObject:button];

                    if (i == _currentColorIndexToShow) {
                        button.layer.borderWidth = 2;
                        ws.lastSelectedButton = button;
                        [ws updateScrollViewContentView];
                    }
                  
                    NSString *imageRelativePath = colorValue;
                    
                    NSString *imageName = [[imageRelativePath lastPathComponent] stringByAppendingString:kStyleColorImageCover];
                    
                    long seriesId = 0;
                    if (self.opusSeriesModel) {
                        seriesId = [self.opusSeriesModel.id longValue];
                    }else if (self.series){
                        seriesId = [self.series.series_id longValue];
                    }
                    
                    NSString *storePath = yyjOfflineSeriesImagePath(seriesId,imageRelativePath,imageName);

                    UIImage *image = [UIImage imageWithContentsOfFile:storePath];
                    if (image) {
                        [button setBackgroundImage:image forState:UIControlStateNormal];
                    }else{
                        sd_downloadWebImageWithRelativePath(NO, imageRelativePath, button, kStyleColorImageCover, 0);
                            }
                    
                    __weak UIView *weakContainer = colorBgView;
                    
                    [button mas_makeConstraints:^(MASConstraintMaker *make) {
                        //make.top.and.bottom.equalTo(weakContainer);
                        make.width.mas_equalTo(item_with);
                        make.height.mas_equalTo(item_height);
                        if ( lastView )
                        {
                            make.left.mas_equalTo(lastView.mas_right).with.offset(margin);
                        }
                        else
                        {
                            make.left.mas_equalTo(weakContainer.mas_left);
                        }
                        make.top.equalTo(weakContainer.mas_top).with.offset(line*(item_height+marginV));
                        
                    }];
                    lastView = button;
                
                }
            }
        }
   }
}

- (void)updateUIAtColorIndex:(NSInteger)colorIndex {

    // ---------- 修改按钮状态 start ----------
    // 0 代表未分类， 需要加入购物车按钮置为灰色、不可点击、toast提示
    if ([_styleInfoModel.style.seriesId intValue] == 0) {
        self.addShoppingCarButton.backgroundColor = [UIColor colorWithHex:@"D3D3D3"];
        [self.addShoppingCarButton setEnabled:NO];
        [YYToast showToastWithTitle:NSLocalizedString(@"该款式未分类不能加入购物车", nil) andDuration:kAlertToastDuration];
    }
    // ---------- end ----------
    
    NSString *name = @"";
    NSString *category = @"";
    NSString *styleCode = @"";
    NSString *materials = @"";
    NSString *daterange = @"";
    NSString *sizeValue = @"";
    NSString *tradePricepriceDetail = @"";
    NSString *retailPriceDetail = @"";
    NSString *desString = nil;
    NSInteger priceType = 0;
    double tmpTradePrice = 0;
    NSArray *colorArray = nil;
    NSComparisonResult compareResult = NSOrderedDescending;
    switch (_currentDataReadType) {
        case EDataReadTypeOffline:
        case EDataReadTypeOnline:{
            YYColorModel *colorModel = self.styleInfoModel.colorImages[colorIndex];
            name = _styleInfoModel.style.name;
            category = _styleInfoModel.style.category;
            styleCode = colorModel.styleCode;
            materials = colorModel.materials;
            daterange = (_styleInfoModel.dateRange ? [_styleInfoModel.dateRange getShowStr] : ([NSString isNilOrEmpty:self.styleInfoModel.style.note] ? NSLocalizedString(@"马上发货", nil) : self.styleInfoModel.style.note));
            if (_styleInfoModel.size
                && [_styleInfoModel.size count] > 0) {
                for (YYSizeModel *sizeModel in _styleInfoModel.size) {
                    if (sizeValue && [sizeValue length] > 0) {
                        sizeValue = [sizeValue stringByAppendingString:@"  "];
                    }
                    sizeValue = [sizeValue stringByAppendingString:sizeModel.value];
                }
            }
             priceType = [_styleInfoModel.style.curType integerValue] ;
            tradePricepriceDetail =  replaceMoneyFlag([NSString stringWithFormat:@"￥%0.2f",[colorModel.tradePrice floatValue]], priceType);
            retailPriceDetail = replaceMoneyFlag([NSString stringWithFormat:@"￥%0.2f",[colorModel.retailPrice floatValue]], priceType);
            tmpTradePrice = [_styleInfoModel.style.tradePrice floatValue];
            desString = _styleInfoModel.style.styleDescription;
            colorArray = _styleInfoModel.colorImages;
            if(_opusSeriesModel.orderDueTime !=nil){
                compareResult = compareNowDate(_opusSeriesModel.orderDueTime);
            }
        }
            break;
        case EDataReadTypeCached:{
            StyleDetailColors *color = [self.styleDetail.colors allObjects][colorIndex];
            name = _styleDetail.name;
            category = _styleDetail.category;
            styleCode = color.style_code;
            materials = color.materials;
            daterange = (_styleDetail.date_range ? [self getShowDateRangeStr:_styleDetail.date_range] : ([NSString isNilOrEmpty:self.styleDetail.note] ? NSLocalizedString(@"马上发货", nil) : self.styleDetail.note));
            if (_styleDetail.sizes && [_styleDetail.sizes count] > 0) {
                for (StyleDeatilSizes *styleDeatilSizes in _styleDetail.sizes) {
                    if (sizeValue && [sizeValue length] > 0) {
                        sizeValue = [sizeValue stringByAppendingString:@"  "];
                    }
                    sizeValue = [sizeValue stringByAppendingString:styleDeatilSizes.size_value];
                }
            }
            priceType = [_styleDetail.cur_type integerValue];
            tradePricepriceDetail = replaceMoneyFlag([NSString stringWithFormat:@"￥%0.2f",[color.trade_price floatValue]], priceType);
            retailPriceDetail = replaceMoneyFlag([NSString stringWithFormat:@"￥%0.2f",[color.retail_price  floatValue]], priceType);
            tmpTradePrice = [_styleDetail.tradePrice floatValue];
            
            NSLog(@"_styleDetail.style_description: %@",_styleDetail.style_description);
            
            desString = _styleDetail.style_description;
            
            colorArray = [_styleDetail.colors allObjects];
            if(_series.order_due_time != nil ){
                compareResult = compareNowDate(_series.order_due_time);
            }

        }
            break;
        default:
            break;
    }
    
    _orderDueCompareResult = compareResult;
    //更新约束
    _nameLabel.text = name;
    float nameLabelHeight = getTxtHeight(200, name, @{NSFontAttributeName:_nameLabel.font});
    CGSize nameLabelSize = [name sizeWithAttributes:@{NSFontAttributeName:_nameLabel.font}];
    float neednameLabeHeight = ceilf(nameLabelSize.height);
    nameLabelHeight = MIN(nameLabelHeight, neednameLabeHeight*2);
    [_nameLabel setConstraintConstant:nameLabelHeight forAttribute:NSLayoutAttributeHeight];
    _categoryLabel.text = category;
    _styleCodeLabel.text = styleCode;
    _styleCodeLabel.adjustsFontSizeToFitWidth = YES;
    _materialsLabel.text = materials;
    self.dateTitleLabel.text = self.styleInfoModel.dateRange ? NSLocalizedString(@"发货波段", nil) : NSLocalizedString(@"发货日期", nil);
    _dateRangeLabel.text = daterange;
    float dateRangeLabelHeight = getTxtHeight(265, daterange, @{NSFontAttributeName:_dateRangeLabel.font});
    [_dateRangeLabel setConstraintConstant:dateRangeLabelHeight forAttribute:NSLayoutAttributeHeight];
    _sizeDetailLabel.text = sizeValue;
    float sizeDetailLabelHeight = getTxtHeight(265,sizeValue,@{NSFontAttributeName:[UIFont boldSystemFontOfSize:14]});//sizeDetailLabelRect.size.height+1;
    _sizeDetailLabelHeightLayoutConstraint.constant = sizeDetailLabelHeight;
    [self.sizeDetailLabel setNeedsDisplay];
    [_sizeDetailLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(sizeDetailLabelHeight));
    }];
    NSString *priceStr = [NSString stringWithFormat:NSLocalizedString(@"批发  %@",nil),tradePricepriceDetail];
    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString: priceStr];
    [attributedStr addAttribute: NSForegroundColorAttributeName value: [UIColor colorWithHex:@"ed6498"] range: NSMakeRange(priceStr.length-tradePricepriceDetail.length, tradePricepriceDetail.length)];
    [attributedStr addAttribute: NSFontAttributeName value: [UIFont boldSystemFontOfSize:16]  range: NSMakeRange(priceStr.length-tradePricepriceDetail.length, tradePricepriceDetail.length)];
   _tradePriceDetailLabel.attributedText= attributedStr;
   _retailPriceDetailLabel.text = [NSString stringWithFormat:NSLocalizedString(@"零售  %@",nil),retailPriceDetail];
    
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.lineSpacing =10;
    NSDictionary *attrDict = @{ NSParagraphStyleAttributeName: paraStyle,
                                NSFontAttributeName: [UIFont systemFontOfSize: 13] };

    if ([desString isKindOfClass:[NSNull class]]) {
        desString = @"";
    }else if([NSString isNilOrEmpty:desString]){
        desString = @"";
    }
    _descriptionTextView.attributedText = [[NSAttributedString alloc] initWithString: desString attributes: attrDict];
    float descriptionTextHeight = getTxtHeight(340,desString,attrDict);
    //税制
    if(needPayTaxView(priceType) &&_selectTaxType){
        float taxRate = [getPayTaxType(_selectTaxType,NO) doubleValue];
        NSString *taxPrice = replaceMoneyFlag([NSString stringWithFormat:@"%@  ￥%0.2f",NSLocalizedString(@"税后",nil),tmpTradePrice*(1+taxRate)],priceType);

         _retailPriceDetailLabel.text = [NSString stringWithFormat:NSLocalizedString(@"零售 %@   %@  ",nil),retailPriceDetail,taxPrice];
    }else{
        _retailPriceDetailLabel.text = [NSString stringWithFormat:NSLocalizedString(@"零售  %@",nil),retailPriceDetail];
    }
    _retailPriceDetailLabel.adjustsFontSizeToFitWidth = YES;
    
    for (UIView *ui in [self.colorBgView subviews]) {
        [ui removeFromSuperview];
    }
    
    if (colorArray && [colorArray count] > 0) {
        [self addColorButton:self.colorBgView colors:colorArray];
    }
    _contentViewHeightLayoutConstraint.constant = 457 + self.colorBgViewHeightConstraint.constant - 40 +sizeDetailLabelHeight -14+dateRangeLabelHeight-14 +descriptionTextHeight-175;
}

#pragma mark -- 购物车弹框
- (IBAction)addShoppingCarAction:(id)sender {
    if(_opusSeriesModel){
        if([_opusSeriesModel.status integerValue] == YYOpusCheckAuthDraft){
            if(_isToScan){
                [YYToast showToastWithView:self.view title:NSLocalizedString(@"该款式为草稿不能加入购物车",nil) andDuration:kAlertToastDuration];
            }else{
                [YYTopAlertView showWithType:YYTopAlertTypeError text:NSLocalizedString(@"请先发布作品！",nil) parentView:self.styleDetailViewController.view];
            }
            return;
        }
    }else if(_series){
        if([_opusSeriesModel.status integerValue] == YYOpusCheckAuthDraft){
            if(_isToScan){
                [YYToast showToastWithView:self.view title:NSLocalizedString(@"该款式为草稿不能加入购物车",nil) andDuration:kAlertToastDuration];
            }else{
                [YYTopAlertView showWithType:YYTopAlertTypeError text:NSLocalizedString(@"请先发布作品！",nil) parentView:self.styleDetailViewController.view];
            }
            return;
        }
    }
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if ( self.orderDueCompareResult == NSOrderedAscending) {
        [YYTopAlertView showWithType:YYTopAlertTypeError text:NSLocalizedString(@"此系列已过最晚下单日期，不能下单。",nil)parentView:self.styleDetailViewController.view];
        return;
    }
    NSInteger moneyType = -1;
    if (_styleInfoModel) {
        moneyType = [_styleInfoModel.style.curType integerValue];
    }else if(self.styleDetail){
        moneyType = [self.styleDetail.cur_type integerValue];
    }
    if(appDelegate.cartModel == nil){
        appDelegate.cartMoneyType = -1;
    }
    
    if(appDelegate.cartMoneyType > -1 && moneyType != appDelegate.cartMoneyType){
        [YYToast showToastWithView:self.view title:NSLocalizedString(@"购物车中存在其他币种的款式，不能将此款式加入购物车。您可以清空购物车后，将此款式加入购物车。",nil) andDuration:kAlertToastDuration];
        return;
    }
    
    
    UIView *superView = self.styleDetailViewController.view;

    [appDelegate showShoppingViewNew:NO styleInfoModel:(_styleInfoModel?_styleInfoModel:_styleDetail) seriesModel:(_opusSeriesModel?_opusSeriesModel:_series) opusStyleModel:nil currentYYOrderInfoModel:nil parentView:superView fromBrandSeriesView:NO WithBlock:nil];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSString *)getShowDateRangeStr:(StyleDateRange *)dateRange{
    
    return  [NSString stringWithFormat:NSLocalizedString(@"%@ :%@-%@",nil),dateRange.name,getShowDateByFormatAndTimeInterval(@"yyyy/MM/dd",[dateRange.start stringValue]),getShowDateByFormatAndTimeInterval(@"yyyy/MM/dd",[dateRange.end stringValue])];
}
@end

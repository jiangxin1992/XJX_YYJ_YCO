//
//  YYSeriesDetailInfoViewCell.m
//  Yunejian
//
//  Created by Apple on 15/12/22.
//  Copyright © 2015年 yyj. All rights reserved.
//

#import "YYSeriesDetailInfoViewCell.h"

// c文件 —> 系统文件（c文件在前）

// 控制器

// 自定义视图
#import "SCLoopScrollView.h"
#import "YYTopAlertView.h"
#import "YYSeriesTagsView.h"
#import "SCGIFImageView.h"

// 接口
#import "YYUserApi.h"

// 分类
#import "NSManagedObject+helper.h"
#import "UIImage+YYImage.h"

// 自定义类和三方类（ cocoapods类 > model > 工具类 > 其他）
#import "LookBook.h"
#import "LookBookPics.h"
#import "YYSeriesInfoModel.h"
#import "YYLookBookModel.h"
#import "YYDateRangeModel.h"
#import "YYSeriesInfoDetailModel.h"


@interface YYSeriesDetailInfoViewCell()

@property (nonatomic, strong) YYLookBookModel *lookBookModel;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *seasonLabel;
@property (weak, nonatomic) IBOutlet UILabel *supplyTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *styleAmountLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderDueTimeLabel;
@property (weak, nonatomic) IBOutlet UIButton *sortBtn;
@property (weak, nonatomic) IBOutlet UIView *lookbookContainer;
@property (weak, nonatomic) IBOutlet UILabel *picsNullTipLabel;
@property (weak, nonatomic) IBOutlet SCGIFImageView *lookBookCoverImageView;

@property (weak, nonatomic) IBOutlet YYSeriesTagsView *tagsView;
@property (weak, nonatomic) IBOutlet YYSeriesTagsView *taxTypeView;

@property (weak, nonatomic) IBOutlet UIButton *addToCartButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelAddToCartButton;
@property (weak, nonatomic) IBOutlet UIButton *sureAddToCartButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cancelAddToCartButtonWidthLayout;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cancelAddToCartButtonLeadLayout;

@end

@implementation YYSeriesDetailInfoViewCell

#pragma mark - --------------生命周期--------------


#pragma mark - --------------SomePrepare--------------
- (void)SomePrepare
{
    [self PrepareData];
    [self PrepareUI];
}
- (void)PrepareData{}
- (void)PrepareUI{

    _sortBtn.layer.borderColor = [UIColor blackColor].CGColor;
    _sortBtn.layer.borderWidth = 1;
    [_sortBtn setImage:[UIImage imageNamed:@"triangle_down_icon"] forState:UIControlStateNormal];
    [_sortBtn setTitle:NSLocalizedString(@"已按款号降序排列",nil) forState:UIControlStateNormal];
    [_sortBtn setImage:[UIImage imageNamed:@"triangle_up_icon"] forState:UIControlStateSelected];
    [_sortBtn setTitle:NSLocalizedString(@"已按款号升序排列",nil) forState:UIControlStateSelected];

    _cancelAddToCartButton.layer.borderColor = _define_black_color.CGColor;
    _cancelAddToCartButton.layer.borderWidth = 1;

    [_lookBookCoverImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showLookBookPics)]];
    
}

#pragma mark - --------------UpdateUI----------------------
-(void)updateUI{

    [self SomePrepare];

    if(_isSelect){
        _addToCartButton.hidden = YES;
        _cancelAddToCartButton.hidden = NO;
        _sureAddToCartButton.hidden = NO;
        _cancelAddToCartButtonWidthLayout.constant = 120;
        _cancelAddToCartButtonLeadLayout.constant = 15;
    }else{
        _addToCartButton.hidden = NO;
        if(self.orderDueCompareResult == NSOrderedAscending){
            _addToCartButton.backgroundColor = [UIColor colorWithHex:@"d3d3d3"];
        }else{
            _addToCartButton.backgroundColor = _define_black_color;
        }
        _cancelAddToCartButton.hidden = YES;
        _sureAddToCartButton.hidden = YES;
        _cancelAddToCartButtonWidthLayout.constant = 0;
        _cancelAddToCartButtonLeadLayout.constant = 0;
    }

    if(!_selectCount){
        [_sureAddToCartButton setTitle:NSLocalizedString(@"未选择", nil) forState:UIControlStateNormal];
        _sureAddToCartButton.backgroundColor = [UIColor colorWithHex:@"d3d3d3"];
    }else{
        [_sureAddToCartButton setTitle:[[NSString alloc] initWithFormat:NSLocalizedString(@"确定加入（%ld）", nil),_selectCount] forState:UIControlStateNormal];
        _sureAddToCartButton.backgroundColor = _define_black_color;
    }

    _sortBtn.hidden = NO;
    if([_sortType isEqualToString:kSORT_STYLE_CODE_DESC]){
        _sortBtn.selected = NO;
    }else if([_sortType isEqualToString:kSORT_STYLE_CODE]){
        _sortBtn.selected = YES;
    }else{
        _sortBtn.hidden = YES;
    }
    if (_seriesInfoDetailModel.series != nil) {
        _nameLabel.text = _seriesInfoDetailModel.series.name;
        _styleAmountLabel.text = [NSString stringWithFormat:NSLocalizedString(@"共%@款",nil),[_seriesInfoDetailModel.series.styleAmount stringValue]];
        if(![NSString isNilOrEmpty:_seriesInfoDetailModel.series.orderDueTime]){
            _seasonLabel.text = [NSString stringWithFormat:NSLocalizedString(@"最晚下单：%@",nil),getShowDateByFormatAndTimeInterval(@"yyyy/MM/dd",_seriesInfoDetailModel.series.orderDueTime)];
        } else {
            self.seasonLabel.text = [NSString stringWithFormat:NSLocalizedString(@"最晚下单：%@",nil), NSLocalizedString(@"随时可以下单",nil)];
        }
        if(_seriesInfoDetailModel.series.orderAmountMin && [_seriesInfoDetailModel.series.orderAmountMin integerValue] > 0){
            _seasonLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@       每款起订量：%@",nil),_seasonLabel.text,[_seriesInfoDetailModel.series.orderAmountMin stringValue]];
        }
        if ([self.seriesInfoDetailModel.series.orderPriceMin floatValue] > 0) {
            self.seasonLabel.text = [[self.seasonLabel.text stringByAppendingString:@"       "] stringByAppendingString:replaceMoneyFlag([NSString stringWithFormat:NSLocalizedString(@"系列起订金额：￥%.2lf", nil), [self.seriesInfoDetailModel.series.orderPriceMin floatValue]], [self.seriesInfoDetailModel.series.orderPriceCurType integerValue])];
        }
        _supplyTimeLabel.text = [NSString stringWithFormat:NSLocalizedString(@"发货波段",nil)];
        _orderDueTimeLabel.text = NSLocalizedString(@"税制",nil);
    }else{
        _nameLabel.text = @"";
        _styleAmountLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@款",nil),@"0"];
        _seasonLabel.text = [NSString stringWithFormat:@"Season：%@",@""];
        _orderDueTimeLabel.text = NSLocalizedString(@"税制",nil);
    }
    WeakSelf(ws);
    if( _seriesInfoDetailModel.dateRanges != nil && [_seriesInfoDetailModel.dateRanges count]> 0){
        NSMutableArray *tagArr = [[NSMutableArray alloc] init];
        for (YYDateRangeModel *dateRang in _seriesInfoDetailModel.dateRanges) {
            [tagArr addObject:[dateRang getShowStr]];
        }
        _tagsView.needCancelImg = NO;
        _tagsView.btnEdgeInsets = UIEdgeInsetsMake(10, 0, 10, 10);

        [_tagsView createTags:tagArr selectedIndex:_dateRangIndex];
        [_tagsView setSelectedValue:^(NSString *value){
            if(ws.selectedTagValue){
                ws.selectedTagValue(value);
            }
        }];
        self.supplyTimeLabel.text = [NSString stringWithFormat:NSLocalizedString(@"发货方式：%@  ", nil), NSLocalizedString(@"期货", nil)];
        self.supplyTimeLabel.text = [self.supplyTimeLabel.text stringByAppendingString:NSLocalizedString(@"发货波段",nil)];
        _tagsView.hidden = NO;
    }else{
        self.supplyTimeLabel.text = [NSString stringWithFormat:NSLocalizedString(@"发货方式：%@  ", nil), NSLocalizedString(@"现货", nil)];
        self.supplyTimeLabel.text = [self.supplyTimeLabel.text stringByAppendingString:[NSString stringWithFormat:NSLocalizedString(@"发货日期：%@", nil), [NSString isNilOrEmpty:self.seriesInfoDetailModel.series.note] ? NSLocalizedString(@"马上发货", nil) : self.seriesInfoDetailModel.series.note]];
        _tagsView.hidden = YES;
    }
    //税制
    NSArray *taxTypeData = getPayTaxData(YES);
    _taxTypeView.needCancelImg = NO;
    [_taxTypeView createTags:taxTypeData selectedIndex:_selectTaxType];
    _taxTypeView.btnEdgeInsets = UIEdgeInsetsMake(10, 0, 10, 0);
    [_taxTypeView setSelectedValue:^(NSString *value){
        if(ws.selectTaxType != [value integerValue]){
            [YYTopAlertView showWithType:YYTopAlertTypeSuccess text:NSLocalizedString(@"成功切换税制",nil) parentView:nil];
        }
        if(ws.selectedTaxTagValue){
            ws.selectedTaxTagValue(value);
        }
    }];
    [self updateLookBookUI];
    [self loadLookBookInfo];
}

#pragma mark - --------------自定义响应----------------------
//加入购物车
- (IBAction)addToCart:(id)sender {
    if (self.delegate) {
        [self.delegate btnClick:_indexPath.row section:_indexPath.section andParmas:@[@"addToCart"]];
    }
}
//取消购物车
- (IBAction)cancelAddToCart:(id)sender {
    if (self.delegate) {
        [self.delegate btnClick:_indexPath.row section:_indexPath.section andParmas:@[@"cancelAddToCart"]];
    }
}
//确认加入
- (IBAction)sureToAddToCart:(id)sender {
    if(_selectCount){
        [self.delegate btnClick:_indexPath.row section:_indexPath.section andParmas:@[@"sureToAddToCart"]];
    }
}
- (IBAction)sortBtnHandler:(id)sender {
    if(_selectButtonClicked){
        _selectButtonClicked(_sortBtn.selected);
    }
}

- (IBAction)moreSytleInfo:(id)sender {
    if(self.showSeriesInfo){
        self.showSeriesInfo(YES);
    }
}

#pragma mark - --------------自定义方法----------------------
- (void)showLookBookPics{
    if(_lookBookModel == nil || [_lookBookModel.picUrls count] == 0){
        return;
    }
    NSInteger count = [_lookBookModel.picUrls count];
    NSMutableArray *tmpArr = [[NSMutableArray alloc] initWithCapacity:count];
    if(count > 0){
        for(int i = 0 ; i < count; i++){
            NSString *imageName =[NSString stringWithFormat:@"%@",[[_lookBookModel.picUrls objectAtIndex:i] objectForKey:@"picUrl"]];
            NSString *_imageRelativePath = imageName;
            NSString *imgInfo = [NSString stringWithFormat:@"%@%@|%@",_imageRelativePath,kLookBookImage,@""];
            [tmpArr addObject:imgInfo];
        }

    }
    SCLoopScrollView *scrollView = [[SCLoopScrollView alloc] initWithFrame:CGRectMake(0, 0, 600, 600)];
    scrollView.backgroundColor = [UIColor clearColor];

    scrollView.images = tmpArr;
    UILabel *pageLabel = [[UILabel alloc] initWithFrame:CGRectMake((CGRectGetWidth(scrollView.frame)-100)/2, (CGRectGetHeight(scrollView.frame) -28-15), 100, 28)];
    pageLabel.textColor = [UIColor whiteColor];//[UIColor colorWithHex:@"0xafafafaf99"];
    pageLabel.font = [UIFont systemFontOfSize:15];
    pageLabel.textAlignment = NSTextAlignmentCenter;
    pageLabel.text = [NSString stringWithFormat:@"%d / %lu",1,(unsigned long)[tmpArr count]];
    __block UILabel *weakpageLabel = pageLabel;
    __block NSInteger blockPagecount = [tmpArr count];

    CMAlertView *alert = [[CMAlertView alloc] initWithViews:@[scrollView,pageLabel] imageFrame:CGRectMake(0, 0, 600, 600) bgClose:NO];
    __block  CMAlertView *blockalert = alert;
    [scrollView show:^(NSInteger index) {
        [blockalert OnTapBg:nil];
    } finished:^(NSInteger index) {
        if(blockPagecount == 0){
            [weakpageLabel setText:@""];
        }else{
            [weakpageLabel setText:[NSString stringWithFormat:@"%ld / %ld",index+1,(long)blockPagecount]];
        }
    }];
    [alert show];
}

-(void)loadLookBookInfo{
    WeakSelf(ws);
    if([self downloadOfflineLookBook:[_seriesInfoDetailModel.series.id integerValue]]){
        [self updateLookBookUI];
    }else if (![YYNetworkReachability connectedToNetwork]) {
        [self fetchEntitys];
    }else{
        if(_seriesInfoDetailModel.lookBookId != nil && [_seriesInfoDetailModel.lookBookId integerValue] > 0){
            [YYUserApi getLookBookInfoWithId:[_seriesInfoDetailModel.lookBookId integerValue] andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYLookBookModel *lookBookModel, NSError *error) {
                if(rspStatusAndMessage.status == YYReqStatusCode100){
                    ws.lookBookModel = lookBookModel;
                    if(lookBookModel.coverPic != nil && ![lookBookModel.coverPic isEqualToString:@""]){
                        NSMutableArray *tmpPics = [[NSMutableArray alloc] init];
                        [tmpPics addObject:@{@"picUrl":lookBookModel.coverPic}];
                        if(lookBookModel.picUrls !=nil && [lookBookModel.picUrls count] > 0){
                            [tmpPics addObjectsFromArray:lookBookModel.picUrls];
                        }
                        ws.lookBookModel.picUrls = tmpPics;
                    }

                    [ws insertObjectToDbFromSeriesModel:lookBookModel];
                    [ws updateLookBookUI];
                }
            }];
        }
    }
}

-(BOOL)downloadOfflineLookBook:(NSInteger)seriesID{
    //读取本地的离线数据
    NSString *folderName = [NSString stringWithFormat:@"%ld",(long)seriesID];
    NSString *offlineFilePath = [yyjOfflineSeriesDirectory() stringByAppendingPathComponent:folderName];
    NSString *imgsJsonPath = [offlineFilePath stringByAppendingPathComponent:@"imgs.json"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    YYLookBookModel *lookBookModel;
    if ([fileManager fileExistsAtPath:imgsJsonPath]) {
        NSData *data = [NSData dataWithContentsOfFile:imgsJsonPath];
        if (data) {
            NSError* error;
            NSDictionary* json = [NSJSONSerialization
                                  JSONObjectWithData:data
                                  options:NSJSONReadingAllowFragments
                                  error:&error];
            NSArray *urls = [json objectForKey:@"lookBook"];
            if(urls && [urls count] > 0){
                lookBookModel = [[YYLookBookModel alloc] init];
                NSMutableArray *tmpArray = [[NSMutableArray alloc] init];
                for (NSString * imageRelativePath in urls) {
                    [tmpArray addObject:@{@"picUrl":imageRelativePath}];
                }
                lookBookModel.coverPic = [[tmpArray objectAtIndex:0] objectForKey:@"picUrl"];
                lookBookModel.picUrls = tmpArray;
            }
            self.lookBookModel = lookBookModel;
            return YES;
        }
    }
    return NO;
}

-(void)updateLookBookUI{
    if(_lookBookModel.coverPic){
        _picsNullTipLabel.hidden = YES;
        NSString *imageRelativePath = _lookBookModel.coverPic;
        _lookBookCoverImageView.contentMode = UIViewContentModeScaleAspectFit;
        sd_downloadWebImageWithRelativePath(YES, imageRelativePath, _lookBookCoverImageView, kLookBookImage, UIViewContentModeScaleAspectFit);

    }
}

- (void)insertObjectToDbFromSeriesModel:(YYLookBookModel *)lookBookModel{
    NSString *predicate = [NSString stringWithFormat:@"lookBookId=%i",[lookBookModel.id intValue]];
    NSLog(@"predicate: %@",predicate);
    LookBook *lookBook = [LookBook one:predicate];
    if (!lookBook) {
        lookBook = [LookBook createNew];
        lookBook.lookBookId = lookBookModel.id;
    }
    lookBook.coverPic = lookBookModel.coverPic;

    NSArray *picUrlArray = lookBookModel.picUrls;
    if (picUrlArray && [picUrlArray count] > 0) {
        NSMutableArray *tempColorArray = [[NSMutableArray alloc] initWithCapacity:0];
        NSString *url_predicate = nil;
        for (NSDictionary *picObj in picUrlArray) {
            url_predicate = [NSString stringWithFormat:@"lookBookId=%i",[lookBookModel.id intValue]];
            LookBookPics *lookBookPics = [LookBookPics one:url_predicate];
            if (!lookBookPics) {
                lookBookPics = [LookBookPics createNew];
                lookBookPics.lookBookId = [picObj objectForKey:@"lookBookId"];
            }
            lookBookPics.picUrl = [picObj objectForKey:@"picUrl"];
            [tempColorArray addObject:lookBookPics];
        }
        lookBook.pics = [[NSSet alloc] initWithArray:tempColorArray];
    }

    [LookBook save:^(NSError *error) {
        NSLog(@"error %@",error);
    }];
}

-(void)fetchEntitys{

    WeakSelf(ws);
    [LookBook async:^id(NSManagedObjectContext *ctx, NSString *className) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:className];
        NSString *predicate = [NSString stringWithFormat:@"lookBookId=%ld",(long)[_seriesInfoDetailModel.lookBookId integerValue]];
        [request setPredicate:[NSPredicate predicateWithFormat:predicate]];
        //[request setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"style_id" ascending:YES]]];
        NSError *error;
        NSArray *dataArray = [ctx executeFetchRequest:request error:&error];
        if (error) {
            return error;
        }else{
            return dataArray;
        }
    } result:^(NSArray *result, NSError *error) {
        if (result
            && [result count] > 0) {
            LookBook *lookBook = [result objectAtIndex:0];
            ws.lookBookModel = [[YYLookBookModel alloc] init];
            ws.lookBookModel.id = lookBook.lookBookId;
            ws.lookBookModel.coverPic = lookBook.coverPic;

            NSMutableArray *tmpArray = [[NSMutableArray alloc] init];
            for (LookBookPics *picData in lookBook.pics) {
                [tmpArray addObject:@{@"picUrl":picData.picUrl}];
            }
            ws.lookBookModel.picUrls = tmpArray;
        }
        [ws updateLookBookUI];
    }];
}
#pragma mark - --------------other----------------------


@end

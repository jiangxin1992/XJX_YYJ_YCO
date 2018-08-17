//
//  YYSeriesCollectionViewCell.m
//  Yunejian
//
//  Created by yyj on 15/9/4.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import "YYSeriesCollectionViewCell.h"

#import "UIImage+YYImage.h"
#import "YYOpusApi.h"
#import "Main.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import "YYPopoverArrowBackgroundView.h"
#import "SCGIFImageView.h"
#import "YYConnApi.h"
#import "YYUser.h"
#import "RequestMacro.h"
#import "SDWebImageManager.h"

#import "YYUser.h"
#import "YYSubShowroomUserPowerModel.h"

#define kHaveDownloadTips NSLocalizedString(@"下载完成",nil)

@interface YYSeriesCollectionViewCell ()


@property (weak, nonatomic) IBOutlet SCGIFImageView *coverImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *produceLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderLabel;
@property (weak, nonatomic) IBOutlet UILabel *styleAmountLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateRangeLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *orderLabelTopLayoutConstraint;

@property (weak, nonatomic) IBOutlet UIButton *operationButton;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UIButton *startBtn;//设置隐私状态
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLableHeightLayoutConstraint;

@property (weak, nonatomic) IBOutlet UILabel *outTimeFlagView1;
@property (weak, nonatomic) IBOutlet UILabel *outTimeFlagView2;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *outTimerViewLayoutleftConstriant1;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *outTimerViewLayoutleftConstriant2;
@property (nonatomic, weak) IBOutlet UILabel *deliveryLabel;

@property (weak, nonatomic) IBOutlet UIImageView *statusDraftImage;
@property(nonatomic,copy) UIButton *tmpMenuBtn;
@property(nonatomic,strong) UIPopoverController *popController;

@end

@implementation YYSeriesCollectionViewCell

static NSMutableDictionary *operationList;
static NSMutableDictionary *downLoadCountList;
- (IBAction)operationButtonClicked:(id)sender{

    NSString *folderName = [NSString stringWithFormat:@"%li",_series_id];
    NSString *offlineFilePath = [yyjOfflineSeriesDirectory() stringByAppendingPathComponent:folderName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(_series_id == 100){
        NSLog(@"111");
    }
    if(sender == nil || ![fileManager fileExistsAtPath:offlineFilePath]){
        if (self.stockEnabled && self.supplyStatus == 0) {
            [YYToast showToastWithTitle:NSLocalizedString(@"离线状态时，现货系列下单可能会因为下单数量过多导致订单建立不成功。", nil) andDuration:kAlertToastDuration];
        }
        
        NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kSeriesOffline1];
        requestURL = [requestURL stringByAppendingString:[NSString stringWithFormat:@"?seriesId=%ld",self.series_id]];
        NSString *writePath = [yyjOfflineSeriesZipDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%ld.zip",self.series_id]];
        [self downloadOfflinePackageWithUrl:requestURL writeToPath:writePath andSeriesId:_series_id];
    }else{
        NSInteger menuUIWidth = 162;
        NSInteger menuUIHeight = 98;
        UIViewController *controller = [[UIViewController alloc] init];
        controller.view.frame = CGRectMake(0, 0, menuUIWidth, menuUIHeight);
        setMenuUI_pad(self,controller.view,@[@[@"download_update",NSLocalizedString(@"更新离线包",nil)],@[@"download_delete",NSLocalizedString(@"删除离线包",nil)
    ]]);

        UIPopoverController *popController = [[UIPopoverController alloc] initWithContentViewController:controller];
        _popController = popController;
        CGPoint p = [self convertPoint:self.operationButton.center toView:[self.delegate getview]];
        CGRect rc = CGRectZero;
        popController.popoverContentSize = CGSizeMake(menuUIWidth,menuUIHeight);
        popController.popoverBackgroundViewClass = [YYPopoverArrowBackgroundView class];

        if((p.y+ menuUIHeight) > SCREEN_HEIGHT){
            rc = CGRectMake(p.x, p.y -CGRectGetHeight(self.operationButton.frame)/2, 0, 0);
            [popController presentPopoverFromRect:rc inView:[self.delegate getview] permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];

        }else{
            rc = CGRectMake(p.x, p.y+CGRectGetHeight(self.operationButton.frame)/2, 0, 0);
            [popController presentPopoverFromRect:rc inView:[self.delegate getview] permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];

        }
        _tmpMenuBtn = sender;
    }
}
#pragma menu
-(void)menuBtnHandler:(id)sender{
    if(_tmpMenuBtn == nil){
        return;
    }
    UIButton *btn = (UIButton *)sender;
    NSInteger type = btn.tag;
    if(_tmpMenuBtn == _operationButton){
        if(type == 1){
            //
            if (![YYNetworkReachability connectedToNetwork]) {
                [YYToast showToastWithTitle:kNetworkIsOfflineTips andDuration:kAlertToastDuration];
            }else{
                _totalImageCount = 0;
                [YYUser deleteTempSeriesID:_series_id];
                [self operationButtonClicked:nil];
            }
        }else if(type == 2){
            [YYUser deleteTempSeriesID:_series_id];
            [self deleteOffinePackage:NO];
        }
    }else if(_tmpMenuBtn == _startBtn){
        if(_indexPath != nil){
            NSInteger tmpType;
            if(type == 1){
                tmpType = kAuthTypeBuyer;
            }else if(type == 2){
                tmpType = kAuthTypeMe;
            }else if(type == 3){
                tmpType = kAuthTypeAll;
            }else if(type == 4){
                tmpType = kAuthTypeDefined;
            }
            [self.delegate operateHandler:tmpType androw:_indexPath.row type:@"updateAuthType"];
        }
    }
    _tmpMenuBtn = nil;
    [_popController dismissPopoverAnimated:YES];
}
#pragma DownLoadOperation
- (void)downloadOfflinePackageWithUrl:(NSString *)url writeToPath:(NSString *)filePath andSeriesId:(long)seriesId{
    NSLog(@"url:%@ filePath: %@",url,filePath);
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    UIView *superView = appDelegate.window.rootViewController.view;

    DownLoadOperation *operation = [[DownLoadOperation alloc] init];
    [self addDownLoadOperation:operation];
    WeakSelf(ws);
    __block NSInteger blockseriesID = seriesId;
    if(ws.series_id == blockseriesID){
        
        _haveLoadData = YES;
        
    }
    [MBProgressHUD showHUDAddedTo:superView animated:YES];
    
    [YYUser addTempSeriesID:blockseriesID];
    
    [operation downloadWithUrl:url cachePath:^NSString *{
        return filePath;
    } progressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        if(blockseriesID == ws.series_id){
            dispatch_async(dispatch_get_main_queue(), ^{
                [ws updateProgressWithCurrentRead:totalBytesRead totalSize:totalBytesExpectedToRead*2 andSeriesId:blockseriesID];
            });
        }
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // Unzip Operation
        
        NSString *destinationPath = yyjOfflineSeriesDirectory();
        
        [Main unzipFileAtPath:filePath toDestination:destinationPath];
        NSString *folderName = [NSString stringWithFormat:@"%li",_series_id];
        NSString *offlineFilePath = [yyjOfflineSeriesDirectory() stringByAppendingPathComponent:folderName];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:offlineFilePath]) {
            NSLog(@"111");
            NSLog(@"offlineFilePath1 = %@",offlineFilePath);
        }else{
            NSLog(@"111");
            NSLog(@"offlineFilePath1_error = %@",offlineFilePath);
        }
        
        if ([fileManager fileExistsAtPath:destinationPath]) {
            [fileManager removeItemAtPath:filePath error:nil];
        }
        
        [ws deleteDownLoadOperation:blockseriesID];
        [ws downloadOfflineImages:blockseriesID];
        
        [MBProgressHUD hideAllHUDsForView:superView animated:YES];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"error = %@",error);
        [YYUser deleteTempSeriesID:blockseriesID];
        
        if(ws.series_id == blockseriesID){
            _haveLoadData = NO;
        }
        [MBProgressHUD hideAllHUDsForView:superView animated:YES];
        
    }];
    [operation.requestOperation start];
 
}
// opeation list
-(void)addDownLoadOperation:(DownLoadOperation *)operation{
    if(operationList == nil){
        operationList = [[NSMutableDictionary alloc] init];
    }
    [operationList setValue:operation forKey:[NSString stringWithFormat:@"%ld",_series_id]];
}

-(void)deleteDownLoadOperation:(NSInteger)seriesID{
    if([operationList objectForKey:[NSString stringWithFormat:@"%ld",(long)seriesID]]){
        DownLoadOperation *operation  = [operationList objectForKey:[NSString stringWithFormat:@"%ld",(long)seriesID]];
        [operation.requestOperation cancel];
        operation = nil;
        [operationList setValue:nil forKey:[NSString stringWithFormat:@"%ld",(long)seriesID]];
    }
}

-(id)checkOperation:(NSInteger)seriesID{
    DownLoadOperation *operation = nil;
    if([operationList objectForKey:[NSString stringWithFormat:@"%ld",(long)seriesID]]){
        operation = [operationList objectForKey:[NSString stringWithFormat:@"%ld",(long)seriesID]];
    }
    return operation;
}

// downLoadCountList
-(void)addDownLoadCount:(NSArray *)value{
    if(downLoadCountList == nil){
        downLoadCountList = [[NSMutableDictionary alloc] init];
    }
    [downLoadCountList setValue:value forKey:[NSString stringWithFormat:@"%ld",_series_id]];
}

-(void)deleteDownLoadCount:(NSInteger)seriesID{
    if(downLoadCountList && [downLoadCountList objectForKey:[NSString stringWithFormat:@"%ld",(long)seriesID]]){
        [downLoadCountList setValue:nil forKey:[NSString stringWithFormat:@"%ld",(long)seriesID]];
    }
}

-(NSArray *)getDownLoadCount:(NSInteger)seriesID{
    if(downLoadCountList && [downLoadCountList objectForKey:[NSString stringWithFormat:@"%ld",(long)seriesID]]){
       return [downLoadCountList valueForKey:[NSString stringWithFormat:@"%ld",(long)seriesID]];
    }
    return nil;
}

-(void)deleteOffinePackage:(BOOL )isFromAlertView{

    long temp_series_id = 0;
    if(isFromAlertView){
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        temp_series_id = [appDelegate.delegate_series_id longValue];
    }else{
        temp_series_id = _series_id;
    }


    [self deleteDownLoadOperation:temp_series_id];
    NSString *folderName = [NSString stringWithFormat:@"%li",temp_series_id];
    NSString *offlineFilePath = [yyjOfflineSeriesDirectory() stringByAppendingPathComponent:folderName];
    NSString *imgsJsonPath = [offlineFilePath stringByAppendingPathComponent:@"imgs.json"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:imgsJsonPath]) {
        NSData *data = [NSData dataWithContentsOfFile:imgsJsonPath];
        if (data) {
            NSError* error;
            NSDictionary* json = [NSJSONSerialization
                                  JSONObjectWithData:data
                                  options:NSJSONReadingAllowFragments
                                  error:&error];
            //这个json要处理下，过滤出可以删除的图片（过滤掉其他离线中包含的图片）
            //我觉得根本就不用删除。。。 这不是图片缓存吗 跟系列没关系吧。这边我注释掉了
            [self requestUrls:json andSuffix:kStyleColorImageCover andType:@"color" andOperate:2];
            [self requestUrls:json andSuffix:kStyleCover andType:@"album" andOperate:2];
            [self requestUrls:json andSuffix:kStyleDetailCover andType:@"style" andOperate:2];

            [self requestUrls:json andSuffix:kLookBookImage andType:@"lookBook" andOperate:2];

        }

    }

    NSError *error = nil;
    [fileManager removeItemAtPath:offlineFilePath error:&error];//删除离线的关键代码
    if ([fileManager fileExistsAtPath:offlineFilePath]) {
        NSLog(@"111");
        NSLog(@"offlineFilePath2 = %@",offlineFilePath);
    }else{
        NSLog(@"111");
        NSLog(@"offlineFilePath_error2 = %@",offlineFilePath);
    }
    [self deleteDownLoadCount:temp_series_id];
    if(_indexPath != nil){
        [self.delegate operateHandler:-1 androw:-1 type:@"refresh"];
    }
}

- (void)updateProgressWithCurrentRead:(long long)totalBytesRead totalSize:(long long) totalBytesExpectedToRead andSeriesId:(long)seriesId{
    BOOL isDownload = judgeOfflineSeriesIsDownload([[NSString alloc] initWithFormat:@"%ld",seriesId]);
    if (totalBytesExpectedToRead > 0
        && _series_id == seriesId ) {
        if(!isDownload){
            [_operationButton setImage:[UIImage imageNamed:@"download_start"] forState:UIControlStateNormal];
            _statusLabel.text = NSLocalizedString(@"离线阅读",nil);
        }else{
            if(!_haveLoadData){
                [self operationButtonClicked:nil];
            }
            [self.operationButton setImage:[UIImage imageNamed:@"download_finished"] forState:UIControlStateNormal];
            self.statusLabel.text = kHaveDownloadTips;
            _operationButton.hidden = YES;
            _statusLabel.hidden = YES;
            _progressView.hidden = NO;
            _cancelBtn.hidden = NO;
            float progressValue = ((float)totalBytesRead/(float)totalBytesExpectedToRead);
            _progressView.progress = progressValue;
            //怎么去判断有没有下载过？
//            SDWebImageManager *manager = [SDWebImageManager sharedManager];
//            diskImageExistsForURL
        }
    }
}

//- (void)downloadSuccess{
//    [_operationButton setImage:[UIImage imageNamed:@"download_finished"] forState:UIControlStateNormal];
//    _statusLabel.text = kHaveDownloadTips;
//    _cancelBtn.hidden = YES;
//    _operationButton.hidden = NO;
//    _statusLabel.hidden = NO;
//    _progressView.hidden = YES;
//}
#pragma 下载图片序列 及 计数
-(NSArray *)checkImagesDownloadAll{
    NSInteger tmptotalImageCount = 0;
    NSInteger tmploadImageCount = 0;
    NSString *folderName = [NSString stringWithFormat:@"%li",_series_id];
    NSString *offlineFilePath = [yyjOfflineSeriesDirectory() stringByAppendingPathComponent:folderName];
    NSString *imgsJsonPath = [offlineFilePath stringByAppendingPathComponent:@"imgs.json"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:imgsJsonPath]) {
        NSData *data = [NSData dataWithContentsOfFile:imgsJsonPath];
        if (data) {
            NSError* error;
            NSDictionary* json = [NSJSONSerialization
                                  JSONObjectWithData:data
                                  options:NSJSONReadingAllowFragments
                                  error:&error];
            
            NSArray *countArr =nil;
            countArr = [self requestUrls:json andSuffix:kStyleColorImageCover andType:@"color" andOperate:1];
            tmploadImageCount += [[countArr objectAtIndex:0] integerValue];
            tmptotalImageCount += [[countArr objectAtIndex:1] integerValue];
            countArr = [self requestUrls:json andSuffix:kStyleCover andType:@"album" andOperate:1];
            tmploadImageCount += [[countArr objectAtIndex:0] integerValue];
            tmptotalImageCount += [[countArr objectAtIndex:1] integerValue];
            countArr = [self requestUrls:json andSuffix:kStyleDetailCover andType:@"style" andOperate:1];
            tmploadImageCount += [[countArr objectAtIndex:0] integerValue];
            tmptotalImageCount += [[countArr objectAtIndex:1] integerValue];
            countArr = [self requestUrls:json andSuffix:kLookBookImage andType:@"lookBook" andOperate:1];
            tmploadImageCount += [[countArr objectAtIndex:0] integerValue];
            tmptotalImageCount += [[countArr objectAtIndex:1] integerValue];

        }
        
    }
    return @[@(tmploadImageCount),@(tmptotalImageCount)];
}

-(void)downloadOfflineImages:(NSInteger)seriesID{
    //读取本地的离线数据
    _loadImageCount = 0;
    _totalImageCount = 0;
    NSString *folderName = [NSString stringWithFormat:@"%ld",(long)seriesID];
    NSString *offlineFilePath = [yyjOfflineSeriesDirectory() stringByAppendingPathComponent:folderName];
    NSString *imgsJsonPath = [offlineFilePath stringByAppendingPathComponent:@"imgs.json"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:imgsJsonPath]) {
        NSData *data = [NSData dataWithContentsOfFile:imgsJsonPath];
        if (data) {
            NSError* error;
            NSDictionary* json = [NSJSONSerialization
                                  JSONObjectWithData:data
                                  options:NSJSONReadingAllowFragments
                                  error:&error];
            NSArray *countArr =nil;
            countArr = [self requestUrls:json andSuffix:kStyleColorImageCover andType:@"color" andOperate:0];
            _loadImageCount += [[countArr objectAtIndex:0] integerValue];
            _totalImageCount += [[countArr objectAtIndex:1] integerValue];
            countArr = [self requestUrls:json andSuffix:kStyleCover andType:@"album" andOperate:0];
            _loadImageCount += [[countArr objectAtIndex:0] integerValue];
            _totalImageCount += [[countArr objectAtIndex:1] integerValue];
            countArr = [self requestUrls:json andSuffix:kStyleDetailCover andType:@"style" andOperate:0];
            _loadImageCount += [[countArr objectAtIndex:0] integerValue];
            _totalImageCount += [[countArr objectAtIndex:1] integerValue];
            countArr = [self requestUrls:json andSuffix:kLookBookImage andType:@"lookBook" andOperate:0];
            _loadImageCount += [[countArr objectAtIndex:0] integerValue];
            _totalImageCount += [[countArr objectAtIndex:1] integerValue];
            NSLog(@"111");
        }

    }
    [self addDownLoadCount:@[@(_loadImageCount),@(_totalImageCount)]];
    [self updateUI];
}

-(NSArray *)requestUrls:(NSDictionary *)source andSuffix:(NSString *)imageSuffix andType:(NSString *)type andOperate:(NSInteger)operate{
    NSString *storePath = nil;
    __block NSURL *imageUrl = nil;
    __block NSInteger tmploadImageCount = 0;
    __block NSInteger tmptotalImageCount = 0;
    NSArray *urls = [source objectForKey:type];

    for (NSString * imageRelativePath in urls) {
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        imageUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",imageRelativePath,imageSuffix]];
        BOOL isExists = [manager diskImageExistsForURL:imageUrl];
        if(operate == 0){
            if(!isExists){//下载
                NSLog(@"downloadImageUrl:%@%@",imageRelativePath,imageSuffix);
                [_delegate downloadImages:imageUrl andStorePath:storePath];
            }else{
                NSLog(@"downloadComplete");
                tmploadImageCount ++;
            }
        }else if(operate == 1){//请求
            if(isExists){
                tmploadImageCount ++;
            }
        }else if(operate == 2){//删除
            if(isExists){
                //删我就不删了 我就不让他下载
//                NSFileManager *fileManager = [NSFileManager defaultManager];
//                [fileManager removeItemAtPath:storePath error:nil];
            }
        }
        tmptotalImageCount ++;
    }

    return @[@(tmploadImageCount),@(tmptotalImageCount)];
}

- (void)updateUI{
    if(_series_id == 543){
        NSLog(@"111");
    }
//    155 44
    [_operationButton setEnlargeEdgeWithTop:0 right:111 bottom:0 left:0];
    
    NSString *imgStr = @"";
    
    if([LanguageManager isEnglishLanguage]){
        imgStr = @"draftflag_en_img";
    }else{
        imgStr = @"draftflag_img";
    }
    [_statusDraftImage setImage:[UIImage imageNamed:imgStr]];
    
    [_statusLabel setAdjustsFontSizeToFitWidth:YES];
    if (_title) {
        _titleLabel.text = _title;
        _titleLabel.numberOfLines = 0;
        CGRect rect = [_titleLabel.text boundingRectWithSize:CGSizeMake(205, 78) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:20]} context:nil];
        _titleLableHeightLayoutConstraint.constant = rect.size.height+1;
    }
    
    if (_produce) {
        _produceLabel.text = _produce;
    }
    
    if (_styleAmount) {
        _styleAmountLabel.text = _styleAmount;
    }
    
    if (_order) {
        _orderLabel.text = _order;
    }
    
    _outTimerViewLayoutleftConstriant1.constant = getWidthWithHeight(30, _produce, _produceLabel.font) + 12;
    _outTimerViewLayoutleftConstriant2.constant = getWidthWithHeight(30, _order, _orderLabel.font) + 12;
    if(_compareResult1 == NSOrderedAscending){
        _outTimeFlagView1.hidden = NO;
    }else{
        _outTimeFlagView1.hidden = YES;
    }
    if(_compareResult2 == NSOrderedAscending){
        _outTimeFlagView2.hidden = NO;
    }else{
        _outTimeFlagView2.hidden = YES;
    }
    
    if (self.supplyStatus == 0) {
        self.deliveryLabel.text = NSLocalizedString(@"现货", nil);
    }else {
        self.deliveryLabel.text = NSLocalizedString(@"期货", nil);
    }
    
    _progressView.progressTintColor = [UIColor colorWithHex:@"ed6498"];
    _progressView.trackTintColor = [UIColor colorWithHex:@"efefef"];
    _progressView.layer.borderColor = [UIColor colorWithHex:@"efefef"].CGColor;
    _progressView.layer.borderWidth = 5;
    _progressView.layer.cornerRadius = 6;
    _progressView.layer.masksToBounds = YES;
    
    _coverImageView.contentMode = UIViewContentModeScaleAspectFit;
    _coverImageView.backgroundColor = [UIColor colorWithHex:kDefaultImageColor];
    
    //_coverImageView.layer.borderColor = [UIColor blackColor].CGColor;
    //_coverImageView.layer.borderWidth = 1;
    
    
    if (_imageRelativePath) {
        _coverImageView.contentMode = UIViewContentModeScaleAspectFit;
        sd_downloadWebImageWithRelativePath(YES, _imageRelativePath, _coverImageView, kSeriesCover, UIViewContentModeScaleAspectFit);
        
    }
    
    _operationButton.hidden = YES;
    _statusLabel.hidden = YES;
    
    _progressView.hidden = YES;
    _startBtn.hidden = NO;
    _cancelBtn.hidden = YES;
    _totalImageCount = 0;
    _loadImageCount = 0;
    _statusLabel.textColor = [UIColor colorWithHex:@"919191"];
    if(_status == kOpusDraft){
        _statusDraftImage.hidden = NO;
        [_startBtn setImage:[UIImage imageNamed:@"opuspublish_icon"] forState:UIControlStateNormal];
    }else{
        _statusDraftImage.hidden = YES;
        if(_authType == kAuthTypeBuyer){
            [_startBtn setImage:[UIImage imageNamed:@"pub_status_buyer1"] forState:UIControlStateNormal];
        }else if (_authType == kAuthTypeMe){
            [_startBtn setImage:[UIImage imageNamed:@"pub_status_me1"] forState:UIControlStateNormal];
        }else if(_authType == kAuthTypeAll){
            [_startBtn setImage:[UIImage imageNamed:@"pub_status_all1"] forState:UIControlStateNormal];
        }else if(_authType >= kAuthTypeDefined){
            [_startBtn setImage:[UIImage imageNamed:@"pub_status_defined1"] forState:UIControlStateNormal];
        }
    }
    if (_supplyStatus == 0) {
        _orderLabelTopLayoutConstraint.constant = 5;
        _dateRangeLabel.text = @"";
    }else{
        _orderLabelTopLayoutConstraint.constant = 5+19;
        _dateRangeLabel.text = [NSString stringWithFormat:NSLocalizedString(@"分%d个波段",nil),_dateRangeAmount];
    }

    //判断有没有下载过离线包
    if (_series_id > 0) {
        _operationButton.hidden = NO;
        _statusLabel.hidden = NO;
        _statusLabel.text = @"";
        
        NSString *folderName = [NSString stringWithFormat:@"%li",_series_id];
        NSString *offlineFilePath = [yyjOfflineSeriesDirectory() stringByAppendingPathComponent:folderName];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL fileExists = [fileManager fileExistsAtPath:offlineFilePath];
        if (fileExists || ([self checkOperation:_series_id] != nil )) {
            //已经下载过
            NSArray *countInfo = [self getDownLoadCount:_series_id];
            if(countInfo != nil){
                self.loadImageCount = [[countInfo objectAtIndex:0] integerValue];
                self.totalImageCount = [[countInfo objectAtIndex:1] integerValue];
                [self updateProgressUI];
            }
            //thread 更新
            __block long blockSeriesId = _series_id;
            WeakSelf(ws);
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSArray *countArr = [ws checkImagesDownloadAll];
                [ws addDownLoadCount:countArr];
                if(blockSeriesId == ws.series_id){
                    ws.loadImageCount = [[countArr objectAtIndex:0] integerValue];
                    ws.totalImageCount = [[countArr objectAtIndex:1] integerValue];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [ws updateProgressUI];
                    });
                }
            });
        }else{
            [_operationButton setImage:[UIImage imageNamed:@"download_start"] forState:UIControlStateNormal];
            _statusLabel.text = NSLocalizedString(@"离线阅读",nil);
        }
        
    }

}

-(void)updateProgressUI{
    [self.operationButton setImage:[UIImage imageNamed:@"download_finished"] forState:UIControlStateNormal];
    self.statusLabel.text = kHaveDownloadTips;
    if(self.totalImageCount > 0  && self.loadImageCount >= self.totalImageCount){
//        下载完成
        self.statusLabel.text = kHaveDownloadTips;
//        BOOL haveTempSeriesID = [YYUser haveTempSeriesID:_series_id];
        [YYUser deleteTempSeriesID:_series_id];
//        if(haveTempSeriesID){
//            if(_modifySuccess){
//                _modifySuccess();
//            }
//        }
        
    }else{
//        下载中
        if(self.totalImageCount > 0){
//            [self updateProgressWithCurrentRead:self.totalImageCount+self.loadImageCount totalSize:self.totalImageCount+self.totalImageCount andSeriesId:self.series_id];
            [self updateProgressWithCurrentRead:self.loadImageCount totalSize:self.totalImageCount andSeriesId:self.series_id];
        }else{
            [self updateProgressWithCurrentRead:1 totalSize:2 andSeriesId:self.series_id];
        }
    }

}

- (IBAction)startDownloadImgs:(id)sender {


    YYUser *user = [YYUser currentUser];
    // 获取subshowroom的权限列表, 首先是判断showroom子账号
    if (user.userType == kShowroomSubType) {
        // 如果没有品牌操作权限，就不能操作
        YYSubShowroomUserPowerModel *subShowroom = [YYSubShowroomUserPowerModel shareModel];
        if (!subShowroom.isBrandAction) {
            [YYToast showToastWithTitle:NSLocalizedString(@"您的账号没有该操作权限！", nil) andDuration:kAlertToastDuration];
            return;
        }
    }

    NSLog(@"_status = %ld",(long)_status);
    if(_status == kOpusPublish){
        NSInteger menuUIWidth = 170;
        NSInteger menuUIHeight = 183;
        UIViewController *controller = [[UIViewController alloc] init];
        controller.view.frame = CGRectMake(0, 0, menuUIWidth, menuUIHeight);
        //[self setMenuUI_pad:controller.view];
        setMenuUI_pad(self,controller.view,@[@[@"menu_pub_status_buyer1|menu_pub_status_buyer",NSLocalizedString(@"合作买手店可见",nil)],@[@"menu_pub_status_me1|menu_pub_status_me",NSLocalizedString(@"仅自己可见",nil)],@[@"menu_pub_status_all1|menu_pub_status_all",NSLocalizedString(@"公开",nil)],@[@"menu_pub_status_defined1|menu_pub_status_defined",NSLocalizedString(@"自定义查看权限",nil)]]);
            
        //设置自动按钮
        UIButton *definedBtn = [controller.view viewWithTag:4];
        __block UIButton *blockdefinedBtnl = definedBtn;
        definedBtn.userInteractionEnabled = NO;
        //definedBtn.alpha = 0.5;
        [definedBtn setTitleColor:[UIColor colorWithHex:@"919191"] forState:UIControlStateNormal];

        [YYConnApi getConnBuyers:1 pageIndex:1 pageSize:1 andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYConnBuyerListModel *listModel, NSError *error) {
            if(rspStatusAndMessage.status == kCode100){
                if(listModel && [listModel.result count] > 0){
                    blockdefinedBtnl.userInteractionEnabled = YES;
                    //blockdefinedBtnl.alpha = 1;
                    [blockdefinedBtnl setTitleColor:[UIColor colorWithHex:@"000000"] forState:UIControlStateNormal];
                }
            }
        }];
        
        
        UIPopoverController *popController = [[UIPopoverController alloc] initWithContentViewController:controller];
        _popController = popController;
        CGPoint p = [self convertPoint:self.startBtn.center toView:[self.delegate getview]];
        CGRect rc = CGRectZero;
        popController.popoverContentSize = CGSizeMake(menuUIWidth,menuUIHeight);
        popController.popoverBackgroundViewClass = [YYPopoverArrowBackgroundView class];

        if((p.y+ menuUIHeight) > SCREEN_HEIGHT){
            rc = CGRectMake(p.x, p.y -CGRectGetHeight(self.startBtn.frame)/2, 0, 0);
            [popController presentPopoverFromRect:rc inView:[self.delegate getview] permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];

        }else{
            rc = CGRectMake(p.x, p.y+CGRectGetHeight(self.startBtn.frame)/2, 0, 0);
            [popController presentPopoverFromRect:rc inView:[self.delegate getview] permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];

        }
        _tmpMenuBtn = sender;
    }else{
        if(self.delegate){//[self.delegate getview]
            if(_indexPath != nil){
                [self.delegate operateHandler:_indexPath.section androw:_indexPath.row type:@"updatePubStatus"];
            }
        }
        
    }
}

- (IBAction)cancelDownLoadRequests:(id)sender {
    WeakSelf(ws);
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.delegate_series_id = [NSNumber numberWithLong:_series_id];
    CMAlertView *alertView = [[CMAlertView alloc] initWithTitle:NSLocalizedString(@"确认要删除离线包",nil) message:nil needwarn:NO delegate:nil cancelButtonTitle:NSLocalizedString(@"取消",nil) otherButtonTitles:@[[NSString stringWithFormat:@"%@|000000",NSLocalizedString(@"确认",nil)]]];
    //alertView.specialParentView = [self.delegate getview];
    [alertView setAlertViewBlock:^(NSInteger selectedIndex){
        if (selectedIndex == 1) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [ws deleteOffinePackage:YES];
            });
        }
    }];
    [alertView show];
}
@end

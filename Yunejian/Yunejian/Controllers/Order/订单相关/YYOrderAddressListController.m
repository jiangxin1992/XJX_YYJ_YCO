//
//  YYOrderAddressListController.m
//  Yunejian
//
//  Created by Apple on 15/10/26.
//  Copyright © 2015年 yyj. All rights reserved.
//

#import "YYOrderAddressListController.h"
#import "YYOrderAddressListCell.h"
#import "YYUserApi.h"
@implementation YYOrderAddressListController

-(void)viewDidLoad{
    _textNameInput.delegate = self;
    _myTableView.delegate = self;
    _myTableView.dataSource = self;
    
    [self addObserverForKeyboard];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}

-(void)loadBuyerList:(NSString *)queryStr{
    WeakSelf(ws);
    __block NSString *blockQueryStr = queryStr;
    [YYUserApi queryBuyer:queryStr andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYBuyerListModel *buyerList, NSError *error) {
        if (rspStatusAndMessage.status == YYReqStatusCode100) {
            ws.buyerList = buyerList;
            if(_needUnDefineBuyer){
            self.buyerModel = [self getBuyerModel:_textNameInput.text];
            if(self.buyerModel == nil){
                self.buyerModel = [[YYBuyerModel alloc] init];
                self.buyerModel.name = blockQueryStr;
                self.buyerModel.contactEmail = nil;
                NSMutableArray *tmpArray = [[NSMutableArray alloc] init];
                [tmpArray addObject:self.buyerModel];
                [tmpArray addObjectsFromArray:buyerList.result];
                ws.buyerList.result = tmpArray;
            }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                //NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                //[_weakSelf.myTableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
                [ws.myTableView reloadData];
                //[_weakSelf.myTableView deselectRowAtIndexPath:indexPath animated:YES];

            });
        }
    }];
}

- (IBAction)closeHandler:(id)sender {
    if(self.cancelButtonClicked){
        self.cancelButtonClicked();
    }
}

- (IBAction)makeSureHandler:(id)sender {
    if (self.makeSureButtonClicked && ![_textNameInput.text isEqualToString:@""]) {
       // YYBuyerModel *infoModel =[self getBuyerModel:_textNameInput.text];
        self.makeSureButtonClicked(_textNameInput.text,self.buyerModel);
    }
}
#pragma mark - UITextFieldDelegate

//- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
//{
//    NSString *toBeString = textField.text;
//    NSString *lang = [[UIApplication sharedApplication] textInputMode].primaryLanguage; // 键盘输入模式
//    NSString *str = @"";
//    if ([lang isEqualToString:@"zh-Hans"]) { // 简体中文输入，包括简体拼音，健体五笔，简体手写
//        UITextRange *selectedRange = [textField markedTextRange];
//        //高亮部分
//        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
//        //已输入的文字进行字数统计和限制
//        if (!position) {
//            str = toBeString;
//        }else{
//            return YES;
//        }
//    }
//    else{
//        str = [toBeString stringByReplacingCharactersInRange:range withString:string];;
//    }
//    
////  NSString *str = [textField.text stringByReplacingCharactersInRange:range withString:string];
////  self.currentYYOrderInfoModel.buyerName = str;
//    if(![str isEqualToString:@""]){
//        [self loadBuyerList:str];
//    }else{
//        self.buyerList = nil;
//        self.buyerModel = nil;
//        [self.myTableView reloadData];
//    }
//    return YES;
//}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UITextFieldTextDidChangeNotification object:_textNameInput];

}

-(void) textFieldDidBeginEditing:(UITextField *)textField{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:_textNameInput];

    self.layoutTopConstraints.constant = 63;
}

- (void)addObserverForKeyboard{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)textFieldDidChange:(NSNotification *)note
{
    //可以用note.object来获取产生该消息的UITextField
//    if (_textNameInput.text.length > 0) {
//        int utfCode = 0;
//        void *buffer = &utfCode;
//        NSRange range = NSMakeRange(_textNameInput.text.length - 1, 1);
//        NSString *word = [_textNameInput.text substringWithRange:range];
//        BOOL b = [word getBytes:buffer maxLength:2 usedLength:NULL encoding:NSUTF16LittleEndianStringEncoding options:NSStringEncodingConversionExternalRepresentation range:range remainingRange:NULL];
//        if (b && (utfCode >= 0x4e00 && utfCode <= 0x9fa5)) {
//            NSLog(@"it is chinese,%@", word);
//        }
//    }
        NSString *toBeString = _textNameInput.text;
        NSString *lang = [[UIApplication sharedApplication] textInputMode].primaryLanguage; // 键盘输入模式
        NSString *str = @"";
        if ([lang isEqualToString:@"zh-Hans"]) { // 简体中文输入，包括简体拼音，健体五笔，简体手写
            UITextRange *selectedRange = [_textNameInput markedTextRange];
            //高亮部分
            UITextPosition *position = [_textNameInput positionFromPosition:selectedRange.start offset:0];
            //已输入的文字进行字数统计和限制
            if (!position) {
                str = toBeString;
            }else{
                return ;
            }
        }
        else{
            str = toBeString;
        }
    //    NSString *str = _textNameInput.text;
    //  self.currentYYOrderInfoModel.buyerName = str;
        if(![str isEqualToString:@""]){
            [self loadBuyerList:str];
        }else{
            self.buyerList = nil;
            self.buyerModel = nil;
            [self.myTableView reloadData];
        }
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}


- (void)keyboardWillHide:(NSNotification *)note
{
    //134
    self.layoutTopConstraints.constant = 163;
}

-(YYBuyerModel * )getBuyerModel:(NSString *)str{
    NSArray *txtArr = [str componentsSeparatedByString:@"|"];
    if (_buyerList && _buyerList.result && [_buyerList.result count] >0) {
        for (YYBuyerModel *infoModel in _buyerList.result) {
            for (NSString *txt in txtArr) {
                if([infoModel.contactName isEqualToString:txt] || [infoModel.contactEmail isEqualToString:txt]){
                    return infoModel;
                }
            }
        }
    }
    return nil;
}
#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return 1;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (_buyerList
        && _buyerList.result) {
        return [_buyerList.result count];
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //UITableViewCell *cell = [[UITableViewCell alloc] init];
    static NSString* reuseIdentifier = @"YYOrderAddressListCell";
    YYOrderAddressListCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    YYBuyerModel *infoModel = [self.buyerList.result objectAtIndex:indexPath.section];
    cell.curModel = _buyerModel;
    cell.infoModel = infoModel;
    [cell updateUI];
    return cell;
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    return 35;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 10;
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *footer = [[UIView alloc] init];
    footer.backgroundColor = [UIColor whiteColor];
    return footer;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [_textNameInput resignFirstResponder];
    YYBuyerModel *infoModel = [self.buyerList.result objectAtIndex:indexPath.section];
    self.buyerModel = infoModel;
    [self.myTableView reloadData];
//    _textNameInput.text = [NSString stringWithFormat:@"%@|%@",infoModel.contactName,infoModel.contactEmail];
}

@end

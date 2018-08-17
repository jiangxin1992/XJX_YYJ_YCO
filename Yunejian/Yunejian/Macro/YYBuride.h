//
//  YYBuride.h
//  Yunejian
//
//  Created by chjsun on 2017/7/20.
//  Copyright © 2017年 yyj. All rights reserved.
//



#ifndef YYBuride_h
#define YYBuride_h

#import <UMMobClick/MobClick.h>

#define currentServerUrlRelease(monitor, placeholder) [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] containsString:@"http://ycosystem.com"]? monitor: placeholder


// showRoom的主页
#define kYYPageShowroomMain currentServerUrlRelease(@"YYShowroomMain", @"not-release")
// 设计师的主页
#define kYYPageMain currentServerUrlRelease(@"YYMain", @"not-release")
// 设置页面
#define kYYPageSetting currentServerUrlRelease(@"YYSetting", @"not-release")
// 设计师的信息展示页面（设计师主页的第一个界面）
#define kYYPageIndex currentServerUrlRelease(@"YYIndex", @"not-release")
// 设计师作品列表（设计师主页的第二个界面）
#define kYYPageOpusList currentServerUrlRelease(@"YYOpus", @"not-release")
// 订单列表（设计师主页的第三个界面）
#define kYYPageOrderList currentServerUrlRelease(@"YYOrderList", @"not-release")
// 设计师某系列列表
#define kYYPageStyleDetailList currentServerUrlRelease(@"YYStyleDetailList", @"not-release")
// 设计师某系列单个产品详情
#define kYYPageStyleDetail currentServerUrlRelease(@"YYStyleDetail", @"not-release")
// 购物车
#define kYYPageCartDetail currentServerUrlRelease(@"YYCartDetail", @"not-release")
// 订单详情
#define kYYPageOrderDetail currentServerUrlRelease(@"YYOrderDetail", @"not-release")
// 订单修改记录
#define kYYPageOrderModifyLogList currentServerUrlRelease(@"YYOrderModifyLogList", @"not-release")
// 用户账户
#define kYYPageAccountDetail currentServerUrlRelease(@"YYAccountDetail", @"not-release")


/// ---------- Register start ----------
// 设计师入驻申请
#define kYYPageRegisterDesignerType currentServerUrlRelease(@"YYRegister_DesignerType", @"not-release")
// 买手店注册
#define kYYPageRegisterBuyerStorUserType currentServerUrlRelease(@"YYRegister_BuyerStorUserType", @"not-release")
// 品牌信息审核
#define kYYPageRegisterBrandRegisterType currentServerUrlRelease(@"YYRegister_BrandRegisterType", @"not-release")
// 买手店身份审核
#define kYYPageRegisterBuyerRegisterType currentServerUrlRelease(@"YYRegister_BuyerRegisterType", @"not-release")
// (首页) -> 编辑我的主页信息
#define kYYPageRegisterBrandInfoType currentServerUrlRelease(@"YYRegister_BrandInfoType", @"not-release")
// 找回密码
#define kYYPageRegisterForgetPasswordType currentServerUrlRelease(@"YYRegister_ForgetPasswordType", @"not-release")
// 忘记密码
#define kYYPageRegisterOtherElse currentServerUrlRelease(@"YYRegister_OtherElse", @"not-release")
/// ---------- Register  end  ----------


// 消息列表
#define kYYPageOrderMessage currentServerUrlRelease(@"YYOrderMessage", @"not-release")


/// ---------- OrderModify  start  ----------
// 创建订单
#define kYYPageOrderModifyCreate currentServerUrlRelease(@"YYOrderModify_create", @"not-release")
// 修改订单
#define kYYPageOrderModifyUpdate currentServerUrlRelease(@"YYOrderModify_update", @"not-release")
// 追单补货
#define kYYPageOrderModifyAddTo currentServerUrlRelease(@"YYOrderModify_addTo", @"not-release")
/// ---------- OrderModify  end  ----------


/// ---------- Shopping 添加到购物车弹出的键盘 start  ----------
// 修改款式数量
#define kYYPageShoppingUpdate currentServerUrlRelease(@"YYShopping_update", @"not-release")
// 填写加入购物车数量
#define kYYPageShoppingCreate currentServerUrlRelease(@"YYShopping_create", @"not-release")
/// ---------- Shopping 添加到购物车弹出的键盘 end  ----------


/// ---------- Protocol start  ----------
// 展示网页信息（隐私权保护声明, 服务协议）
#define kYYPageProtocolAgreement currentServerUrlRelease(@"YYProtocol_agreement", @"not-release")
// 展示代理协议
#define kYYPageProtocolAgent currentServerUrlRelease(@"YYProtocol_agent", @"not-release")
/// ---------- Protocol  end   ----------

// 邀请合作买手店 - 列表
#define kYYPageConnAdd currentServerUrlRelease(@"YYConnAdd", @"not-release")
// 买手店详情
#define kYYPageConnBuyerInfo currentServerUrlRelease(@"YYConnBuyerInfo", @"not-release")
// 我的买手店
#define kYYPageConnBuyerList currentServerUrlRelease(@"YYConnBuyerList", @"not-release")
// 合作消息
#define kYYPageConnMsgList currentServerUrlRelease(@"YYConnMsgList", @"not-release")
// 忘记密码
#define kYYPageForgetPassword currentServerUrlRelease(@"YYForgetPassword", @"not-release")
// 登录
#define kYYPageLogin currentServerUrlRelease(@"YYLogin", @"not-release")
// 设计师申请入住结果页
#define kYYPageRegisterResult currentServerUrlRelease(@"YYRegisterResult", @"not-release")
// 产品介绍页（安装后的三张介绍）
#define kYYPageIntroduction currentServerUrlRelease(@"YYIntroduction", @"not-release")
// 收款纪录
#define kYYPageOrderPayLog currentServerUrlRelease(@"YYOrderPayLog", @"not-release")

#endif /* YYBuride_h */

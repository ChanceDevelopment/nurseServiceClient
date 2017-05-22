//
//  HeProtectedUserInfoVC.h
//  nurseService
//
//  Created by Tony on 2017/1/10.
//  Copyright © 2017年 iMac. All rights reserved.
//  受护人信息视图控制器

#import "HeBaseViewController.h"

//选择受护人信息的协议
@protocol SelectProtectUserInfoProtocol <NSObject>

- (void)selectUserInfoWithDict:(NSDictionary *)userInfo;

@end

@interface HeProtectedUserInfoVC : HeBaseViewController
//选择受护人信息的代理
@property(assign,nonatomic)id<SelectProtectUserInfoProtocol>selectDelegate;
//是否来自下单页面，如果是，需要回调代理方法
@property(assign,nonatomic) BOOL isFromOrder;

@end

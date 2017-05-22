//
//  HeSelectProtectedUserInfoVC.h
//  nurseService
//
//  Created by Tony on 2017/1/16.
//  Copyright © 2017年 iMac. All rights reserved.
//  选择受护人信息视图控制器

#import "HeBaseViewController.h"

//选择受护人信息协议
@protocol SelectProtectUserInfoProtocol <NSObject>
//userInfo：受护人的信息
- (void)selectUserInfoWithDict:(NSDictionary *)userInfo;

@end

@interface HeSelectProtectedUserInfoVC : HeBaseViewController
//选择受护人的代理
@property(assign,nonatomic)id<SelectProtectUserInfoProtocol>selectDelegate;

@end

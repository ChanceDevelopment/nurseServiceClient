//
//  HeProtectedUserInfoVC.h
//  nurseService
//
//  Created by Tony on 2017/1/10.
//  Copyright © 2017年 iMac. All rights reserved.
//

#import "HeBaseViewController.h"

@protocol SelectProtectUserInfoProtocol <NSObject>

- (void)selectUserInfoWithDict:(NSDictionary *)userInfo;

@end

@interface HeProtectedUserInfoVC : HeBaseViewController
@property(assign,nonatomic)id<SelectProtectUserInfoProtocol>selectDelegate;

@end

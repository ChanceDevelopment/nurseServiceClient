//
//  HeSelectProtectedUserInfoVC.h
//  nurseService
//
//  Created by Tony on 2017/1/16.
//  Copyright © 2017年 iMac. All rights reserved.
//

#import "HeBaseViewController.h"

@protocol SelectProtectUserInfoProtocol <NSObject>

- (void)selectUserInfoWithDict:(NSDictionary *)userInfo;

@end

@interface HeSelectProtectedUserInfoVC : HeBaseViewController
@property(assign,nonatomic)id<SelectProtectUserInfoProtocol>selectDelegate;

@end

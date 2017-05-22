//
//  HeAddProtectUserAddressVC.h
//  nurseService
//
//  Created by Tony on 2017/1/10.
//  Copyright © 2017年 iMac. All rights reserved.
//  添加受护人地址视图控制器

#import "HeBaseViewController.h"

//添加受护人地址协议
@protocol AddProtectUserAddressProtocol <NSObject>

- (void)addProtectUserAddressWithAddressInfo:(NSDictionary *)addressInfo;

@end


@interface HeAddProtectUserAddressVC : HeBaseViewController
//添加受护人地址代理
@property(assign,nonatomic)id<AddProtectUserAddressProtocol>addressDelegate;

@end

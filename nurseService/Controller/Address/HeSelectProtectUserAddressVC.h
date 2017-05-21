//
//  HeSelectProtectUserAddressVC.h
//  nurseService
//
//  Created by Tony on 2017/1/10.
//  Copyright © 2017年 iMac. All rights reserved.
//  选择用户地址视图控制器

#import "HeBaseViewController.h"

//选择地址的协议
@protocol SelectAddressProtocol <NSObject>

- (void)selectAddressWithAddressInfo:(NSDictionary *)addressDcit;

@end

@interface HeSelectProtectUserAddressVC : HeBaseViewController
//选择地址的代理
@property(assign,nonatomic)id <SelectAddressProtocol>addressDeleage;

@end

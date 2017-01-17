//
//  HeAddProtectUserAddressVC.h
//  nurseService
//
//  Created by Tony on 2017/1/10.
//  Copyright © 2017年 iMac. All rights reserved.
//

#import "HeBaseViewController.h"

@protocol AddProtectUserAddressProtocol <NSObject>

- (void)addProtectUserAddressWithAddressInfo:(NSDictionary *)addressInfo;

@end


@interface HeAddProtectUserAddressVC : HeBaseViewController
@property(assign,nonatomic)id<AddProtectUserAddressProtocol>addressDelegate;

@end

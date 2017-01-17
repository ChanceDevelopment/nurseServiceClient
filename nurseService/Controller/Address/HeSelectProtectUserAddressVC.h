//
//  HeSelectProtectUserAddressVC.h
//  nurseService
//
//  Created by Tony on 2017/1/10.
//  Copyright © 2017年 iMac. All rights reserved.
//

#import "HeBaseViewController.h"

@protocol SelectAddressProtocol <NSObject>

- (void)selectAddressWithAddressInfo:(NSDictionary *)addressDcit;

@end

@interface HeSelectProtectUserAddressVC : HeBaseViewController
@property(assign,nonatomic)id <SelectAddressProtocol>addressDeleage;

@end

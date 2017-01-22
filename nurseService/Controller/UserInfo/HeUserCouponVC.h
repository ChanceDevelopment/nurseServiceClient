//
//  HeUserCouponVC.h
//  nurseService
//
//  Created by Tony on 2017/1/11.
//  Copyright © 2017年 iMac. All rights reserved.
//

#import "HeBaseViewController.h"

@protocol SelectCouponDelegate <NSObject>

- (void)selectCouponWithOrder:(NSDictionary *)orderDict;

@end

@interface HeUserCouponVC : HeBaseViewController
@property(strong,nonatomic)NSDictionary *orderDict;
@property(assign,nonatomic)id<SelectCouponDelegate>selectDelegate;

@end

//
//  HeUserCouponVC.h
//  nurseService
//
//  Created by Tony on 2017/1/11.
//  Copyright © 2017年 iMac. All rights reserved.
//  用户的优惠券视图控制器

#import "HeBaseViewController.h"

//选择优惠券的协议
@protocol SelectCouponDelegate <NSObject>

- (void)selectCouponWithOrder:(NSDictionary *)orderDict;

@end

@interface HeUserCouponVC : HeBaseViewController
//
@property(strong,nonatomic)NSDictionary *orderDict;
//选择优惠券的代理
@property(assign,nonatomic)id<SelectCouponDelegate>selectDelegate;

@end

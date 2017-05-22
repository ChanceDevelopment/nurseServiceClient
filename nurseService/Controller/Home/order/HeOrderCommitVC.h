//
//  HeOrderCommitVC.h
//  nurseService
//
//  Created by Tony on 2017/1/9.
//  Copyright © 2017年 iMac. All rights reserved.
//  订单提交视图控制器

#import "HeBaseViewController.h"

@interface HeOrderCommitVC : HeBaseViewController
//订单的ID
@property(strong,nonatomic)NSString *orderId;
//订单的信息
@property(strong,nonatomic)NSDictionary *orderDict;

@end

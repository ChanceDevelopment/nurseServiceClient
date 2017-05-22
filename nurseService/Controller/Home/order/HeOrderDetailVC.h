//
//  HeOrderDetailVC.h
//  nurseService
//
//  Created by Tony on 2017/1/3.
//  Copyright © 2017年 iMac. All rights reserved.
//  订单详情视图控制器

#import "HeBaseViewController.h"



@interface HeOrderDetailVC : HeBaseViewController
//订单的ID
@property(strong,nonatomic)NSString *orderId;
//是否已经评价
@property(assign,nonatomic)BOOL isEvaluate;
//当前订单的类型
@property(assign,nonatomic)NSInteger currentOrderType;

@end

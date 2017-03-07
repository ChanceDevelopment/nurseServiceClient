//
//  HeOrderDetailVC.h
//  nurseService
//
//  Created by Tony on 2017/1/3.
//  Copyright © 2017年 iMac. All rights reserved.
//

#import "HeBaseViewController.h"



@interface HeOrderDetailVC : HeBaseViewController
@property(strong,nonatomic)NSString *orderId;
@property(assign,nonatomic)BOOL isEvaluate;

@property(assign,nonatomic)NSInteger currentOrderType;

@end

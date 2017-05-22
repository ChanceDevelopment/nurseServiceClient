//
//  OrderViewController.h
//  nurseService
//
//  Created by 梅阳阳 on 16/12/9.
//  Copyright © 2016年 iMac. All rights reserved.
//  用户订单视图控制器

#import <UIKit/UIKit.h>
#import "HeBaseViewController.h"

@interface OrderViewController : HeBaseViewController

//提供外部方法，选择跳到某个tab
- (void)selectOrderIndex:(NSInteger)orderIndex;

@end

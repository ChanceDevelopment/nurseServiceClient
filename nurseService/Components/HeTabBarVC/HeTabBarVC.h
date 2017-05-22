//
//  HeTabBarVC.h
//  huayoutong
//
//  Created by HeDongMing on 16/3/2.
//  Copyright © 2016年 HeDongMing. All rights reserved.
//  App底部4个tab的控制器

#import "HeBaseViewController.h"
#import "RDVTabBarController.h"
#import "FirstViewController.h"
#import "NurseViewController.h"
#import "OrderViewController.h"
#import "MyViewController.h"


@interface HeTabBarVC : RDVTabBarController<UIAlertViewDelegate>

//底部4个tab的控制器
//主页
@property(strong,nonatomic)FirstViewController *homePageVC;
//护士
@property(strong,nonatomic)NurseViewController *nurseVC;
//订单
@property(strong,nonatomic)OrderViewController *orderVC;
//个人中心
@property(strong,nonatomic)MyViewController *userVC;


@end

//
//  HeTabBarVC.h
//  huayoutong
//
//  Created by HeDongMing on 16/3/2.
//  Copyright © 2016年 HeDongMing. All rights reserved.
//

#import "HeBaseViewController.h"
#import "RDVTabBarController.h"
#import "FirstViewController.h"
#import "NurseViewController.h"
#import "OrderViewController.h"
#import "MyViewController.h"


@interface HeTabBarVC : RDVTabBarController<UIAlertViewDelegate>


@property(strong,nonatomic)FirstViewController *homePageVC;
@property(strong,nonatomic)NurseViewController *nurseVC;
@property(strong,nonatomic)OrderViewController *orderVC;
@property(strong,nonatomic)MyViewController *userVC;


@end

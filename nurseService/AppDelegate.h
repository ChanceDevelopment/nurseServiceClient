//
//  AppDelegate.h
//  nurseService
//
//  Created by Tony on 16/7/29.
//  Copyright © 2016年 iMac. All rights reserved.
//  App的入口代理

#import <UIKit/UIKit.h>
#import "RESideMenu.h"
#import <BaiduMapAPI_Base/BMKBaseComponent.h>
#import "JPUSHService.h"

//极光推送的参数
static NSString *appKey = @"95b106d9684d3f5e71c9fa32";
static NSString *channel = @"AppStore";
static BOOL isProduction = YES;

@interface AppDelegate : UIResponder <UIApplicationDelegate,RESideMenuDelegate,BMKGeneralDelegate,JPUSHRegisterDelegate>

//app的窗口
@property (strong, nonatomic) UIWindow *window;
//当前的跟控制器
@property (strong, nonatomic) UIViewController *viewController;
//处理数据的队列
@property (strong, nonatomic)NSOperationQueue *queue;

@end


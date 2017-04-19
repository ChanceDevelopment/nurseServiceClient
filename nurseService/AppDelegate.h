//
//  AppDelegate.h
//  nurseService
//
//  Created by Tony on 16/7/29.
//  Copyright © 2016年 iMac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RESideMenu.h"
#import <BaiduMapAPI_Base/BMKBaseComponent.h>
#import "JPUSHService.h"

static NSString *appKey = @"95b106d9684d3f5e71c9fa32";
static NSString *channel = @"AppStore";
static BOOL isProduction = TRUE;

@interface AppDelegate : UIResponder <UIApplicationDelegate,RESideMenuDelegate,BMKGeneralDelegate,JPUSHRegisterDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UIViewController *viewController;
@property (strong, nonatomic)NSOperationQueue *queue;

@end


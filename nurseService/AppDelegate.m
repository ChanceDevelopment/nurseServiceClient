//
//  AppDelegate.m
//  nurseService
//
//  Created by Tony on 16/7/29.
//  Copyright © 2016年 iMac. All rights reserved.
//

#import "AppDelegate.h"
#import "HomeTabbarController.h"
#import "LeftViewController.h"
#import "RESideMenu.h"
#import "HeLoginVC.h"
#import "HeTabBarVC.h"
#import <SMS_SDK/SMSSDK.h>
#import "JPUSHService.h"
#include <sys/xattr.h>
#import "HeTabBarVC.h"
#import <UMMobClick/MobClick.h>
#import "HeInstructionView.h"
#import "HeLoginVC.h"
#import <ShareSDK/ShareSDK.h>
#import <ShareSDKConnector/ShareSDKConnector.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import "WXApi.h"
#import "WeiboSDK.h"
#import "BrowserView.h"
#import "TOWebViewController.h"
#import <SMS_SDK/SMSSDK.h>
#import "HeTabBarVC.h"
#import <AlipaySDK/AlipaySDK.h>

#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif

@interface AppDelegate ()<JPUSHRegisterDelegate>
@property(strong,nonatomic)NSMutableArray *cancerOrderArray;
@property(strong,nonatomic)NSArray *improcessOrderArray;
@property(strong,nonatomic)NSTimer *cancelOrderTimer;

@end

BMKMapManager* _mapManager;

@implementation AppDelegate
@synthesize queue;
@synthesize cancerOrderArray;
@synthesize improcessOrderArray;
@synthesize cancelOrderTimer;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [self initialization];
    [self launchBaiduMap];
    [self initAPServiceWithOptions:launchOptions];
    [self umengTrack];
    [self initshareSDK];
    [self performSelector:@selector(getCancelOrder) withObject:nil afterDelay:1.0];
    self.window.rootViewController = self.viewController;
    //清除缓存
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(clearImg:) object:nil];
    
    [operation setQueuePriority:NSOperationQueuePriorityNormal];
    [operation setCompletionBlock:^{
        //不上传到iCloud
        [Tool canceliClouldBackup];
    }];
    queue = [[NSOperationQueue alloc]init];
    [queue addOperation:operation];
    [queue setMaxConcurrentOperationCount:1];
    //配置根控制器
    [self loginStateChange:nil];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    return YES;
}

//初始化极光推送
- (void)initAPServiceWithOptions:(NSDictionary *)launchOptions
{
    //Required
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 10.0) {
        JPUSHRegisterEntity * entity = [[JPUSHRegisterEntity alloc] init];
        entity.types = UNAuthorizationOptionAlert|UNAuthorizationOptionBadge|UNAuthorizationOptionSound;
        [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
    }
    else if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        //可以添加自定义categories
        [JPUSHService registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge |
                                                          UIUserNotificationTypeSound |
                                                          UIUserNotificationTypeAlert)
                                              categories:nil];
    }
    else {
        //categories 必须为nil
        [JPUSHService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                          UIRemoteNotificationTypeSound |
                                                          UIRemoteNotificationTypeAlert)
                                              categories:nil];
    }
    
    //Required
    // init Push(2.1.5版本的SDK新增的注册方法，改成可上报IDFA，如果没有使用IDFA直接传nil  )
    // 如需继续使用pushConfig.plist文件声明appKey等配置内容，请依旧使用[JPUSHService setupWithOption:launchOptions]方式初始化。
    [JPUSHService setupWithOption:launchOptions appKey:appKey
                          channel:channel
                 apsForProduction:isProduction
            advertisingIdentifier:nil];
    //2.1.9版本新增获取registration id block接口。
    [JPUSHService registrationIDCompletionHandler:^(int resCode, NSString *registrationID) {
        if(resCode == 0){
            NSLog(@"registrationID获取成功：%@",registrationID);
            
        }
        else{
            NSLog(@"registrationID获取失败，code：%d",resCode);
        }
    }];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [JPUSHService registerDeviceToken:deviceToken];
}

//avoid compile error for sdk under 7.0
#ifdef __IPHONE_7_0
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    //IOS7收到推送执行的方法
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [JPUSHService handleRemoteNotification:userInfo];
    completionHandler(UIBackgroundFetchResultNoData);
    
    NSLog(@"iOS7及以上系统，收到通知:%@", userInfo);
    
    [self performSelector:@selector(receiveNotification:) withObject:userInfo afterDelay:0.5];
}
#endif

#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#pragma mark- JPUSHRegisterDelegate
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler {
    NSDictionary * userInfo = notification.request.content.userInfo;
    
    UNNotificationRequest *request = notification.request; // 收到推送的请求
    UNNotificationContent *content = request.content; // 收到推送的消息内容
    
    NSNumber *badge = content.badge;  // 推送消息的角标
    NSString *body = content.body;    // 推送消息体
    UNNotificationSound *sound = content.sound;  // 推送消息的声音
    NSString *subtitle = content.subtitle;  // 推送消息的副标题
    NSString *title = content.title;  // 推送消息的标题
    
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
        NSLog(@"iOS10 前台收到远程通知:%@", userInfo);
        [self performSelector:@selector(receiveNotification:) withObject:userInfo afterDelay:0.5];
        //        [rootViewController addNotificationCount];
        
    }
    else {
        // 判断为本地通知
        NSLog(@"iOS10 前台收到本地通知:{\nbody:%@，\ntitle:%@,\nsubtitle:%@,\nbadge：%@，\nsound：%@，\nuserInfo：%@\n}",body,title,subtitle,badge,sound,userInfo);
    }
    completionHandler(UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionSound|UNNotificationPresentationOptionAlert); // 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以设置
}

- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    UNNotificationRequest *request = response.notification.request; // 收到推送的请求
    UNNotificationContent *content = request.content; // 收到推送的消息内容
    
    NSNumber *badge = content.badge;  // 推送消息的角标
    NSString *body = content.body;    // 推送消息体
    UNNotificationSound *sound = content.sound;  // 推送消息的声音
    NSString *subtitle = content.subtitle;  // 推送消息的副标题
    NSString *title = content.title;  // 推送消息的标题
    
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
        NSLog(@"iOS10 收到远程通知:%@", userInfo);
        [self performSelector:@selector(receiveNotification:) withObject:userInfo afterDelay:0.5];
        
    }
    else {
        // 判断为本地通知
        NSLog(@"iOS10 收到本地通知:{\nbody:%@，\ntitle:%@,\nsubtitle:%@,\nbadge：%@，\nsound：%@，\nuserInfo：%@\n}",body,title,subtitle,badge,sound,userInfo);
    }
    
    completionHandler();  // 系统要求执行这个方法
}
#endif

//当接收到推送通知，并且设备激活后的处理事件
-(void)receiveNotification:(NSDictionary *)userInfo
{
    NSLog(@"receiveNotification = %@",userInfo);
    [[NSNotificationCenter defaultCenter] postNotificationName:kHanldeCancelOrderNotification object:nil];
    [self performSelector:@selector(getCancelOrder) withObject:nil afterDelay:1.0];
}

#pragma mark - login changed

- (void)loginStateChange:(NSNotification *)notification
{
    NSString *userAccount = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    BOOL haveLogin = (userAccount == nil) ? NO : YES;
    NSString *ss = [[NSUserDefaults standardUserDefaults] objectForKey:@"userAccountKey"];
//    18606519253 13136170275
    if (haveLogin) {//登陆成功加载主窗口控制器
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        
        [[UINavigationBar appearance] setTitleTextAttributes:
         [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, [UIFont systemFontOfSize:20.0], NSFontAttributeName, nil]];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
        
        HeTabBarVC *tabbarVC = [[HeTabBarVC alloc] init];
        LeftViewController *leftViewController = [[LeftViewController alloc] init];
        RESideMenu *sideMenuVC = [[RESideMenu alloc] initWithContentViewController:tabbarVC
                                                            leftMenuViewController:leftViewController
                                                           rightMenuViewController:nil];
        sideMenuVC.mainController = tabbarVC;
        sideMenuVC.menuPreferredStatusBarStyle = 1;
        sideMenuVC.delegate = self;
        sideMenuVC.contentViewShadowColor = [UIColor blackColor];
        sideMenuVC.contentViewShadowOffset = CGSizeMake(0, 0);
        sideMenuVC.contentViewShadowOpacity = 0.6;
        sideMenuVC.contentViewShadowRadius = 12;
        sideMenuVC.panGestureEnabled = NO;
//        sideMenuVC.panFromEdge = NO;
        sideMenuVC.contentViewShadowEnabled = YES;
        //是否缩小
        sideMenuVC.scaleContentView = NO;
        self.viewController = sideMenuVC;

    }
    else{
        HeLoginVC *loginVC = [[HeLoginVC alloc] init];
        CustomNavigationController *loginNav = [[CustomNavigationController alloc] initWithRootViewController:loginVC];
        self.viewController = loginNav;
    }
    self.window.rootViewController = self.viewController;
}

- (void)clearImg:(id)sender
{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *folderPath = [NSHomeDirectory() stringByAppendingString:@"/tmp"];
    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:folderPath] objectEnumerator];
    NSString* fileName;
    
    NSString *libraryfolderPath = [NSHomeDirectory() stringByAppendingString:@"/Library"];
    //    libraryfolderPath = [[NSString alloc] initWithFormat:@"libraryfolderPath = %@",libraryfolderPath];
    
    NSString* LibraryfileName = [libraryfolderPath stringByAppendingPathComponent:@"EaseMobLog"];
    childFilesEnumerator = [[manager subpathsAtPath:LibraryfileName] objectEnumerator];
    while ((fileName = [childFilesEnumerator nextObject]) != nil){
        NSString* fileAbsolutePath = [LibraryfileName stringByAppendingPathComponent:fileName];
        
        BOOL result = [manager removeItemAtPath:fileAbsolutePath error:nil];
        if (result) {
            NSLog(@"remove EaseMobLog succeed");
        }
        else{
            NSLog(@"remove EaseMobLog faild");
        }
        
    }
    
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesPath = [path objectAtIndex:0];
    childFilesEnumerator = [[manager subpathsAtPath:cachesPath] objectEnumerator];
    while ((fileName = [childFilesEnumerator nextObject]) != nil){
        NSString* fileAbsolutePath = [cachesPath stringByAppendingPathComponent:fileName];
        NSRange range = [fileAbsolutePath rangeOfString:@"umeng"];
        
        if (range.length == 0) {
            BOOL result = [manager removeItemAtPath:fileAbsolutePath error:nil];
            if (result) {
                NSLog(@"remove caches succeed");
            }
            else{
                NSLog(@"remove caches faild");
            }
        }
        
    }
}


- (void)initialization
{
    
    cancerOrderArray = [[NSMutableArray alloc] initWithCapacity:0];
    [[NSUserDefaults standardUserDefaults] setObject:@NO forKey:USERHAVELOGINKEY];
    //注册登录状态监听
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loginStateChange:)
                                                 name:KNOTIFICATION_LOGINCHANGE
                                               object:nil];
    
    
    
    [[UINavigationBar appearance] setShadowImage:[UIImage new]];
    if (ISIOS7) {
        [[UINavigationBar appearance] setTintColor:NAVTINTCOLOR];
        UIImage *navBackgroundImage = [UIImage imageNamed:@"NavBarIOS7"];
        [[UINavigationBar appearance] setBackgroundImage:navBackgroundImage forBarMetrics:UIBarMetricsDefault];
        NSDictionary *attributeDict = @{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont systemFontOfSize:20.0]};
        [[UINavigationBar appearance] setTitleTextAttributes:attributeDict];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    }
    else{
        [[UINavigationBar appearance] setTintColor:APPDEFAULTORANGE];
        
        NSDictionary *attributeDict = @{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont systemFontOfSize:20.0]};
        [[UINavigationBar appearance] setTitleTextAttributes:attributeDict];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];
        
    }
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
}

-(BOOL)isShowIntroduce
{
    NSDictionary* dic =[[NSBundle mainBundle] infoDictionary];
    /****  读取当前应用的版本号  ****/
    NSString *versionInfo = [dic objectForKey:@"CFBundleShortVersionString"];
    NSString *libraryfolderPath = [NSHomeDirectory() stringByAppendingString:@"/Library"];
    NSString *myPath = [libraryfolderPath stringByAppendingPathComponent:@"NurseClientDocument"];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:myPath]) {
        [fm createDirectoryAtPath:myPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *documentString = [myPath stringByAppendingPathComponent:@"UserData"];
    
    if(![fm fileExistsAtPath:documentString])
    {
        [fm createDirectoryAtPath:documentString withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *filename = [documentString stringByAppendingPathComponent:@"launch.plist"];
    
    NSDictionary *launchDic = [[NSDictionary alloc] initWithContentsOfFile:filename];
    
    if (launchDic == nil) {
        NSString *versionInfo = [dic objectForKey:@"CFBundleShortVersionString"];
        launchDic = [[NSDictionary alloc] initWithObjectsAndKeys:versionInfo,@"lastVersion" ,nil];
        [launchDic writeToFile:filename atomically:YES];
        
        return YES;
    }
    else{
        NSString *lastVersion = [launchDic objectForKey:@"lastVersion"];
        BOOL showInstruction = [[dic objectForKey:@"ShowInstruction"] boolValue];
        if ((![lastVersion isEqualToString:versionInfo]) && showInstruction) {
            
            NSString *versionInfo = [dic objectForKey:@"CFBundleShortVersionString"];
            launchDic = [[NSDictionary alloc] initWithObjectsAndKeys:versionInfo,@"lastVersion" ,nil];
            [launchDic writeToFile:filename atomically:YES];
            return YES;
        }
    }
    return NO;
}

- (void)launchBaiduMap
{
    // 要使用百度地图，请先启动BaiduMapManager
    _mapManager = [[BMKMapManager alloc]init];
    BOOL ret = [_mapManager start:BAIDUMAPKEY generalDelegate:self];
    if (!ret) {
        NSLog(@"manager start failed!");
    }
    else{
        NSLog(@"manager start success!");
    }
}

//初始化友盟的SDK
- (void)umengTrack
{
    [MobClick setLogEnabled:NO];  // 打开友盟sdk调试，注意Release发布时需要注释掉此行,减少io消耗
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [MobClick setAppVersion:version];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
        [MobClick setLogEnabled:YES];
        UMConfigInstance.appKey = UMANALYSISKEY;
        UMConfigInstance.secret = @"secretstringaldfkals";
        //    UMConfigInstance.eSType = E_UM_GAME;
        [MobClick startWithConfigure:UMConfigInstance];
        
        //        [MobClick startWithAppkey:UMANALYSISKEY reportPolicy:(ReportPolicy) SEND_INTERVAL channelId:nil];
    }
    else{
        [MobClick setLogEnabled:YES];
        UMConfigInstance.appKey = UMANALYSISKEY_HD;
        UMConfigInstance.secret = @"secretstringaldfkals";
        //    UMConfigInstance.eSType = E_UM_GAME;
        [MobClick startWithConfigure:UMConfigInstance];
        
        //        [MobClick startWithAppkey:UMANALYSISKEY_HD reportPolicy:(ReportPolicy) SEND_INTERVAL channelId:nil];
    }
    
    [MobClick setCrashReportEnabled:YES]; // 如果不需要捕捉异常，注释掉此行
    [MobClick setBackgroundTaskEnabled:YES];
    [MobClick setLogSendInterval:90];//每隔两小时上传一次
    //    [MobClick ];  //在线参数配置
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onlineConfigCallBack:) name:UMOnlineConfigDidFinishedNotification object:nil];
    
}

//初始化shareSDK
- (void)initshareSDK
{
    [ShareSDK registerApp:SHARESDKKEY
          activePlatforms:@[
                            @(SSDKPlatformSubTypeQZone),
                            @(SSDKPlatformTypeQQ),
                            @(SSDKPlatformTypeWechat)
                            ]
                 onImport:^(SSDKPlatformType platformType) {
                     
                     switch (platformType)
                     {
                         case SSDKPlatformTypeWechat:
                             [ShareSDKConnector connectWeChat:[WXApi class] delegate:self];
                             break;
                         case SSDKPlatformTypeQQ:
                             [ShareSDKConnector connectQQ:[QQApiInterface class]
                                        tencentOAuthClass:[TencentOAuth class]];
                             break;
                         default:
                             break;
                     }
                     
                 }
          onConfiguration:^(SSDKPlatformType platformType, NSMutableDictionary *appInfo) {
              
              switch (platformType)
              {
                  case SSDKPlatformTypeWechat:
                      [appInfo SSDKSetupWeChatByAppId:@"wxeb71d3d324b829f7"
                                            appSecret:@"e02faf49615c6c9208cd3510604e1599"];
                      break;
                  case SSDKPlatformTypeQQ:
                      [appInfo SSDKSetupQQByAppId:@"1105867459"
                                           appKey:@"o5DiIa7E8KR9OJn8"
                                         authType:SSDKAuthTypeBoth];
                      break;
                  default:
                      break;
              }
          }];
}

- (void)onlineConfigCallBack:(NSNotification *)note {
    
    NSLog(@"online config has fininshed and note = %@", note.userInfo);
}

- (void)networkDidSetup:(NSNotification *)notification {
    
    NSLog(@"已连接");
}

- (void)networkDidClose:(NSNotification *)notification {
    
    NSLog(@"未连接。。。");
}

- (void)networkDidRegister:(NSNotification *)notification {
    
    NSLog(@"已注册");
}

- (void)networkDidLogin:(NSNotification *)notification {
    
    NSLog(@"已登录");
}

- (void)serviceError:(NSNotification *)notification {
    //    NSDictionary *userInfo = [notification userInfo];
    //    NSString *error = [userInfo valueForKey:@"error"];
    //    NSLog(@"%@", error);
}


- (void)networkDidReceiveMessage:(NSNotification *)notification {
    //    NSDictionary * userInfo = [notification userInfo];
    //    NSString *title = [userInfo valueForKey:@"title"];
    //    NSString *content = [userInfo valueForKey:@"content"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    //如果在线的情况下所需要执行的方法
}

- (void)tagsAliasCallback:(int)iResCode tags:(NSSet*)tags alias:(NSString*)alias {
    NSLog(@"rescode: %d, \ntags: %@, \nalias: %@\n", iResCode, tags , alias);
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    if ([cancerOrderArray count] == 0) {
        [self performSelector:@selector(getCancelOrder) withObject:nil afterDelay:1.0];
    }
    
}

- (void)getCancelOrder
{
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    if (!userId) {
        userId = @"";
        return;
    }
    NSDictionary * params  = @{@"userId":userId};
    NSString *requestUrl = [NSString stringWithFormat:@"%@/orderSend/selectOrderInfoOfNotHandleBecancel.action",BASEURL];
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestUrl params:params success:^(AFHTTPRequestOperation* operation,id response){
        
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSDictionary *respondDict = [NSDictionary dictionaryWithDictionary:[respondString objectFromJSONString]];
        if ([[respondDict valueForKey:@"errorCode"] integerValue] == REQUESTCODE_SUCCEED){
            NSArray *jsonArray = respondDict[@"json"];
            if ([jsonArray isMemberOfClass:[NSNull class]]) {
                jsonArray = [NSArray array];
            }
            [cancerOrderArray removeAllObjects];
            for (NSDictionary *dict in jsonArray) {
                NSString *orderSendId = dict[@"orderSendId"];
                if ([orderSendId isMemberOfClass:[NSNull class]] || orderSendId == nil) {
                    orderSendId = @"";
                    continue;
                }
                BOOL haveOrder = NO;
                for (NSDictionary *myDict in cancerOrderArray) {
                    NSString *myOrderSendId = myDict[@"orderSendId"];
                    if ([myOrderSendId isMemberOfClass:[NSNull class]] || myOrderSendId == nil) {
                        myOrderSendId = @"";
                        continue;
                    }
                    if ([orderSendId isEqualToString:myOrderSendId]) {
                        haveOrder = YES;
                        break;
                    }
                }
                if (!haveOrder) {
                    [cancerOrderArray addObject:dict];
                }
            }
            if (!cancelOrderTimer) {
                cancelOrderTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(hanldeCancelOrder) userInfo:nil repeats:YES];
                [cancelOrderTimer fire];
            }
        }
        
    } failure:^(NSError* err){
        
    }];
}

- (void)hanldeCancelOrder
{
    if ([self.improcessOrderArray count] != 0) {
        return;
    }
    if ([cancerOrderArray count] == 0) {
        return;
    }
    self.improcessOrderArray = [[NSArray alloc] initWithObjects:cancerOrderArray[0], nil];
    NSDictionary *orderDetailDict = self.improcessOrderArray[0];
    NSString *orderName = orderDetailDict[@"orderSendServicecontent"];
    if ([orderName isMemberOfClass:[NSNull class]] || orderName == nil) {
        orderName = @"";
    }
    id zoneCreatetimeObj = [orderDetailDict objectForKey:@"orderSendGetOrderTime"];
    if ([zoneCreatetimeObj isMemberOfClass:[NSNull class]] || zoneCreatetimeObj == nil) {
        NSTimeInterval  timeInterval = [[NSDate date] timeIntervalSince1970];
        zoneCreatetimeObj = [NSString stringWithFormat:@"%.0f000",timeInterval];
    }
    long long timestamp = [zoneCreatetimeObj longLongValue];
    NSString *zoneCreatetime = [NSString stringWithFormat:@"%lld",timestamp];
    if ([zoneCreatetime length] > 3) {
        //时间戳
        zoneCreatetime = [zoneCreatetime substringToIndex:[zoneCreatetime length] - 3];
    }
    
    NSString *time = [Tool convertTimespToString:[zoneCreatetime longLongValue] dateFormate:@"yyyy/MM/dd HH:mm"];
    
    NSString *message = [NSString stringWithFormat:@"有护士取消了您的订单:%@(%@)，是否确认，若确认，我们将全额退还您的订单金额",orderName,time];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"确认取消" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        NSLog(@"取消");
//        NSString *currentSendId = self.improcessOrderArray[0][@"orderSendId"];
//        for (NSDictionary *dict in self.cancerOrderArray) {
//            NSString *temporderSendId = dict[@"orderSendId"];
//            if ([currentSendId isEqualToString:temporderSendId]) {
//                [self.cancerOrderArray removeObject:dict];
//                self.improcessOrderArray = nil; //清空处理池
//                break;
//            }
//        }
        
        [self agreeCancelOrder:NO];
    }];
    UIAlertAction *commitAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        NSLog(@"确认");
//        NSString *currentSendId = self.improcessOrderArray[0][@"orderSendId"];
//        for (NSDictionary *dict in self.cancerOrderArray) {
//            NSString *temporderSendId = dict[@"orderSendId"];
//            if ([currentSendId isEqualToString:temporderSendId]) {
//                [self.cancerOrderArray removeObject:dict];
//                self.improcessOrderArray = nil; //清空处理池
//                break;
//            }
//        }
        [self agreeCancelOrder:YES];
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:commitAction];
    [self.viewController presentViewController:alertController animated:YES completion:nil];
    
}

- (void)agreeCancelOrder:(BOOL)isAgree
{
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    if (!userId) {
        userId = @"";
    }
    NSDictionary *currentOrderDict = self.improcessOrderArray[0];
    
    NSString *orderSendId = currentOrderDict[@"orderSendId"];
    if ([orderSendId isMemberOfClass:[NSNull class]] || orderSendId == nil) {
        orderSendId = @"";
    }
    NSString *agreeState = @"1";  //0同意1不同意
    if (isAgree) {
        agreeState = @"0";
    }
    else{
        //不同意
        NSString *currentSendId = self.improcessOrderArray[0][@"orderSendId"];
        for (NSDictionary *dict in self.cancerOrderArray) {
            NSString *temporderSendId = dict[@"orderSendId"];
            if ([currentSendId isEqualToString:temporderSendId]) {
                [self.cancerOrderArray removeObject:dict];
                self.improcessOrderArray = nil; //清空处理池
                break;
            }
        }
        return;
    }
    NSDictionary * params  = @{@"orderSendId":orderSendId,@"userId":userId,@"agreeState":agreeState};
    NSString *requestUrl = [NSString stringWithFormat:@"%@/orderSend/agreecancelOrder.action",BASEURL];
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestUrl params:params success:^(AFHTTPRequestOperation* operation,id response){
        
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSDictionary *respondDict = [NSDictionary dictionaryWithDictionary:[respondString objectFromJSONString]];
        
        NSString *currentSendId = self.improcessOrderArray[0][@"orderSendId"];
        for (NSDictionary *dict in self.cancerOrderArray) {
            NSString *temporderSendId = dict[@"orderSendId"];
            if ([currentSendId isEqualToString:temporderSendId]) {
                [self.cancerOrderArray removeObject:dict];
                self.improcessOrderArray = nil; //清空处理池
                break;
            }
        }
        
        
    } failure:^(NSError* err){
        
    }];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_9_0
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options {
    /*
     此处必须执行,不然的话在设备安装支付宝app的情况下,
     使用支付宝支付时,获取不到支付结果的回调
     */
    NSString *appScheme = [Tool getAppScheme];
    //传过来的参数
    NSString *paramsID = [url host];
    NSLog(@"appScheme = %@, paramsID = %@",appScheme,paramsID);
    //根据不同的参数ID做不同处理
    //    [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic){
    //
    //    }];
    
    if ([url.host isEqualToString:@"safepay"]) {
        //跳转支付宝钱包进行支付，处理支付结果
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            NSLog(@"result = %@",resultDic);
            if ([[resultDic objectForKey:@"resultStatus"] isEqualToString:@"9000"]) {
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"GetAlipayResult" object:nil userInfo:@{@"result":@YES}];
                //------发送通知-------
                //                [[NSNotificationCenter defaultCenter] postNotificationName:@"realRecharge" object:nil userInfo:@{@"result":@"true"}];//发送通知,重新加载未支付订单
                
                //----未支付订单支付完成------发送通知--------
                //                [[NSNotificationCenter defaultCenter] postNotificationName:@"initOrderList" object:nil userInfo:nil];//发送通知,重新加载未支付订单
            }else if([[resultDic objectForKey:@"resultStatus"] isEqualToString:@"6001"]){
                //用户中途取消
                [[NSNotificationCenter defaultCenter] postNotificationName:@"GetAlipayResult" object:nil userInfo:@{@"result":@NO}];
            }
            else{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"GetAlipayResult" object:nil userInfo:@{@"result":@NO}];
            }
            
        }];
    }
    
    return YES;
}
#endif

//支付
//独立客户端回调函数,支付宝支付回调,分享回调,
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    //	[self parse:url application:application];
    //    danertuChunKang
    
    if ([[url scheme] isEqualToString:@"danertuChunKang"])
    {
        NSLog(@"%@",url);
    }
    return YES;
    /*
     return [ShareSDK handleOpenURL:url wxDelegate:self];
     return [ShareSDK handleOpenURL:url
     wxDelegate:self];
     */
}

//------分享使用------这个严重影响了支付宝支付结果的回调------
/*
 - (BOOL)application:(UIApplication *)application
 openURL:(NSURL *)url
 sourceApplication:(NSString *)sourceApplication
 annotation:(id)annotation
 {
 return [ShareSDK handleOpenURL:url
 sourceApplication:sourceApplication
 annotation:annotation
 wxDelegate:self];
 }
 */

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    /*
     此处必须执行,不然的话在设备安装支付宝app的情况下,
     使用支付宝支付时,获取不到支付结果的回调
     */
    NSString *appScheme = [Tool getAppScheme];
    //传过来的参数
    NSString *paramsID = [url host];
    NSLog(@"appScheme = %@, paramsID = %@",appScheme,paramsID);
    //根据不同的参数ID做不同处理
    //    [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic){
    //
    //    }];
    if ([url.host isEqualToString:@"safepay"]) {
        //跳转支付宝钱包进行支付，处理支付结果
        //跳转支付宝钱包进行支付，处理支付结果
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            NSLog(@"result = %@",resultDic);
            if ([[resultDic objectForKey:@"resultStatus"] isEqualToString:@"9000"]) {
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"GetAlipayResult" object:nil userInfo:@{@"result":@"YES"}];
                //------发送通知-------
                [[NSNotificationCenter defaultCenter] postNotificationName:@"realRecharge" object:nil userInfo:@{@"result":@"true"}];//发送通知,重新加载未支付订单
                
                //----未支付订单支付完成------发送通知--------
                [[NSNotificationCenter defaultCenter] postNotificationName:@"initOrderList" object:nil userInfo:nil];//发送通知,重新加载未支付订单
            }else if([[resultDic objectForKey:@"resultStatus"] isEqualToString:@"6001"]){
                //用户中途取消
                [[NSNotificationCenter defaultCenter] postNotificationName:@"GetAlipayResult" object:nil userInfo:@{@"result":@"NO"}];
            }
            
        }];
    }
    //    NSString *urlStr  = [url.absoluteString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //    NSLog(@"jgoreigoiejgioe--%@---%@--%@",urlStr,url,url.host);
    //    if ([url.host isEqualToString:@"safepay"]) {
    //        if ([urlStr rangeOfString:@"\"ResultStatus\":\"9000\""].location!=NSNotFound) {
    //            //------发送通知-------
    //            [[NSNotificationCenter defaultCenter] postNotificationName:@"realRecharge" object:nil userInfo:@{@"result":@"true"}];//发送通知,重新加载未支付订单
    //            NSLog(@"gjireojgieorg-----");
    //
    //            //----未支付订单支付完成------发送通知--------
    //            [[NSNotificationCenter defaultCenter] postNotificationName:@"initOrderList" object:nil userInfo:nil];//发送通知,重新加载未支付订单
    //        }
    //
    //        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic){
    //            NSLog(@"resultDic:%@",resultDic);
    //        }];
    //
    //        [[AlipaySDK defaultService] processAuth_V2Result:url
    //                                         standbyCallback:^(NSDictionary *resultDic) {
    //
    //                                             NSString *resultStr = resultDic[@"result"];
    //                                             NSLog(@"hfeufhe = %@,%@",resultDic,resultStr);
    //                                             [[NSNotificationCenter defaultCenter] postNotificationName:@"realRecharge" object:nil userInfo:@{@"result":@"true"}];//发送通知,重新加载未支付订单
    //                                         }];
    //    }
    
    return YES;
}

@end

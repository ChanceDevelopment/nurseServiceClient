//
//  HeTabBarVC.m
//  huayoutong
//
//  Created by HeDongMing on 16/3/2.
//  Copyright © 2016年 HeDongMing. All rights reserved.
//

#import "HeTabBarVC.h"
#import "RDVTabBarItem.h"
#import "RDVTabBar.h"
#import "RDVTabBarController.h"
#import "HeSysbsModel.h"
#import <BaiduMapAPI_Location/BMKLocationService.h>
#import <BaiduMapAPI_Search/BMKGeocodeSearch.h>

#define MinLocationSucceedNum 1   //要求最少成功定位的次数

@interface HeTabBarVC ()<BMKLocationServiceDelegate,BMKGeoCodeSearchDelegate,CLLocationManagerDelegate>
{
    BMKLocationService *_locService;
    BMKGeoCodeSearch *_geoSearch;
}
//定位
@property (nonatomic,assign)NSInteger locationSucceedNum; //定位成功的次数
@property (nonatomic,strong)NSMutableDictionary *userLocationDict;
@property (nonatomic,strong)NSMutableArray *cancerOrderArray;

@end

@implementation HeTabBarVC
@synthesize homePageVC;
@synthesize nurseVC;
@synthesize orderVC;
@synthesize userVC;
@synthesize cancerOrderArray;

@synthesize locationSucceedNum;
@synthesize userLocationDict;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //获取用户资料
    [self getUserInfoWithUserID:[[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getUserPayInfo) name:kUpdateUserPayInfoNotificaiton object:nil];
    cancerOrderArray = [[NSMutableArray alloc] initWithCapacity:0];
    //获取左边侧栏的菜单
    [self loadLeftMenu];
    [self autoLogin];
    [self setupSubviews];
    [self initLocationService];
    //获取用户的地理位置
    [self getLocation];
    //获取医院分类数据
    [self getHospitalData];
    //获取专业分类数据
    [self getMajorData];
    [self getUserPayInfo];
    //获取取消的订单
    [self getCancelOrder];
    [Tools initPush];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    [_locService stopUserLocationService];
    _geoSearch.delegate = nil;
}

- (void)getCancelOrder
{
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    if (!userId) {
        userId = @"";
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
            cancerOrderArray = [[NSMutableArray alloc] initWithArray:jsonArray];
        }
        
    } failure:^(NSError* err){
        
    }];
}

- (void)getUserPayInfo
{
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    if (!userId) {
        userId = @"";
    }
    NSDictionary * params  = @{@"userId":userId};
    NSString *requestUrl = [NSString stringWithFormat:@"%@/nurseAnduser/selectUserThreeInfo.action",BASEURL];
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestUrl params:params success:^(AFHTTPRequestOperation* operation,id response){
        
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSDictionary *respondDict = [NSDictionary dictionaryWithDictionary:[respondString objectFromJSONString]];
        if ([[respondDict valueForKey:@"errorCode"] integerValue] == REQUESTCODE_SUCCEED){
            NSDictionary *payInfo = respondDict[@"json"];
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:payInfo];
            NSArray *keyArray = dict.allKeys;
            for (NSString *key in keyArray) {
                id obj = dict[key];
                if ([obj isMemberOfClass:[NSNull class]] || obj == nil) {
                    obj = @"";
                }
                [dict setObject:obj forKey:key];
            }
            payInfo = [[NSDictionary alloc] initWithDictionary:dict];
            [[NSUserDefaults standardUserDefaults] setObject:payInfo forKey:kUserPayInfoKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
    } failure:^(NSError* err){
        
    }];
}

- (void)initLocationService
{
    //初始化BMKLocationService
    _locService = [[BMKLocationService alloc] init];
    _locService.delegate = self;
    //启动LocationService
    _locService.desiredAccuracy = kCLLocationAccuracyBest;
    _locService.distanceFilter  = 1.5f;
    
    _geoSearch = [[BMKGeoCodeSearch alloc] init];
    _geoSearch.delegate = self;
    
    userLocationDict = [[NSMutableDictionary alloc] initWithCapacity:0];
    locationSucceedNum = 0;
}

//后台自动登录
- (void)autoLogin
{
    NSString *account = [[NSUserDefaults standardUserDefaults] objectForKey:USERPASSWORDKEY];
    if (!account) {
        account = @"";
    }
    NSString *password = [[NSUserDefaults standardUserDefaults] objectForKey:USERACCOUNTKEY];
    if (!password) {
        password = @"";
    }
    
    NSString *requestUrl = [NSString stringWithFormat:@"%@/nurseAnduser/UserLogin.action",BASEURL];
    NSDictionary * params  = @{@"UserName": account,@"UserPwd" : password};
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestUrl params:params success:^(AFHTTPRequestOperation* operation,id response){
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        
        NSDictionary *respondDict = [NSDictionary dictionaryWithDictionary:[respondString objectFromJSONString]];
        if ([[[respondDict valueForKey:@"errorCode"] stringValue] isEqualToString:@"200"]) {
            NSLog(@"success");
            
            NSDictionary *userInfoDic = [NSDictionary dictionaryWithDictionary:[respondDict valueForKey:@"json"]];
            NSMutableDictionary *nurseDic = [NSMutableDictionary dictionaryWithCapacity:0];
            
            for (NSString *key in [userInfoDic allKeys]) {
                
                if ([[NSString stringWithFormat:@"%@",[userInfoDic valueForKey:key]] isEqualToString:@"<null>"]) {
                    NSLog(@"key:%@",key);
                    [nurseDic setValue:@"" forKey:key];
                }else{
                    [nurseDic setValue:[NSString stringWithFormat:@"%@",[userInfoDic valueForKey:key]] forKey:key];
                }
            }
            NSLog(@"%@",nurseDic);
            //用户的资料
            NSString *userId = [userInfoDic valueForKey:@"nurseId"];
            if ([userId isMemberOfClass:[NSNull class]] || userId == nil) {
                userId = @"";
            }
            
            [[NSUserDefaults standardUserDefaults] setObject:account forKey:USERACCOUNTKEY];
            [[NSUserDefaults standardUserDefaults] setObject:nurseDic forKey:kUserDataKey];
            [[NSUserDefaults standardUserDefaults] setObject:userId forKey:USERIDKEY];
            [[NSUserDefaults standardUserDefaults] setObject:password forKey:USERPASSWORDKEY];
            
            [[NSUserDefaults standardUserDefaults] synchronize];//强制写入,保存数据
            
        }else{
            
            NSLog(@"faile");
        }
    } failure:^(NSError* err){
        
    }];
}

- (void)loadLeftMenu
{
    NSString *requestUrl = [NSString stringWithFormat:@"%@/NursingReport.action",BASEURL];
    NSDictionary * params  = @{@"1": @"1"};
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestUrl params:params success:^(AFHTTPRequestOperation* operation,id response){
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        
        NSDictionary *respondDict = [NSDictionary dictionaryWithDictionary:[respondString objectFromJSONString]];
        if ([[respondDict valueForKey:@"errorCode"] integerValue] == REQUESTCODE_SUCCEED){
            
            NSArray *menuArray = [[NSArray alloc] initWithArray:[respondDict valueForKey:@"json"]];
            [HeSysbsModel getSysModel].menuArray = menuArray;
            [[NSNotificationCenter defaultCenter] postNotificationName:kLoadLeftMenuNotification object:menuArray];
            
        }
    } failure:^(NSError* err){
        
    }];
}

- (void)udpateUserLocationWithLocation:(NSDictionary *)locationDict
{
    NSString *userid = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    if (!userid) {
        userid = @"";
    }
    NSString *latitude = locationDict[@"latitude"];
    if (!latitude) {
        latitude = @"";
    }
    NSString *longitude = locationDict[@"longitude"];
    if (!longitude) {
        longitude = @"";
    }
    
    NSString *requestUrl = [NSString stringWithFormat:@"%@/latitude/userlatiude.action",BASEURL];
    NSDictionary * params  = @{@"userid":userid,@"latitude": latitude,@"longitude":longitude};
    
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestUrl params:params success:^(AFHTTPRequestOperation* operation,id response){
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        
        NSDictionary *respondDict = [NSDictionary dictionaryWithDictionary:[respondString objectFromJSONString]];
        if ([[respondDict valueForKey:@"errorCode"] integerValue] == REQUESTCODE_SUCCEED){
            NSLog(@"update Location Succeed!");
            
        }
    } failure:^(NSError* err){
        
    }];
}

- (void)clearInfo
{
    
}

//获取医院分类数据
- (void)getHospitalData
{
    NSString *requestUrl = [NSString stringWithFormat:@"%@/nurseAnduser/selecthospitalandmajor.action",BASEURL];
    NSDictionary * params  = @{@"1": @"1"};
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestUrl params:params success:^(AFHTTPRequestOperation* operation,id response){
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        
        NSDictionary *respondDict = [NSDictionary dictionaryWithDictionary:[respondString objectFromJSONString]];
        if ([[respondDict valueForKey:@"errorCode"] integerValue] == REQUESTCODE_SUCCEED){
            
            NSArray *menuArray = [[NSArray alloc] initWithArray:[respondDict valueForKey:@"json"]];
            [HeSysbsModel getSysModel].hospitalArray = [[NSArray alloc] initWithArray:menuArray];
            [[NSNotificationCenter defaultCenter] postNotificationName:kLoadHospitalDataNotification object:menuArray];
            
        }
    } failure:^(NSError* err){
        
    }];
}

//获取专业分类数据
- (void)getMajorData
{
    NSString *requestUrl = [NSString stringWithFormat:@"%@/nurseAnduser/SelectMajorAndHospital.action",BASEURL];
    NSDictionary * params  = @{@"1": @"1"};
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestUrl params:params success:^(AFHTTPRequestOperation* operation,id response){
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        
        NSDictionary *respondDict = [NSDictionary dictionaryWithDictionary:[respondString objectFromJSONString]];
        if ([[respondDict valueForKey:@"errorCode"] integerValue] == REQUESTCODE_SUCCEED){
            
            NSArray *menuArray = [[NSArray alloc] initWithArray:[respondDict valueForKey:@"json"]];
            [HeSysbsModel getSysModel].majorArray = [[NSArray alloc] initWithArray:menuArray];
            [[NSNotificationCenter defaultCenter] postNotificationName:kLoadMajorDataNotification object:menuArray];
            
        }
    } failure:^(NSError* err){
        
    }];
}

//获取用户的信息
- (void)getUserInfoWithUserID:(NSString *)userid
{
    if (!userid) {
        userid = @"";
    }
    
    NSString *requestUrl = [NSString stringWithFormat:@"%@/nurseAnduser/selectuserinfobyid.action",BASEURL];
    NSDictionary * params  = @{@"userid":userid};
    
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestUrl params:params success:^(AFHTTPRequestOperation* operation,id response){
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        
        NSDictionary *respondDict = [NSDictionary dictionaryWithDictionary:[respondString objectFromJSONString]];
        if ([[respondDict valueForKey:@"errorCode"] integerValue] == REQUESTCODE_SUCCEED){
            NSDictionary *userDetailInfoDict = respondDict[@"json"];
            if ([userDetailInfoDict isMemberOfClass:[NSNull class]]) {
                return;
            }
            NSMutableDictionary *infoDict = [NSMutableDictionary dictionaryWithCapacity:0];
            
            for (NSString *key in [userDetailInfoDict allKeys]) {
                id obj = [userDetailInfoDict objectForKey:key];
                if ([obj isMemberOfClass:[NSNull class]] || obj == nil) {
                    obj = @"";
                }
                [infoDict setObject:obj forKey:key];
            }
            
            [[NSUserDefaults standardUserDefaults] setObject:infoDict forKey:kUserDetailDataKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            User *userModel = [[User alloc] init];
            [userModel setValuesForKeysWithDictionary:infoDict];
            NSLog(@"userModel = %@",userModel);
            NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDetailDataKey];
            [HeSysbsModel getSysModel].user = userModel;;
            
        }
    } failure:^(NSError* err){
        
    }];
}


//设置根控制器的四个子控制器
- (void)setupSubviews
{
    homePageVC = [[FirstViewController alloc] init];
    CustomNavigationController *homePageNav = [[CustomNavigationController alloc] initWithRootViewController:homePageVC];
    
    nurseVC = [[NurseViewController alloc] init];
    CustomNavigationController *nurseNav = [[CustomNavigationController alloc]
                                           initWithRootViewController:nurseVC];
    
    orderVC = [[OrderViewController alloc] init];
    CustomNavigationController *orderNav = [[CustomNavigationController alloc]
                                            initWithRootViewController:orderVC];
    
    userVC = [[MyViewController alloc] init];
    CustomNavigationController *userNav = [[CustomNavigationController alloc]
                                            initWithRootViewController:userVC];
    
    [self setViewControllers:@[homePageNav,nurseNav,orderNav,userNav]];
    [self customizeTabBarForController];
}

//设置底部的tabbar
- (void)customizeTabBarForController{
    //    tabbar_normal_background   tabbar_selected_background
    UIImage *finishedImage = [UIImage imageNamed:@"tabbar_normal_background"];
    UIImage *unfinishedImage = [UIImage imageNamed:@"tabbar_normal_background"];
    NSArray *tabBarItemImages = @[@"main_home", @"main_nurse", @"main_order", @"main_mine"];
    
    NSInteger index = 0;
    for (RDVTabBarItem *item in [[self tabBar] items]) {
        [item setBackgroundSelectedImage:finishedImage withUnselectedImage:unfinishedImage];
        UIImage *selectedimage = [UIImage imageNamed:[NSString stringWithFormat:@"%@_selector",
                                                      [tabBarItemImages objectAtIndex:index]]];
        UIImage *unselectedimage = [UIImage imageNamed:[NSString stringWithFormat:@"%@_unselector",
                                                        [tabBarItemImages objectAtIndex:index]]];
        [item setFinishedSelectedImage:selectedimage withFinishedUnselectedImage:unselectedimage];
        
        index++;
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 100) {
        //后台自动登录失败，退出登录
        [self clearInfo];
    }
}

- (void)getLocation
{
    if([CLLocationManager locationServicesEnabled] && [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"定位服务未开启" message:@"请在系统设置中开启定位服务设置->隐私->定位服务" delegate:self cancelButtonTitle:@"我知道了" otherButtonTitles:nil, nil];
        [alertView show];
    }else{
        [_locService startUserLocationService];
    }
}

//处理位置坐标更新
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    //NSLog(@"didUpdateUserLocation lat %f,long %f",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude);
    CLLocation *newLocation = userLocation.location;
    CLLocationCoordinate2D coordinate = newLocation.coordinate;
    
    NSString *latitudeStr = [NSString stringWithFormat:@"%.6f",coordinate.latitude];
    NSString *longitudeStr = [NSString stringWithFormat:@"%.6f",coordinate.longitude];
    
    [self udpateUserLocationWithLocation:@{@"latitude":latitudeStr,@"longitude":longitudeStr}];
    
    if (newLocation && ![userLocationDict objectForKey:@"latitude"]) {
        locationSucceedNum = locationSucceedNum + 1;
        if (locationSucceedNum >= MinLocationSucceedNum) {
            [self hideHud];
            locationSucceedNum = 0;
            [userLocationDict setObject:latitudeStr forKey:@"latitude"];
            [userLocationDict setObject:longitudeStr forKey:@"longitude"];
            [_locService stopUserLocationService];
            
            BMKReverseGeoCodeOption *reverseGeoCodeOption = [[BMKReverseGeoCodeOption alloc] init];
            
            reverseGeoCodeOption.reverseGeoPoint = coordinate;
            _geoSearch.delegate = self;
            //进行反地理编码
            [_geoSearch reverseGeoCode:reverseGeoCodeOption];
            
            //更新用户坐标
            NSString *latitudeStr = [userLocationDict objectForKey:@"latitude"];
            if (latitudeStr == nil) {
                latitudeStr = @"";
            }
            NSString *longitudeStr = [userLocationDict objectForKey:@"longitude"];
            if (longitudeStr == nil) {
                longitudeStr = @"";
            }
            [HeSysbsModel getSysModel].userLocationDict = [[NSDictionary alloc] initWithDictionary:userLocationDict];
            
        }
    }
}


- (void)didFailToLocateUserWithError:(NSError *)error
{
    [self hideHud];
    [self showHint:@"定位失败!"];
}

- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error
{
    NSLog(@"地址是：%@,%@",result.address,result.addressDetail);
    NSString *cityString = result.addressDetail.city;
    //记录当前的定位城市
    [[NSUserDefaults standardUserDefaults] setObject:cityString forKey:kPreLocationCityKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSLog(@"当前城市是：%@",cityString);
    [HeSysbsModel getSysModel].addressResult = result;
    if (![[HeSysbsModel getSysModel].userCity isEqualToString:cityString]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kGetCitySucceedNotification object:cityString];
    }
    
    
}

- (void)onGetGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error
{
    NSLog(@"%@",result.address);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kUpdateUserPayInfoNotificaiton object:nil];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
